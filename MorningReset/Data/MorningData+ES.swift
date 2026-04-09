import Foundation

extension MorningData {

    static var protectES: MorningResult {
        let i = variantIndex
        return MorningResult(
            mode: "Protect",
            meaning: [
                "Esta mañana empieza baja. Ajusta el día en consecuencia.",
                "Hoy empieza sensible. Mantenlo usable.",
                "Inclínate hacia la estabilidad hoy. La intensidad puede esperar.",
                "Las señales de esta mañana están mezcladas. Estabilízate antes de asumir más.",
                "No es una mañana de alta capacidad. Mantén las exigencias bajas.",
                "Inicio suave. Trata la mañana como cristal.",
                "Poco combustible. Muévete con cuidado, no con presión.",
                "Clima silencioso por dentro. No abras la puerta demasiado rápido.",
                "Mañana de media luz. No fuerces la habitación a brillar.",
                "El cuerpo pide paciencia. Escucha una vez.",
                "Una mañana de aliento contenido. No lo sueltes en ruido.",
                "Mañana reservada. No gastes nada que puedas guardar."
            ][i],
            startWith: [
                "pies en el suelo, luego agua — nada más todavía",
                "levántate despacio, abre las cortinas, agua antes que nada",
                "baño, agua, una cosa fácil — en ese orden",
                "levántate, bebe agua, luego una tarea con un final claro",
                "levántate suavemente, primero agua, luego tu tarea más predecible",
                "siéntate en el borde de la cama, respira dos veces, luego agua",
                "arriba, enciende una lámpara, bebe agua antes de tocar el teléfono",
                "pies abajo, tres respiraciones lentas, agua, una tarea tranquila",
                "levántate, abre una ventana, agua, luego lo más fácil de tu lista",
                "arriba, mójate la cara con agua fría, luego bebe un vaso entero",
                "siéntate recto, respira lento diez veces, agua, luego muévete una vez",
                "pies en el suelo, ojos en la habitación, agua, nada más"
            ][i],
            avoid: [
                "mensajes antes de asentarte",
                "planificación reactiva",
                "noticias y feeds",
                "decisiones de alto riesgo antes de asentarte",
                "decisiones que puedes dejar para mañana",
                "cualquier cosa que pida una respuesta inmediata",
                "compararte con nadie, en ningún lugar",
                "la urgencia de hacer esta mañana productiva",
                "la bandeja de entrada hasta que hayas comido algo",
                "la emergencia de otro antes de tu primer vaso de agua",
                "la espiral de arreglar cosas que aún no están rotas",
                "prometer más de lo que puedes cargar hoy"
            ][i],
            win: [
                "una primera hora tranquila",
                "sin espiral, sin caída",
                "lo suficientemente claro para moverse, sin agotarte",
                "terminar la mañana intacto",
                "una tarea hecha sin desgastarte",
                "terminar la mañana con algo en el tanque",
                "sin promesas rotas a ti mismo",
                "un aterrizaje suave en vez de un inicio duro",
                "un éxito silencioso antes del mediodía",
                "dejar la mañana con tu sistema nervioso intacto",
                "presentarte a una cosa pequeña a tiempo",
                "una mañana por la que no debas disculparte"
            ][i],
            music: [
                "lento, espacioso, sin letra",
                "ambient, mínimo, sin presión rítmica",
                "tempo bajo, arreglo disperso",
                "instrumental, nada exigente",
                "silencioso, discreto, de fondo",
                "piano suave, temperatura de habitación",
                "acordes estirados, como el clima",
                "neoclásico, fino como papel",
                "un solo instrumento, un solo pensamiento",
                "bordes difusos, sin ritmo",
                "grabación de campo sobre una nota sostenida",
                "siseo de cinta y un acorde lento"
            ][i],
            bonus: [
                "Frase del día: protege el sistema antes de forzarlo.",
                "Señal matinal: día de recuperación. muévete suavemente.",
                "Señal matinal: día de señal baja. protege tu ritmo.",
                "Frase del día: un suelo estable es mejor que un techo inestable.",
                "Señal matinal: día bajo. no te sobreextiendas.",
                "Frase del día: pequeño y terminado vence a grande y abandonado.",
                "Señal matinal: aire delgado. respira antes de actuar.",
                "Frase del día: cumple una promesa contigo mismo, no más.",
                "Señal matinal: mantén la línea, no la amplíes.",
                "Frase del día: descansar también es dirección.",
                "Señal matinal: camina a través, no corras.",
                "Frase del día: el día es suficientemente largo."
            ][i]
        )
    }

    static var steadyES: MorningResult {
        let i = variantIndex
        return MorningResult(
            mode: "Steady",
            meaning: [
                "Estás lo suficientemente estable para moverte. Usa el día bien.",
                "Esta mañana es trabajable. No la desperdicies.",
                "Sin gran peso esta mañana. Úsala limpiamente.",
                "Ni alto ni bajo. Trabaja con lo que tienes.",
                "Un inicio limpio esta mañana. Úsalo.",
                "Clima promedio por dentro. El clima promedio es suficiente.",
                "Nada en el camino. Comienza sin negociar.",
                "Motor silencioso, tanque lleno. Conduce con cuidado.",
                "Terreno parejo. Da un paso honesto.",
                "Línea base calmada. No busques estimulación.",
                "Mañana trabajable. No la adornes.",
                "Agua quieta. Atraviesa, no luches contra ella."
            ][i],
            startWith: [
                "arriba, agua, luego la tarea que le da forma al día",
                "levántate ya, agua, luego una acción deliberada antes de recibir información",
                "pies abajo, agua, luego tu prioridad más clara",
                "levántate, agua, luego la tarea que pospones sin razón real",
                "arriba, agua, luego un entregable concreto — no una sesión de planificación",
                "arriba, agua, luego veinte minutos en lo que realmente importa",
                "pies abajo, agua, luego la primera oración real del día",
                "arriba, agua, luego el movimiento que facilita el siguiente",
                "levántate, agua, luego empieza el trabajo antes de explicarlo",
                "pies en el suelo, agua, luego comienza por la parte que entiendes",
                "arriba, agua, luego un párrafo, una repetición, una llamada",
                "levántate, agua, luego la versión más pequeña de lo correcto"
            ][i],
            avoid: [
                "scroll aleatorio disfrazado de calentamiento",
                "ruido antes del impulso",
                "productividad falsa",
                "optimizar en vez de ejecutar",
                "sobrepreparar lo que deberías empezar",
                "reorganizar tus herramientas en vez de usarlas",
                "la quinta pestaña que no necesitas abierta",
                "revisar algo que no cambia tu próximo paso",
                "la comodidad de organizar el día en vez de comenzarlo",
                "la segunda taza de café antes de la primera oración",
                "explicarte el trabajo a ti mismo en vez de hacerlo",
                "preguntar cuál tarea antes de responder con movimiento"
            ][i],
            win: [
                "una cosa significativa hecha limpiamente",
                "movimiento limpio de la mañana al mediodía",
                "claridad, ritmo, sin desvíos innecesarios",
                "progreso real en un punto antes de que termine la mañana",
                "avance antes de que se acabe la mañana",
                "enviar la versión pequeña en vez de pulir la imaginada",
                "dejar la mañana más ligera de lo que la encontraste",
                "una cosa terminada, luego la siguiente comenzada",
                "una mañana que se gane la tarde",
                "sin demoras, sin disculpas, solo una cosa hecha",
                "evidencia en la página, no en tu cabeza",
                "movimiento que se compone"
            ][i],
            music: [
                "enfocada, ligera, tempo medio",
                "instrumental, ritmo consistente",
                "lo-fi, paso moderado, sin picos",
                "fondo limpio, pulso estable",
                "baja distracción, energía balanceada",
                "tokyo lo-fi, kick constante",
                "house mínimo cálido, nada ocupado",
                "downtempo escandinavo, contenido",
                "city pop japonés lado mañanero",
                "jazz moderno, solo escobillas",
                "ambient techno a volumen de conversación",
                "post-rock, sin clímax"
            ][i],
            bonus: [
                "Frase del día: el ritmo vence a la intensidad.",
                "Señal matinal: sin fricción esta mañana. mantente en movimiento.",
                "Señal matinal: aire estable. buen día para ejecución limpia.",
                "Frase del día: úsalo. no lo pienses demasiado.",
                "Señal matinal: línea base limpia. buenas condiciones para trabajar.",
                "Frase del día: el movimiento es la respuesta a la mayoría de preguntas matinales.",
                "Señal matinal: nada dramático, que es el regalo.",
                "Frase del día: confía en la versión aburrida del plan.",
                "Señal matinal: la constancia es una ventaja competitiva.",
                "Frase del día: pequeño y constante vence a grande y ocasional.",
                "Señal matinal: condiciones silenciosas para trabajo honesto.",
                "Frase del día: mantén el ritmo, cambia el tempo después."
            ][i]
        )
    }

    static var pushES: MorningResult {
        let i = variantIndex
        return MorningResult(
            mode: "Push",
            meaning: [
                "Señales fuertes esta mañana. Actúa temprano.",
                "Esta mañana tiene apalancamiento. No lo diluyas.",
                "Hay impulso utilizable aquí. Dirígelo.",
                "Las condiciones son buenas. No dejes que la mañana se vaya a la deriva.",
                "La mañana se inclina hacia la producción. Dale dirección.",
                "Mañana con viento a favor. Apunta antes de acelerar.",
                "Señal alta. No la gastes en tareas pequeñas.",
                "Camino abierto. Elige la salida correcta temprano.",
                "Motor caliente. Úsalo en la subida real.",
                "Ventana brillante. Muévete mientras esté abierta.",
                "La mañana te ofrece un tiro limpio. Tómalo.",
                "Mañana cargada. Gástala en lo de mayor apalancamiento."
            ][i],
            startWith: [
                "arriba rápido, agua, luego la tarea más difícil — en ese orden",
                "fuera de la cama, agua, luego trabajo real antes de abrir el feed",
                "levántate, agua, luego la tarea con el mayor retorno",
                "arriba ya, agua, luego algo concreto antes de abrir nada",
                "levántate, primero agua, luego el trabajo que necesita toda tu atención",
                "arriba, agua, luego lo que te aliviaría haber terminado antes del mediodía",
                "pies abajo, agua, luego noventa minutos en la subida real",
                "levántate, agua, luego la tarea con la que has estado negociando",
                "arriba, agua, luego el movimiento que eleva el piso de todo el día",
                "fuera de la cama, agua, luego empieza por la parte que requiere valor",
                "arriba, agua, luego envía la versión que existe, no la de tu cabeza",
                "levántate, agua, luego comprométete antes de revisar nada"
            ][i],
            avoid: [
                "administración antes de producción",
                "revisar todo antes de hacer algo",
                "esfuerzo disperso",
                "calentar demasiado antes de comprometerte",
                "tareas de bajo valor que roban tiempo al trabajo real",
                "pretender que prepararse es lo mismo que trabajar",
                "el mensaje de slack que quiere redirigir tu mañana",
                "quemar la mañana en pestañas superficiales",
                "cualquier reunión que podría ser una oración",
                "dejar que la bandeja de entrada fije tus prioridades",
                "leer sobre el trabajo en vez de hacerlo",
                "pulir lo incorrecto"
            ][i],
            win: [
                "un bloque fuerte de progreso real",
                "progreso antes del mediodía",
                "convertir energía en algo concreto",
                "producción real en las primeras dos horas",
                "un movimiento sustancial en lo que realmente importa",
                "envíalo, aunque sea feo, aunque sea pequeño",
                "noventa minutos que cambien la forma del día",
                "terminar la parte que has estado evitando",
                "dejar la mañana con prueba de trabajo, no prueba de esfuerzo",
                "envía. cierra el ciclo. sigue adelante.",
                "una decisión tomada, ejecutada y olvidada",
                "la versión que existe es mejor que la que no existe"
            ][i],
            music: [
                "energizante, enfocada, bajo caos",
                "tempo impulsor, sin letra",
                "alta energía, ritmo estructurado",
                "tempo rápido, arreglo limpio",
                "construye impulso, sin distracción",
                "deep house, propulsivo pero contenido",
                "techno al amanecer, sin drops",
                "post-rock electrónico, todo hacia adelante",
                "krautrock motorik, mantén la línea",
                "uk garage a bajo volumen",
                "techno mínimo, un solo loop hipnótico",
                "afrobeat instrumental, cuerpo completo"
            ][i],
            bonus: [
                "Frase del día: mañana de señal alta. no la gastes en tareas pequeñas.",
                "Frase del día: la ventana de producción está abierta. cruza.",
                "Señal matinal: el impulso hacia adelante es alto. elige bien tu objetivo.",
                "Frase del día: no entres suave en una mañana así.",
                "Señal matinal: señal fuerte. fija el objetivo temprano.",
                "Frase del día: una mañana fuerte sin objetivo es una mañana desperdiciada.",
                "Señal matinal: día de apalancamiento. componlo.",
                "Frase del día: sé directo con esta mañana.",
                "Señal matinal: luz verde. no pidas permiso.",
                "Frase del día: apunta estrecho, golpea fuerte, sigue.",
                "Señal matinal: marea alta. rema.",
                "Frase del día: la mañana no preguntará dos veces."
            ][i]
        )
    }
}
