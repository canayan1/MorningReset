import Foundation
import AuthenticationServices

extension AppState {

    func handleAppleSignIn(result: ASAuthorization) {
        guard let credential = result.credential as? ASAuthorizationAppleIDCredential else { return }
        let id = credential.user
        let name = [credential.fullName?.givenName, credential.fullName?.familyName]
            .compactMap { $0 }.joined(separator: " ")
        userAppleID = id
        UserDefaults.standard.set(id, forKey: UDKey.appleUserID)
        if !name.isEmpty {
            userName = name
            UserDefaults.standard.set(name, forKey: UDKey.appleUserName)
        }
    }

    func signOut() {
        userAppleID = nil
        userName = nil
        UserDefaults.standard.removeObject(forKey: UDKey.appleUserID)
        UserDefaults.standard.removeObject(forKey: UDKey.appleUserName)
    }
}
