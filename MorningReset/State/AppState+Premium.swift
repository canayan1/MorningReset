import Foundation
import StoreKit

extension AppState {

    private static let productID = "com.canayan.MorningReset.premium.annual"

    func onPaywallPresented() {
        guard !paywallShownThisFlow else { return }
        paywallShownThisFlow = true
        paywallLastShownDate = Date().timeIntervalSince1970
        UserDefaults.standard.set(paywallLastShownDate, forKey: UDKey.paywallLastShown)
    }

    func advanceFromPaywall() {
        screen = .action
    }

    func unlockPremium() {
        isPremium = true
        UserDefaults.standard.set(true, forKey: UDKey.premiumUnlocked)
    }

    func recordManualPaywallShown() {
        paywallLastShownDate = Date().timeIntervalSince1970
        paywallShownThisFlow = true
        UserDefaults.standard.set(paywallLastShownDate, forKey: UDKey.paywallLastShown)
    }

    @MainActor
    func purchase() async throws {
        guard let product = try await Product.products(for: [Self.productID]).first else { return }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await transaction.finish()
                unlockPremium()
            }
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }

    @MainActor
    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {
            return
        }
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.productID,
               transaction.revocationDate == nil {
                unlockPremium()
                return
            }
        }
    }

    @MainActor
    func checkEntitlement() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.productID,
               transaction.revocationDate == nil {
                unlockPremium()
                return
            }
        }
    }
}
