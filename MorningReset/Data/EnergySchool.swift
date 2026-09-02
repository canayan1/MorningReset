import SwiftUI

// MARK: - Tiers, palette and progress for the energy schools
//
// School *content* lives in bundled JSON (see SchoolContent.swift). This file
// holds what the app layers on top: paid tiers, per-school colour, and local
// progress. Every school ships one free routine, so all ten are sampleable.

enum EnergyTier: String, CaseIterable, Identifiable, Codable {
    case foundations
    case deep

    var id: String { rawValue }

    var title: String {
        switch self {
        case .foundations: return "Foundations"
        case .deep:        return "Deep"
        }
    }

    var blurb: String {
        switch self {
        case .foundations: return "The everyday practices"
        case .deep:        return "The longer, quieter work"
        }
    }

    /// StoreKit product for unlocking this tier (auto-renewable monthly).
    var productID: String {
        switch self {
        case .foundations: return "com.canayan.MorningReset.tier.foundations"
        case .deep:        return "com.canayan.MorningReset.tier.deep"
        }
    }

    var accent: Color {
        switch self {
        case .foundations: return DS.accent
        case .deep:        return Color(red: 0.42, green: 0.45, blue: 0.68)
        }
    }
}

/// Per-school colour and glyph, keyed by the content id.
enum SchoolPalette {
    static func color(_ id: String) -> Color {
        switch id {
        case "reiki":      return Color(red: 0.55, green: 0.44, blue: 0.78)   // amethyst
        case "breathing":  return Color(red: 0.38, green: 0.62, blue: 0.72)   // sky
        case "qigong":     return Color(red: 0.45, green: 0.64, blue: 0.50)   // jade
        case "meditation": return Color(red: 0.48, green: 0.47, blue: 0.72)   // indigo
        case "yoga":       return Color(red: 0.78, green: 0.52, blue: 0.60)   // rose
        case "sound":      return Color(red: 0.80, green: 0.62, blue: 0.36)   // gold
        case "coldheat":   return Color(red: 0.40, green: 0.63, blue: 0.75)   // ice
        case "sleep":      return Color(red: 0.40, green: 0.46, blue: 0.68)   // night
        case "nature":     return Color(red: 0.46, green: 0.65, blue: 0.47)   // leaf
        case "journal":    return Color(red: 0.66, green: 0.54, blue: 0.76)   // lilac
        default:           return DS.accent
        }
    }

    /// The photograph that stands for a tradition. Bundled in the asset
    /// catalogue; the id doubles as the asset name so there is nothing to keep
    /// in sync beyond the ten schools themselves.
    static func photo(_ id: String) -> String { "tradition-\(id)" }

    static func symbol(_ id: String) -> String {
        switch id {
        case "reiki":      return "hands.and.sparkles"
        case "breathing":  return "wind"
        case "qigong":     return "figure.mind.and.body"
        case "meditation": return "circle.hexagonpath"
        case "yoga":       return "figure.flexibility"
        case "sound":      return "waveform"
        case "coldheat":   return "snowflake"
        case "sleep":      return "moon.stars"
        case "nature":     return "leaf"
        case "journal":    return "square.and.pencil"
        default:           return "sparkles"
        }
    }
}

/// Per-school completion counts, derived from the practice log so that
/// deleting or editing a session updates progress everywhere.
enum SchoolProgressStore {
    static func completions(_ schoolID: String) -> Int {
        PracticeLogStore.completedCount(school: schoolID)
    }
}
