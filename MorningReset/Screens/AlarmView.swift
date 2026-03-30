import SwiftUI

struct AlarmView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
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
                .padding(.bottom, 48)
            }
        }
    }
}
