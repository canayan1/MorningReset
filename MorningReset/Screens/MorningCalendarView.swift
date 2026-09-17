import SwiftUI

// MARK: - The mornings
//
// A month of waking pulses. One square a day, filled in proportion to how the
// morning compared with the usual one, so the month reads as a texture before
// it reads as numbers — a run of calm mornings looks calm from across the room.
//
// Nothing here is a diagnosis and the screen says so once, quietly, at the
// bottom. A waking pulse moves with sleep, a late meal, a cold coming on and
// the time of the month; the useful thing about it is the shape over weeks,
// which is exactly what a month at a glance shows and a single number does not.

struct MorningCalendarView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var month = Calendar.current.startOfDay(for: Date())
    @State private var selected: MorningRecord?

    private let calendar = Calendar.current

    var body: some View {
        ZStack {
            AppBackground(intensity: 0.35)

            VStack(spacing: 0) {
                header
                monthHeader
                Spacer().frame(height: DS.Space.md)
                weekdayRow
                Spacer().frame(height: DS.Space.sm)
                grid
                Spacer().frame(height: DS.Space.lg)
                summary
                Spacer()
                footnote
            }
            .padding(.horizontal, DS.Space.lg)
        }
        .accessibilityIdentifier("mornings.screen")
    }

    // MARK: - Chrome

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DS.textSecondary)
            }
            .accessibilityLabel(L10n.text(en: "Close", tr: "Kapat", es: "Cerrar"))
            Spacer()
        }
        .padding(.top, 20)
        .padding(.bottom, DS.Space.lg)
    }

    private var monthHeader: some View {
        HStack {
            stepButton("chevron.left", by: -1)
            Spacer()
            VStack(spacing: 2) {
                Text(L10n.text(en: "YOUR MORNINGS", tr: "SABAHLARIN", es: "TUS MAÑANAS"))
                    .font(DS.Typo.label).kerning(1.4)
                    .foregroundStyle(DS.textSecondary)
                Text(month, format: .dateTime.month(.wide).year().locale(L10n.locale))
                    .font(DS.Typo.title)
                    .foregroundStyle(DS.textPrimary)
            }
            Spacer()
            stepButton("chevron.right", by: 1)
                .opacity(isCurrentMonth ? 0.25 : 1)
                .disabled(isCurrentMonth)
        }
    }

    private func stepButton(_ symbol: String, by months: Int) -> some View {
        Button {
            if let next = calendar.date(byAdding: .month, value: months, to: month) {
                withAnimation(.easeOut(duration: 0.2)) { month = next; selected = nil }
            }
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DS.textSecondary)
                .frame(width: 34, height: 34)
                .background(DS.surface, in: Circle())
        }
    }

    private var isCurrentMonth: Bool {
        calendar.isDate(month, equalTo: Date(), toGranularity: .month)
    }

    private var weekdayRow: some View {
        HStack(spacing: 6) {
            ForEach(orderedWeekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(DS.Typo.micro)
                    .foregroundStyle(DS.textDim)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    /// The week starts where the reader's calendar starts it — Monday in most
    /// of Europe, Sunday in the US — so the grid matches the phone's own.
    private var orderedWeekdaySymbols: [String] {
        // The names come from the app's language; the week still starts where
        // the reader's own calendar starts it, which is a region question.
        var naming = calendar
        naming.locale = L10n.locale
        let symbols = naming.veryShortStandaloneWeekdaySymbols
        let first = calendar.firstWeekday - 1
        return Array(symbols[first...] + symbols[..<first])
    }

    // MARK: - Grid

    private var grid: some View {
        VStack(spacing: 6) {
            ForEach(weeks.indices, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(weeks[row].indices, id: \.self) { column in
                        if let day = weeks[row][column] {
                            dayCell(day)
                        } else {
                            Color.clear.frame(maxWidth: .infinity).aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
        }
    }

    /// The month laid out in weeks, padded with blanks so the first day lands
    /// under the right weekday.
    private var weeks: [[Date?]] {
        guard let interval = calendar.dateInterval(of: .month, for: month) else { return [] }
        let days = calendar.range(of: .day, in: .month, for: month)?.count ?? 30
        let leading = (calendar.component(.weekday, from: interval.start) - calendar.firstWeekday + 7) % 7

        var cells: [Date?] = Array(repeating: nil, count: leading)
        for offset in 0..<days {
            cells.append(calendar.date(byAdding: .day, value: offset, to: interval.start))
        }
        while cells.count % 7 != 0 { cells.append(nil) }
        return stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<$0 + 7]) }
    }

    private func dayCell(_ day: Date) -> some View {
        let record = records[calendar.startOfDay(for: day)]
        let isToday = calendar.isDateInToday(day)
        let isSelected = selected.map { calendar.isDate($0.date, inSameDayAs: day) } ?? false

        return Button {
            withAnimation(.easeOut(duration: 0.2)) {
                selected = (isSelected ? nil : record)
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(fill(for: record))
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(isSelected ? DS.accentInk : (isToday ? DS.accent : DS.border),
                                  lineWidth: isSelected || isToday ? 1.5 : DS.hairline)

                VStack(spacing: 1) {
                    Text("\(calendar.component(.day, from: day))")
                        .font(.system(size: 11, weight: record == nil ? .regular : .medium))
                        .foregroundStyle(record == nil ? DS.textDim : DS.textPrimary)
                    if let bpm = record?.bpm {
                        Text("\(bpm)")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(DS.accentInk)
                            .monospacedDigit()
                    } else if record?.smiled == true {
                        Circle().fill(DS.accent).frame(width: 3, height: 3)
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .disabled(record == nil)
        .accessibilityLabel(accessibilityLabel(day: day, record: record))
    }

    /// How full the square is: a calm morning relative to the usual one is
    /// pale, a fast one is strong. With nothing to compare against yet, every
    /// morning is simply marked as having happened.
    private func fill(for record: MorningRecord?) -> Color {
        guard let record else { return DS.surface.opacity(0.45) }
        guard let bpm = record.bpm, let typical = MorningLogStore.typicalBPM() else {
            return DS.accentSoft.opacity(0.22)
        }
        let ratio = Double(bpm) / Double(typical)
        let strength = min(1, max(0, (ratio - 0.88) / 0.3))
        return DS.accent.opacity(0.12 + strength * 0.42)
    }

    private func accessibilityLabel(day: Date, record: MorningRecord?) -> String {
        let date = day.formatted(.dateTime.day().month(.wide).locale(L10n.locale))
        guard let record else {
            return L10n.text(en: "\(date)", tr: "\(date)", es: "\(date)")
        }
        guard let bpm = record.bpm else {
            return L10n.text(en: "\(date), morning done", tr: "\(date), sabah tamam", es: "\(date), mañana hecha")
        }
        return L10n.text(en: "\(date), \(bpm) beats per minute",
                         tr: "\(date), dakikada \(bpm) atım",
                         es: "\(date), \(bpm) latidos por minuto")
    }

    private var records: [Date: MorningRecord] {
        Dictionary(MorningLogStore.month(containing: month).map {
            (calendar.startOfDay(for: $0.date), $0)
        }, uniquingKeysWith: { first, _ in first })
    }

    // MARK: - Below the grid

    @ViewBuilder
    private var summary: some View {
        if let selected {
            selectedCard(selected)
        } else {
            monthSummary
        }
    }

    private func selectedCard(_ record: MorningRecord) -> some View {
        VStack(spacing: DS.Space.xs) {
            Text(record.date.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(L10n.locale)))
                .font(DS.Typo.label).kerning(1.2)
                .foregroundStyle(DS.textSecondary)

            if let bpm = record.bpm {
                HStack(alignment: .firstTextBaseline, spacing: DS.Space.xs) {
                    Text("\(bpm)")
                        .font(.system(size: 34, weight: .light, design: .serif))
                        .foregroundStyle(DS.textPrimary)
                        .monospacedDigit()
                    Text("BPM")
                        .font(DS.Typo.label).kerning(1.6)
                        .foregroundStyle(DS.textDim)
                }
                if let typical = MorningLogStore.typicalBPM() {
                    Text(comparison(bpm: bpm, typical: typical))
                        .font(.caption)
                        .foregroundStyle(DS.textSecondary)
                }
            } else {
                Text(L10n.text(en: "A morning you showed up for.",
                               tr: "Geldiğin bir sabah.",
                               es: "Una mañana en la que apareciste."))
                    .font(.caption)
                    .foregroundStyle(DS.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Space.md)
        .background(DS.surface, in: RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous))
    }

    /// What the morning was like, never how far off it was.
    ///
    /// The arithmetic is still a comparison with this person's own usual
    /// morning — there is nothing else worth comparing a waking pulse to —
    /// but the sentence never is. "Eight above your usual" is a verdict with
    /// a number attached, and it lands on someone who has been awake for
    /// ninety seconds. A lively morning is named as lively and then followed
    /// by an invitation, which is the one thing that is actually useful: the
    /// day is still unwritten, and it could be a slow one.
    ///
    /// Four beats is inside the noise of a night's sleep, so under that the
    /// honest thing is to name the steadiness rather than invent a story.
    private func comparison(bpm: Int, typical: Int) -> String {
        let delta = bpm - typical

        if delta <= -4 {
            return L10n.text(en: "You woke up settled. Carry that with you.",
                             tr: "Sakin uyanmışsın. Bunu yanında taşı.",
                             es: "Despertaste en calma. Llévala contigo.")
        }
        if delta < 4 {
            return L10n.text(en: "Your own steady morning.",
                             tr: "Kendi dingin sabahın.",
                             es: "Tu propia mañana serena.")
        }
        return L10n.text(en: "Awake and lively. A slow day, maybe?",
                         tr: "Uyanık ve canlı. Bugünü sakin geçirsen mi acaba?",
                         es: "Despierta y con brío. ¿Un día tranquilo, quizá?")
    }

    private var monthSummary: some View {
        let month = MorningLogStore.month(containing: month)
        let readings = month.compactMap(\.bpm)
        return HStack(spacing: 0) {
            summaryItem(value: "\(month.count)",
                        label: L10n.text(en: "MORNINGS", tr: "SABAH", es: "MAÑANAS"))
            if !readings.isEmpty {
                divider
                summaryItem(value: "\(readings.reduce(0, +) / readings.count)",
                            label: L10n.text(en: "AVERAGE", tr: "ORTALAMA", es: "PROMEDIO"))
                divider
                summaryItem(value: "\(readings.min() ?? 0)",
                            label: L10n.text(en: "CALMEST", tr: "EN SAKİN", es: "MÁS CALMA"))
            }
        }
        .padding(.vertical, DS.Space.md)
        .background(DS.surface, in: RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous))
    }

    private var divider: some View {
        Rectangle().fill(DS.divider).frame(width: DS.hairline, height: 30)
    }

    private func summaryItem(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 24, weight: .light, design: .serif))
                .foregroundStyle(DS.textPrimary)
                .monospacedDigit()
            Text(label)
                .font(DS.Typo.micro).kerning(1.2)
                .foregroundStyle(DS.textDim)
        }
        .frame(maxWidth: .infinity)
    }

    private var footnote: some View {
        Text(L10n.text(
            en: "A waking pulse moves with sleep, a late meal, a cold coming on. This is for noticing your own shape over weeks — it is not a medical measurement.",
            tr: "Uyanma nabzı uykuyla, geç yemekle, gelmekte olan bir soğuk algınlığıyla değişir. Bu, haftalar içindeki kendi şeklini fark etmek için — tıbbi bir ölçüm değil.",
            es: "El pulso al despertar cambia con el sueño, una cena tardía, un resfriado en camino. Esto sirve para notar tu propia forma a lo largo de semanas — no es una medición médica."
        ))
        .font(DS.Typo.micro)
        .foregroundStyle(DS.textDim)
        .multilineTextAlignment(.center)
        .lineSpacing(2)
        .padding(.bottom, DS.Space.lg)
    }
}
