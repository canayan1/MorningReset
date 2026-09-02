import SwiftUI

struct AlarmView: View {
    @Environment(AppState.self) private var appState
    @State private var showAbout  = false
    @State private var schedule   = WakeScheduleStore.load()
    @State private var entries: [DailyEntry] = []
    @State private var numberScale: CGFloat = 0.85
    @State private var primaryTapped = 0
    @AppStorage("mrHomeNudgeSeen") private var homeNudgeSeen = false
    @State private var playSession = false
    @State private var orbTotal = 0

    private let language = AppLanguage.current
    private var streak: Int { appState.streakCount }
    private var notificationIsSet: Bool { schedule.isEnabled }

    var body: some View {
        ZStack {
            AuraBackground(path: appState.activePath, intensity: 0.4)

            VStack(spacing: 0) {

                // ── Nav bar ───────────────────────────────────────────
                HStack {
                    Spacer()
                    Menu {
                        Button {
                            appState.showNightSound()
                        } label: {
                            Label(L10n.text(language: language, en: "Wind down for sleep", tr: "Uyku için yavaşla", es: "Desacelera para dormir"), systemImage: "moon.stars")
                        }
                        Button {
                            appState.showScheduleSetup()
                        } label: {
                            Label(L10n.text(language: language, en: "Notification time", tr: "Bildirim zamanı", es: "Hora de notificación"), systemImage: "bell")
                        }
                        Button {
                            showAbout = true
                        } label: {
                            Label(L10n.text(language: language, en: "About", tr: "Hakkında", es: "Acerca de"), systemImage: "info.circle")
                        }
                        if appState.activePath != nil {
                            Button {
                                appState.showPathLearn()
                            } label: {
                                Label(L10n.text(language: language, en: "Learn your path", tr: "Yolunu öğren", es: "Conoce tu camino"), systemImage: "book")
                            }
                        }
                        Divider()
                        if appState.isPremium {
                            Link(destination: AppState.manageSubscriptionsURL) {
                                Label(L10n.text(language: language, en: "Manage subscription", tr: "Aboneliği yönet", es: "Gestionar suscripción"), systemImage: "creditcard")
                            }
                        } else {
                            Button {
                                appState.paywallContext = .contextual
                                appState.screen = .paywall
                            } label: {
                                Label(L10n.text(language: language, en: "Upgrade to Premium", tr: "Premium'a yükselt", es: "Mejorar a Premium"), systemImage: "sparkles")
                            }
                        }
                        Divider()
                        Link(destination: AppState.privacyPolicyURL) {
                            Label(L10n.text(language: language, en: "Privacy Policy", tr: "Gizlilik Politikası", es: "Política de privacidad"), systemImage: "hand.raised")
                        }
                        Link(destination: AppState.supportURL) {
                            Label(L10n.text(language: language, en: "Support", tr: "Destek", es: "Soporte"), systemImage: "questionmark.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(DS.textDim)
                            .frame(width: 32, height: 32)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel(L10n.text(language: language, en: "More options", tr: "Daha fazla seçenek", es: "Más opciones"))
                    .accessibilityIdentifier("alarm.aboutButton")
                }
                .padding(.top, 20)
                .padding(.horizontal, DS.Space.lg)

                Spacer()

                // ── Hero: the orb is the button ──────────────────────
                Button {
                    primaryTapped &+= 1
                    homeNudgeSeen = true
                    playSession = true
                } label: {
                    orbHero
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.impact(weight: .light), trigger: primaryTapped)
                .accessibilityElement(children: .ignore)
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel(primaryLabel)
                .accessibilityIdentifier("alarm.primaryButton")

                Spacer()

                // ── Today's practice (the one thing to do) ───────────
                todaysSessionCard
                    .padding(.horizontal, DS.Space.lg)

                Spacer().frame(height: DS.Space.sm)

                // ── Optional check-in ────────────────────────────────
                energyReadEntry
                    .padding(.horizontal, DS.Space.lg)

                Spacer()

                // ── CTAs ─────────────────────────────────────────────
                VStack(spacing: DS.Space.sm) {
                    Button(secondaryLabel) {
                        appState.showScheduleSetup()
                    }
                    .font(.subheadline)
                    .foregroundStyle(DS.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .accessibilityIdentifier("alarm.secondaryButton")
                }
                .padding(.horizontal, DS.Space.lg)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            schedule = WakeScheduleStore.load()
            entries  = DailyEntryStore.load()
            orbTotal = EnergyOrb.totalSessions
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) {
                numberScale = 1.0
            }
        }
        .sensoryFeedback(.success, trigger: isMilestone)
        .sheet(isPresented: $showAbout) { AboutView() }
        .sheet(isPresented: $playSession, onDismiss: { orbTotal = EnergyOrb.totalSessions }) {
            RoutinePlayerView(school: appState.activeSchool, routine: appState.todaysRoutine)
        }
    }

    // MARK: - Today's session

    private var todaysSessionCard: some View {
        let school = appState.activeSchool
        let session = appState.todaysRoutine
        let color = SchoolPalette.color(school.id)
        return Button { playSession = true } label: {
            HStack(spacing: DS.Space.md) {
                ZStack {
                    Circle().fill(color.opacity(0.16)).frame(width: 44, height: 44)
                    Image(systemName: SchoolPalette.symbol(school.id)).font(.system(size: 20)).foregroundStyle(color)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(L10n.text(language: language, en: "TODAY'S PRACTICE", tr: "BUGÜNÜN PRATİĞİ", es: "PRÁCTICA DE HOY"))
                        .font(.system(size: 9, weight: .semibold)).kerning(1.1)
                        .foregroundStyle(DS.textDim)
                    Text(session.title)
                        .font(.body.weight(.semibold)).foregroundStyle(DS.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(school.name) · \(session.minutes) min")
                        .font(.caption).foregroundStyle(DS.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "play.circle.fill").font(.system(size: 26)).foregroundStyle(color)
            }
            .dreamCard(radius: DS.Radius.lg, padding: DS.Space.md, tint: color)
        }
        .accessibilityIdentifier("alarm.todaysSession")
    }

    // MARK: - Hero states

    private var orbHero: some View {
        VStack(spacing: DS.Space.sm) {
            EnergyOrbView(total: orbTotal,
                          tint: SchoolPalette.color(appState.activeSchoolID),
                          size: 196)
            Text(EnergyOrb.title(EnergyOrb.level(orbTotal)).uppercased())
                .font(.system(size: 10, weight: .semibold)).tracking(1.8)
                .foregroundStyle(SchoolPalette.color(appState.activeSchoolID))
            Text(streak > 0
                 ? L10n.text(language: language,
                             en: "\(streak) day\(streak == 1 ? "" : "s") in a row · \(orbTotal) practices",
                             tr: "\(streak) gün üst üste · \(orbTotal) pratik",
                             es: "\(streak) día\(streak == 1 ? "" : "s") seguidos · \(orbTotal) prácticas")
                 : L10n.text(language: language,
                             en: "Practise today and your orb grows.",
                             tr: "Bugün pratik yap, orbun büyüsün.",
                             es: "Practica hoy y tu orbe crece."))
                .font(.caption).foregroundStyle(DS.textSecondary)
                .multilineTextAlignment(.center)

            // The orb is the control, so it has to say so.
            Text(L10n.text(language: language, en: "Tap to begin",
                           tr: "Başlamak için dokun", es: "Toca para empezar"))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(DS.background)
                .padding(.horizontal, DS.Space.lg)
                .padding(.vertical, 12)
                .background(Capsule().fill(SchoolPalette.color(appState.activeSchoolID)))
                .padding(.top, DS.Space.xs)
        }
        .frame(maxWidth: .infinity)
    }

    private var streakHero: some View {
        VStack(spacing: DS.Space.xs) {
            if isMilestone {
                Text(milestoneBadge)
                    .font(.system(size: 10, weight: .semibold, design: .serif))
                    .tracking(1.4)
                    .foregroundStyle(DS.background)
                    .padding(.horizontal, DS.Space.md)
                    .padding(.vertical, 6)
                    .background(DS.accent)
                    .clipShape(Capsule())
                    .padding(.bottom, DS.Space.xs)
                    .transition(.scale.combined(with: .opacity))
            }

            // Big number
            Text("\(streak)")
                .font(.system(size: 88, weight: .thin, design: .serif))
                .foregroundStyle(isMilestone ? DS.accent : DS.textPrimary)
                .monospacedDigit()
                .scaleEffect(numberScale)

            Text(L10n.text(language: language,
                           en: streak == 1 ? "day" : "days in a row",
                           tr: streak == 1 ? "gün" : "gün üst üste",
                           es: streak == 1 ? "día" : "días seguidos"))
                .font(.system(.callout, design: .serif))
                .foregroundStyle(DS.textSecondary)

            if streak >= 3 {
                Text(streakMotivation)
                    .font(.caption)
                    .italic()
                    .foregroundStyle(DS.textDim)
                    .padding(.top, DS.Space.xs)
            }
        }
    }

    private var isMilestone: Bool {
        streak == 7 || streak == 14 || streak == 30 || streak == 100
    }

    private var milestoneBadge: String {
        switch streak {
        case 7:   return L10n.text(language: language, en: "ONE WEEK",   tr: "BİR HAFTA",  es: "UNA SEMANA")
        case 14:  return L10n.text(language: language, en: "TWO WEEKS",  tr: "İKİ HAFTA",  es: "DOS SEMANAS")
        case 30:  return L10n.text(language: language, en: "ONE MONTH",  tr: "BİR AY",     es: "UN MES")
        case 100: return L10n.text(language: language, en: "100 DAYS",   tr: "100 GÜN",    es: "100 DÍAS")
        default:  return ""
        }
    }

    private var emptyStateHero: some View {
        VStack(spacing: DS.Space.lg) {
            Image(systemName: appState.activePath?.symbol ?? "sun.and.horizon.fill")
                .font(.system(size: 64, weight: .ultraLight))
                .foregroundStyle(DS.accent.opacity(0.75))

            VStack(spacing: DS.Space.sm) {
                Text(greeting)
                    .font(.system(size: 36, weight: .light, design: .serif))
                    .foregroundStyle(DS.textPrimary)

                Text(L10n.text(language: language,
                               en: "One small practice.\nReset your energy — any time of day.",
                               tr: "Küçük tek bir pratik.\nEnerjini resetle — günün her saati.",
                               es: "Una práctica pequeña.\nReinicia tu energía — a cualquier hora."))
                    .font(.callout)
                    .foregroundStyle(DS.textSecondary)
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, DS.Space.lg)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Morning energy read entry

    private var energyReadEntry: some View {
        Button { appState.showEnergyRead() } label: {
            HStack(spacing: DS.Space.md) {
                ZStack {
                    Circle().fill(DS.calm.opacity(0.14)).frame(width: 44, height: 44)
                    Image(systemName: "face.smiling")
                        .font(.system(size: 21, weight: .medium))
                        .foregroundStyle(DS.calm)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(L10n.text(language: language, en: "ENERGY CHECK-IN", tr: "ENERJİ CHECK-IN", es: "CHEQUEO DE ENERGÍA"))
                        .font(.system(size: 9, weight: .semibold))
                        .kerning(1.2)
                        .foregroundStyle(DS.textDim)
                    Text(L10n.text(language: language, en: "Smile & read your energy", tr: "Gülümse, enerjini oku", es: "Sonríe y lee tu energía"))
                        .font(.body.weight(.semibold))
                        .foregroundStyle(DS.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(L10n.text(language: language, en: "Optional — a selfie reads your energy", tr: "İsteğe bağlı — selfie enerjini okur", es: "Opcional — un selfie lee tu energía"))
                        .font(.caption)
                        .foregroundStyle(DS.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DS.textDim)
            }
            .dreamCard(radius: DS.Radius.lg, padding: DS.Space.md, tint: DS.calm)
        }
        .accessibilityIdentifier("alarm.energyReadEntry")
    }

    // MARK: - First Win entry

    @ViewBuilder
    private var firstWinEntry: some View {
        if let active = appState.activeFirstWin {
            Button { appState.showMyWins() } label: {
                HStack(spacing: DS.Space.md) {
                    Image(systemName: active.kind.symbol)
                        .font(.system(size: 26))
                        .foregroundStyle(DS.accent)
                        .frame(width: 36)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.text(language: language, en: "TODAY'S PRACTICE", tr: "BUGÜNÜN PRATİĞİ", es: "PRÁCTICA DE HOY"))
                            .font(.system(size: 9, weight: .semibold))
                            .kerning(1.2)
                            .foregroundStyle(DS.textDim)
                        Text(active.kind.title)
                            .font(.body.weight(.medium))
                            .foregroundStyle(DS.textPrimary)
                    }
                    Spacer()
                    HStack(spacing: 5) {
                        ForEach(0..<FirstWinStore.target, id: \.self) { i in
                            Circle()
                                .fill(i < active.displayStreak() ? DS.accent : Color.clear)
                                .frame(width: 8, height: 8)
                                .overlay(Circle().stroke(i < active.displayStreak() ? DS.accent : DS.border, lineWidth: 1))
                        }
                    }
                }
                .padding(DS.Space.lg)
                .background(DS.surface)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(DS.border, lineWidth: DS.hairline))
            }
            .accessibilityIdentifier("alarm.firstWinEntry")
        } else {
            Button { appState.showFirstWinPick() } label: {
                HStack(spacing: DS.Space.md) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 26))
                        .foregroundStyle(DS.accent)
                        .frame(width: 36)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.text(language: language, en: "FIRST WIN", tr: "FIRST WIN", es: "FIRST WIN"))
                            .font(.system(size: 9, weight: .semibold))
                            .kerning(1.2)
                            .foregroundStyle(DS.textDim)
                        Text(L10n.text(language: language, en: "Choose a practice", tr: "Bir pratik seç", es: "Elige una práctica"))
                            .font(.body.weight(.medium))
                            .foregroundStyle(DS.textPrimary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DS.textDim)
                }
                .padding(DS.Space.lg)
                .background(DS.surface)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(DS.border, lineWidth: DS.hairline))
            }
            .accessibilityIdentifier("alarm.firstWinPickEntry")
        }
    }

    // MARK: - Computed strings

    private var streakMotivation: String {
        switch streak {
        case 3...6:
            return L10n.text(language: language,
                             en: "Don't break it.",
                             tr: "Bozma.",
                             es: "No lo rompas.")
        case 7...13:
            return L10n.text(language: language,
                             en: "One week in. Keep going.",
                             tr: "Bir hafta oldu. Devam et.",
                             es: "Una semana dentro. Sigue.")
        case 14...29:
            return L10n.text(language: language,
                             en: "Two weeks. This is a practice now.",
                             tr: "İki hafta. Bu artık bir pratik.",
                             es: "Dos semanas. Esto es una práctica.")
        case 30...:
            return L10n.text(language: language,
                             en: "A month of practice.",
                             tr: "Bir aylık pratik.",
                             es: "Un mes de práctica.")
        default:
            return L10n.text(language: language,
                             en: "Don't break it.",
                             tr: "Bozma.",
                             es: "No lo rompas.")
        }
    }

    private var greeting: String {
        TimeOfDay.current.greeting + "."
    }

    private var primaryLabel: String {
        L10n.text(language: language, en: "Start today's practice", tr: "Bugünün pratiğini başlat", es: "Iniciar la práctica de hoy")
    }

    private var secondaryLabel: String {
        notificationIsSet
        ? L10n.text(language: language, en: "Edit reminder", tr: "Hatırlatıcıyı düzenle", es: "Editar recordatorio")
        : L10n.text(language: language, en: "Set a daily reminder", tr: "Günlük hatırlatıcı kur", es: "Configurar recordatorio")
    }
}
