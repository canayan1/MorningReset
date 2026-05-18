import Foundation

enum InsightStrength: Equatable {
    case none, weak, strong
}

enum PatternReader {

    // MARK: - Strength

    static func strength(for history: [DailyEntry]) -> InsightStrength {
        guard history.count >= 3 else { return .none }
        let last7 = Array(history.suffix(7))
        let last3 = Array(history.suffix(3))

        // Strong: same mode or intention in 5+ of last 7
        if last7.count >= 5 {
            let modes = last7.map { $0.mode }
            if let top = modes.mostFrequent(), modes.filter({ $0 == top }).count >= 5 { return .strong }
            let intentions = last7.map { $0.intention }
            if let top = intentions.mostFrequent(), intentions.filter({ $0 == top }).count >= 5 { return .strong }
        }

        // Weak: same mode all 3 of last 3, or same intention 3+ of last 7
        let modes3 = last3.map { $0.mode }
        if Set(modes3).count == 1 { return .weak }
        let intentions7 = last7.map { $0.intention }
        if let top = intentions7.mostFrequent(), intentions7.filter({ $0 == top }).count >= 3 { return .weak }

        return .none
    }

    // MARK: - Insight text

    static func weakInsight(for history: [DailyEntry]) -> String? {
        let last7 = Array(history.suffix(7))
        let last3 = Array(history.suffix(3))

        let modes3 = last3.map { $0.mode }
        if Set(modes3).count == 1, let mode = modes3.first {
            switch mode {
            case "protect":
                return L10n.text(en: "This morning feels slower — keep it simple.", tr: "Bu sabah daha yavaş hissettiriyor — sade tut.", es: "Esta mañana se siente más lenta; mantenlo simple.")
            case "steady":
                return L10n.text(en: "Start steady. No need to rush.", tr: "Dengeli başla. Acele etmene gerek yok.", es: "Empieza con calma. No hace falta apresurarse.")
            case "push":
                return L10n.text(en: "Move with intention today.", tr: "Bugün niyetle hareket et.", es: "Muévete con intención hoy.")
            default: break
            }
        }

        let intentions7 = last7.map { $0.intention }
        if let top = intentions7.mostFrequent(), intentions7.filter({ $0 == top }).count >= 3 {
            return L10n.text(
                en: "Today you're leaning toward \(top.capitalized).",
                tr: "Bugün \(localizedIntention(top)) yönüne eğiliyorsun.",
                es: "Hoy te inclinas hacia \(localizedIntention(top))."
            )
        }

        return nil
    }

    static func strongInsight(for history: [DailyEntry]) -> String? {
        let last7 = Array(history.suffix(7))
        let modes = last7.map { $0.mode }
        let intentions = last7.map { $0.intention }

        if let top = modes.mostFrequent(), modes.filter({ $0 == top }).count >= 5 {
            switch top {
            case "protect":
                return L10n.text(en: "Your mornings have been slower lately.", tr: "Sabahların son zamanlarda daha yavaş ilerliyor.", es: "Tus mañanas han ido más lentas últimamente.")
            case "steady":
                return L10n.text(en: "You've been leaning toward steadiness recently.", tr: "Son zamanlarda daha çok dengeye yöneliyorsun.", es: "Últimamente te estás inclinando hacia la constancia.")
            case "push":
                return L10n.text(en: "You're building consistency, even if it feels small.", tr: "Küçük hissettirse de istikrar kuruyorsun.", es: "Estás construyendo constancia, aunque parezca pequeña.")
            default: break
            }
        }

        if let top = intentions.mostFrequent(), intentions.filter({ $0 == top }).count >= 5 {
            return L10n.text(
                en: "You've been returning to \(top.capitalized) a lot this week.",
                tr: "Bu hafta sık sık \(localizedIntention(top)) yönüne geri dönüyorsun.",
                es: "Esta semana has vuelto mucho a \(localizedIntention(top))."
            )
        }

        return nil
    }

    // MARK: - Today reflection (always available, no history needed)

    static func todayReflection(mode: MorningMode, intention: IntentionType) -> String {
        switch (mode, intention) {
        case (.protect, .calm):
            return L10n.text(en: "Today begins with a lighter step.", tr: "Bugün daha hafif bir adımla başlıyor.", es: "Hoy empieza con un paso más ligero.")
        case (.protect, .focus):
            return L10n.text(en: "Keep your attention where it matters.", tr: "Dikkatini önemli yerde tut.", es: "Mantén tu atención donde importa.")
        case (.protect, .energy):
            return L10n.text(en: "Start steady. No need to rush.", tr: "Dengeli başla. Acele etmene gerek yok.", es: "Empieza con calma. No hace falta apresurarse.")
        case (.protect, .confidence):
            return L10n.text(en: "Today is about clarity, not intensity.", tr: "Bugün yoğunluk değil, berraklık günü.", es: "Hoy va de claridad, no de intensidad.")
        case (.protect, .connection):
            return L10n.text(en: "Move with intention today.", tr: "Bugün niyetle hareket et.", es: "Muévete con intención hoy.")
        case (.protect, .discipline):
            return L10n.text(en: "This morning feels slower — keep it simple.", tr: "Bu sabah daha yavaş hissettiriyor — sade tut.", es: "Esta mañana se siente más lenta; mantenlo simple.")
        case (.steady, .focus):
            return L10n.text(en: "Keep your attention where it matters.", tr: "Dikkatini önemli yerde tut.", es: "Mantén tu atención donde importa.")
        case (.steady, .calm):
            return L10n.text(en: "You're starting with calm today.", tr: "Bugün sakinlikle başlıyorsun.", es: "Hoy empiezas con calma.")
        case (.steady, .energy):
            return L10n.text(en: "Start steady. No need to rush.", tr: "Dengeli başla. Acele etmene gerek yok.", es: "Empieza con calma. No hace falta apresurarse.")
        case (.steady, .confidence):
            return L10n.text(en: "Today is about clarity, not intensity.", tr: "Bugün yoğunluk değil, berraklık günü.", es: "Hoy va de claridad, no de intensidad.")
        case (.steady, .connection):
            return L10n.text(en: "Move with intention today.", tr: "Bugün niyetle hareket et.", es: "Muévete con intención hoy.")
        case (.steady, .discipline):
            return L10n.text(en: "Today is about clarity, not intensity.", tr: "Bugün yoğunluk değil, berraklık günü.", es: "Hoy va de claridad, no de intensidad.")
        case (.push, .calm):
            return L10n.text(en: "You're starting with calm today.", tr: "Bugün sakinlikle başlıyorsun.", es: "Hoy empiezas con calma.")
        case (.push, .focus):
            return L10n.text(en: "Today you're leaning toward Focus.", tr: "Bugün odağa yöneliyorsun.", es: "Hoy te inclinas hacia el foco.")
        case (.push, .energy):
            return L10n.text(en: "Move with intention today.", tr: "Bugün niyetle hareket et.", es: "Muévete con intención hoy.")
        case (.push, .confidence):
            return L10n.text(en: "Today is about clarity, not intensity.", tr: "Bugün yoğunluk değil, berraklık günü.", es: "Hoy va de claridad, no de intensidad.")
        case (.push, .connection):
            return L10n.text(en: "Move with intention today.", tr: "Bugün niyetle hareket et.", es: "Muévete con intención hoy.")
        case (.push, .discipline):
            return L10n.text(en: "Today is about clarity, not intensity.", tr: "Bugün yoğunluk değil, berraklık günü.", es: "Hoy va de claridad, no de intensidad.")
        }
    }
}

// MARK: - Array helper

private func localizedIntention(_ rawValue: String) -> String {
    IntentionType(rawValue: rawValue)?.label ?? rawValue.capitalized
}

private extension Array where Element == String {
    func mostFrequent() -> String? {
        var counts: [String: Int] = [:]
        for item in self { counts[item, default: 0] += 1 }
        return counts.max(by: { $0.value < $1.value })?.key
    }
}
