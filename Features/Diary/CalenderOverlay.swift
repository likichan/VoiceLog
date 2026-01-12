import SwiftUI

struct CalendarOverlay: View {
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date
    let daysWithEntries: Set<Date>

    @State private var viewingYear: Int = Calendar.current.component(.year, from: Date())
    @State private var showSearchPanel = false
    @State private var searchText: String = ""

    private let cal = Calendar.current

    var body: some View {
        ZStack {
            // 背景タップで閉じる
            Color.black.opacity(0.12)
                .ignoresSafeArea()
                .onTapGesture { withAnimation(.spring()) { isPresented = false } }

            VStack(spacing: 10) {
                header

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 18) {

                        // ✅ 年の表示は「上のheaderだけ」にする（ここで2回目を出さない）

                        ForEach(1...12, id: \.self) { m in
                            MonthGrid(
                                year: viewingYear,
                                month: m,
                                selectedDate: $selectedDate,
                                daysWithEntries: daysWithEntries,
                                onSelect: {
                                    withAnimation(.spring()) { isPresented = false }
                                }
                            )
                        }

                        Divider().opacity(0.25)
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
                }
            }
            .frame(maxWidth: 420)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(.black.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal, 14)

            // Top-right close
            .overlay(alignment: .topTrailing) {
                GlassIconButton(systemName: "xmark") {
                    withAnimation(.spring()) { isPresented = false }
                }
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 32, height: 32)
                .padding(16)
            }

            // Bottom-left today
            .overlay(alignment: .bottomLeading) {
                GlassPillButton {
                    selectedDate = .now
                    viewingYear = cal.component(.year, from: .now)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                        Text("今日").font(.subheadline)
                    }
                }
                .frame(height: 32)
                .padding(16)
            }

            // Bottom-right search
            .overlay(alignment: .bottomTrailing) {
                VStack(alignment: .trailing, spacing: 10) {
                    if showSearchPanel {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("年を検索").font(.footnote).opacity(0.7)
                            HStack(spacing: 8) {
                                TextField("2027", text: $searchText)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 160)

                                Button("検索") {
                                    if let y = Int(searchText) { viewingYear = y }
                                    withAnimation(.easeInOut) { showSearchPanel = false }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(.black.opacity(0.06), lineWidth: 1)
                        )
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }

                    GlassIconButton(systemName: "magnifyingglass") {
                        withAnimation(.spring()) { showSearchPanel.toggle() }
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 32, height: 32)
                }
                .padding(16)
            }
        }
        .onAppear {
            viewingYear = cal.component(.year, from: selectedDate)
        }
    }

    private var header: some View {
        HStack {
            Spacer()

            HStack(spacing: 12) {
                Button(action: { viewingYear -= 1 }) {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)

                // ✅ カンマ無しの年表示
                Text(String(viewingYear))
                    .font(.system(size: 20, weight: .semibold, design: .serif))

                Button(action: { viewingYear += 1 }) {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.top, 6)
    }
}

private struct MonthGrid: View {
    let year: Int
    let month: Int
    @Binding var selectedDate: Date
    let daysWithEntries: Set<Date>
    let onSelect: () -> Void

    private var gridCal: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.locale = Locale(identifier: "en_US_POSIX")
        c.firstWeekday = 1 // Sunday
        return c
    }

    private let cols = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(monthTitle)
                .font(.caption)
                .opacity(0.6)

            LazyVGrid(columns: cols, spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { s in
                    Text(s).font(.caption2).opacity(0.45)
                }

                ForEach(paddedDays, id: \.self) { cell in
                    if let date = cell {
                        dayCell(date)
                    } else {
                        Color.clear.frame(height: 26)
                    }
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(.white.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.black.opacity(0.06), lineWidth: 1)
            )
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let isSelected = gridCal.isDate(date, inSameDayAs: selectedDate)
        let hasEntry = daysWithEntries.contains(gridCal.startOfDay(for: date))
        let day = gridCal.component(.day, from: date)

        return Button {
            selectedDate = date
            onSelect()
        } label: {
            VStack(spacing: 2) {
                Text("\(day)")
                    .font(.system(size: isSelected ? 15 : 13, weight: isSelected ? .semibold : .regular))
                    .opacity(isSelected ? 1.0 : 0.85)
                    .foregroundStyle(colorForWeekday(date))
                    .frame(maxWidth: .infinity)

                Circle()
                    .frame(width: 4, height: 4)
                    .opacity(hasEntry ? 0.7 : 0.0)
            }
            .frame(height: 26)
            .background(isSelected ? Color.black.opacity(0.08) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private var monthTitle: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "MMMM"
        let d = gridCal.date(from: DateComponents(year: year, month: month, day: 1)) ?? .now
        return f.string(from: d).uppercased()
    }

    private var weekdaySymbols: [String] {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = gridCal
        return f.shortWeekdaySymbols // Sun Mon ...
    }

    private var paddedDays: [Date?] {
        guard let first = gridCal.date(from: DateComponents(year: year, month: month, day: 1)),
              let range = gridCal.range(of: .day, in: .month, for: first) else { return [] }

        let firstWeekdayIndex = (gridCal.component(.weekday, from: first) - 1) // Sun=0
        var arr: [Date?] = Array(repeating: nil, count: firstWeekdayIndex)

        for d in range {
            arr.append(gridCal.date(from: DateComponents(year: year, month: month, day: d)))
        }
        return arr
    }

    private func colorForWeekday(_ date: Date) -> Color {
        let wd = gridCal.component(.weekday, from: date) // 1=Sun, 7=Sat
        if wd == 1 { return .red }
        if wd == 7 { return .blue }
        return .primary
    }
}
