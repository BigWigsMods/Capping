
if GetLocale() ~= "ptBR" then return end
local _, mod = ...
local L = mod.L

L.battleBegins = "Batalha Começa"
--L.finalScore = "Final: %d - %d"
L.flagRespawns = "Bandeira reaparece"

L.takenTheFlagTrigger = "^(.+) pegou a bandeira!"
--L.hasTakenTheTrigger = "has taken the"
--L.upgradeToTrigger = "Upgrade to"
L.droppedTrigger = "largada!"
L.capturedTheTrigger = "capturou"

L.hordeGate = "Portão da Horda"
L.allianceGate = "Portão da Aliança"
--L.gatePosition = "%s (%s)"
L.west = "Oeste" --West
L.front = "Frente"
L.east = "Leste" --East
L.hordeBoss = "Chefe da Horda" -- Horde Boss
L.allianceBoss = "Chefe da Aliança" -- Alliance Boss
L.hordeGuardian = "Guardião da Horda"
L.allianceGuardian = "Guardião da Aliança"
L.galvangar = "Galvangar"
L.balinda = "Balinda"
L.ivus = "Ivus" -- Ivus, o Senhor da Floresta
L.lokholar = "Lokholar" -- Lokholar, o Senhor do Gelo
L.handIn = "|cFF33FF99Capping|r: Automaticamente entregando items de quest."

--- Alliance IoC Workshop yells:
-- Mecânico Gnômico grita: Estou na metade do caminho! Mantenha a Horda longe. Não ensinam luta na faculdade de engenharia! 
-- Mecânico Gnômico grita: Já quebrou?! Não esquenta. Não é nada que eu não possa consertar.
--- Horde IoC Workshop yells:
-- Goblin Mechanic yells: I'm about halfway done! Keep the Alliance away - fighting's not in my contract!
-- Goblin Mechanic yells: It's broken again?! I'll fix it... just don't expect the warranty to cover this.
L.halfway = "caminho!" --need some tests
L.broken = "quebrou?!" --need some tests

-- Wintergrasp
L.damaged = "|cFF33FF99Capping|r: %s Danificada"
L.destroyed = "|cFF33FF99Capping|r: %s Destruída"
L.northEastKeep = "Torre Nordeste da Fortaleza"
L.southEastKeep = "Torre Sudeste da Fortaleza"
L.northWestKeep = "Torre Noroeste da Fortaleza"
L.southWestKeep = "Torre Sudoeste da Fortaleza"
L.northWest = "Muralha Noroeste"
L.southWest = "Muralha Sudoeste"
L.south = "Muralha Sul"
L.southEast = "Muralha Suldeste"
L.northEast = "Muralha Nordeste"
L.innerWest = "Muralha Interior Oeste"
L.innerSouth = "Muralha Interior Sul"
L.innerEast = "Muralha Interior Leste"
L.southGate = "Portão Sul"
L.mainEntrance = "Entrada Principal"
L.westTower = "Torre Oeste"
L.southTower = "Torre Sul" --"South Tower"
L.eastTower = "Torre Leste" --East Tower
