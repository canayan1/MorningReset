import SwiftUI

/// 7-day history strip — colored dots by morning mode.
/// Completed days are filled circles; today (if not done) is a pulsing ring;
/// missed days are tiny dim circles so the gap is visible but quiet.
struct StreakStripView: View {
    var entries: [DailyEntry]
    var days: Int = 7
    @State private var pulse = false

    // Build an array of (date, entry?) for the last N days, oldest first
    private var strip: [(date: Date, entry: DailyEntry?)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<days).reversed().map { offset in
            let day = cal.date(byAdding: .day, value: -offset, to: today)!
            let match = entries.first { cal.startOfDay(for: $0.date) == day }
            return (day, match)
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Array(strip.enumerated()), id: \.offset) { _, item in
                dot(date: item.date, entry: item.entry)
            }
        }
    }

    @ViewBuilder
    private func dot(date: Date, entry: DailyEntry?) -> some View {
        let isToday = Calendar.current.isDateInToday(date)

        if let e = entry {
            // Completed — filled circle in mode colour
            Circle()
                .fill(modeColor(e.mode))
                .frame(width: 26, height: 26)
        } else if isToday {
            // Today, not yet done — pulsing accent ring
            Circle()
                .strokeBorder(DS.accent, lineWidth: 1.5)
                .frame(width: 26, height: 26)
                .scaleEffect(pulse ? 1.08 : 1.0)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
                .onAppear { pulse = true }
        } else {
            // Missed — tiny dim dot
            Circle()
                .fill(DS.border)
                .frame(width: 8, height: 8)
                .frame(width: 26, height: 26) // keep spacing consistent
        }
    }

    private func modeColor(_ mode: String) -> Color {
        switch mode {
        case "protect": return DS.modeProtect
        case "push":    return DS.modePush
        default:        return DS.modeSteady
        }
    }
}

// MARK: - Day-of-week legend companion

struct StreakStripLegend: View {
    var days: Int = 7

    private var labels: [String] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE" // single letter: M T W T F S S
        return (0..<days).reversed().map { offset in
            let day = cal.date(byAdding: .day, value: -offset, to: today)!
            return formatter.string(from: day)
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Array(labels.enumerated()), id: \.offset) { _, label in
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(DS.textDim)
                    .frame(width: 26)
            }
        }
    }
}
