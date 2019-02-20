
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
-- 侏儒技师喊道：我就要完成了！挡住那帮部落的家伙。他们可不是在工程学校进行战斗教学！
-- 侏儒技师喊道：它已经坏了？！别担心，没有我修不好的。
--- Horde IoC Workshop yells:
-- 地精机械师喊道：我就要完成了！挡住那帮联盟的家伙，合同上没说我还得打仗！
-- 地精机械师喊道：它又坏了？！我会把它修好……但我可不保证它一定能好用。
L.halfway = "我就要完成了"
L.broken = "坏了"
