import Foundation
import StoreKit

enum PremiumPurchaseOutcome {
    case purchased
    case cancelled
    case pending
}

enum PremiumRestoreOutcome {
    case restored
    case nothingToRestore
    case failed
}

private enum PremiumStoreError: LocalizedError {
    case productUnavailable
    case verificationFailed

    var errorDescription: String? {
        switch self {
        case .productUnavailable:
            return L10n.text(en: "Subscription details are unavailable right now.", tr: "Abonelik ayrıntıları şu anda kullanılamıyor.", es: "Los detalles de la suscripción no están disponibles ahora mismo.")
        case .verificationFailed:
            return L10n.text(en: "Apple could not verify the purchase.", tr: "Apple satın almayı doğrulayamadı.", es: "Apple no pudo verificar la compra.")
        }
    }
}

extension AppState {

    static let productID = "com.canayan.MorningReset.premium.annual"
    static let monthlyProductID = "com.canayan.MorningReset.premium.monthly"
    static let privacyPolicyURL = URL(string: "https://canayan1.github.io/MorningReset/privacy-policy.html")!
    static let supportURL = URL(string: "https://canayan1.github.io/MorningReset/support.html")!
    static let termsOfUseURL = URL(string: "https://canayan1.github.io/MorningReset/terms.html")!
    static let manageSubscriptionsURL = URL(string: "https://apps.apple.com/account/subscriptions")!

    func onPaywallPresented() {
        guard !paywallShownThisFlow else { return }
        paywallShownThisFlow = true
        paywallLastShownDate = Date().timeIntervalSince1970
        UserDefaults.standard.set(paywallLastShownDate, forKey: UDKey.paywallLastShown)
    }

    func advanceFromPaywall() {
        if paywallContext == .riseAndFlow {
            screen = .premiumHub
        } else {
            screen = .action
        }
    }

    func unlockPremium() {
        isPremium = true
        UserDefaults.standard.set(true, forKey: UDKey.premiumUnlocked)
    }

    func clearPremium() {
        isPremium = false
        UserDefaults.standard.set(false, forKey: UDKey.premiumUnlocked)
    }

    func recordManualPaywallShown() {
        paywallLastShownDate = Date().timeIntervalSince1970
        paywallShownThisFlow = true
        UserDefaults.standard.set(paywallLastShownDate, forKey: UDKey.paywallLastShown)
    }

    @MainActor
    func premiumProduct() async -> Product? {
        try? await Product.products(for: [Self.productID]).first
    }

    /// Both subscription plans, annual first.
    @MainActor
    func subscriptionProducts() async -> [Product] {
        let products = (try? await Product.products(for: [Self.productID, Self.monthlyProductID])) ?? []
        return products.sorted { lhs, rhs in
            let l = (lhs.subscription?.subscriptionPeriod.unit == .year) ? 0 : 1
            let r = (rhs.subscription?.subscriptionPeriod.unit == .year) ? 0 : 1
            return l < r
        }
    }

    @MainActor
    func purchase(_ product: Product) async throws -> PremiumPurchaseOutcome {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                unlockPremium()
                return .purchased
            case .unverified:
                throw PremiumStoreError.verificationFailed
            }
        case .userCancelled:
            return .cancelled
        case .pending:
            return .pending
        @unknown default:
            return .cancelled
        }
    }

    @MainActor
    func purchase() async throws -> PremiumPurchaseOutcome {
        guard let product = await premiumProduct() else {
            throw PremiumStoreError.productUnavailable
        }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                unlockPremium()
                return .purchased
            case .unverified:
                throw PremiumStoreError.verificationFailed
            }
        case .userCancelled:
            return .cancelled
        case .pending:
            return .pending
        @unknown default:
            return .cancelled
        }
    }

    @MainActor
    func restorePurchases() async -> PremiumRestoreOutcome {
        do {
            try await AppStore.sync()
        } catch {
            return .failed
        }

        if await hasActivePremiumEntitlement() {
            unlockPremium()
            return .restored
        }

        return .nothingToRestore
    }

    @MainActor
    func checkEntitlement() async {
        if await hasActivePremiumEntitlement() {
            unlockPremium()
        } else {
            clearPremium()
        }
        await refreshTierEntitlements()
    }

    @MainActor
    private func hasActivePremiumEntitlement() async -> Bool {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard transaction.productID == Self.productID else { continue }
            guard transaction.revocationDate == nil else { continue }
            if let expiration = transaction.expirationDate, expiration <= Date() {
                continue
            }
            return true
        }
        return false
    }
}
