import SwiftUI

// MARK: - Design tokens (mimoza · warm morning minimal)
//
// Palette inspired by mimoza blossoms, warm peach light,
// soft apricot tones — inviting, gentle, never cold.

enum DS {
    // Surfaces
    static let background    = Color(red: 1.000, green: 0.976, blue: 0.949) // warm cream
    static let surface       = Color(red: 0.996, green: 0.953, blue: 0.906) // pale mimoza
    static let surfaceAlt    = Color(red: 0.988, green: 0.933, blue: 0.871) // soft apricot
    static let border        = Color(red: 0.933, green: 0.871, blue: 0.784) // warm sand
    static let divider       = Color(red: 0.961, green: 0.914, blue: 0.847) // light sand

    // Accents
    static let accent        = Color(red: 0.878, green: 0.557, blue: 0.200) // mimoza gold
    static let accentSoft    = Color(red: 0.949, green: 0.729, blue: 0.412) // soft amber
    static let accentInk     = Color(red: 0.612, green: 0.337, blue: 0.082) // deep honey

    // Text
    static let textPrimary   = Color(red: 0.157, green: 0.118, blue: 0.082) // espresso
    static let textSecondary = Color(red: 0.424, green: 0.369, blue: 0.318) // warm stone
    static let textDim       = Color(red: 0.620, green: 0.565, blue: 0.510) // driftwood

    // Mode colors (used by 14-day strip and accents)
    static let modeProtect   = Color(red: 0.682, green: 0.745, blue: 0.792) // soft sky-grey
    static let modeSteady    = Color(red: 0.949, green: 0.729, blue: 0.412) // soft amber
    static let modePush      = Color(red: 0.878, green: 0.557, blue: 0.200) // mimoza gold

    // Hairline width
    static let hairline: CGFloat = 0.5

    // Spacing scale — generous negative space
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
