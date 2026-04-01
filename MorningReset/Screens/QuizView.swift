import SwiftUI

struct QuizView: View {
    @Environment(AppState.self) private var appState
    @State private var index: Int = 0
    @State private var answered: Bool = false

    private var question: Question {
        MorningData.questions[index]
    }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(spacing: 6) {
                    ForEach(0..<MorningData.questions.count, id: \.self) { i in
                        Capsule()
                            .fill(i <= index ? DS.textPrimary : DS.border)
                            .frame(width: 20, height: 3)
                    }
                }
                .padding(.top, 24)

                Spacer()

                Text(question.text)
                    .font(.title.bold())
                    .foregroundStyle(DS.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .id(index)
                    .transition(.opacity)

                Spacer()

                HStack(spacing: 12) {
                    answerButton(label: "No", answer: "No", isYes: false)
                    answerButton(label: "Yes", answer: "Yes", isYes: true)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }

    private func answerButton(label: String, answer: String, isYes: Bool) -> some View {
        Button {
            guard !answered else { return }
            answered = true
            appState.recordAnswer(answer)
            appState.resetInactivityTimer()
            advance()
        } label: {
            Text(label)
                .font(.headline)
                .foregroundStyle(isYes ? DS.background : DS.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(isYes ? DS.textPrimary : DS.surface)
                .clipShape(Capsule())
        }
        .disabled(answered)
    }

    private func advance() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            let next = index + 1
            if next < MorningData.questions.count {
                withAnimation(.linear(duration: 0.15)) {
                    index = next
                    answered = false
                }
            } else {
                appState.showWeeklyAffirmation()
            }
        }
    }
}
