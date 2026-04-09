// MorningResetWidget.swift
//
// READY-TO-INSTALL widget code. To activate:
//
// 1. In Xcode: File → New → Target → Widget Extension. Name it "MorningResetWidget".
//    Uncheck "Include Configuration Intent" (we use StaticConfiguration).
// 2. Replace the auto-generated widget Swift file with THIS file.
// 3. Add an App Group capability to BOTH the main app target and the widget target:
//      Group ID: group.com.canayan.MorningReset
// 4. Move the file `WidgetSnapshot.swift` (next to this file) into the widget target
//    AND keep it in the main app target — it's used by both.
// 5. Build & run. Long-press home screen → add MorningReset widget.
//
// The widget reads a tiny snapshot from the app group and renders today's
// mode + mantra. It refreshes once per hour and is force-refreshed by the
// main app whenever the user completes a flow (see WidgetSnapshot.write).

import WidgetKit
import SwiftUI

// MARK: - Provider

struct MorningEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct MorningProvider: TimelineProvider {
    func placeholder(in context: Context) -> MorningEntry {
        MorningEntry(date: Date(), snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (MorningEntry) -> Void) {
        completion(MorningEntry(date: Date(), snapshot: WidgetSnapshot.read() ?? .placeholder))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MorningEntry>) -> Void) {
        let entry = MorningEntry(date: Date(), snapshot: WidgetSnapshot.read() ?? .placeholder)
        let next  = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

// MARK: - View

struct MorningWidgetView: View {
    let entry: MorningEntry

    private var modeColor: Color {
        switch entry.snapshot.mode {
        case "protect": return Color(red: 0.682, green: 0.745, blue: 0.792)
        case "steady":  return Color(red: 0.910, green: 0.643, blue: 0.682)
        case "push":    return Color(red: 0.776, green: 0.443, blue: 0.510)
        default:        return Color(red: 0.886, green: 0.804, blue: 0.812)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Circle().fill(modeColor).frame(width: 6, height: 6)
                Text(entry.snapshot.mode.uppercased())
                    .font(.system(size: 9, weight: .medium))
                    .kerning(1.2)
                    .foregroundStyle(.secondary)
                Spacer()
                if entry.snapshot.streak > 0 {
                    Text("\(entry.snapshot.streak)d")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(entry.snapshot.mantra)
                .font(.system(.footnote, design: .serif))
                .foregroundStyle(.primary)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
            Spacer()
            Text("Morning Reset")
                .font(.system(size: 8, weight: .medium))
                .kerning(1.0)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .containerBackground(Color(red: 0.984, green: 0.965, blue: 0.957), for: .widget)
    }
}

// MARK: - Widget

struct MorningResetWidget: Widget {
    let kind: String = "MorningResetWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MorningProvider()) { entry in
            MorningWidgetView(entry: entry)
        }
        .configurationDisplayName("Morning Reset")
        .description("Today's mode and mantra at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct MorningResetWidgetBundle: WidgetBundle {
    var body: some Widget {
        MorningResetWidget()
    }
}
