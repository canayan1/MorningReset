import SwiftUI

struct MonthlyStoryView: View {
    @Environment(AppState.self) private var appState
    @State private var appeared = false

    private var lastMonthComponents: (year: Int, month: Int)? {
        let cal = Calendar.current
        guard let lastMonth = cal.date(byAdding: .month, value: -1, to: Date()) else { return nil }
        let c = cal.dateComponents([.year, .month], from: lastMonth)
        guard let y = c.year, let m = c.month else { return nil }
        return (y, m)
    }

    private var story: String {
        guard let c = lastMonthComponents else { return "" }
        return MorningPagesStore.cachedStory(year: c.year, month: c.month) ?? ""
    }

    private var monthName: String {
        guard let c = lastMonthComponents,
              let date = Calendar.current.date(from: DateComponents(year: c.year, month: c.month))
        else { return "" }
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }

    private var entryCount: Int {
        guard let c = lastMonthComponents else { return 0 }
        return MorningPagesStore.entriesForMonth(year: c.year, month: c.month).count
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .center, spacing: 0) {

                Spacer()

                // Header
                VStack(alignment: .center, spacing: DS.Space.xs) {
                    Text(monthName.uppercased())
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(DS.textDim)
                        .kerning(1.4)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.35).delay(0.1), value: appeared)

                    Text(L10n.text(
                        en: "\(entryCount) mornings",
                        tr: "\(entryCount) sabah",
                        es: "\(entryCount) mañanas"
                    ))
                    .font(.system(.callout, design: .serif))
                    .foregroundStyle(DS.textDim)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.35).delay(0.2), value: appeared)
                }
                .frame(maxWidth: .infinity)

                Spacer().frame(height: DS.Space.xl)

                // Story text — scrollable
                ScrollView(showsIndicators: false) {
                    Text(story)
                        .font(.system(size: 19, weight: .regular, design: .serif))
                        .foregroundStyle(DS.textPrimary)
                        .lineSpacing(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)

                Spacer()

                // Back
                Button(L10n.text(en: "Back", tr: "Geri", es: "Volver")) {
                    appState.showPremiumHub()
                }
                .primaryCTA()
                .padding(.bottom, DS.Space.xl)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.35).delay(0.5), value: appeared)
            }
            .padding(.horizontal, DS.Space.lg)
        }
        .onAppear { appeared = true }
    }
}
