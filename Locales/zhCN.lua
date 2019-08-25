
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
L.gatePosition = "%s（%s）"
L.west = "西"
L.front = "前"
L.east = "东"
L.hordeBoss = "部落将军"
L.allianceBoss = "联盟将军"
L.galvangar = "加尔范上尉"
L.balinda = "巴琳达"
L.ivus = "伊弗斯"
L.lokholar = "洛克霍拉"
L.handIn = "|cFF33FF99Capping|r: 自动交任务物品。"

--- Alliance IoC Workshop yells:
-- 侏儒技师喊道：我就要完成了！挡住那帮部落的家伙。他们可不是在工程学校进行战斗教学！
-- 侏儒技师喊道：它已经坏了？！别担心，没有我修不好的。
--- Horde IoC Workshop yells:
-- 地精机械师喊道：我就要完成了！挡住那帮联盟的家伙，合同上没说我还得打仗！
-- 地精机械师喊道：它又坏了？！我会把它修好……但我可不保证它一定能好用。
L.halfway = "我就要完成了"
L.broken = "坏了"

-- Wintergrasp 冬拥湖之战
L.damaged = "|cFF33FF99Capping|r: %s 遭到破坏"
L.destroyed = "|cFF33FF99Capping|r: %s 被摧毁了"
L.northEastKeep = "东北堡垒塔楼"
L.southEastKeep = "东南堡垒塔楼"
L.northWestKeep = "西北堡垒塔楼"
L.southWestKeep = "西南堡垒塔楼"
L.northWest = "西北城墙"
L.southWest = "东南城墙"
L.south = "南城墙"
L.southEast = "东南城墙"
L.northEast = "东北城墙"
L.innerWest = "西内墙"
L.innerSouth = "南内墙"
L.innerEast = "东内墙"
L.southGate = "堡垒大门（南）"
L.mainEntrance = "堡垒塔楼之门（最后一面墙）"
L.westTower = "影目塔楼（西塔）"
L.southTower = "冬缘塔楼（南塔）"
L.eastTower = "火光塔楼（东塔）"
