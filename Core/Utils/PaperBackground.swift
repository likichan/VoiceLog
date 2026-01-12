//
//  PaperBackground.swift
//  VoiceLog
//
//  Created by 後藤吏希 on 2025/12/29.
//

import SwiftUI

struct PaperBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.96, green: 0.94, blue: 0.90),
                Color(red: 0.95, green: 0.93, blue: 0.88)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(
            // ほんの少し汚し（点）
            NoiseOverlay().opacity(0.08)
        )
    }
}

private struct NoiseOverlay: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<1800 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let r = CGFloat.random(in: 0.4...1.2)
                let rect = CGRect(x: x, y: y, width: r, height: r)
                context.fill(Path(ellipseIn: rect), with: .color(.black))
            }
        }
    }
}
