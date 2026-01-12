//
//  MicButtonSimple.swift
//  VoiceLog
//
//  Created by 後藤吏希 on 2025/12/29.
//

import SwiftUI

struct MicButton: View {
    let isRecording: Bool
    var isEnabled: Bool = true
    let action: () -> Void

    @State private var pulsing = false

    private let micColor = Color(red: 0.35, green: 0.16, blue: 0.18)

    // ✅ 追加：昔の呼び出し (isOn:) でも使えるようにする
    init(isOn: Bool, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.isRecording = isOn
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                if isRecording {
                    Circle()
                        .stroke(micColor.opacity(0.35), lineWidth: 10)
                        .frame(width: 88, height: 88)
                        .scaleEffect(pulsing ? 1.18 : 0.86)
                        .opacity(pulsing ? 0.0 : 1.0)
                }

                Circle()
                    .fill(Color(red: 0.33, green: 0.12, blue: 0.15))
                    .shadow(color: .black.opacity(0.20), radius: 12, x: 0, y: 7)

                Circle()
                    .stroke(.white.opacity(0.30), lineWidth: 1)

                Image(systemName: "mic.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 66, height: 66)
            .opacity(isEnabled ? 1.0 : 0.45)
        }
        .buttonStyle(.plain)
        // ✅ 修正：新しいonChangeの形にする（確実に動く）
        .onChange(of: isRecording) { _, newValue in
            newValue ? startPulse() : stopPulse()
        }
        .onAppear {
            if isRecording { startPulse() }
        }
    }

    private func startPulse() {
        pulsing = false
        withAnimation(.easeOut(duration: 1.1).repeatForever(autoreverses: false)) {
            pulsing = true
        }
    }

    private func stopPulse() {
        pulsing = false
    }
}
