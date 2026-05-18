import SwiftUI

struct BreathResetView: View {
    @Environment(AppState.self) private var appState

    // ── Breathing protocol ──────────────────────────────────────────
    // protect → 4-7-8  (inhale 4, hold 7, exhale 8)  calming
    // steady  → box    (inhale 4, hold 4, exhale 4, hold 4)  centering
    // push    → 4-4    (inhale 4, exhale 4)  energising

    private struct BreathParams {
        let inhale: Int
        let holdIn: Int
        let exhale: Int
        let holdOut: Int
        let name: String
    }

    private var params: BreathParams {
        switch appState.sessionMode {
        case .protect: return BreathParams(inhale: 4, holdIn: 7, exhale: 8, holdOut: 0, name: "4-7-8 breathing")
        case .steady:  return BreathParams(inhale: 4, holdIn: 4, exhale: 4, holdOut: 4, name: "Box breathing")
        case .push:    return BreathParams(inhale: 4, holdIn: 0, exhale: 4, holdOut: 0, name: "Energising breath")
        }
    }

    private let totalCycles = 4

    @State private var phase:            BreathPhase = .idle
    @State private var circleScale:      CGFloat     = 0.38
    @State private var cyclesCompleted:  Int         = 0
    @State private var breathTask:       Task<Void, Never>? = nil

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // ── Breathing circle ──────────────────────────────────
                ZStack {
                    Circle()
                        .fill(DS.accent.opacity(0.07))
                        .frame(width: 210, height: 210)
                        .scaleEffect(circleScale)

                    Circle()
                        .strokeBorder(DS.accent.opacity(0.35), lineWidth: 1.5)
                        .frame(width: 210, height: 210)
                        .scaleEffect(circleScale)

                    VStack(spacing: 4) {
                        Text(phaseLabel)
                            .font(.system(.callout, design: .serif))
                            .foregroundStyle(DS.textSecondary)
                            .animation(.easeInOut(duration: 0.25), value: phase)

                        if phase != .idle && phase != .done {
                            Text(params.name)
                                .font(.system(size: 10))
                                .foregroundStyle(DS.textDim)
                        }
                    }
                }

                Spacer().frame(height: DS.Space.xl)

                // ── Cycle dots ────────────────────────────────────────
                HStack(spacing: 10) {
                    ForEach(0..<totalCycles, id: \.self) { i in
                        Circle()
                            .fill(i < cyclesCompleted ? DS.accent : DS.border)
                            .frame(width: 6, height: 6)
                            .animation(.easeOut(duration: 0.25), value: cyclesCompleted)
                    }
                }

                Spacer()

                // ── Controls ──────────────────────────────────────────
                Group {
                    switch phase {
                    case .idle:
                        Button(L10n.text(en: "Begin", tr: "Başla", es: "Comenzar")) {
                            startBreathing()
                        }
                        .font(.system(.body, design: .serif))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(DS.accent)
                        .foregroundStyle(DS.background)
                        .clipShape(Capsule())
                        .padding(.horizontal, DS.Space.lg)

                    case .done:
                        Button(L10n.text(en: "Done", tr: "Bitti", es: "Listo")) {
                            appState.showPremiumHub()
                        }
                        .font(.system(.body, design: .serif))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(DS.accent)
                        .foregroundStyle(DS.background)
                        .clipShape(Capsule())
                        .padding(.horizontal, DS.Space.lg)
                        .transition(.opacity)

                    default:
                        Button(L10n.text(en: "Skip", tr: "Atla", es: "Saltar")) {
                            breathTask?.cancel()
                            appState.showPremiumHub()
                        }
                        .font(.subheadline)
                        .foregroundStyle(DS.textDim)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, DS.Space.lg)
                    }
                }
                .padding(.bottom, DS.Space.xl)
            }
        }
        .animation(.easeOut(duration: 0.3), value: phase)
        .onDisappear { breathTask?.cancel() }
    }

    // MARK: - Phase label

    private var phaseLabel: String {
        switch phase {
        case .idle:    return L10n.text(en: "Ready", tr: "Hazır", es: "Listo")
        case .inhale:  return L10n.text(en: "Inhale", tr: "Nefes Al", es: "Inhala")
        case .holdIn:  return L10n.text(en: "Hold", tr: "Tut", es: "Aguanta")
        case .exhale:  return L10n.text(en: "Exhale", tr: "Nefes Ver", es: "Exhala")
        case .holdOut: return L10n.text(en: "Hold", tr: "Tut", es: "Aguanta")
        case .done:    return L10n.text(en: "Done", tr: "Bitti", es: "Listo")
        }
    }

    // MARK: - Breathing task

    private func startBreathing() {
        let p = params
        breathTask = Task { @MainActor in
            for _ in 0..<totalCycles {
                guard !Task.isCancelled else { return }

                // Inhale
                phase = .inhale
                withAnimation(.easeInOut(duration: Double(p.inhale))) { circleScale = 1.0 }
                try? await Task.sleep(nanoseconds: UInt64(p.inhale) * 1_000_000_000)
                guard !Task.isCancelled else { return }

                // Hold in
                if p.holdIn > 0 {
                    phase = .holdIn
                    try? await Task.sleep(nanoseconds: UInt64(p.holdIn) * 1_000_000_000)
                    guard !Task.isCancelled else { return }
                }

                // Exhale
                phase = .exhale
                withAnimation(.easeInOut(duration: Double(p.exhale))) { circleScale = 0.38 }
                try? await Task.sleep(nanoseconds: UInt64(p.exhale) * 1_000_000_000)
                guard !Task.isCancelled else { return }

                // Hold out
                if p.holdOut > 0 {
                    phase = .holdOut
                    try? await Task.sleep(nanoseconds: UInt64(p.holdOut) * 1_000_000_000)
                    guard !Task.isCancelled else { return }
                }

                cyclesCompleted += 1
            }
            phase = .done
        }
    }
}

// MARK: - Phase enum

enum BreathPhase: Equatable {
    case idle, inhale, holdIn, exhale, holdOut, done
}
