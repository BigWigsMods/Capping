if GetLocale() ~= "esMX" then return end
local _, mod = ...
local L = mod.L

--- Options
L.introduction = "Puedes acceder a los opciones de abajo escribiendo el siguiente comando en el chat: /capping"
L.general = "General"
L.test = "Prueba"
L.lock = "Bloqueo"
L.lockDesc = "Activa el bloqueo para esconder el ancla móvil de la barra, evitando que las barras se muevan"
L.barIcon = "Icono de barra"
L.showTime = "Mostrar tiempo"
L.fillBar = "Rellenar barra"
L.font = "Fuente"
L.fontSize = "Tamaño de fuente"
L.monochrome = "Texto monocromo"
L.outline = "Borde de línea"
L.none = "Ninguno"
L.thin = "Estrecho"
L.thick = "Grueso"
L.texture = "Textura"
L.barSpacing = "Espacio de barra"
L.barWidth = "Anchura de barra"
L.barHeight = "Altura de barra"
L.alignText = "Alinear texto"
L.alignTime = "Alinear tiempo"
L.alignIcon = "Alinear icono de barra"
L.left = "Izquierda"
L.center = "Centro"
L.right = "Derecha"
L.growUpwards = "Crecer hacia arriba"
L.textColor = "Color de texto"
L.allianceBars = "Barras de la Alianza"
L.hordeBars = "Barras de la Horda"
L.queueBars = "Barras de cola"
L.otherBars = "Otras barras"
L.barBackground = "Fondo de barra"

--- Features
L.features = "Características"
L.queueBarsDesc = "Activa las barras mostrando a qué colas te has unido y qué tiempo estimado en cola estarás."
L.barClickDesc = "Configura el modificador de teclado que desees usar para la salida de chat específica cuando hagas click en una barra. Seleccionando las 3 a 'Ninguno' desactivará las barras clicables, permitiéndote clicar a través de ellas."
L.shiftClick = "Shift-Clic"
L.controlClick = "Control-Clic"
L.altClick = "Alt-Clic"
L.sayChat = "Chat decir"
L.raidChat = "Chat de grupo"
L.clickableBars = "Barras clicables"
L.loudQueue = "Cola ruidosa"
L.loudQueueDesc = "Cuando la cola esté lista el sonido de notificación será forzado a sonar a través del canal de sonido 'General'."
L.autoTurnIn = "Entregar automáticamente"
L.autoTurnInDesc = "Automáticamente entrega objetos de misión en zonas como Valle de Alterac y Ashran."
