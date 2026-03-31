import SwiftUI

// MARK: - Context

enum PaywallContext {
    case contextual  // triggered after strong pattern insight
    case periodic    // triggered after 21-day gap
    case manual      // opened from About
}

// MARK: - Copy model

private struct PaywallCopy {
    let headline: String
    let body: String?          // nil → show feature rows instead
    let primaryCTA: String
    let secondaryCTA: String

    static let contextual = PaywallCopy(
        headline: "There's more to this pattern.",
        body: "Premium shows you what's been showing up in your mornings — and gives you a moment to use it.",
        primaryCTA: "Unlock Premium",
        secondaryCTA: "Continue without"
    )

    static let periodic = PaywallCopy(
        headline: "A deeper reset exists.",
        body: nil,
        primaryCTA: "Unlock Premium",
        secondaryCTA: "Not now"
    )

    static let manual = PaywallCopy(
        headline: "Your reset, deeper.",
        body: "Pattern awareness, adaptive guidance, and a guided reflection — built into the same morning flow. All local.",
        primaryCTA: "Unlock Premium",
        secondaryCTA: "Maybe later"
    )
}

// MARK: - View

struct PaywallView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var context: PaywallContext = .contextual
    var isSheet: Bool = false

    private var copy: PaywallCopy {
        switch context {
        case .contextual: return .contextual
        case .periodic:   return .periodic
        case .manual:     return .manual
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

                if let body = copy.body {
                    Text(body)
                        .font(.callout)
                        .foregroundStyle(DS.textSecondary)
                        .lineSpacing(3)
                } else {
                    VStack(spacing: DS.Space.sm) {
                        featureRow("Pattern awareness over time")
                        featureRow("Adaptive morning guidance")
                        featureRow("Guided reflection pause")
                    }
                }

                Spacer()

                Text("No bad vibes. No negative noise.")
                    .font(.caption)
                    .foregroundStyle(DS.textDim)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, DS.Space.md)

                Button(copy.primaryCTA) {
                    appState.unlockPremium()
                    advance()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.accent)
                .foregroundStyle(DS.background)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Button(copy.secondaryCTA) {
                    advance()
                }
                .font(.subheadline)
                .foregroundStyle(DS.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .padding(.bottom, 32)
            }
            .padding(.horizontal, DS.Space.lg)
        }
        .onAppear {
            appState.onPaywallPresented()
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
