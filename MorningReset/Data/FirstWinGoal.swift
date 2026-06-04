import Foundation

// MARK: - Presentation

struct FirstWinPresentation: Equatable {
    let symbol: String
    let title: String
    let how: String
    let checkPrompt: String
    let winTitle: String
    let winBody: String
    var steps: [String] = []
}

// MARK: - Health & Fitness preset set

enum FirstWinPreset: String, Codable, CaseIterable, Identifiable, Equatable {
    case hydrate
    case move
    case stretch
    case daylight
    case intention
    case oneThing
    case readPage
    case breathe
    case phoneDown
    case grateful

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .hydrate:   return "drop.fill"
        case .move:      return "figure.strengthtraining.traditional"
        case .stretch:   return "figure.flexibility"
        case .daylight:  return "sun.max.fill"
        case .intention: return "square.and.pencil"
        case .oneThing:  return "target"
        case .readPage:  return "book.fill"
        case .breathe:   return "lungs.fill"
        case .phoneDown: return "iphone.slash"
        case .grateful:  return "heart.fill"
        }
    }

    var title: String {
        switch self {
        case .hydrate:   return L10n.text(en: "Drink water", tr: "Su iç", es: "Bebe agua")
        case .move:      return L10n.text(en: "Move", tr: "Hareket et", es: "Muévete")
        case .stretch:   return L10n.text(en: "Stretch", tr: "Esne", es: "Estírate")
        case .daylight:  return L10n.text(en: "Get daylight", tr: "Gün ışığı al", es: "Toma luz natural")
        case .intention: return L10n.text(en: "Set your intention", tr: "Niyetini yaz", es: "Define tu intención")
        case .oneThing:  return L10n.text(en: "Name your one thing", tr: "Tek önceliğini seç", es: "Elige tu prioridad")
        case .readPage:  return L10n.text(en: "Read one page", tr: "Bir sayfa oku", es: "Lee una página")
        case .breathe:   return L10n.text(en: "Breathe", tr: "Nefes al", es: "Respira")
        case .phoneDown: return L10n.text(en: "Phone down", tr: "Telefonu bırak", es: "Sin teléfono")
        case .grateful:  return L10n.text(en: "One grateful thought", tr: "Bir şükran", es: "Un pensamiento de gratitud")
        }
    }

    var how: String {
        switch self {
        case .hydrate:   return L10n.text(en: "A full glass before anything else.", tr: "Her şeyden önce dolu bir bardak.", es: "Un vaso lleno antes que nada.")
        case .move:      return L10n.text(en: "Ten squats or push-ups.", tr: "On squat ya da şınav.", es: "Diez sentadillas o flexiones.")
        case .stretch:   return L10n.text(en: "Sixty seconds, head to toe.", tr: "Tepeden tırnağa altmış saniye.", es: "Sesenta segundos, de pies a cabeza.")
        case .daylight:  return L10n.text(en: "Step outside or to a window.", tr: "Dışarı ya da pencereye git.", es: "Sal afuera o ve a una ventana.")
        case .intention: return L10n.text(en: "Write one line: what is today for?", tr: "Tek satır yaz: bugün ne için?", es: "Escribe una línea: ¿para qué es hoy?")
        case .oneThing:  return L10n.text(en: "Pick the single thing that matters today.", tr: "Bugün önemli olan tek şeyi seç.", es: "Elige lo único que importa hoy.")
        case .readPage:  return L10n.text(en: "One page of something good.", tr: "İyi bir şeyden bir sayfa.", es: "Una página de algo bueno.")
        case .breathe:   return L10n.text(en: "Six slow breaths.", tr: "Altı yavaş nefes.", es: "Seis respiraciones lentas.")
        case .phoneDown: return L10n.text(en: "Five minutes face down.", tr: "Beş dakika ekran aşağı.", es: "Cinco minutos boca abajo.")
        case .grateful:  return L10n.text(en: "Bring one thing you're grateful for to mind.", tr: "Minnettar olduğun bir şeyi aklına getir.", es: "Trae a la mente algo que agradeces.")
        }
    }

    var why: String {
        switch self {
        case .hydrate:   return L10n.text(en: "Start physical, not reactive.", tr: "Tepkisel değil, fiziksel başla.", es: "Empieza físico, no reactivo.")
        case .move:      return L10n.text(en: "Spend energy on your body before the day spends it.", tr: "Gün harcamadan enerjini bedenine ver.", es: "Gasta energía en tu cuerpo antes de que el día lo haga.")
        case .stretch:   return L10n.text(en: "Wake the body before the noise.", tr: "Gürültüden önce bedeni uyandır.", es: "Despierta el cuerpo antes del ruido.")
        case .daylight:  return L10n.text(en: "Give your body clock a clear \"start.\"", tr: "İç saatine net bir \"başla\" ver.", es: "Dale a tu reloj interno un claro \"empieza\".")
        case .intention: return L10n.text(en: "Name what today is for, before the world does.", tr: "Dünya senin için koymadan, bugünün anlamını sen koy.", es: "Nombra para qué es hoy, antes de que el mundo lo haga.")
        case .oneThing:  return L10n.text(en: "One clear thing beats a busy list.", tr: "Tek net şey, dolu listeyi yener.", es: "Una cosa clara vence a una lista llena.")
        case .readPage:  return L10n.text(en: "Feed your mind before the feed does.", tr: "Aklını feed'den önce besle.", es: "Alimenta tu mente antes que el feed.")
        case .breathe:   return L10n.text(en: "Choose calm before the day chooses for you.", tr: "Gün senin için seçmeden, sakinliği sen seç.", es: "Elige la calma antes de que el día elija por ti.")
        case .phoneDown: return L10n.text(en: "The first minutes are yours, not the feed's.", tr: "İlk dakikalar senin, feed'in değil.", es: "Los primeros minutos son tuyos, no del feed.")
        case .grateful:  return L10n.text(en: "Begin from enough, not from lack.", tr: "Eksiklikten değil, yeterlilikten başla.", es: "Empieza desde la suficiencia, no la carencia.")
        }
    }

    var checkPrompt: String {
        switch self {
        case .hydrate:   return L10n.text(en: "Did you drink the water?", tr: "Suyunu içtin mi?", es: "¿Bebiste el agua?")
        case .move:      return L10n.text(en: "Did you move?", tr: "Hareket ettin mi?", es: "¿Te moviste?")
        case .stretch:   return L10n.text(en: "Did you stretch?", tr: "Esnedin mi?", es: "¿Te estiraste?")
        case .daylight:  return L10n.text(en: "Did you get daylight?", tr: "Gün ışığı aldın mı?", es: "¿Tomaste luz natural?")
        case .intention: return L10n.text(en: "Did you set your intention?", tr: "Niyetini yazdın mı?", es: "¿Definiste tu intención?")
        case .oneThing:  return L10n.text(en: "Did you name your one thing?", tr: "Tek önceliğini seçtin mi?", es: "¿Elegiste tu prioridad?")
        case .readPage:  return L10n.text(en: "Did you read a page?", tr: "Bir sayfa okudun mu?", es: "¿Leíste una página?")
        case .breathe:   return L10n.text(en: "Did you breathe?", tr: "Nefes aldın mı?", es: "¿Respiraste?")
        case .phoneDown: return L10n.text(en: "Did you keep the phone down?", tr: "Telefonu bıraktın mı?", es: "¿Dejaste el teléfono?")
        case .grateful:  return L10n.text(en: "Did you find your grateful thought?", tr: "Şükranını buldun mu?", es: "¿Encontraste tu gratitud?")
        }
    }

    var winTitle: String {
        switch self {
        case .hydrate:   return L10n.text(en: "You started with water.", tr: "Su ile başladın.", es: "Empezaste con agua.")
        case .move:      return L10n.text(en: "You moved before the scroll.", tr: "Kaydırmadan önce hareket ettin.", es: "Te moviste antes del scroll.")
        case .stretch:   return L10n.text(en: "Your body woke up first.", tr: "Önce bedenin uyandı.", es: "Tu cuerpo despertó primero.")
        case .daylight:  return L10n.text(en: "You met the light.", tr: "Işıkla buluştun.", es: "Te encontraste con la luz.")
        case .intention: return L10n.text(en: "You named the day.", tr: "Güne bir anlam koydun.", es: "Le diste un sentido al día.")
        case .oneThing:  return L10n.text(en: "You chose your focus.", tr: "Odağını seçtin.", es: "Elegiste tu enfoque.")
        case .readPage:  return L10n.text(en: "You fed your mind first.", tr: "Önce aklını besledin.", es: "Primero alimentaste tu mente.")
        case .breathe:   return L10n.text(en: "You started calm.", tr: "Sakin başladın.", es: "Empezaste en calma.")
        case .phoneDown: return L10n.text(en: "You protected the first minutes.", tr: "İlk dakikaları korudun.", es: "Protegiste los primeros minutos.")
        case .grateful:  return L10n.text(en: "You started from enough.", tr: "Yeterlilikten başladın.", es: "Empezaste desde la suficiencia.")
        }
    }

    var winBody: String {
        switch self {
        case .hydrate:   return L10n.text(en: "Your body came first today.", tr: "Bugün önce bedenin geldi.", es: "Hoy tu cuerpo fue primero.")
        case .move:      return L10n.text(en: "Energy, on purpose.", tr: "Bilinçli bir enerji.", es: "Energía, a propósito.")
        case .stretch:   return L10n.text(en: "Gentle, but yours.", tr: "Nazik ama senin.", es: "Suave, pero tuyo.")
        case .daylight:  return L10n.text(en: "The day has a clear edge now.", tr: "Günün artık net bir başı var.", es: "El día ya tiene un inicio claro.")
        case .intention: return L10n.text(en: "Direction before input.", tr: "Girdilerden önce yön.", es: "Dirección antes que entradas.")
        case .oneThing:  return L10n.text(en: "Clarity, first thing.", tr: "İlk iş, netlik.", es: "Claridad, lo primero.")
        case .readPage:  return L10n.text(en: "Better input, better day.", tr: "Daha iyi girdi, daha iyi gün.", es: "Mejor entrada, mejor día.")
        case .breathe:   return L10n.text(en: "Steady, on purpose.", tr: "Bilinçli bir denge.", es: "Estable, a propósito.")
        case .phoneDown: return L10n.text(en: "Your attention stayed yours.", tr: "Dikkatin sana ait kaldı.", es: "Tu atención siguió siendo tuya.")
        case .grateful:  return L10n.text(en: "A fuller kind of morning.", tr: "Daha dolu bir sabah.", es: "Una mañana más plena.")
        }
    }

    var presentation: FirstWinPresentation {
        FirstWinPresentation(symbol: symbol, title: title, how: how, checkPrompt: checkPrompt, winTitle: winTitle, winBody: winBody)
    }
}

// MARK: - Active commitment

enum FirstWinKind: Codable, Equatable {
    case practice(path: EnergyPath, id: String)
    case custom(String)

    var practice: PathPractice? {
        if case let .practice(path, id) = self { return path.practice(id: id) }
        return nil
    }

    var symbol: String { practice?.symbol ?? "sparkles" }

    var title: String {
        switch self {
        case .practice:      return practice?.title ?? ""
        case .custom(let t): return t
        }
    }

    var presentation: FirstWinPresentation {
        if let p = practice { return p.presentation }
        let customTitle: String = { if case let .custom(t) = self { return t } ; return "" }()
        return FirstWinPresentation(
            symbol: "sparkles",
            title: customTitle,
            how: "",
            checkPrompt: L10n.text(en: "Did you do it?", tr: "Yaptın mı?", es: "¿Lo hiciste?"),
            winTitle: L10n.text(en: "You showed up.", tr: "Devam ettin.", es: "Apareciste."),
            winBody: L10n.text(en: "One more morning, kept.", tr: "Bir sabah daha, korundu.", es: "Una mañana más, cumplida.")
        )
    }
}

struct ActiveFirstWin: Codable, Equatable {
    var kind: FirstWinKind
    var streak: Int
    var lastCheckDay: Date?
    var startedAt: Date

    /// Streak shown to the user, accounting for a break since the last check.
    func displayStreak(now: Date = Date()) -> Int {
        guard let last = lastCheckDay else { return 0 }
        let cal = Calendar.current
        let today = cal.startOfDay(for: now)
        let lastDay = cal.startOfDay(for: last)
        if lastDay == today { return streak }
        if let yesterday = cal.date(byAdding: .day, value: -1, to: today), lastDay == yesterday { return streak }
        return 0
    }

    func checkedToday(now: Date = Date()) -> Bool {
        guard let last = lastCheckDay else { return false }
        return Calendar.current.isDate(last, inSameDayAs: now)
    }
}

struct CompletedFirstWin: Codable, Equatable, Identifiable {
    var id: UUID
    var symbol: String
    var title: String
    var completedAt: Date

    init(id: UUID = UUID(), symbol: String, title: String, completedAt: Date) {
        self.id = id
        self.symbol = symbol
        self.title = title
        self.completedAt = completedAt
    }
}

// MARK: - Store

enum FirstWinStore {
    static let target = 7

    private static let activeKey    = UDKey.firstWinActive
    private static let completedKey = UDKey.firstWinCompleted
    private static let suiteName    = "group.com.canayan.MorningReset"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? UserDefaults.standard
    }

    static func loadActive() -> ActiveFirstWin? {
        guard let data = defaults.data(forKey: activeKey),
              let value = try? JSONDecoder().decode(ActiveFirstWin.self, from: data)
        else { return nil }
        return value
    }

    static func saveActive(_ value: ActiveFirstWin?) {
        guard let value, let data = try? JSONEncoder().encode(value) else {
            defaults.removeObject(forKey: activeKey)
            return
        }
        defaults.set(data, forKey: activeKey)
    }

    static func loadCompleted() -> [CompletedFirstWin] {
        guard let data = defaults.data(forKey: completedKey),
              let value = try? JSONDecoder().decode([CompletedFirstWin].self, from: data)
        else { return [] }
        return value
    }

    static func saveCompleted(_ value: [CompletedFirstWin]) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: completedKey)
    }
}

// MARK: - Domains & personalization

enum FirstWinDomain: String, Codable {
    case body, calm, mind, heart
}

extension FirstWinPreset {
    var domain: FirstWinDomain {
        switch self {
        case .hydrate, .move, .stretch, .daylight: return .body
        case .breathe, .phoneDown:                 return .calm
        case .intention, .oneThing, .readPage:     return .mind
        case .grateful:                            return .heart
        }
    }
}

enum MorningGoal: String, Codable, CaseIterable, Identifiable, Equatable {
    case energy, calm, focus, meaning

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .energy:  return "bolt.fill"
        case .calm:    return "leaf.fill"
        case .focus:   return "target"
        case .meaning: return "heart.fill"
        }
    }

    var title: String {
        switch self {
        case .energy:  return L10n.text(en: "Energy", tr: "Enerji", es: "Energía")
        case .calm:    return L10n.text(en: "Calm", tr: "Sükunet", es: "Calma")
        case .focus:   return L10n.text(en: "Focus", tr: "Odak", es: "Enfoque")
        case .meaning: return L10n.text(en: "Meaning", tr: "Anlam", es: "Sentido")
        }
    }

    var subtitle: String {
        switch self {
        case .energy:  return L10n.text(en: "Wake the body up.", tr: "Bedeni uyandır.", es: "Despierta el cuerpo.")
        case .calm:    return L10n.text(en: "Start unhurried.", tr: "Telaşsız başla.", es: "Empieza sin prisa.")
        case .focus:   return L10n.text(en: "Aim the day.", tr: "Güne yön ver.", es: "Apunta el día.")
        case .meaning: return L10n.text(en: "Start from enough.", tr: "Yeterlilikten başla.", es: "Empieza desde la suficiencia.")
        }
    }

    var domain: FirstWinDomain {
        switch self {
        case .energy:  return .body
        case .calm:    return .calm
        case .focus:   return .mind
        case .meaning: return .heart
        }
    }

    var recommended: FirstWinPreset {
        switch self {
        case .energy:  return .move
        case .calm:    return .breathe
        case .focus:   return .oneThing
        case .meaning: return .grateful
        }
    }

    var reason: String {
        switch self {
        case .energy:  return L10n.text(en: "Because you want more energy", tr: "Çünkü daha çok enerji istiyorsun", es: "Porque quieres más energía")
        case .calm:    return L10n.text(en: "Because you want more calm", tr: "Çünkü daha çok sükunet istiyorsun", es: "Porque quieres más calma")
        case .focus:   return L10n.text(en: "Because you want more focus", tr: "Çünkü daha çok odak istiyorsun", es: "Porque quieres más enfoque")
        case .meaning: return L10n.text(en: "Because you want more meaning", tr: "Çünkü daha çok anlam istiyorsun", es: "Porque quieres más sentido")
        }
    }
}

enum FirstWinRecommender {
    static func recommended(for goal: MorningGoal?) -> FirstWinPreset? {
        goal?.recommended
    }

    static func orderedPresets(for goal: MorningGoal?) -> [FirstWinPreset] {
        let all = FirstWinPreset.allCases
        guard let goal else { return all }
        let rec = goal.recommended
        let inDomain = all.filter { $0.domain == goal.domain && $0 != rec }
        let rest = all.filter { $0.domain != goal.domain && $0 != rec }
        return [rec] + inDomain + rest
    }

    static func nextRecommended(goal: MorningGoal?, completedTitles: Set<String>, excluding: String?) -> FirstWinPreset {
        let ordered = orderedPresets(for: goal)
        if let fresh = ordered.first(where: { !completedTitles.contains($0.title) && $0.title != excluding }) {
            return fresh
        }
        return ordered.first ?? .move
    }
}
