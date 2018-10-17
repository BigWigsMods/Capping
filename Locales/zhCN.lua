
if GetLocale() ~= "zhCN" then return end
local _, mod = ...
local L = mod.L

L.battleBegins = "战斗即将开始"
L.finalScore = "最终：%d - %d"
L.flagRespawns = "旗帜即将刷新"

L.takenTheFlagTrigger = "^(.+)夺走了旗帜！"
L.hasTakenTheTrigger = "夺取了"
L.upgradeToTrigger = "升级到"
L.droppedTrigger = "丢掉了"
L.capturedTheTrigger = "夺取"

--L.hordeGate = "Horde Gate"
--L.allianceGate = "Alliance Gate"
--L.hordeBoss = "Horde Boss"
--L.allianceBoss = "Alliance Boss"
--L.galvangar = "Galvangar"
--L.balinda = "Balinda Stonehearth"
