//
//  ContentView.swift
//  MOQGOCallInjectionTest
//
//  iPhone Microphone Injection PoC for WhatsApp Voice Call Translation
//

import SwiftUI
import AVFAudio

struct ContentView: View {
    @State private var permissionStatus: String = "UNKNOWN"
    @State private var injectionAvailable: String = "UNKNOWN"
    @State private var preferredMode: String = "UNKNOWN"
    @State private var logMessage: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 状态卡片
                    statusCard

                    // 按钮组
                    buttonGroup

                    // 日志
                    logCard
                }
                .padding()
            }
            .navigationTitle("MOQGO Call Injection")
            .onAppear {
                refreshStatus()
            }
        }
    }

    // MARK: - 状态卡片
    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("状态")
                .font(.headLine)

            statusRow(label: "Microphone Injection Permission", value: permissionStatus)
            statusRow(label: "Injection Available", value: injectionAvailable)
            statusRow(label: "Preferred Mode", value: preferredMode)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func statusRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(statusColor(value))
        }
    }

    private func statusColor(_ value: String) -> Color {
        switch value {
        case "GRANTED", "YES", "SPOKEN_AUDIO":
            return .green
        case "DENIED", "NO", "SERVICE_DISABLED":
            return .red
        default:
            return .orange
        }
    }

    // MARK: - 按钮组
    private var buttonGroup: some View {
        VStack(spacing: 12) {
            Button(action: requestPermission) {
                Text("Request Permission")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: enableInjection) {
                Text("Enable Injection")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: playTestSpeech) {
                Text("Play Test Speech")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: disableInjection) {
                Text("Disable Injection")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: refreshStatus) {
                Text("Refresh Status")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }

    // MARK: - 日志卡片
    private var logCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("日志")
                .font(.headLine)
            Text(logMessage)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - 功能方法

    /// 刷新所有状态
    private func refreshStatus() {
        logMessage = "刷新状态..."

        // 1. Microphone Injection Permission
        if #available(iOS 18.2, *) {
            let status = AVAudioApplication.shared.microphoneInjectionPermission
            switch status {
            case .serviceDisabled:
                permissionStatus = "SERVICE_DISABLED"
            case .undetermined:
                permissionStatus = "UNDETERMINED"
            case .granted:
                permissionStatus = "GRANTED"
            case .denied:
                permissionStatus = "DENIED"
            @unknown default:
                permissionStatus = "UNKNOWN(\(status.rawValue))"
            }
        } else {
            permissionStatus = "NOT_SUPPORTED"
            logMessage += "\niOS 版本不支持 Microphone Injection (需要 iOS 18.2+)"
        }

        // 2. Injection Available
        let available = AVAudioSession.sharedInstance().isMicrophoneInjectionAvailable
        injectionAvailable = available ? "YES" : "NO"

        // 3. Preferred Mode
        if #available(iOS 18.2, *) {
            let mode = AVAudioSession.sharedInstance().preferredMicrophoneInjectionMode
            switch mode {
            case .none:
                preferredMode = "NONE"
            case .spokenAudio:
                preferredMode = "SPOKEN_AUDIO"
            @unknown default:
                preferredMode = "UNKNOWN"
            }
        } else {
            preferredMode = "NOT_SUPPORTED"
        }

        logMessage += "\n权限: \(permissionStatus)"
        logMessage += "\n可用: \(injectionAvailable)"
        logMessage += "\n模式: \(preferredMode)"
    }

    /// 请求 Microphone Injection 权限
    private func requestPermission() {
        logMessage = "请求权限..."

        if #available(iOS 18.2, *) {
            AVAudioApplication.requestMicrophoneInjectionPermission { granted in
                DispatchQueue.main.async {
                    logMessage += "\n权限请求结果: \(granted ? "GRANTED" : "DENIED")"
                    refreshStatus()
                }
            }
        } else {
            logMessage += "\niOS 版本不支持"
        }
    }

    /// 开启 Microphone Injection
    private func enableInjection() {
        logMessage = "开启 Injection..."

        do {
            if #available(iOS 18.2, *) {
                try AVAudioSession.sharedInstance().setPreferredMicrophoneInjectionMode(.spokenAudio)
                logMessage += "\n成功设置为 SPOKEN_AUDIO"
            } else {
                logMessage += "\niOS 版本不支持"
            }
            refreshStatus()
        } catch {
            logMessage += "\n错误: \(error.localizedDescription)"
        }
    }

    /// 关闭 Microphone Injection
    private func disableInjection() {
        logMessage = "关闭 Injection..."

        do {
            if #available(iOS 18.2, *) {
                try AVAudioSession.sharedInstance().setPreferredMicrophoneInjectionMode(.none)
                logMessage += "\n成功设置为 NONE"
            } else {
                logMessage += "\niOS 版本不支持"
            }
            refreshStatus()
        } catch {
            logMessage += "\n错误: \(error.localizedDescription)"
        }
    }

    /// 播放测试语音
    private func playTestSpeech() {
        logMessage = "播放测试语音..."

        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: "Hello, this is a MOQGO translation test.")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate

        synthesizer.speak(utterance)
        logMessage += "\n已播放: Hello, this is a MOQGO translation test."
    }
}

#Preview {
    ContentView()
}
