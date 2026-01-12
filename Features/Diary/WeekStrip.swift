import SwiftUI

struct WeekStrip: View {
    @Binding var selectedDate: Date
    private let swipeThreshold: CGFloat = 40

    private var days: [Date] { weekDays(for: selectedDate) }

    var body: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 10
            let cellWidth = (geo.size.width - spacing * 6) / 7

            HStack(spacing: spacing) {
                ForEach(days, id: \.self) { date in
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)

                    dayCell(date, isSelected: isSelected)
                        .frame(width: cellWidth, height: 52)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.snappy) { selectedDate = date }
                        }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 15, coordinateSpace: .local)
                    .onEnded { value in
                        let dx = value.translation.width
                        if abs(dx) > swipeThreshold {
                            let cal = Calendar.current
                            withAnimation(.snappy) {
                                if dx < 0 {
                                    if let next = cal.date(byAdding: .day, value: 7, to: selectedDate) { selectedDate = next }
                                } else {
                                    if let prev = cal.date(byAdding: .day, value: -7, to: selectedDate) { selectedDate = prev }
                                }
                            }
                        }
                    }
            )
        }
        .frame(height: 60)
        .padding(.vertical, 8)
    }

    private func dayCell(_ date: Date, isSelected: Bool) -> some View {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date)
        let day = cal.component(.day, from: date)
        let weekdayText = ["日","月","火","水","木","金","土"][weekday - 1]

        return VStack(spacing: 6) {
            Text(weekdayText)
                .font(.system(size: 11, weight: .regular, design: .serif))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .opacity(isSelected ? 1.0 : 0.55)

            Text("\(day)")
                .font(.system(size: isSelected ? 17 : 15,
                              weight: isSelected ? .semibold : .regular,
                              design: .serif))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .opacity(isSelected ? 1.0 : 0.55)
                .scaleEffect(isSelected ? 1.08 : 1.0)


            Capsule()
                .frame(height: 2)
                .opacity(isSelected ? 1.0 : 0.0)
        }
    }

    private func weekDays(for date: Date) -> [Date] {
        var cal = Calendar.current
        cal.firstWeekday = 1
        let interval = cal.dateInterval(of: .weekOfYear, for: date)!
        let start = interval.start
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }
}
