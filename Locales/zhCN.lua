
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

L.hordeGate = "部落大门"
L.allianceGate = "联盟大门"
L.hordeBoss = "部落将军"
L.allianceBoss = "联盟将军"
L.galvangar = "加尔范上尉"
L.balinda = "巴琳达·斯通赫尔斯"

--- Alliance IoC Workshop yells:
-- Gnomish Mechanic yells: I'm halfway there! Keep the Horde away from here.  They don't teach fighting in engineering school!
-- Gnomish Mechanic yells: It's broken already?! No worries. It's nothing I can't fix.
--- Horde IoC Workshop yells:
-- Goblin Mechanic yells: I'm about halfway done! Keep the Alliance away - fighting's not in my contract!
-- Goblin Mechanic yells: It's broken again?! I'll fix it... just don't expect the warranty to cover this.
L.halfway = "一半"
L.broken = "被摧毁"
