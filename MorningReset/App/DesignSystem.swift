import SwiftUI

// MARK: - Design tokens (sakura · japanese minimal)
//
// Palette inspired by washi paper, sumi ink, and the muted pinks
// of the sakura season — desaturated, never sweet, never loud.

enum DS {
    // Surfaces
    static let background    = Color(red: 0.984, green: 0.965, blue: 0.957) // washi
    static let surface       = Color(red: 0.976, green: 0.929, blue: 0.929) // pale sakura
    static let surfaceAlt    = Color(red: 0.957, green: 0.898, blue: 0.902) // soft mochi pink
    static let border        = Color(red: 0.886, green: 0.804, blue: 0.812) // muted hairline
    static let divider       = Color(red: 0.929, green: 0.875, blue: 0.882) // even softer

    // Accents
    static let accent        = Color(red: 0.776, green: 0.443, blue: 0.510) // muted rose
    static let accentSoft    = Color(red: 0.910, green: 0.643, blue: 0.682) // tea-rose
    static let accentInk     = Color(red: 0.557, green: 0.231, blue: 0.314) // deep sakura

    // Text
    static let textPrimary   = Color(red: 0.106, green: 0.094, blue: 0.094) // sumi ink
    static let textSecondary = Color(red: 0.420, green: 0.376, blue: 0.376) // stone
    static let textDim       = Color(red: 0.647, green: 0.580, blue: 0.580) // mist

    // Mode colors (used by 14-day strip and accents)
    static let modeProtect   = Color(red: 0.682, green: 0.745, blue: 0.792) // soft sky-grey
    static let modeSteady    = Color(red: 0.910, green: 0.643, blue: 0.682) // tea-rose
    static let modePush      = Color(red: 0.776, green: 0.443, blue: 0.510) // muted rose

    // Hairline width — Japanese minimal favors 0.5pt over 1pt
    static let hairline: CGFloat = 0.5

    // Spacing scale — ma (間), generous negative space
    enum Space {
        static let xxs: CGFloat =  2
        static let xs:  CGFloat =  4
        static let sm:  CGFloat =  8
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 40
        static let xxl: CGFloat = 64
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
        overlay(Rectangle().stroke(color, lineWidth: DS.hairline))
    }

    func hairlineBottom(_ color: Color = DS.divider) -> some View {
        overlay(alignment: .bottom) {
            Rectangle()
                .fill(color)
                .frame(height: DS.hairline)
        }
    }
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
        .hairlineBorder()
    }
}
