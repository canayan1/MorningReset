import SwiftUI

struct MyWinsView: View {
    @Environment(AppState.self) private var appState

    @State private var sessions: [PracticeSession] = []
    @State private var editing: PracticeSession? = nil
    @State private var redoing: PracticeSession? = nil

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(spacing: DS.Space.xl) {
                        practiceProgressCard
                        recentSessionsSection
                    }
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.top, DS.Space.lg)
                    .padding(.bottom, DS.Space.tabInset)
                }
            }
        }
        .onAppear { sessions = PracticeLogStore.recent(appState.isPremium ? 200 : 7) }
        .sheet(item: $editing) { s in editSheet(s) }
        .sheet(item: $redoing) { s in
            if let (school, routine) = SchoolContentStore.lookup(schoolID: s.schoolID, routineID: s.routineID) {
                RoutinePlayerView(school: school, routine: routine) {
                    sessions = PracticeLogStore.recent(appState.isPremium ? 200 : 7)
                }
            }
        }
        .accessibilityIdentifier("myWins.screen")
    }

    // MARK: - Header

    private var header: some View {
        Text(L10n.text(en: "My Wins", tr: "Kazanımlarım", es: "Mis logros"))
            .font(DS.Typo.subtitle)
            .foregroundStyle(DS.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.top, DS.Space.md)
    }

    // MARK: - Practice progress (energy schools)

    private var schoolProgress: [(school: SchoolContent, count: Int)] {
        SchoolContentStore.all
            .map { ($0, SchoolProgressStore.completions($0.id)) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
    }

    private var totalSessions: Int { schoolProgress.reduce(0) { $0 + $1.count } }

    private var practiceProgressCard: some View {
        VStack(spacing: DS.Space.md) {
            Text(L10n.text(en: "YOUR PRACTICE", tr: "PRATİĞİN", es: "TU PRÁCTICA"))
                .font(.system(size: 10, weight: .semibold)).tracking(1.6)
                .foregroundStyle(DS.textDim)

            HStack(spacing: DS.Space.xl) {
                statBlock(value: "\(appState.streakCount)",
                          label: L10n.text(en: "day streak", tr: "günlük seri", es: "días seguidos"))
                statBlock(value: "\(totalSessions)",
                          label: L10n.text(en: "routines done", tr: "tamamlanan rutin", es: "rutinas hechas"))
                statBlock(value: "\(schoolProgress.count)",
                          label: L10n.text(en: "schools", tr: "okul", es: "escuelas"))
            }

            if schoolProgress.isEmpty {
                Text(L10n.text(en: "Run a routine from any school and it shows up here.",
                               tr: "Herhangi bir okuldan bir rutin yap, burada görünsün.",
                               es: "Haz una rutina de cualquier escuela y aparecerá aquí."))
                    .font(.caption).foregroundStyle(DS.textSecondary)
                    .multilineTextAlignment(.center)
            } else {
                VStack(spacing: DS.Space.sm) {
                    ForEach(schoolProgress.prefix(5), id: \.school.id) { entry in
                        HStack(spacing: DS.Space.sm) {
                            Image(systemName: SchoolPalette.symbol(entry.school.id))
                                .font(.system(size: 13))
                                .foregroundStyle(SchoolPalette.color(entry.school.id))
                                .frame(width: 20)
                            Text(entry.school.name)
                                .font(.caption).foregroundStyle(DS.textPrimary)
                            Spacer()
                            Text("\(entry.count)")
                                .font(.caption.weight(.semibold).monospacedDigit())
                                .foregroundStyle(DS.textSecondary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DS.Space.lg)
        .background(DS.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(DS.border, lineWidth: DS.hairline))
    }

    private func statBlock(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 30, weight: .thin, design: .serif))
                .monospacedDigit().foregroundStyle(DS.textPrimary)
            Text(label)
                .font(.system(size: 9)).foregroundStyle(DS.textDim)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Recent practices (review, edit, redo)

    @ViewBuilder
    private var recentSessionsSection: some View {
        if !sessions.isEmpty {
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                Text(L10n.text(en: "RECENT PRACTICES", tr: "SON PRATİKLER", es: "PRÁCTICAS RECIENTES"))
                    .font(.system(size: 10, weight: .semibold)).tracking(1.6)
                    .foregroundStyle(DS.textDim)

                ForEach(sessions) { s in sessionRow(s) }

                if !appState.isPremium, PracticeLogStore.all().count > sessions.count {
                    Button {
                        appState.paywallContext = .contextual
                        appState.screen = .paywall
                    } label: {
                        HStack(spacing: DS.Space.sm) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 15)).foregroundStyle(DS.accent)
                            Text(L10n.text(en: "See your full history with All-Access",
                                           tr: "Tüm geçmişini All-Access ile gör",
                                           es: "Ve tu historial completo con All-Access"))
                                .font(.caption).foregroundStyle(DS.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                        .dreamCard(radius: DS.Radius.md, padding: DS.Space.md)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func sessionRow(_ s: PracticeSession) -> some View {
        let color = SchoolPalette.color(s.schoolID)
        let schoolName = SchoolContentStore.school(s.schoolID)?.name ?? ""
        return HStack(spacing: DS.Space.md) {
            Image(systemName: s.outcome.symbol)
                .font(.system(size: 18))
                .foregroundStyle(s.outcome.feedsOrb ? color : DS.textDim)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(s.routineTitle)
                    .font(.body.weight(.medium)).foregroundStyle(DS.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(schoolName) · \(s.date.formatted(date: .abbreviated, time: .shortened))")
                    .font(.system(size: 10)).foregroundStyle(DS.textDim)
                    .fixedSize(horizontal: false, vertical: true)
                if !s.outcome.feedsOrb {
                    Text(s.outcome.title)
                        .font(.system(size: 10, weight: .medium)).foregroundStyle(DS.textSecondary)
                }
                if let note = s.note, !note.isEmpty {
                    Text(note).font(.caption).foregroundStyle(DS.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer()

            Menu {
                Button {
                    redoing = s
                } label: {
                    Label(L10n.text(en: "Do it again", tr: "Yeniden yap", es: "Hazlo otra vez"), systemImage: "arrow.clockwise")
                }
                Button {
                    editing = s
                } label: {
                    Label(L10n.text(en: "Edit", tr: "Düzenle", es: "Editar"), systemImage: "slider.horizontal.3")
                }
                Divider()
                Button(role: .destructive) {
                    PracticeLogStore.delete(s.id)
                    appState.invalidateStreakCache()
                    sessions = PracticeLogStore.recent(appState.isPremium ? 200 : 7)
                } label: {
                    Label(L10n.text(en: "Delete", tr: "Sil", es: "Eliminar"), systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 17)).foregroundStyle(DS.textDim)
                    .frame(width: 34, height: 34).contentShape(Rectangle())
            }
            .accessibilityLabel(L10n.text(en: "Session options", tr: "Seans seçenekleri", es: "Opciones de sesión"))
        }
        .dreamCard(radius: DS.Radius.md, padding: DS.Space.md, tint: s.outcome.feedsOrb ? color : nil)
    }

    private func editSheet(_ session: PracticeSession) -> some View {
        NavigationStack {
            ZStack {
                AppBackground(intensity: 0.3)
                VStack(spacing: DS.Space.lg) {
                    Text(session.routineTitle)
                        .font(.system(size: 24, weight: .regular, design: .serif))
                        .foregroundStyle(DS.textPrimary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(L10n.text(en: "How did it actually go?", tr: "Gerçekte nasıl geçti?", es: "¿Cómo fue realmente?"))
                        .font(.callout).foregroundStyle(DS.textSecondary)

                    VStack(spacing: DS.Space.sm) {
                        ForEach(PracticeOutcome.allCases) { outcome in
                            Button {
                                var updated = session
                                updated.outcome = outcome
                                PracticeLogStore.update(updated)
                                appState.invalidateStreakCache()
                                sessions = PracticeLogStore.recent(appState.isPremium ? 200 : 7)
                                editing = nil
                            } label: {
                                HStack(spacing: DS.Space.md) {
                                    Image(systemName: outcome.symbol)
                                        .font(.system(size: 18))
                                        .foregroundStyle(outcome == session.outcome ? DS.accent : DS.textDim)
                                    Text(outcome.title)
                                        .font(.body).foregroundStyle(DS.textPrimary)
                                    Spacer()
                                    if outcome == session.outcome {
                                        Image(systemName: "checkmark").font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(DS.accent)
                                    }
                                }
                                .dreamCard(radius: DS.Radius.md, padding: DS.Space.md)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text(L10n.text(en: "Only a full practice feeds your orb.",
                                   tr: "Orbunu yalnızca tam yapılan pratik besler.",
                                   es: "Solo una práctica completa alimenta tu orbe."))
                        .font(.caption).foregroundStyle(DS.textDim)
                        .multilineTextAlignment(.center)

                    Spacer()

                    Button(L10n.text(en: "Do it again", tr: "Yeniden yap", es: "Hazlo otra vez")) {
                        editing = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { redoing = session }
                    }
                    .primaryCTA()
                }
                .padding(.horizontal, DS.Space.lg)
                .padding(.top, DS.Space.xl)
                .padding(.bottom, DS.Space.xl)
            }
        }
    }
}
