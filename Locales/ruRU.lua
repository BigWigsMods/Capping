
if GetLocale() ~= "ruRU" then return end
local _, mod = ...
local L = mod.L

L.battleBegins = "Начало сражения"
L.finalScore = "Финал: %d - %d"
L.flagRespawns = "Появление Флагов"

L.takenTheFlagTrigger = "^(.+) захватывает флаг!"
L.hasTakenTheTrigger = "захватил"
--L.upgradeToTrigger = "Upgrade to"
L.droppedTrigger = "уронил"
L.capturedTheTrigger = "захватил"
