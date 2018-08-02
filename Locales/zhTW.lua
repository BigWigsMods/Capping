
if GetLocale() ~= "zhTW" then return end
local _, mod = ...
local L = mod.L

L.battleBegins = "開始"
L.finalScore = "估計最終比數: %d - %d"
L.flagRespawns = "旗幟已重置"

L.takenTheFlagTrigger = "^(.+)已經奪走了旗幟!"
L.hasTakenTheTrigger = "奪取了"
L.upgradeToTrigger = "升級成"
L.droppedTrigger = "丟掉了"
L.capturedTheTrigger = "佔據了"
