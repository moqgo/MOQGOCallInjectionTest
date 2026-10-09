import SwiftUI
import AVFAudio
import Accessibility
import UniformTypeIdentifiers

// In the existing source file so the original Xcode target needs no new references.
@MainActor
final class InjectionController: ObservableObject {
    @Published private(set) var permission = "UNKNOWN"
    @Published private(set) var availability = "UNKNOWN"
    @Published private(set) var preferredMode = "UNKNOWN"
    @Published private(set) var log = ""
    @Published private(set) var isRequestingPermission = false
    @Published private(set) var importedAudioName = ""
    @Published private(set) var playbackRequested = false

    private let session = AVAudioSession.sharedInstance()
    // Retain playback objects for the whole playback, rather than a button's stack frame.
    private var synthesizer = AVSpeechSynthesizer()
    private var player: AVAudioPlayer?
    private var audioData: Data?

    init() {
        refreshStatus()
        append("Runtime initialized. Availability requires a notification; UNKNOWN is not NO.")
    }

    var canPlay: Bool {
        permission == "GRANTED" && preferredMode == "SPOKEN_AUDIO" && availability != "NO"
    }
    var hasImportedAudio: Bool { audioData != nil }

    func append(_ message: String) {
        let time = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let lines = (log + "\n[\(time)] \(message)").split(separator: "\n")
        log = lines.suffix(150).joined(separator: "\n")
    }

    func refreshStatus() {
        switch AVAudioApplication.shared.microphoneInjectionPermission {
        case .undetermined: permission = "UNDETERMINED"
        case .granted: permission = "GRANTED"
        case .denied: permission = "DENIED"
        case .serviceDisabled: permission = "SERVICE_DISABLED"
        @unknown default: permission = "UNKNOWN"
        }
        switch session.preferredMicrophoneInjectionMode {
        case .none: preferredMode = "NONE"
        case .spokenAudio: preferredMode = "SPOKEN_AUDIO"
        @unknown default: preferredMode = "UNKNOWN"
        }
        // Do not infer call availability from permission or the preferred mode.
        if permission != "GRANTED" || preferredMode != "SPOKEN_AUDIO" { stopPlayback() }
    }

    func requestPermission() async {
        guard !isRequestingPermission else { return }
        refreshStatus()
        guard permission == "UNDETERMINED" else {
            append("Permission: \(permission). SERVICE_DISABLED/DENIED must be changed in Settings.")
            return
        }
        isRequestingPermission = true
        defer { isRequestingPermission = false }
        _ = await AVAudioApplication.requestMicrophoneInjectionPermission()
        refreshStatus()
        append("Permission response: \(permission).")
    }

    func enableInjection() async {
        await requestPermission()
        refreshStatus()
        guard permission == "GRANTED" else {
            append("Cannot enable injection: \(permission).")
            return
        }
        setMode(.spokenAudio)
    }

    func disableInjection() {
        stopPlayback()
        setMode(.none)
    }

    private func setMode(_ mode: AVAudioSession.MicrophoneInjectionMode) {
        do {
            // Follow Apple's sample without taking over the call app's recording session.
            try session.setPreferredMicrophoneInjectionMode(mode)
            refreshStatus()
            append("Preferred mode: \(preferredMode). This is not proof of remote delivery.")
        } catch {
            refreshStatus()
            let nsError = error as NSError
            append("Injection error: \(nsError.domain) / \(nsError.code): \(nsError.localizedDescription)")
        }
    }

    func capabilitiesChanged(_ notification: Notification) {
        guard let available = notification.userInfo?[AVAudioSessionMicrophoneInjectionIsAvailableKey] as? Bool else {
            availability = "UNKNOWN"
            append("Capability notification did not contain Boolean availability.")
            return
        }
        availability = available ? "YES" : "NO"
        if !available { stopPlayback() }
        refreshStatus()
        append("System injection availability: \(availability).")
    }

    func mediaServicesReset() {
        let shouldRestore = preferredMode == "SPOKEN_AUDIO"
        stopPlayback()
        synthesizer = AVSpeechSynthesizer()
        player = nil
        availability = "UNKNOWN"
        refreshStatus()
        append("Media services reset; recreated playback objects. Awaiting capability notification.")
        if shouldRestore && permission == "GRANTED" { setMode(.spokenAudio) }
    }

    func interrupted(_ notification: Notification) {
        guard let type = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        if type == AVAudioSession.InterruptionType.began.rawValue {
            stopPlayback()
            append("Audio session interrupted. Stopped playback; no automatic replay.")
        } else {
            refreshStatus()
            append("Interruption ended. Check the call and retry manually.")
        }
    }

    private func preparePlayback() -> Bool {
        refreshStatus()
        guard canPlay else {
            append("Blocked: permission=\(permission), mode=\(preferredMode), availability=\(availability).")
            return false
        }
        stopPlayback()
        if availability == "UNKNOWN" {
            append("No capability notification observed. Open this app BEFORE starting the call. This attempt is unverified.")
        }
        return true
    }

    func playTestSpeech() {
        guard preparePlayback() else { return }
        let utterance = AVSpeechUtterance(string: "Hello, this is a MOQGO translation test.")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
        playbackRequested = true
        append("Test speech queued. Only the receiving device can confirm it was heard.")
    }

    func importAudio(from url: URL) {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        do {
            let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            guard size > 0 && size <= 20 * 1024 * 1024 else {
                append("Choose nonempty spoken audio of at most 20 MB.")
                return
            }
            let data = try Data(contentsOf: url)
            guard !data.isEmpty && data.count <= 20 * 1024 * 1024 else {
                append("Audio data is empty or exceeds 20 MB.")
                return
            }
            // Validate decoding without prepareToPlay(), which may activate an audio session.
            // Importing a file must not change the ongoing call's audio route.
            _ = try AVAudioPlayer(data: data)
            stopPlayback()
            audioData = data
            importedAudioName = url.lastPathComponent
            append("Imported: \(importedAudioName), \(data.count) bytes. Not yet played or delivered.")
        } catch {
            append("Import failed: \(error.localizedDescription)")
        }
    }

    func playImportedAudio() {
        guard let data = audioData, preparePlayback() else { return }
        do {
            // Playback-only and mix with the call; do not request the call's recording input.
            try session.setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers])
            try session.setActive(true)
            // Reapply injection after configuring the playback session, then check the actual preference.
            try session.setPreferredMicrophoneInjectionMode(.spokenAudio)
            refreshStatus()
            guard canPlay else {
                append("Playback cancelled: injection is no longer enabled or available.")
                return
            }
            let outputs = session.currentRoute.outputs.map { $0.portType.rawValue }.joined(separator: ",")
            append("Playback route: \(outputs); injection preference: \(preferredMode).")
            player = try AVAudioPlayer(data: data)
            guard player?.prepareToPlay() == true, player?.play() == true else {
                append("Audio player could not start.")
                return
            }
            playbackRequested = true
            append("Player started: \(importedAudioName). Remote delivery remains unverified.")
        } catch {
            append("Playback failed: \(error.localizedDescription)")
        }
    }

    func stopPlayback() {
        synthesizer.stopSpeaking(at: .immediate)
        player?.stop()
    }

    func openSettings() async {
        do {
            try await AccessibilitySettings.openSettings(for: .allowAppsToAddAudioToCalls)
        } catch {
            append("Open Settings failed: \(error.localizedDescription). Open Accessibility > Audio & Visual > Add Audio in Calls manually.")
        }
    }
}

@MainActor
struct ContentView: View {
    @StateObject private var audio = InjectionController()
    @Environment(\.scenePhase) private var scenePhase
    @State private var showImporter = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    GroupBox("Status - device test required") {
                        VStack(alignment: .leading, spacing: 8) {
                            statusRow("Injection Permission", audio.permission)
                            statusRow("Injection Available", audio.availability)
                            statusRow("Preferred Mode", audio.preferredMode)
                            Text("Remote delivery: NOT VERIFIED")
                                .font(.headline).foregroundStyle(.orange)
                        }
                    }
                    Text("Open this app first, request permission and enable injection, then start a WhatsApp call and return here. Use headphones and keep the call microphone unmuted. SPOKEN_AUDIO is only a preference; the receiving device must hear the test.")
                        .font(.footnote)
                    Button("Open Add Audio in Calls Settings") { Task { await audio.openSettings() } }
                    Button("Request Permission") { Task { await audio.requestPermission() } }
                        .disabled(audio.isRequestingPermission)
                    Button("Enable Injection") { Task { await audio.enableInjection() } }
                        .disabled(audio.isRequestingPermission)
                    Button("Play Test Speech") { audio.playTestSpeech() }
                        .disabled(!audio.canPlay)
                    Button("Import Windows TTS Audio") { showImporter = true }
                    if audio.hasImportedAudio {
                        Text(audio.importedAudioName).font(.caption)
                        Button("Play Imported Speech into Call") { audio.playImportedAudio() }
                            .disabled(!audio.canPlay)
                    }
                    Button("Stop Playback") { audio.stopPlayback() }
                    Button("Disable Injection", role: .destructive) { audio.disableInjection() }
                    Button("Refresh Permission and Mode") {
                        audio.refreshStatus()
                        audio.append("Refreshed permission and mode. Availability is notification-based.")
                    }
                    ShareLink(item: report) { Label("Share Diagnostic Report", systemImage: "square.and.arrow.up") }
                    GroupBox("Log") {
                        Text(audio.log).font(.system(.caption, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                }
                .padding()
                .buttonStyle(.bordered)
            }
            .navigationTitle("MOQGO Call Injection")
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.audio]) { result in
            switch result {
            case .success(let url): audio.importAudio(from: url)
            case .failure(let error): audio.append("File selection failed: \(error.localizedDescription)")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.microphoneInjectionCapabilitiesChangeNotification)) {
            audio.capabilitiesChanged($0)
        }
        .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.mediaServicesWereResetNotification)) { _ in
            audio.mediaServicesReset()
        }
        .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)) {
            audio.interrupted($0)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                audio.refreshStatus()
                audio.append("App active; rechecked permission and preferred mode.")
            }
        }
    }

    private func statusRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).bold()
        }.font(.subheadline)
    }

    private var report: String {
        """
        IOS_VERSION: \(ProcessInfo.processInfo.operatingSystemVersionString)
        APP_VERSION: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "UNKNOWN")
        BUILD_SOURCE_SHA: \(Bundle.main.object(forInfoDictionaryKey: "MOQGOBuildSourceSHA") as? String ?? "LOCAL")
        DEVICE_MODEL: FILL_IN
        WHATSAPP_VERSION: FILL_IN
        MICROPHONE_INJECTION_PERMISSION: \(audio.permission)
        LATEST_INJECTION_AVAILABILITY_NOTIFICATION: \(audio.availability)
        PREFERRED_MODE: \(audio.preferredMode)
        PLAYBACK_REQUESTED: \(audio.playbackRequested ? "YES" : "NO")
        REMOTE_SIDE_HEARD_TEST_AUDIO: NOT_VERIFIED
        WHATSAPP_CALL_INJECTION: NOT_VERIFIED

        \(audio.log)
        """
    }
}
