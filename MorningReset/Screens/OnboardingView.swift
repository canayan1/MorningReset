import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState

    private enum Step { case hook, orb, schools, practice, plan }

    @State private var step: Step = .hook
    @State private var page = 0
    @State private var qIndex = 0
    @State private var answers: [Int] = []
    @State private var progress: CGFloat = 0
    @State private var statusIndex = 0
    @State private var cardIndex = 0
    @State private var showPaywall = false
    @State private var chosenSchoolID: String? = nil
    @State private var showFirstPractice = false

    private let language = AppLanguage.current

    var body: some View {
        ZStack {
            switch step {
            case .hook:     hookView.transition(.opacity)
            case .orb:      orbIntro.transition(.opacity)
            case .schools:  schoolsStep.transition(.opacity)
            case .practice: practiceStep.transition(.opacity)
            case .plan:     planView.transition(.opacity)
            }
        }
        .fullScreenCover(isPresented: $showPaywall, onDismiss: {
            appState.completeOnboardingAndShowScheduleSetup()
        }) {
            PaywallView(context: .onboarding, isSheet: true)
        }
        .accessibilityIdentifier("onboarding.screen")
    }

    // MARK: - Recommendation

    private var chosenSchool: SchoolContent? {
        chosenSchoolID.flatMap(SchoolContentStore.school)
    }

    private var schoolName: String { chosenSchool?.name ?? "your school" }
    private var schoolColor: Color { SchoolPalette.color(chosenSchoolID ?? "") }
    private var schoolSymbol: String { SchoolPalette.symbol(chosenSchoolID ?? "") }

    private var recommendedPath: EnergyPath {
        switch chosenSchoolID {
        case "reiki":                         return .reiki
        case "qigong", "yoga":                return .qigong
        case "breathing", "sound", "coldheat": return .breathwork
        default:                              return .reiki
        }
    }

    private func applyRecommendation() {
        let path = recommendedPath
        appState.selectMorningPath(path)
        if let practice = path.practices.first {
            appState.selectActiveFirstWin(.practice(path: path, id: practice.id))
        }
    }

    // MARK: - Hook

    private struct Slide { let symbol: String; let title: String; let subtitle: String; let cta: String }

    private var slides: [Slide] {
        [
            Slide(
                symbol: "sun.and.horizon.fill",
                title: L10n.text(language: language,
                                 en: "One small practice\nresets your energy\nfor the whole day.",
                                 tr: "Küçük tek bir pratik\ntüm günün enerjisini\nsıfırlar.",
                                 es: "Una práctica pequeña\nreinicia tu energía\ntodo el día."),
                subtitle: L10n.text(language: language,
                                    en: "A short daily practice from ten living traditions — at whichever hour is yours.",
                                    tr: "On yaşayan gelenekten kısa bir günlük pratik — hangi saat senin ise.",
                                    es: "Una práctica diaria breve de diez tradiciones vivas — a la hora que sea tuya."),
                cta: L10n.text(language: language, en: "Get started", tr: "Başlayalım", es: "Empezar"))
        ]
    }

    private var hookView: some View {
        ZStack {
            AuraBackground(path: nil, intensity: 0.35)
            VStack(spacing: 0) {
                Spacer()

                Image(systemName: slides[page].symbol)
                    .font(.system(size: 72, weight: .ultraLight))
                    .foregroundStyle(DS.accent.opacity(0.65))
                    .padding(.bottom, DS.Space.xl)
                    .id("sym_\(page)").transition(.opacity).animation(.easeOut(duration: 0.2), value: page)

                VStack(spacing: DS.Space.md) {
                    Text(slides[page].title)
                        .font(.system(size: 34, weight: .light, design: .serif))
                        .foregroundStyle(DS.textPrimary)
                        .multilineTextAlignment(.center).lineSpacing(6)
                    Text(slides[page].subtitle)
                        .font(.callout).foregroundStyle(DS.textSecondary)
                        .multilineTextAlignment(.center).lineSpacing(4)
                }
                .id(page).transition(.opacity).animation(.easeOut(duration: 0.2), value: page)
                .padding(.horizontal, 36)

                Spacer()

                HStack(spacing: 8) {
                    ForEach(0..<slides.count, id: \.self) { i in
                        Circle()
                            .fill(i == page ? DS.accent : DS.border)
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.bottom, DS.Space.lg)

                Button(slides[page].cta) {
                    if page < slides.count - 1 {
                        withAnimation(.easeOut(duration: 0.2)) { page += 1 }
                    } else {
                        withAnimation(.easeOut(duration: 0.25)) { step = .orb }
                    }
                }
                .font(.system(.body, design: .serif)).tracking(0.5)
                .frame(maxWidth: .infinity).padding(.vertical, 22)
                .background(DS.accent).foregroundStyle(DS.background).clipShape(Capsule())
                .padding(.horizontal, DS.Space.lg)
                .accessibilityIdentifier("onboarding.primaryButton")

                Spacer().frame(height: DS.Space.xl)
            }
        }
    }

    // MARK: - Quiz

    private struct Question { let prompt: String; let options: [(label: String, symbol: String)] }

    private var questions: [Question] {
        [
            Question(prompt: L10n.text(language: language, en: "How does your energy usually feel?", tr: "Enerjin genelde nasıl?", es: "¿Cómo suele estar tu energía?"),
                     options: [
                        (L10n.text(language: language, en: "Foggy and slow", tr: "Sisli ve yavaş", es: "Nubladas y lentas"), "moon.zzz.fill"),
                        (L10n.text(language: language, en: "Rushed and scattered", tr: "Aceleci ve dağınık", es: "Apuradas y dispersas"), "wind"),
                        (L10n.text(language: language, en: "Pretty okay", tr: "Fena değil", es: "Más o menos bien"), "sun.horizon.fill"),
                        (L10n.text(language: language, en: "Awake and ready", tr: "Uyanık ve hazır", es: "Despierto y listo"), "bolt.fill")
                     ]),
            Question(prompt: L10n.text(language: language, en: "What do you reach for first?", tr: "İlk neye uzanıyorsun?", es: "¿Qué es lo primero que tocas?"),
                     options: [
                        (L10n.text(language: language, en: "My phone", tr: "Telefonum", es: "Mi teléfono"), "iphone"),
                        (L10n.text(language: language, en: "Snooze", tr: "Erteleme", es: "Posponer"), "alarm"),
                        (L10n.text(language: language, en: "Coffee", tr: "Kahve", es: "Café"), "cup.and.saucer.fill"),
                        (L10n.text(language: language, en: "Nothing yet", tr: "Henüz hiçbir şey", es: "Nada aún"), "sparkle")
                     ]),
            Question(prompt: L10n.text(language: language, en: "Have you practiced energy work before?", tr: "Daha önce enerji çalışması yaptın mı?", es: "¿Has practicado trabajo energético antes?"),
                     options: [
                        (L10n.text(language: language, en: "I'm new to this", tr: "Bu konuda yeniyim", es: "Soy nuevo en esto"), "leaf"),
                        (L10n.text(language: language, en: "Reiki", tr: "Reiki", es: "Reiki"), "hands.and.sparkles.fill"),
                        (L10n.text(language: language, en: "Breathwork", tr: "Nefes çalışması", es: "Respiración"), "wind"),
                        (L10n.text(language: language, en: "Qigong", tr: "Qigong", es: "Qigong"), "figure.mind.and.body")
                     ]),
            Question(prompt: L10n.text(language: language, en: "What do you want most from your practice?", tr: "Pratiğinden en çok ne istiyorsun?", es: "¿Qué quieres más de tu práctica?"),
                     options: [
                        (L10n.text(language: language, en: "Calm and grounding", tr: "Sakinlik ve denge", es: "Calma y arraigo"), "leaf.fill"),
                        (L10n.text(language: language, en: "Energy and vitality", tr: "Enerji ve canlılık", es: "Energía y vitalidad"), "flame.fill"),
                        (L10n.text(language: language, en: "Focus and clarity", tr: "Odak ve berraklık", es: "Enfoque y claridad"), "scope"),
                        (L10n.text(language: language, en: "A clear intention", tr: "Net bir niyet", es: "Una intención clara"), "target")
                     ])
        ]
    }

    // MARK: - The energy orb

    private var orbIntro: some View {
        ZStack {
            AuraBackground(path: nil, intensity: 0.4)
            VStack(spacing: 0) {
                Spacer()

                EnergyOrbView(total: 0, tint: DS.accent, size: 210)

                Spacer().frame(height: DS.Space.xl)

                Text(L10n.text(language: language,
                               en: "This is your\nenergy orb.",
                               tr: "Bu senin\nenerji topun.",
                               es: "Este es tu\norbe de energía."))
                    .font(.system(size: 32, weight: .light, design: .serif))
                    .foregroundStyle(DS.textPrimary)
                    .multilineTextAlignment(.center).lineSpacing(5)

                Spacer().frame(height: DS.Space.md)

                Text(L10n.text(language: language,
                               en: "Every practice you finish feeds it. Keep going and it grows brighter and bigger — one small practice a day is all it takes.",
                               tr: "Tamamladığın her pratik onu besler. Devam ettikçe daha parlak ve daha büyük olur — günde küçük tek bir pratik yeter.",
                               es: "Cada práctica que completas lo alimenta. Sigue y se vuelve más brillante y más grande — basta con una pequeña práctica al día."))
                    .font(.callout).foregroundStyle(DS.textSecondary)
                    .multilineTextAlignment(.center).lineSpacing(4)
                    .padding(.horizontal, 36)

                Spacer()

                Button(L10n.text(language: language, en: "Grow my orb", tr: "Topumu büyüt", es: "Hacer crecer mi orbe")) {
                    withAnimation(.easeOut(duration: 0.25)) { step = .schools }
                }
                .primaryCTA()
                .padding(.horizontal, DS.Space.lg)
                .accessibilityIdentifier("onboarding.orbContinue")

                Spacer().frame(height: DS.Space.xl)
            }
        }
    }

    // MARK: - First practice (before we ever ask for money)

    private var practiceStep: some View {
        let school = chosenSchool
        let routine = school?.freeRoutine ?? school?.routines.first
        return ZStack {
            AuraBackground(path: recommendedPath, intensity: 0.4)
            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle().fill(schoolColor.opacity(0.16)).frame(width: 96, height: 96)
                    Image(systemName: schoolSymbol).font(.system(size: 40)).foregroundStyle(schoolColor)
                }

                Spacer().frame(height: DS.Space.lg)

                Text(L10n.text(language: language,
                               en: "Let's do one now.",
                               tr: "Hadi şimdi bir tane yapalım.",
                               es: "Hagamos una ahora."))
                    .font(.system(size: 30, weight: .light, design: .serif))
                    .foregroundStyle(DS.textPrimary)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: DS.Space.sm)

                if let routine {
                    Text("\(routine.title) · \(routine.minutes) min")
                        .font(.callout).foregroundStyle(DS.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 36)
                }

                Spacer().frame(height: DS.Space.md)

                Text(L10n.text(language: language,
                               en: "Free, and yours to keep. Your orb starts here.",
                               tr: "Ücretsiz ve hep senin. Orbun burada başlıyor.",
                               es: "Gratis y tuya para siempre. Tu orbe empieza aquí."))
                    .font(.caption).foregroundStyle(DS.textDim)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 40)

                Spacer()

                Button(L10n.text(language: language, en: "Begin", tr: "Başla", es: "Comenzar")) {
                    showFirstPractice = true
                }
                .primaryCTA()
                .padding(.horizontal, DS.Space.lg)
                .accessibilityIdentifier("onboarding.beginPractice")

                Button(L10n.text(language: language, en: "Later", tr: "Sonra", es: "Más tarde")) {
                    withAnimation(.easeOut(duration: 0.3)) { step = .plan }
                }
                .font(.footnote).foregroundStyle(DS.textSecondary)
                .padding(.top, DS.Space.md)

                Spacer().frame(height: DS.Space.xl)
            }
        }
        .sheet(isPresented: $showFirstPractice, onDismiss: {
            withAnimation(.easeOut(duration: 0.3)) { step = .plan }
        }) {
            if let school, let routine {
                RoutinePlayerView(school: school, routine: routine)
            }
        }
    }

    // MARK: - Schools (choose what draws you)

    private var schoolsStep: some View {
        ZStack {
            AuraBackground(path: nil, intensity: 0.3)
            VStack(spacing: 0) {
                Spacer().frame(height: DS.Space.xl)

                VStack(spacing: DS.Space.xs) {
                    Text(L10n.text(language: language,
                                   en: "Ten energy schools.",
                                   tr: "On enerji okulu.",
                                   es: "Diez escuelas de energía."))
                        .font(.system(size: 30, weight: .light, design: .serif))
                        .foregroundStyle(DS.textPrimary)
                    Text(L10n.text(language: language,
                                   en: "Pick the one that draws you. You can explore the rest any time.",
                                   tr: "Seni çeken okulu seç. Diğerlerini istediğin zaman keşfedebilirsin.",
                                   es: "Elige la que te atraiga. Puedes explorar el resto cuando quieras."))
                        .font(.callout).foregroundStyle(DS.textSecondary)
                        .multilineTextAlignment(.center).lineSpacing(3)
                        .padding(.horizontal, DS.Space.xl)
                }

                Spacer().frame(height: DS.Space.lg)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: DS.Space.sm),
                                        GridItem(.flexible(), spacing: DS.Space.sm)],
                              spacing: DS.Space.sm) {
                        ForEach(SchoolContentStore.all) { s in
                            schoolTile(s)
                        }
                    }
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.bottom, DS.Space.lg)
                }

                Spacer().frame(height: DS.Space.sm)
            }
        }
    }

    private func schoolTile(_ s: SchoolContent) -> some View {
        let color = SchoolPalette.color(s.id)
        return Button {
            chosenSchoolID = s.id
            appState.setActiveSchool(s.id)
            applyRecommendation()
            withAnimation(.easeOut(duration: 0.3)) { step = .practice }
        } label: {
            VStack(spacing: DS.Space.xs) {
                ZStack {
                    Circle().fill(color.opacity(0.16)).frame(width: 44, height: 44)
                    Image(systemName: SchoolPalette.symbol(s.id))
                        .font(.system(size: 19)).foregroundStyle(color)
                }
                Text(s.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DS.textPrimary)
                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                Text("\(s.routines.count) routines")
                    .font(.system(size: 9)).foregroundStyle(DS.textDim)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Space.md)
            .background(DS.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(DS.border, lineWidth: DS.hairline))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("onboarding.school.\(s.id)")
    }

    // MARK: - Plan ready (value props)

    private struct ValueProp { let symbol: String; let text: String }

    private var valueProps: [ValueProp] {
        [
            ValueProp(symbol: "face.smiling", text: L10n.text(language: language, en: "Read your energy aura", tr: "Enerji auranı oku", es: "Lee tu aura de energía")),
            ValueProp(symbol: "book", text: L10n.text(language: language, en: "Teachings behind each practice", tr: "Her pratiğin ardındaki öğretiler", es: "Las enseñanzas tras cada práctica")),
            ValueProp(symbol: schoolSymbol, text: L10n.text(language: language, en: "\(chosenSchool?.routines.count ?? 25) \(schoolName) routines", tr: "\(chosenSchool?.routines.count ?? 25) \(schoolName) rutini", es: "\(chosenSchool?.routines.count ?? 25) rutinas de \(schoolName)")),
            ValueProp(symbol: "flame.fill", text: L10n.text(language: language, en: "Streaks and a widget", tr: "Seriler ve bir widget", es: "Rachas y un widget"))
        ]
    }

    private var planView: some View {
        ZStack {
            AuraBackground(path: recommendedPath, intensity: 0.45)
            VStack(spacing: 0) {
                Spacer().frame(height: DS.Space.xl)

                Text(L10n.text(language: language, en: "YOUR PRACTICE IS READY", tr: "PRATİĞİN HAZIR", es: "TU PRÁCTICA ESTÁ LISTA"))
                    .font(.system(size: 11, weight: .semibold)).kerning(1.6)
                    .foregroundStyle(DS.textDim)

                Spacer().frame(height: DS.Space.md)

                EnergyOrbView(total: EnergyOrb.totalSessions, tint: schoolColor, size: 132)

                Spacer().frame(height: DS.Space.md)

                Text(L10n.text(language: language,
                               en: EnergyOrb.totalSessions > 0
                                   ? "Your orb has\nits first light."
                                   : "You're starting with\n\(schoolName).",
                               tr: EnergyOrb.totalSessions > 0
                                   ? "Orbun ilk\nışığını aldı."
                                   : "\(schoolName) ile\nbaşlıyorsun.",
                               es: EnergyOrb.totalSessions > 0
                                   ? "Tu orbe tiene\nsu primera luz."
                                   : "Empiezas con\n\(schoolName)."))
                    .font(.system(size: 30, weight: .light, design: .serif))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(DS.textPrimary)
                    .lineSpacing(4)
                    .padding(.horizontal, DS.Space.lg)

                Spacer().frame(height: DS.Space.xs)

                Text(chosenSchool?.tagline ?? "")
                    .font(.callout).italic()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(DS.textSecondary)
                    .padding(.horizontal, 36)

                Spacer().frame(height: DS.Space.xl)

                VStack(alignment: .center, spacing: DS.Space.md) {
                    ForEach(valueProps.indices, id: \.self) { i in
                        HStack(spacing: DS.Space.sm) {
                            Image(systemName: valueProps[i].symbol)
                                .font(.system(size: 18))
                                .foregroundStyle(DS.accent)
                                .frame(width: 26)
                            Text(valueProps[i].text)
                                .font(.callout)
                                .foregroundStyle(DS.textPrimary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, DS.Space.lg)

                Spacer()

                Button(L10n.text(language: language, en: "Continue", tr: "Devam et", es: "Continuar")) {
                    showPaywall = true
                }
                .primaryCTA()
                .padding(.horizontal, DS.Space.lg)
                .accessibilityIdentifier("onboarding.planContinueButton")

                Text(L10n.text(language: language,
                               en: "Core ritual free. Cancel anytime.",
                               tr: "Çekirdek ritüel ücretsiz. İstediğin zaman iptal et.",
                               es: "Ritual principal gratis. Cancela cuando quieras."))
                    .font(.caption2)
                    .foregroundStyle(DS.textDim)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.top, DS.Space.sm)

                Spacer().frame(height: DS.Space.lg)
            }
        }
    }
}
