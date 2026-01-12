import SwiftUI

struct HeaderBar: View {
    let date: Date
    let onTapCalendar: () -> Void
    let onTapSettings: () -> Void

    private var monthText: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "MMMM"
        return f.string(from: date).uppercased()
    }

    private var yearText: String {
        String(Calendar.current.component(.year, from: date)) // ← カンマ無し
    }

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(monthText)
                    .font(.system(size: 12, weight: .regular, design: .serif))
                    .tracking(1.6)
                    .opacity(0.55)

                Text(yearText)
                    .font(.system(size: 44, weight: .semibold, design: .serif))
            }

            Spacer()

            HStack(spacing: 12) {
                GlassIconButton(systemName: "calendar") { onTapCalendar() }
                GlassIconButton(systemName: "gearshape") { onTapSettings() }
            }
            .padding(.top, 8)
        }
        // ✅ ここでは padding しない（外側で揃える）
    }
}


    private func monthText(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "MMMM"
        return f.string(from: date)
    }

    private func yearText(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy"
        return f.string(from: date)
    }

// ✅ 見た目 36 / タップ 44（LiquidGlassっぽい）
private struct LiquidIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 36, height: 36) // 見た目
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(.white.opacity(0.22), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .frame(width: 44, height: 44) // タップ領域
        .contentShape(Rectangle())
    }
}
