//
//  AddItemSheet.swift
//  VoiceLog
//
//  Created by 後藤吏希 on 2025/12/29.
//

import SwiftUI
import SwiftData

struct AddItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let selectedDay: Date

    @State private var text: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("内容") {
                    TextField("例：牛乳と卵を買う", text: $text, axis: .vertical)
                        .lineLimit(3...8)
                }

            }
            .navigationTitle("追加")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let ts = makeTimestamp(for: selectedDay)
                        let newItem = Item(timestamp: ts, text: text)
                        modelContext.insert(newItem)
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    // 選択した「日付」に保存したいので、日付だけ selectedDay に合わせる
    private func makeTimestamp(for day: Date) -> Date {
        let cal = Calendar.current

        let dayParts = cal.dateComponents([.year, .month, .day], from: day)
        let timeParts = cal.dateComponents([.hour, .minute, .second], from: Date.now)

        var comps = DateComponents()
        comps.year = dayParts.year
        comps.month = dayParts.month
        comps.day = dayParts.day
        comps.hour = timeParts.hour
        comps.minute = timeParts.minute
        comps.second = timeParts.second

        return cal.date(from: comps) ?? Date.now
    }
}
