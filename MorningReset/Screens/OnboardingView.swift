import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState

    /// The order is the pitch.
    ///
    /// The app's showcase is its alarm, and the old first run never mentioned
    /// it — somebody could finish onboarding without learning the one thing
    /// the product is for, and without an alarm set, which is the same as not
    /// having installed it. So the alarm opens the flow and is set before the
    /// paywall rather than after it.
    private enum Step { case alarm, morning, traditions, mornings, practice, setAlarm, plan }

    @State private var step: Step = .alarm
    @State private var page = 0
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
            case .alarm:      alarmStep.transition(.opacity)
            case .morning:    morningStep.transition(.opacity)
            case .traditions: schoolsStep.transition(.opacity)
            case .mornings:   morningsStep.transition(.opacity)
            case .practice:   practiceStep.transition(.opacity)
            case .setAlarm:   setAlarmStep.transition(.opacity)
            case .plan:       planView.transition(.opacity)
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

    private func stepChrome<Content: View>(
        label: String, title: String, body: String, cta: String,
        page: Int, next: Step, @ViewBuilder art: () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            Spacer().frame(height: DS.Space.xl)

            Text(label)
                .font(DS.Typo.label).kerning(1.6)
                .foregroundStyle(DS.accent)

            Spacer().frame(height: DS.Space.sm)

            Text(title)
                .font(.system(size: 30, weight: .regular, design: .serif))
                .foregroundStyle(DS.textPrimary)
                .multilineTextAlignment(.center).lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, DS.Space.lg)

            Spacer().frame(height: DS.Space.sm)

            Text(body)
                .font(.callout).foregroundStyle(DS.textSecondary)
                .multilineTextAlignment(.center).lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 36)

            Spacer()

            art()

            Spacer()

            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(i == page ? DS.accent : DS.border)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.bottom, DS.Space.lg)

            Button(cta) { withAnimation(.easeOut(duration: 0.3)) { step = next } }
                .primaryCTA()
                .padding(.horizontal, DS.Space.lg)
                .accessibilityIdentifier("onboarding.primaryButton")

            Spacer().frame(height: DS.Space.xl)
        }
    }

    // MARK: - 1 · The alarm (the showcase, said first)

    private var alarmStep: some View {
        ZStack {
            AuraBackground(path: nil, intensity: 0.3)
            stepChrome(
                label: L10n.text(language: language, en: "TOMORROW MORNING", tr: "YARIN SABAH", es: "MAÑANA POR LA MAÑANA"),
                title: L10n.text(language: language,
                                 en: "You wake into it,\nnot out of it.",
                                 tr: "Ondan değil,\nonun içine uyanırsın.",
                                 es: "Despiertas dentro,\nno fuera."),
                body: L10n.text(language: language,
                                en: "At the hour you choose, a melody you have not heard before. It rings through Silent mode and Sleep Focus.",
                                tr: "Seçtiğin saatte, daha önce duymadığın bir ezgi. Sessiz modda ve Uyku Odağı'nda da çalar.",
                                es: "A la hora que elijas, una melodía que no has oído antes. Suena en modo Silencio y Concentración de sueño."),
                cta: L10n.text(language: language, en: "Continue", tr: "Devam", es: "Continuar"),
                page: 0, next: .morning
            ) { lockScreenArt }
        }
    }

    /// The app's own lock-screen card, with the melody drawn as rings around it.
    private var lockScreenArt: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .strokeBorder(DS.accentSoft.opacity(0.30 - Double(i) * 0.08), lineWidth: 1)
                    .frame(width: 210 + CGFloat(i) * 78, height: 210 + CGFloat(i) * 78)
            }

            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("INNER LIGHT")
                        .font(.system(size: 9, weight: .semibold)).tracking(1.4)
                        .foregroundStyle(DS.textDim)
                    Text(L10n.text(language: language,
                                   en: "Your morning is ready.",
                                   tr: "Sabahın hazır.",
                                   es: "Tu mañana está lista."))
                        .font(.system(size: 13, design: .serif))
                        .foregroundStyle(DS.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                Text("06:40")
                    .font(.system(size: 22, weight: .thin, design: .serif))
                    .foregroundStyle(DS.textPrimary)
                    .monospacedDigit()
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(DS.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(DS.border, lineWidth: DS.hairline))
            .padding(.horizontal, DS.Space.xl)
        }
        .frame(height: 330)
    }

    // MARK: - 2 · The first minute

    private var morningStep: some View {
        ZStack {
            AuraBackground(path: nil, intensity: 0.3)
            stepChrome(
                label: L10n.text(language: language, en: "THE FIRST MINUTE", tr: "İLK DAKİKA", es: "EL PRIMER MINUTO"),
                title: L10n.text(language: language,
                                 en: "It asks for\none smile.",
                                 tr: "Senden tek bir\ngülümseme ister.",
                                 es: "Te pide\nuna sonrisa."),
                body: L10n.text(language: language,
                                en: "The bell draws away when you smile, and the morning is done. Your breath and your pulse are there afterwards, whenever you want them.",
                                tr: "Gülümsediğinde çan çekilir ve sabah tamamlanır. Nefesin ve nabzın, istediğin an, sonrasında burada.",
                                es: "La campana se retira cuando sonríes y la mañana está hecha. Tu respiración y tu pulso están después, cuando los quieras."),
                cta: L10n.text(language: language, en: "Continue", tr: "Devam", es: "Continuar"),
                page: 1, next: .traditions
            ) {
                VStack(spacing: DS.Space.lg) {
                    ForEach(Array(firstMinute.enumerated()), id: \.offset) { i, row in
                        HStack(spacing: DS.Space.md) {
                            ZStack {
                                Circle()
                                    .fill(i == 0 ? DS.accentSoft.opacity(0.26) : DS.surface)
                                    .frame(width: 46, height: 46)
                                Image(systemName: row.symbol)
                                    .font(.system(size: 17, weight: .light))
                                    .foregroundStyle(i == 0 ? DS.accentInk : DS.textSecondary)
                            }
                            Text(row.label)
                                .font(.callout)
                                .foregroundStyle(i == 0 ? DS.textPrimary : DS.textSecondary)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, DS.Space.xl + DS.Space.md)
            }
        }
    }

    private var firstMinute: [(symbol: String, label: String)] {
        [(symbol: "face.smiling",
          label: L10n.text(language: language, en: "A smile", tr: "Bir gülümseme", es: "Una sonrisa")),
         (symbol: "waveform.path.ecg",
          label: L10n.text(language: language, en: "Your pulse", tr: "Nabzın", es: "Tu pulso")),
         (symbol: "wind",
          label: L10n.text(language: language, en: "Your breath", tr: "Nefesin", es: "Tu respiración"))]
    }

    // MARK: - 4 · Your own mornings (and the orb that counts them)

    private var morningsStep: some View {
        ZStack {
            AuraBackground(path: nil, intensity: 0.4)
            stepChrome(
                label: L10n.text(language: language, en: "ONE A DAY", tr: "GÜNDE BİR", es: "UNA AL DÍA"),
                title: L10n.text(language: language,
                                 en: "You begin to recognise\nyour own mornings.",
                                 tr: "Kendi sabahlarını\ntanımaya başlarsın.",
                                 es: "Empiezas a reconocer\ntus propias mañanas."),
                body: L10n.text(language: language,
                                en: "Every morning is one line: your waking pulse, and that you were there. Each practice you finish feeds your orb.",
                                tr: "Her sabah tek bir satır: uyanma nabzın ve orada olduğun. Tamamladığın her pratik topunu besler.",
                                es: "Cada mañana es una línea: tu pulso al despertar, y que estuviste. Cada práctica que terminas alimenta tu orbe."),
                cta: L10n.text(language: language, en: "Continue", tr: "Devam", es: "Continuar"),
                page: 2, next: .practice
            ) {
                VStack(spacing: DS.Space.lg) {
                    EnergyOrbView(total: 0, tint: DS.accent, size: 128)
                    monthSketch
                }
            }
        }
    }

    /// A month at a glance — the shape the calendar makes, not a screenshot.
    ///
    /// Every square is drawn, the empty ones as a hairline outline, so it
    /// reads as a month with gaps in it. Drawing only the filled days left
    /// squares floating in space and the calendar was not legible as one.
    private var monthSketch: some View {
        let filled: Set<Int> = [0, 1, 2, 4, 5, 6, 7, 8, 10, 11, 12, 13,
                                15, 16, 17, 18, 19, 21, 22, 23, 24, 25]
        return VStack(spacing: 5) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 5) {
                    ForEach(0..<7, id: \.self) { col in
                        let i = row * 7 + col
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(filled.contains(i)
                                  ? DS.accent.opacity(0.14 + Double((i * 3) % 4) * 0.07)
                                  : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .strokeBorder(DS.border, lineWidth: DS.hairline)
                            )
                            .frame(width: 24, height: 24)
                    }
                }
            }
        }
    }

    // MARK: - 5 · Set the hour (before the paywall, never after)

    private var setAlarmStep: some View {
        ScheduleSetupView(isOnboarding: true) {
            withAnimation(.easeOut(duration: 0.3)) { step = .plan }
        }
    }

    // MARK: - Quiz

    // MARK: - First practice (before we ever ask for money)

    private var practiceStep: some View {
        // The first practice is the free one *in the tradition that drew them
        // in* — every school has one now — so the thing they chose is the thing
        // they get to try. The alarm's own practice is only the fallback.
        let school = chosenSchool.flatMap { $0.freeRoutine == nil ? nil : $0 }
            ?? SchoolContentStore.freePractice?.school
        let routine = school?.freeRoutine ?? SchoolContentStore.freePractice?.routine
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
                    withAnimation(.easeOut(duration: 0.3)) { step = .setAlarm }
                }
                .font(.footnote).foregroundStyle(DS.textSecondary)
                .padding(.top, DS.Space.md)

                Spacer().frame(height: DS.Space.xl)
            }
        }
        .sheet(isPresented: $showFirstPractice, onDismiss: {
            withAnimation(.easeOut(duration: 0.3)) { step = .setAlarm }
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
                                   en: "Ten traditions,\nmet from the inside.",
                                   tr: "On gelenek,\niçeriden karşılanır.",
                                   es: "Diez tradiciones,\nvistas desde dentro."))
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
            withAnimation(.easeOut(duration: 0.3)) { step = .mornings }
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
            ValueProp(symbol: "book", text: L10n.text(language: language, en: "What lives inside each one", tr: "Her birinin içinde yaşayan", es: "Lo que vive dentro de cada una")),
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
