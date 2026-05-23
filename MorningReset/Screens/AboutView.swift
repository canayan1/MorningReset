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
                            en: "Morning Reset partners with the moment you open your eyes.",
                            tr: "Morning Reset, gözlerini açtığın ana ortaktır.",
                            es: "Morning Reset te acompaña en el momento en que abres los ojos."
                        ))
                        .font(.body)
                        .foregroundStyle(DS.textPrimary)

                        Text(L10n.text(
                            en: "Set your wake time inside the app. Keep using your trusted alarm.",
                            tr: "Uygulama içinde uyanma saatini ayarla. Güvendiğin alarmını kullanmaya devam et.",
                            es: "Define tu hora de despertar en la app. Sigue usando tu alarma de siempre."
                        ))
                        .foregroundStyle(DS.textSecondary)

                        Text(L10n.text(
                            en: "From the night you set it, Morning Reset waits on your lock screen — the first thing you see when you reach for your phone.",
                            tr: "Ayarladığın geceden itibaren Morning Reset kilit ekranında seni bekler — telefonu eline aldığında gördüğün ilk şey.",
                            es: "Desde la noche en que lo configuras, Morning Reset espera en tu pantalla bloqueada — lo primero que ves al tomar el teléfono."
                        ))
                        .foregroundStyle(DS.textSecondary)

                        Text(L10n.text(
                            en: "Tap it before anything else. We guide you through five quick questions, a result, and one concrete first win.",
                            tr: "Başka bir şeyden önce ona dokun. Seni beş hızlı soru, bir sonuç ve somut bir ilk kazanım üzerinden yönlendiriyoruz.",
                            es: "Tócalo antes que nada. Te guiamos por cinco preguntas rápidas, un resultado y una primera victoria concreta."
                        ))
                        .foregroundStyle(DS.textSecondary)

                        Text(L10n.text(
                            en: "Not a feed. Not a productivity system. A small ritual that wins the first three minutes of your day.",
                            tr: "Bir akış değil. Bir üretkenlik sistemi değil. Günün ilk üç dakikasını kazanan küçük bir ritüel.",
                            es: "No es un feed. No es un sistema de productividad. Un pequeño ritual que gana los primeros tres minutos del día."
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
