import SwiftUI

struct WeeklyAffirmationView: View {
    @Environment(AppState.self) private var appState
    @State private var progress = 0.0
    @State private var hasAdvanced = false

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .center, spacing: 0) {
                Spacer()

                Text(MantraEngine.weeklyMantra())
                    .font(.system(size: 26, weight: .regular, design: .serif))
                    .foregroundStyle(DS.textPrimary)
                    .lineSpacing(6)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, DS.Space.lg)

                Spacer()

                ProgressView(value: progress, total: 1)
                    .tint(DS.accent)
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.bottom, DS.Space.xl)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { advance() }
        .task {
            withAnimation(.linear(duration: 2.4)) { progress = 1 }
            try? await Task.sleep(nanoseconds: 2_400_000_000)
            guard !Task.isCancelled else { return }
            advance()
        }
    }

    private func advance() {
        guard !hasAdvanced else { return }
        hasAdvanced = true
        appState.showMorningSound()
    }
}
