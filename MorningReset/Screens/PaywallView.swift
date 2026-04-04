import SwiftUI
import StoreKit

// MARK: - Context

enum PaywallContext {
    case onboarding   // soft entry, first-launch or About
    case contextual   // triggered after strong pattern insight
    case periodic     // triggered after 21-day gap
    case riseAndFlow  // triggered when non-premium taps Rise & Flow
}

// MARK: - Copy model

private struct PaywallCopy {
    let headline: String
    let body: String
    let features: [String]
    let primaryCTA: String
    let secondaryCTA: String

    static let onboarding = PaywallCopy(
        headline: "Start your mornings differently",
        body: "Take a moment before the day takes over.",
        features: [],
        primaryCTA: "Try Morning Reset",
        secondaryCTA: "Continue"
    )

    static let contextual = PaywallCopy(
        headline: "Go deeper with your mornings",
        body: "Notice your patterns.\nAdjust your direction.\nBuild consistency over time.",
        features: ["Pattern-based insights", "Adaptive daily guidance", "Extended reset flow"],
        primaryCTA: "Start free trial",
        secondaryCTA: "Continue free"
    )

    static let periodic = PaywallCopy(
        headline: "Want to go deeper?",
        body: "Unlock a more personalized reset experience.",
        features: [],
        primaryCTA: "Learn more",
        secondaryCTA: "Not now"
    )

    static let riseAndFlow = PaywallCopy(
        headline: "Move with intention",
        body: "A guided 5-minute morning movement flow.\nAnimated cues. No equipment. No rush.",
        features: ["Rise & Flow — 5 min guided movement", "Adaptive mobility flows by season", "Animated stick figure cues"],
        primaryCTA: "Start free trial",
        secondaryCTA: "Not now"
    )
}

// MARK: - View

struct PaywallView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var context: PaywallContext = .contextual
    var isSheet: Bool = false

    @State private var purchaseError: String? = nil
    @State private var isLoading: Bool = false

    private var copy: PaywallCopy {
        switch context {
        case .onboarding:  return .onboarding
        case .contextual:  return .contextual
        case .periodic:    return .periodic
        case .riseAndFlow: return .riseAndFlow
        }
    }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("MORNING RESET PREMIUM")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(DS.textDim)
                        .kerning(1.2)

                    Text(copy.headline)
                        .font(.title2.bold())
                        .foregroundStyle(DS.textPrimary)
                }

                Spacer().frame(height: DS.Space.lg)

                Text(copy.body)
                    .font(.callout)
                    .foregroundStyle(DS.textSecondary)
                    .lineSpacing(3)

                if !copy.features.isEmpty {
                    Spacer().frame(height: DS.Space.md)
                    VStack(spacing: DS.Space.sm) {
                        ForEach(copy.features, id: \.self) { featureRow($0) }
                    }
                }

                Spacer()

                Text("No bad vibes. No negative noise.")
                    .font(.caption)
                    .foregroundStyle(DS.textDim)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, DS.Space.md)

                if let error = purchaseError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, DS.Space.sm)
                }

                Button {
                    isLoading = true
                    purchaseError = nil
                    Task {
                        do {
                            try await appState.purchase()
                            advance()
                        } catch {
                            purchaseError = "Something went wrong. Please try again."
                        }
                        isLoading = false
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(DS.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                    } else {
                        Text(copy.primaryCTA)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                    }
                }
                .background(DS.accent)
                .foregroundStyle(DS.background)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .disabled(isLoading)

                Button(copy.secondaryCTA) {
                    advance()
                }
                .font(.subheadline)
                .foregroundStyle(DS.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)

                Button("Restore Purchases") {
                    isLoading = true
                    purchaseError = nil
                    Task {
                        await appState.restorePurchases()
                        isLoading = false
                        if appState.isPremium { advance() }
                    }
                }
                .font(.caption)
                .foregroundStyle(DS.textDim)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 32)
                .disabled(isLoading)
            }
            .padding(.horizontal, DS.Space.lg)
        }
        .onAppear {
            if context != .riseAndFlow {
                appState.onPaywallPresented()
            }
        }
    }

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: DS.Space.sm) {
            Rectangle()
                .fill(DS.accent)
                .frame(width: 2, height: 14)
            Text(text)
                .font(.callout)
                .foregroundStyle(DS.textPrimary)
            Spacer()
        }
    }

    private func advance() {
        if isSheet {
            dismiss()
        } else {
            appState.advanceFromPaywall()
        }
    }
}
