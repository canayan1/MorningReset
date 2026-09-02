import SwiftUI

struct MobilityFlowView: View {
    @Environment(AppState.self) private var appState
    @State private var hasStarted: Bool = false

    var body: some View {
        guard let flow = appState.currentMobilityFlow else {
            return AnyView(AppBackground())
        }
        let move = flow.moves[appState.currentMobilityMoveIndex]
        let family = PoseFamily.resolve(move.animationName)
        let anim = PoseVariation.resolve(move.animationName).apply(to: family)
        let moveIndex = appState.currentMobilityMoveIndex
        let totalMoves = flow.moves.count
        let progress = moveFraction(move: move)

        return AnyView(
            ZStack {
                AppBackground()

                VStack(alignment: .center, spacing: 0) {

                    Spacer()

                    // MARK: Header
                    VStack(alignment: .center, spacing: DS.Space.xs) {
                        Text(L10n.text(en: "MOBILITY", tr: "HAREKETLİLİK", es: "MOVILIDAD"))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(DS.textDim)
                            .kerning(1.2)

                        Text(flow.title)
                            .font(.title2.bold())
                            .foregroundStyle(DS.textPrimary)
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                    Spacer().frame(height: DS.Space.lg)

                    // MARK: Animation area
                    AnimatedStickFigureView(
                        from: anim.from,
                        to: anim.to,
                        duration: anim.duration,
                        isAnimating: appState.isMobilityRunning,
                        color: DS.textSecondary
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)

                    Spacer().frame(height: DS.Space.lg)

                    // MARK: Move label + name
                    VStack(alignment: .center, spacing: DS.Space.xs) {
                        Text(L10n.text(
                            en: "MOVE \(moveIndex + 1) OF \(totalMoves)",
                            tr: "HAREKET \(moveIndex + 1) / \(totalMoves)",
                            es: "MOVIMIENTO \(moveIndex + 1) DE \(totalMoves)"
                        ))
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
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .animation(.easeInOut(duration: 0.25), value: moveIndex)
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

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
                    }
                    .primaryCTA()

                    Spacer().frame(height: DS.Space.sm)

                    // MARK: Skip
                    if hasStarted {
                        Button {
                            appState.pauseMobility()
                            appState.advanceMobilityMove()
                        } label: {
                            Text(L10n.text(en: "Skip →", tr: "Atla →", es: "Saltar →"))
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
                        Text(L10n.text(en: "Exit", tr: "Çıkış", es: "Salir"))
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
        if !hasStarted { return L10n.text(en: "Begin", tr: "Başla", es: "Comenzar") }
        return appState.isMobilityRunning
            ? L10n.text(en: "Pause",  tr: "Duraklat", es: "Pausar")
            : L10n.text(en: "Resume", tr: "Devam et", es: "Reanudar")
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
