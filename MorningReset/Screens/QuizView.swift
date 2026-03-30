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
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text(Strings.Quiz.progress(current: index + 1, total: MorningData.questions.count))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.white.opacity(0.4))
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)

                Spacer()

                Text(question.text)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 24)
                    .id(index)
                    .transition(.opacity)

                Spacer()

                HStack(spacing: 12) {
                    answerButton(label: "No", answer: "No")
                    answerButton(label: "Yes", answer: "Yes")
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }

    private func answerButton(label: String, answer: String) -> some View {
        Button {
            guard !answered else { return }
            answered = true
            appState.recordAnswer(answer)
            appState.resetInactivityTimer()
            advance()
        } label: {
            Text(label)
                .font(.headline)
                .foregroundStyle(answer == "Yes" ? .black : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(answer == "Yes" ? Color.white : Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 14))
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
                appState.showIntention()
            }
        }
    }
}
