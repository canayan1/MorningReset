import SwiftUI

struct GuidedPauseView: View {
    @Environment(AppState.self) private var appState
    @State private var progress = 0.0
    @State private var hasAdvanced = false

    private static var weekIndex: Int {
        Calendar.current.component(.weekOfYear, from: Date()) % 4
    }

    private var prompts: [(breath: String, reflect: String)] {[
        (
            L10n.text(en: "One slow breath.",           tr: "Yavaş bir nefes.",          es: "Una respiración lenta."),
            L10n.text(en: "What's worth your full attention today?", tr: "Bugün tam dikkatini neye hak veriyor?", es: "¿Qué merece tu atención completa hoy?")
        ),
        (
            L10n.text(en: "Three quiet breaths.",       tr: "Üç sessiz nefes.",           es: "Tres respiraciones tranquilas."),
            L10n.text(en: "What's one thing worth protecting today?", tr: "Bugün korunmaya değer bir şey nedir?", es: "¿Qué es una cosa que vale la pena proteger hoy?")
        ),
        (
            L10n.text(en: "Inhale. Hold. Release.",     tr: "Nefes al. Tut. Bırak.",      es: "Inhala. Aguanta. Suelta."),
            L10n.text(en: "What would a clean first hour look like?", tr: "Temiz bir ilk saat nasıl görünürdü?", es: "¿Cómo sería una primera hora limpia?")
        ),
        (
            L10n.text(en: "Breathe in. Let it settle.", tr: "İçine çek. Yerleşmesine izin ver.", es: "Respira. Déjalo asentarse."),
            L10n.text(en: "What matters most before noon?",           tr: "Öğleden önce en çok ne önemli?",      es: "¿Qué importa más antes del mediodía?")
        ),
    ]}

    private var prompt: (breath: String, reflect: String) {
        prompts[Self.weekIndex]
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .center, spacing: 0) {
                Spacer()

                VStack(alignment: .center, spacing: DS.Space.xs) {
                    Text(L10n.text(en: "PAUSE", tr: "DURAKLAMA", es: "PAUSA"))
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(DS.textDim)
                        .kerning(1.2)

                    Text(prompt.breath)
                        .font(.title2.bold())
                        .foregroundStyle(DS.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)

                Spacer().frame(height: DS.Space.lg)

                InfoCard(label: L10n.text(en: "REFLECT", tr: "DÜŞÜNCE", es: "REFLEXIÓN"), value: prompt.reflect)

                Spacer()

                ProgressView(value: progress, total: 1)
                    .tint(DS.accent)
                .padding(.bottom, 48)
            }
            .padding(.horizontal, DS.Space.lg)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            advance()
        }
        .task {
            withAnimation(.linear(duration: 3.0)) {
                progress = 1
            }
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard !Task.isCancelled else { return }
            advance()
        }
    }

    private func advance() {
        guard !hasAdvanced else { return }
        hasAdvanced = true
        appState.showAction()
    }
}
