//
//  DiaryScreen.swift
//  VoiceLog
//
//  Created by 後藤吏希 on 2025/12/29.
//

import SwiftUI
import SwiftData
import PhotosUI

struct DiaryScreen: View {
    @Environment(\.modelContext) private var modelContext

    @State private var selectedDate: Date = .now
    @State private var showSavedAlert = false
    @State private var savedDate: Date = .now

    @State private var isShowingSettings = false
    @State private var isShowingCalendar = false

    @Query(
        filter: #Predicate<Item> { $0.deletedAt == nil },
        sort: [SortDescriptor(\Item.timestamp, order: .forward)]
    ) private var activeItems: [Item]

    // 録音・文字起こし
    @StateObject private var recorder = AudioRecorderService()
    private let transcriber = SpeechTranscriber()

    @State private var permissionOK = false
    @State private var isTranscribing = false
    @State private var errorMessage: String?

    // 写真/カメラ
    @State private var showPhotoPicker = false
    @State private var showCamera = false

    // 追加（Twitter風）
    @State private var showComposeSheet = false
    @State private var showQuickAddMenu = false

    @State private var composeImages: [UIImage] = []
    @State private var photoPickerItems: [PhotosPickerItem] = []

    private let sidePadding: CGFloat = 16

    var body: some View {
        ZStack {
            // 最背面: 紙背景を常時表示
            PaperBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // ヘッダー + 週
                VStack(spacing: 0) {
                    HeaderBar(
                        date: selectedDate,
                        onTapCalendar: { withAnimation(.spring()) { isShowingCalendar = true } },
                        onTapSettings: { isShowingSettings = true }
                    )

                    WeekStrip(selectedDate: $selectedDate)

                    Divider().opacity(0.35)
                }
                .padding(.horizontal, sidePadding)
                .padding(.top, 16)

                // タイムライン（Listは使わず、内部でScrollView+LazyVStack）
                ItemsTimelineView(day: selectedDate)
                    .padding(.top, 14)

                if recorder.isRecording {
                    Text("録音中… \(format(recorder.elapsed))")
                        .font(.caption)
                        .opacity(0.7)
                        .padding(.top, 10)
                } else if isTranscribing {
                    Text("文字起こし中…")
                        .font(.caption)
                        .opacity(0.7)
                        .padding(.top, 10)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.top, 6)
                }

                Spacer(minLength: 24)
            }
        }
        .toolbar(.hidden, for: .navigationBar)

        // 下部バー
        .safeAreaInset(edge: .bottom) {
            ZStack {
                HStack {
                    GlassPillButton {
                        selectedDate = .now
                    } label: {
                        HStack(spacing: 6) {
                            Text("今日").font(.subheadline)
                        }
                    }

                    Spacer()

                    GlassIconButton(systemName: showQuickAddMenu ? "xmark" : "plus") {
                        if showQuickAddMenu {
                            showQuickAddMenu = false
                        } else {
                            composeImages = []
                            showComposeSheet = true
                        }
                    }
                    .onLongPressGesture(minimumDuration: 0.28) {
                        showQuickAddMenu = true
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 10)

                MicButton(isOn: recorder.isRecording, isEnabled: permissionOK) {
                    Task { await onTapMic() }
                }
                .padding(.bottom, 10)
            }
        }

        // 権限
        .task {
            let mic = await recorder.requestMicPermission()
            let sp  = await transcriber.requestSpeechPermission()
            permissionOK = mic && sp
            if !permissionOK {
                errorMessage = "権限がないので録音できません（設定で許可してね）"
            }
        }

        // 録音が「今日に保存」されたアラート
        .alert("今日に保存しました", isPresented: $showSavedAlert) {
            Button("今日を見る") { selectedDate = savedDate }
            Button("OK", role: .cancel) {}
        } message: {
            Text("録音した内容はスマホの日時に保存されました。")
        }

        // 設定へ
        .navigationDestination(isPresented: $isShowingSettings) {
            SettingsScreen()
        }

        // カレンダー
        .fullScreenCover(isPresented: $isShowingCalendar) {
            CalendarOverlay(
                isPresented: $isShowingCalendar,
                selectedDate: $selectedDate,
                daysWithEntries: Set(activeItems.map { Calendar.current.startOfDay(for: $0.timestamp) })
            )
        }

        // 入力シート
        .sheet(isPresented: $showComposeSheet) {
            ComposeDiarySheet(selectedDay: selectedDate, initialImages: composeImages)
                .onDisappear { composeImages = [] }
        }

        // 写真ピッカー（複数対応）
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $photoPickerItems,
            matching: .images
        )
        .onChange(of: photoPickerItems) { _, newItems in
            Task {
                var imgs: [UIImage] = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let ui = UIImage(data: data) {
                        imgs.append(ui)
                    }
                }
                photoPickerItems = []
                if !imgs.isEmpty {
                    composeImages = imgs
                    showComposeSheet = true
                }
            }
        }

        // カメラ
        .sheet(isPresented: $showCamera) {
            CameraPicker { img in
                composeImages = [img]
                showComposeSheet = true
            }
        }

        // クイックメニュー
        .overlay {
            if showQuickAddMenu {
                QuickAddMenuOverlay(
                    onClose: { showQuickAddMenu = false },
                    onTapKeyboard: {
                        showQuickAddMenu = false
                        composeImages = []
                        showComposeSheet = true
                    },
                    onTapPhoto: {
                        showQuickAddMenu = false
                        errorMessage = nil
                        showPhotoPicker = true
                    },
                    onTapCamera: {
                        showQuickAddMenu = false
                        errorMessage = nil
                        showCamera = true
                    }
                )
                .transition(AnyTransition.opacity)
            }
        }
    }

    // MARK: - Actions（録音）
    private func onTapMic() async {
        errorMessage = nil
        guard permissionOK else {
            errorMessage = "権限がないので録音できません（設定で許可してね）"
            return
        }

        if recorder.isRecording {
            let url = recorder.stop()
            guard let url else { return }

            isTranscribing = true
            defer { isTranscribing = false }

            do {
                let text = try await transcriber.transcribe(url: url)
                let item = Item(timestamp: Date.now, text: text)
                modelContext.insert(item)

                savedDate = Date.now
                if !Calendar.current.isDate(selectedDate, inSameDayAs: Date.now) {
                    showSavedAlert = true
                }
            } catch {
                errorMessage = "文字起こし失敗: \(error.localizedDescription)"
            }
        } else {
            do { try recorder.start() }
            catch { errorMessage = "録音開始失敗: \(error.localizedDescription)" }
        }
    }

    private func format(_ t: TimeInterval) -> String {
        let s = Int(t)
        return String(format: "%02d:%02d", s/60, s%60)
    }
}

#Preview {
    NavigationStack {
        DiaryScreen()
    }
    .modelContainer(for: Item.self, inMemory: true)
}
