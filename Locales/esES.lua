
if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end
local _, mod = ...
local L = mod.L

L.battleBegins = "Comienza la Batalla"
L.finalScore = "Resultado Final: %d - %d"
L.flagRespawns = "Reaparece la bandera"

L.takenTheFlagTrigger = "¡^(.+) ha cogido la bandera!"
L.hasTakenTheTrigger = "cogido la"
L.upgradeToTrigger = "Mejorado a"
L.droppedTrigger = "caído"
L.capturedTheTrigger = "capturado la"

L.hordeGate = "Portón Horda"
L.allianceGate = "Portón Alianza"
L.gatePosition = "%s (%s)"
L.west = "Oeste"
L.front = "Frente"
L.east = "Este"
L.hordeBoss = "Jefe Horda"
L.allianceBoss = "Jefe Alianza"
L.galvangar = "Galvangar"
L.balinda = "Balinda"
L.ivus = "Ivus" -- Ivus el Señor del Bosque
L.lokholar = "Lokholar" -- Lokholar el Señor del Hielo
L.handIn = "|cFF33FF99Capping|r: Entrega automática de objetos de misión."

--- Alliance IoC Workshop yells:
-- Gnomish Mechanic yells: I'm halfway there! Keep the Horde away from here.  They don't teach fighting in engineering school!
-- Gnomish Mechanic yells: It's broken already?! No worries. It's nothing I can't fix.
--- Horde IoC Workshop yells:
-- Goblin Mechanic yells: I'm about halfway done! Keep the Alliance away - fighting's not in my contract!
-- Goblin Mechanic yells: It's broken again?! I'll fix it... just don't expect the warranty to cover this.
L.halfway = "medio camino"
L.broken = "destruido"

-- Conquista de Invierno
L.damaged = "|cFF33FF99Capping|r: %s Dañado"
L.destroyed = "|cFF33FF99Capping|r: %s Destruido"
L.northEastKeep = "Torre noreste de la Fortaleza"
L.southEastKeep = "Torre sureste de la Fortaleza"
L.northWestKeep = "Torre noroeste de la Fortaleza"
L.southWestKeep = "Torre suroeste de la Fortaleza"
L.northWest = "Muralla del noroeste"
L.southWest = "Muralla del suroeste"
L.south = "Muralla sur"
L.southEast = "Muralla sureste"
L.northEast = "Muralla noreste"
L.innerWest = "Muralla interior oeste"
L.innerSouth = "Muralla interior sur"
L.innerEast = "Muralla interior este"
L.southGate = "Portón sur"
L.mainEntrance = "Entrada principal"
L.westTower = "Torre oeste"
L.southTower = "Torre sur"
L.eastTower = "Torre este"
