
if GetLocale() ~= "deDE" then return end
local _, mod = ...
local L = mod.L

L.battleBegins = "Schlachtfeld beginnt"
L.finalScore = "Endstand: %d - %d"
L.flagRespawns = "Flaggen"

L.takenTheFlagTrigger = "^(.+) hat die Fahne erobert!"
L.hasTakenTheTrigger = "eingenommen!"
--L.upgradeToTrigger = "Upgrade to"
L.droppedTrigger = "fallen lassen!"
L.capturedTheTrigger = "errungen!"

L.hordeGate = "Hordentor"
L.allianceGate = "Allianztor"
--L.hordeBoss = "Horde Boss"
--L.allianceBoss = "Alliance Boss"
--L.galvangar = "Galvangar"
L.balinda = "Balinda" -- Hauptmann Balinda Steinbruch
L.ivus = "Ivus" -- Ivus der Waldlord
L.lokholar = "Lokholar" -- Lokholar der Eislord
--L.handIn = "|cFF33FF99Capping|r: Automatically handing in quest items."

--- Alliance IoC Workshop yells:
-- Gnomenmechaniker: Ich hab's gleich! Haltet die Horde von hier fern. Kämpfen stand in der Ingenieursschule nicht auf dem
-- Gnomenmechaniker: Es ist schon kaputt?! Ach, keine Sorge, nichts, was ich nicht reparieren kann.
--- Horde IoC Workshop yells:
-- Goblinmechaniker: Ich hab's gleich! Haltet mir die Allianz vom Leib. Kämpfen steht nicht in meinem Vertrag!
-- Goblinmechaniker: Schon wieder kaputt?! Ich werde es richten... Ihr solltet allerdings nicht davon ausgehen, dass das noch unter die Garantie
L.halfway = "gleich!"
L.broken = "kaputt?"

-- Wintergrasp
--L.damaged = "|cFF33FF99Capping|r: %s damaged"
--L.destroyed = "|cFF33FF99Capping|r: %s destroyed"
--L.northWest = "North-West wall"
--L.southWest = "South-West wall"
--L.south = "South wall"
--L.southEast = "South-East wall"
--L.northEast = "North-East wall"
--L.innerWest = "Inner-West wall"
--L.innerSouth = "Inner-South wall"
--L.innerEast = "Inner-East wall"
--L.southGate = "South gate"
--L.mainEntrance = "Main entrance"
--L.westTower = "West Tower"
--L.southTower = "South Tower"
--L.eastTower = "East Tower"
