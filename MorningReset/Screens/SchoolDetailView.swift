import SwiftUI
import StoreKit

struct SchoolDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let school: SchoolContent

    @State private var playing: Routine? = nil
    @State private var expandedTeaching: String? = nil
    @State private var showSources = false
    @State private var tab: DetailTab = .practise

    private enum DetailTab: String, CaseIterable { case practise, inside
        var title: String { self == .practise ? "Practise" : "Inside" }
    }
    @State private var tierPrice: String? = nil
    @State private var completions = 0
    @State private var working = false
    @State private var errorText: String? = nil

    private var color: Color { SchoolPalette.color(school.id) }
    private var tier: EnergyTier { SchoolContentStore.tier(for: school.id) }
    private var unlocked: Bool { appState.isSchoolFullyUnlocked(school) }

    var body: some View {
        ZStack {
            AppBackground(intensity: 0.35)
            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.Space.lg) {
                    closeBar
                    header
                    tabPicker
                    if tab == .practise {
                        if !unlocked { lockCard }
                        routinesSection
                    } else {
                        overviewCard
                        teachingsSection
                        sourcesDisclosure
                    }
                }
                .padding(.horizontal, DS.Space.lg)
                .padding(.bottom, DS.Space.xxl)
            }
        }
        .task {
            completions = SchoolProgressStore.completions(school.id)
            if !unlocked, let p = await appState.tierProduct(tier) { tierPrice = p.displayPrice }
        }
        .sheet(item: $playing) { r in
            RoutinePlayerView(school: school, routine: r) {
                completions = SchoolProgressStore.completions(school.id)
            }
        }
    }

    private var closeBar: some View {
        HStack {
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DS.textDim).frame(width: 32, height: 32)
            }
            .accessibilityLabel("Close")
            .accessibilityIdentifier("school.close")
        }
        .padding(.top, DS.Space.md)
    }

    private var header: some View {
        VStack(spacing: DS.Space.sm) {
            // The photograph opens the tradition before a word is read.
            ZStack(alignment: .bottom) {
                Image(SchoolPalette.photo(school.id))
                    .resizable().scaledToFill()
                    .frame(height: 260)
                    .clipped()
                LinearGradient(colors: [.clear, DS.background.opacity(0.55), DS.background],
                               startPoint: .top, endPoint: .bottom)
                    .frame(height: 140)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 260)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .stroke(color.opacity(0.28), lineWidth: DS.hairline)
            )
            Text(school.name)
                .font(.system(size: 32, weight: .regular, design: .serif))
                .foregroundStyle(DS.textPrimary)
            if let sub = school.subtitle {
                Text(sub)
                    .font(.callout).foregroundStyle(DS.textSecondary)
                    .multilineTextAlignment(.center)
            }
            if let pron = school.pronunciation, !pron.isEmpty {
                Text(pron)
                    .font(.system(size: 11, design: .serif)).italic()
                    .foregroundStyle(DS.textDim)
            }
            HStack(spacing: 6) {
                badge(school.kind == .traditional ? "TRADITIONAL" : "EVIDENCE-BASED", color)
                badge("\(school.routines.count) ROUTINES", DS.textDim)
                if completions > 0 { badge("\(completions) DONE", tier.accent) }
            }
            .padding(.top, 2)

            if unlocked {
                if appState.activeSchoolID == school.id {
                    Label("Your current focus", systemImage: "checkmark.circle.fill")
                        .font(.callout).foregroundStyle(color).padding(.top, DS.Space.xs)
                } else {
                    Button("Make this my focus") {
                        appState.setActiveSchool(school.id); dismiss()
                    }
                    .primaryCTA().padding(.top, DS.Space.xs)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    /// Routines are what people came for — they lead. The teaching sits one tap away.
    private var tabPicker: some View {
        HStack(spacing: DS.Space.sm) {
            ForEach(DetailTab.allCases, id: \.self) { t in
                Button {
                    withAnimation(.easeOut(duration: 0.2)) { tab = t }
                } label: {
                    Text(t.title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(tab == t ? Color.white : DS.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(tab == t ? color : DS.surface.opacity(0.6))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(tab == t ? color : DS.border.opacity(0.7), lineWidth: DS.hairline))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func badge(_ t: String, _ c: Color) -> some View {
        Text(t).font(.system(size: 8, weight: .bold)).tracking(0.6)
            .foregroundStyle(c)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .overlay(Capsule().stroke(c.opacity(0.45), lineWidth: 1))
    }

    private var overviewCard: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text(school.overview)
                .font(.callout).foregroundStyle(DS.textSecondary).lineSpacing(3)
            if let origin = school.origin, !origin.isEmpty {
                Divider().overlay(DS.border)
                Text(origin)
                    .font(.caption).foregroundStyle(DS.textSecondary).lineSpacing(2)
            }
            Divider().overlay(DS.border)
            Text(school.framingNote)
                .font(.caption2).foregroundStyle(DS.textDim).lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dreamCard(radius: DS.Radius.lg, tint: color)
    }

    private var teachingsSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text("WHAT LIVES HERE")
                .font(.system(size: 11, weight: .semibold)).tracking(1.6).foregroundStyle(color)
            ForEach(school.teachings) { t in
                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        expandedTeaching = expandedTeaching == t.id ? nil : t.id
                    }
                } label: {
                    VStack(alignment: .leading, spacing: DS.Space.xs) {
                        HStack {
                            Text(t.title).font(.body.weight(.medium)).foregroundStyle(DS.textPrimary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: expandedTeaching == t.id ? "chevron.up" : "chevron.down")
                                .font(.system(size: 11, weight: .semibold)).foregroundStyle(DS.textDim)
                        }
                        if expandedTeaching == t.id {
                            Text(t.body).font(.callout).foregroundStyle(DS.textSecondary).lineSpacing(3)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .dreamCard(radius: DS.Radius.md, padding: DS.Space.md)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var routinesSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.lg) {
            ForEach(RoutineGroup.allCases, id: \.self) { g in
                let list = school.routines(in: g)
                if !list.isEmpty {
                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        Text(g.title.uppercased())
                            .font(.system(size: 11, weight: .semibold)).tracking(1.6)
                            .foregroundStyle(DS.textDim)
                        ForEach(list) { routineRow($0) }
                    }
                }
            }
        }
    }

    private func routineRow(_ r: Routine) -> some View {
        let open = appState.isRoutineUnlocked(r, in: school)
        return Button {
            if open { playing = r } else { Task { await unlock() } }
        } label: {
            HStack(spacing: DS.Space.md) {
                Image(systemName: open ? "play.circle.fill" : "lock.fill")
                    .font(.system(size: open ? 24 : 16))
                    .foregroundStyle(open ? color : DS.textDim)
                    .frame(width: 26)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Text(r.title).font(.body.weight(.medium)).foregroundStyle(DS.textPrimary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        if r.free {
                            Text("FREE").font(.system(size: 8, weight: .bold))
                                .foregroundStyle(DS.background)
                                .padding(.horizontal, 5).padding(.vertical, 2)
                                .background(color).clipShape(Capsule())
                        }
                    }
                    Text(r.purpose).font(.caption).foregroundStyle(DS.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 8) {
                        Text("\(r.minutes) min").font(.system(size: 10)).foregroundStyle(DS.textDim)
                        if (r.safety ?? "").isEmpty == false {
                            Label("safety note", systemImage: "exclamationmark.triangle")
                                .font(.system(size: 9)).foregroundStyle(DS.textDim)
                        }
                    }
                }
                Spacer()
            }
            .dreamCard(radius: DS.Radius.md, padding: DS.Space.md, tint: open ? color : nil)
            .opacity(open ? 1 : 0.72)
        }
        .buttonStyle(.plain)
    }

    private var lockCard: some View {
        let inTier = SchoolContentStore.all
            .filter { SchoolContentStore.tier(for: $0.id) == tier }
            .map(\.name).joined(separator: ", ")

        return VStack(spacing: DS.Space.sm) {
            Text(tier.title.uppercased())
                .font(.system(size: 10, weight: .semibold)).tracking(1.6)
                .foregroundStyle(tier.accent)

            // Guideline 3.1.2: title, duration and price per period, all visible
            // on the purchase screen itself.
            Text(tierPrice.map { "\($0) per month" } ?? "Monthly subscription")
                .font(.system(size: 22, weight: .regular, design: .serif))
                .foregroundStyle(DS.textPrimary)

            Text("Unlocks every routine in \(inTier).")
                .font(.caption).foregroundStyle(DS.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                Task { await unlock() }
            } label: {
                Text(working ? "Please wait…" : "Unlock \(tier.title)")
            }
            .primaryCTA().disabled(working)
            .padding(.top, DS.Space.xs)

            Text("Auto-renews monthly until cancelled. Cancel any time in Settings.")
                .font(.system(size: 10)).foregroundStyle(DS.textDim)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: DS.Space.md) {
                Button("Restore") { Task { await restore() } }
                Link("Terms of Use", destination: AppState.termsOfUseURL)
                Link("Privacy Policy", destination: AppState.privacyPolicyURL)
            }
            .font(.system(size: 10))
            .foregroundStyle(DS.textSecondary)
            .padding(.top, 2)

            Text("All-Access adds every other school, the night soundscapes and your full history.")
                .font(.system(size: 10)).foregroundStyle(DS.textDim)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, DS.Space.xs)

            Button("Or see All-Access") {
                dismiss()
                appState.paywallContext = .contextual
                appState.screen = .paywall
            }
            .font(.footnote).foregroundStyle(DS.accent)
            .padding(.top, DS.Space.xs)

            if let errorText {
                Text(errorText).font(.caption).foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .dreamCard(radius: DS.Radius.lg, tint: tier.accent)
    }

    private var sourcesDisclosure: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Button {
                withAnimation(.easeOut(duration: 0.2)) { showSources.toggle() }
            } label: {
                HStack {
                    Text("Sources (\(school.sources.count))")
                        .font(.caption.weight(.medium)).foregroundStyle(DS.textDim)
                    Spacer()
                    Image(systemName: showSources ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .semibold)).foregroundStyle(DS.textDim)
                }
            }
            .buttonStyle(.plain)
            if showSources {
                ForEach(Array(school.sources.enumerated()), id: \.offset) { _, s in
                    Text("• \(s)").font(.system(size: 10)).foregroundStyle(DS.textDim).lineSpacing(2)
                }
            }
        }
        .padding(.top, DS.Space.sm)
    }

    @MainActor
    private func restore() async {
        working = true; errorText = nil
        let outcome = await appState.restorePurchases()
        await appState.refreshTierEntitlements()
        if outcome == .nothingToRestore { errorText = "Nothing to restore on this Apple Account." }
        working = false
    }

    @MainActor
    private func unlock() async {
        working = true; errorText = nil
        do { _ = try await appState.purchaseTier(tier) }
        catch { errorText = error.localizedDescription }
        working = false
    }
}
