import SwiftUI

struct QuizView: View {
    @Environment(AppState.self) private var appState
    @State private var stack: [QuizNode] = []
    @State private var selectedIdx: Int? = nil
    @State private var isAdvancing = false
    @State private var advanceTask: Task<Void, Never>?
    @State private var didInit = false

    private var current: QuizNode { stack.last ?? MorningData.quizRoot }
    private let maxDepth = 2

    var body: some View {
        ZStack {
            AuraBackground(path: appState.activePath, intensity: 0.4)

            VStack(spacing: 0) {

                // Progress dots + Skip
                HStack {
                    HStack(spacing: 6) {
                        ForEach(0..<maxDepth, id: \.self) { i in
                            Circle()
                                .fill(i < stack.count ? DS.accent : DS.border)
                                .frame(width: 5, height: 5)
                                .animation(.easeOut(duration: 0.2), value: stack.count)
                        }
                    }
                    Spacer()
                    Button(L10n.text(en: "Skip", tr: "Atla", es: "Omitir")) {
                        appState.resolveQuiz(mode: .steady)
                    }
                    .font(.subheadline)
                    .foregroundStyle(DS.textDim)
                }
                .padding(.top, DS.Space.xl)
                .padding(.horizontal, DS.Space.lg)

                Spacer()

                Image(systemName: appState.activePath?.symbol ?? "moon.stars.fill")
                    .font(.system(size: 52, weight: .ultraLight))
                    .foregroundStyle(DS.accent.opacity(0.65))
                    .padding(.bottom, DS.Space.xl)

                VStack(spacing: DS.Space.lg) {
                    Text(current.text)
                        .font(.system(size: 26, weight: .regular, design: .serif))
                        .foregroundStyle(DS.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.horizontal, DS.Space.lg)
                        .id(stack.count)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.22), value: stack.count)

                    VStack(spacing: DS.Space.sm) {
                        ForEach(current.branches.indices, id: \.self) { i in
                            branchButton(current.branches[i], index: i)
                        }
                    }
                    .padding(.horizontal, DS.Space.lg)
                    .id(stack.count)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.22), value: stack.count)
                }

                Spacer()
            }
        }
        .accessibilityIdentifier("quiz.screen")
        .contentShape(Rectangle())
        .simultaneousGesture(TapGesture().onEnded { appState.resetInactivityTimer() })
        .onAppear {
            if !didInit {
                didInit = true
                stack = [MorningData.quizRoot]
            }
            appState.resetInactivityTimer()
        }
        .onDisappear { advanceTask?.cancel() }
    }

    private func branchButton(_ branch: QuizBranch, index: Int) -> some View {
        let isSelected = selectedIdx == index
        return Button {
            submit(branch, at: index)
        } label: {
            HStack(spacing: DS.Space.md) {
                Image(systemName: branch.icon)
                    .font(.system(size: 15))
                    .foregroundStyle(isSelected ? DS.background : DS.accent)
                    .frame(width: 24)
                Text(branch.label)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(isSelected ? DS.background : DS.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, DS.Space.md)
            .background(isSelected ? DS.accent : DS.surface)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(isSelected ? DS.accent : DS.border, lineWidth: DS.hairline))
        }
        .disabled(isAdvancing)
        .animation(.easeOut(duration: 0.18), value: isSelected)
        .accessibilityIdentifier("quiz.branch.\(stack.count).\(index)")
    }

    private func submit(_ branch: QuizBranch, at index: Int) {
        guard !isAdvancing else { return }
        isAdvancing = true
        selectedIdx = index
        appState.resetInactivityTimer()

        advanceTask?.cancel()
        advanceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            switch branch.next {
            case .node(let next):
                withAnimation(.easeInOut(duration: 0.22)) {
                    stack.append(next)
                    selectedIdx = nil
                    isAdvancing = false
                }
            case .result(let mode):
                appState.resolveQuiz(mode: mode)
            }
        }
    }
}
