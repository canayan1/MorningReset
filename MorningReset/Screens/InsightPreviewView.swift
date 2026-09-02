import SwiftUI

struct InsightPreviewView: View {
    @Environment(AppState.self) private var appState
    @State private var progress = 0.0
    @State private var hasAdvanced = false

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: DS.Space.lg) {
                    insightContent

                    if appState.insightStrength != .none {
                        Text(MantraEngine.weeklyMantra())
                            .font(.system(.callout, design: .serif))
                            .italic()
                            .foregroundStyle(DS.textDim)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, DS.Space.lg)

                Spacer()

                ProgressView(value: progress, total: 1)
                    .tint(DS.accent)
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.bottom, DS.Space.xl)
            }
        }
        .accessibilityIdentifier("insight.screen")
        .contentShape(Rectangle())
        .onTapGesture { advance() }
        .task {
            withAnimation(.linear(duration: 2.8)) { progress = 1 }
            try? await Task.sleep(nanoseconds: 2_800_000_000)
            guard !Task.isCancelled else { return }
            advance()
        }
    }

    @ViewBuilder
    private var insightContent: some View {
        if appState.insightStrength == .strong && !appState.isPremium {
            // Teaser — keep it simple
            VStack(spacing: DS.Space.xs) {
                Text(L10n.text(
                    en: "Your practice this week has a shape to it.",
                    tr: "Bu haftaki pratiğinin bir şekli var.",
                    es: "Tu práctica de esta semana tiene una forma."
                ))
                .font(.system(size: 22, weight: .regular, design: .serif))
                .foregroundStyle(DS.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

                Text(L10n.text(
                    en: "Premium reveals the pattern.",
                    tr: "Premium örüntüyü açığa çıkarır.",
                    es: "Premium revela el patrón."
                ))
                .font(.callout)
                .foregroundStyle(DS.textDim)
                .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        } else {
            Text(appState.insightText)
                .font(.system(size: 22, weight: .regular, design: .serif))
                .foregroundStyle(DS.textPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .lineSpacing(5)
        }
    }

    private func advance() {
        guard !hasAdvanced else { return }
        hasAdvanced = true
        appState.advanceFromInsightPreview()
    }
}
