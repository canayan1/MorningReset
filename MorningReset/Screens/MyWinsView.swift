import SwiftUI

struct MyWinsView: View {
    @Environment(AppState.self) private var appState

    @State private var checkTrigger = 0
    @State private var graduateTrigger = 0

    private var active: ActiveFirstWin? { appState.activeFirstWin }
    private var completed: [CompletedFirstWin] { appState.completedFirstWins }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(spacing: DS.Space.xl) {
                        if let graduated = appState.firstWinJustGraduated {
                            graduatedCard(graduated)
                        } else if let active {
                            activeCard(active)
                        } else {
                            emptyCard
                        }

                        if !completed.isEmpty {
                            collectionSection
                        }
                    }
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.top, DS.Space.lg)
                    .padding(.bottom, DS.Space.xl)
                }
            }
        }
        .sensoryFeedback(.success, trigger: checkTrigger)
        .sensoryFeedback(.success, trigger: graduateTrigger)
        .accessibilityIdentifier("myWins.screen")
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button {
                appState.firstWinJustGraduated = nil
                appState.showWakeHome()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(DS.textSecondary)
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
            }
            .accessibilityIdentifier("myWins.backButton")

            Spacer()

            Text(L10n.text(en: "My Wins", tr: "Kazanımlarım", es: "Mis logros"))
                .font(DS.Typo.subtitle)
                .foregroundStyle(DS.textPrimary)

            Spacer()

            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, DS.Space.md)
        .padding(.top, DS.Space.sm)
    }

    // MARK: - Active win card

    private func activeCard(_ active: ActiveFirstWin) -> some View {
        let streak = active.displayStreak()
        let checkedToday = active.checkedToday()

        return VStack(spacing: DS.Space.md) {
            Image(systemName: active.kind.symbol)
                .font(.system(size: 40))
                .foregroundStyle(DS.accent)
                .frame(height: 52)

            Text(active.kind.title)
                .font(.system(.title2, design: .serif))
                .foregroundStyle(DS.textPrimary)
                .multilineTextAlignment(.center)

            progressDots(streak: streak)

            Text(L10n.text(
                en: "\(streak) of \(FirstWinStore.target) mornings",
                tr: "\(FirstWinStore.target) sabahın \(streak)'i",
                es: "\(streak) de \(FirstWinStore.target) mañanas"
            ))
            .font(.caption)
            .foregroundStyle(DS.textDim)

            if checkedToday {
                Label(
                    L10n.text(en: "Done for today", tr: "Bugünlük tamam", es: "Hecho por hoy"),
                    systemImage: "checkmark.seal.fill"
                )
                .font(.callout.weight(.medium))
                .foregroundStyle(DS.accent)
                .padding(.top, DS.Space.xs)
            } else {
                Button {
                    let graduated = appState.registerFirstWinCheck()
                    if graduated { graduateTrigger &+= 1 } else { checkTrigger &+= 1 }
                } label: {
                    Text(L10n.text(en: "I did it today", tr: "Bugün yaptım", es: "Lo hice hoy"))
                        .font(.system(.body, design: .serif))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(DS.accent)
                        .foregroundStyle(DS.background)
                        .clipShape(Capsule())
                }
                .padding(.top, DS.Space.xs)
                .accessibilityIdentifier("myWins.checkButton")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DS.Space.lg)
        .background(DS.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(DS.border, lineWidth: DS.hairline))
    }

    private func progressDots(streak: Int) -> some View {
        HStack(spacing: DS.Space.sm) {
            ForEach(0..<FirstWinStore.target, id: \.self) { index in
                Circle()
                    .fill(index < streak ? DS.accent : Color.clear)
                    .frame(width: 14, height: 14)
                    .overlay(Circle().stroke(index < streak ? DS.accent : DS.border, lineWidth: 1.5))
            }
        }
    }

    // MARK: - Graduated card

    private func graduatedCard(_ win: CompletedFirstWin) -> some View {
        VStack(spacing: DS.Space.md) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 44))
                .foregroundStyle(DS.accent)

            Text(L10n.text(en: "Locked in.", tr: "Kilitlendi.", es: "Fijada."))
                .font(.system(.title2, design: .serif))
                .foregroundStyle(DS.textPrimary)

            Text(L10n.text(
                en: "Seven mornings of \(win.title). It's yours now.",
                tr: "Yedi sabah \(win.title). Artık senin.",
                es: "Siete mañanas de \(win.title). Ahora es tuyo."
            ))
            .font(.callout)
            .foregroundStyle(DS.textSecondary)
            .multilineTextAlignment(.center)
            .lineSpacing(3)

            Button {
                appState.showFirstWinPick()
            } label: {
                Text(L10n.text(en: "Pick your next win", tr: "Sıradaki win'i seç", es: "Elige tu próximo win"))
                    .font(.system(.body, design: .serif))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(DS.accent)
                    .foregroundStyle(DS.background)
                    .clipShape(Capsule())
            }
            .padding(.top, DS.Space.xs)
            .accessibilityIdentifier("myWins.pickNextButton")
        }
        .frame(maxWidth: .infinity)
        .padding(DS.Space.lg)
        .background(DS.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(DS.accent, lineWidth: DS.hairline))
        .onAppear { graduateTrigger &+= 1 }
    }

    // MARK: - Empty card

    private var emptyCard: some View {
        VStack(spacing: DS.Space.md) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(DS.accent)

            Text(L10n.text(en: "Choose a First Win", tr: "Bir First Win seç", es: "Elige un First Win"))
                .font(.system(.title3, design: .serif))
                .foregroundStyle(DS.textPrimary)

            Text(L10n.text(
                en: "One small thing, every morning, for a week.",
                tr: "Küçük tek bir şey, her sabah, bir hafta boyunca.",
                es: "Una cosa pequeña, cada mañana, durante una semana."
            ))
            .font(.callout)
            .foregroundStyle(DS.textSecondary)
            .multilineTextAlignment(.center)

            Button {
                appState.showFirstWinPick()
            } label: {
                Text(L10n.text(en: "Pick a win", tr: "Win seç", es: "Elegir un win"))
                    .font(.system(.body, design: .serif))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(DS.accent)
                    .foregroundStyle(DS.background)
                    .clipShape(Capsule())
            }
            .padding(.top, DS.Space.xs)
            .accessibilityIdentifier("myWins.pickButton")
        }
        .frame(maxWidth: .infinity)
        .padding(DS.Space.lg)
        .background(DS.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(DS.border, lineWidth: DS.hairline))
    }

    // MARK: - Collection

    private var collectionSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text(L10n.text(en: "LOCKED IN", tr: "KİLİTLENENLER", es: "FIJADOS"))
                .font(.system(size: 10, weight: .semibold))
                .kerning(1.2)
                .foregroundStyle(DS.textDim)

            let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: DS.Space.md) {
                ForEach(completed) { win in
                    badge(win)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func badge(_ win: CompletedFirstWin) -> some View {
        VStack(spacing: DS.Space.xs) {
            ZStack {
                Circle()
                    .fill(DS.surfaceAlt)
                    .frame(width: 60, height: 60)
                Image(systemName: win.symbol)
                    .font(.system(size: 24))
                    .foregroundStyle(DS.accent)
            }
            Text(win.title)
                .font(.caption2)
                .foregroundStyle(DS.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }
}
