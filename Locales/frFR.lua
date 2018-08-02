
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
