import SwiftUI

struct MorningPagesView: View {
    @Environment(AppState.self) private var appState
    @FocusState private var isFocused: Bool

    @State private var text:  String = ""
    @State private var saved: Bool   = false

    private var mode: MorningMode { appState.sessionMode }

    private var prompt: String {
        switch mode {
        case .protect: return L10n.text(en: "What will you protect today?",
                                        tr: "Bugün neyi koruyacaksın?",
                                        es: "¿Qué vas a proteger hoy?")
        case .steady:  return L10n.text(en: "What are you returning to today?",
                                        tr: "Bugün neye geri dönüyorsun?",
                                        es: "¿A qué estás volviendo hoy?")
        case .push:    return L10n.text(en: "What's the one thing that moves the needle today?",
                                        tr: "Bugün ibreyi ne hareket ettirecek?",
                                        es: "¿Qué es lo único que mueve la aguja hoy?")
        }
    }

    private var alreadyWritten: Bool { MorningPagesStore.hasEntryForToday() }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                if saved || alreadyWritten {
                    savedState
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    writeState
                        .transition(.opacity)
                }

                Spacer()
            }
            .padding(.horizontal, DS.Space.lg)
            .animation(.easeOut(duration: 0.3), value: saved)
            .animation(.easeOut(duration: 0.3), value: alreadyWritten)
        }
        .onAppear {
            if !alreadyWritten { isFocused = true }
        }
    }

    // MARK: - Write state

    private var writeState: some View {
        VStack(alignment: .leading, spacing: DS.Space.xl) {

            Text(prompt)
                .font(.system(size: 26, weight: .regular, design: .serif))
                .foregroundStyle(DS.textPrimary)
                .lineSpacing(4)

            // Single-sentence text field
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(L10n.text(en: "One sentence…", tr: "Tek bir cümle…", es: "Una frase…"))
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(DS.textDim)
                        .padding(.top, 2)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $text)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(DS.textPrimary)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 72, maxHeight: 140)
                    .focused($isFocused)
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(text.isEmpty ? DS.border : DS.accent)
                    .frame(height: 1)
                    .animation(.easeOut(duration: 0.2), value: text.isEmpty)
            }
            .padding(.bottom, DS.Space.xs)

            VStack(spacing: DS.Space.sm) {
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                Button(L10n.text(en: "Save", tr: "Kaydet", es: "Guardar")) {
                    saveEntry()
                }
                .font(.system(.body, design: .serif))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(trimmed.isEmpty ? DS.surface : DS.accent)
                .foregroundStyle(trimmed.isEmpty ? DS.textDim : DS.background)
                .clipShape(Capsule())
                .disabled(trimmed.isEmpty)

                Button(L10n.text(en: "Skip for today", tr: "Bugün atla", es: "Saltar hoy")) {
                    appState.showPremiumHub()
                }
                .font(.subheadline)
                .foregroundStyle(DS.textDim)
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Saved state

    private var savedState: some View {
        VStack(alignment: .leading, spacing: DS.Space.lg) {
            Text(L10n.text(en: "Saved.", tr: "Kaydedildi.", es: "Guardado."))
                .font(.system(size: 38, weight: .light, design: .serif))
                .foregroundStyle(DS.textPrimary)

            if let entry = MorningPagesStore.todayEntry() {
                Text(entry.text)
                    .font(.system(.body, design: .serif))
                    .italic()
                    .foregroundStyle(DS.textSecondary)
                    .lineSpacing(4)
            }

            Button(L10n.text(en: "Done", tr: "Tamam", es: "Listo")) {
                appState.showPremiumHub()
            }
            .font(.system(.body, design: .serif))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(DS.accent)
            .foregroundStyle(DS.background)
            .clipShape(Capsule())
            .padding(.top, DS.Space.sm)
        }
    }

    // MARK: - Save

    private func saveEntry() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let entry = MorningPageEntry(mode: mode.rawValue, prompt: prompt, text: trimmed)
        MorningPagesStore.append(entry)
        isFocused = false
        withAnimation { saved = true }
    }
}
