//
//  QuickAddMenuOverlay.swift
//  VoiceLog
//
//  Created by 後藤吏希 on 2026/01/02.
//
import SwiftUI

struct QuickAddMenuOverlay: View {
    let onClose: () -> Void
    let onTapKeyboard: () -> Void
    let onTapPhoto: () -> Void
    let onTapCamera: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack {
                Spacer()
                HStack {
                    Spacer()

                    VStack(spacing: 12) {
                        QuickIconButton(systemName: "camera", action: onTapCamera)
                        QuickIconButton(systemName: "photo", action: onTapPhoto)
                        QuickIconButton(systemName: "keyboard", action: onTapKeyboard)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 92)
                }
            }
        }
    }
}

struct QuickIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: systemName)
                        .font(.system(size: 20, weight: .semibold))
                )
        }
        .buttonStyle(.plain)
    }
}
