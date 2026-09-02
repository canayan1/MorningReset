import UIKit
import CoreImage

// MARK: - Energy read (on-device)
//
// Reads a selfie entirely on-device using Core Image face analysis
// (smile + eye-open) and average brightness. NOTHING leaves the device — no
// network, no third party. The "energy field" is an experiential, playful
// interpretation of your expression, not a medical or scientific reading.

enum MorningEnergy: String, Equatable {
    case radiant   // bright, smiling, eyes open
    case warm      // smiling, gentle
    case steady    // calm, neutral, present
    case foggy     // heavy eyes / dim — still waking up

    var label: String {
        switch self {
        case .radiant: return L10n.text(en: "Radiant", tr: "Işıltılı", es: "Radiante")
        case .warm:    return L10n.text(en: "Warm", tr: "Sıcak", es: "Cálida")
        case .steady:  return L10n.text(en: "Steady", tr: "Dengeli", es: "Serena")
        case .foggy:   return L10n.text(en: "Softly arriving", tr: "Yumuşakça geliyor", es: "Llegando suave")
        }
    }

    var headline: String {
        switch self {
        case .radiant:
            let when = TimeOfDay.current.phrase
            return L10n.text(
                en: "Your field is bright \(when).",
                tr: "\(when.prefix(1).uppercased() + when.dropFirst()) enerji alanın parlak.",
                es: "Tu campo está brillante \(when)."
            )
        case .warm:
            return L10n.text(
                en: "A soft, warm glow around you.",
                tr: "Etrafında yumuşak, sıcak bir parıltı.",
                es: "Un resplandor suave y cálido a tu alrededor."
            )
        case .steady:
            return L10n.text(
                en: "Calm and grounded — quietly present.",
                tr: "Sakin ve dengeli — sessizce buradasın.",
                es: "Tranquila y centrada — presente en calma."
            )
        case .foggy:
            return L10n.text(
                en: "Your energy is gathering.",
                tr: "Enerjin toplanıyor.",
                es: "Tu energía se está reuniendo."
            )
        }
    }

    var detail: String {
        switch self {
        case .radiant:
            return L10n.text(
                en: "Channel it into movement before the day pulls at you.",
                tr: "Gün seni çekmeden önce bunu harekete yönlendir.",
                es: "Canalízalo en movimiento antes de que el día tire de ti."
            )
        case .warm:
            return L10n.text(
                en: "A gentle practice will carry this glow forward.",
                tr: "Nazik bir pratik bu parıltıyı ileri taşır.",
                es: "Una práctica suave llevará este brillo adelante."
            )
        case .steady:
            return L10n.text(
                en: "Hold this calm with something slow and grounding.",
                tr: "Bu sükûneti yavaş, topraklayan bir şeyle koru.",
                es: "Sostén esta calma con algo lento y de raíz."
            )
        case .foggy:
            return L10n.text(
                en: "A few conscious breaths will lift the fog.",
                tr: "Birkaç bilinçli nefes sisi kaldırır.",
                es: "Unas respiraciones conscientes disiparán la niebla."
            )
        }
    }
}

struct EnergyReading: Equatable {
    let energy: MorningEnergy
    let score: Int          // playful 0–100 "energy field" reading
    let smile: Bool
    let eyesOpen: Bool
    let brightness: Double   // 0–1 perceived luminance
    let recommendedPath: EnergyPath

    /// The practice to suggest for today, drawn from the recommended path.
    var recommendedPractice: PathPractice? {
        recommendedPath.practices.first
    }
}

enum EnergyReader {

    /// Analyse a selfie fully on-device. `activePath` lets us keep the
    /// user's chosen tradition when their reading is ambiguous.
    static func read(from image: UIImage, activePath: EnergyPath?) -> EnergyReading {
        let context = CIContext(options: [.useSoftwareRenderer: false])
        let ci = CIImage(image: image)

        var smile = false
        var eyesOpen = true
        if let ci,
           let detector = CIDetector(
               ofType: CIDetectorTypeFace,
               context: context,
               options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
           ) {
            let faces = detector.features(
                in: ci,
                options: [CIDetectorSmile: true, CIDetectorEyeBlink: true]
            ) as? [CIFaceFeature] ?? []
            if let face = faces.max(by: { $0.bounds.width < $1.bounds.width }) {
                smile = face.hasSmile
                eyesOpen = !(face.leftEyeClosed && face.rightEyeClosed)
            }
        }

        let brightness = ci.map { averageLuminance(of: $0, context: context) } ?? 0.5

        let energy: MorningEnergy
        switch (smile, eyesOpen, brightness) {
        case (true, true, let b) where b > 0.45: energy = .radiant
        case (true, _, _):                       energy = .warm
        case (_, true, let b) where b > 0.40:    energy = .steady
        default:                                 energy = .foggy
        }

        var score = 50
        if smile { score += 26 }
        if eyesOpen { score += 10 }
        score += Int((brightness - 0.4) * 45)
        score = min(98, max(28, score))

        return EnergyReading(
            energy: energy,
            score: score,
            smile: smile,
            eyesOpen: eyesOpen,
            brightness: brightness,
            recommendedPath: recommendPath(for: energy, active: activePath)
        )
    }

    // MARK: - Helpers

    private static func recommendPath(for energy: MorningEnergy, active: EnergyPath?) -> EnergyPath {
        switch energy {
        case .radiant: return .qigong       // move the high energy through the body
        case .warm:    return active ?? .reiki
        case .steady:  return active ?? .reiki   // gentle, grounding
        case .foggy:   return .breathwork   // breath wakes the system
        }
    }

    private static func averageLuminance(of image: CIImage, context: CIContext) -> Double {
        let extent = image.extent
        guard extent.width >= 1, extent.height >= 1,
              let filter = CIFilter(
                  name: "CIAreaAverage",
                  parameters: [kCIInputImageKey: image, kCIInputExtentKey: CIVector(cgRect: extent)]
              ),
              let output = filter.outputImage else { return 0.5 }

        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(
            output,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )
        let r = Double(bitmap[0]) / 255.0
        let g = Double(bitmap[1]) / 255.0
        let b = Double(bitmap[2]) / 255.0
        return 0.299 * r + 0.587 * g + 0.114 * b
    }
}

// MARK: - Energy teachings
//
// A grounded teaching drawn from the recommended tradition (reiki / breathwork /
// qigong) and the current energy state. Researched from authentic sources;
// wellbeing and energy-practice framing only — no medical claims.

extension EnergyReading {
    var teaching: String {
        EnergyTeachings.text(path: recommendedPath, energy: energy)
    }
}

extension MorningEnergy {
    var emoji: String {
        switch self {
        case .radiant: return "☀️"
        case .warm:    return "🌅"
        case .steady:  return "🍃"
        case .foggy:   return "🌙"
        }
    }
}

enum EnergyTeachings {
    static func text(path: EnergyPath, energy: MorningEnergy) -> String {
        switch (path, energy) {

        // ── Reiki ──────────────────────────────────────────────
        case (.reiki, .radiant):
            return L10n.text(
                en: "In Reiki, this is ki moving freely and brightly, with little stagnation to clear. A minute of gassho — hands together at the heart — helps you gather and steady that flow rather than spend it all at once.",
                tr: "Reiki'de bu, ki'nin özgürce ve parlak biçimde aktığı, dağıtılacak çok az durgunluğun kaldığı andır. Bir dakikalık gassho — eller kalbin önünde birleşik — bu akışı bir anda harcamak yerine toplayıp dengelemene yardım eder.",
                es: "En el Reiki, esto es el ki fluyendo libre y luminoso, con poco estancamiento por despejar. Un minuto de gassho — las manos juntas a la altura del corazón — te ayuda a reunir y serenar ese flujo en vez de gastarlo todo de golpe.")
        case (.reiki, .warm):
            return L10n.text(
                en: "A soft glow points to ki flowing gently and in balance. Rest your palms over your heart or lower belly and let the warmth settle — the traditional way Reiki invites ki to deepen — then carry it down with a few slow joshin kokyu ho breaths.",
                tr: "Yumuşak bir parıltı, ki'nin nazikçe ve dengeli aktığına işaret eder. Avuçlarını kalbinin ya da alt karnının üzerine koy ve sıcaklığın yerleşmesine izin ver — Reiki'nin ki'yi derinleştirmeye davet ettiği geleneksel yol — sonra birkaç yavaş joshin kokyu ho nefesiyle onu aşağıya taşı.",
                es: "Un brillo suave indica que el ki fluye con suavidad y en equilibrio. Apoya las palmas sobre el corazón o el bajo vientre y deja que el calor se asiente — la manera tradicional en que el Reiki invita al ki a profundizarse — y luego llévalo hacia abajo con unas cuantas respiraciones lentas de joshin kokyu ho.")
        case (.reiki, .steady):
            return L10n.text(
                en: "Calm and grounded reflects ki that is even and unhurried — the balanced baseline Reiki cultivates. Begin with gassho to anchor mind and body, then let joshin kokyu ho breathing keep the current smooth and the center clear.",
                tr: "Sakin ve köklü oluş, ki'nin düzenli ve telaşsız olduğunu yansıtır — Reiki'nin geliştirdiği dengeli temel hal. Zihni ve bedeni demirlemek için gassho ile başla, sonra joshin kokyu ho nefesinin akımı pürüzsüz ve merkezi açık tutmasına izin ver.",
                es: "La calma y el arraigo reflejan un ki parejo y sin prisa — la base equilibrada que el Reiki cultiva. Empieza con gassho para anclar mente y cuerpo, y deja que la respiración joshin kokyu ho mantenga la corriente fluida y el centro despejado.")
        case (.reiki, .foggy):
            return L10n.text(
                en: "Heaviness can reflect byosen — places where ki feels pooled or stagnant — something Reiki gently moves rather than a flaw. Kenyoku, brushing the hands down across the chest and arms, clears that heaviness; follow it with a few slow breaths to ease awake.",
                tr: "Ağırlık, byosen'i yansıtabilir — ki'nin biriktiği ya da durgunlaştığı yerler — Reiki'nin nazikçe hareket ettirdiği bir şey, bir kusur değil. Kenyoku, ellerin göğüs ve kollardan aşağı süpürülmesi, o ağırlığı temizler; ardından birkaç yavaş nefesle yavaşça uyanışa geç.",
                es: "La pesadez puede reflejar el byosen — zonas donde el ki se siente acumulado o estancado — algo que el Reiki mueve con suavidad, no un defecto. El kenyoku, deslizar las manos por el pecho y los brazos hacia abajo, despeja esa pesadez; sigue con unas respiraciones lentas para despertar con calma.")

        // ── Breathwork ─────────────────────────────────────────
        case (.breathwork, .radiant):
            return L10n.text(
                en: "This is abundant prana already moving freely, the solar pingala channel bright and alert. Worth channeling rather than amplifying: a few minutes of ujjayi, the soft “ocean” breath, gives that brightness a smooth, steady rhythm to flow along.",
                tr: "Bu, zaten özgürce hareket eden bol prana'dır; güneş kanalı pingala parlak ve uyanık. Artırmaktan çok yönlendirmeye değer: birkaç dakikalık ujjayi, o yumuşak “okyanus” nefesi, bu parlaklığa boyunca akabileceği pürüzsüz, düzenli bir ritim verir.",
                es: "Esto es prana abundante que ya se mueve con libertad, el canal solar pingala luminoso y despierto. Conviene encauzarlo más que amplificarlo: unos minutos de ujjayi, la suave respiración “del océano”, le dan a ese brillo un ritmo fluido y constante por el que discurrir.")
        case (.breathwork, .warm):
            return L10n.text(
                en: "Prana is present and pleasant, the activating and calming currents close to balance. Nadi shodhana — alternate-nostril breathing — draws the two channels into quiet equilibrium and lets the warmth hold through the rest of \(TimeOfDay.current.span).",
                tr: "Prana mevcut ve hoş; etkinleştiren ve sakinleştiren akımlar dengeye yakın. Nadi shodhana — dönüşümlü burun deliği nefesi — iki kanalı sessiz bir dengeye çeker ve sıcaklığın \(TimeOfDay.current.span) boyunca korunmasını sağlar.",
                es: "El prana está presente y es grato, con las corrientes activadora y calmante cerca del equilibrio. El nadi shodhana — la respiración alterna por las fosas nasales — lleva ambos canales a un equilibrio sereno y deja que el calor se sostenga durante \(TimeOfDay.current.span).")
        case (.breathwork, .steady):
            return L10n.text(
                en: "Prana is grounded and evenly distributed, the nervous system poised between effort and ease. Coherent breathing at a slow, even pace — or a few rounds of bhramari, the low humming breath — holds that calm as the day begins.",
                tr: "Prana köklü ve düzgün dağılmış; sinir sistemi çaba ile rahatlık arasında dengede. Yavaş, düzenli bir tempoda uyumlu nefes — ya da birkaç tur bhramari, o alçak vızıltı nefesi — gün başlarken bu sakinliği korur.",
                es: "El prana está arraigado y repartido de manera uniforme, el sistema nervioso en equilibrio entre el esfuerzo y la calma. La respiración coherente a un ritmo lento y parejo — o unas rondas de bhramari, la respiración de zumbido grave — sostiene esa calma al comenzar el día.")
        case (.breathwork, .foggy):
            return L10n.text(
                en: "Prana is still low and pooled, the body lingering in its slower night rhythm. A gentle, unforced kapalabhati — light rapid exhales — coaxes the system awake; keep it brief, and simply slow down if you feel lightheaded.",
                tr: "Prana hâlâ düşük ve birikmiş; beden gecenin daha yavaş ritminde oyalanıyor. Nazik, zorlanmamış bir kapalabhati — hafif, hızlı nefes vermeler — sistemi uyanışa çağırır; kısa tut ve başın dönerse yalnızca yavaşla.",
                es: "El prana sigue bajo y acumulado, el cuerpo aún en su ritmo nocturno más lento. Un kapalabhati suave y sin forzar — exhalaciones ligeras y rápidas — invita al sistema a despertar; hazlo breve y simplemente baja el ritmo si sientes mareo.")

        // ── Qigong ─────────────────────────────────────────────
        case (.qigong, .radiant):
            return L10n.text(
                en: "Bright, alert energy reflects abundant qi already circulating freely through your meridians. Move with it rather than contain it: flowing forms like “Lifting the Sky” open the channels and let strong qi spread evenly — slow and continuous, so it circulates instead of scattering.",
                tr: "Parlak, uyanık enerji, meridyenlerinde zaten özgürce dolaşan bol qi'yi yansıtır. Onu tutmaktan çok onunla birlikte hareket et: “Lifting the Sky” (Göğü Kaldırmak) gibi akıcı formlar kanalları açar ve güçlü qi'nin eşit yayılmasını sağlar — yavaş ve sürekli, böylece dağılmak yerine dolaşır.",
                es: "La energía vívida y despierta refleja un qi abundante que ya circula con libertad por tus meridianos. Muévete con él en vez de contenerlo: las formas fluidas como “Lifting the Sky” (Levantar el Cielo) abren los canales y dejan que el qi fuerte se reparta de manera uniforme — lento y continuo, para que circule en lugar de dispersarse.")
        case (.qigong, .warm):
            return L10n.text(
                en: "A soft glow reflects qi that is present but not yet gathered. Rather than spend it, draw it inward: scoop the palms up and sink them to rest on the lower dantian, holding a few breaths to let the warmth settle into its reservoir.",
                tr: "Yumuşak bir parıltı, mevcut ama henüz toplanmamış qi'yi yansıtır. Onu harcamak yerine içeri çek: avuçlarını yukarı doğru kepçele ve alt dantian'a inerek dinlenmeye bırak, sıcaklığın bu hazneye yerleşmesi için birkaç nefes tut.",
                es: "Un brillo suave refleja un qi que está presente pero aún no se ha reunido. En vez de gastarlo, llévalo hacia dentro: recoge las palmas hacia arriba y bájalas para posarlas sobre el bajo dantian, sosteniendo unas respiraciones para que el calor se asiente en su depósito.")
        case (.qigong, .steady):
            return L10n.text(
                en: "Calm, even energy reflects qi that is settled and rooted. This is the moment for zhan zhuang — stand with knees softly bent, weight sinking into the feet — letting stillness root your qi to the dantian and the earth.",
                tr: "Sakin, düzenli enerji, yerleşmiş ve köklenmiş qi'yi yansıtır. Bu, zhan zhuang anıdır — dizler hafifçe bükük dur, ağırlık ayaklara insin — durağanlığın qi'ni dantian'a ve toprağa köklemesine izin ver.",
                es: "La energía calma y pareja refleja un qi asentado y arraigado. Este es el momento del zhan zhuang — de pie con las rodillas ligeramente flexionadas, el peso hundiéndose en los pies — dejando que la quietud arraigue tu qi al dantian y a la tierra.")
        case (.qigong, .foggy):
            return L10n.text(
                en: "Heaviness reflects qi that grew stagnant and slow overnight. Gentle shaking is the traditional remedy: stand loose, bounce softly through the knees, and let the body tremble to break up stagnation and wake the channels.",
                tr: "Ağırlık, gece boyunca durgunlaşıp yavaşlayan qi'yi yansıtır. Nazik sallanma geleneksel çaredir: gevşek dur, dizlerden yumuşakça zıpla ve bedenin titremesine izin ver; böylece durgunluk dağılır ve kanallar uyanır.",
                es: "La pesadez refleja un qi que se volvió estancado y lento durante la noche. El balanceo suave es el remedio tradicional: ponte de pie relajado, rebota suavemente con las rodillas y deja que el cuerpo tiemble para deshacer el estancamiento y despertar los canales.")
        }
    }
}
