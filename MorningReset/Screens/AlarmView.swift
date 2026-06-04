import SwiftUI

struct AlarmView: View {
    @Environment(AppState.self) private var appState
    @State private var showAbout  = false
    @State private var schedule   = WakeScheduleStore.load()
    @State private var entries: [DailyEntry] = []
    @State private var numberScale: CGFloat = 0.85
    @State private var primaryTapped = 0

    private let language = AppLanguage.current
    private var streak: Int { appState.streakCount }
    private var notificationIsSet: Bool { schedule.isEnabled }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Nav bar ───────────────────────────────────────────
                HStack {
                    Spacer()
                    Menu {
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

                // ── Hero ─────────────────────────────────────────────
                if streak > 0 {
                    streakHero
                } else {
                    emptyStateHero
                }

                Spacer().frame(height: DS.Space.xl)

                // ── 7-day strip ───────────────────────────────────────
                VStack(spacing: 8) {
                    StreakStripLegend(days: 7)
                    StreakStripView(entries: entries, days: 7)
                }

                Spacer().frame(height: DS.Space.lg)

                // ── First Win entry ───────────────────────────────────
                firstWinEntry
                    .padding(.horizontal, DS.Space.lg)

                Spacer()

                // ── CTAs ─────────────────────────────────────────────
                VStack(spacing: DS.Space.sm) {
                    Button(primaryLabel) {
                        primaryTapped &+= 1
                        if notificationIsSet { appState.startFlow() }
                        else { appState.showScheduleSetup() }
                    }
                    .font(.system(.body, design: .serif))
                    .tracking(0.5)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(DS.accent)
                    .foregroundStyle(DS.background)
                    .clipShape(Capsule())
                    .sensoryFeedback(.impact(weight: .medium), trigger: primaryTapped)
                    .accessibilityIdentifier("alarm.primaryButton")

                    Button(secondaryLabel) {
                        if notificationIsSet { appState.showScheduleSetup() }
                        else { appState.startFlow() }
                    }
                    .font(.subheadline)
                    .foregroundStyle(DS.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(DS.surface)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(DS.border, lineWidth: DS.hairline))
                    .accessibilityIdentifier("alarm.secondaryButton")
                }
                .padding(.horizontal, DS.Space.lg)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            schedule = WakeScheduleStore.load()
            entries  = DailyEntryStore.load()
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) {
                numberScale = 1.0
            }
        }
        .sensoryFeedback(.success, trigger: isMilestone)
        .sheet(isPresented: $showAbout) { AboutView() }
    }

    // MARK: - Hero states

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
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text(greeting)
                .font(.system(size: 36, weight: .regular, design: .serif))
                .foregroundStyle(DS.textPrimary)

            Text(L10n.text(language: language,
                           en: "One small practice.\nTo raise your morning energy.",
                           tr: "Küçük tek bir pratik.\nSabah enerjini yükseltmek için.",
                           es: "Una práctica pequeña.\nPara elevar tu energía matinal."))
                .font(.callout)
                .foregroundStyle(DS.textSecondary)
                .lineSpacing(4)
        }
        .padding(.horizontal, DS.Space.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - First Win entry

    @ViewBuilder
    private var firstWinEntry: some View {
        if let active = appState.activeFirstWin {
            Button { appState.showMyWins() } label: {
                HStack(spacing: DS.Space.md) {
                    Image(systemName: active.kind.symbol)
                        .font(.system(size: 18))
                        .foregroundStyle(DS.accent)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.text(language: language, en: "TODAY'S PRACTICE", tr: "BUGÜNÜN PRATİĞİ", es: "PRÁCTICA DE HOY"))
                            .font(.system(size: 9, weight: .semibold))
                            .kerning(1.2)
                            .foregroundStyle(DS.textDim)
                        Text(active.kind.title)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(DS.textPrimary)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        ForEach(0..<FirstWinStore.target, id: \.self) { i in
                            Circle()
                                .fill(i < active.displayStreak() ? DS.accent : Color.clear)
                                .frame(width: 7, height: 7)
                                .overlay(Circle().stroke(i < active.displayStreak() ? DS.accent : DS.border, lineWidth: 1))
                        }
                    }
                }
                .padding(DS.Space.md)
                .background(DS.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(DS.border, lineWidth: DS.hairline))
            }
            .accessibilityIdentifier("alarm.firstWinEntry")
        } else {
            Button { appState.showFirstWinPick() } label: {
                HStack(spacing: DS.Space.md) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18))
                        .foregroundStyle(DS.accent)
                        .frame(width: 28)
                    Text(L10n.text(language: language, en: "Choose a practice", tr: "Bir pratik seç", es: "Elige una práctica"))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(DS.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DS.textDim)
                }
                .padding(DS.Space.md)
                .background(DS.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(DS.border, lineWidth: DS.hairline))
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
                             en: "A month of mornings.",
                             tr: "Bir aylık sabahlar.",
                             es: "Un mes de mañanas.")
        default:
            return L10n.text(language: language,
                             en: "Don't break it.",
                             tr: "Bozma.",
                             es: "No lo rompas.")
        }
    }

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return L10n.text(language: language, en: "Good morning.", tr: "Günaydın.", es: "Buenos días.") }
        if h < 17 { return L10n.text(language: language, en: "Good afternoon.", tr: "İyi öğleden sonralar.", es: "Buenas tardes.") }
        return L10n.text(language: language, en: "Good evening.", tr: "İyi akşamlar.", es: "Buenas noches.")
    }

    private var primaryLabel: String {
        notificationIsSet
        ? L10n.text(language: language, en: "Start Morning Reset", tr: "Morning Reset'i başlat", es: "Iniciar Morning Reset")
        : L10n.text(language: language, en: "Set morning notification", tr: "Sabah bildirimini ayarla", es: "Configurar notificación")
    }

    private var secondaryLabel: String {
        notificationIsSet
        ? L10n.text(language: language, en: "Edit notification", tr: "Bildirimi düzenle", es: "Editar notificación")
        : L10n.text(language: language, en: "Start without notification", tr: "Bildirimsiz başla", es: "Iniciar sin notificación")
    }
}
