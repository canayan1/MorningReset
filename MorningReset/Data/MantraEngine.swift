import Foundation

enum MorningMode: String, Equatable {
    case protect, steady, push

    init?(from string: String) {
        self.init(rawValue: string.lowercased())
    }
}

enum IntentionType: String, CaseIterable, Equatable {
    case calm, focus, energy, confidence, connection, discipline

    var label: String {
        switch self {
        case .calm:
            return L10n.text(en: "Calm", tr: "Sakinlik", es: "Calma")
        case .focus:
            return L10n.text(en: "Focus", tr: "Odak", es: "Foco")
        case .energy:
            return L10n.text(en: "Energy", tr: "Enerji", es: "Energía")
        case .confidence:
            return L10n.text(en: "Confidence", tr: "Güven", es: "Confianza")
        case .connection:
            return L10n.text(en: "Connection", tr: "Bağ", es: "Conexión")
        case .discipline:
            return L10n.text(en: "Discipline", tr: "Disiplin", es: "Disciplina")
        }
    }
}

enum SoundDirection: CaseIterable, Identifiable, Equatable {
    case calm, focus, energy

    var id: Self { self }

    var label: String {
        switch self {
        case .calm:
            return L10n.text(en: "Calm", tr: "Sakin", es: "Calma")
        case .focus:
            return L10n.text(en: "Focus", tr: "Odak", es: "Foco")
        case .energy:
            return L10n.text(en: "Energy", tr: "Enerji", es: "Energía")
        }
    }

    var todayPick: SoundPick {
        SoundLibrary.todayPick(for: self)
    }

    var playlistURL: URL? {
        todayPick.spotifyURL ?? todayPick.webURL
    }

    static func recommended(for mode: MorningMode) -> SoundDirection {
        switch mode {
        case .protect: return .calm
        case .steady:  return .focus
        case .push:    return .energy
        }
    }
}

enum MantraEngine {

    private static let startDateKey = "mantra_start_date"

    private static var cycleIndex: Int {
        let defaults = UserDefaults.standard
        let start: Date
        if let stored = defaults.object(forKey: startDateKey) as? Date {
            start = stored
        } else {
            let now = Date()
            defaults.set(now, forKey: startDateKey)
            start = now
        }
        let days = max(0, Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0)
        return (days / 21) % 3
    }

    static func generate(mode: MorningMode, intention: IntentionType) -> String {
        if mode == .protect && intention == .calm {
            return L10n.text(
                en: "Today, you move gently and protect your attention.",
                tr: "Bugün nazikçe hareket eder ve dikkatini korursun.",
                es: "Hoy te mueves con suavidad y proteges tu atención."
            )
        }
        if mode == .steady && intention == .focus {
            return L10n.text(
                en: "Today, you stay clear and follow what matters.",
                tr: "Bugün berrak kalır ve önemli olanı takip edersin.",
                es: "Hoy te mantienes claro y sigues lo que importa."
            )
        }
        if mode == .push && intention == .discipline {
            return L10n.text(
                en: "Today, you take action and build momentum.",
                tr: "Bugün harekete geçer ve ivme kurarsın.",
                es: "Hoy actúas y construyes impulso."
            )
        }

        let base: String
        switch mode {
        case .protect: base = protectBases[cycleIndex]
        case .steady:  base = steadyBases[cycleIndex]
        case .push:    base = pushBases[cycleIndex]
        }

        let modifier: String
        switch intention {
        case .calm:
            modifier = L10n.text(en: "Calm is the method.", tr: "Yöntem sakinlik.", es: "La calma es el método.")
        case .focus:
            modifier = L10n.text(en: "One thing at a time.", tr: "Aynı anda tek şey.", es: "Una cosa a la vez.")
        case .energy:
            modifier = L10n.text(en: "Direct what you have.", tr: "Elindekini yönlendir.", es: "Dirige lo que tienes.")
        case .confidence:
            modifier = L10n.text(en: "Act on what you know.", tr: "Bildiğin şeye göre hareket et.", es: "Actúa sobre lo que sabes.")
        case .connection:
            modifier = L10n.text(en: "Presence over performance.", tr: "Performans değil, mevcudiyet.", es: "Presencia antes que rendimiento.")
        case .discipline:
            modifier = L10n.text(en: "Do the first thing.", tr: "İlk şeyi yap.", es: "Haz lo primero.")
        }

        return "\(base) \(modifier)"
    }

    // MARK: - Weekly mantra

    static func weeklyMantra(for date: Date = Date()) -> String {
        MantraLibrary.mantra(for: date).text
    }

    private static let protectBases = [
        L10n.text(en: "Today doesn't need to be big. Just a little lighter than yesterday.", tr: "Bugünün büyük olması gerekmiyor. Sadece dünden biraz daha hafif olsun.", es: "Hoy no tiene que ser grande. Solo un poco más ligero que ayer."),
        L10n.text(en: "You don't have to fight the morning. Meet it where it is.", tr: "Sabahla savaşmak zorunda değilsin. Onu olduğu yerde karşıla.", es: "No tienes que pelear con la mañana. Encuéntrala donde está."),
        L10n.text(en: "Less noise, less pressure. That's enough to work with.", tr: "Daha az gürültü, daha az baskı. Bununla çalışmak yeter.", es: "Menos ruido, menos presión. Eso basta para trabajar.")
    ]

    private static let steadyBases = [
        L10n.text(en: "You know what to do. Stay with it and don't overcomplicate today.", tr: "Ne yapacağını biliyorsun. Onunla kal ve bugünü gereksiz yere karmaşıklaştırma.", es: "Sabes qué hacer. Mantente con ello y no compliques hoy."),
        L10n.text(en: "No sudden moves. Keep the rhythm you already have.", tr: "Ani hamle yok. Zaten sahip olduğun ritmi koru.", es: "Sin movimientos bruscos. Mantén el ritmo que ya tienes."),
        L10n.text(en: "Today is a continuation, not a restart. Pick up where you left off.", tr: "Bugün yeniden başlama değil, devam günü. Kaldığın yerden al.", es: "Hoy es una continuación, no un reinicio. Retoma donde lo dejaste.")
    ]

    private static let pushBases = [
        L10n.text(en: "You have something going. Use it cleanly and don't overload the day.", tr: "Sende çalışan bir şey var. Temiz kullan ve günü aşırı yükleme.", es: "Hay algo en marcha. Úsalo con claridad y no sobrecargues el día."),
        L10n.text(en: "Move forward. Not faster — just forward.", tr: "İleri git. Daha hızlı değil, sadece ileri.", es: "Avanza. No más rápido, solo hacia adelante."),
        L10n.text(en: "One good decision builds the next. Start there.", tr: "Bir iyi karar bir sonrakini kurar. Oradan başla.", es: "Una buena decisión construye la siguiente. Empieza ahí.")
    ]
}
