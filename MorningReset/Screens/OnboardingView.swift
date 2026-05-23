import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var page = 0

    private struct Slide {
        let title: String
        let subtitle: String
        let cta: String
    }

    private let slides: [Slide] = [
        Slide(
            title: L10n.text(
                en: "Wake up.\nReach for your phone.\nCatch yourself first.",
                tr: "Uyan.\nTelefonuna uzan.\nÖnce kendini yakala.",
                es: "Despierta.\nAlcanza el teléfono.\nFrena antes."
            ),
            subtitle: L10n.text(
                en: "Morning Reset gives you one intentional tap before the scroll begins.",
                tr: "Morning Reset, kaydırma başlamadan önce sana bilinçli bir ilk dokunuş verir.",
                es: "Morning Reset te da un toque intencional antes de que empiece el scroll."
            ),
            cta: L10n.text(en: "Continue", tr: "Devam et", es: "Continuar")
        ),
        Slide(
            title: L10n.text(
                en: "Set your\nwake time.",
                tr: "Uyanma\nsaatini ayarla.",
                es: "Define tu\nhora de despertar."
            ),
            subtitle: L10n.text(
                en: "Keep your usual alarm.\nWe meet you on the lock screen\nthe moment you open your eyes.",
                tr: "Normal alarmını kullanmaya devam et.\nGözlerini açtığın anda\nkilit ekranında seni karşılarız.",
                es: "Mantén tu alarma habitual.\nNos vemos en la pantalla bloqueada\nen cuanto abres los ojos."
            ),
            cta: L10n.text(en: "Continue", tr: "Devam et", es: "Continuar")
        ),
        Slide(
            title: L10n.text(
                en: "Tap the card.\nAnswer 5 quick questions.\nTake your first win.",
                tr: "Karta dokun.\n5 hızlı soruyu yanıtla.\nİlk kazanımını al.",
                es: "Toca la tarjeta.\nResponde 5 preguntas rápidas.\nToma tu primera victoria."
            ),
            subtitle: L10n.text(
                en: "We guide you through a short result and one immediate action before the scroll begins.",
                tr: "Kaydırma başlamadan önce seni kısa bir sonuç ve tek bir anlık eylem üzerinden yönlendiriyoruz.",
                es: "Te guiamos por un resultado breve y una acción inmediata antes de que empiece el scroll."
            ),
            cta: L10n.text(en: "Set wake time", tr: "Uyanma saatini ayarla", es: "Definir hora de despertar")
        ),
    ]

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 20) {
                    Text(slides[page].title)
                        .font(DS.Typo.title)
                        .foregroundStyle(DS.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)

                    Text(slides[page].subtitle)
                        .font(.subheadline)
                        .foregroundStyle(DS.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .id(page)
                .transition(.opacity)
                .animation(.easeOut(duration: 0.2), value: page)
                .padding(.horizontal, 40)

                Spacer()

                HStack(spacing: 8) {
                    ForEach(0..<slides.count, id: \.self) { i in
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) { page = i }
                        } label: {
                            Circle()
                                .fill(i == page ? DS.accent : DS.border)
                                .frame(width: 4, height: 4)
                                .frame(width: 22, height: 22)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(L10n.text(en: "Slide \(i + 1)", tr: "Slayt \(i + 1)", es: "Diapositiva \(i + 1)"))
                    }
                }
                .animation(.easeOut(duration: 0.2), value: page)
                .padding(.bottom, DS.Space.lg)

                Button(slides[page].cta) {
                    if page < slides.count - 1 {
                        withAnimation(.easeOut(duration: 0.2)) { page += 1 }
                    } else {
                        appState.completeOnboardingAndShowScheduleSetup()
                    }
                }
                .font(.system(.body, design: .serif))
                .tracking(0.5)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.accent)
                .foregroundStyle(DS.background)
                .clipShape(Capsule())
                .padding(.horizontal, DS.Space.lg)
                .padding(.bottom, DS.Space.sm)
                .accessibilityIdentifier("onboarding.primaryButton")

                if page == slides.count - 1 {
                    Text(L10n.text(
                        en: "Morning Reset includes optional breathing and mobility exercises. These are not a substitute for professional medical advice. Consult your doctor before starting any exercise programme, especially if you have a health condition. Stop immediately if you feel pain or discomfort.",
                        tr: "Morning Reset, isteğe bağlı nefes ve hareketlilik egzersizleri içerir. Bunlar profesyonel tıbbi tavsiyenin yerini tutmaz. Mevcut bir sağlık durumunuz varsa egzersiz yapmadan önce doktorunuza danışın. Ağrı veya rahatsızlık hissederseniz hemen durun.",
                        es: "Morning Reset incluye ejercicios opcionales de respiración y movilidad. No sustituyen el consejo médico profesional. Consulta a tu médico antes de comenzar, especialmente si tienes alguna condición de salud. Detente de inmediato si sientes dolor o malestar."
                    ))
                    .font(.caption2)
                    .foregroundStyle(DS.textDim)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DS.Space.lg)
                    .transition(.opacity)
                }

                Spacer().frame(height: DS.Space.xl)
            }
        }
        .accessibilityIdentifier("onboarding.screen")
    }
}
