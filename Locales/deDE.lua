
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
--L.gatePosition = "%s (%s)"
--L.west = "West"
--L.front = "Front"
--L.east = "East"
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
--L.damaged = "|cFF33FF99Capping|r: %s Damaged"
--L.destroyed = "|cFF33FF99Capping|r: %s Destroyed"
--L.northEastKeep = "North-East Fortress Tower"
--L.southEastKeep = "South-East Fortress Tower"
--L.northWestKeep = "North-West Fortress Tower"
--L.southWestKeep = "South-West Fortress Tower"
--L.northWest = "North-West Wall"
--L.southWest = "South-West Wall"
--L.south = "South Wall"
--L.southEast = "South-East Wall"
--L.northEast = "North-East Wall"
--L.innerWest = "Inner-West Wall"
--L.innerSouth = "Inner-South Wall"
--L.innerEast = "Inner-East Wall"
--L.southGate = "South Gate"
--L.mainEntrance = "Main Entrance"
--L.westTower = "West Tower"
--L.southTower = "South Tower"
--L.eastTower = "East Tower"
