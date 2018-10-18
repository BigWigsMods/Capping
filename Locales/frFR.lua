
if GetLocale() ~= "frFR" then return end
local _, mod = ...
local L = mod.L

L.battleBegins = "Début de la bataille"
L.finalScore = "Final : %d - %d"
L.flagRespawns = "Réapparition drapeau(x)"

L.takenTheFlagTrigger = "^(.+) a pris le drapeau !"
L.hasTakenTheTrigger = "s'est emparée"
--L.upgradeToTrigger = "Upgrade to"
L.droppedTrigger = "a été lâché"
L.capturedTheTrigger = "a pris le drapeau de"

--L.hordeGate = "Horde Gate"
--L.allianceGate = "Alliance Gate"
--L.hordeBoss = "Horde Boss"
--L.allianceBoss = "Alliance Boss"
--L.galvangar = "Galvangar"
--L.balinda = "Balinda Stonehearth"

--- Alliance IoC Workshop yells:
-- Gnomish Mechanic yells: I'm halfway there! Keep the Horde away from here.  They don't teach fighting in engineering school!
-- Gnomish Mechanic yells: It's broken already?! No worries. It's nothing I can't fix.
--- Horde IoC Workshop yells:
-- Goblin Mechanic yells: I'm about halfway done! Keep the Alliance away - fighting's not in my contract!
-- Goblin Mechanic yells: It's broken again?! I'll fix it... just don't expect the warranty to cover this.
--L.halfway = "halfway"
--L.broken = "broken"
