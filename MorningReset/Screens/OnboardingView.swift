import SwiftUI

struct OnboardingView: View {
    @AppStorage("onboarding_complete") private var onboardingComplete = false
    @State private var page = 0

    private struct Slide {
        let title: String
        let subtitle: String
        let cta: String
    }

    private let slides: [Slide] = [
        Slide(
            title: "You wake up.\nYou reach for your phone.\nYou start scrolling.",
            subtitle: "It happens automatically.",
            cta: "Continue"
        ),
        Slide(
            title: "Instead of scrolling,\ndo one small thing.",
            subtitle: "That's your first win.",
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
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 20) {
                    Text(slides[page].title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    Text(slides[page].subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .id(page)
                .transition(.opacity)
                .animation(.easeOut(duration: 0.2), value: page)
                .padding(.horizontal, 40)

                Spacer()

                HStack(spacing: 6) {
                    ForEach(0..<slides.count, id: \.self) { i in
                        Circle()
                            .fill(i == page ? Color.white : Color.white.opacity(0.25))
                            .frame(width: 5, height: 5)
                    }
                }
                .animation(.easeOut(duration: 0.2), value: page)
                .padding(.bottom, 24)

                Button(slides[page].cta) {
                    if page < slides.count - 1 {
                        withAnimation(.easeOut(duration: 0.2)) { page += 1 }
                    } else {
                        onboardingComplete = true
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(.white)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}
