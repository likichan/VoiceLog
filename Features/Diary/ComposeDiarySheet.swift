//
//  ComposeDiarySheet.swift
//  VoiceLog
//

import SwiftUI
import SwiftData
import UIKit

struct ComposeDiarySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let selectedDay: Date
    let initialImages: [UIImage]

    @State private var text: String = ""
    @State private var images: [UIImage]
    @State private var saveError: String?

    init(selectedDay: Date, initialImages: [UIImage] = []) {
        self.selectedDay = selectedDay
        self.initialImages = initialImages
        _images = State(initialValue: initialImages)
    }

    var body: some View {
        ZStack {
            PaperBackground()
                .ignoresSafeArea()

            VStack(spacing: 14) {

                // 上部：キャンセル / 追加
                HStack {
                    Button("キャンセル") { dismiss() }
                        .font(.system(size: 16, weight: .semibold, design: .serif))

                    Spacer()

                    Button("追加") { saveAndClose() }
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .disabled(!canSave)
                        .opacity(canSave ? 1.0 : 0.4)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)

                // 画像プレビュー（複数）
                if !images.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(Array(images.indices), id: \.self) { i in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: images[i])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 72, height: 72)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                                    Button {
                                        images.remove(at: i)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 18))
                                            .foregroundStyle(.primary, .thinMaterial)
                                    }
                                    .padding(6)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 4)
                }

                // 入力欄（本文フォントは serif 強制しない）
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.thinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.black.opacity(0.07), lineWidth: 1)
                        )

                    TextEditor(text: $text)
                        .font(.body)
                        .scrollContentBackground(.hidden)
                        .padding(12)

                    if text.isEmpty {
                        Text("いまどうしてる？")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 22)
                    }
                }
                .frame(minHeight: 220)
                .padding(.horizontal, 16)

                if let saveError {
                    Text(saveError)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.top, 4)
                }

                Spacer()
            }
        }
    }

    private var canSave: Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty || !images.isEmpty
    }

    private func saveAndClose() {
        saveError = nil

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || !images.isEmpty else { return }

        // Itemを作る（テキスト空でも画像あればOK）
        let item = Item(timestamp: makeTimestamp(), text: trimmed)
        
        // 画像があれば保存して紐付け
        if !images.isEmpty {
            for img in images {
                do {
                    let saved = try ImageStorage.save(image: img)
                    let attachment = ItemImage(
                        originalPath: saved.originalPath,
                        thumbPath: saved.thumbPath
                    )
                    attachment.item = item
                    item.images.append(attachment)
                } catch {
                    saveError = "画像の保存に失敗しました"
                    // 画像が一部失敗しても日記は保存したいなら、ここでreturnしない
                }
            }
        }

        modelContext.insert(item)
        dismiss()
    }

    // 「選択した日付」に、時間だけ “今” を乗せる
    private func makeTimestamp(for day: Date = .now) -> Date {
        let cal = Calendar.current
        let d = cal.dateComponents([.year, .month, .day], from: day)
        let t = cal.dateComponents([.hour, .minute, .second], from: Date.now)

        var c = DateComponents()
        c.year = d.year
        c.month = d.month
        c.day = d.day
        c.hour = t.hour
        c.minute = t.minute
        c.second = t.second

        return cal.date(from: c) ?? Date.now
    }
}

#Preview {
    NavigationStack {
        ComposeDiarySheet(selectedDay: .now, initialImages: [])
    }
    .modelContainer(for: Item.self, inMemory: true)
}
