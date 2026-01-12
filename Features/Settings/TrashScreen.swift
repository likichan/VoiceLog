//
//  TrashScreen.swift
//  VoiceLog
//

import SwiftUI
import SwiftData

struct TrashScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<Item> { $0.deletedAt != nil },
        sort: [SortDescriptor(\Item.timestamp, order: .reverse)]
    )
    private var deletedItems: [Item]

    @State private var isSelecting = false
    @State private var selectedIDs = Set<PersistentIdentifier>()

    @State private var showBulkDialog = false

    var body: some View {
        ZStack {
            PaperBackground().ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    LazyVStack(spacing: 0) {
                        if deletedItems.isEmpty {
                            emptyState
                                .padding(.top, 48)
                        } else {
                            ForEach(deletedItems, id: \.persistentModelID) { item in
                                TrashRow(
                                    item: item,
                                    isSelecting: isSelecting,
                                    isChecked: selectedIDs.contains(item.persistentModelID),
                                    onTap: {
                                        if isSelecting { toggle(item) }
                                    }
                                )
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)

                                Divider().opacity(0.14)
                                    .padding(.horizontal, 18)
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, isSelecting ? 92 : 24) // 下バー分の余白
                }

                if isSelecting {
                    bottomBar
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .confirmationDialog("操作", isPresented: $showBulkDialog) {
            Button("すべて復旧") { restoreAll() }
            Button("すべて削除", role: .destructive) { deleteAllPermanently() }
            Button("キャンセル", role: .cancel) {}
        }
    }

    // MARK: - Header
    private var header: some View {
        ZStack {
            Text("ゴミ箱")
                .font(.system(size: 28, weight: .semibold, design: .serif))

            HStack {
                LiquidIconButton(systemName: "chevron.left") { dismiss() }
                Spacer()
            }

            HStack {
                Spacer()

                if isSelecting {
                    HStack(spacing: 10) {
                        LiquidIconButton(systemName: "ellipsis") {
                            showBulkDialog = true
                        }
                        LiquidIconButton(systemName: "xmark") {
                            exitSelecting()
                        }
                    }
                } else {
                    LiquidPillButton(title: "選択") {
                        enterSelecting()
                    }
                    .disabled(deletedItems.isEmpty)
                    .opacity(deletedItems.isEmpty ? 0.5 : 1.0)
                }
            }
        }
        .frame(maxWidth: .infinity)     // ★中央揃えが崩れない 핵
        .padding(.horizontal, 18)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "trash")
                .font(.system(size: 28, weight: .semibold))
                .opacity(0.35)
            Text("ゴミ箱は空です")
                .font(AppFont.body)
                .opacity(0.55)
        }
    }

    // MARK: - Bottom Bar（選択中だけ出る）
    private var bottomBar: some View {
        HStack {
            Button("復元") { restoreSelected() }
                .disabled(selectedIDs.isEmpty)

            Spacer()

            Button("完全に削除") { deleteSelectedPermanently() }
                .disabled(selectedIDs.isEmpty)
                .foregroundStyle(.red)
        }
        .font(.system(size: 16, weight: .semibold))
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle().frame(height: 1).opacity(0.08),
            alignment: .top
        )
    }

    // MARK: - Selection
    private func enterSelecting() {
        isSelecting = true
        selectedIDs.removeAll()
    }

    private func exitSelecting() {
        isSelecting = false
        selectedIDs.removeAll()
    }

    private func toggle(_ item: Item) {
        let id = item.persistentModelID
        if selectedIDs.contains(id) { selectedIDs.remove(id) }
        else { selectedIDs.insert(id) }
    }

    // MARK: - Actions
    private func restoreSelected() {
        let targets = deletedItems.filter { selectedIDs.contains($0.persistentModelID) }
        targets.forEach { $0.deletedAt = nil }
        try? modelContext.save()
        exitSelecting()
    }

    private func deleteSelectedPermanently() {
        let targets = deletedItems.filter { selectedIDs.contains($0.persistentModelID) }
        targets.forEach { modelContext.delete($0) }
        try? modelContext.save()
        exitSelecting()
    }

    private func restoreAll() {
        deletedItems.forEach { $0.deletedAt = nil }
        try? modelContext.save()
        exitSelecting()
    }

    private func deleteAllPermanently() {
        deletedItems.forEach { modelContext.delete($0) }
        try? modelContext.save()
        exitSelecting()
    }
}

// MARK: - Row
private struct TrashRow: View {
    let item: Item
    let isSelecting: Bool
    let isChecked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                if isSelecting {
                    Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundStyle(isChecked ? .blue : .gray.opacity(0.45))
                        .padding(.top, 4)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.timestamp, format: .dateTime.month().day().year())
                        .font(AppFont.sub)
                        .opacity(0.55)

                    Text(item.text)
                        .font(AppFont.body)
                        .lineSpacing(4)
                        .foregroundStyle(.primary)
                }

                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 6)
    }
}

// MARK: - LiquidGlass buttons（このファイル内だけで完結）
private struct LiquidIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 36, height: 36) // 見た目サイズ
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.22), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .frame(width: 44, height: 44)      // タップ領域
        .contentShape(Rectangle())
    }
}

private struct LiquidPillButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .padding(.horizontal, 14)
                .frame(height: 36)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.22), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .frame(height: 44) // タップしやすく
    }
}
