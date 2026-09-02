import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Button(L10n.text(en: "Done", tr: "Tamam", es: "Listo")) { dismiss() }
                        .font(.subheadline)
                        .foregroundStyle(DS.textSecondary)
                }
                .padding(.top, DS.Space.lg)
                .padding(.horizontal, DS.Space.lg)

                Spacer()

                VStack(alignment: .leading, spacing: DS.Space.lg + 4) {
                    Text(L10n.text(
                        en: "How Inner Light works",
                        tr: "Inner Light nasıl çalışır",
                        es: "Cómo funciona Inner Light"
                    ))
                    .font(DS.Typo.subtitle)
                    .foregroundStyle(DS.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: DS.Space.md + 4) {
                        Text(L10n.text(
                            en: "Inner Light is a daily practice drawn from ten living traditions — at whichever hour is yours.",
                            tr: "Inner Light, on yaşayan gelenekten beslenen günlük bir pratik — hangi saat senin ise.",
                            es: "Inner Light es una práctica diaria de diez tradiciones vivas — a la hora que sea tuya."
                        ))
                        .font(.body)
                        .foregroundStyle(DS.textPrimary)

                        Text(L10n.text(
                            en: "Choose the tradition that draws you. Sit with what it is. Then run a practice — a calm timer, step by step, and a quiet voice beside you.",
                            tr: "Seni çeken geleneği seç. Ne olduğuyla otur. Sonra bir pratik çalıştır — sakin bir sayaç, adım adım, ve yanında sessiz bir ses.",
                            es: "Elige la tradición que te atraiga. Siéntate con lo que es. Luego corre una práctica — un temporizador tranquilo, paso a paso, y una voz serena a tu lado."
                        ))
                        .foregroundStyle(DS.textSecondary)

                        Text(L10n.text(
                            en: "Every practice you finish feeds your orb of light. It grows brighter and fuller the longer you go, and it remembers all of it.",
                            tr: "Tamamladığın her pratik ışık topunu besler. Devam ettikçe daha parlak ve dolgun olur, ve hepsini hatırlar.",
                            es: "Cada práctica que terminas alimenta tu orbe de luz. Crece más brillante y pleno cuanto más sigues, y lo recuerda todo."
                        ))
                        .foregroundStyle(DS.textSecondary)

                        Text(L10n.text(
                            en: "A daily reminder is yours to set, or to leave. Inner Light is not an alarm clock — keep using the one you trust.",
                            tr: "Günlük hatırlatıcıyı kurmak da kurmamak da sana kalmış. Inner Light bir çalar saat değil — güvendiğini kullanmaya devam et.",
                            es: "El recordatorio diario es tuyo, para ponerlo o dejarlo. Inner Light no es un despertador — sigue usando el que ya usas."
                        ))
                        .foregroundStyle(DS.textSecondary)

                        Text(L10n.text(
                            en: "Not a feed. Not a productivity system. One small return to yourself, each day.",
                            tr: "Bir akış değil. Bir üretkenlik sistemi değil. Her gün, kendine küçük bir dönüş.",
                            es: "No es un feed. No es un sistema de productividad. Un pequeño regreso a ti, cada día."
                        ))
                        .foregroundStyle(DS.textSecondary)

                        Text(L10n.text(
                            en: "Health notice: Inner Light includes optional breathing, movement, cold and heat practices. These are not a substitute for professional medical advice, diagnosis or treatment. Consult a qualified healthcare provider before starting any of them, particularly if you have a pre-existing health condition or injury, or are pregnant. Stop immediately and seek medical attention if you experience pain, dizziness or discomfort. Use all practices at your own risk.",
                            tr: "Sağlık bildirimi: Inner Light, isteğe bağlı nefes, hareket, soğuk ve sıcak pratikleri içerir. Bunlar profesyonel tıbbi tavsiye, tanı veya tedavinin yerini tutmaz. Mevcut bir sağlık durumunuz ya da yaralanmanız varsa veya hamileyseniz, herhangi birine başlamadan önce bir sağlık uzmanına danışın. Ağrı, baş dönmesi veya rahatsızlık hissederseniz hemen durun ve tıbbi yardım alın. Tüm pratikleri kendi sorumluluğunuzda kullanın.",
                            es: "Aviso de salud: Inner Light incluye prácticas opcionales de respiración, movimiento, frío y calor. No sustituyen el consejo médico profesional, el diagnóstico ni el tratamiento. Consulta a un profesional de la salud antes de comenzar cualquiera de ellas, especialmente si tienes una condición de salud preexistente, una lesión o estás embarazada. Detente de inmediato y busca atención médica si experimentas dolor, mareos o malestar. Usa todas las prácticas bajo tu propia responsabilidad."
                        ))
                        .font(.caption)
                        .foregroundStyle(DS.textDim)
                        .lineSpacing(4)

                        HStack(spacing: DS.Space.md) {
                            Link(L10n.text(en: "Privacy Policy", tr: "Gizlilik Politikası", es: "Política de privacidad"),
                                 destination: AppState.privacyPolicyURL)
                            Link(L10n.text(en: "Support", tr: "Destek", es: "Soporte"),
                                 destination: AppState.supportURL)
                        }
                        .font(.subheadline)
                        .foregroundStyle(DS.accentInk)
                    }
                    .font(.body)
                    .lineSpacing(5)
                }
                .padding(.horizontal, DS.Space.lg)

                Spacer()

                Text(L10n.text(
                    en: "One ping. Five questions. One first win.",
                    tr: "Bir bildirim. Beş soru. Bir ilk kazanım.",
                    es: "Un aviso. Cinco preguntas. Un primer logro."
                ))
                .font(.caption)
                .italic()
                .foregroundStyle(DS.textDim)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DS.Space.lg)
                .padding(.bottom, DS.Space.xl)
            }
        }
    }
}
