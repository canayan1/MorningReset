import Foundation

enum FirstWinAction: String, Codable, CaseIterable, Identifiable, Equatable {
    case water
    case movement
    case firstTask
    case phoneDown

    var id: Self { self }

    var title: String {
        switch self {
        case .water:
            return L10n.text(en: "Drink water", tr: "Su iç", es: "Bebe agua")
        case .movement:
            return L10n.text(en: "60-second movement", tr: "60 saniyelik hareket", es: "Movimiento de 60 segundos")
        case .firstTask:
            return L10n.text(en: "Start first task", tr: "İlk göreve başla", es: "Empieza la primera tarea")
        case .phoneDown:
            return L10n.text(en: "5 minutes phone down", tr: "5 dakika telefonu bırak", es: "5 minutos sin teléfono")
        }
    }

    var buttonTitle: String {
        switch self {
        case .water:
            return L10n.text(en: "I drank the water", tr: "Suyu içtim", es: "Bebí el agua")
        case .movement:
            return L10n.text(en: "Start 60-second move", tr: "60 saniyelik hareketi başlat", es: "Empezar movimiento de 60 segundos")
        case .firstTask:
            return L10n.text(en: "I started the task", tr: "Göreve başladım", es: "Empecé la tarea")
        case .phoneDown:
            return L10n.text(en: "Phone is down", tr: "Telefonu bıraktım", es: "El teléfono está abajo")
        }
    }

    var checkoutTitle: String {
        switch self {
        case .water:
            return L10n.text(en: "Did you drink the water?", tr: "Suyu içtin mi?", es: "¿Bebiste el agua?")
        case .movement:
            return L10n.text(en: "Did you finish the 60-second move?", tr: "60 saniyelik hareketi bitirdin mi?", es: "¿Terminaste el movimiento de 60 segundos?")
        case .firstTask:
            return L10n.text(en: "Did you start the first task?", tr: "İlk göreve başladın mı?", es: "¿Empezaste la primera tarea?")
        case .phoneDown:
            return L10n.text(en: "Did you put the phone down?", tr: "Telefonu bıraktın mı?", es: "¿Dejaste el teléfono?")
        }
    }

    func detail(for mode: MorningMode) -> String {
        switch (self, mode) {
        case (.water, .protect):
            return L10n.text(en: "Start with your body before the world gets a vote.", tr: "Dünya araya girmeden önce bedeninle başla.", es: "Empieza con tu cuerpo antes de que el mundo intervenga.")
        case (.water, .steady):
            return L10n.text(en: "Hydrate first, then take the next clean step.", tr: "Önce su iç, sonra sıradaki net adıma geç.", es: "Hidrátate primero y luego da el siguiente paso claro.")
        case (.water, .push):
            return L10n.text(en: "Ground the energy before you spend it.", tr: "Harcamadan önce enerjiyi yere bastır.", es: "Asienta la energía antes de gastarla.")
        case (.movement, .protect):
            return L10n.text(en: "Wake the body gently without forcing the morning.", tr: "Sabahı zorlamadan bedeni nazikçe uyandır.", es: "Despierta el cuerpo con suavidad sin forzar la mañana.")
        case (.movement, .steady):
            return L10n.text(en: "Use motion to turn a workable start into momentum.", tr: "Hareketi, çalışılabilir başlangıcı ivmeye çevirmek için kullan.", es: "Usa el movimiento para convertir un inicio funcional en impulso.")
        case (.movement, .push):
            return L10n.text(en: "Channel the energy into something physical right away.", tr: "Enerjiyi hemen fiziksel bir şeye yönlendir.", es: "Canaliza la energía enseguida hacia algo físico.")
        case (.firstTask, .protect):
            return L10n.text(en: "Pick the smallest real task so the day can settle.", tr: "Günün sakinleşmesi için en küçük gerçek işi seç.", es: "Elige la tarea real más pequeña para que el día se asiente.")
        case (.firstTask, .steady):
            return L10n.text(en: "Turn this morning into visible progress before input.", tr: "Girdiler gelmeden önce bu sabahı görünür ilerlemeye çevir.", es: "Convierte esta mañana en progreso visible antes de recibir entradas.")
        case (.firstTask, .push):
            return L10n.text(en: "Aim the energy at the thing that actually matters.", tr: "Enerjiyi gerçekten önemli olan şeye yönelt.", es: "Dirige la energía hacia lo que de verdad importa.")
        case (.phoneDown, .protect):
            return L10n.text(en: "Give your nervous system five quiet minutes first.", tr: "Önce sinir sistemine beş dakikalık sessizlik ver.", es: "Dale primero cinco minutos de calma a tu sistema nervioso.")
        case (.phoneDown, .steady):
            return L10n.text(en: "Protect your first attention block from drift.", tr: "İlk dikkat bloğunu dağılmadan koru.", es: "Protege tu primer bloque de atención para que no se disperse.")
        case (.phoneDown, .push):
            return L10n.text(en: "Keep the morning pointed at your priorities, not feeds.", tr: "Sabahı akışlara değil önceliklerine dönük tut.", es: "Mantén la mañana orientada a tus prioridades, no a los feeds.")
        }
    }

    func actionTitle(for mode: MorningMode) -> String {
        switch self {
        case .water:
            if mode == .protect {
                return L10n.text(en: "Get a full glass of water.", tr: "Dolu bir bardak su al.", es: "Toma un vaso lleno de agua.")
            }
            return L10n.text(en: "Get water before anything else.", tr: "Her şeyden önce su al.", es: "Toma agua antes de cualquier otra cosa.")
        case .movement:
            return L10n.text(en: "Move for one minute.", tr: "Bir dakika hareket et.", es: "Muévete durante un minuto.")
        case .firstTask:
            return L10n.text(en: "Start the first real task.", tr: "İlk gerçek göreve başla.", es: "Empieza la primera tarea real.")
        case .phoneDown:
            return L10n.text(en: "Put the phone down for five minutes.", tr: "Telefonu beş dakikalığına bırak.", es: "Deja el teléfono cinco minutos.")
        }
    }

    var actionBody: String {
        switch self {
        case .water:
            return L10n.text(en: "Nothing fancy. Stand up, get the water, drink it, then come back.", tr: "Abartı yok. Ayağa kalk, suyu al, iç ve geri gel.", es: "Nada sofisticado. Levántate, ve por el agua, bébela y vuelve.")
        case .movement:
            return L10n.text(en: "Any simple movement counts. The goal is to wake the body, not perform.", tr: "Her basit hareket sayılır. Amaç performans değil, bedeni uyandırmak.", es: "Cualquier movimiento sencillo cuenta. La meta es despertar el cuerpo, no rendir.")
        case .firstTask:
            return L10n.text(en: "Open the thing that gives the day shape and do the first visible piece.", tr: "Güne şekil veren şeyi aç ve ilk görünür parçayı yap.", es: "Abre lo que le da forma al día y haz la primera parte visible.")
        case .phoneDown:
            return L10n.text(en: "Place the phone face down and give yourself a small pocket of silence.", tr: "Telefonu ekranı aşağı gelecek şekilde bırak ve kendine küçük bir sessizlik alanı ver.", es: "Deja el teléfono boca abajo y date un pequeño espacio de silencio.")
        }
    }

    var steps: [String] {
        switch self {
        case .water:
            return [
                L10n.text(en: "Stand up and walk to the nearest water.", tr: "Ayağa kalk ve en yakın suya yürü.", es: "Levántate y camina hasta el agua más cercana."),
                L10n.text(en: "Drink a full glass slowly.", tr: "Dolu bir bardağı yavaşça iç.", es: "Bebe despacio un vaso lleno."),
                L10n.text(en: "Come back without checking anything else.", tr: "Başka bir şey kontrol etmeden geri dön.", es: "Vuelve sin revisar ninguna otra cosa.")
            ]
        case .movement:
            return [
                L10n.text(en: "Start the timer.", tr: "Zamanlayıcıyı başlat.", es: "Inicia el temporizador."),
                L10n.text(en: "Follow the cues for one minute.", tr: "Bir dakika boyunca yönlendirmeleri takip et.", es: "Sigue las indicaciones durante un minuto."),
                L10n.text(en: "Lock in the win when the minute ends.", tr: "Dakika bitince kazanımı kilitle.", es: "Fija la victoria cuando termine el minuto.")
            ]
        case .firstTask:
            return [
                L10n.text(en: "Open the first task that matters today.", tr: "Bugün önemli olan ilk görevi aç.", es: "Abre la primera tarea que importa hoy."),
                L10n.text(en: "Do the smallest real part of it now.", tr: "Şimdi onun en küçük gerçek parçasını yap.", es: "Haz ahora la parte real más pequeña."),
                L10n.text(en: "Stop after you have clear forward motion.", tr: "Net bir ileri hareket yakaladığında dur.", es: "Detente cuando ya tengas un avance claro.")
            ]
        case .phoneDown:
            return [
                L10n.text(en: "Put the phone face down.", tr: "Telefonu ekranı aşağı gelecek şekilde bırak.", es: "Deja el teléfono boca abajo."),
                L10n.text(en: "Step away from the feed and notifications.", tr: "Akıştan ve bildirimlerden uzaklaş.", es: "Aléjate del feed y las notificaciones."),
                L10n.text(en: "Give yourself five quiet minutes.", tr: "Kendine beş dakikalık sessizlik ver.", es: "Regálate cinco minutos de calma.")
            ]
        }
    }

    var winTitle: String {
        switch self {
        case .water:
            return L10n.text(en: "You started with water.", tr: "Su ile başladın.", es: "Empezaste con agua.")
        case .movement:
            return L10n.text(en: "You moved before the scroll.", tr: "Kaydırmadan önce hareket ettin.", es: "Te moviste antes del scroll.")
        case .firstTask:
            return L10n.text(en: "You started the day with action.", tr: "Güne eylemle başladın.", es: "Empezaste el día con acción.")
        case .phoneDown:
            return L10n.text(en: "You protected the first five minutes.", tr: "İlk beş dakikayı korudun.", es: "Protegiste los primeros cinco minutos.")
        }
    }

    var winBody: String {
        switch self {
        case .water:
            return L10n.text(en: "That first decision was physical, not reactive.", tr: "İlk kararın tepkisel değil, fiziksel oldu.", es: "Esa primera decisión fue física, no reactiva.")
        case .movement:
            return L10n.text(en: "Your body woke up before the noise did.", tr: "Bedenin gürültüden önce uyandı.", es: "Tu cuerpo despertó antes que el ruido.")
        case .firstTask:
            return L10n.text(en: "Momentum is already real now, not theoretical.", tr: "İvme artık teorik değil, gerçek.", es: "El impulso ya es real, no teórico.")
        case .phoneDown:
            return L10n.text(en: "You gave your attention back to yourself first.", tr: "Dikkatini önce kendine geri verdin.", es: "Primero te devolviste la atención a ti mismo.")
        }
    }
}

enum ActionContent {

    static func recommendedFirstWin(for mode: MorningMode) -> FirstWinAction {
        switch mode {
        case .protect: return .water
        case .steady:  return .firstTask
        case .push:    return .movement
        }
    }

    static func orderedFirstWins(for mode: MorningMode) -> [FirstWinAction] {
        let recommended = recommendedFirstWin(for: mode)
        return [recommended] + FirstWinAction.allCases.filter { $0 != recommended }
    }
}
