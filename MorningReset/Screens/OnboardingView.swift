import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var page = 0
    @State private var pathPicking = ProcessInfo.processInfo.arguments.contains("-startPathPick")
    @State private var basicsShowing = false
    @State private var practicePicking = false

    private struct Slide {
        let title: String
        let subtitle: String
        let cta: String
    }

    private let slides: [Slide] = [
        Slide(
            title: L10n.text(
                en: "How you wake\nsets your energy\nfor the whole day.",
                tr: "Nasıl uyandığın\ntüm günün enerjisini\nbelirler.",
                es: "Cómo despiertas\ndefine tu energía\ntodo el día."
            ),
            subtitle: L10n.text(
                en: "Morning Reset is a short ritual to raise it — on purpose, before the scroll begins.",
                tr: "Morning Reset, bunu bilinçli olarak yükselten kısa bir ritüel — kaydırma başlamadan önce.",
                es: "Morning Reset es un ritual breve para elevarla — a propósito, antes de que empiece el scroll."
            ),
            cta: L10n.text(en: "Continue", tr: "Devam et", es: "Continuar")
        ),
        Slide(
            title: L10n.text(
                en: "Choose an\nancient path.",
                tr: "Kadim bir\nyol seç.",
                es: "Elige un\ncamino ancestral."
            ),
            subtitle: L10n.text(
                en: "Reiki, breathwork, or qigong — each wakes your energy a different way. Keep your usual alarm; we meet you on your lock screen.",
                tr: "Reiki, nefes ya da qigong — her biri enerjini farklı uyandırır. Normal alarmını kullan; biz kilit ekranında seni karşılarız.",
                es: "Reiki, respiración o qigong — cada uno despierta tu energía de otra forma. Mantén tu alarma; te esperamos en tu pantalla bloqueada."
            ),
            cta: L10n.text(en: "Continue", tr: "Devam et", es: "Continuar")
        ),
        Slide(
            title: L10n.text(
                en: "One practice.\nSeven mornings.\nIt becomes yours.",
                tr: "Tek pratik.\nYedi sabah.\nSenin olur.",
                es: "Una práctica.\nSiete mañanas.\nSe vuelve tuya."
            ),
            subtitle: L10n.text(
                en: "Pick one small practice, do it each morning, and lock it in. We guide you step by step.",
                tr: "Küçük tek bir pratik seç, her sabah yap ve kilitle. Adım adım sana eşlik ederiz.",
                es: "Elige una práctica pequeña, hazla cada mañana y fíjala. Te guiamos paso a paso."
            ),
            cta: L10n.text(en: "Choose your path", tr: "Yolunu seç", es: "Elige tu camino")
        ),
    ]

    var body: some View {
        if pathPicking {
            EnergyPathPickView { path in
                appState.selectMorningPath(path)
                withAnimation(.easeOut(duration: 0.25)) {
                    pathPicking = false
                    basicsShowing = true
                }
            }
            .transition(.opacity)
        } else if basicsShowing {
            PathBasicsView(
                path: appState.activePath ?? .reiki,
                ctaTitle: L10n.text(en: "Begin your practice", tr: "Pratiğine başla", es: "Comienza tu práctica"),
                onContinue: {
                    withAnimation(.easeOut(duration: 0.25)) {
                        basicsShowing = false
                        practicePicking = true
                    }
                }
            )
            .transition(.opacity)
        } else if practicePicking {
            FirstWinPickView(
                title: L10n.text(en: "Choose your first practice", tr: "İlk pratiğini seç", es: "Elige tu primera práctica"),
                subtitle: L10n.text(
                    en: "One practice, seven mornings. That's how your energy builds.",
                    tr: "Tek pratik, yedi sabah. Enerjin böyle birikir.",
                    es: "Una práctica, siete mañanas. Así se acumula tu energía."
                ),
                ctaTitle: L10n.text(en: "Start this practice", tr: "Bu pratiği başlat", es: "Empezar esta práctica"),
                path: appState.activePath ?? .reiki,
                recommended: (appState.activePath ?? .reiki).practices.first,
                reason: (appState.activePath ?? .reiki).essence
            ) { kind in
                appState.selectActiveFirstWin(kind)
                appState.completeOnboardingAndShowScheduleSetup()
            }
            .transition(.opacity)
        } else {
            slides_body
        }
    }

    private var slides_body: some View {
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
                        withAnimation(.easeOut(duration: 0.25)) { pathPicking = true }
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
