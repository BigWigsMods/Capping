
if GetLocale() ~= "ptBR" then return end
local _, mod = ...
local L = mod.L

L.battleBegins = "Batalha Começa"
L.finalScore = "Final: %d - %d"
L.flagRespawns = "Bandeira reaparece"

L.takenTheFlagTrigger = "^(.+) pegou a bandeira!"
--L.hasTakenTheTrigger = "has taken the"
--L.upgradeToTrigger = "Upgrade to"
L.droppedTrigger = "largada"
L.capturedTheTrigger = "capturou"

L.hordeGate = "Portão da Horda"
L.allianceGate = "Portão da Aliança"
L.gatePosition = "%s (%s)"
L.west = "Oeste"
L.front = "Frente"
L.east = "Leste"
L.hordeBoss = "Chefe da Horda"
L.allianceBoss = "Chefe da Aliança"
L.hordeGuardian = "Guardião da Horda"
L.allianceGuardian = "Guardião da Aliança"
L.galvangar = "Galvangar"
L.balinda = "Balinda"
L.ivus = "Ivus"
L.lokholar = "Lokholar"
L.handIn = "|cFF33FF99Capping|r: Automaticamente entregando items de quest."

--- Alliance IoC Workshop yells:
-- Mecânico Gnômico grita: Estou na metade do caminho! Mantenha a Horda longe. Não ensinam luta na faculdade de engenharia!
-- Mecânico Gnômico grita: Já quebrou?! Não esquenta. Não é nada que eu não possa consertar.
--- Horde IoC Workshop yells:
-- Mecânico Goblin grita: Estou quase acabando! Mantenha a Aliança longe de mim. Lutar não está no meu contrato!
-- Mecânico Goblin grita: Quebrou de novo?! Eu conserto... Mas não fique esperando que a garantia cubra isso.
L.halfway = "[Ll]utar? "
L.broken = "uebrou"

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
L.southTower = "Torre Sul"
L.eastTower = "Torre Leste"

-- Arena
--L.arenaStartTrigger = "The Arena battle has begun!" -- Needs to match the in game text exactly
--L.arenaStart60s = "One minute until the Arena battle begins!" -- Needs to match the in game text exactly
--L.arenaStart30s = "Thirty seconds until the Arena battle begins!" -- Needs to match the in game text exactly
--L.arenaStart15s = "Fifteen seconds until the Arena battle begins!" -- Needs to match the in game text exactly
