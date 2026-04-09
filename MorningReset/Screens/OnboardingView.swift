import SwiftUI

struct OnboardingView: View {
    @AppStorage(UDKey.onboardingComplete) private var onboardingComplete = false
    @State private var page = 0

    private struct Slide {
        let title: LocalizedStringKey
        let subtitle: LocalizedStringKey
        let cta: LocalizedStringKey
    }

    private let slides: [Slide] = [
        Slide(
            title: "You wake up.\nYou reach for your phone.\nYou start scrolling.",
            subtitle: "It happens automatically.",
            cta: "Continue"
        ),
        Slide(
            title: "Tomorrow morning,\nyour phone will ring.",
            subtitle: "Not Instagram.\nNot the news.\nA single notification from here.",
            cta: "Continue"
        ),
        Slide(
            title: "Tap it instead\nof opening anything else.",
            subtitle: "Two minutes.\nOne small action.\nA different day begins.",
            cta: "Continue"
        ),
        Slide(
            title: "Start with a win.",
            subtitle: "We'll guide you.\nOne step at a time.",
            cta: "Get started"
        ),
    ]

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 20) {
                    Text(slides[page].title)
                        .font(DS.Typo.title)
                        .foregroundStyle(DS.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)

                    Text(slides[page].subtitle)
                        .font(.subheadline)
                        .foregroundStyle(DS.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .id(page)
                .transition(.opacity)
                .animation(.easeOut(duration: 0.2), value: page)
                .padding(.horizontal, 40)

                Spacer()

                HStack(spacing: 8) {
                    ForEach(0..<slides.count, id: \.self) { i in
                        Circle()
                            .fill(i == page ? DS.accent : DS.border)
                            .frame(width: 4, height: 4)
                    }
                }
                .animation(.easeOut(duration: 0.2), value: page)
                .padding(.bottom, DS.Space.lg)

                Button(slides[page].cta) {
                    if page < slides.count - 1 {
                        withAnimation(.easeOut(duration: 0.2)) { page += 1 }
                    } else {
                        Task {
                            _ = await AlarmManager.current.requestAuthorization()
                            await MainActor.run { onboardingComplete = true }
                        }
                    }
                }
                .font(.system(.body, design: .serif))
                .tracking(0.5)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.accent)
                .foregroundStyle(DS.background)
                .clipShape(Capsule())
                .padding(.horizontal, DS.Space.lg)
                .padding(.bottom, DS.Space.xl)
            }
        }
    }
}
