import SwiftUI

struct AlarmView: View {
    @Environment(AppState.self) private var appState
    @State private var showAbout = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 12) {
                    Text(Strings.Alarm.title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)

                    Text("Get up. Take two minutes.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                Button(Strings.Alarm.startButton) {
                    appState.startFlow()
                }
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(.white)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 32)

                Button("About") {
                    showAbout = true
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.25))
                .padding(.bottom, 48)
            }
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
    }
}
