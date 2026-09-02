import SwiftUI

// MARK: - Design tokens (mimoza · warm morning minimal)
//
// Palette inspired by mimoza blossoms, warm peach light,
// soft apricot tones — inviting, gentle, never cold.

enum DS {
    // Surfaces — dawn blue, moonlit lavender: soft, low-contrast, restful
    static let background    = Color(red: 0.957, green: 0.965, blue: 0.988) // dawn mist
    static let surface       = Color(red: 0.929, green: 0.945, blue: 0.980) // soft blue haze
    static let surfaceAlt    = Color(red: 0.898, green: 0.918, blue: 0.965) // deeper haze
    static let border        = Color(red: 0.878, green: 0.898, blue: 0.945) // barely-there edge
    static let divider       = Color(red: 0.910, green: 0.925, blue: 0.961)

    // Accents — periwinkle: amethyst warmed toward a peaceful blue
    static let accent        = Color(red: 0.435, green: 0.451, blue: 0.780) // periwinkle
    static let accentSoft    = Color(red: 0.612, green: 0.647, blue: 0.878) // soft cornflower
    static let accentInk     = Color(red: 0.267, green: 0.278, blue: 0.529) // deep indigo

    // A calm blue used for restful surfaces and secondary accents
    static let calm          = Color(red: 0.412, green: 0.596, blue: 0.769) // still water
    static let calmSoft      = Color(red: 0.647, green: 0.769, blue: 0.878)

    // Text — slate blue rather than black: softer on the eye
    static let textPrimary   = Color(red: 0.153, green: 0.169, blue: 0.259) // deep slate
    static let textSecondary = Color(red: 0.365, green: 0.396, blue: 0.494) // muted slate
    static let textDim       = Color(red: 0.573, green: 0.604, blue: 0.686) // soft haze

    // Mode colors
    static let modeProtect   = Color(red: 0.412, green: 0.596, blue: 0.769)
    static let modeSteady    = Color(red: 0.612, green: 0.647, blue: 0.878)
    static let modePush      = Color(red: 0.435, green: 0.451, blue: 0.780)

    // Hairline width
    static let hairline: CGFloat = 0.5

    // Rounded, generous cards
    enum Radius {
        static let sm: CGFloat = 16
        static let md: CGFloat = 22
        static let lg: CGFloat = 28
    }

    // Spacing scale — generous negative space
    enum Space {
        static let xxs: CGFloat =  2
        static let xs:  CGFloat =  4
        static let sm:  CGFloat =  8
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 40
        static let xxl: CGFloat = 64

        /// Clears the floating tab bar, so the last row of a scrolling tab
        /// screen is never left half-readable underneath it.
        static let tabInset: CGFloat = 116
    }

    // Typography helpers
    enum Typo {
        static let display      = Font.system(.largeTitle, design: .serif).weight(.regular)
        static let title        = Font.system(.title2,     design: .serif).weight(.regular)
        static let subtitle     = Font.system(.title3,     design: .serif).weight(.regular)
        static let body         = Font.system(.body,       design: .default)
        static let label        = Font.system(size: 11, weight: .medium, design: .default)
        static let micro        = Font.system(size:  9, weight: .medium, design: .default)
    }
}

// MARK: - Hairline modifier

extension View {
    func hairlineBorder(_ color: Color = DS.border) -> some View {
        overlay(RoundedRectangle(cornerRadius: 12).stroke(color, lineWidth: DS.hairline))
    }

    func hairlineBottom(_ color: Color = DS.divider) -> some View {
        overlay(alignment: .bottom) {
            Rectangle()
                .fill(color)
                .frame(height: DS.hairline)
        }
    }
}

// MARK: - App background
//
// Single source of truth for screen backgrounds: a calm, living aura. Used
// everywhere instead of a flat fill so no screen ever shows a static, near-white
// surface. Drop in as the first child of a screen's root ZStack.

struct AppBackground: View {
    var path: EnergyPath? = nil
    var intensity: Double = 0.4
    var showEmblem: Bool = false

    var body: some View {
        AuraBackground(path: path, intensity: intensity, showEmblem: showEmblem)
    }
}

// MARK: - Cards
//
// One card treatment everywhere: soft translucent surface, generous radius,
// barely-there edge and a diffuse shadow. Keeps the app calm and consistent.

struct DreamCard: ViewModifier {
    var radius: CGFloat = DS.Radius.md
    var padding: CGFloat = DS.Space.lg
    var tint: Color? = nil

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(DS.surface.opacity(0.72))
                    .background {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(.ultraThinMaterial)
                    }
                    .overlay {
                        if let tint {
                            RoundedRectangle(cornerRadius: radius, style: .continuous)
                                .fill(LinearGradient(colors: [tint.opacity(0.10), .clear],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(DS.border.opacity(0.7), lineWidth: DS.hairline)
            }
            .shadow(color: DS.accentInk.opacity(0.06), radius: 14, y: 6)
    }
}

extension View {
    /// The app's one card treatment.
    func dreamCard(radius: CGFloat = DS.Radius.md,
                   padding: CGFloat = DS.Space.lg,
                   tint: Color? = nil) -> some View {
        modifier(DreamCard(radius: radius, padding: padding, tint: tint))
    }
}

// MARK: - Primary call-to-action

// One prominent, consistent primary button across the whole app: serif label,
// full-width gold capsule. Use `.primaryCTA()` on any Button.
struct PrimaryCTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .serif))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                LinearGradient(colors: [DS.accent, DS.accent.opacity(0.88)],
                               startPoint: .top, endPoint: .bottom)
            )
            .foregroundStyle(Color.white)
            .clipShape(Capsule())
            .shadow(color: DS.accent.opacity(configuration.isPressed ? 0.12 : 0.28), radius: 16, y: 7)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .animation(.easeOut(duration: 0.22), value: configuration.isPressed)
    }
}

extension View {
    func primaryCTA() -> some View { buttonStyle(PrimaryCTAButtonStyle()) }
}

// MARK: - InfoCard

struct InfoCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            Text(label.uppercased())
                .font(DS.Typo.label)
                .foregroundStyle(DS.textSecondary)
                .kerning(1.4)
            Text(value)
                .font(DS.Typo.body)
                .foregroundStyle(DS.textPrimary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, DS.Space.md)
        .padding(.horizontal, DS.Space.md)
        .background(DS.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .hairlineBorder()
    }
}
