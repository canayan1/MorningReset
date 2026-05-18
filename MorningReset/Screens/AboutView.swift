import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

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
                        en: "How Morning Reset works",
                        tr: "Morning Reset nasıl çalışır",
                        es: "Cómo funciona Morning Reset"
                    ))
                    .font(DS.Typo.subtitle)
                    .foregroundStyle(DS.textPrimary)

                    VStack(alignment: .leading, spacing: DS.Space.md + 4) {
                        Text(L10n.text(
                            en: "Morning Reset is a short interruption before the scroll begins.",
                            tr: "Morning Reset, kaydırma başlamadan önceki kısa bir müdahaledir.",
                            es: "Morning Reset es una breve interrupción antes de que empiece el scroll."
                        ))
                        .font(.body)
                        .foregroundStyle(DS.textPrimary)

                        Text(L10n.text(
                            en: "Set one morning notification inside the app.",
                            tr: "Uygulama içinde bir sabah bildirimi ayarla.",
                            es: "Configura una notificación matinal dentro de la app."
                        ))
                        .foregroundStyle(DS.textSecondary)

                        Text(L10n.text(
                            en: "When the ping arrives, tap it before you open anything else.",
                            tr: "Bildirim geldiğinde, başka bir şey açmadan önce ona dokun.",
                            es: "Cuando llegue el aviso, ábrelo antes de abrir cualquier otra cosa."
                        ))
                        .foregroundStyle(DS.textSecondary)

                        Text(L10n.text(
                            en: "We guide you through five quick questions, a result, and one immediate first win.",
                            tr: "Seni beş hızlı soru, bir sonuç ve anlık bir ilk kazanım üzerinden yönlendiriyoruz.",
                            es: "Te guiamos a través de cinco preguntas rápidas, un resultado y un primer logro inmediato."
                        ))
                        .foregroundStyle(DS.textSecondary)

                        Text(L10n.text(
                            en: "It is not an alarm clock, a widget, or a giant life system. It helps you do one intentional thing first.",
                            tr: "Bu bir çalar saat, widget veya büyük bir yaşam sistemi değil. Önce kasıtlı bir şey yapmanı sağlar.",
                            es: "No es un despertador, un widget ni un gran sistema de vida. Te ayuda a hacer primero una cosa intencionada."
                        ))
                        .foregroundStyle(DS.textSecondary)

                        Text(L10n.text(
                            en: "Health disclaimer: Morning Reset includes optional breathing and mobility exercises. These are not a substitute for professional medical advice, diagnosis, or treatment. Always consult a qualified healthcare provider before starting any exercise programme, particularly if you have a pre-existing health condition, injury, or are pregnant. Stop immediately and seek medical attention if you experience pain, dizziness, or discomfort. Use all exercises at your own risk.",
                            tr: "Sağlık bildirimi: Morning Reset, isteğe bağlı nefes ve hareketlilik egzersizleri içerir. Bu içerikler, profesyonel tıbbi tavsiye, tanı veya tedavinin yerini tutmaz. Mevcut bir sağlık durumunuz, yaralanmanız varsa ya da hamileyseniz, herhangi bir egzersiz programına başlamadan önce mutlaka bir sağlık uzmanına danışın. Ağrı, baş dönmesi veya rahatsızlık hissederseniz hemen durun ve tıbbi yardım alın. Tüm egzersizleri kendi sorumluluğunuzda kullanın.",
                            es: "Aviso de salud: Morning Reset incluye ejercicios opcionales de respiración y movilidad. Estos no sustituyen el consejo médico profesional, el diagnóstico ni el tratamiento. Consulta siempre a un profesional de la salud antes de comenzar cualquier programa de ejercicio, especialmente si tienes alguna condición de salud preexistente, una lesión o estás embarazada. Detente de inmediato y busca atención médica si experimentas dolor, mareos o malestar. Usa todos los ejercicios bajo tu propia responsabilidad."
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DS.Space.lg)
                .padding(.bottom, DS.Space.xl)
            }
        }
    }
}
