
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
Gnomish Mechanic yells: "¡Ya estoy a medio camino! Mantened a la Horda lejos de aquí. ¡No enseñan a luchar en la escuela de ingeniería!"
Gnomish Mechanic yells: "¡¿Ya está roto?! No os preocupéis. No existe nada que no pueda reparar."
--- Horde IoC Workshop yells:
Goblin Mechanic yells: "¡Ya llevo la mitad del camino! Mantened a la Alianza lejos - ¡luchar no está en mi contrato!"
Goblin Mechanic yells: "¡¿Otra vez roto?! Lo arreglaré... es sólo que dudo que la garantía lo cubra."
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
