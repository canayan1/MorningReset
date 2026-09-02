import SwiftUI

/// The final screen after every completed ritual.
/// Houses the three premium features: Rise & Flow · Breath Reset · Morning Pages.
/// Free users see locked cards and a single unlock CTA.
struct PremiumHubView: View {
    @Environment(AppState.self) private var appState

    @State private var storyReady      = false
    @State private var generatingStory = false
    @State private var appeared        = false

    private var mode: MorningMode { appState.sessionMode }

    // MARK: - Computed helpers

    private var thisMonthFlow: MobilityFlow { MobilityLibrary.flow() }

    private var breathTitle: String {
        switch mode {
        case .protect: return L10n.text(en: "4-7-8 breathing",    tr: "4-7-8 nefes",       es: "Respiración 4-7-8")
        case .steady:  return L10n.text(en: "Box breathing",      tr: "Kutu nefes",         es: "Respiración cuadrada")
        case .push:    return L10n.text(en: "Energising breath",  tr: "Canlandırıcı nefes", es: "Respiración energizante")
        }
    }

    private var pagesPrompt: String {
        switch mode {
        case .protect: return L10n.text(en: "What will you protect today?",
                                        tr: "Bugün neyi koruyacaksın?",
                                        es: "¿Qué vas a proteger hoy?")
        case .steady:  return L10n.text(en: "What are you returning to today?",
                                        tr: "Bugün neye geri dönüyorsun?",
                                        es: "¿A qué estás volviendo hoy?")
        case .push:    return L10n.text(en: "What's the one thing that moves the needle?",
                                        tr: "Bugün ibreyi ne hareket ettirecek?",
                                        es: "¿Qué mueve la aguja hoy?")
        }
    }

    private var pagesDone: Bool { MorningPagesStore.hasEntryForToday() }

    private var lastMonthStoryKey: (year: Int, month: Int)? {
        let cal = Calendar.current
        guard let lm = cal.date(byAdding: .month, value: -1, to: Date()) else { return nil }
        let c = cal.dateComponents([.year, .month], from: lm)
        guard let y = c.year, let m = c.month else { return nil }
        return (y, m)
    }

    private var lastMonthName: String {
        guard let key = lastMonthStoryKey,
              let date = Calendar.current.date(from: DateComponents(year: key.year, month: key.month))
        else { return "" }
        let f = DateFormatter(); f.dateFormat = "MMMM"
        return f.string(from: date)
    }

    private var currentMonthName: String {
        let f = DateFormatter(); f.dateFormat = "MMMM"
        return f.string(from: Date())
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DS.Space.sm) {

                        // Story notification card
                        if storyReady, let key = lastMonthStoryKey,
                           MorningPagesStore.cachedStory(year: key.year, month: key.month) != nil {
                            storyCard
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // Rise & Flow
                        FeatureCard(
                            title:    thisMonthFlow.title,
                            subtitle: "\(currentMonthName) · \(thisMonthFlow.subtitle)",
                            detail:   L10n.text(en: "5 min", tr: "5 dk", es: "5 min"),
                            icon:     "figure.walk",
                            locked:   !appState.isPremium,
                            done:     false
                        ) { appState.openMobilityFlow() }

                        // Breath Reset
                        FeatureCard(
                            title:    breathTitle,
                            subtitle: L10n.text(en: "Guided breathing session", tr: "Rehberli nefes seansı", es: "Sesión de respiración guiada"),
                            detail:   L10n.text(en: "3 min", tr: "3 dk", es: "3 min"),
                            icon:     "wind",
                            locked:   !appState.isPremium,
                            done:     false
                        ) { appState.openBreathReset() }

                        // Morning Pages
                        FeatureCard(
                            title:    L10n.text(en: "Morning Pages", tr: "Sabah Sayfaları", es: "Páginas matinales"),
                            subtitle: pagesPrompt,
                            detail:   pagesDone
                                ? L10n.text(en: "Written ✓", tr: "Yazıldı ✓", es: "Escrito ✓")
                                : L10n.text(en: "2 min", tr: "2 dk", es: "2 min"),
                            icon:     "pencil",
                            locked:   !appState.isPremium,
                            done:     pagesDone
                        ) { appState.openMorningPages() }
                    }
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.top, DS.Space.xl)
                    .padding(.bottom, DS.Space.lg)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)
                }

                // Footer
                VStack(spacing: DS.Space.sm) {
                    Button(L10n.text(en: "Done for today", tr: "Bugünlük tamam", es: "Listo por hoy")) {
                        appState.showWakeHome()
                    }
                    .primaryCTA()
                    .accessibilityIdentifier("premiumHub.doneButton")

                    if !appState.isPremium {
                        Button(L10n.text(en: "Unlock all three features", tr: "Üç özelliğin kilidini aç", es: "Desbloquear las tres funciones")) {
                            appState.paywallContext = .riseAndFlow
                            appState.screen = .paywall
                        }
                        .font(.subheadline)
                        .foregroundStyle(DS.textSecondary)
                        .accessibilityIdentifier("premiumHub.unlockButton")
                    }
                }
                .padding(.horizontal, DS.Space.lg)
                .padding(.bottom, DS.Space.xl)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.25), value: appeared)
            }
        }
        .onAppear {
            appeared = true
            checkForStory()
            triggerStoryGeneration()
        }
        .animation(.easeOut(duration: 0.35), value: storyReady)
    }

    // MARK: - Story card

    private var storyCard: some View {
        Button { appState.showMonthlyStory() } label: {
            HStack(spacing: DS.Space.md) {
                Image(systemName: "sparkles")
                    .font(.system(size: 15))
                    .foregroundStyle(DS.accent)
                    .frame(width: 26)

                VStack(alignment: .leading, spacing: 3) {
                    Text(L10n.text(
                        en: "Your \(lastMonthName) story is ready",
                        tr: "\(lastMonthName) hikayeniz hazır",
                        es: "Tu historia de \(lastMonthName) está lista"
                    ))
                    .font(.system(.callout, design: .serif))
                    .foregroundStyle(DS.textPrimary)

                    Text(L10n.text(
                        en: "Written from your practice entries",
                        tr: "Sabah girişlerinizden yazıldı",
                        es: "Escrita a partir de tus entradas de práctica"
                    ))
                    .font(.caption)
                    .foregroundStyle(DS.textDim)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundStyle(DS.border)
            }
            .padding(DS.Space.md)
            .background(DS.accent.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(DS.accent.opacity(0.2), lineWidth: DS.hairline))
        }
    }

    // MARK: - Story generation

    private func checkForStory() {
        guard let key = lastMonthStoryKey else { return }
        storyReady = MorningPagesStore.cachedStory(year: key.year, month: key.month) != nil
    }

    private func triggerStoryGeneration() {
        guard !storyReady, !generatingStory else { return }
        guard let key = lastMonthStoryKey,
              MorningPagesStore.entriesForMonth(year: key.year, month: key.month).count >= MonthlyStoryEngine.minimumEntries
        else { return }

        generatingStory = true
        Task {
            await MonthlyStoryEngine.generateIfNeeded()
            await MainActor.run {
                generatingStory = false
                withAnimation { checkForStory() }
            }
        }
    }
}

// MARK: - Feature card component

private struct FeatureCard: View {
    let title:    String
    let subtitle: String
    let detail:   String
    let icon:     String
    let locked:   Bool
    let done:     Bool
    let action:   () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Space.md) {
                Image(systemName: done ? "checkmark" : (locked ? "lock" : icon))
                    .font(.system(size: 15))
                    .foregroundStyle(done ? DS.accent : (locked ? DS.textDim : DS.textSecondary))
                    .frame(width: 26)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(.callout, design: .serif))
                        .foregroundStyle(locked ? DS.textDim : DS.textPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(DS.textDim)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Text(detail)
                    .font(.caption)
                    .foregroundStyle(done ? DS.accent : DS.textDim)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundStyle(DS.border)
            }
            .padding(DS.Space.md)
            .background(done ? DS.accent.opacity(0.04) : DS.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(done ? DS.accent.opacity(0.25) : DS.border, lineWidth: DS.hairline)
            )
        }
    }
}
