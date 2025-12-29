//  ItemsListView.swift
//  VoiceLog
//
//  Created by Assistant on 2025/12/29.
//

import SwiftUI
import SwiftData

struct ItemsListView: View {
    let day: Date

    // Replace this with your real query/model once available
    // Example placeholder items for the selected date
    @State private var items: [String] = []

    var body: some View {
        Group {
            if items.isEmpty {
                ContentUnavailableView(
                    "No entries",
                    systemImage: "calendar.badge.clock",
                    description: Text("There are no items for this date.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(items, id: \.self) { item in
                    Text(item)
                }
                .listStyle(.plain)
            }
        }
        .onAppear(perform: loadItems)
        .onChange(of: day) { _, _ in
            loadItems()
        }
    }

    private func loadItems() {
        // TODO: Replace with real SwiftData fetch filtered by `day`
        // For now, populate some mock content tied to the date to show it changes
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateString = formatter.string(from: day)
        // Simple demo: if today, show 2 items; otherwise one item
        let calendar = Calendar.current
        if calendar.isDateInToday(day) {
            items = ["Sample entry A (\(dateString))", "Sample entry B (\(dateString))"]
        } else {
            items = ["Sample entry (\(dateString))"]
        }
    }
}

#Preview {
    ItemsListView(day: .now)
}
