//
//  ItemsListView.swift
//  VoiceLog
//
//  Created by Assistant on 2025/12/29.
//

import SwiftUI
import SwiftData

struct ItemsTimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    init(day: Date) {
        let cal = Calendar.current
        let start = cal.startOfDay(for: day)
        let end = cal.date(byAdding: .day, value: 1, to: start)!

        _items = Query(
            filter: #Predicate<Item> { item in
                item.deletedAt == nil &&
                item.timestamp >= start &&
                item.timestamp < end
            },
            sort: [SortDescriptor(\Item.timestamp, order: .forward)]
        )
    }

    var body: some View {
        Group {
            if items.isEmpty {
                emptyState
            } else {
                timelineBody
            }
        }
    }

    // MARK: - Views

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "book.closed")
                .font(.system(size: 40))
                .opacity(0.5)
            Text("日記をつけてみよう")
                .font(.headline)
                .opacity(0.7)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .padding(.horizontal, 16)
    }

    private var timelineBody: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(items, id: \.persistentModelID) { item in
                    TimelineRow(item: item, onDelete: { softDelete(item) })
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }

                // 下のマイクUIに被らないよう余白を確保
                Color.clear.frame(height: 80)
            }
        }
        .scrollIndicators(.automatic)
        .scrollBounceBehavior(.basedOnSize)
        .scrollContentBackground(.hidden)
        .contentShape(Rectangle())
    }

    // MARK: - Delete

    private func softDelete(_ item: Item) {
        item.deletedAt = Date.now
        do { try modelContext.save() } catch { }
    }

    // MARK: - Row Visuals

    private struct TimelineRow: View {
        let item: Item
        let onDelete: () -> Void

        init(item: Item, onDelete: @escaping () -> Void) {
            self.item = item
            self.onDelete = onDelete
        }

        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                TimelineRail()
                    .padding(.top, 6)

                ZStack(alignment: .topTrailing) {
                    VStack(alignment: .leading, spacing: 8) {
                        // 時刻（HH:mm）
                        Text(item.timestamp, style: .time)
                            .font(.caption)
                            .opacity(0.55)

                        // 本文（空なら表示しない）
                        if !item.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(item.text)
                                .font(.system(.body, design: .serif))
                                .lineSpacing(4)
                        }

                        // 画像（DiaryPhotoCard）
                        if !item.images.isEmpty {
                            VStack(spacing: 10) {
                                ForEach(item.images) { img in
                                    DiaryPhotoCard(
                                        thumbPath: img.thumbPath,
                                        originalPath: img.originalPath
                                    )
                                }
                            }
                            .padding(.top, 6)
                        }

                        Divider().opacity(0.25)
                    }

                    Menu {
                        Button(role: .destructive) {
                            onDelete()
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(8)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                    .padding(.trailing, 2)
                }
            }
        }
    }

    private struct TimelineRail: View {
        var body: some View {
            VStack(spacing: 0) {
                Circle()
                    .frame(width: 6, height: 6)
                    .opacity(0.6)

                Rectangle()
                    .frame(width: 1)
                    .opacity(0.15)
                    .frame(maxHeight: .infinity)
            }
        }
    }
}

// 画像のForEachが通らない場合の代案（id指定）
// ForEach(item.images, id: \.self) { img in ... } でも良いですが、
// ItemImageがEquatable/Hashableでない場合は、pathの組み合わせで一意にする方法もあります。
// 例:
// ForEach(item.images, id: \.originalPath) { img in
//     DiaryPhotoCard(thumbPath: img.thumbPath, originalPath: img.originalPath)
// }

