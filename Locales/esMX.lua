
if GetLocale() ~= "esMX" then return end
local _, mod = ...
local L = mod.L

L.battleBegins = "La batalla ha comenzado"
L.finalScore = "Final: %d - %d"
L.flagRespawns = "La bandera se ha restablecido"
L.timeRemaining = "Tiempo"

L.takenTheFlagTrigger = "^(.+) ha cogido la bandera!"
L.hasTakenTheTrigger = "ha cogido"
L.droppedTrigger = "soltado"
L.capturedTheTrigger = "capturado"

L.hordeGate = "Puerta de la Horda"
L.allianceGate = "Puerta de la Alianza"
L.gatePosition = "%s (%s)"
L.west = "Oeste"
L.front = "Frente"
L.east = "Este"
L.hordeBoss = "Jefe de la Horda"
L.allianceBoss = "Jefe de la Alianza"
L.galvangar = "Galvangar"
L.balinda = "Balinda"
L.ivus = "Ivus" -- Ivus el Señor del Bosque
L.lokholar = "Lokholar" -- Lokholar el Señor del Hielo
L.handIn = "|cFF33FF99Capping|r: Entregando objetos de misión automáticamente."
L.anchorTooltip = "|cffeda55fRight-Clic|r para acceder a las opciones"
L.anchorTooltipNote = "Abre las opciones y bloquea las barras para esconder este ancla móvil."

--- Alliance IoC Workshop yells:
-- Mecánico gnomo grita: ¡Estoy a medias! Mantén a la Horda alejada de aquí. ¡En la escuela de ingeniería no enseñan a luchar!
-- Mecánico gnomo grita: ¿Ya está rota? No pasa nada. No es nada que no pueda arreglar.
--- Horde IoC Workshop yells:
-- Mecánico goblin grita: ¡Ya casi estoy! Mantén a la Alianza alejada... ¡Luchar no entra en mi contrato!
-- Mecánico goblin grita: ¿Está estropeada otra vez? Lo arreglaré... pero no esperes que la garantía cubra esto.
L.halfway = "alejada" -- Needs to match the in game text exactly
L.broken = "arreglar" -- Needs to match the in game text exactly

-- Wintergrasp
L.damaged = "|cFF33FF99Capping|r: %s Dañada"
L.destroyed = "|cFF33FF99Capping|r: %s Destruida"
L.northEastKeep = "Torre de la Fortaleza Noreste"
L.southEastKeep = "Torre de la Fortaleza Sureste"
L.northWestKeep = "Torre de la Fortaleza Noroeste"
L.southWestKeep = "Torre de la Fortaleza Suroeste"
L.northWest = "Muralla del Noroeste"
L.southWest = "Muralla del Suroeste"
L.south = "Muralla del Sur"
L.southEast = "Muralla del Sureste"
L.northEast = "Muralla del Noreste"
L.innerWest = "Muralla interior Oeste"
L.innerSouth = "Muralla interior Sur"
L.innerEast = "Muralla interior Este"
L.southGate = "Puerta del Sur"
L.mainEntrance = "Entrada principal"
L.westTower = "Torre del Oeste"
L.southTower = "Torre del Sur"
L.eastTower = "Torre del Este"

-- Ashran
L.hordeGuardian = "Guardián de la Horda"
L.allianceGuardian = "Guardián de la Alianza"
L.kronus = "Kronus"
L.fangraal = "Fangraal"

-- Arena
L.arenaStartTrigger = "¡La batalla de arena ha comenzado!" -- Needs to match the in game text exactly
L.arenaStart60s = "¡Un minuto hasta que comience la batalla de arena!" -- Needs to match the in game text exactly
L.arenaStart30s = "¡Treinta segundos hasta que comience la batalla de arena!" -- Needs to match the in game text exactly
L.arenaStart15s = "¡Quince segundos para que comience la batalla de arena!" -- Needs to match the in game text exactly
