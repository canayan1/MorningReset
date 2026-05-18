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
                    Button(L10n.text(language: language, en: "About", tr: "Hakkında", es: "Acerca de")) {
                        showAbout = true
                    }
                    .font(.caption)
                    .foregroundStyle(DS.textDim)
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
        .sheet(isPresented: $showAbout) { AboutView() }
    }

    // MARK: - Hero states

    private var streakHero: some View {
        VStack(spacing: DS.Space.xs) {
            // Big number
            Text("\(streak)")
                .font(.system(size: 88, weight: .thin, design: .serif))
                .foregroundStyle(DS.textPrimary)
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

    private var emptyStateHero: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text(greeting)
                .font(.system(size: 36, weight: .regular, design: .serif))
                .foregroundStyle(DS.textPrimary)

            Text(L10n.text(language: language,
                           en: "One morning ritual.\nBefore the scroll begins.",
                           tr: "Tek bir sabah ritüeli.\nKaydırma başlamadan önce.",
                           es: "Un ritual matinal.\nAntes de que empiece el scroll."))
                .font(.callout)
                .foregroundStyle(DS.textSecondary)
                .lineSpacing(4)
        }
        .padding(.horizontal, DS.Space.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
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
