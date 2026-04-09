import SwiftUI

struct ActionView: View {
    @Environment(AppState.self)      private var appState
    @Environment(InsightEngine.self) private var insightEngine
    @State private var panel: Panel = .main

    private enum Panel { case main, learn, action }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()
            switch panel {
            case .main:   mainPanel
            case .learn:  learnPanel
            case .action: actionPanel
            }
        }
    }

    // MARK: - Main

    private var mainPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(spacing: DS.Space.md) {
                aiInsightBlock

                sectionCard(
                    label: "ONE MORE STEP",
                    preview: ActionContent.todayBonusAction
                ) { panel = .action }

                if appState.isPremium {
                    mobilityCard
                }
            }

            Spacer()

            pastDaysStrip
                .padding(.bottom, DS.Space.sm)

            doneButton
        }
        .padding(.horizontal, DS.Space.lg)
    }

    // MARK: - Past 14 days

    private var pastDaysStrip: some View {
        let entries = DailyEntryStore.load()
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let byDay: [Date: String] = Dictionary(
            uniqueKeysWithValues: entries.map { (cal.startOfDay(for: $0.date), $0.mode) }
        )
        let days: [(date: Date, mode: String?)] = (0..<14).reversed().map { offset in
            let d = cal.date(byAdding: .day, value: -offset, to: today)!
            return (d, byDay[d])
        }
        return VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text("LAST 14 DAYS")
                .font(DS.Typo.micro)
                .foregroundStyle(DS.textDim)
                .kerning(1.4)
            HStack(spacing: 6) {
                ForEach(days, id: \.date) { day in
                    Circle()
                        .fill(color(for: day.mode))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func color(for mode: String?) -> Color {
        switch mode {
        case "protect": return DS.modeProtect
        case "steady":  return DS.modeSteady
        case "push":    return DS.modePush
        default:        return DS.divider
        }
    }

    // MARK: - Learn

    private var learnPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            backButton

            Spacer().frame(height: DS.Space.lg)

            InfoCard(label: "INSIGHT", value: ActionContent.todayInsight)

            Spacer()

            doneButton
        }
        .padding(.horizontal, DS.Space.lg)
    }

    // MARK: - Action

    private var actionPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            backButton

            Spacer().frame(height: DS.Space.lg)

            InfoCard(label: "ONE MORE STEP", value: ActionContent.todayBonusAction)

            Spacer()

            doneButton
        }
        .padding(.horizontal, DS.Space.lg)
    }

    // MARK: - Shared

    private var backButton: some View {
        Button { panel = .main } label: {
            Label(Strings.Action.backButton, systemImage: "chevron.left")
                .font(.subheadline)
                .foregroundStyle(DS.textSecondary)
        }
    }

    private var doneButton: some View {
        Button("Done") { appState.showFlowCheckout() }
            .font(.subheadline)
            .foregroundStyle(DS.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.bottom, 32)
    }

    @ViewBuilder
    private var aiInsightBlock: some View {
        if appState.isPremium {
            if insightEngine.isRefreshing {
                AIInsightCardView(
                    eyebrow: "YOUR INSIGHT",
                    text: "",
                    isLoading: true
                )
            } else if let insight = insightEngine.dailyInsight {
                AIInsightCardView(
                    eyebrow: "YOUR INSIGHT",
                    text: insight.reflection,
                    isAIGenerated: insight.isAIGenerated
                )
            } else {
                sectionCard(label: "INSIGHT", preview: ActionContent.todayInsight) { panel = .learn }
            }
        } else {
            sectionCard(label: "INSIGHT", preview: ActionContent.todayInsight) { panel = .learn }
        }
    }

    private var mobilityCard: some View {
        let flow = MobilityLibrary.flow()
        return Button { appState.openMobilityFlow() } label: {
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text("MOBILITY · 5 MIN")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(DS.textSecondary)
                    .kerning(1.2)
                Text(flow.title)
                    .font(.callout)
                    .foregroundStyle(DS.textPrimary)
                    .multilineTextAlignment(.leading)
                Text(flow.subtitle)
                    .font(.caption)
                    .foregroundStyle(DS.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DS.Space.md)
            .background(DS.surface)
            .overlay(Rectangle().stroke(DS.border, lineWidth: 1))
        }
    }

    private func sectionCard(label: String, preview: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(DS.textSecondary)
                    .kerning(1.2)
                Text(preview)
                    .font(.callout)
                    .foregroundStyle(DS.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DS.Space.md)
            .background(DS.surface)
            .overlay(Rectangle().stroke(DS.border, lineWidth: 1))
        }
    }
}
