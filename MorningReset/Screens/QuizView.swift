import SwiftUI

struct QuizView: View {
    @Environment(AppState.self) private var appState
    @State private var index: Int = 0
    @State private var selected: String? = nil

    private var question: Question {
        MorningData.questions[index]
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 32) {
                Text("\(index + 1) of \(MorningData.questions.count)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 24)

                Text(question.text)
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                VStack(spacing: 12) {
                    ForEach(question.options, id: \.self) { option in
                        Button {
                            guard selected == nil else { return }
                            selected = option
                            advance()
                        } label: {
                            HStack {
                                Text(option)
                                    .foregroundStyle(selected == option ? .black : .white)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding()
                            .background(selected == option ? Color.white : Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(selected != nil)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }

    private func advance() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            let next = index + 1
            if next < MorningData.questions.count {
                index = next
                selected = nil
            } else {
                appState.showResults()
            }
        }
    }
}
