
if GetLocale() ~= "deDE" then return end
local _, mod = ...
local L = mod.L

L.battleBegins = "Schlachtfeld beginnt"
L.finalScore = "Endstand: %d - %d"
L.flagRespawns = "Flaggen"

L.takenTheFlagTrigger = "^(.+) hat die Fahne erobert!"
L.hasTakenTheTrigger = "eingenommen!"
L.upgradeToTrigger = "Verbessert zu" -- todo: muss Schmied Regzar bzw. Murgot Tiefenschmied Gossip-Option sein!
L.droppedTrigger = "fallen lassen!"
L.capturedTheTrigger = "errungen!"

L.hordeGate = "Hordentor"
L.allianceGate = "Allianztor"
L.gatePosition = "%s (%s)"
L.west = "West"
L.front = "Vorne"
L.east = "Ost"
L.hordeBoss = "Hordeboss"
L.allianceBoss = "Allianzboss"
L.galvangar = "Galvangar" -- Hauptmann Galvangar
L.balinda = "Balinda" -- Hauptmann Balinda Steinbruch
L.ivus = "Ivus" -- Ivus der Waldlord
L.lokholar = "Lokholar" -- Lokholar der Eislord
L.handIn = "|cFF33FF99Capping|r: Gebe Quest-Gegenstände automatisch ab."

--- Alliance IoC Workshop yells:
-- Gnomenmechaniker: Ich hab's gleich! Haltet die Horde von hier fern. Kämpfen stand in der Ingenieursschule nicht auf dem
-- Gnomenmechaniker: Es ist schon kaputt?! Ach, keine Sorge, nichts, was ich nicht reparieren kann.
--- Horde IoC Workshop yells:
-- Goblinmechaniker: Ich hab's gleich! Haltet mir die Allianz vom Leib. Kämpfen steht nicht in meinem Vertrag!
-- Goblinmechaniker: Schon wieder kaputt?! Ich werde es richten... Ihr solltet allerdings nicht davon ausgehen, dass das noch unter die Garantie
L.halfway = "Gleich!"
L.broken = "Kaputt?"

-- Wintergrasp
L.damaged = "|cFF33FF99Capping|r: %s beschädigt"
L.destroyed = "|cFF33FF99Capping|r: %s zerstört"
L.northEastKeep = "Nordöstlicher Festungsturm"
L.southEastKeep = "Südöstlicher Festungsturm"
L.northWestKeep = "Nordwestlicher Festungsturm"
L.southWestKeep = "Südwestlicher Festungsturm"
L.northWest = "Nordwestliche Wand"
L.southWest = "Südwestliche Wand"
L.south = "Südliche Wand"
L.southEast = "Südöstliche Wand"
L.northEast = "Nordöstliche Wand"
L.innerWest = "Innere westliche Wand"
L.innerSouth = "Innere südliche Wand"
L.innerEast = "Innere östliche Wand"
L.southGate = "Südliches Tor"
L.mainEntrance = "Haupteingang"
L.westTower = "Westlicher Turm"
L.southTower = "Südlicher Turm"
L.eastTower = "Östlicher Turm"
