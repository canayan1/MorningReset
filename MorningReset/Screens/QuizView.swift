import SwiftUI

struct QuizView: View {
    @Environment(AppState.self) private var appState
    @State private var currentIndex = 0
    @State private var selectedOption: String?
    @State private var isAdvancing = false
    @State private var advanceTask: Task<Void, Never>?

    private var questions: [Question] { MorningData.questions }
    private var currentQuestion: Question { questions[currentIndex] }
    private var isLastQuestion: Bool { currentIndex == questions.count - 1 }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(spacing: 0) {

                // Dot progress — top, centered
                HStack(spacing: 6) {
                    ForEach(0..<questions.count, id: \.self) { i in
                        Circle()
                            .fill(i <= currentIndex ? DS.accent : DS.border)
                            .frame(width: 5, height: 5)
                            .animation(.easeOut(duration: 0.2), value: currentIndex)
                    }
                }
                .padding(.top, DS.Space.xl)

                Spacer()

                // Question — the only thing on screen
                VStack(spacing: DS.Space.lg) {
                    Text(currentQuestion.text)
                        .font(.system(size: 28, weight: .regular, design: .serif))
                        .foregroundStyle(DS.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .id(currentIndex)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.22), value: currentIndex)

                    VStack(spacing: DS.Space.sm) {
                        ForEach(currentQuestion.options, id: \.self) { option in
                            optionButton(option)
                        }
                    }
                }
                .padding(.horizontal, DS.Space.lg)

                Spacer()
            }
        }
        .accessibilityIdentifier("quiz.screen")
        .contentShape(Rectangle())
        .simultaneousGesture(TapGesture().onEnded { appState.resetInactivityTimer() })
        .onAppear { appState.resetInactivityTimer() }
        .onDisappear { advanceTask?.cancel() }
    }

    private func optionButton(_ option: String) -> some View {
        let isSelected = selectedOption == option

        return Button {
            submit(option)
        } label: {
            Text(option)
                .font(.system(.body, design: .serif))
                .foregroundStyle(isSelected ? DS.background : DS.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isSelected ? DS.accent : DS.surface)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(isSelected ? DS.accent : DS.border, lineWidth: DS.hairline))
        }
        .disabled(isAdvancing)
        .animation(.easeOut(duration: 0.18), value: isSelected)
        .accessibilityIdentifier("quiz.option.\(currentIndex).\(currentQuestion.options.firstIndex(of: option) ?? 0)")
    }

    private func submit(_ option: String) {
        guard !isAdvancing else { return }
        isAdvancing = true
        selectedOption = option
        appState.recordAnswer(option)

        advanceTask?.cancel()
        advanceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            if isLastQuestion {
                appState.showWeeklyAffirmation()
                return
            }
            withAnimation(.easeInOut(duration: 0.22)) {
                currentIndex += 1
                selectedOption = nil
                isAdvancing = false
            }
        }
    }
}
