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
                    statusCard
                    buttonGroup
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

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("鐘舵€?)
                .font(.headline)
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

    private var logCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("鏃ュ織")
                .font(.headline)
            Text(logMessage)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func refreshStatus() {
        logMessage = "鍒锋柊鐘舵€?.."
        permissionStatus = "NOT_SUPPORTED"
        injectionAvailable = "UNKNOWN"
        preferredMode = "NOT_SUPPORTED"
        logMessage += "\n闇€瑕?iOS 18.2+ 鍜?Xcode 16 SDK 鏀寔 Microphone Injection"
    }

    private func requestPermission() {
        logMessage += "\n闇€瑕?iOS 18.2+ 鍜?Xcode 16 SDK"
    }

    private func enableInjection() {
        logMessage += "\n闇€瑕?iOS 18.2+ 鍜?Xcode 16 SDK"
    }

    private func disableInjection() {
        logMessage += "\n闇€瑕?iOS 18.2+ 鍜?Xcode 16 SDK"
    }

    private func playTestSpeech() {
        logMessage = "鎾斁娴嬭瘯璇煶..."
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: "Hello, this is a MOQGO translation test.")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
        logMessage += "\n宸叉挱鏀? Hello, this is a MOQGO translation test."
    }
}

#Preview {
    ContentView()
}
