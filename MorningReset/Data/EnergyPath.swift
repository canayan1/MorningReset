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
    var steps: [String] = []

    var presentation: FirstWinPresentation {
        FirstWinPresentation(symbol: symbol, title: title, how: how, checkPrompt: checkPrompt, winTitle: winTitle, winBody: winBody, steps: steps)
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
                ),
                PathSection(
                    heading: L10n.text(en: "The hand positions", tr: "El pozisyonları", es: "Las posiciones de las manos"),
                    body: L10n.text(
                        en: "In self-treatment the hands rest, soft and still, on a few key centers: over the eyes and head, the throat, the heart, the solar plexus, and the lower belly. Stay a minute or two at each, letting warmth build before moving on. There is no pressing — only resting and listening.",
                        tr: "Kendine uygulamada eller yumuşak ve durgun biçimde birkaç temel merkeze konur: gözler ve baş, boğaz, kalp, güneş siniri ve alt karın. Her birinde bir-iki dakika kal, ilerlemeden önce sıcaklığın oluşmasına izin ver. Bastırmak yok — yalnızca dinlenmek ve dinlemek.",
                        es: "En el autotratamiento las manos descansan, suaves y quietas, sobre algunos centros clave: los ojos y la cabeza, la garganta, el corazón, el plexo solar y el bajo vientre. Quédate uno o dos minutos en cada uno, dejando que el calor crezca antes de avanzar. No se presiona — solo se descansa y se escucha."
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
                        en: "Some breaths build heat and alertness — the bellows breath, skull-shining breath, and solar breath. Others balance and calm — alternate-nostril and coherent breathing. Choose what your practice needs, and always stay gentle.",
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
                ),
                PathSection(
                    heading: L10n.text(en: "The five vayus", tr: "Beş vayu", es: "Los cinco vayus"),
                    body: L10n.text(
                        en: "Yoga describes prana moving in five directions, the vayus: prana (inward, at the chest), apana (downward, releasing), samana (the steady center), udana (upward, the throat and voice), and vyana (outward, through the whole body). Energizing breaths lift udana and prana; calming breaths settle apana. You don't need to track them — but knowing them deepens the practice.",
                        tr: "Yoga, pranayı beş yönde hareket eder olarak tanımlar — vayular: prana (içe, göğüste), apana (aşağı, boşaltan), samana (durağan merkez), udana (yukarı, boğaz ve ses), vyana (dışa, tüm bedene). Enerjilendiren nefesler udana ve pranayı yükseltir; sakinleştirenler apanayı yatıştırır. Bunları takip etmen gerekmez — ama bilmek pratiği derinleştirir.",
                        es: "El yoga describe el prana moviéndose en cinco direcciones, los vayus: prana (hacia dentro, en el pecho), apana (hacia abajo, que libera), samana (el centro estable), udana (hacia arriba, la garganta y la voz) y vyana (hacia fuera, por todo el cuerpo). Las respiraciones energizantes elevan udana y prana; las calmantes asientan apana. No hace falta seguirlos — pero conocerlos profundiza la práctica."
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
                ),
                PathSection(
                    heading: L10n.text(en: "The Three Treasures", tr: "Üç Hazine", es: "Los Tres Tesoros"),
                    body: L10n.text(
                        en: "Daoist tradition speaks of three treasures: jing (the body's deep essence), qi (the energy that moves and warms), and shen (the spirit, or clear mind). Morning practice tends all three — rooting jing, circulating qi, and brightening shen. Many of the eight classic movements, the Ba Duan Jin, were made for exactly this.",
                        tr: "Taocu gelenek üç hazineden söz eder: jing (bedenin derin özü), qi (hareket eden ve ısıtan enerji) ve shen (ruh ya da berrak zihin). Sabah pratiği üçünü de besler — jing'i köklendirir, qi'yi dolaştırır, shen'i aydınlatır. Sekiz klasik hareketin (Ba Duan Jin) çoğu tam bunun için yapılmıştır.",
                        es: "La tradición taoísta habla de tres tesoros: jing (la esencia profunda del cuerpo), qi (la energía que mueve y calienta) y shen (el espíritu o la mente clara). La práctica matinal cuida los tres — enraíza el jing, circula el qi y aclara el shen. Muchos de los ocho movimientos clásicos, el Ba Duan Jin, se crearon justo para esto."
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
            how: L10n.text(en: "Bring your palms together at your heart and let the mind grow quiet.", tr: "Avuçlarını kalbinin önünde birleştir ve zihni durult.", es: "Junta las palmas frente al corazón y deja que la mente se aquiete."),
            why: L10n.text(en: "Gasshō settles the mind — the doorway of every Reiki session.", tr: "Gasshō zihni durultur — her Reiki seansının kapısı.", es: "El Gasshō aquieta la mente — la puerta de toda sesión de Reiki."),
            checkPrompt: L10n.text(en: "Did you sit in Gasshō?", tr: "Gasshō'da oturdun mu?", es: "¿Te sentaste en Gasshō?"),
            winTitle: L10n.text(en: "You opened with stillness.", tr: "Sükunetle açtın.", es: "Abriste con quietud."),
            winBody: L10n.text(en: "Energy work begins where the mind quiets.", tr: "Enerji çalışması zihnin durulduğu yerde başlar.", es: "El trabajo energético empieza donde la mente calla."),
            steps: [
                L10n.text(en: "Sit comfortably and bring your palms together at your heart.", tr: "Rahatça otur ve avuçlarını kalbinin önünde birleştir.", es: "Siéntate cómodo y junta las palmas frente al corazón."),
                L10n.text(en: "Rest your attention where your middle fingertips meet.", tr: "Dikkatini orta parmak uçlarının buluştuğu yere ver.", es: "Lleva la atención al punto donde se tocan las yemas de los dedos medios."),
                L10n.text(en: "Breathe slowly and let the mind grow quiet for a minute.", tr: "Yavaşça nefes al, bir dakika zihnin durulsun.", es: "Respira despacio y deja que la mente se aquiete un minuto.")
            ]
        ),
        PathPractice(
            id: "reiki.kenyoku",
            symbol: "wind",
            title: L10n.text(en: "Kenyoku — dry bathing", tr: "Kenyoku — kuru arınma", es: "Kenyoku — baño seco"),
            how: L10n.text(en: "Sweep the hands across the body to brush off stale energy.", tr: "Durgun enerjiyi silkelemek için elleri beden üzerinde süpür.", es: "Desliza las manos por el cuerpo para sacudir la energía estancada."),
            why: L10n.text(en: "A cleansing gesture to begin clear.", tr: "Berrak başlamak için arındırıcı bir jest.", es: "Un gesto de limpieza para empezar despejado."),
            checkPrompt: L10n.text(en: "Did you do Kenyoku?", tr: "Kenyoku yaptın mı?", es: "¿Hiciste Kenyoku?"),
            winTitle: L10n.text(en: "You cleared the field.", tr: "Alanı temizledin.", es: "Despejaste el campo."),
            winBody: L10n.text(en: "Fresh energy needs room to arrive.", tr: "Taze enerjiye yer açmak gerekir.", es: "La energía fresca necesita espacio para llegar."),
            steps: [
                L10n.text(en: "Place your right hand at your left shoulder.", tr: "Sağ elini sol omzuna koy.", es: "Coloca la mano derecha en el hombro izquierdo."),
                L10n.text(en: "Sweep down across the chest to the right hip; repeat on the other side.", tr: "Göğsünden sağ kalçana süpür; diğer tarafta tekrarla.", es: "Desliza por el pecho hasta la cadera derecha; repite del otro lado."),
                L10n.text(en: "Then sweep down each arm, shoulder to fingertips.", tr: "Sonra her kolu omuzdan parmak uçlarına süpür.", es: "Luego baja por cada brazo, del hombro a los dedos.")
            ]
        ),
        PathPractice(
            id: "reiki.hands",
            symbol: "hand.raised.fill",
            title: L10n.text(en: "Self-Reiki hands", tr: "Kendine Reiki", es: "Manos de auto-Reiki"),
            how: L10n.text(en: "Rest your hands on the body's centers and let warmth gather.", tr: "Ellerini bedenin merkezlerine koy, sıcaklık toplansın.", es: "Apoya las manos en los centros del cuerpo y deja que se reúna el calor."),
            why: L10n.text(en: "Bring warmth and energy to your three centers.", tr: "Üç merkezine sıcaklık ve enerji getir.", es: "Lleva calor y energía a tus tres centros."),
            checkPrompt: L10n.text(en: "Did you place your hands?", tr: "Ellerini koydun mu?", es: "¿Colocaste las manos?"),
            winTitle: L10n.text(en: "You gave yourself energy.", tr: "Kendine enerji verdin.", es: "Te diste energía."),
            winBody: L10n.text(en: "The simplest healing is your own hands.", tr: "En basit şifa kendi ellerindir.", es: "La sanación más simple son tus propias manos."),
            steps: [
                L10n.text(en: "Rest both hands on your heart and breathe softly for a minute.", tr: "İki elini kalbine koy, bir dakika yumuşakça nefes al.", es: "Apoya ambas manos en el corazón y respira suave un minuto."),
                L10n.text(en: "Move them to your solar plexus; stay another minute.", tr: "Ellerini güneş sinirine taşı; bir dakika daha kal.", es: "Pásalas al plexo solar; quédate otro minuto."),
                L10n.text(en: "Rest them on your lower belly (hara) and feel the warmth.", tr: "Alt karnına (hara) koy ve sıcaklığı hisset.", es: "Apóyalas en el bajo vientre (hara) y siente el calor.")
            ]
        ),
        PathPractice(
            id: "reiki.breath",
            symbol: "lungs.fill",
            title: L10n.text(en: "Jōshin Kokyū-hō breath", tr: "Jōshin Kokyū-hō nefesi", es: "Respiración Jōshin Kokyū-hō"),
            how: L10n.text(en: "Draw energy to the hara on the inhale and spread it on the exhale.", tr: "Alışta enerjiyi hara'ya çek, verişte yay.", es: "Atrae energía al hara al inhalar y expándela al exhalar."),
            why: L10n.text(en: "The soul-cleansing breath moves ki through the body.", tr: "Ruhu arındıran nefes ki'yi bedende dolaştırır.", es: "La respiración que limpia el alma mueve el ki por el cuerpo."),
            checkPrompt: L10n.text(en: "Did you breathe the energy?", tr: "Enerji nefesini aldın mı?", es: "¿Respiraste la energía?"),
            winTitle: L10n.text(en: "You moved energy with breath.", tr: "Enerjiyi nefesle hareket ettirdin.", es: "Moviste energía con el aliento."),
            winBody: L10n.text(en: "Breath and ki travel together.", tr: "Nefes ve ki birlikte yol alır.", es: "El aliento y el ki viajan juntos."),
            steps: [
                L10n.text(en: "Inhale through the nose, drawing energy to the hara.", tr: "Burnundan al, enerjiyi hara'ya çek.", es: "Inhala por la nariz, llevando energía al hara."),
                L10n.text(en: "Hold softly for a moment.", tr: "Bir an hafifçe tut.", es: "Retén suavemente un instante."),
                L10n.text(en: "Exhale and let energy spread through the whole body.", tr: "Ver ve enerjinin tüm bedene yayılmasına izin ver.", es: "Exhala y deja que la energía se expanda por todo el cuerpo.")
            ]
        ),
        PathPractice(
            id: "reiki.gokai",
            symbol: "text.book.closed.fill",
            title: L10n.text(en: "Gokai — the five precepts", tr: "Gokai — beş ilke", es: "Gokai — los cinco principios"),
            how: L10n.text(en: "Recite Usui's five principles to set the day's energy.", tr: "Günün enerjisini kurmak için Usui'nin beş ilkesini oku.", es: "Recita los cinco principios de Usui para marcar la energía del día."),
            why: L10n.text(en: "Five lines that shape a whole day.", tr: "Bütün bir günü biçimlendiren beş satır.", es: "Cinco líneas que dan forma a todo un día."),
            checkPrompt: L10n.text(en: "Did you recite the Gokai?", tr: "Gokai'yi okudun mu?", es: "¿Recitaste el Gokai?"),
            winTitle: L10n.text(en: "You set your intention.", tr: "Niyetini kurdun.", es: "Fijaste tu intención."),
            winBody: L10n.text(en: "Intention shapes the energy that follows.", tr: "Niyet, ardından gelen enerjiyi biçimlendirir.", es: "La intención da forma a la energía que sigue."),
            steps: [
                L10n.text(en: "Settle with your hands at your heart.", tr: "Ellerin kalbinde yerleş.", es: "Acomódate con las manos en el corazón."),
                L10n.text(en: "Say slowly: \"Just for today — I will not anger, I will not worry, I will be grateful, I will work honestly, I will be kind.\"", tr: "Yavaşça söyle: \"Sadece bugün — öfkelenmeyeceğim, endişelenmeyeceğim, şükredeceğim, dürüstçe çalışacağım, nazik olacağım.\"", es: "Di despacio: \"Solo por hoy — no me enojaré, no me preocuparé, seré agradecido, trabajaré con honestidad, seré amable.\""),
                L10n.text(en: "Let each line land before the next.", tr: "Her satır bir sonraki gelmeden otursun.", es: "Deja que cada línea cale antes de la siguiente.")
            ]
        ),
        PathPractice(
            id: "reiki.byosen",
            symbol: "dot.radiowaves.left.and.right",
            title: L10n.text(en: "Byōsen scanning", tr: "Byōsen tarama", es: "Escaneo Byōsen"),
            how: L10n.text(en: "Hold your palms just off the body and sense for warmth or tingling.", tr: "Avuçlarını bedenin hemen üstünde tut, sıcaklık ya da karıncalanma sez.", es: "Mantén las palmas justo sobre el cuerpo y percibe calor u hormigueo."),
            why: L10n.text(en: "Listen to where your energy wants attention.", tr: "Enerjinin nerede dikkat istediğini dinle.", es: "Escucha dónde tu energía pide atención."),
            checkPrompt: L10n.text(en: "Did you scan with your hands?", tr: "Ellerinle taradın mı?", es: "¿Escaneaste con las manos?"),
            winTitle: L10n.text(en: "You listened to the body.", tr: "Bedeni dinledin.", es: "Escuchaste al cuerpo."),
            winBody: L10n.text(en: "Sensing is the first half of healing.", tr: "Sezmek şifanın ilk yarısıdır.", es: "Percibir es la primera mitad de la sanación."),
            steps: [
                L10n.text(en: "Rub your palms together until they feel warm.", tr: "Avuçlarını ısınana dek birbirine sürt.", es: "Frota las palmas hasta sentirlas cálidas."),
                L10n.text(en: "Hold them just above the body and move slowly.", tr: "Bedenin hemen üstünde tut ve yavaşça gezdir.", es: "Mantenlas justo sobre el cuerpo y muévelas despacio."),
                L10n.text(en: "Rest where you sense heat or tingling, and breathe.", tr: "Sıcaklık ya da karıncalanma sezdiğin yerde dur ve nefes al.", es: "Detente donde sientas calor u hormigueo y respira.")
            ]
        ),
        PathPractice(
            id: "reiki.shower",
            symbol: "shower.fill",
            title: L10n.text(en: "Reiki shower", tr: "Reiki duşu", es: "Ducha de Reiki"),
            how: L10n.text(en: "Sweep your hands down the front of the body, pouring energy over yourself.", tr: "Ellerini bedenin önünden aşağı süpür, üzerine enerji dök.", es: "Desliza las manos por el frente del cuerpo, vertiendo energía sobre ti."),
            why: L10n.text(en: "Rinse the field clean and start fresh.", tr: "Alanı durula ve taze başla.", es: "Enjuaga el campo y empieza renovado."),
            checkPrompt: L10n.text(en: "Did you take a Reiki shower?", tr: "Reiki duşu aldın mı?", es: "¿Tomaste una ducha de Reiki?"),
            winTitle: L10n.text(en: "You rinsed the field.", tr: "Alanı duruladın.", es: "Enjuagaste el campo."),
            winBody: L10n.text(en: "Clean energy, clear morning.", tr: "Temiz enerji, berrak sabah.", es: "Energía limpia, mañana clara."),
            steps: [
                L10n.text(en: "Stand and raise both hands high above your head.", tr: "Ayağa kalk ve iki elini başının çok üstüne kaldır.", es: "Ponte de pie y levanta ambas manos por encima de la cabeza."),
                L10n.text(en: "Sweep them slowly down the front of the body.", tr: "Bedeninin önünden yavaşça aşağı süpür.", es: "Deslízalas despacio por el frente del cuerpo."),
                L10n.text(en: "Repeat three times, imagining light washing over you.", tr: "Üç kez tekrarla, üzerine ışık aktığını hayal et.", es: "Repite tres veces, imaginando luz que te baña.")
            ]
        )
    ]

    static let breathwork: [PathPractice] = [
        PathPractice(
            id: "breath.nadi",
            symbol: "wind",
            title: L10n.text(en: "Nadi Shodhana", tr: "Nadi Shodhana", es: "Nadi Shodhana"),
            how: L10n.text(en: "Alternate the breath between the nostrils to balance the channels.", tr: "Kanalları dengelemek için nefesi burun delikleri arasında değiştir.", es: "Alterna la respiración entre las fosas para equilibrar los canales."),
            why: L10n.text(en: "Balance the solar and lunar channels for steady, clear energy.", tr: "Güneş ve ay kanallarını dengele; dingin, berrak enerji.", es: "Equilibra los canales solar y lunar para una energía estable y clara."),
            checkPrompt: L10n.text(en: "Did you balance the breath?", tr: "Nefesi dengeledin mi?", es: "¿Equilibraste la respiración?"),
            winTitle: L10n.text(en: "You balanced the channels.", tr: "Kanalları dengeledin.", es: "Equilibraste los canales."),
            winBody: L10n.text(en: "Even breath, even mind.", tr: "Dengeli nefes, dengeli zihin.", es: "Respiración pareja, mente pareja."),
            steps: [
                L10n.text(en: "Close the right nostril with your thumb; inhale through the left.", tr: "Başparmağınla sağ burnu kapat; soldan al.", es: "Cierra la fosa derecha con el pulgar; inhala por la izquierda."),
                L10n.text(en: "Close the left; exhale right, then inhale right.", tr: "Solu kapat; sağdan ver, sonra sağdan al.", es: "Cierra la izquierda; exhala por la derecha y luego inhala por la derecha."),
                L10n.text(en: "Close the right; exhale left. That is one round — do six.", tr: "Sağı kapat; soldan ver. Bu bir tur — altı yap.", es: "Cierra la derecha; exhala por la izquierda. Eso es una ronda — haz seis.")
            ]
        ),
        PathPractice(
            id: "breath.kapalabhati",
            symbol: "sun.max.fill",
            title: L10n.text(en: "Kapalabhati", tr: "Kapalabhati", es: "Kapalabhati"),
            how: L10n.text(en: "Short, sharp exhales through the nose, with passive inhales.", tr: "Burundan kısa, keskin verişler; alışlar edilgen.", es: "Exhalaciones cortas y enérgicas por la nariz, con inhalaciones pasivas."),
            why: L10n.text(en: "The skull-shining breath clears the mind and wakes the system.", tr: "Kafatası parlatan nefes zihni temizler, sistemi uyandırır.", es: "La respiración de cráneo brillante despeja la mente y despierta el sistema."),
            checkPrompt: L10n.text(en: "Did you do Kapalabhati?", tr: "Kapalabhati yaptın mı?", es: "¿Hiciste Kapalabhati?"),
            winTitle: L10n.text(en: "You lit the inner fire.", tr: "İç ateşi yaktın.", es: "Encendiste el fuego interior."),
            winBody: L10n.text(en: "Bright breath, bright morning.", tr: "Parlak nefes, parlak sabah.", es: "Aliento brillante, mañana brillante."),
            steps: [
                L10n.text(en: "Sit tall and take one easy breath in.", tr: "Dik otur ve rahat bir nefes al.", es: "Siéntate erguido y toma una inhalación suave."),
                L10n.text(en: "Make twenty short, sharp exhales; let inhales happen on their own.", tr: "Yirmi kısa, keskin veriş yap; alışlar kendiliğinden olsun.", es: "Haz veinte exhalaciones cortas; deja que las inhalaciones ocurran solas."),
                L10n.text(en: "Rest and breathe normally, then do a second round.", tr: "Dinlen ve normal nefes al, sonra ikinci tur.", es: "Descansa y respira normal, luego una segunda ronda.")
            ]
        ),
        PathPractice(
            id: "breath.bhastrika",
            symbol: "flame.fill",
            title: L10n.text(en: "Bhastrika — bellows breath", tr: "Bhastrika — körük nefesi", es: "Bhastrika — respiración de fuelle"),
            how: L10n.text(en: "Forceful, equal breaths in and out, like a bellows.", tr: "Körük gibi güçlü ve eşit al-ver.", es: "Respiraciones intensas y parejas, como un fuelle."),
            why: L10n.text(en: "Stoke the inner fire and lift your energy quickly.", tr: "İç ateşi körükle, enerjini hızla yükselt.", es: "Aviva el fuego interior y eleva tu energía rápidamente."),
            checkPrompt: L10n.text(en: "Did you pump the bellows?", tr: "Körüğü çalıştırdın mı?", es: "¿Bombeaste el fuelle?"),
            winTitle: L10n.text(en: "You raised the heat.", tr: "Isıyı yükselttin.", es: "Elevaste el calor."),
            winBody: L10n.text(en: "Energy, on demand.", tr: "İstediğinde enerji.", es: "Energía, a voluntad."),
            steps: [
                L10n.text(en: "Sit tall and relax the shoulders.", tr: "Dik otur ve omuzları gevşet.", es: "Siéntate erguido y relaja los hombros."),
                L10n.text(en: "Breathe forcefully and equally in and out, ten times.", tr: "On kez güçlü ve eşit al-ver.", es: "Respira con fuerza y por igual, diez veces."),
                L10n.text(en: "Finish, breathe normally, and feel the buzz.", tr: "Bitir, normal nefes al ve canlılığı hisset.", es: "Termina, respira normal y siente la vibración.")
            ]
        ),
        PathPractice(
            id: "breath.surya",
            symbol: "sunrise.fill",
            title: L10n.text(en: "Surya Bhedana — solar breath", tr: "Surya Bhedana — güneş nefesi", es: "Surya Bhedana — respiración solar"),
            how: L10n.text(en: "Inhale right, exhale left, to warm and activate.", tr: "Isıtmak ve harekete geçirmek için sağdan al, soldan ver.", es: "Inhala por la derecha y exhala por la izquierda, para calentar y activar."),
            why: L10n.text(en: "The right channel is solar — warming and energizing.", tr: "Sağ kanal güneştir — ısıtır ve enerji verir.", es: "El canal derecho es solar — calienta y energiza."),
            checkPrompt: L10n.text(en: "Did you breathe the sun side?", tr: "Güneş tarafından nefes aldın mı?", es: "¿Respiraste por el lado solar?"),
            winTitle: L10n.text(en: "You turned toward the sun.", tr: "Güneşe döndün.", es: "Te volviste hacia el sol."),
            winBody: L10n.text(en: "A warmer current to start the day.", tr: "Güne başlamak için daha sıcak bir akım.", es: "Una corriente más cálida para iniciar el día."),
            steps: [
                L10n.text(en: "Close the left nostril; inhale through the right.", tr: "Sol burnu kapat; sağdan al.", es: "Cierra la fosa izquierda; inhala por la derecha."),
                L10n.text(en: "Close the right; exhale through the left.", tr: "Sağı kapat; soldan ver.", es: "Cierra la derecha; exhala por la izquierda."),
                L10n.text(en: "Keep the rhythm slow and full for one minute.", tr: "Bir dakika ritmi yavaş ve dolu tut.", es: "Mantén el ritmo lento y pleno un minuto.")
            ]
        ),
        PathPractice(
            id: "breath.coherent",
            symbol: "waveform.path",
            title: L10n.text(en: "Coherent breath", tr: "Koherans nefesi", es: "Respiración coherente"),
            how: L10n.text(en: "Breathe in for five and out for five, smooth and even.", tr: "Beşte al, beşte ver; akıcı ve eşit.", es: "Inhala en cinco y exhala en cinco, suave y parejo."),
            why: L10n.text(en: "Even breathing settles the nervous system and steadies your energy.", tr: "Eşit nefes sinir sistemini yatıştırır, enerjini dengeler.", es: "La respiración pareja serena el sistema nervioso y estabiliza tu energía."),
            checkPrompt: L10n.text(en: "Did you find the even breath?", tr: "Dengeli nefesi buldun mu?", es: "¿Encontraste la respiración pareja?"),
            winTitle: L10n.text(en: "You found your rhythm.", tr: "Ritmini buldun.", es: "Encontraste tu ritmo."),
            winBody: L10n.text(en: "Steady breath is steady energy.", tr: "Dengeli nefes, dengeli enerji.", es: "Aliento estable es energía estable."),
            steps: [
                L10n.text(en: "Inhale slowly for a count of five.", tr: "Yavaşça beş sayarak al.", es: "Inhala despacio en una cuenta de cinco."),
                L10n.text(en: "Exhale slowly for a count of five.", tr: "Yavaşça beş sayarak ver.", es: "Exhala despacio en una cuenta de cinco."),
                L10n.text(en: "Keep it smooth, no pause, for two minutes.", tr: "İki dakika akıcı, duraksız tut.", es: "Mantenlo suave, sin pausa, dos minutos.")
            ]
        ),
        PathPractice(
            id: "breath.ujjayi",
            symbol: "water.waves",
            title: L10n.text(en: "Ujjayi — ocean breath", tr: "Ujjayi — okyanus nefesi", es: "Ujjayi — respiración oceánica"),
            how: L10n.text(en: "Breathe through the nose with a soft ocean sound at the throat.", tr: "Boğazında yumuşak bir okyanus sesiyle burnundan nefes al.", es: "Respira por la nariz con un suave sonido de océano en la garganta."),
            why: L10n.text(en: "A warming, steadying breath that gathers focus.", tr: "Isıtan, dengeleyen, odağı toplayan bir nefes.", es: "Una respiración cálida y estable que reúne el foco."),
            checkPrompt: L10n.text(en: "Did you breathe the ocean?", tr: "Okyanus nefesi aldın mı?", es: "¿Respiraste el océano?"),
            winTitle: L10n.text(en: "You steadied the current.", tr: "Akımı dengeledin.", es: "Estabilizaste la corriente."),
            winBody: L10n.text(en: "Sound gives the breath an anchor.", tr: "Ses, nefese bir çapa verir.", es: "El sonido le da un ancla a la respiración."),
            steps: [
                L10n.text(en: "Inhale through the nose, gently narrowing the throat.", tr: "Burnundan al, boğazını hafifçe daralt.", es: "Inhala por la nariz, estrechando un poco la garganta."),
                L10n.text(en: "Exhale through the nose with the same soft sound.", tr: "Aynı yumuşak sesle burnundan ver.", es: "Exhala por la nariz con el mismo sonido suave."),
                L10n.text(en: "Continue, smooth and audible, for two minutes.", tr: "İki dakika akıcı ve duyulur şekilde sürdür.", es: "Continúa, suave y audible, dos minutos.")
            ]
        ),
        PathPractice(
            id: "breath.bhramari",
            symbol: "waveform",
            title: L10n.text(en: "Bhramari — bee breath", tr: "Bhramari — arı nefesi", es: "Bhramari — respiración de abeja"),
            how: L10n.text(en: "Exhale with a steady humming sound, like a bee.", tr: "Arı gibi sabit bir vızıltıyla ver.", es: "Exhala con un zumbido constante, como una abeja."),
            why: L10n.text(en: "The hum clears mental noise and calms the field.", tr: "Vızıltı zihinsel gürültüyü temizler, alanı sakinleştirir.", es: "El zumbido despeja el ruido mental y calma el campo."),
            checkPrompt: L10n.text(en: "Did you hum the breath?", tr: "Nefesi mırıldandın mı?", es: "¿Zumbaste la respiración?"),
            winTitle: L10n.text(en: "You cleared the noise.", tr: "Gürültüyü temizledin.", es: "Despejaste el ruido."),
            winBody: L10n.text(en: "A quiet mind holds more energy.", tr: "Sakin bir zihin daha çok enerji tutar.", es: "Una mente serena guarda más energía."),
            steps: [
                L10n.text(en: "Sit tall and softly close your eyes.", tr: "Dik otur ve gözlerini yumuşakça kapat.", es: "Siéntate erguido y cierra suavemente los ojos."),
                L10n.text(en: "Inhale through the nose.", tr: "Burnundan al.", es: "Inhala por la nariz."),
                L10n.text(en: "Exhale with a long, even hum; repeat six times.", tr: "Uzun, eşit bir vızıltıyla ver; altı kez tekrarla.", es: "Exhala con un zumbido largo y parejo; repite seis veces.")
            ]
        )
    ]

    static let qigong: [PathPractice] = [
        PathPractice(
            id: "qi.shake",
            symbol: "figure.cooldown",
            title: L10n.text(en: "Wake the qi — shaking", tr: "Qi'yi uyandır — silkelenme", es: "Despierta el qi — sacudida"),
            how: L10n.text(en: "Bounce gently and let the whole body shake loose.", tr: "Nazikçe zıpla, tüm beden gevşeyip silkelensin.", es: "Rebota suavemente y deja que todo el cuerpo se afloje."),
            why: L10n.text(en: "Loosen stuck energy and wake circulation.", tr: "Tıkanmış enerjiyi gevşet, dolaşımı uyandır.", es: "Afloja la energía estancada y despierta la circulación."),
            checkPrompt: L10n.text(en: "Did you shake the qi loose?", tr: "Qi'yi silkeleyip gevşettin mi?", es: "¿Sacudiste el qi?"),
            winTitle: L10n.text(en: "You woke the energy.", tr: "Enerjiyi uyandırdın.", es: "Despertaste la energía."),
            winBody: L10n.text(en: "Movement is the first medicine.", tr: "Hareket ilk ilaçtır.", es: "El movimiento es la primera medicina."),
            steps: [
                L10n.text(en: "Stand with feet shoulder-width, knees soft.", tr: "Ayaklar omuz genişliğinde, dizler yumuşak dur.", es: "Pies al ancho de hombros, rodillas blandas."),
                L10n.text(en: "Bounce gently and let the whole body shake loose.", tr: "Nazikçe zıpla, tüm beden gevşeyip silkelensin.", es: "Rebota suave y deja que todo el cuerpo se afloje."),
                L10n.text(en: "Stop, stand still, and feel the tingling settle.", tr: "Dur, hareketsiz kal, karıncalanmanın yerleşmesini hisset.", es: "Detente, quédate quieto y siente cómo se asienta el hormigueo.")
            ]
        ),
        PathPractice(
            id: "qi.sky",
            symbol: "arrow.up.circle.fill",
            title: L10n.text(en: "Lifting the Sky", tr: "Gökyüzünü kaldırmak", es: "Levantar el cielo"),
            how: L10n.text(en: "Raise the hands and press to the sky, then lower them wide.", tr: "Elleri kaldır, gökyüzüne bastır, sonra geniş indir.", es: "Sube las manos y empuja al cielo, luego bájalas abiertas."),
            why: L10n.text(en: "The opening move of the Eight Brocades — it lifts energy.", tr: "Sekiz Brokar'ın açılış hareketi — enerjiyi yükseltir.", es: "El movimiento inicial de los Ocho Brocados — eleva la energía."),
            checkPrompt: L10n.text(en: "Did you lift the sky?", tr: "Gökyüzünü kaldırdın mı?", es: "¿Levantaste el cielo?"),
            winTitle: L10n.text(en: "You opened the channels.", tr: "Kanalları açtın.", es: "Abriste los canales."),
            winBody: L10n.text(en: "Reach up, and energy follows.", tr: "Yukarı uzan, enerji izler.", es: "Estírate hacia arriba y la energía sigue."),
            steps: [
                L10n.text(en: "Hands low in front, fingers toward each other.", tr: "Eller önde aşağıda, parmaklar birbirine baksın.", es: "Manos abajo al frente, dedos enfrentados."),
                L10n.text(en: "Raise up the body's front, turn palms and press to the sky, looking up.", tr: "Bedenin önünden yukarı kaldır, avuçları çevir ve gökyüzüne bastır, yukarı bak.", es: "Sube por el frente, gira las palmas y empuja al cielo, mirando arriba."),
                L10n.text(en: "Lower the arms out to the sides; repeat six times.", tr: "Kolları yanlardan indir; altı kez tekrarla.", es: "Baja los brazos por los lados; repite seis veces.")
            ]
        ),
        PathPractice(
            id: "qi.gather",
            symbol: "circle.circle.fill",
            title: L10n.text(en: "Gathering qi to the dantian", tr: "Qi'yi dantian'a toplamak", es: "Reunir el qi en el dantian"),
            how: L10n.text(en: "Scoop energy upward, then rest the palms below the navel.", tr: "Enerjiyi yukarı kepçele, sonra avuçları göbek altına koy.", es: "Recoge energía hacia arriba y apoya las palmas bajo el ombligo."),
            why: L10n.text(en: "Collect and store qi in the body's energy center.", tr: "Qi'yi bedenin enerji merkezinde topla ve sakla.", es: "Recoge y almacena el qi en el centro energético del cuerpo."),
            checkPrompt: L10n.text(en: "Did you gather the qi?", tr: "Qi'yi topladın mı?", es: "¿Reuniste el qi?"),
            winTitle: L10n.text(en: "You stored the energy.", tr: "Enerjiyi depoladın.", es: "Almacenaste la energía."),
            winBody: L10n.text(en: "What you gather, you keep.", tr: "Topladığın sende kalır.", es: "Lo que reúnes, lo conservas."),
            steps: [
                L10n.text(en: "Scoop both hands upward at your sides as if lifting energy.", tr: "Yanlardan iki elini enerji kaldırır gibi yukarı kepçele.", es: "Recoge ambas manos hacia arriba por los lados como elevando energía."),
                L10n.text(en: "Bring the palms to rest below the navel, one over the other.", tr: "Avuçları biri diğerinin üstünde göbeğin altına koy.", es: "Apoya las palmas bajo el ombligo, una sobre otra."),
                L10n.text(en: "Breathe into the dantian for a minute.", tr: "Bir dakika dantian'a nefes ver.", es: "Respira hacia el dantian un minuto.")
            ]
        ),
        PathPractice(
            id: "qi.spine",
            symbol: "waveform.path.ecg",
            title: L10n.text(en: "Spinal waves", tr: "Omurga dalgaları", es: "Ondas de columna"),
            how: L10n.text(en: "Roll the spine in slow waves from tailbone to head.", tr: "Omurgayı kuyruk sokumundan başa yavaş dalgalarla dalgalandır.", es: "Ondula la columna en olas lentas del coxis a la cabeza."),
            why: L10n.text(en: "Free the spine so qi can move along the central channel.", tr: "Omurgayı serbest bırak ki qi merkez kanaldan aksın.", es: "Libera la columna para que el qi fluya por el canal central."),
            checkPrompt: L10n.text(en: "Did you wave the spine?", tr: "Omurgayı dalgalandırdın mı?", es: "¿Ondulaste la columna?"),
            winTitle: L10n.text(en: "You freed the central channel.", tr: "Merkez kanalı serbest bıraktın.", es: "Liberaste el canal central."),
            winBody: L10n.text(en: "A loose spine, a flowing morning.", tr: "Gevşek bir omurga, akan bir sabah.", es: "Columna suelta, mañana que fluye."),
            steps: [
                L10n.text(en: "Stand soft and easy, hands resting low.", tr: "Yumuşak ve rahat dur, eller aşağıda.", es: "Ponte de pie relajado, manos abajo."),
                L10n.text(en: "Tuck and round forward, then open and gently arch.", tr: "Öne büzül ve yuvarla, sonra aç ve nazikçe yayla.", es: "Recoge y redondea al frente, luego abre y arquea suave."),
                L10n.text(en: "Flow eight slow waves with the breath.", tr: "Nefesle sekiz yavaş dalga akıt.", es: "Fluye ocho ondas lentas con la respiración.")
            ]
        ),
        PathPractice(
            id: "qi.stand",
            symbol: "figure.stand",
            title: L10n.text(en: "Standing like a tree", tr: "Ağaç gibi durmak", es: "De pie como un árbol"),
            how: L10n.text(en: "Stand with arms rounded as if holding a ball, and breathe.", tr: "Top tutar gibi kolları yuvarlak dur ve nefes al.", es: "Ponte de pie con brazos redondeados como sosteniendo una bola, y respira."),
            why: L10n.text(en: "Zhan Zhuang — root, settle, and build quiet energy.", tr: "Zhan Zhuang — köklen, yerleş ve sessiz enerji biriktir.", es: "Zhan Zhuang — enraíza, asiéntate y acumula energía silenciosa."),
            checkPrompt: L10n.text(en: "Did you stand like a tree?", tr: "Ağaç gibi durdun mu?", es: "¿Te paraste como un árbol?"),
            winTitle: L10n.text(en: "You rooted your energy.", tr: "Enerjini köklendirdin.", es: "Enraizaste tu energía."),
            winBody: L10n.text(en: "Stillness builds the deepest qi.", tr: "Durağanlık en derin qi'yi biriktirir.", es: "La quietud cultiva el qi más profundo."),
            steps: [
                L10n.text(en: "Stand with knees soft, weight rooted in the feet.", tr: "Dizler yumuşak, ağırlık ayaklara köklü dur.", es: "Rodillas blandas, peso enraizado en los pies."),
                L10n.text(en: "Round the arms in front as if holding a large ball.", tr: "Kolları önde büyük bir top tutar gibi yuvarla.", es: "Redondea los brazos al frente como sosteniendo una bola."),
                L10n.text(en: "Relax and breathe naturally for two minutes.", tr: "Gevşe ve iki dakika doğal nefes al.", es: "Relájate y respira con naturalidad dos minutos.")
            ]
        ),
        PathPractice(
            id: "qi.knock",
            symbol: "hand.tap.fill",
            title: L10n.text(en: "Knocking on the Door of Life", tr: "Yaşam Kapısını Çalmak", es: "Golpear la Puerta de la Vida"),
            how: L10n.text(en: "Swing from the waist, letting loose fists tap the lower back and belly.", tr: "Belinden sallan, gevşek yumruklar bel altını ve karnı çalsın.", es: "Gira desde la cintura y deja que los puños golpeen la lumbar y el vientre."),
            why: L10n.text(en: "Wake the kidneys and the dantian — the body's energy roots.", tr: "Böbrekleri ve dantian'ı uyandır — bedenin enerji kökleri.", es: "Despierta los riñones y el dantian — las raíces de energía del cuerpo."),
            checkPrompt: L10n.text(en: "Did you knock on the door of life?", tr: "Yaşam kapısını çaldın mı?", es: "¿Golpeaste la puerta de la vida?"),
            winTitle: L10n.text(en: "You woke your roots.", tr: "Köklerini uyandırdın.", es: "Despertaste tus raíces."),
            winBody: L10n.text(en: "Energy rises from a strong base.", tr: "Enerji güçlü bir temelden yükselir.", es: "La energía sube desde una base fuerte."),
            steps: [
                L10n.text(en: "Stand relaxed, arms hanging loose.", tr: "Gevşek dur, kollar serbest sarksın.", es: "De pie relajado, brazos sueltos."),
                L10n.text(en: "Twist gently from the waist, side to side.", tr: "Belinden nazikçe iki yana dön.", es: "Gira con suavidad desde la cintura, de lado a lado."),
                L10n.text(en: "Let the fists tap the lower back and belly; continue a minute.", tr: "Yumruklar bel altını ve karnı çalsın; bir dakika sürdür.", es: "Deja que los puños golpeen la lumbar y el vientre; continúa un minuto.")
            ]
        ),
        PathPractice(
            id: "qi.crane",
            symbol: "bird.fill",
            title: L10n.text(en: "White Crane Spreads Wings", tr: "Beyaz Turna Kanat Açar", es: "La Grulla Blanca Abre las Alas"),
            how: L10n.text(en: "Open the arms wide like wings on the inhale, lower them on the exhale.", tr: "Alışta kolları kanat gibi geniş aç, verişte indir.", es: "Abre los brazos como alas al inhalar y bájalos al exhalar."),
            why: L10n.text(en: "Open the chest and let qi circulate through the heart.", tr: "Göğsü aç, qi kalpten dolaşsın.", es: "Abre el pecho y deja que el qi circule por el corazón."),
            checkPrompt: L10n.text(en: "Did the crane spread its wings?", tr: "Turna kanatlarını açtı mı?", es: "¿La grulla abrió las alas?"),
            winTitle: L10n.text(en: "You opened the heart.", tr: "Kalbini açtın.", es: "Abriste el corazón."),
            winBody: L10n.text(en: "An open chest, an open day.", tr: "Açık bir göğüs, açık bir gün.", es: "Pecho abierto, día abierto."),
            steps: [
                L10n.text(en: "Stand tall, arms low at your sides.", tr: "Dik dur, kollar yanlarda aşağıda.", es: "De pie erguido, brazos abajo a los lados."),
                L10n.text(en: "Inhale and float the arms wide and up like wings.", tr: "Nefes al ve kolları kanat gibi geniş ve yukarı süzdür.", es: "Inhala y eleva los brazos amplios como alas."),
                L10n.text(en: "Exhale and lower them slowly; repeat six times.", tr: "Ver ve yavaşça indir; altı kez tekrarla.", es: "Exhala y bájalos despacio; repite seis veces.")
            ]
        )
    ]
}
