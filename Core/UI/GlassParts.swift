//
//  Untitled.swift
//  VoiceLog
//
//  Created by 後藤吏希 on 2026/01/01.
//

import SwiftUI

struct GlassIconButton: View {
    let systemName: String
    var size: CGFloat = 40          // 見た目サイズ（背景の直径）
    var iconSize: CGFloat = 16
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .semibold))
                .frame(width: size, height: size)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(
                    Circle().stroke(.black.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        // 触れる範囲は最低44pt（見た目は40のまま）
        .frame(minWidth: 44, minHeight: 44)
        .contentShape(Rectangle())
    }
}

struct GlassPillButton<Label: View>: View {
    var action: () -> Void
    @ViewBuilder var label: () -> Label

    var body: some View {
        Button(action: action) {
            label()
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(
                    Capsule().stroke(.black.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }
}
