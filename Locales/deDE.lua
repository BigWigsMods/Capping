
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

--L.hordeGate = "Horde Gate"
--L.allianceGate = "Alliance Gate"
--L.hordeBoss = "Horde Boss"
--L.allianceBoss = "Alliance Boss"
--L.galvangar = "Galvangar"
--L.balinda = "Balinda Stonehearth"
