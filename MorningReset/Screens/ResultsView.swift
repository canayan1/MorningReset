import SwiftUI

struct ResultsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 32) {
                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Your mode today")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    Text("Focus Mode")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Do this now")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    Text("Pick your one most important task before opening any app.")
                        .font(.body)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Watch out for")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    Text("Don't waste this window — avoid meetings or social media for the first hour.")
                        .font(.body)
                        .foregroundStyle(.white)
                }

                Spacer()

                Button("Continue") {
                    appState.showAction()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(.white)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.bottom, 48)
            }
            .padding(.horizontal, 24)
        }
    }
}
