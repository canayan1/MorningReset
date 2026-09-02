import SwiftUI

struct SchoolsView: View {
    @Environment(AppState.self) private var appState
    @State private var selected: SchoolContent? = nil

    private var schools: [SchoolContent] { SchoolContentStore.all }

    var body: some View {
        ZStack {
            AppBackground(intensity: 0.4)
            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.Space.lg) {
                    header
                    ForEach(EnergyTier.allCases) { tierSection($0) }
                    allAccessCard
                }
                .padding(.horizontal, DS.Space.lg)
                .padding(.top, DS.Space.xl)
                .padding(.bottom, DS.Space.tabInset)
            }
        }
        .sheet(item: $selected) { SchoolDetailView(school: $0) }
    }

    private var header: some View {
        VStack(spacing: DS.Space.xs) {
            Text("Ten Traditions")
                .font(.system(size: 32, weight: .light, design: .serif))
                .foregroundStyle(DS.textPrimary)
            Text("Kept whole, named as they are.\nOne practice free in each.")
                .font(.callout)
                .foregroundStyle(DS.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private func tierSection(_ tier: EnergyTier) -> some View {
        let list = schools.filter { SchoolContentStore.tier(for: $0.id) == tier }
        return VStack(alignment: .leading, spacing: DS.Space.sm) {
            HStack {
                Text(tier.title.uppercased())
                    .font(.system(size: 11, weight: .semibold)).tracking(1.6)
                    .foregroundStyle(tier.accent)
                Spacer()
                if appState.isTierOwned(tier) {
                    Label("Unlocked", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(tier.accent)
                }
            }
            ForEach(list) { schoolRow($0) }
        }
    }

    private func schoolRow(_ school: SchoolContent) -> some View {
        let unlocked = appState.isSchoolFullyUnlocked(school)
        let color = SchoolPalette.color(school.id)
        return Button { selected = school } label: {
            HStack(spacing: DS.Space.md) {
                ZStack {
                    Image(SchoolPalette.photo(school.id))
                        .resizable().scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(color.opacity(0.35), lineWidth: DS.hairline)
                        .frame(width: 64, height: 64)
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(school.name).font(.body.weight(.semibold)).foregroundStyle(DS.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        if !unlocked {
                            Text("1 FREE")
                                .font(.system(size: 8, weight: .bold)).tracking(0.4)
                                .foregroundStyle(DS.background)
                                .padding(.horizontal, 5).padding(.vertical, 2)
                                .background(color).clipShape(Capsule())
                        }
                    }
                    Text(school.subtitle ?? school.tagline)
                        .font(.caption).foregroundStyle(DS.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(school.routines.count) routines · \(school.kind == .traditional ? "Traditional" : "Evidence-based")")
                        .font(.system(size: 10)).foregroundStyle(DS.textDim)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold)).foregroundStyle(DS.textDim)
            }
            .dreamCard(radius: DS.Radius.lg, padding: DS.Space.md, tint: color)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("school.row.\(school.id)")
    }

    private var allAccessCard: some View {
        VStack(spacing: DS.Space.xs) {
            Text("ALL-ACCESS").font(.system(size: 10, weight: .semibold)).tracking(1.6).foregroundStyle(DS.accentInk)
            Text("All ten traditions").font(.system(.title3, design: .serif)).foregroundStyle(DS.textPrimary)
            Text(appState.isPremium
                 ? "You have All-Access."
                 : "All 250 practices, every soundscape, your full history, and everything we add next.")
                .font(.caption).foregroundStyle(DS.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            if !appState.isPremium {
                Button("See All-Access") {
                    appState.paywallContext = .contextual
                    appState.screen = .paywall
                }
                .primaryCTA()
                .padding(.top, DS.Space.sm)
            }
        }
        .frame(maxWidth: .infinity)
        .dreamCard(radius: DS.Radius.lg, tint: DS.accent)
    }
}
