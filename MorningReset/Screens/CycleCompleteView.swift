import SwiftUI

struct CycleCompleteView: View {
    @Environment(AppState.self) private var appState
    @AppStorage(UDKey.selectedIntention) private var selectedIntention: String = IntentionType.focus.rawValue
    @State private var appeared = false

    private var descriptors: [IntentionType: String] { [
        .calm:        L10n.text(en: "Move without noise",          tr: "Gürültüsüz hareket et",         es: "Muévete sin ruido"),
        .focus:       L10n.text(en: "Stay with what matters",      tr: "Önemli olanla kal",              es: "Quédate con lo que importa"),
        .energy:      L10n.text(en: "Protect and use your fuel",   tr: "Enerjini koru ve kullan",        es: "Protege y usa tu energía"),
        .confidence:  L10n.text(en: "Trust your next move",        tr: "Bir sonraki adımına güven",      es: "Confía en tu próximo movimiento"),
        .connection:  L10n.text(en: "Show up with presence",       tr: "Tam anlamıyla var ol",           es: "Preséntate con presencia"),
        .discipline:  L10n.text(en: "Return to clean action",      tr: "Temiz eyleme dön",               es: "Vuelve a la acción limpia"),
    ]}

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: DS.Space.lg) {
                    Text(IntentionType(rawValue: selectedIntention)?.label ?? "")
                        .font(DS.Typo.label)
                        .tracking(1.4)
                        .foregroundStyle(DS.background)
                        .padding(.horizontal, DS.Space.md)
                        .padding(.vertical, 7)
                        .background(DS.accent)
                        .clipShape(Capsule())

                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        Text(L10n.text(en: "7 wins", tr: "7 kazanım", es: "7 logros"))
                            .font(.system(size: 52, design: .serif).weight(.regular))
                            .foregroundStyle(DS.textPrimary)
                        Text(L10n.text(en: "You kept showing up.", tr: "Devam ettin.", es: "Seguiste apareciendo."))
                            .font(.body)
                            .foregroundStyle(DS.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DS.Space.lg)

                Spacer()

                VStack(alignment: .leading, spacing: DS.Space.md) {
                    Text(L10n.text(en: "Choose a new direction", tr: "Yeni bir yön seç", es: "Elige una nueva dirección"))
                        .font(DS.Typo.label)
                        .tracking(1.2)
                        .foregroundStyle(DS.textDim)
                        .padding(.horizontal, DS.Space.lg)

                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: DS.Space.sm + 2
                    ) {
                        ForEach(IntentionType.allCases, id: \.self) { intention in
                            intentionCard(intention)
                        }
                    }
                    .padding(.horizontal, DS.Space.lg)
                }

                Spacer().frame(height: DS.Space.xl - 8)

                Button(L10n.text(en: "Start fresh", tr: "Yeniden başla", es: "Comenzar de nuevo")) {
                    appState.endFlow()
                }
                .font(.system(.body, design: .serif))
                .tracking(0.5)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(DS.accent)
                .foregroundStyle(DS.background)
                .clipShape(Capsule())
                .padding(.horizontal, DS.Space.lg)
                .padding(.bottom, DS.Space.xl)
            }
        }
        .sensoryFeedback(.success, trigger: appeared)
        .onAppear { appeared = true }
    }

    private func intentionCard(_ intention: IntentionType) -> some View {
        let selected = selectedIntention == intention.rawValue
        return Button {
            selectedIntention = intention.rawValue
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(intention.label)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(selected ? DS.background : DS.textPrimary)
                Text(descriptors[intention] ?? "")
                    .font(.caption)
                    .foregroundStyle(selected ? DS.background.opacity(0.8) : DS.textDim)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
            .padding(DS.Space.md)
            .background(selected ? DS.accent : DS.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(selected ? Color.clear : DS.border, lineWidth: DS.hairline)
            )
        }
        .animation(.easeOut(duration: 0.15), value: selected)
    }
}
