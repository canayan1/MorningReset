import SwiftUI

struct ActionView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openURL) private var openURL
    @State private var panel: Panel = .main
    @State private var soundDirection: SoundDirection = .focus

    private enum Panel { case main, learn, action }

    private enum SoundDirection: CaseIterable, Identifiable {
        case calm, focus, energy

        var id: Self { self }

        var label: String {
            switch self {
            case .calm:   return "Calm"
            case .focus:  return "Focus"
            case .energy: return "Energy"
            }
        }

        var url: URL? {
            switch self {
            case .calm:   return URL(string: "https://open.spotify.com/playlist/37i9dQZF1DX3Ogo9pFvBkY")
            case .focus:  return URL(string: "https://open.spotify.com/playlist/37i9dQZF1DXZeyjIkhend1")
            case .energy: return URL(string: "https://open.spotify.com/playlist/37i9dQZF1DX76Wlfdnj7AP")
            }
        }

        static func recommended(for mode: MorningMode) -> SoundDirection {
            switch mode {
            case .protect: return .calm
            case .steady:  return .focus
            case .push:    return .energy
            }
        }
    }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()
            switch panel {
            case .main:   mainPanel
            case .learn:  learnPanel
            case .action: actionPanel
            }
        }
    }

    // MARK: - Main

    private var mainPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text("OPTIONAL")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(DS.textDim)
                    .kerning(1.2)

                Text("Keep going?")
                    .font(.title2.bold())
                    .foregroundStyle(DS.textPrimary)
            }

            Spacer().frame(height: 28)

            // MARK: Sound direction
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                Text("SOUND")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(DS.textDim)
                    .kerning(1.2)

                HStack(spacing: DS.Space.sm) {
                    ForEach(SoundDirection.allCases) { direction in
                        soundChip(direction)
                    }
                }
            }

            Spacer().frame(height: DS.Space.md)

            VStack(spacing: DS.Space.md) {
                sectionCard(
                    label: "INSIGHT",
                    preview: ActionContent.todayInsight
                ) { panel = .learn }

                sectionCard(
                    label: "ONE MORE STEP",
                    preview: ActionContent.todayBonusAction
                ) { panel = .action }

                if appState.isPremium {
                    mobilityCard
                }
            }

            Spacer().frame(height: DS.Space.lg)

            Text("No bad vibes. No negative noise.")
                .font(.caption)
                .foregroundStyle(DS.textDim)
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer()

            doneButton
        }
        .padding(.horizontal, DS.Space.lg)
        .onAppear { soundDirection = SoundDirection.recommended(for: appState.sessionMode) }
    }

    // MARK: - Learn

    private var learnPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            backButton

            Spacer().frame(height: DS.Space.lg)

            InfoCard(label: "INSIGHT", value: ActionContent.todayInsight)

            Spacer()

            doneButton
        }
        .padding(.horizontal, DS.Space.lg)
    }

    // MARK: - Action

    private var actionPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            backButton

            Spacer().frame(height: DS.Space.lg)

            InfoCard(label: "ONE MORE STEP", value: ActionContent.todayBonusAction)

            Spacer()

            doneButton
        }
        .padding(.horizontal, DS.Space.lg)
    }

    // MARK: - Shared

    private var backButton: some View {
        Button { panel = .main } label: {
            Label(Strings.Action.backButton, systemImage: "chevron.left")
                .font(.subheadline)
                .foregroundStyle(DS.textSecondary)
        }
    }

    private var doneButton: some View {
        Button("Done") { appState.endFlow() }
            .font(.subheadline)
            .foregroundStyle(DS.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.bottom, 32)
    }

    private func soundChip(_ direction: SoundDirection) -> some View {
        let selected = soundDirection == direction
        return Button {
            soundDirection = direction
            if let url = direction.url { openURL(url) }
        } label: {
            Text(direction.label)
                .font(.system(size: 13, weight: selected ? .semibold : .regular))
                .foregroundStyle(selected ? DS.background : DS.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(selected ? DS.textPrimary : DS.surface)
                .overlay(Rectangle().stroke(DS.border, lineWidth: 1))
        }
    }

    private var mobilityCard: some View {
        let flow = MobilityLibrary.flow()
        return Button { appState.openMobilityFlow() } label: {
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text("MOBILITY · 5 MIN")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(DS.textSecondary)
                    .kerning(1.2)
                Text(flow.title)
                    .font(.callout)
                    .foregroundStyle(DS.textPrimary)
                    .multilineTextAlignment(.leading)
                Text(flow.subtitle)
                    .font(.caption)
                    .foregroundStyle(DS.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DS.Space.md)
            .background(DS.surface)
            .overlay(Rectangle().stroke(DS.border, lineWidth: 1))
        }
    }

    private func sectionCard(label: String, preview: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(DS.textSecondary)
                    .kerning(1.2)
                Text(preview)
                    .font(.callout)
                    .foregroundStyle(DS.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DS.Space.md)
            .background(DS.surface)
            .overlay(Rectangle().stroke(DS.border, lineWidth: 1))
        }
    }
}
