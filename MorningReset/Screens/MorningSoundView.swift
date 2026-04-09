import SwiftUI

struct MorningSoundView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openURL) private var openURL

    private var pick: SoundPick {
        appState.selectedSoundDirection.todayPick
    }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("SOUND")
                        .font(DS.Typo.label)
                        .foregroundStyle(DS.textDim)
                        .kerning(1.4)

                    Text("Choose your morning sound.")
                        .font(DS.Typo.title)
                        .foregroundStyle(DS.textPrimary)
                }

                Spacer().frame(height: DS.Space.lg + 4)

                HStack(spacing: DS.Space.sm) {
                    ForEach(SoundDirection.allCases) { direction in
                        soundChip(direction)
                    }
                }

                Spacer().frame(height: DS.Space.md + 4)

                // Today's curated pick
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("TODAY'S PICK")
                        .font(DS.Typo.micro)
                        .foregroundStyle(DS.textDim)
                        .kerning(1.4)

                    Text(pick.title)
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(DS.textPrimary)

                    Text(pick.curator)
                        .font(.caption)
                        .italic()
                        .foregroundStyle(DS.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(DS.Space.md)
                .background(DS.surface)
                .hairlineBorder()

                Spacer().frame(height: DS.Space.sm + 4)

                if let url = pick.url {
                    Button {
                        openURL(url)
                    } label: {
                        HStack(spacing: 6) {
                            Text("Open in Spotify")
                                .font(.subheadline)
                                .foregroundStyle(DS.accent)
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 11))
                                .foregroundStyle(DS.accent)
                        }
                    }
                }

                Spacer()

                Button("Continue") {
                    appState.showResults()
                }
                .font(.system(.body, design: .serif))
                .tracking(0.5)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.accent)
                .foregroundStyle(DS.background)
                .clipShape(Capsule())
                .padding(.bottom, DS.Space.xl)
            }
            .padding(.horizontal, DS.Space.lg)
        }
    }

    private func soundChip(_ direction: SoundDirection) -> some View {
        let selected = appState.selectedSoundDirection == direction
        return Button {
            appState.setSoundDirection(direction)
        } label: {
            Text(direction.label)
                .font(.system(size: 13, weight: selected ? .semibold : .regular))
                .foregroundStyle(selected ? DS.background : DS.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(selected ? DS.accent : DS.surface)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(DS.border, lineWidth: DS.hairline))
        }
    }
}
