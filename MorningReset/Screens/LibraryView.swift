import SwiftUI

// MARK: - Library (retention / discovery screen)

struct LibraryView: View {
    @Environment(AppState.self) private var appState

    struct PracticeSelection: Identifiable {
        let id = UUID()
        let practice: PathPractice
        let path: EnergyPath
    }

    @State private var selected: PracticeSelection? = nil

    private var todayPick: (PathPractice, EnergyPath) {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        if let path = appState.activePath {
            return (path.practices[day % path.practices.count], path)
        }
        let all = EnergyPath.allCases.flatMap { p in p.practices.map { ($0, p) } }
        return all[day % all.count]
    }

    var body: some View {
        ZStack {
            AuraBackground(path: appState.activePath, intensity: 0.25)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DS.Space.xl) {

                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.text(en: "Library", tr: "Kütüphane", es: "Biblioteca"))
                            .font(DS.Typo.title)
                            .foregroundStyle(DS.textPrimary)
                        Text(L10n.text(
                            en: "All practices, at any time.",
                            tr: "Tüm pratikler, her zaman.",
                            es: "Todas las prácticas, en cualquier momento."
                        ))
                        .font(.subheadline)
                        .foregroundStyle(DS.textSecondary)
                    }
                    .padding(.top, DS.Space.xl)

                    // Today's Practice
                    todaySection

                    // Active path — Learn link
                    if let path = appState.activePath {
                        pathSection(path, isActive: true)
                    }

                    // Other paths
                    ForEach(EnergyPath.allCases) { path in
                        if path != appState.activePath {
                            pathSection(path, isActive: false)
                        }
                    }

                    Spacer().frame(height: DS.Space.xl)
                }
                .padding(.horizontal, DS.Space.lg)
            }
        }
        .sheet(item: $selected) { sel in
            PracticeDetailSheet(practice: sel.practice, path: sel.path)
                .environment(appState)
        }
    }

    // MARK: - Today's pick card

    private var todaySection: some View {
        let (practice, path) = todayPick
        return VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text(L10n.text(en: "TODAY'S PRACTICE", tr: "BUGÜNÜN PRATİĞİ", es: "PRÁCTICA DE HOY"))
                .font(.system(size: 9, weight: .semibold))
                .kerning(1.2)
                .foregroundStyle(DS.accent)

            Button {
                selected = PracticeSelection(practice: practice, path: path)
            } label: {
                HStack(spacing: DS.Space.md) {
                    Image(systemName: practice.symbol)
                        .font(.system(size: 28))
                        .foregroundStyle(DS.accent)
                        .frame(width: 40)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(practice.title)
                            .font(.system(.title3, design: .serif))
                            .foregroundStyle(DS.textPrimary)
                        Text(practice.why)
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
                .background(DS.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(DS.border, lineWidth: DS.hairline))
            }
        }
    }

    // MARK: - Path section

    private func pathSection(_ path: EnergyPath, isActive: Bool) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            HStack {
                Image(systemName: path.symbol)
                    .font(.callout)
                    .foregroundStyle(DS.accent)
                Text(path.title)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(DS.textPrimary)
                Spacer()
                Button {
                    appState.showPathLearn()
                } label: {
                    Text(L10n.text(en: "Learn", tr: "Öğren", es: "Aprender"))
                        .font(.caption.bold())
                        .foregroundStyle(DS.accent)
                }
            }

            ForEach(path.practices) { practice in
                practiceRow(practice, path: path)
            }
        }
    }

    // MARK: - Practice row

    private func practiceRow(_ practice: PathPractice, path: EnergyPath) -> some View {
        let isActive: Bool = {
            if case .practice(let p, let id) = appState.activeFirstWin?.kind {
                return p == path && id == practice.id
            }
            return false
        }()

        return Button {
            selected = PracticeSelection(practice: practice, path: path)
        } label: {
            HStack(spacing: DS.Space.md) {
                Image(systemName: practice.symbol)
                    .font(.system(size: 15))
                    .foregroundStyle(isActive ? DS.background : DS.accent)
                    .frame(width: 26)
                VStack(alignment: .leading, spacing: 2) {
                    Text(practice.title)
                        .font(.body)
                        .foregroundStyle(isActive ? DS.background : DS.textPrimary)
                    Text(practice.why)
                        .font(.caption)
                        .foregroundStyle(isActive ? DS.background.opacity(0.8) : DS.textDim)
                        .lineLimit(1)
                }
                Spacer()
                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(DS.background)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(DS.textDim)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, DS.Space.md)
            .background(isActive ? DS.accent : DS.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(isActive ? DS.accent : DS.border, lineWidth: DS.hairline))
        }
    }
}

// MARK: - Practice Detail Sheet

struct PracticeDetailSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var practice: PathPractice
    var path: EnergyPath

    private var isActive: Bool {
        if case .practice(let p, let id) = appState.activeFirstWin?.kind {
            return p == path && id == practice.id
        }
        return false
    }

    var body: some View {
        ZStack {
            AuraBackground(path: path, intensity: 0.5)

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(DS.textDim)
                    }
                }
                .padding(.horizontal, DS.Space.lg)
                .padding(.top, DS.Space.md)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DS.Space.lg) {

                        // Symbol + path label + title + why
                        VStack(alignment: .leading, spacing: DS.Space.sm) {
                            Image(systemName: practice.symbol)
                                .font(.system(size: 36))
                                .foregroundStyle(DS.accent)

                            Text(path.title.uppercased())
                                .font(.system(size: 10, weight: .semibold))
                                .kerning(1.2)
                                .foregroundStyle(DS.accent)

                            Text(practice.title)
                                .font(DS.Typo.title)
                                .foregroundStyle(DS.textPrimary)

                            Text(practice.why)
                                .font(.callout.italic())
                                .foregroundStyle(DS.textSecondary)
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // How
                        VStack(alignment: .leading, spacing: DS.Space.xs) {
                            Text(L10n.text(en: "HOW TO PRACTICE", tr: "NASIL YAPILIR", es: "CÓMO PRACTICAR"))
                                .font(.system(size: 10, weight: .semibold))
                                .kerning(1.2)
                                .foregroundStyle(DS.accent)
                            Text(practice.how)
                                .font(.callout)
                                .foregroundStyle(DS.textPrimary)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // Steps
                        if !practice.steps.isEmpty {
                            VStack(alignment: .leading, spacing: DS.Space.sm) {
                                ForEach(Array(practice.steps.enumerated()), id: \.offset) { i, step in
                                    HStack(alignment: .top, spacing: DS.Space.sm) {
                                        Text("\(i + 1)")
                                            .font(.system(size: 13, weight: .semibold, design: .serif))
                                            .foregroundStyle(DS.accent)
                                            .frame(width: 20, alignment: .leading)
                                        Text(step)
                                            .font(.callout)
                                            .foregroundStyle(DS.textPrimary)
                                            .lineSpacing(3)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.bottom, DS.Space.lg)
                }

                // CTA
                if !isActive {
                    Button {
                        appState.selectActiveFirstWin(.practice(path: path, id: practice.id))
                        appState.selectMorningPath(path)
                        dismiss()
                    } label: {
                        Text(L10n.text(
                            en: "Set as my practice",
                            tr: "Pratiğim olarak seç",
                            es: "Elegir como mi práctica"
                        ))
                        .font(.system(.body, design: .serif))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(DS.accent)
                        .foregroundStyle(DS.background)
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.bottom, DS.Space.lg)
                } else {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(DS.accent)
                        Text(L10n.text(en: "Your current practice", tr: "Şu anki pratiğin", es: "Tu práctica actual"))
                            .font(.subheadline)
                            .foregroundStyle(DS.textSecondary)
                    }
                    .padding(.bottom, DS.Space.lg)
                }
            }
        }
        .onAppear { AmbientPlayer.shared.start(path: path) }
        .onDisappear { AmbientPlayer.shared.stop() }
    }
}
