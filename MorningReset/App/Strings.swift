import Foundation

enum AppLanguage: String {
    case en
    case tr
    case es

    static var current: AppLanguage {
        if let override = ProcessInfo.processInfo.environment["MR_LANGUAGE_OVERRIDE"] {
            return AppLanguage(rawValue: override) ?? .en
        }

        let identifier = Locale.current.language.languageCode?.identifier ?? Locale.current.identifier
        if identifier.hasPrefix("tr") { return .tr }
        if identifier.hasPrefix("es") { return .es }
        return .en
    }
}

enum L10n {
    static func text(
        language: AppLanguage = .current,
        en: String,
        tr: String,
        es: String
    ) -> String {
        switch language {
        case .en: return en
        case .tr: return tr
        case .es: return es
        }
    }
}

enum Strings {

    enum Quiz {
        static func progress(current: Int, total: Int) -> String {
            "\(current)/\(total)"
        }
    }
}
