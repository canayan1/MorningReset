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
            en: "Weekly pattern insight from your recent resets",
            tr: "Son resetlerinden haftalık örüntü içgörüsü",
            es: "Patrón semanal a partir de tus resets recientes"
        ),
        L10n.text(
            en: "A short guided pause after strong patterns show up",
            tr: "Güçlü örüntüler ortaya çıktığında kısa bir rehberli duraklama",
            es: "Una breve pausa guiada cuando aparecen patrones fuertes"
        ),
        L10n.text(
            en: "Rise & Flow: a guided 5-minute movement reset",
            tr: "Rise & Flow: rehberli 5 dakikalık hareket reset'i",
            es: "Rise & Flow: reset guiado de movimiento de 5 minutos"
        )
    ]

    static let onboarding = PaywallCopy(
        headline: L10n.text(
            en: "Add one deeper layer when you want it",
            tr: "İstediğinde bir katman daha ekle",
            es: "Añade una capa más profunda cuando quieras"
        ),
        body: L10n.text(
            en: "The core Morning Reset stays free. Premium only unlocks a few extra follow-up tools that already exist in the app.",
            tr: "Morning Reset'in çekirdeği ücretsiz kalır. Premium yalnızca uygulamada zaten bulunan birkaç ek takip aracını açar.",
            es: "El núcleo de Morning Reset sigue siendo gratuito. Premium solo desbloquea algunas herramientas extra de seguimiento que ya existen en la app."
        ),
        features: sharedFeatures,
        secondaryCTA: L10n.text(en: "Continue without Premium", tr: "Premium olmadan devam et", es: "Continuar sin Premium")
    )

    static let contextual = PaywallCopy(
        headline: L10n.text(en: "See the full pattern", tr: "Tam örüntüyü gör", es: "Ver el patrón completo"),
        body: L10n.text(
            en: "When your recent resets start to repeat, Premium shows the full pattern and adds one short guided pause before you move on.",
            tr: "Son resetlerin tekrar etmeye başladığında Premium tam örüntüyü gösterir ve ilerlemeden önce kısa bir rehberli duraklama ekler.",
            es: "Cuando tus resets recientes empiezan a repetirse, Premium muestra el patrón completo y añade una breve pausa guiada antes de seguir."
        ),
        features: sharedFeatures,
        secondaryCTA: L10n.text(en: "Continue without Premium", tr: "Premium olmadan devam et", es: "Continuar sin Premium")
    )

    static let periodic = PaywallCopy(
        headline: L10n.text(en: "Premium is optional", tr: "Premium isteğe bağlı", es: "Premium es opcional"),
        body: L10n.text(
            en: "If you want more than the core reset, Premium adds a clearer weekly pattern read and the extra guided movement flow.",
            tr: "Çekirdek reset'ten fazlasını istiyorsan Premium daha net bir haftalık örüntü okuması ve ek rehberli hareket akışı ekler.",
            es: "Si quieres más que el reset principal, Premium añade una lectura semanal más clara del patrón y el flujo extra de movimiento guiado."
        ),
        features: sharedFeatures,
        secondaryCTA: L10n.text(en: "Keep using the free reset", tr: "Ücretsiz reset'i kullanmaya devam et", es: "Sigue usando el reset gratuito")
    )

    static let riseAndFlow = PaywallCopy(
        headline: L10n.text(en: "Unlock all three extras", tr: "Üç eklentiyi birden aç", es: "Desbloquea los tres extras"),
        body: L10n.text(
            en: "Premium adds three optional follow-up tools after your reset. The core morning ritual stays free.",
            tr: "Premium, resetinden sonra üç isteğe bağlı takip aracı ekler. Çekirdek sabah ritüeli ücretsiz kalır.",
            es: "Premium añade tres herramientas opcionales de seguimiento tras tu reset. El ritual matinal principal sigue siendo gratuito."
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
        priceLine: L10n.text(en: "$19.99/year", tr: "$19.99/yıl", es: "$19.99/año"),
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

    @State private var product: Product? = nil
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
        SubscriptionDetails(product: product)
    }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DS.Space.lg) {
                        headerSection
                        featureSection
                        subscriptionCard
                        expectationCopy
                    }
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.top, DS.Space.xl)
                    .padding(.bottom, DS.Space.lg)
                }

                footerSection
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.bottom, 24)
                    .background(DS.background)
            }
        }
        .accessibilityIdentifier("paywall.screen")
        .sensoryFeedback(.success, trigger: purchaseSucceeded)
        .task { await loadProduct() }
        .onAppear {
            if context != .riseAndFlow {
                appState.onPaywallPresented()
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text(L10n.text(en: "MORNING RESET PREMIUM", tr: "MORNING RESET PREMIUM", es: "MORNING RESET PREMIUM"))
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
        }
    }

    private var featureSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            ForEach(copy.features, id: \.self) { feature in
                HStack(alignment: .top, spacing: DS.Space.sm) {
                    Rectangle()
                        .fill(DS.accent)
                        .frame(width: 2, height: 16)
                    Text(feature)
                        .font(.callout)
                        .foregroundStyle(DS.textPrimary)
                        .lineSpacing(3)
                    Spacer()
                }
            }
        }
    }

    private var subscriptionCard: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            Text(L10n.text(en: "SUBSCRIPTION", tr: "ABONELİK", es: "SUSCRIPCIÓN"))
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(DS.textDim)
                .kerning(1.2)

            Text(details.priceLine)
                .font(.title2.bold())
                .foregroundStyle(DS.textPrimary)

            if !details.trialLine.isEmpty {
                Text(details.trialLine)
                    .font(.subheadline)
                    .foregroundStyle(DS.textSecondary)
            }

            Text(details.billingLine)
                .font(.caption)
                .foregroundStyle(DS.textSecondary)

            Text(details.renewalLine)
                .font(.caption)
                .foregroundStyle(DS.textSecondary)
                .lineSpacing(3)

            Text(
                L10n.text(
                    en: "Manage or cancel anytime in App Store subscription settings. Restore purchases below if you already subscribed.",
                    tr: "Aboneliği App Store abonelik ayarlarından istediğin zaman yönetebilir veya iptal edebilirsin. Zaten aboneysen aşağıdan satın alımları geri yükle.",
                    es: "Gestiona o cancela cuando quieras en los ajustes de suscripciones del App Store. Restaura las compras abajo si ya te suscribiste."
                )
            )
                .font(.caption)
                .foregroundStyle(DS.textDim)
                .lineSpacing(3)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.md)
        .background(DS.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(DS.border, lineWidth: 1)
        )
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
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
            }
            .background(DS.accent)
            .foregroundStyle(DS.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .disabled(isWorking || isLoadingProduct || product == nil)
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
    private func loadProduct() async {
        guard product == nil else { return }
        isLoadingProduct = true
        product = await appState.premiumProduct()
        isLoadingProduct = false

        if product == nil {
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
        isWorking = true
        setStatus(nil, isError: false)

        Task {
            do {
                switch try await appState.purchase() {
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
