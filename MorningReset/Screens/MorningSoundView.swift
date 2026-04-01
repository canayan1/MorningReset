import SwiftUI

struct MorningSoundView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openURL) private var openURL

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("SOUND")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(DS.textDim)
                        .kerning(1.2)

                    Text("Choose your morning sound.")
                        .font(.title2.bold())
                        .foregroundStyle(DS.textPrimary)
                }

                Spacer().frame(height: 28)

                HStack(spacing: DS.Space.sm) {
                    ForEach(SoundDirection.allCases) { direction in
                        soundChip(direction)
                    }
                }

                Spacer().frame(height: DS.Space.md)

                if let url = appState.selectedSoundDirection.playlistURL {
                    Button {
                        openURL(url)
                    } label: {
                        HStack(spacing: 6) {
                            Text("Open playlist")
                                .font(.subheadline)
                                .foregroundStyle(DS.textSecondary)
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 11))
                                .foregroundStyle(DS.textDim)
                        }
                    }
                }

                Spacer()

                Button("Continue") {
                    appState.showResults()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.textPrimary)
                .foregroundStyle(DS.background)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.bottom, 48)
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
                .background(selected ? DS.textPrimary : DS.surface)
                .overlay(Rectangle().stroke(DS.border, lineWidth: 1))
        }
    }
}
