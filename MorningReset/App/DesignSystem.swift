import SwiftUI

// MARK: - Design tokens (warm minimal)

enum DS {
    static let background    = Color(red: 0.97, green: 0.95, blue: 0.91)  // warm cream
    static let surface       = Color(red: 0.92, green: 0.89, blue: 0.84)  // warm card fill
    static let border        = Color(red: 0.80, green: 0.75, blue: 0.68)  // warm line
    static let accent        = Color(red: 0.55, green: 0.40, blue: 0.22)  // amber
    static let textPrimary   = Color(red: 0.10, green: 0.09, blue: 0.07)  // near-black warm
    static let textSecondary = Color(red: 0.45, green: 0.40, blue: 0.35)  // warm grey
    static let textDim       = Color(red: 0.65, green: 0.58, blue: 0.50)  // faint warm

    enum Space {
        static let xs: CGFloat =  4
        static let sm: CGFloat =  8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
    }
}

// MARK: - InfoCard

struct InfoCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(DS.textSecondary)
                .kerning(1.2)
            Text(value)
                .font(.callout)
                .foregroundStyle(DS.textPrimary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, DS.Space.md)
        .padding(.horizontal, DS.Space.md)
        .background(DS.surface)
        .overlay(Rectangle().stroke(DS.border, lineWidth: 1))
    }
}
