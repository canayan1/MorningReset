import Foundation

struct PathSection: Equatable {
    let heading: String
    let body: String
}

struct PathPractice: Identifiable, Equatable {
    let id: String
    let symbol: String
    let title: String
    let how: String
    let why: String
    let checkPrompt: String
    let winTitle: String
    let winBody: String

    var presentation: FirstWinPresentation {
        FirstWinPresentation(symbol: symbol, title: title, how: how, checkPrompt: checkPrompt, winTitle: winTitle, winBody: winBody)
    }
}

enum EnergyPath: String, Codable, CaseIterable, Identifiable, Equatable {
    case reiki
    case breathwork
    case qigong

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .reiki:      return "hands.and.sparkles.fill"
        case .breathwork: return "wind"
        case .qigong:     return "figure.mind.and.body"
        }
    }

    var title: String {
        switch self {
        case .reiki:      return L10n.text(en: "Reiki", tr: "Reiki", es: "Reiki")
        case .breathwork: return L10n.text(en: "Breathwork", tr: "Nefes Çalışması", es: "Respiración")
        case .qigong:     return L10n.text(en: "Qigong", tr: "Qigong", es: "Qigong")
        }
    }

    var essence: String {
        switch self {
        case .reiki:      return L10n.text(en: "Channel calm, healing energy through your hands.", tr: "Ellerinden geçen sakin, şifalı enerjiyi yönlendir.", es: "Canaliza energía serena y sanadora con tus manos.")
        case .breathwork: return L10n.text(en: "Raise your life force through the breath.", tr: "Yaşam gücünü nefesle yükselt.", es: "Eleva tu fuerza vital a través de la respiración.")
        case .qigong:     return L10n.text(en: "Move gently and let your energy flow.", tr: "Nazikçe hareket et, enerjini akıt.", es: "Muévete con suavidad y deja fluir tu energía.")
        }
    }

    var disclaimer: String {
        switch self {
        case .reiki:
            return L10n.text(
                en: "Reiki is a spiritual practice for wellbeing and relaxation, not a medical treatment. It doesn't replace professional care.",
                tr: "Reiki, esenlik ve rahatlama için ruhsal bir pratiktir; tıbbi bir tedavi değildir. Profesyonel bakımın yerini tutmaz.",
                es: "El Reiki es una práctica espiritual de bienestar y relajación, no un tratamiento médico. No sustituye la atención profesional."
            )
        case .breathwork:
            return L10n.text(
                en: "Breathe gently and never strain. Skip forceful breaths if you are pregnant or have heart or blood-pressure conditions. This is a wellbeing practice, not medical advice.",
                tr: "Nazikçe nefes al, asla zorlama. Hamileysen ya da kalp/tansiyon rahatsızlığın varsa güçlü nefesleri atla. Bu, esenlik pratiğidir; tıbbi tavsiye değildir.",
                es: "Respira con suavidad y sin forzar. Evita las respiraciones intensas si estás embarazada o tienes problemas cardíacos o de presión. Es una práctica de bienestar, no consejo médico."
            )
        case .qigong:
            return L10n.text(
                en: "Move within comfort and never to strain. Qigong is a gentle wellbeing practice, not a medical treatment.",
                tr: "Rahatın elverdiğince hareket et, asla zorlama. Qigong nazik bir esenlik pratiğidir; tıbbi tedavi değildir.",
                es: "Muévete dentro de tu comodidad, sin forzar. El Qigong es una práctica suave de bienestar, no un tratamiento médico."
            )
        }
    }

    var basics: [PathSection] {
        switch self {
        case .reiki:
            return [
                PathSection(
                    heading: L10n.text(en: "What Reiki is", tr: "Reiki nedir", es: "Qué es el Reiki"),
                    body: L10n.text(
                        en: "Reiki (霊気) is a Japanese energy practice developed by Mikao Usui in 1922. \"Rei\" means universal or spiritual, and \"ki\" means life energy. Practitioners gently rest their hands on the body to guide this energy and invite balance, calm, and ease.",
                        tr: "Reiki (霊気), Mikao Usui tarafından 1922'de geliştirilen Japon kökenli bir enerji pratiğidir. \"Rei\" evrensel ya da ruhsal, \"ki\" ise yaşam enerjisi anlamına gelir. Uygulayıcılar ellerini bedene nazikçe koyarak bu enerjiyi yönlendirir; denge, sükunet ve rahatlık davet eder.",
                        es: "El Reiki (霊気) es una práctica energética japonesa desarrollada por Mikao Usui en 1922. \"Rei\" significa universal o espiritual, y \"ki\", energía vital. Quien lo practica apoya suavemente las manos sobre el cuerpo para guiar esa energía e invitar equilibrio, calma y serenidad."
                    )
                ),
                PathSection(
                    heading: L10n.text(en: "The idea of ki", tr: "Ki fikri", es: "La idea del ki"),
                    body: L10n.text(
                        en: "In this tradition, ki is the life energy moving through every living thing. When it flows freely you feel vital and at ease; when it stalls you feel heavy or scattered. Morning Reiki is a quiet way to clear and replenish it before the day begins.",
                        tr: "Bu gelenekte ki, her canlının içinden geçen yaşam enerjisidir. Serbestçe aktığında diri ve huzurlu hissedersin; tıkandığında ağır ya da dağınık. Sabah Reiki'si, gün başlamadan bu enerjiyi temizlemenin ve tazelemenin sessiz bir yoludur.",
                        es: "En esta tradición, el ki es la energía vital que recorre todo ser vivo. Cuando fluye libre te sientes pleno y sereno; cuando se estanca, pesado o disperso. El Reiki matinal es una forma silenciosa de limpiarlo y renovarlo antes de empezar el día."
                    )
                ),
                PathSection(
                    heading: L10n.text(en: "The Five Precepts (Gokai)", tr: "Beş İlke (Gokai)", es: "Los Cinco Principios (Gokai)"),
                    body: L10n.text(
                        en: "Usui taught five principles to live by, each beginning \"Just for today\": do not anger, do not worry, be grateful, work honestly, and be kind to every living thing. Many practitioners recite them each morning to set the tone of the day.",
                        tr: "Usui, her biri \"Sadece bugün\" diye başlayan beş yaşam ilkesi öğretti: öfkelenme, endişelenme, şükret, dürüstçe çalış ve her canlıya nazik ol. Birçok uygulayıcı günün tonunu belirlemek için bunları her sabah tekrarlar.",
                        es: "Usui enseñó cinco principios para vivir, cada uno comienza con \"Solo por hoy\": no te enojes, no te preocupes, sé agradecido, trabaja con honestidad y sé amable con todo ser vivo. Muchos los recitan cada mañana para marcar el tono del día."
                    )
                ),
                PathSection(
                    heading: L10n.text(en: "Your morning practice", tr: "Sabah pratiğin", es: "Tu práctica matinal"),
                    body: L10n.text(
                        en: "A few minutes is enough: still the mind with palms together (Gasshō), cleanse with the breath, rest your hands on your body's centers, and let the energy settle. No belief is required — only your attention.",
                        tr: "Birkaç dakika yeter: avuçlarını birleştirip zihni durul (Gasshō), nefesle arın, ellerini bedeninin merkezlerine koy ve enerjinin yerleşmesine izin ver. İnanç gerekmez — yalnızca dikkatin.",
                        es: "Bastan unos minutos: aquieta la mente con las palmas juntas (Gasshō), límpiate con la respiración, apoya las manos en los centros del cuerpo y deja que la energía se asiente. No hace falta creer — solo tu atención."
                    )
                )
            ]
        case .breathwork:
            return [
                PathSection(
                    heading: L10n.text(en: "What pranayama is", tr: "Pranayama nedir", es: "Qué es el pranayama"),
                    body: L10n.text(
                        en: "In yoga, prana is the life force and \"ayama\" means to extend or guide. Pranayama is the art of guiding life energy through the breath. The breath is seen as the bridge between body and mind — change it, and you change your state.",
                        tr: "Yogada prana yaşam gücü, \"ayama\" ise uzatmak ya da yönlendirmek demektir. Pranayama, yaşam enerjisini nefesle yönlendirme sanatıdır. Nefes, beden ile zihin arasındaki köprü sayılır — onu değiştirirsin, halini değiştirirsin.",
                        es: "En el yoga, prana es la fuerza vital y \"ayama\" significa extender o guiar. El pranayama es el arte de guiar la energía vital con la respiración. El aliento es el puente entre cuerpo y mente — cámbialo y cambias tu estado."
                    )
                ),
                PathSection(
                    heading: L10n.text(en: "Prana and the nadis", tr: "Prana ve nadiler", es: "El prana y los nadis"),
                    body: L10n.text(
                        en: "Tradition describes subtle channels called nadis through which prana flows. Ida (cooling, lunar) runs on the left, pingala (warming, solar) on the right, and sushumna through the center. Morning breathwork balances and charges these channels.",
                        tr: "Gelenek, pranayı taşıyan nadi adı verilen ince kanallardan söz eder. Ida (serinletici, ay) solda, pingala (ısıtıcı, güneş) sağda, sushumna ise merkezden akar. Sabah nefes çalışması bu kanalları dengeler ve doldurur.",
                        es: "La tradición describe canales sutiles llamados nadis por donde fluye el prana. Ida (lunar, refrescante) va por la izquierda, pingala (solar, cálido) por la derecha y sushumna por el centro. La respiración matinal equilibra y carga estos canales."
                    )
                ),
                PathSection(
                    heading: L10n.text(en: "Charge or settle", tr: "Doldur ya da sakinleştir", es: "Cargar o serenar"),
                    body: L10n.text(
                        en: "Some breaths build heat and alertness — the bellows breath, skull-shining breath, and solar breath. Others balance and calm — alternate-nostril and coherent breathing. Choose what your morning needs, and always stay gentle.",
                        tr: "Kimi nefesler ısı ve uyanıklık üretir — körük nefesi, kafatası parlatan nefes ve güneş nefesi. Kimileri dengeler ve sakinleştirir — alternatif burun ve koherans nefesi. Sabahının ihtiyacına göre seç ve her zaman nazik kal.",
                        es: "Algunas respiraciones generan calor y alerta — la respiración de fuelle, la de cráneo brillante y la solar. Otras equilibran y calman — la de fosas alternas y la coherente. Elige lo que tu mañana necesita y mantente siempre suave."
                    )
                ),
                PathSection(
                    heading: L10n.text(en: "Your morning practice", tr: "Sabah pratiğin", es: "Tu práctica matinal"),
                    body: L10n.text(
                        en: "Sit tall and easy before the day's noise, and take a few rounds of conscious breathing. Let the inhale fill you and the exhale release. Move slowly into the stronger breaths, and never force.",
                        tr: "Günün gürültüsünden önce dik ve rahat otur, birkaç tur bilinçli nefes al. Nefes seni doldursun, veriş bıraksın. Güçlü nefeslere yavaşça geç ve asla zorlama.",
                        es: "Siéntate erguido y relajado antes del ruido del día y haz unas rondas de respiración consciente. Que la inhalación te llene y la exhalación suelte. Pasa despacio a las respiraciones intensas y nunca fuerces."
                    )
                )
            ]
        case .qigong:
            return [
                PathSection(
                    heading: L10n.text(en: "What qigong is", tr: "Qigong nedir", es: "Qué es el Qigong"),
                    body: L10n.text(
                        en: "Qigong (氣功) is a Chinese practice of cultivating qi — life energy — through gentle movement, breath, and attention. \"Qi\" is energy; \"gong\" is skilled, patient work. It grew from Daoist tradition and Chinese medicine over many centuries.",
                        tr: "Qigong (氣功), nazik hareket, nefes ve dikkat yoluyla qi'yi — yaşam enerjisini — geliştiren bir Çin pratiğidir. \"Qi\" enerji, \"gong\" ustalıklı ve sabırlı çalışmadır. Yüzyıllar içinde Taocu gelenek ve Çin tıbbından doğmuştur.",
                        es: "El Qigong (氣功) es una práctica china de cultivo del qi — la energía vital — mediante movimiento suave, respiración y atención. \"Qi\" es energía; \"gong\", trabajo hábil y paciente. Surgió de la tradición taoísta y la medicina china a lo largo de siglos."
                    )
                ),
                PathSection(
                    heading: L10n.text(en: "Qi and the dantian", tr: "Qi ve dantian", es: "El qi y el dantian"),
                    body: L10n.text(
                        en: "Qi is said to move through channels called meridians. The lower dantian — a point about three fingers below the navel — is the body's main energy reservoir. Morning qigong gathers qi there and circulates it through the body.",
                        tr: "Qi'nin meridyen denen kanallardan aktığı söylenir. Alt dantian — göbeğin yaklaşık üç parmak altındaki nokta — bedenin ana enerji deposudur. Sabah qigong'u qi'yi orada toplar ve bedene dolaştırır.",
                        es: "Se dice que el qi circula por canales llamados meridianos. El dantian inferior — un punto unos tres dedos bajo el ombligo — es el principal depósito de energía del cuerpo. El Qigong matinal reúne ahí el qi y lo hace circular."
                    )
                ),
                PathSection(
                    heading: L10n.text(en: "Soft, rooted, slow", tr: "Yumuşak, köklü, yavaş", es: "Suave, enraizado, lento"),
                    body: L10n.text(
                        en: "Qigong is gentle by design: relaxed shoulders, soft knees, slow breath, and an unhurried mind. The aim is not effort but flow — letting energy move freely instead of forcing it.",
                        tr: "Qigong doğası gereği naziktir: gevşek omuzlar, yumuşak dizler, yavaş nefes ve telaşsız bir zihin. Amaç efor değil akıştır — enerjiyi zorlamak yerine serbestçe hareket etmesine izin vermek.",
                        es: "El Qigong es suave por naturaleza: hombros relajados, rodillas blandas, respiración lenta y mente sin prisa. El objetivo no es el esfuerzo sino el flujo — dejar que la energía se mueva libre en vez de forzarla."
                    )
                ),
                PathSection(
                    heading: L10n.text(en: "Your morning practice", tr: "Sabah pratiğin", es: "Tu práctica matinal"),
                    body: L10n.text(
                        en: "A few minutes of easy movement wakes the body's energy before the day. Stand soft and breathe naturally, move within comfort, and finish by resting your hands over the dantian to keep what you gathered.",
                        tr: "Birkaç dakikalık rahat hareket, gün başlamadan bedenin enerjisini uyandırır. Yumuşakça dur ve doğal nefes al, rahatın elverdiğince hareket et ve topladığını korumak için ellerini dantian üzerine koyarak bitir.",
                        es: "Unos minutos de movimiento suave despiertan la energía del cuerpo antes del día. Ponte de pie relajado y respira con naturalidad, muévete dentro de tu comodidad y termina apoyando las manos sobre el dantian para conservar lo reunido."
                    )
                )
            ]
        }
    }

    var practices: [PathPractice] {
        switch self {
        case .reiki:      return EnergyPractices.reiki
        case .breathwork: return EnergyPractices.breathwork
        case .qigong:     return EnergyPractices.qigong
        }
    }

    func practice(id: String) -> PathPractice? {
        practices.first { $0.id == id }
    }
}

enum EnergyPractices {
    static let reiki: [PathPractice] = [
        PathPractice(
            id: "reiki.gassho",
            symbol: "hands.and.sparkles.fill",
            title: L10n.text(en: "Gasshō stillness", tr: "Gasshō sükuneti", es: "Quietud Gasshō"),
            how: L10n.text(en: "Bring your palms together at your heart. Rest your attention where your middle fingertips meet, and breathe slowly for one minute.", tr: "Avuçlarını kalbinin önünde birleştir. Dikkatini orta parmak uçlarının buluştuğu yere koy ve bir dakika boyunca yavaşça nefes al.", es: "Junta las palmas frente al corazón. Lleva la atención al punto donde se tocan las yemas de los dedos medios y respira despacio un minuto."),
            why: L10n.text(en: "Gasshō settles the mind — the doorway of every Reiki session.", tr: "Gasshō zihni durultur — her Reiki seansının kapısı.", es: "El Gasshō aquieta la mente — la puerta de toda sesión de Reiki."),
            checkPrompt: L10n.text(en: "Did you sit in Gasshō?", tr: "Gasshō'da oturdun mu?", es: "¿Te sentaste en Gasshō?"),
            winTitle: L10n.text(en: "You opened with stillness.", tr: "Sükunetle açtın.", es: "Abriste con quietud."),
            winBody: L10n.text(en: "Energy work begins where the mind quiets.", tr: "Enerji çalışması zihnin durulduğu yerde başlar.", es: "El trabajo energético empieza donde la mente calla.")
        ),
        PathPractice(
            id: "reiki.kenyoku",
            symbol: "wind",
            title: L10n.text(en: "Kenyoku — dry bathing", tr: "Kenyoku — kuru arınma", es: "Kenyoku — baño seco"),
            how: L10n.text(en: "Sweep one hand from the opposite shoulder down across the chest to the hip. Repeat on the other side, then sweep down each arm. Three passes in all.", tr: "Bir elini karşı omuzdan göğsün üzerinden kalçaya doğru süpür. Diğer tarafta tekrarla, sonra her kolu aşağı süpür. Toplam üç geçiş.", es: "Desliza una mano desde el hombro opuesto, cruzando el pecho hasta la cadera. Repite del otro lado y luego baja por cada brazo. Tres pasadas en total."),
            why: L10n.text(en: "A cleansing gesture to brush off stale energy and begin clear.", tr: "Durgun enerjiyi silkeleyip berrak başlamak için arındırıcı bir jest.", es: "Un gesto de limpieza para sacudir la energía estancada y empezar despejado."),
            checkPrompt: L10n.text(en: "Did you do Kenyoku?", tr: "Kenyoku yaptın mı?", es: "¿Hiciste Kenyoku?"),
            winTitle: L10n.text(en: "You cleared the field.", tr: "Alanı temizledin.", es: "Despejaste el campo."),
            winBody: L10n.text(en: "Fresh energy needs room to arrive.", tr: "Taze enerjiye yer açmak gerekir.", es: "La energía fresca necesita espacio para llegar.")
        ),
        PathPractice(
            id: "reiki.hands",
            symbol: "hand.raised.fill",
            title: L10n.text(en: "Self-Reiki hands", tr: "Kendine Reiki", es: "Manos de auto-Reiki"),
            how: L10n.text(en: "Rest both hands gently on your heart, then your solar plexus, then your lower belly (hara). Stay about a minute at each, breathing softly.", tr: "İki elini nazikçe önce kalbine, sonra güneş sinirine, sonra alt karnına (hara) koy. Her birinde yumuşakça nefes alarak yaklaşık bir dakika kal.", es: "Apoya ambas manos con suavidad sobre el corazón, luego el plexo solar y después el bajo vientre (hara). Permanece cerca de un minuto en cada uno, respirando suave."),
            why: L10n.text(en: "Bring warmth and energy to your body's three centers.", tr: "Bedeninin üç merkezine sıcaklık ve enerji getir.", es: "Lleva calor y energía a los tres centros del cuerpo."),
            checkPrompt: L10n.text(en: "Did you place your hands?", tr: "Ellerini koydun mu?", es: "¿Colocaste las manos?"),
            winTitle: L10n.text(en: "You gave yourself energy.", tr: "Kendine enerji verdin.", es: "Te diste energía."),
            winBody: L10n.text(en: "The simplest healing is your own hands.", tr: "En basit şifa kendi ellerindir.", es: "La sanación más simple son tus propias manos.")
        ),
        PathPractice(
            id: "reiki.breath",
            symbol: "lungs.fill",
            title: L10n.text(en: "Jōshin Kokyū-hō breath", tr: "Jōshin Kokyū-hō nefesi", es: "Respiración Jōshin Kokyū-hō"),
            how: L10n.text(en: "Inhale through the nose, imagining energy gathering at your hara below the navel. As you exhale, let it spread through your whole body. Six slow breaths.", tr: "Burnundan nefes al, enerjinin göbek altındaki hara'da toplandığını hayal et. Verirken tüm bedenine yayılmasına izin ver. Altı yavaş nefes.", es: "Inhala por la nariz imaginando que la energía se reúne en el hara, bajo el ombligo. Al exhalar, deja que se expanda por todo el cuerpo. Seis respiraciones lentas."),
            why: L10n.text(en: "The soul-cleansing breath draws energy in and lets it flow out.", tr: "Ruhu arındıran nefes enerjiyi içeri çeker, dışarı akıtır.", es: "La respiración que limpia el alma atrae la energía y la deja fluir."),
            checkPrompt: L10n.text(en: "Did you breathe the energy?", tr: "Enerji nefesini aldın mı?", es: "¿Respiraste la energía?"),
            winTitle: L10n.text(en: "You moved energy with breath.", tr: "Enerjiyi nefesle hareket ettirdin.", es: "Moviste energía con el aliento."),
            winBody: L10n.text(en: "Breath and ki travel together.", tr: "Nefes ve ki birlikte yol alır.", es: "El aliento y el ki viajan juntos.")
        ),
        PathPractice(
            id: "reiki.gokai",
            symbol: "text.book.closed.fill",
            title: L10n.text(en: "Gokai — the five precepts", tr: "Gokai — beş ilke", es: "Gokai — los cinco principios"),
            how: L10n.text(en: "Say slowly to yourself: Just for today — I will not be angry, I will not worry, I will be grateful, I will work honestly, I will be kind to every living thing.", tr: "Kendine yavaşça söyle: Sadece bugün — öfkelenmeyeceğim, endişelenmeyeceğim, şükredeceğim, dürüstçe çalışacağım, her canlıya nazik olacağım.", es: "Dite despacio: Solo por hoy — no me enojaré, no me preocuparé, seré agradecido, trabajaré con honestidad, seré amable con todo ser vivo."),
            why: L10n.text(en: "Set the day's energy with Usui's five principles.", tr: "Günün enerjisini Usui'nin beş ilkesiyle kur.", es: "Marca la energía del día con los cinco principios de Usui."),
            checkPrompt: L10n.text(en: "Did you recite the Gokai?", tr: "Gokai'yi okudun mu?", es: "¿Recitaste el Gokai?"),
            winTitle: L10n.text(en: "You set your intention.", tr: "Niyetini kurdun.", es: "Fijaste tu intención."),
            winBody: L10n.text(en: "Five lines that shape a whole day.", tr: "Bütün bir günü biçimlendiren beş satır.", es: "Cinco líneas que dan forma a todo un día.")
        )
    ]

    static let breathwork: [PathPractice] = [
        PathPractice(
            id: "breath.nadi",
            symbol: "wind",
            title: L10n.text(en: "Nadi Shodhana", tr: "Nadi Shodhana", es: "Nadi Shodhana"),
            how: L10n.text(en: "Close the right nostril, inhale left. Close the left, exhale right. Inhale right, close it, exhale left. That is one round — do six, slow and even.", tr: "Sağ burnu kapat, soldan al. Solu kapat, sağdan ver. Sağdan al, kapat, soldan ver. Bu bir turdur — yavaş ve eşit altı tur yap.", es: "Cierra la fosa derecha, inhala por la izquierda. Cierra la izquierda, exhala por la derecha. Inhala derecha, ciérrala, exhala izquierda. Eso es una ronda — haz seis, lentas y parejas."),
            why: L10n.text(en: "Balance the solar and lunar channels for steady, clear energy.", tr: "Güneş ve ay kanallarını dengele; dingin, berrak enerji.", es: "Equilibra los canales solar y lunar para una energía estable y clara."),
            checkPrompt: L10n.text(en: "Did you balance the breath?", tr: "Nefesi dengeledin mi?", es: "¿Equilibraste la respiración?"),
            winTitle: L10n.text(en: "You balanced the channels.", tr: "Kanalları dengeledin.", es: "Equilibraste los canales."),
            winBody: L10n.text(en: "Even breath, even mind.", tr: "Dengeli nefes, dengeli zihin.", es: "Respiración pareja, mente pareja.")
        ),
        PathPractice(
            id: "breath.kapalabhati",
            symbol: "sun.max.fill",
            title: L10n.text(en: "Kapalabhati", tr: "Kapalabhati", es: "Kapalabhati"),
            how: L10n.text(en: "Sit tall. Make short, sharp exhales through the nose, letting each inhale happen on its own. One round of twenty, rest, then a second round.", tr: "Dik otur. Burundan kısa ve keskin verişler yap; her alış kendiliğinden olsun. Yirmilik bir tur, dinlen, sonra ikinci tur.", es: "Siéntate erguido. Exhala corto y enérgico por la nariz, dejando que cada inhalación ocurra sola. Una ronda de veinte, descansa y una segunda ronda."),
            why: L10n.text(en: "The skull-shining breath clears the mind and wakes the whole system.", tr: "Kafatası parlatan nefes zihni temizler, tüm sistemi uyandırır.", es: "La respiración de cráneo brillante despeja la mente y despierta todo el sistema."),
            checkPrompt: L10n.text(en: "Did you do Kapalabhati?", tr: "Kapalabhati yaptın mı?", es: "¿Hiciste Kapalabhati?"),
            winTitle: L10n.text(en: "You lit the inner fire.", tr: "İç ateşi yaktın.", es: "Encendiste el fuego interior."),
            winBody: L10n.text(en: "Bright breath, bright morning.", tr: "Parlak nefes, parlak sabah.", es: "Aliento brillante, mañana brillante.")
        ),
        PathPractice(
            id: "breath.bhastrika",
            symbol: "flame.fill",
            title: L10n.text(en: "Bhastrika — bellows breath", tr: "Bhastrika — körük nefesi", es: "Bhastrika — respiración de fuelle"),
            how: L10n.text(en: "Breathe forcefully and equally in and out through the nose, like a bellows, arms pumping if you like. One slow round of ten, then breathe normally and feel it.", tr: "Burundan körük gibi güçlü ve eşit al-ver; istersen kolların pompalasın. Onluk yavaş bir tur, sonra normal nefes al ve hisset.", es: "Respira con fuerza y por igual, entrando y saliendo por la nariz, como un fuelle; bombea los brazos si quieres. Una ronda lenta de diez, luego respira normal y siéntelo."),
            why: L10n.text(en: "Stoke the inner fire and lift your energy quickly.", tr: "İç ateşi körükle, enerjini hızla yükselt.", es: "Aviva el fuego interior y eleva tu energía rápidamente."),
            checkPrompt: L10n.text(en: "Did you pump the bellows?", tr: "Körüğü çalıştırdın mı?", es: "¿Bombeaste el fuelle?"),
            winTitle: L10n.text(en: "You raised the heat.", tr: "Isıyı yükselttin.", es: "Elevaste el calor."),
            winBody: L10n.text(en: "Energy, on demand.", tr: "İstediğinde enerji.", es: "Energía, a voluntad.")
        ),
        PathPractice(
            id: "breath.surya",
            symbol: "sunrise.fill",
            title: L10n.text(en: "Surya Bhedana — solar breath", tr: "Surya Bhedana — güneş nefesi", es: "Surya Bhedana — respiración solar"),
            how: L10n.text(en: "Inhale through the right nostril, close it, and exhale through the left. Keep the rhythm slow and full for one minute.", tr: "Sağ burundan al, kapat, soldan ver. Bir dakika boyunca ritmi yavaş ve dolu tut.", es: "Inhala por la fosa derecha, ciérrala y exhala por la izquierda. Mantén el ritmo lento y pleno durante un minuto."),
            why: L10n.text(en: "The right channel is solar — warming, activating, energizing.", tr: "Sağ kanal güneştir — ısıtır, harekete geçirir, enerji verir.", es: "El canal derecho es solar — calienta, activa, energiza."),
            checkPrompt: L10n.text(en: "Did you breathe the sun side?", tr: "Güneş tarafından nefes aldın mı?", es: "¿Respiraste por el lado solar?"),
            winTitle: L10n.text(en: "You turned toward the sun.", tr: "Güneşe döndün.", es: "Te volviste hacia el sol."),
            winBody: L10n.text(en: "A warmer current to start the day.", tr: "Güne başlamak için daha sıcak bir akım.", es: "Una corriente más cálida para iniciar el día.")
        ),
        PathPractice(
            id: "breath.coherent",
            symbol: "waveform.path",
            title: L10n.text(en: "Coherent breath", tr: "Koherans nefesi", es: "Respiración coherente"),
            how: L10n.text(en: "Inhale for a slow count of five, exhale for a slow count of five. Smooth and continuous, no pause, for two minutes.", tr: "Yavaşça beş sayarak al, yavaşça beş sayarak ver. İki dakika boyunca akıcı ve kesintisiz, duraksız.", es: "Inhala en una cuenta lenta de cinco y exhala en una cuenta lenta de cinco. Suave y continuo, sin pausa, durante dos minutos."),
            why: L10n.text(en: "Even five-and-five breathing settles the nervous system and steadies your energy.", tr: "Eşit beş-beş nefes sinir sistemini yatıştırır, enerjini dengeler.", es: "La respiración pareja de cinco y cinco serena el sistema nervioso y estabiliza tu energía."),
            checkPrompt: L10n.text(en: "Did you find the even breath?", tr: "Dengeli nefesi buldun mu?", es: "¿Encontraste la respiración pareja?"),
            winTitle: L10n.text(en: "You found your rhythm.", tr: "Ritmini buldun.", es: "Encontraste tu ritmo."),
            winBody: L10n.text(en: "Steady breath is steady energy.", tr: "Dengeli nefes, dengeli enerji.", es: "Aliento estable es energía estable.")
        )
    ]

    static let qigong: [PathPractice] = [
        PathPractice(
            id: "qi.shake",
            symbol: "figure.cooldown",
            title: L10n.text(en: "Wake the qi — shaking", tr: "Qi'yi uyandır — silkelenme", es: "Despierta el qi — sacudida"),
            how: L10n.text(en: "Stand with soft knees and gently bounce, letting your arms and whole body shake loose for one minute. Then stand still and feel the tingling settle.", tr: "Dizlerin yumuşak dur ve nazikçe zıpla; bir dakika boyunca kollarının ve tüm bedeninin gevşeyip silkelenmesine izin ver. Sonra hareketsiz dur ve karıncalanmanın yerleşmesini hisset.", es: "Ponte de pie con rodillas blandas y rebota suavemente, dejando que los brazos y todo el cuerpo se aflojen un minuto. Luego quédate quieto y siente cómo se asienta el hormigueo."),
            why: L10n.text(en: "Loosen stuck energy and wake circulation — the simplest qi reset.", tr: "Tıkanmış enerjiyi gevşet, dolaşımı uyandır — en basit qi sıfırlaması.", es: "Afloja la energía estancada y despierta la circulación — el reinicio de qi más simple."),
            checkPrompt: L10n.text(en: "Did you shake the qi loose?", tr: "Qi'yi silkeleyip gevşettin mi?", es: "¿Sacudiste el qi?"),
            winTitle: L10n.text(en: "You woke the energy.", tr: "Enerjiyi uyandırdın.", es: "Despertaste la energía."),
            winBody: L10n.text(en: "Movement is the first medicine.", tr: "Hareket ilk ilaçtır.", es: "El movimiento es la primera medicina.")
        ),
        PathPractice(
            id: "qi.sky",
            symbol: "arrow.up.circle.fill",
            title: L10n.text(en: "Lifting the Sky", tr: "Gökyüzünü kaldırmak", es: "Levantar el cielo"),
            how: L10n.text(en: "Hands low in front, fingers toward each other. Raise them up the front of the body, turn the palms and press to the sky as you look up. Lower the arms out to the sides. Six slow times with the breath.", tr: "Eller önde aşağıda, parmaklar birbirine baksın. Bedenin önünden yukarı kaldır, avuçları çevirip gökyüzüne doğru bastırırken yukarı bak. Kolları yanlardan indir. Nefesle altı yavaş tekrar.", es: "Manos abajo al frente, dedos enfrentados. Súbelas por el frente del cuerpo, gira las palmas y empuja hacia el cielo mirando arriba. Baja los brazos por los lados. Seis veces lentas con la respiración."),
            why: L10n.text(en: "The opening move of the Eight Brocades — it stretches the channels and lifts energy.", tr: "Sekiz Brokar'ın açılış hareketi — kanalları açar, enerjiyi yükseltir.", es: "El movimiento inicial de los Ocho Brocados — estira los canales y eleva la energía."),
            checkPrompt: L10n.text(en: "Did you lift the sky?", tr: "Gökyüzünü kaldırdın mı?", es: "¿Levantaste el cielo?"),
            winTitle: L10n.text(en: "You opened the channels.", tr: "Kanalları açtın.", es: "Abriste los canales."),
            winBody: L10n.text(en: "Reach up, and energy follows.", tr: "Yukarı uzan, enerji izler.", es: "Estírate hacia arriba y la energía sigue.")
        ),
        PathPractice(
            id: "qi.gather",
            symbol: "circle.circle.fill",
            title: L10n.text(en: "Gathering qi to the dantian", tr: "Qi'yi dantian'a toplamak", es: "Reunir el qi en el dantian"),
            how: L10n.text(en: "Scoop both hands upward at your sides as if gathering energy, then bring the palms to rest below your navel, one over the other. Breathe into the dantian for a minute.", tr: "Yanlardan iki elini enerji topluyormuş gibi yukarı kepçele, sonra avuçlarını biri diğerinin üstünde göbeğinin altına koy. Bir dakika dantian'a nefes ver.", es: "Recoge ambas manos hacia arriba por los lados como si reunieras energía, luego apóyalas bajo el ombligo, una sobre otra. Respira hacia el dantian durante un minuto."),
            why: L10n.text(en: "Collect and store qi in the body's energy center.", tr: "Qi'yi bedenin enerji merkezinde topla ve sakla.", es: "Recoge y almacena el qi en el centro energético del cuerpo."),
            checkPrompt: L10n.text(en: "Did you gather the qi?", tr: "Qi'yi topladın mı?", es: "¿Reuniste el qi?"),
            winTitle: L10n.text(en: "You stored the energy.", tr: "Enerjiyi depoladın.", es: "Almacenaste la energía."),
            winBody: L10n.text(en: "What you gather, you keep.", tr: "Topladığın sende kalır.", es: "Lo que reúnes, lo conservas.")
        ),
        PathPractice(
            id: "qi.spine",
            symbol: "waveform.path.ecg",
            title: L10n.text(en: "Spinal waves", tr: "Omurga dalgaları", es: "Ondas de columna"),
            how: L10n.text(en: "Soft and slow, roll the spine: tuck and round forward, then open and gently arch, like a wave moving from tailbone to head. Eight slow waves with the breath.", tr: "Yumuşak ve yavaş, omurgayı dalgalandır: öne büzül ve yuvarla, sonra aç ve nazikçe yayla — kuyruk sokumundan başa giden bir dalga gibi. Nefesle sekiz yavaş dalga.", es: "Suave y lento, ondula la columna: recoge y redondea al frente, luego abre y arquea con suavidad, como una ola del coxis a la cabeza. Ocho ondas lentas con la respiración."),
            why: L10n.text(en: "Free the spine so qi can move along the central channel.", tr: "Omurgayı serbest bırak ki qi merkez kanaldan aksın.", es: "Libera la columna para que el qi fluya por el canal central."),
            checkPrompt: L10n.text(en: "Did you wave the spine?", tr: "Omurgayı dalgalandırdın mı?", es: "¿Ondulaste la columna?"),
            winTitle: L10n.text(en: "You freed the central channel.", tr: "Merkez kanalı serbest bıraktın.", es: "Liberaste el canal central."),
            winBody: L10n.text(en: "A loose spine, a flowing morning.", tr: "Gevşek bir omurga, akan bir sabah.", es: "Columna suelta, mañana que fluye.")
        ),
        PathPractice(
            id: "qi.stand",
            symbol: "figure.stand",
            title: L10n.text(en: "Standing like a tree", tr: "Ağaç gibi durmak", es: "De pie como un árbol"),
            how: L10n.text(en: "Stand with knees soft and arms rounded in front, as if holding a large ball at chest height. Relax the shoulders and breathe naturally for two minutes.", tr: "Dizlerin yumuşak, kolların önde yuvarlak — göğüs hizasında büyük bir top tutar gibi dur. Omuzlarını gevşet ve iki dakika doğal nefes al.", es: "Ponte de pie con rodillas blandas y brazos redondeados al frente, como sosteniendo una gran bola a la altura del pecho. Relaja los hombros y respira con naturalidad dos minutos."),
            why: L10n.text(en: "Zhan Zhuang, the foundational stance — root, settle, and build quiet energy.", tr: "Zhan Zhuang, temel duruş — köklen, yerleş ve sessiz enerji biriktir.", es: "Zhan Zhuang, la postura fundamental — enraíza, asiéntate y acumula energía silenciosa."),
            checkPrompt: L10n.text(en: "Did you stand like a tree?", tr: "Ağaç gibi durdun mu?", es: "¿Te paraste como un árbol?"),
            winTitle: L10n.text(en: "You rooted your energy.", tr: "Enerjini köklendirdin.", es: "Enraizaste tu energía."),
            winBody: L10n.text(en: "Stillness builds the deepest qi.", tr: "Durağanlık en derin qi'yi biriktirir.", es: "La quietud cultiva el qi más profundo.")
        )
    ]
}
