// WidgetSnapshot.swift
//
// Tiny payload shared between the main app and the widget extension via App Group.
// The main app calls WidgetSnapshot.write(...) at the end of every flow.
// The widget calls WidgetSnapshot.read() each refresh.
//
// IMPORTANT: To make this work after adding the Widget Extension target,
// add an App Group capability to BOTH targets with this exact ID:
//
//     group.com.canayan.MorningReset
//
// This file should be a member of BOTH the main app target and the widget target.

import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

struct WidgetSnapshot: Codable {
    let mode: String
    let mantra: String
    let streak: Int

    static let placeholder = WidgetSnapshot(
        mode:   "steady",
        mantra: "Begin with what you can hold.",
        streak: 0
    )

    private static let suiteName = "group.com.canayan.MorningReset"
    private static let key       = "widget_snapshot_v1"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    static func write(mode: String, mantra: String, streak: Int) {
        let snapshot = WidgetSnapshot(mode: mode, mantra: mantra, streak: streak)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults?.set(data, forKey: key)
        #if canImport(WidgetKit)
        // Force the widget to refresh next time the system asks.
        // (Wrapped in canImport so this file compiles for both targets.)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    static func read() -> WidgetSnapshot? {
        guard let data = defaults?.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }
}
