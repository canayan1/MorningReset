import SwiftUI

struct MobilityFlowView: View {
    @Environment(AppState.self) private var appState
    @State private var hasStarted: Bool = false

    var body: some View {
        guard let flow = appState.currentMobilityFlow else {
            return AnyView(DS.background.ignoresSafeArea())
        }
        let move = flow.moves[appState.currentMobilityMoveIndex]
        let moveIndex = appState.currentMobilityMoveIndex
        let totalMoves = flow.moves.count
        let progress = moveFraction(move: move)

        return AnyView(
            ZStack {
                DS.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {

                    Spacer()

                    // MARK: Header
                    VStack(alignment: .leading, spacing: DS.Space.xs) {
                        Text("MOBILITY")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(DS.textDim)
                            .kerning(1.2)

                        Text(flow.title)
                            .font(.title2.bold())
                            .foregroundStyle(DS.textPrimary)

                        Text(flow.subtitle)
                            .font(.callout)
                            .foregroundStyle(DS.textSecondary)
                    }

                    Spacer().frame(height: DS.Space.lg)

                    // MARK: Animation area
                    ZStack {
                        DS.surface
                            .overlay(Rectangle().stroke(DS.border, lineWidth: 1))

                        VStack(spacing: DS.Space.sm) {
                            Circle()
                                .fill(DS.accent.opacity(0.12))
                                .frame(width: 44, height: 44)
                                .overlay(Circle().stroke(DS.accent.opacity(0.25), lineWidth: 1))
                                .scaleEffect(appState.isMobilityRunning ? 1.10 : 1.0)
                                .animation(
                                    appState.isMobilityRunning
                                        ? .easeInOut(duration: 2.4).repeatForever(autoreverses: true)
                                        : .easeOut(duration: 0.3),
                                    value: appState.isMobilityRunning
                                )

                            Text(move.animationName.replacingOccurrences(of: "_", with: " "))
                                .font(.system(size: 10, weight: .regular))
                                .foregroundStyle(DS.textDim)
                                .kerning(0.5)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)

                    Spacer().frame(height: DS.Space.lg)

                    // MARK: Move label + name
                    VStack(alignment: .leading, spacing: DS.Space.xs) {
                        Text("MOVE \(moveIndex + 1) OF \(totalMoves)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(DS.textDim)
                            .kerning(1.2)

                        Text(move.name)
                            .font(.title3.bold())
                            .foregroundStyle(DS.textPrimary)
                            .animation(.easeInOut(duration: 0.25), value: moveIndex)

                        Text(move.cue)
                            .font(.callout)
                            .foregroundStyle(DS.textSecondary)
                            .lineLimit(2)
                            .animation(.easeInOut(duration: 0.25), value: moveIndex)
                    }

                    Spacer().frame(height: DS.Space.lg)

                    // MARK: Countdown
                    Text(timeString)
                        .font(.system(size: 60, weight: .thin, design: .monospaced))
                        .foregroundStyle(DS.textPrimary)
                        .animation(.none, value: appState.mobilitySecondsRemaining)

                    Spacer().frame(height: DS.Space.md)

                    // MARK: Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(DS.surface)
                            Rectangle()
                                .fill(DS.accent)
                                .frame(width: geo.size.width * progress)
                                .animation(.linear(duration: 0.9), value: progress)
                        }
                        .overlay(Rectangle().stroke(DS.border, lineWidth: 0.5))
                    }
                    .frame(height: 3)

                    Spacer().frame(height: DS.Space.sm)

                    // MARK: Overall dots
                    overallProgress(total: totalMoves, current: moveIndex)

                    Spacer().frame(height: DS.Space.lg)

                    // MARK: Primary control
                    Button(action: primaryAction) {
                        Text(primaryLabel)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(DS.textPrimary)
                            .foregroundStyle(DS.background)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Spacer().frame(height: DS.Space.sm)

                    // MARK: Skip
                    if hasStarted {
                        Button {
                            appState.pauseMobility()
                            appState.advanceMobilityMove()
                        } label: {
                            Text("Skip →")
                                .font(.subheadline)
                                .foregroundStyle(DS.textDim)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                    }

                    Spacer()

                    // MARK: Exit
                    Button {
                        appState.pauseMobility()
                        appState.completeMobilityFlow()
                    } label: {
                        Text("Exit")
                            .font(.subheadline)
                            .foregroundStyle(DS.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .padding(.bottom, 32)
                    }
                }
                .padding(.horizontal, DS.Space.lg)
            }
        )
    }

    // MARK: - Helpers

    private var timeString: String {
        let s = appState.mobilitySecondsRemaining
        return s >= 60
            ? String(format: "%d:%02d", s / 60, s % 60)
            : "\(s)"
    }

    private func moveFraction(move: MobilityMove) -> CGFloat {
        guard move.duration > 0 else { return 1 }
        let elapsed = move.duration - appState.mobilitySecondsRemaining
        return CGFloat(elapsed) / CGFloat(move.duration)
    }

    private var primaryLabel: String {
        if !hasStarted { return "Begin" }
        return appState.isMobilityRunning ? "Pause" : "Resume"
    }

    private func primaryAction() {
        if !hasStarted {
            hasStarted = true
            appState.startMobility()
        } else if appState.isMobilityRunning {
            appState.pauseMobility()
        } else {
            appState.resumeMobility()
        }
    }

    private func overallProgress(total: Int, current: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { i in
                Capsule()
                    .fill(i <= current ? DS.accent : DS.border)
                    .frame(height: 3)
                    .animation(.easeInOut(duration: 0.3), value: current)
            }
        }
    }
}
