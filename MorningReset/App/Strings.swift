import Foundation

enum AppLanguage: String {
    case en
    case tr
    case es

    /// English, for now, whatever the phone is set to.
    ///
    /// The app ships three languages in its source and the Turkish and Spanish
    /// strings are all still here — but they were written alongside an older
    /// version of the product and the morning it now opens with has not been
    /// through a translator. Showing a half-translated app to a Turkish phone
    /// is worse than showing it an English one it can read.
    ///
    /// Restoring the device language is the one line marked below, and French
    /// joins the enum at the same time. Until the translations are done and
    /// checked, everyone gets the language the copy was actually written in.
    static var current: AppLanguage {
        if let override = ProcessInfo.processInfo.environment["MR_LANGUAGE_OVERRIDE"] {
            return AppLanguage(rawValue: override) ?? .en
        }
        return .en          // ← the line: `return fromDevice` when translated
    }

    /// What the device would choose. Kept live so the switch is a switch and
    /// not an archaeology project, and so the screenshot runs can still ask
    /// for a language by name.
    static var fromDevice: AppLanguage {
        let identifier = Locale.current.language.languageCode?.identifier ?? Locale.current.identifier
        if identifier.hasPrefix("tr") { return .tr }
        if identifier.hasPrefix("es") { return .es }
        return .en
    }
}

enum L10n {

    /// The locale the app's *words* are in — weekday names, month names.
    ///
    /// Only the words. Times, dates-as-numbers and prices stay with the
    /// phone's region, because 24-hour clocks and comma decimals are not a
    /// language choice and a Turkish reader wants them whatever the app is
    /// written in.
    static var locale: Locale { Locale(identifier: AppLanguage.current.rawValue) }

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
