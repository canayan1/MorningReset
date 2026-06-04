import SwiftUI

// MARK: - Path picker (onboarding)

struct EnergyPathPickView: View {
    var onPick: (EnergyPath) -> Void

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: DS.Space.lg) {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text(L10n.text(en: "Choose your path", tr: "Yolunu seç", es: "Elige tu camino"))
                        .font(DS.Typo.title)
                        .foregroundStyle(DS.textPrimary)
                    Text(L10n.text(
                        en: "Each tradition raises your morning energy a different way.",
                        tr: "Her gelenek sabah enerjini farklı bir yoldan yükseltir.",
                        es: "Cada tradición eleva tu energía matinal de una forma distinta."
                    ))
                    .font(.subheadline)
                    .foregroundStyle(DS.textSecondary)
                    .lineSpacing(3)
                }
                .padding(.top, DS.Space.xl)

                VStack(spacing: DS.Space.md) {
                    ForEach(EnergyPath.allCases) { path in
                        pathCard(path)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, DS.Space.lg)
            .padding(.bottom, DS.Space.lg)
        }
    }

    private func pathCard(_ path: EnergyPath) -> some View {
        Button {
            onPick(path)
        } label: {
            HStack(spacing: DS.Space.md) {
                Image(systemName: path.symbol)
                    .font(.system(size: 26))
                    .foregroundStyle(DS.accent)
                    .frame(width: 40)
                VStack(alignment: .leading, spacing: 3) {
                    Text(path.title)
                        .font(.system(.title3, design: .serif))
                        .foregroundStyle(DS.textPrimary)
                    Text(path.essence)
                        .font(.caption)
                        .foregroundStyle(DS.textSecondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DS.textDim)
            }
            .padding(DS.Space.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DS.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(DS.border, lineWidth: DS.hairline))
        }
        .accessibilityIdentifier("pathPick.\(path.rawValue)")
    }
}

// MARK: - Path basics / Learn

struct PathBasicsView: View {
    var path: EnergyPath
    var ctaTitle: String
    var onContinue: () -> Void
    var showBack: Bool = false
    var onBack: (() -> Void)? = nil

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(spacing: 0) {
                if showBack {
                    HStack {
                        Button { onBack?() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(DS.textSecondary)
                                .frame(width: 40, height: 40)
                                .contentShape(Rectangle())
                        }
                        .accessibilityIdentifier("pathBasics.backButton")
                        Spacer()
                    }
                    .padding(.horizontal, DS.Space.md)
                    .padding(.top, DS.Space.sm)
                }

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DS.Space.lg) {
                        VStack(alignment: .leading, spacing: DS.Space.sm) {
                            Image(systemName: path.symbol)
                                .font(.system(size: 36))
                                .foregroundStyle(DS.accent)
                            Text(path.title)
                                .font(DS.Typo.title)
                                .foregroundStyle(DS.textPrimary)
                            Text(path.essence)
                                .font(.callout)
                                .foregroundStyle(DS.textSecondary)
                                .lineSpacing(3)
                        }
                        .padding(.top, showBack ? DS.Space.xs : DS.Space.xl)

                        ForEach(Array(path.basics.enumerated()), id: \.offset) { _, section in
                            VStack(alignment: .leading, spacing: DS.Space.xs) {
                                Text(section.heading.uppercased())
                                    .font(.system(size: 10, weight: .semibold))
                                    .kerning(1.2)
                                    .foregroundStyle(DS.accent)
                                Text(section.body)
                                    .font(.callout)
                                    .foregroundStyle(DS.textPrimary)
                                    .lineSpacing(4)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        Text(path.disclaimer)
                            .font(.caption2)
                            .foregroundStyle(DS.textDim)
                            .lineSpacing(3)
                            .padding(.top, DS.Space.sm)
                    }
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.bottom, DS.Space.lg)
                }

                Button(ctaTitle) {
                    onContinue()
                }
                .font(.system(.body, design: .serif))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.accent)
                .foregroundStyle(DS.background)
                .clipShape(Capsule())
                .padding(.horizontal, DS.Space.lg)
                .padding(.bottom, DS.Space.lg)
                .accessibilityIdentifier("pathBasics.continueButton")
            }
        }
    }
}

struct PathLearnView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        PathBasicsView(
            path: appState.activePath ?? .reiki,
            ctaTitle: L10n.text(en: "Done", tr: "Tamam", es: "Listo"),
            onContinue: { appState.showWakeHome() },
            showBack: true,
            onBack: { appState.showWakeHome() }
        )
    }
}

// MARK: - Practice picker (the daily First Win)

struct FirstWinPickScreen: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        let path = appState.activePath ?? .reiki
        FirstWinPickView(
            title: L10n.text(en: "Pick your next practice", tr: "Sıradaki pratiğini seç", es: "Elige tu próxima práctica"),
            subtitle: L10n.text(
                en: "One practice, seven mornings. That's how your energy builds.",
                tr: "Tek pratik, yedi sabah. Enerjin böyle birikir.",
                es: "Una práctica, siete mañanas. Así se acumula tu energía."
            ),
            ctaTitle: L10n.text(en: "Start this practice", tr: "Bu pratiği başlat", es: "Empezar esta práctica"),
            path: path,
            recommended: appState.recommendedNextPractice,
            reason: L10n.text(en: "Recommended next", tr: "Önerilen sıradaki", es: "Recomendado a continuación")
        ) { kind in
            appState.selectActiveFirstWin(kind)
            appState.showMyWins()
        }
    }
}

struct FirstWinPickView: View {
    var title: String
    var subtitle: String
    var ctaTitle: String
    var path: EnergyPath
    var recommended: PathPractice? = nil
    var reason: String? = nil
    var onPick: (FirstWinKind) -> Void

    @State private var selectedID: String? = nil
    @State private var customSelected = false
    @State private var customText = ""
    @State private var didPreselect = false
    @FocusState private var customFocused: Bool

    private var listPractices: [PathPractice] {
        guard let recommended else { return path.practices }
        return path.practices.filter { $0.id != recommended.id }
    }

    private var resolvedKind: FirstWinKind? {
        if customSelected {
            let trimmed = customText.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : .custom(trimmed)
        }
        if let id = selectedID { return .practice(path: path, id: id) }
        return nil
    }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DS.Space.lg) {
                        VStack(alignment: .leading, spacing: DS.Space.xs) {
                            Text(title)
                                .font(DS.Typo.title)
                                .foregroundStyle(DS.textPrimary)
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(DS.textSecondary)
                                .lineSpacing(3)
                        }
                        .padding(.top, DS.Space.xl)

                        VStack(spacing: DS.Space.sm) {
                            if let recommended {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(L10n.text(en: "RECOMMENDED FOR YOU", tr: "SANA ÖNERİLEN", es: "RECOMENDADO PARA TI"))
                                        .font(.system(size: 9, weight: .semibold))
                                        .kerning(1.2)
                                        .foregroundStyle(DS.accent)
                                    if let reason {
                                        Text(reason)
                                            .font(.caption)
                                            .foregroundStyle(DS.textDim)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                practiceRow(recommended)
                                Divider().background(DS.border).padding(.vertical, DS.Space.xs)
                            }
                            ForEach(listPractices) { practice in
                                practiceRow(practice)
                            }
                            customRow
                        }
                    }
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.bottom, DS.Space.lg)
                }

                Button(ctaTitle) {
                    if let kind = resolvedKind { onPick(kind) }
                }
                .font(.system(.body, design: .serif))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(resolvedKind == nil ? DS.surfaceAlt : DS.accent)
                .foregroundStyle(resolvedKind == nil ? DS.textDim : DS.background)
                .clipShape(Capsule())
                .disabled(resolvedKind == nil)
                .animation(.easeOut(duration: 0.15), value: resolvedKind == nil)
                .padding(.horizontal, DS.Space.lg)
                .padding(.bottom, DS.Space.lg)
                .accessibilityIdentifier("firstWinPick.continueButton")
            }
        }
        .onAppear {
            if !didPreselect {
                didPreselect = true
                if selectedID == nil, let recommended { selectedID = recommended.id }
            }
        }
    }

    private func practiceRow(_ practice: PathPractice) -> some View {
        let selected = !customSelected && selectedID == practice.id
        return Button {
            customSelected = false
            customFocused = false
            selectedID = practice.id
        } label: {
            HStack(spacing: DS.Space.md) {
                Image(systemName: practice.symbol)
                    .font(.system(size: 18))
                    .foregroundStyle(selected ? DS.background : DS.accent)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 1) {
                    Text(practice.title)
                        .font(.body.weight(selected ? .semibold : .regular))
                        .foregroundStyle(selected ? DS.background : DS.textPrimary)
                    Text(practice.why)
                        .font(.caption)
                        .foregroundStyle(selected ? DS.background.opacity(0.85) : DS.textDim)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16))
                    .foregroundStyle(selected ? DS.background : DS.border)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, DS.Space.md)
            .background(selected ? DS.accent : DS.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(selected ? DS.accent : DS.border, lineWidth: DS.hairline))
        }
        .animation(.easeOut(duration: 0.15), value: selected)
        .accessibilityIdentifier("firstWinPick.practice.\(practice.id)")
    }

    private var customRow: some View {
        let selected = customSelected
        return VStack(alignment: .leading, spacing: DS.Space.sm) {
            Button {
                selectedID = nil
                customSelected = true
                customFocused = true
            } label: {
                HStack(spacing: DS.Space.md) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18))
                        .foregroundStyle(selected ? DS.background : DS.accent)
                        .frame(width: 30)
                    Text(L10n.text(en: "Write your own", tr: "Kendi pratiğini yaz", es: "Escribe la tuya"))
                        .font(.body.weight(selected ? .semibold : .regular))
                        .foregroundStyle(selected ? DS.background : DS.textPrimary)
                    Spacer()
                    Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 16))
                        .foregroundStyle(selected ? DS.background : DS.border)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, DS.Space.md)
                .background(selected ? DS.accent : DS.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(selected ? DS.accent : DS.border, lineWidth: DS.hairline))
            }
            .animation(.easeOut(duration: 0.15), value: selected)

            if selected {
                TextField(
                    L10n.text(en: "e.g. Morning meditation", tr: "örn. Sabah meditasyonu", es: "ej. Meditación matinal"),
                    text: $customText
                )
                .focused($customFocused)
                .font(.body)
                .foregroundStyle(DS.textPrimary)
                .padding(.vertical, 12)
                .padding(.horizontal, DS.Space.md)
                .background(DS.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(DS.border, lineWidth: DS.hairline))
                .accessibilityIdentifier("firstWinPick.customField")
            }
        }
    }
}
