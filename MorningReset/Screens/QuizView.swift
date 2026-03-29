import SwiftUI

struct QuizView: View {
    @Environment(AppState.self) private var state
    @State private var selectedOption: String? = nil
    @State private var questionIndex: Int = 0

    private var question: Question {
        MorningData.questions[questionIndex]
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 32) {
                progressBar
                    .padding(.top, 16)

                Text(question.text)
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                VStack(spacing: 12) {
                    ForEach(question.options, id: \.text) { option in
                        optionButton(option)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .onChange(of: state.answers.count) { _, newCount in
            if newCount < MorningData.questions.count {
                selectedOption = nil
                questionIndex = newCount
            }
        }
    }

    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(0..<MorningData.questions.count, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .frame(height: 4)
                    .foregroundStyle(i <= questionIndex ? Color.white : Color.white.opacity(0.2))
            }
        }
    }

    private func optionButton(_ option: Option) -> some View {
        let isSelected = selectedOption == option.text

        return Button {
            guard selectedOption == nil else { return }
            selectedOption = option.text
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                state.recordAnswer(option.text)
            }
        } label: {
            HStack {
                Text(option.text)
                    .foregroundStyle(isSelected ? .black : .white)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.white : Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(selectedOption != nil)
    }
}
