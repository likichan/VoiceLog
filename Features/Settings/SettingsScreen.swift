// Features/Settings/SettingsScreen.swift
import SwiftUI

struct SettingsScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            PaperBackground().ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {

                ZStack {
                    // Center title
                    Text("設定")
                        .font(.system(size: 28, weight: .semibold, design: .serif))

                    // Left back button
                    HStack {
                        GlassIconButton(systemName: "chevron.left") { dismiss() }
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 18)
                .padding(.top, 16)
                
                // ✅ ここも日記のカードと同じ見た目に寄せる
                NavigationLink {
                    TrashScreen()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "trash")
                        Text("ゴミ箱").font(AppFont.body)
                        Spacer()
                        Image(systemName: "chevron.right").opacity(0.5)
                    }
                    .padding(16)
                    .background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.black.opacity(0.06), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 18)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: "bolt.fill")
                        Text("ショートカット連携").font(AppFont.body)
                        Spacer()
                    }

                    Text("ショートカットから録音の開始/停止ができます。背面タップやサイドボタンのショートカットに割り当てて使えます。").font(.caption)
                        .opacity(0.7)

                    HStack(spacing: 12) {
                        Image(systemName: "play.circle")
                        Text("録音を開始 (Start Recording)").font(.subheadline)
                        Spacer()
                    }
                    .opacity(0.85)

                    HStack(spacing: 12) {
                        Image(systemName: "stop.circle")
                        Text("録音を停止 (Stop Recording)").font(.subheadline)
                        Spacer()
                    }
                    .opacity(0.85)

                    Text("ショートカットアプリで 'VoiceLog' のアクションから追加してください。").font(.caption2)
                        .opacity(0.6)
                }
                .padding(16)
                .background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.black.opacity(0.06), lineWidth: 1)
                )
                .padding(.horizontal, 18)

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true) // ← “標準ナビ”を消して統一
    }
}

