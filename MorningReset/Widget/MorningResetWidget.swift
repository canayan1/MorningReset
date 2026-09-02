import WidgetKit
import SwiftUI
import ActivityKit
import AppIntents

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

    // Consecutive-day streak ending today or yesterday — mirrors AppState.computeStreak.
    static func streak(from entries: [WidgetEntry]) -> Int {
        guard !entries.isEmpty else { return 0 }
        let cal   = Calendar.current
        let today = cal.startOfDay(for: Date())
        guard let yesterday = cal.date(byAdding: .day, value: -1, to: today) else { return 0 }
        let days = Array(Set(entries.map { cal.startOfDay(for: $0.date) })).sorted(by: >)
        guard let first = days.first, first == today || first == yesterday else { return 0 }
        var streak   = 0
        var expected = first
        for day in days {
            if day == expected {
                streak += 1
                expected = cal.date(byAdding: .day, value: -1, to: expected) ?? expected
            } else {
                break
            }
        }
        return streak
    }

    static func pathSymbol() -> String {
        guard let raw = UserDefaults(suiteName: suiteName)?.string(forKey: "widget_path") else {
            return "sparkles"
        }
        switch raw {
        case "reiki":      return "hands.and.sparkles.fill"
        case "breathwork": return "wind"
        case "qigong":     return "figure.mind.and.body"
        default:           return "sparkles"
        }
    }

    static func mantra() -> String {
        UserDefaults(suiteName: suiteName)?.string(forKey: "widget_mantra")
            ?? "Begin with one honest, small action."
    }
}

// MARK: - Widget Theme

enum WidgetTheme: String, CaseIterable, AppEnum {
    case dawn, ember, forest, tide, petal, night

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Theme"
    static var caseDisplayRepresentations: [WidgetTheme: DisplayRepresentation] = [
        .dawn:   DisplayRepresentation(title: "Dawn"),
        .ember:  DisplayRepresentation(title: "Ember"),
        .forest: DisplayRepresentation(title: "Forest"),
        .tide:   DisplayRepresentation(title: "Tide"),
        .petal:  DisplayRepresentation(title: "Petal"),
        .night:  DisplayRepresentation(title: "Night"),
    ]

    var gradient: LinearGradient {
        switch self {
        case .dawn:
            return LinearGradient(colors: [
                Color(red: 1.00, green: 0.96, blue: 0.89),
                Color(red: 0.97, green: 0.94, blue: 0.91)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .ember:
            return LinearGradient(colors: [
                Color(red: 0.16, green: 0.09, blue: 0.03),
                Color(red: 0.08, green: 0.04, blue: 0.01)
            ], startPoint: .top, endPoint: .bottom)
        case .forest:
            return LinearGradient(colors: [
                Color(red: 0.06, green: 0.14, blue: 0.08),
                Color(red: 0.02, green: 0.07, blue: 0.03)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .tide:
            return LinearGradient(colors: [
                Color(red: 0.05, green: 0.14, blue: 0.24),
                Color(red: 0.02, green: 0.07, blue: 0.14)
            ], startPoint: .top, endPoint: .bottom)
        case .petal:
            return LinearGradient(colors: [
                Color(red: 0.97, green: 0.87, blue: 0.85),
                Color(red: 0.91, green: 0.75, blue: 0.73)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .night:
            return LinearGradient(colors: [
                Color(red: 0.09, green: 0.10, blue: 0.16),
                Color(red: 0.04, green: 0.05, blue: 0.09)
            ], startPoint: .top, endPoint: .bottom)
        }
    }

    var orbColor: Color {
        switch self {
        case .dawn:   return Color(red: 0.88, green: 0.66, blue: 0.28).opacity(0.32)
        case .ember:  return Color(red: 0.92, green: 0.48, blue: 0.15).opacity(0.45)
        case .forest: return Color(red: 0.28, green: 0.82, blue: 0.40).opacity(0.32)
        case .tide:   return Color(red: 0.20, green: 0.68, blue: 0.92).opacity(0.32)
        case .petal:  return Color(red: 0.90, green: 0.50, blue: 0.55).opacity(0.38)
        case .night:  return Color(red: 0.22, green: 0.40, blue: 0.88).opacity(0.30)
        }
    }

    var primaryText: Color {
        switch self {
        case .dawn:   return Color(red: 0.15, green: 0.12, blue: 0.09)
        case .ember:  return Color(red: 0.98, green: 0.92, blue: 0.82)
        case .forest: return Color(red: 0.86, green: 0.96, blue: 0.88)
        case .tide:   return Color(red: 0.86, green: 0.95, blue: 1.00)
        case .petal:  return Color(red: 0.32, green: 0.16, blue: 0.18)
        case .night:  return Color(red: 0.88, green: 0.92, blue: 0.98)
        }
    }

    var dimText: Color { primaryText.opacity(0.50) }

    var accentColor: Color {
        switch self {
        case .dawn:   return Color(red: 0.55, green: 0.42, blue: 0.28)
        case .ember:  return Color(red: 0.96, green: 0.70, blue: 0.32)
        case .forest: return Color(red: 0.45, green: 0.92, blue: 0.52)
        case .tide:   return Color(red: 0.36, green: 0.84, blue: 0.96)
        case .petal:  return Color(red: 0.68, green: 0.30, blue: 0.36)
        case .night:  return Color(red: 0.50, green: 0.74, blue: 0.98)
        }
    }

    func dotColor(mode: String, done: Bool) -> Color {
        guard done else { return accentColor.opacity(0.18) }
        switch mode {
        case "protect": return accentColor.opacity(0.40)
        case "steady":  return accentColor.opacity(0.70)
        default:        return accentColor
        }
    }
}

// MARK: - Configuration Intent

struct WidgetThemeIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Inner Light"
    static let description = IntentDescription("Choose your widget theme.")

    @Parameter(title: "Theme", default: .ember)
    var theme: WidgetTheme
}

// MARK: - Timeline entry

struct StreakWidgetEntry: TimelineEntry {
    let date:       Date
    let last7:      [(done: Bool, mode: String)]
    let theme:      WidgetTheme
    let pathSymbol: String
    let mantra:     String
    let streak:     Int
}

// MARK: - Provider

struct StreakProvider: AppIntentTimelineProvider {
    typealias Intent = WidgetThemeIntent
    typealias Entry  = StreakWidgetEntry

    func placeholder(in context: Context) -> StreakWidgetEntry {
        StreakWidgetEntry(
            date: Date(),
            last7: [(true,"push"),(true,"steady"),(true,"push"),(false,""),(false,""),(true,"steady"),(false,"")],
            theme: .ember,
            pathSymbol: "wind",
            mantra: "Begin with one honest, small action.",
            streak: 4
        )
    }

    func snapshot(for configuration: WidgetThemeIntent, in context: Context) async -> StreakWidgetEntry {
        makeEntry(theme: configuration.theme)
    }

    func timeline(for configuration: WidgetThemeIntent, in context: Context) async -> Timeline<StreakWidgetEntry> {
        let entry    = makeEntry(theme: configuration.theme)
        let midnight = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        )
        return Timeline(entries: [entry], policy: .after(midnight))
    }

    private func makeEntry(theme: WidgetTheme) -> StreakWidgetEntry {
        let entries = WidgetStore.load()
        return StreakWidgetEntry(
            date:       Date(),
            last7:      WidgetStore.last7(from: entries),
            theme:      theme,
            pathSymbol: WidgetStore.pathSymbol(),
            mantra:     WidgetStore.mantra(),
            streak:     WidgetStore.streak(from: entries)
        )
    }
}

// MARK: - Background

private struct WidgetBackground: View {
    let theme: WidgetTheme
    var body: some View {
        ZStack {
            theme.gradient
            Circle()
                .fill(theme.orbColor)
                .frame(width: 110, height: 110)
                .blur(radius: 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: 18, y: -18)
            Circle()
                .fill(theme.orbColor.opacity(0.55))
                .frame(width: 55, height: 55)
                .blur(radius: 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .offset(x: -10, y: 10)
        }
    }
}

// MARK: - Day row  (replaces dot row — rounded cells + day letters avoid page-control association)

private struct DayRow: View {
    let days:  [(done: Bool, mode: String)]
    let theme: WidgetTheme

    // Dynamic letters so the row always reflects the real calendar week
    private var letters: [String] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEEE"          // Single letter: M T W T F S S
        return (0..<7).reversed().compactMap { i in
            cal.date(byAdding: .day, value: -i, to: today).map { fmt.string(from: $0) }
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(days.indices, id: \.self) { i in
                let isToday = i == days.count - 1
                VStack(spacing: 3) {
                    Text(letters[i])
                        .font(.system(size: 6, weight: isToday ? .bold : .regular))
                        .foregroundStyle(
                            isToday ? theme.primaryText.opacity(0.80)
                            : (days[i].done ? theme.primaryText.opacity(0.55) : theme.dimText)
                        )
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.dotColor(mode: days[i].mode, done: days[i].done))
                        .frame(width: 8, height: 8)
                        .overlay(
                            isToday && !days[i].done
                            ? RoundedRectangle(cornerRadius: 2).stroke(theme.accentColor.opacity(0.50), lineWidth: 1)
                            : nil
                        )
                }
            }
        }
    }
}

// MARK: - Streak badge  (language-neutral: flame + count)

private struct StreakBadge: View {
    let streak: Int
    let theme:  WidgetTheme
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "flame.fill")
                .font(.system(size: 8))
            Text("\(streak)")
                .font(.system(size: 11, weight: .semibold, design: .serif))
                .monospacedDigit()
        }
        .foregroundStyle(theme.accentColor)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(theme.accentColor.opacity(0.14), in: Capsule())
    }
}

// MARK: - Small widget

private struct SmallView: View {
    let entry: StreakWidgetEntry
    var body: some View {
        let t = entry.theme
        VStack(spacing: 0) {
            Spacer()
            Image(systemName: entry.pathSymbol)
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(t.primaryText.opacity(0.88))
            Spacer().frame(height: 10)
            Text(entry.mantra)
                .font(.system(size: 10, design: .serif).italic())
                .foregroundStyle(t.dimText)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            DayRow(days: entry.last7, theme: t)
                .padding(.bottom, 4)
        }
        .padding(.horizontal, 14)
        .overlay(alignment: .topTrailing) {
            if entry.streak > 0 {
                StreakBadge(streak: entry.streak, theme: t)
                    .padding(.top, 10)
                    .padding(.trailing, 2)
            }
        }
        .containerBackground(for: .widget) { WidgetBackground(theme: t) }
    }
}

// MARK: - Medium widget

private struct MediumView: View {
    let entry: StreakWidgetEntry
    var body: some View {
        let t = entry.theme
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: entry.pathSymbol)
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(t.primaryText.opacity(0.88))
                    .frame(width: 34, alignment: .leading)
                Text(entry.mantra)
                    .font(.system(size: 12, design: .serif).italic())
                    .foregroundStyle(t.dimText)
                    .lineSpacing(3)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            DayRow(days: entry.last7, theme: t)
                .padding(.bottom, 4)
        }
        .padding(.horizontal, 18)
        .overlay(alignment: .topTrailing) {
            if entry.streak > 0 {
                StreakBadge(streak: entry.streak, theme: t)
                    .padding(.top, 14)
                    .padding(.trailing, 6)
            }
        }
        .containerBackground(for: .widget) { WidgetBackground(theme: t) }
    }
}

// MARK: - Lock screen (accessoryCircular)

private struct LockScreenView: View {
    let entry: StreakWidgetEntry
    var body: some View {
        Image(systemName: entry.pathSymbol)
            .font(.system(size: 20, weight: .light))
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

// MARK: - Live Activity design tokens (fixed)

private enum WDS {
    static let bg      = Color(red: 0.973, green: 0.953, blue: 0.925)
    static let accent  = Color(red: 0.549, green: 0.424, blue: 0.282)
    static let text    = Color(red: 0.149, green: 0.118, blue: 0.090)
    static let textDim = Color(red: 0.149, green: 0.118, blue: 0.090).opacity(0.40)
}

// MARK: - Live Activity

struct WakeLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WakeActivityAttributes.self) { context in
            WakeLiveActivityLockScreenView(state: context.state)
                .widgetURL(URL(string: "morningreset://start"))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "sun.horizon.fill")
                        .foregroundStyle(WDS.accent)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.phase == .ringing {
                        Text("Begin →")
                            .font(.system(size: 13, weight: .semibold, design: .serif))
                            .foregroundStyle(WDS.accent)
                    } else {
                        Text(context.state.fireDate, style: .time)
                            .font(.system(size: 13, design: .serif))
                            .foregroundStyle(WDS.text)
                            .monospacedDigit()
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.tagline)
                        .font(.system(size: 12, design: .serif))
                        .foregroundStyle(WDS.textDim)
                }
            } compactLeading: {
                Image(systemName: "sun.horizon.fill")
                    .foregroundStyle(WDS.accent)
            } compactTrailing: {
                Text(context.state.fireDate, style: .time)
                    .monospacedDigit()
                    .foregroundStyle(WDS.text)
            } minimal: {
                Image(systemName: "sun.horizon.fill")
                    .foregroundStyle(WDS.accent)
            }
            .widgetURL(URL(string: "morningreset://start"))
        }
    }
}

private struct WakeLiveActivityLockScreenView: View {
    let state: WakeActivityAttributes.ContentState
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("ENERGY RESET")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(WDS.textDim)
                Text(state.tagline)
                    .font(.system(size: 16, design: .serif))
                    .foregroundStyle(WDS.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 2) {
                if state.phase == .ringing {
                    Text("Begin →")
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundStyle(WDS.accent)
                } else {
                    Text(state.fireDate, style: .time)
                        .font(.system(size: 28, weight: .thin, design: .serif))
                        .foregroundStyle(WDS.text)
                        .monospacedDigit()
                }
            }
        }
        .padding(16)
        .activityBackgroundTint(WDS.bg)
        .activitySystemActionForegroundColor(WDS.accent)
    }
}

// MARK: - Widget Bundle

@main
struct MorningResetWidgetBundle: WidgetBundle {
    var body: some Widget {
        MorningResetWidget()
        WakeLiveActivity()
    }
}

struct MorningResetWidget: Widget {
    let kind = "MorningResetWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: WidgetThemeIntent.self, provider: StreakProvider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Inner Light")
        .description("Your energy practice, every day.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular])
    }
}
