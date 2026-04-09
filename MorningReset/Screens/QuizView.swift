import SwiftUI

struct QuizView: View {
    @Environment(AppState.self) private var appState
    @State private var selections: [Int: String] = [:]

    private var questions: [Question] { MorningData.questions }

    private var allAnswered: Bool { selections.count == questions.count }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DS.Space.lg) {

                        Text("How are you\nthis morning?")
                            .font(DS.Typo.title)
                            .foregroundStyle(DS.textPrimary)
                            .lineSpacing(4)
                            .padding(.top, DS.Space.xl)

                        ForEach(Array(questions.enumerated()), id: \.offset) { i, q in
                            questionCard(index: i, question: q)
                        }
                    }
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.bottom, 100)
                }

                VStack(spacing: 0) {
                    Divider().foregroundStyle(DS.divider)
                    Button("Done") {
                        submitAll()
                    }
                    .font(.system(.body, design: .serif))
                    .tracking(0.5)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(allAnswered ? DS.accent : DS.border)
                    .foregroundStyle(allAnswered ? DS.background : DS.textDim)
                    .clipShape(Capsule())
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.vertical, DS.Space.md)
                    .animation(.easeOut(duration: 0.2), value: allAnswered)
                }
                .background(DS.background)
                .disabled(!allAnswered)
            }
        }
        .onAppear {
            appState.resetInactivityTimer()
        }
    }

    private func questionCard(index: Int, question: Question) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.sm + 4) {
            Text(question.text)
                .font(.system(.body, design: .serif))
                .foregroundStyle(DS.textPrimary)

            HStack(spacing: DS.Space.sm) {
                ForEach(question.options, id: \.self) { option in
                    let selected = selections[index] == option
                    Button {
                        withAnimation(.easeOut(duration: 0.15)) {
                            selections[index] = option
                        }
                        appState.resetInactivityTimer()
                    } label: {
                        Text(option)
                            .font(.subheadline.weight(selected ? .semibold : .regular))
                            .foregroundStyle(selected ? DS.background : DS.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selected ? DS.accent : DS.surface)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(selected ? DS.accent : DS.border, lineWidth: DS.hairline))
                    }
                }
            }
        }
        .padding(DS.Space.md)
        .background(DS.surface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func submitAll() {
        for i in 0..<questions.count {
            if let answer = selections[i] {
                appState.recordAnswer(answer)
            }
        }
        appState.showWeeklyAffirmation()
    }
}
