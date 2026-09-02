import SwiftUI
import StoreKit

enum PaywallContext: Equatable {
    case onboarding
    case contextual
    case periodic
    case riseAndFlow
}

private struct PaywallCopy {
    let headline: String
    let body: String
    let features: [String]
    let secondaryCTA: String

    static let sharedFeatures = [
        L10n.text(
            en: "All 250 routines across the ten schools",
            tr: "On okuldaki 250 rutinin tamamı",
            es: "Las 250 rutinas de las diez escuelas"
        ),
        L10n.text(
            en: "Every night wind-down soundscape",
            tr: "Tüm gece yavaşlama sesleri",
            es: "Todos los paisajes sonoros nocturnos"
        ),
        L10n.text(
            en: "Your full practice history, not just the last few",
            tr: "Sadece son birkaçı değil, tüm pratik geçmişin",
            es: "Tu historial completo, no solo los últimos"
        ),
        L10n.text(
            en: "Every new school and routine as they're added",
            tr: "Eklenen her yeni okul ve rutin",
            es: "Cada nueva escuela y rutina que se añada"
        )
    ]

    static let onboarding = PaywallCopy(
        headline: L10n.text(
            en: "Ten schools. 250 routines.",
            tr: "On okul. 250 rutin.",
            es: "Diez escuelas. 250 rutinas."
        ),
        body: L10n.text(
            en: "Every school keeps one routine free forever. A single tier opens its schools; All-Access opens everything — plus the soundscapes, your full history, and whatever we add next.",
            tr: "Her okulun bir rutini sonsuza dek ücretsiz. Tek paket kendi okullarını açar; All-Access ise her şeyi — artı sesler, tüm geçmişin ve sonra eklenecekler.",
            es: "Cada escuela mantiene una rutina gratis para siempre. Un nivel abre sus escuelas; All-Access lo abre todo — más los sonidos, tu historial completo y lo que añadamos."
        ),
        features: sharedFeatures,
        secondaryCTA: L10n.text(en: "Continue without Premium", tr: "Premium olmadan devam et", es: "Continuar sin Premium")
    )

    static let contextual = PaywallCopy(
        headline: L10n.text(en: "Open the whole school", tr: "Okulun tamamını aç", es: "Abre la escuela entera"),
        body: L10n.text(
            en: "You have the free routine. All-Access opens every routine in all ten schools, with the teachings behind them.",
            tr: "Ücretsiz rutin sende. All-Access, on okulun tüm rutinlerini ve ardındaki öğretileri açar.",
            es: "Ya tienes la rutina gratuita. All-Access abre todas las rutinas de las diez escuelas, con sus enseñanzas."
        ),
        features: sharedFeatures,
        secondaryCTA: L10n.text(en: "Continue without Premium", tr: "Premium olmadan devam et", es: "Continuar sin Premium")
    )

    static let periodic = PaywallCopy(
        headline: L10n.text(en: "All-Access is optional", tr: "All-Access isteğe bağlı", es: "All-Access es opcional"),
        body: L10n.text(
            en: "The ten free routines stay free. If you want the full library, All-Access opens all 250.",
            tr: "On ücretsiz rutin ücretsiz kalır. Tüm kütüphaneyi istersen All-Access 250 rutini açar.",
            es: "Las diez rutinas gratuitas siguen siendo gratis. Si quieres la biblioteca completa, All-Access abre las 250."
        ),
        features: sharedFeatures,
        secondaryCTA: L10n.text(en: "Keep using the free reset", tr: "Ücretsiz reset'i kullanmaya devam et", es: "Sigue usando el reset gratuito")
    )

    static let riseAndFlow = PaywallCopy(
        headline: L10n.text(en: "Unlock all three extras", tr: "Üç eklentiyi birden aç", es: "Desbloquea los tres extras"),
        body: L10n.text(
            en: "Premium adds three optional follow-up tools after your reset. The core daily reset stays free.",
            tr: "Premium, resetinden sonra üç isteğe bağlı takip aracı ekler. Çekirdek günlük reset ücretsiz kalır.",
            es: "Premium añade tres herramientas opcionales de seguimiento tras tu reset. El reset diario principal sigue siendo gratuito."
        ),
        features: [
            L10n.text(en: "Rise & Flow: a guided 5-minute movement reset", tr: "Rise & Flow: rehberli 5 dakikalık hareket reset'i", es: "Rise & Flow: reset guiado de movimiento de 5 minutos"),
            L10n.text(en: "Breath Reset: mode-matched animated breathing session", tr: "Breath Reset: moda uygun animasyonlu nefes seansı", es: "Breath Reset: sesión de respiración animada según tu modo"),
            L10n.text(en: "Morning Pages: a daily sentence journal with monthly story", tr: "Morning Pages: aylık hikayeli günlük cümle günlüğü", es: "Morning Pages: diario de una frase diaria con historia mensual")
        ],
        secondaryCTA: L10n.text(en: "Not now", tr: "Şimdi değil", es: "Ahora no")
    )
}

private struct SubscriptionDetails {
    let priceLine: String
    let trialLine: String
    let billingLine: String
    let renewalLine: String
    let cta: String

    init(
        priceLine: String,
        trialLine: String,
        billingLine: String,
        renewalLine: String,
        cta: String
    ) {
        self.priceLine = priceLine
        self.trialLine = trialLine
        self.billingLine = billingLine
        self.renewalLine = renewalLine
        self.cta = cta
    }

    static let fallback = SubscriptionDetails(
        priceLine: L10n.text(en: "$59.99/year", tr: "$59.99/yıl", es: "$59.99/año"),
        trialLine: L10n.text(en: "Includes a 7-day free trial", tr: "7 günlük ücretsiz deneme dahil", es: "Incluye una prueba gratis de 7 días"),
        billingLine: L10n.text(en: "After the trial, billed to your Apple Account.", tr: "Deneme sonrası Apple Hesabına yansıtılır.", es: "Tras la prueba, cobrado a tu cuenta de Apple."),
        renewalLine: L10n.text(en: "Auto-renews yearly unless cancelled at least 24 hours before the current period ends.", tr: "Geçerli dönem bitmeden en az 24 saat önce iptal edilmezse her yıl otomatik yenilenir.", es: "Se renueva automáticamente cada año salvo que canceles al menos 24 horas antes de que termine el periodo actual."),
        cta: L10n.text(en: "Subscribe", tr: "Abone ol", es: "Suscribirse")
    )

    init(product: Product?) {
        guard
            let product,
            let subscription = product.subscription
        else {
            self = .fallback
            return
        }

        let period = subscription.subscriptionPeriod.displayLabel
        let renewal = L10n.text(
            en: "Auto-renews every \(period) unless cancelled at least 24 hours before the current period ends.",
            tr: "Geçerli dönem bitmeden en az 24 saat önce iptal edilmezse her \(period) otomatik yenilenir.",
            es: "Se renueva automáticamente cada \(period) salvo que canceles al menos 24 horas antes de que termine el periodo actual."
        )

        priceLine = "\(product.displayPrice)/\(period)"

        if let intro = subscription.introductoryOffer, intro.paymentMode == .freeTrial {
            let trial = intro.period.displayLabel
            trialLine = L10n.text(
                en: "Includes a \(trial) free trial",
                tr: "\(trial) ücretsiz deneme dahil",
                es: "Incluye una prueba gratis de \(trial)"
            )
            billingLine = L10n.text(
                en: "After the trial, billed to your Apple Account.",
                tr: "Deneme sonrası Apple Hesabına yansıtılır.",
                es: "Tras la prueba, cobrado a tu cuenta de Apple."
            )
            renewalLine = renewal
            cta = L10n.text(en: "Subscribe", tr: "Abone ol", es: "Suscribirse")
            return
        }

        trialLine = ""
        billingLine = L10n.text(en: "Billed to your Apple Account.", tr: "Apple Hesabına yansıtılır.", es: "Cobrado a tu cuenta de Apple.")
        renewalLine = renewal
        cta = L10n.text(en: "Subscribe", tr: "Abone ol", es: "Suscribirse")
    }
}

private extension Product.SubscriptionPeriod {
    var displayLabel: String {
        let singular: String
        let plural: String

        switch unit {
        case .day:
            singular = L10n.text(en: "day", tr: "gün", es: "día")
            plural = L10n.text(en: "days", tr: "gün", es: "días")
        case .week:
            singular = L10n.text(en: "week", tr: "hafta", es: "semana")
            plural = L10n.text(en: "weeks", tr: "hafta", es: "semanas")
        case .month:
            singular = L10n.text(en: "month", tr: "ay", es: "mes")
            plural = L10n.text(en: "months", tr: "ay", es: "meses")
        case .year:
            singular = L10n.text(en: "year", tr: "yıl", es: "año")
            plural = L10n.text(en: "years", tr: "yıl", es: "años")
        @unknown default:
            singular = L10n.text(en: "period", tr: "dönem", es: "periodo")
            plural = L10n.text(en: "periods", tr: "dönem", es: "periodos")
        }

        return value == 1 ? singular : "\(value) \(plural)"
    }
}

struct PaywallView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var context: PaywallContext = .contextual
    var isSheet: Bool = false

    @State private var products: [Product] = []
    @State private var tierProducts: [EnergyTier: Product] = [:]
    @State private var showTiers = false
    @State private var selected: Product? = nil
    @State private var isLoadingProduct = true
    @State private var isWorking = false
    @State private var statusMessage: String? = nil
    @State private var statusIsError = false
    @State private var purchaseSucceeded = false

    private var copy: PaywallCopy {
        switch context {
        case .onboarding:  return .onboarding
        case .contextual:  return .contextual
        case .periodic:    return .periodic
        case .riseAndFlow: return .riseAndFlow
        }
    }

    private var details: SubscriptionDetails {
        SubscriptionDetails(product: selected)
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DS.Space.lg) {
                        heroBand
                        headerSection
                        featureSection
                        subscriptionCard
                        trialTimeline
                        tierOption
                    }
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.bottom, DS.Space.lg)
                }

                footerSection
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.bottom, 24)
                    .background(
                        LinearGradient(
                            colors: [DS.background.opacity(0), DS.background.opacity(0.95)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        }
        .accessibilityIdentifier("paywall.screen")
        .sensoryFeedback(.success, trigger: purchaseSucceeded)
        .task { await loadProducts() }
        .onAppear {
            if context != .riseAndFlow {
                appState.onPaywallPresented()
            }
        }
    }

    /// A photograph at the top, dissolving into the ground beneath it.
    private var heroBand: some View {
        ZStack(alignment: .bottom) {
            Image("paywall-hero")
                .resizable().scaledToFill()
                .frame(height: 300)
                .clipped()
            LinearGradient(
                colors: [.clear, DS.background.opacity(0.5), DS.background],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 180)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .clipped()
        .padding(.horizontal, -DS.Space.lg)   // bleed past the column padding
        .accessibilityHidden(true)
    }

    private var headerSection: some View {
        VStack(alignment: .center, spacing: DS.Space.sm) {
            Text(L10n.text(en: "ENERGY RESET PREMIUM", tr: "ENERGY RESET PREMIUM", es: "ENERGY RESET PREMIUM"))
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(DS.textDim)
                .kerning(1.2)

            Text(copy.headline)
                .font(.title2.bold())
                .foregroundStyle(DS.textPrimary)

            Text(copy.body)
                .font(.callout)
                .foregroundStyle(DS.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }

    private func shortFeature(_ feature: String) -> String {
        if let range = feature.range(of: ":") {
            return String(feature[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
        }
        if let range = feature.range(of: ",") {
            return String(feature[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
        }
        return feature
    }

    private var featureSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            ForEach(copy.features, id: \.self) { feature in
                HStack(alignment: .center, spacing: DS.Space.sm) {
                    Rectangle()
                        .fill(DS.accent)
                        .frame(width: 2, height: 16)
                    Text(feature)
                        .font(.callout)
                        .foregroundStyle(DS.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
            }
        }
    }

    private var subscriptionCard: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text(L10n.text(en: "CHOOSE YOUR PLAN", tr: "PLANINI SEÇ", es: "ELIGE TU PLAN"))
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(DS.textDim)
                .kerning(1.2)

            ForEach(products, id: \.id) { plan in
                planRow(plan)
            }
            if let savingsLine {
                Text(savingsLine)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DS.accent)
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 4) {
                if !details.trialLine.isEmpty {
                    Text(details.trialLine)
                        .font(.caption)
                        .foregroundStyle(DS.textSecondary)
                }
                Text(L10n.text(
                    en: "Auto-renews until cancelled. Cancel anytime in Settings.",
                    tr: "İptal edilene kadar otomatik yenilenir. Ayarlar'dan istediğin zaman iptal et.",
                    es: "Se renueva hasta que canceles. Cancela cuando quieras en Ajustes."
                ))
                    .font(.caption)
                    .foregroundStyle(DS.textDim)
            }
            .padding(.top, DS.Space.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// The cheapest way in. Without this, someone who balks at All-Access
    /// never learns a single tier exists.
    @ViewBuilder
    private var tierOption: some View {
        if !tierProducts.isEmpty {
            VStack(spacing: DS.Space.sm) {
                Button {
                    withAnimation(.easeOut(duration: 0.2)) { showTiers.toggle() }
                } label: {
                    HStack(spacing: 6) {
                        Text(cheapestTierLine)
                            .font(.footnote).foregroundStyle(DS.accent)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        Image(systemName: showTiers ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10, weight: .semibold)).foregroundStyle(DS.accent)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)

                if showTiers {
                    ForEach(EnergyTier.allCases) { tier in
                        if let p = tierProducts[tier] {
                            Button {
                                Task { await purchaseTier(tier) }
                            } label: {
                                HStack(spacing: DS.Space.md) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(tier.title)
                                            .font(.body.weight(.medium)).foregroundStyle(DS.textPrimary)
                                        Text(tier.blurb)
                                            .font(.caption).foregroundStyle(DS.textSecondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer()
                                    Text("\(p.displayPrice)/mo")
                                        .font(.subheadline.weight(.semibold)).foregroundStyle(DS.accent)
                                }
                                .dreamCard(radius: DS.Radius.md, padding: DS.Space.md)
                            }
                            .buttonStyle(.plain)
                            .disabled(isWorking)
                        }
                    }
                    Text(L10n.text(en: "Each tier unlocks its own schools and renews monthly until cancelled.",
                                   tr: "Her paket kendi okullarını açar ve iptal edilene dek aylık yenilenir.",
                                   es: "Cada nivel abre sus escuelas y se renueva mensualmente hasta cancelar."))
                        .font(.system(size: 10)).foregroundStyle(DS.textDim)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var cheapestTierLine: String {
        let cheapest = EnergyTier.allCases.compactMap { tierProducts[$0]?.displayPrice }.min() ?? "$2.99"
        return L10n.text(en: "Only want one tier? From \(cheapest)/mo",
                         tr: "Tek paket mi istiyorsun? \(cheapest)/ay'dan",
                         es: "¿Solo un nivel? Desde \(cheapest)/mes")
    }

    @MainActor
    private func purchaseTier(_ tier: EnergyTier) async {
        isWorking = true
        setStatus(nil, isError: false)
        do {
            if case .purchased = try await appState.purchaseTier(tier) {
                purchaseSucceeded = true
                advance()
            }
        } catch {
            setStatus(error.localizedDescription, isError: true)
        }
        isWorking = false
    }

    /// "Save 54% vs monthly" — the maths users shouldn't have to do.
    private var savingsLine: String? {
        guard let annual = products.first(where: { $0.subscription?.subscriptionPeriod.unit == .year }),
              let monthly = products.first(where: { $0.subscription?.subscriptionPeriod.unit == .month })
        else { return nil }
        let yearAtMonthlyRate = monthly.price * 12
        guard yearAtMonthlyRate > 0, annual.price < yearAtMonthlyRate else { return nil }
        let pct = ((yearAtMonthlyRate - annual.price) / yearAtMonthlyRate) * 100
        let rounded = Int(NSDecimalNumber(decimal: pct).doubleValue.rounded())
        return rounded > 0 ? L10n.text(en: "Save \(rounded)% compared with monthly",
                                       tr: "Aylığa göre %\(rounded) tasarruf",
                                       es: "Ahorra un \(rounded)% frente al mensual") : nil
    }

    /// What actually happens over the trial — the single most common gap on
    /// subscription paywalls, and the honest thing to show.
    @ViewBuilder
    private var trialTimeline: some View {
        if let selected, selected.subscription?.introductoryOffer != nil {
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                timelineRow("checkmark.circle.fill",
                            L10n.text(en: "Today — everything unlocks, free.",
                                      tr: "Bugün — her şey açılır, ücretsiz.",
                                      es: "Hoy — todo se desbloquea, gratis."), DS.accent)
                timelineRow("bell",
                            L10n.text(en: "Day 5 — we'll remind you the trial is ending.",
                                      tr: "5. gün — denemenin bittiğini hatırlatırız.",
                                      es: "Día 5 — te recordamos que la prueba termina."), DS.textSecondary)
                timelineRow("creditcard",
                            L10n.text(en: "Day 7 — your subscription starts. Cancel any time before then.",
                                      tr: "7. gün — aboneliğin başlar. O ana dek istediğin zaman iptal et.",
                                      es: "Día 7 — comienza tu suscripción. Cancela antes cuando quieras."), DS.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .dreamCard(radius: DS.Radius.md, padding: DS.Space.md)
        }
    }

    private func timelineRow(_ symbol: String, _ text: String, _ tint: Color) -> some View {
        HStack(alignment: .top, spacing: DS.Space.sm) {
            Image(systemName: symbol)
                .font(.system(size: 13)).foregroundStyle(tint).frame(width: 18)
            Text(text)
                .font(.caption).foregroundStyle(DS.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// The yearly price divided into months. Shrinking the figure to a smaller
    /// unit is the one move every competitor studied makes.
    private func perMonthLine(_ plan: Product) -> String? {
        guard plan.subscription?.subscriptionPeriod.unit == .year else { return nil }
        let monthly = plan.price / Decimal(12)
        let formatted = monthly.formatted(plan.priceFormatStyle)
        return L10n.text(
            en: "\(formatted) a month",
            tr: "ayda \(formatted)",
            es: "\(formatted) al mes"
        )
    }

    /// What the yearly plan saves against paying monthly, as a badge. Nil when
    /// both plans are not loaded, or when the saving is too small to be worth
    /// claiming — an honest badge or none at all.
    private var savingsBadge: String? {
        guard let year = products.first(where: { $0.subscription?.subscriptionPeriod.unit == .year }),
              let month = products.first(where: { $0.subscription?.subscriptionPeriod.unit == .month })
        else { return nil }
        let full = month.price * Decimal(12)
        guard full > 0, year.price < full else { return nil }
        let saved = (full - year.price) / full * Decimal(100)
        let percent = Int(NSDecimalNumber(decimal: saved).doubleValue.rounded())
        guard percent >= 10 else { return nil }
        return L10n.text(en: "SAVE \(percent)%", tr: "%\(percent) TASARRUF", es: "AHORRA \(percent)%")
    }

    private func planRow(_ plan: Product) -> some View {
        let isSelected = selected?.id == plan.id
        let isAnnual = plan.subscription?.subscriptionPeriod.unit == .year
        let det = SubscriptionDetails(product: plan)
        return Button {
            selected = plan
        } label: {
            HStack(spacing: DS.Space.sm) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? DS.accent : DS.border)

                VStack(alignment: .leading, spacing: 2) {
                    Text(isAnnual
                         ? L10n.text(en: "Yearly", tr: "Yıllık", es: "Anual")
                         : L10n.text(en: "Monthly", tr: "Aylık", es: "Mensual"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(DS.textPrimary)
                    if isAnnual, let perMonth = perMonthLine(plan) {
                        Text(perMonth)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(DS.accentInk)
                    }
                    Text(det.priceLine)
                        .font(.caption)
                        .foregroundStyle(DS.textSecondary)
                    if isAnnual, !det.trialLine.isEmpty {
                        Text(det.trialLine)
                            .font(.caption2)
                            .foregroundStyle(DS.accent)
                    }
                }

                Spacer()

                if isAnnual {
                    Text(savingsBadge ?? L10n.text(en: "BEST VALUE", tr: "EN AVANTAJLI", es: "MEJOR VALOR"))
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(DS.background)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(DS.accent)
                        .clipShape(Capsule())
                }
            }
            .padding(DS.Space.md)
            .background(isSelected ? DS.accent.opacity(0.08) : DS.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? DS.accent : DS.border, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var expectationCopy: some View {
        Text(
            L10n.text(
                en: "Premium is optional. It does not change the core 2-minute reset. It only unlocks the shipped extras listed above.",
                tr: "Premium isteğe bağlıdır. Çekirdek 2 dakikalık reset'i değiştirmez. Yalnızca yukarıda listelenen gönderilmiş ekstraların kilidini açar.",
                es: "Premium es opcional. No cambia el reset principal de 2 minutos. Solo desbloquea los extras ya incluidos arriba."
            )
        )
            .font(.caption)
            .foregroundStyle(DS.textDim)
            .lineSpacing(3)
    }

    private var footerSection: some View {
        VStack(spacing: DS.Space.sm) {
            if let statusMessage {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(statusIsError ? .red : DS.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
            }

            Button { purchase() } label: {
                Group {
                    if isWorking || isLoadingProduct {
                        ProgressView()
                            .tint(DS.background)
                    } else {
                        Text(details.cta)
                    }
                }
            }
            .primaryCTA()
            .disabled(isWorking || isLoadingProduct || selected == nil)
            .accessibilityIdentifier("paywall.purchaseButton")

            Button(copy.secondaryCTA) {
                advance()
            }
            .font(.subheadline)
            .foregroundStyle(DS.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .accessibilityIdentifier("paywall.secondaryCTA")

            Text(
                L10n.text(
                    en: "By continuing, you agree to the Terms of Use and Privacy Policy.",
                    tr: "Devam ederek Kullanım Koşulları'nı ve Gizlilik Politikası'nı kabul etmiş olursun.",
                    es: "Al continuar, aceptas los Términos de uso y la Política de privacidad."
                )
            )
                .font(.caption)
                .foregroundStyle(DS.textDim)
                .multilineTextAlignment(.center)

            HStack(spacing: DS.Space.md) {
                Link(L10n.text(en: "Terms of Use", tr: "Kullanım Koşulları", es: "Términos de uso"), destination: AppState.termsOfUseURL)
                Link(L10n.text(en: "Privacy Policy", tr: "Gizlilik Politikası", es: "Política de privacidad"), destination: AppState.privacyPolicyURL)
                Link(L10n.text(en: "Support", tr: "Destek", es: "Soporte"), destination: AppState.supportURL)
            }
            .font(.caption)
            .foregroundStyle(DS.textSecondary)

            HStack(spacing: DS.Space.md) {
                Link(L10n.text(en: "Manage Subscription", tr: "Aboneliği yönet", es: "Gestionar suscripción"), destination: AppState.manageSubscriptionsURL)

                Button(L10n.text(en: "Restore Purchases", tr: "Satın alımları geri yükle", es: "Restaurar compras")) {
                    restorePurchases()
                }
                .disabled(isWorking)
            }
            .font(.caption)
            .foregroundStyle(DS.textSecondary)
        }
    }

    @MainActor
    private func loadProducts() async {
        guard products.isEmpty else { return }
        isLoadingProduct = true
        products = await appState.subscriptionProducts()
        var tiers: [EnergyTier: Product] = [:]
        for tier in EnergyTier.allCases {
            if let p = await appState.tierProduct(tier) { tiers[tier] = p }
        }
        tierProducts = tiers
        selected = products.first { $0.subscription?.subscriptionPeriod.unit == .year }
            ?? products.first
        isLoadingProduct = false

        if products.isEmpty {
            setStatus(
                L10n.text(
                    en: "Subscription details are unavailable right now. Please try again later.",
                    tr: "Abonelik ayrıntıları şu anda kullanılamıyor. Lütfen daha sonra tekrar dene.",
                    es: "Los detalles de la suscripción no están disponibles ahora mismo. Inténtalo de nuevo más tarde."
                ),
                isError: true
            )
        }
    }

    private func purchase() {
        guard let plan = selected else { return }
        isWorking = true
        setStatus(nil, isError: false)

        Task {
            do {
                switch try await appState.purchase(plan) {
                case .purchased:
                    await MainActor.run {
                        purchaseSucceeded = true
                        advance()
                    }
                case .cancelled:
                    await MainActor.run {
                        setStatus(L10n.text(en: "Purchase cancelled. You can keep using the free reset.", tr: "Satın alma iptal edildi. Ücretsiz reset'i kullanmaya devam edebilirsin.", es: "La compra se canceló. Puedes seguir usando el reset gratuito."), isError: false)
                        isWorking = false
                    }
                case .pending:
                    await MainActor.run {
                        setStatus(L10n.text(en: "Purchase is pending approval. Premium unlocks when Apple confirms it.", tr: "Satın alma onay bekliyor. Apple onayladığında Premium açılır.", es: "La compra está pendiente de aprobación. Premium se desbloquea cuando Apple la confirme."), isError: false)
                        isWorking = false
                    }
                }
            } catch {
                await MainActor.run {
                    let message = (error as? LocalizedError)?.errorDescription
                        ?? L10n.text(en: "Something went wrong while starting the subscription.", tr: "Abonelik başlatılırken bir şeyler ters gitti.", es: "Algo salió mal al iniciar la suscripción.")
                    setStatus(message, isError: true)
                    isWorking = false
                }
            }
        }
    }

    private func restorePurchases() {
        isWorking = true
        setStatus(nil, isError: false)

        Task {
            let result = await appState.restorePurchases()

            await MainActor.run {
                switch result {
                case .restored:
                    setStatus(L10n.text(en: "Subscription restored.", tr: "Abonelik geri yüklendi.", es: "Suscripción restaurada."), isError: false)
                    advance()
                case .nothingToRestore:
                    setStatus(L10n.text(en: "No active subscription was found to restore.", tr: "Geri yüklenecek etkin bir abonelik bulunamadı.", es: "No se encontró ninguna suscripción activa para restaurar."), isError: false)
                case .failed:
                    setStatus(L10n.text(en: "Restore couldn't be completed. Please try again.", tr: "Geri yükleme tamamlanamadı. Lütfen tekrar dene.", es: "No se pudo completar la restauración. Inténtalo de nuevo."), isError: true)
                }
                isWorking = false
            }
        }
    }

    @MainActor
    private func setStatus(_ message: String?, isError: Bool) {
        statusMessage = message
        statusIsError = isError
    }

    @MainActor
    private func advance() {
        isWorking = false
        if isSheet {
            dismiss()
        } else {
            appState.advanceFromPaywall()
        }
    }
}
