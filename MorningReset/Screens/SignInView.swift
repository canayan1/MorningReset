import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("YOUR MORNINGS")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(DS.textDim)
                        .kerning(1.2)

                    Text("Sign in to save\nyour progress.")
                        .font(.title2.bold())
                        .foregroundStyle(DS.textPrimary)
                        .lineSpacing(3)
                }

                Spacer().frame(height: DS.Space.lg)

                Text("Your streak and session history stay on this device.\nSign in to identify your account across reinstalls.")
                    .font(.callout)
                    .foregroundStyle(DS.textSecondary)
                    .lineSpacing(3)

                Spacer()

                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success(let auth):
                        appState.handleAppleSignIn(result: auth)
                        dismiss()
                    case .failure:
                        break
                    }
                }
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Button("Not now") {
                    dismiss()
                }
                .font(.subheadline)
                .foregroundStyle(DS.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .padding(.bottom, 32)
            }
            .padding(.horizontal, DS.Space.lg)
        }
    }
}
