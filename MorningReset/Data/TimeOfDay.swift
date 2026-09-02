import Foundation

// MARK: - Time of day
//
// The app began life as a morning-only ritual and a lot of its copy still
// assumed that. Energy Reset is used at any hour, so anything that refers to
// "now" asks this instead of hard-coding the morning.

enum TimeOfDay: String, CaseIterable {
    case morning, afternoon, evening, night

    static func at(_ date: Date = Date(), calendar: Calendar = .current) -> TimeOfDay {
        switch calendar.component(.hour, from: date) {
        case 5...11:  return .morning
        case 12...16: return .afternoon
        case 17...21: return .evening
        default:      return .night     // 22–4
        }
    }

    static var current: TimeOfDay { at() }

    /// Slots into a sentence: "Your field is bright <phrase>."
    var phrase: String {
        switch self {
        case .morning:
            return L10n.text(en: "this morning", tr: "bu sabah", es: "esta mañana")
        case .afternoon:
            return L10n.text(en: "this afternoon", tr: "bu öğleden sonra", es: "esta tarde")
        case .evening:
            return L10n.text(en: "this evening", tr: "bu akşam", es: "esta noche")
        case .night:
            return L10n.text(en: "tonight", tr: "bu gece", es: "esta noche")
        }
    }

    /// "…hold through the rest of <span>."
    var span: String {
        switch self {
        case .morning:
            return L10n.text(en: "the morning", tr: "sabah", es: "la mañana")
        case .afternoon:
            return L10n.text(en: "the afternoon", tr: "öğleden sonra", es: "la tarde")
        case .evening:
            return L10n.text(en: "the evening", tr: "akşam", es: "la tarde")
        case .night:
            return L10n.text(en: "the night", tr: "gece", es: "la noche")
        }
    }

    /// A greeting for whenever the user actually opened the app.
    var greeting: String {
        switch self {
        case .morning:
            return L10n.text(en: "Good morning", tr: "Günaydın", es: "Buenos días")
        case .afternoon:
            return L10n.text(en: "Good afternoon", tr: "İyi günler", es: "Buenas tardes")
        case .evening:
            return L10n.text(en: "Good evening", tr: "İyi akşamlar", es: "Buenas tardes")
        case .night:
            return L10n.text(en: "Still up", tr: "Hâlâ ayaktasın", es: "Aún despierto")
        }
    }

    /// Plain English for the model. Never localised — the prompt is English.
    var promptLabel: String { rawValue }
}
