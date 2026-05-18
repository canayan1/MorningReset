import WidgetKit
import SwiftUI

// MARK: - Shared data reader

private struct WidgetEntry: Codable {
    let date: Date
    let mode: String
    let intention: String
}

private enum WidgetStore {
    static let suiteName = "group.com.canayan.MorningReset"
    static let key       = "dailyEntries"

    static func load() -> [WidgetEntry] {
        guard let ud      = UserDefaults(suiteName: suiteName),
              let data    = ud.data(forKey: key),
              let entries = try? JSONDecoder().decode([WidgetEntry].self, from: data)
        else { return [] }
        return entries
    }

    static func streak(from entries: [WidgetEntry]) -> Int {
        guard !entries.isEmpty else { return 0 }
        let cal       = Calendar.current
        let today     = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        let days      = Array(Set(entries.map { cal.startOfDay(for: $0.date) })).sorted(by: >)
        guard let first = days.first, first == today || first == yesterday else { return 0 }
        var count    = 0
        var expected = first
        for day in days {
            if day == expected {
                count   += 1
                expected = cal.date(byAdding: .day, value: -1, to: expected)!
            } else { break }
        }
        return count
    }

    static func todayDone(from entries: [WidgetEntry]) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return entries.contains { Calendar.current.startOfDay(for: $0.date) == today }
    }

    static func last7(from entries: [WidgetEntry]) -> [(done: Bool, mode: String)] {
        let cal   = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<7).reversed().compactMap { offset -> (done: Bool, mode: String) in
            guard let day = cal.date(byAdding: .day, value: -offset, to: today) else {
                return (false, "")
            }
            if let match = entries.last(where: { cal.startOfDay(for: $0.date) == day }) {
                return (true, match.mode)
            }
            return (false, "")
        }
    }
}

// MARK: - Timeline entry

struct StreakWidgetEntry: TimelineEntry {
    let date:      Date
    let streak:    Int
    let todayDone: Bool
    let last7:     [(done: Bool, mode: String)]
}

// MARK: - Provider

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakWidgetEntry {
        StreakWidgetEntry(date: Date(), streak: 7, todayDone: false,
                         last7: Array(repeating: (true, "steady"), count: 7))
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakWidgetEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakWidgetEntry>) -> Void) {
        let entry    = makeEntry()
        let midnight = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        )
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }

    private func makeEntry() -> StreakWidgetEntry {
        let entries = WidgetStore.load()
        return StreakWidgetEntry(
            date:      Date(),
            streak:    WidgetStore.streak(from: entries),
            todayDone: WidgetStore.todayDone(from: entries),
            last7:     WidgetStore.last7(from: entries)
        )
    }
}

// MARK: - Design tokens

private enum WDS {
    static let bg      = Color(red: 0.973, green: 0.953, blue: 0.925)
    static let accent  = Color(red: 0.549, green: 0.424, blue: 0.282)
    static let text    = Color(red: 0.149, green: 0.118, blue: 0.090)
    static let textDim = Color(red: 0.149, green: 0.118, blue: 0.090).opacity(0.40)
    static let surface = Color(red: 0.149, green: 0.118, blue: 0.090).opacity(0.07)

    static func modeColor(_ mode: String) -> Color {
        switch mode {
        case "protect": return accent.opacity(0.40)
        case "steady":  return accent.opacity(0.70)
        case "push":    return accent
        default:        return surface
        }
    }
}

// MARK: - Small widget

private struct SmallView: View {
    let entry: StreakWidgetEntry

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Text("\(entry.streak)")
                .font(.system(size: 54, weight: .thin, design: .serif))
                .foregroundStyle(WDS.text)
                .monospacedDigit()
            Text(entry.streak == 1 ? "day" : "days in a row")
                .font(.system(size: 11, design: .serif))
                .foregroundStyle(WDS.textDim)
            Spacer()
            Group {
                if entry.todayDone {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(WDS.accent)
                } else {
                    Text("Begin →")
                        .font(.system(size: 11))
                        .foregroundStyle(WDS.accent)
                }
            }
            .padding(.bottom, 4)
        }
        .containerBackground(WDS.bg, for: .widget)
    }
}

// MARK: - Medium widget

private struct MediumView: View {
    let entry: StreakWidgetEntry

    var body: some View {
        HStack(spacing: 0) {
            // Left — streak hero
            VStack(alignment: .leading, spacing: 2) {
                Spacer()
                Text("\(entry.streak)")
                    .font(.system(size: 58, weight: .thin, design: .serif))
                    .foregroundStyle(WDS.text)
                    .monospacedDigit()
                Text(entry.streak == 1 ? "day" : "days\nin a row")
                    .font(.system(size: 12, design: .serif))
                    .foregroundStyle(WDS.textDim)
                    .lineSpacing(2)
                Spacer()
            }
            .padding(.leading, 20)
            .frame(maxWidth: .infinity)

            // Right — 7-day strip + CTA
            VStack(alignment: .leading, spacing: 14) {
                Spacer()
                HStack(spacing: 6) {
                    ForEach(entry.last7.indices, id: \.self) { i in
                        let day    = entry.last7[i]
                        let isLast = i == entry.last7.count - 1
                        ZStack {
                            Circle()
                                .fill(day.done ? WDS.modeColor(day.mode) : WDS.surface)
                                .frame(width: 9, height: 9)
                            if isLast && !entry.todayDone {
                                Circle()
                                    .strokeBorder(WDS.accent, lineWidth: 1)
                                    .frame(width: 13, height: 13)
                            }
                        }
                    }
                }
                if entry.todayDone {
                    Label("Done today", systemImage: "checkmark")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(WDS.accent)
                } else {
                    Text("Begin morning reset")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(WDS.accent)
                }
                Spacer()
            }
            .padding(.trailing, 20)
            .frame(maxWidth: .infinity)
        }
        .containerBackground(WDS.bg, for: .widget)
    }
}

// MARK: - Lock screen (accessoryCircular)

private struct LockScreenView: View {
    let entry: StreakWidgetEntry

    var body: some View {
        ZStack {
            if entry.todayDone {
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .light))
            } else {
                VStack(spacing: 0) {
                    Text("\(entry.streak)")
                        .font(.system(size: 20, weight: .thin, design: .serif))
                        .monospacedDigit()
                    Text("days")
                        .font(.system(size: 8))
                }
            }
        }
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Entry view

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: StreakWidgetEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:       SmallView(entry: entry)
            case .systemMedium:      MediumView(entry: entry)
            case .accessoryCircular: LockScreenView(entry: entry)
            default:                 SmallView(entry: entry)
            }
        }
        .widgetURL(URL(string: "morningreset://start"))
    }
}

// MARK: - Widget

@main
struct MorningResetWidget: Widget {
    let kind = "MorningResetWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Morning Reset")
        .description("Your streak, always visible.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular])
    }
}
