import SwiftUI

// Practice library — every routine across all ten schools in one place,
// searchable and filterable by length. Complements SchoolsView (browse by
// tradition) with a "just find me a practice" entry point.

struct LibraryView: View {
    @Environment(AppState.self) private var appState

    @State private var query = ""
    @State private var lengthFilter: LengthFilter = .any
    @State private var playing: (SchoolContent, Routine)? = nil

    private enum LengthFilter: String, CaseIterable, Identifiable {
        case any, short, medium, long
        var id: String { rawValue }
        var title: String {
            switch self {
            case .any:    return "Any"
            case .short:  return "≤5 min"
            case .medium: return "6–15"
            case .long:   return "15+"
            }
        }
        func matches(_ m: Int) -> Bool {
            switch self {
            case .any:    return true
            case .short:  return m <= 5
            case .medium: return m > 5 && m <= 15
            case .long:   return m > 15
            }
        }
    }

    private struct Item: Identifiable {
        let school: SchoolContent
        let routine: Routine
        var id: String { routine.id }
    }

    private var items: [Item] {
        let all = SchoolContentStore.all.flatMap { s in s.routines.map { Item(school: s, routine: $0) } }
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        return all.filter { i in
            lengthFilter.matches(i.routine.minutes) &&
            (q.isEmpty
             || i.routine.title.lowercased().contains(q)
             || i.routine.purpose.lowercased().contains(q)
             || i.school.name.lowercased().contains(q))
        }
    }

    var body: some View {
        ZStack {
            AppBackground(intensity: 0.4)
            VStack(spacing: 0) {
                header
                filters
                if items.isEmpty {
                    Spacer()
                    Text("Nothing matches that.")
                        .font(.callout).foregroundStyle(DS.textDim)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: DS.Space.sm) {
                            ForEach(items) { row($0) }
                        }
                        .padding(.horizontal, DS.Space.lg)
                        .padding(.bottom, DS.Space.tabInset)
                    }
                }
            }
        }
        .sheet(item: Binding(
            get: { playing.map { PlayPair(school: $0.0, routine: $0.1) } },
            set: { if $0 == nil { playing = nil } }
        )) { pair in
            RoutinePlayerView(school: pair.school, routine: pair.routine)
        }
    }

    private struct PlayPair: Identifiable {
        let school: SchoolContent; let routine: Routine
        var id: String { routine.id }
    }

    private var header: some View {
        VStack(spacing: DS.Space.xs) {
            Text("Practice Library")
                .font(.system(size: 30, weight: .light, design: .serif))
                .foregroundStyle(DS.textPrimary)
            Text("\(SchoolContentStore.all.reduce(0) { $0 + $1.routines.count }) routines across ten schools")
                .font(.caption).foregroundStyle(DS.textSecondary)
            HStack(spacing: DS.Space.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13)).foregroundStyle(DS.textDim)
                TextField("Search practices", text: $query)
                    .font(.callout).foregroundStyle(DS.textPrimary)
                    .autocorrectionDisabled()
                if !query.isEmpty {
                    Button { query = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14)).foregroundStyle(DS.textDim)
                    }
                }
            }
            .padding(.horizontal, DS.Space.md).padding(.vertical, 11)
            .background(DS.surface.opacity(0.7)).clipShape(Capsule())
            .overlay(Capsule().stroke(DS.border.opacity(0.7), lineWidth: DS.hairline))
            .padding(.top, DS.Space.sm)
        }
        .padding(.horizontal, DS.Space.lg)
        .padding(.top, DS.Space.xl)
    }

    private var filters: some View {
        HStack(spacing: DS.Space.sm) {
            ForEach(LengthFilter.allCases) { f in
                Button { lengthFilter = f } label: {
                    Text(f.title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(lengthFilter == f ? DS.background : DS.textSecondary)
                        .padding(.horizontal, DS.Space.md).padding(.vertical, 7)
                        .background(lengthFilter == f ? DS.accent : DS.surface)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(lengthFilter == f ? DS.accent : DS.border, lineWidth: DS.hairline))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, DS.Space.md)
    }

    private func row(_ i: Item) -> some View {
        let open = appState.isRoutineUnlocked(i.routine, in: i.school)
        let color = SchoolPalette.color(i.school.id)
        return Button {
            if open { playing = (i.school, i.routine) }
            else {
                appState.paywallContext = .contextual
                appState.screen = .paywall
            }
        } label: {
            HStack(spacing: DS.Space.md) {
                Image(systemName: open ? SchoolPalette.symbol(i.school.id) : "lock.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(open ? color : DS.textDim)
                    .frame(width: 26)
                VStack(alignment: .leading, spacing: 2) {
                    Text(i.routine.title).font(.body.weight(.medium))
                        .foregroundStyle(DS.textPrimary).multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(i.school.name) · \(i.routine.minutes) min")
                        .font(.system(size: 10)).foregroundStyle(DS.textDim)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                if i.routine.free {
                    Text("FREE").font(.system(size: 8, weight: .bold))
                        .foregroundStyle(DS.background)
                        .padding(.horizontal, 5).padding(.vertical, 2)
                        .background(color).clipShape(Capsule())
                }
            }
            .dreamCard(radius: DS.Radius.sm, padding: DS.Space.md, tint: open ? color : nil)
            .opacity(open ? 1 : 0.72)
        }
        .buttonStyle(.plain)
    }
}
