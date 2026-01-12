//
//  DiaryPhotoCard.swift
//  VoiceLog
//
//  Created by 後藤吏希 on 2026/01/12.
//
import SwiftUI

struct DiaryPhotoCard: View {
    let thumbPath: String
    let originalPath: String

    // 画面の雰囲気に合わせて “いつもの角丸” を固定
    private let radius: CGFloat = 20

    var body: some View {
        Group {
            if let ui = ImageStorage.loadImage(relativePath: originalPath)
                ?? ImageStorage.loadImage(relativePath: thumbPath) {

                Image(uiImage: ui)
                    .resizable()
                    .scaledToFit()
            } else {
                // 読み込み失敗時もUIを崩さない
                ZStack {
                    RoundedRectangle(cornerRadius: radius)
                        .fill(.ultraThinMaterial)
                    Image(systemName: "photo")
                        .font(.system(size: 22, weight: .semibold))
                        .opacity(0.6)
                        .padding(.vertical, 40)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(.white.opacity(0.35), lineWidth: 1)
        )
        .background(
            // 背景も角丸で切る（紙の上に自然に置ける）
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .shadow(radius: 10, y: 6) // 影は弱めで1個
        .padding(.vertical, 8)     // 行間の統一
    }
}
