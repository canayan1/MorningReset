import Foundation
import StoreKit

// Tier access + daily routine selection for the energy schools.
// All-Access (isPremium) unlocks everything; otherwise a school's routines are
// unlocked by owning its tier. Every school's one free routine is always open.

extension AppState {

    var activeSchool: SchoolContent {
        SchoolContentStore.school(activeSchoolID) ?? SchoolContentStore.all.first!
    }

    /// A routine the user picked for today, if they picked one. Stamped with the
    /// day it was chosen so it lapses on its own at midnight rather than needing
    /// to be cleared.
    struct TodaysPick: Codable {
        var schoolID: String
        var routineID: String
        var day: Int
    }

    private static func dayStamp(_ date: Date = Date()) -> Int {
        let cal = Calendar.current
        return (cal.component(.year, from: date) * 1000)
             + (cal.ordinality(of: .day, in: .year, for: date) ?? 0)
    }

    var todaysPick: TodaysPick? {
        get {
            guard let data = UserDefaults.standard.data(forKey: UDKey.todaysRoutinePick),
                  let pick = try? JSONDecoder().decode(TodaysPick.self, from: data),
                  pick.day == Self.dayStamp()
            else { return nil }
            return pick
        }
        set {
            if let newValue, let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: UDKey.todaysRoutinePick)
            } else {
                UserDefaults.standard.removeObject(forKey: UDKey.todaysRoutinePick)
            }
        }
    }

    /// Pin a routine as today's practice. Also makes its school active, so the
    /// rest of the home screen agrees with the card.
    func makeTodaysRoutine(schoolID: String, routineID: String) {
        setActiveSchool(schoolID)
        todaysPick = TodaysPick(schoolID: schoolID, routineID: routineID, day: Self.dayStamp())
        todaysPickRevision &+= 1
    }

    /// Today's routine: whatever the user pinned today, otherwise the active
    /// school's daily rotation.
    var todaysRoutine: Routine {
        _ = todaysPickRevision   // the pick is stored outside the model; this is what makes it observable
        if let pick = todaysPick,
           let (school, routine) = SchoolContentStore.lookup(schoolID: pick.schoolID,
                                                            routineID: pick.routineID),
           isRoutineUnlocked(routine, in: school) {
            return routine
        }
        let s = activeSchool
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let pool = isSchoolFullyUnlocked(s) ? s.routines : s.routines.filter(\.free)
        let list = pool.isEmpty ? s.routines : pool
        return list[(day - 1) % max(1, list.count)]
    }

    /// The energy reading still speaks the old three-path vocabulary. Resolve it
    /// into real school content so the check-in can offer something the rest of
    /// the app can actually play.
    func suggestedRoutine(for path: EnergyPath) -> (school: SchoolContent, routine: Routine)? {
        let schoolID: String
        switch path {
        case .reiki:      schoolID = "reiki"
        case .breathwork: schoolID = "breathing"
        case .qigong:     schoolID = "qigong"
        }
        guard let school = SchoolContentStore.school(schoolID) else { return nil }
        let playable = school.routines.first { isRoutineUnlocked($0, in: school) }
        guard let routine = playable ?? school.routines.first else { return nil }
        return (school, routine)
    }

    func setActiveSchool(_ id: String) {
        activeSchoolID = id
        UserDefaults.standard.set(id, forKey: UDKey.activeSchool)
    }

    func tier(for school: SchoolContent) -> EnergyTier {
        SchoolContentStore.tier(for: school.id)
    }

    /// True when every routine in the school is available.
    func isSchoolFullyUnlocked(_ school: SchoolContent) -> Bool {
        isPremium || ownedTiers.contains(SchoolContentStore.tier(for: school.id))
    }

    /// A single routine is playable if it's the free one or the school is unlocked.
    func isRoutineUnlocked(_ routine: Routine, in school: SchoolContent) -> Bool {
        routine.free || isSchoolFullyUnlocked(school)
    }

    func isTierOwned(_ tier: EnergyTier) -> Bool {
        isPremium || ownedTiers.contains(tier)
    }

    func unlockTier(_ tier: EnergyTier) {
        ownedTiers.insert(tier)
        UserDefaults.standard.set(ownedTiers.map(\.rawValue), forKey: UDKey.ownedTiers)
    }

    @MainActor
    func tierProduct(_ tier: EnergyTier) async -> Product? {
        try? await Product.products(for: [tier.productID]).first
    }

    @MainActor
    func purchaseTier(_ tier: EnergyTier) async throws -> PremiumPurchaseOutcome {
        guard let product = await tierProduct(tier) else {
            throw NSError(domain: "EnergyReset", code: 1,
                          userInfo: [NSLocalizedDescriptionKey:
                            L10n.text(en: "This tier isn't available right now.",
                                      tr: "Bu paket şu anda kullanılamıyor.",
                                      es: "Este paquete no está disponible ahora mismo.")])
        }
        switch try await product.purchase() {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await transaction.finish()
                unlockTier(tier)
                return .purchased
            }
            return .cancelled
        case .userCancelled: return .cancelled
        case .pending:       return .pending
        @unknown default:    return .cancelled
        }
    }

    /// Refresh tier entitlements from the App Store.
    @MainActor
    func refreshTierEntitlements() async {
        var owned: Set<EnergyTier> = []
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard transaction.revocationDate == nil else { continue }
            if let exp = transaction.expirationDate, exp <= Date() { continue }
            for tier in EnergyTier.allCases where transaction.productID == tier.productID {
                owned.insert(tier)
            }
        }
        ownedTiers = owned
        UserDefaults.standard.set(owned.map(\.rawValue), forKey: UDKey.ownedTiers)
    }
}
