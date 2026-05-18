import SwiftUI

struct MorningSoundView: View {
    @Environment(AppState.self) private var appState
    @State private var progress = 0.0
    @State private var hasAdvanced = false

    private var pick: SoundPick {
        appState.selectedSoundDirection.todayPick
    }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text(L10n.text(en: "SOUND CUE", tr: "SES İPUCU", es: "PISTA DE SONIDO"))
                        .font(DS.Typo.label)
                        .foregroundStyle(DS.textDim)
                        .kerning(1.4)

                    Text(L10n.text(en: "Keep the soundtrack for after the reset.", tr: "Müziği reset'ten sonrasına sakla.", es: "Deja la banda sonora para después del reset."))
                        .font(DS.Typo.title)
                        .foregroundStyle(DS.textPrimary)
                }

                Spacer().frame(height: DS.Space.lg + 4)

                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text(appState.selectedSoundDirection.label.uppercased())
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

                    Text(L10n.text(en: "Queue it when the ritual is done.", tr: "Ritüel bitince sıraya al.", es: "Ponlo en cola cuando termine el ritual."))
                        .font(.caption)
                        .foregroundStyle(DS.textDim)
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(DS.Space.md)
                .background(DS.surface)
                .hairlineBorder()

                Spacer()

                ProgressView(value: progress, total: 1)
                    .tint(DS.accent)
                .padding(.bottom, DS.Space.xl)
            }
            .padding(.horizontal, DS.Space.lg)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            advance()
        }
        .task {
            withAnimation(.linear(duration: 2.2)) {
                progress = 1
            }
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            guard !Task.isCancelled else { return }
            advance()
        }
    }

    private func advance() {
        guard !hasAdvanced else { return }
        hasAdvanced = true
        appState.showResults()
    }
}
