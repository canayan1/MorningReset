import SwiftUI

// MARK: - Night wind-down sound
//
// A calming soundscape to wind down into sleep, drawn from traditional
// contemplative sound practices (Qigong's Six Healing Sounds, yogic humming,
// Zen flute/temple bells). Played continuously and softly — it keeps the app's
// audio session alive through the night so the morning ritual can greet you.
// Framed experientially for relaxation only — not a medical or measurable claim.

struct NightSoundView: View {
    @Environment(AppState.self) private var appState

    private let language = AppLanguage.current

    private struct Soundscape: Identifiable {
        let id: String
        let path: EnergyPath
        let name: String
        let lineage: String
        let symbol: String
    }

    private var soundscapes: [Soundscape] {
        [
            Soundscape(id: "reiki", path: .reiki,
                       name: L10n.text(language: language, en: "Standing Bell Drift", tr: "Çan Sürüklenişi", es: "Deriva de Campana"),
                       lineage: L10n.text(language: language, en: "Inspired by struck temple bells & Zen flute", tr: "Tapınak çanları ve Zen flütünden esinle", es: "Inspirado en campanas de templo y flauta zen"),
                       symbol: "bell.fill"),
            Soundscape(id: "breathwork", path: .breathwork,
                       name: L10n.text(language: language, en: "Humming Breath", tr: "Vızıltı Nefesi", es: "Aliento que Zumba"),
                       lineage: L10n.text(language: language, en: "Inspired by Bhramari & Om", tr: "Bhramari ve Om'dan esinle", es: "Inspirado en Bhramari y Om"),
                       symbol: "waveform"),
            Soundscape(id: "qigong", path: .qigong,
                       name: L10n.text(language: language, en: "Six Sounds at Dusk", tr: "Alacakaranlıkta Altı Ses", es: "Seis Sonidos al Anochecer"),
                       lineage: L10n.text(language: language, en: "Inspired by Qigong's Six Healing Sounds", tr: "Qigong'un Altı Şifa Sesi'nden esinle", es: "Inspirado en los Seis Sonidos del Qigong"),
                       symbol: "leaf.fill")
        ]
    }

    @State private var playingID: String? = nil

    /// The first soundscape is always free; the rest come with All-Access.
    private func isLocked(_ s: Soundscape) -> Bool {
        !appState.isPremium && s.id != soundscapes.first?.id
    }

    var body: some View {
        ZStack {
            AuraBackground(path: appState.activePath, intensity: 0.3, showEmblem: false)
            Color.black.opacity(0.25).ignoresSafeArea()

            VStack(alignment: .center, spacing: 0) {
                // Nav
                HStack {
                    Button {
                        AmbientPlayer.shared.stop()
                        appState.showWakeHome()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                            .frame(width: 32, height: 32)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel(L10n.text(language: language, en: "Close", tr: "Kapat", es: "Cerrar"))
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.horizontal, DS.Space.lg)

                Spacer().frame(height: DS.Space.lg)

                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 40, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.85))

                Spacer().frame(height: DS.Space.md)

                Text(L10n.text(language: language, en: "Wind down", tr: "Yavaşla", es: "Desacelera"))
                    .font(.system(size: 32, weight: .light, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: DS.Space.sm)

                Text(L10n.text(language: language,
                               en: "Drift into sleep. Your practice is waiting whenever you wake.",
                               tr: "Uykuya süzül. Uyandığında pratiğin seni bekliyor.",
                               es: "Déjate llevar al sueño. Tu práctica te espera al despertar."))
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DS.Space.lg)

                Spacer().frame(height: DS.Space.xl)

                VStack(spacing: DS.Space.sm) {
                    ForEach(soundscapes) { s in
                        soundRow(s)
                    }
                }
                .padding(.horizontal, DS.Space.lg)

                Spacer()

                Text(L10n.text(language: language,
                               en: "Inspired by traditional contemplative sound practices — for relaxation, not medical use.",
                               tr: "Geleneksel kontemplatif ses pratiklerinden esinlenmiştir — rahatlama içindir, tıbbi kullanım değildir.",
                               es: "Inspirado en prácticas contemplativas tradicionales de sonido — para relajación, no uso médico."))
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.35))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.bottom, DS.Space.xl)
            }
        }
        .onDisappear {
            // Audio intentionally keeps playing in the background for the night.
        }
        .accessibilityIdentifier("night.screen")
    }

    private func soundRow(_ s: Soundscape) -> some View {
        let isPlaying = playingID == s.id
        let locked = isLocked(s)
        return Button {
            if locked {
                AmbientPlayer.shared.stop()
                appState.paywallContext = .contextual
                appState.screen = .paywall
                return
            }
            if isPlaying {
                AmbientPlayer.shared.stop()
                playingID = nil
            } else {
                AmbientPlayer.shared.start(path: s.path)
                playingID = s.id
            }
        } label: {
            HStack(spacing: DS.Space.md) {
                Image(systemName: locked ? "lock.fill" : (isPlaying ? "pause.circle.fill" : s.symbol))
                    .font(.system(size: locked ? 16 : 22))
                    .foregroundStyle(.white.opacity(locked ? 0.6 : 1))
                    .frame(width: 30)
                Text(s.name)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white)
                Spacer()
                if isPlaying {
                    Image(systemName: "waveform")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.8))
                        .symbolEffect(.variableColor.iterative, options: .repeating)
                }
            }
            .padding(.vertical, DS.Space.md)
            .padding(.horizontal, DS.Space.lg)
            .background(.white.opacity(isPlaying ? 0.18 : 0.10))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(isPlaying ? 0.4 : 0.15), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
