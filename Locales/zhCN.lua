
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
L.gatePosition = "%s (%s)"
L.west = "西"
L.front = "前"
L.east = "东"
L.hordeBoss = "部落将军"
L.allianceBoss = "联盟将军"
L.galvangar = "加尔范上尉"
L.balinda = "巴琳达"
L.ivus = "Ivus"
L.lokholar = "Lokholar"
L.handIn = "|cFF33FF99Capping|r: 自动交任务品."

--- Alliance IoC Workshop yells:
-- 侏儒技师喊道：我就要完成了！挡住那帮部落的家伙。他们可不是在工程学校进行战斗教学！
-- 侏儒技师喊道：它已经坏了？！别担心，没有我修不好的。
--- Horde IoC Workshop yells:
-- 地精机械师喊道：我就要完成了！挡住那帮联盟的家伙，合同上没说我还得打仗！
-- 地精机械师喊道：它又坏了？！我会把它修好……但我可不保证它一定能好用。
L.halfway = "我就要完成了"
L.broken = "坏了"

-- Wintergrasp
L.damaged ="| cFF33FF99Capping | r：％s已损坏"
L.destroyed ="| cFF33FF99Capping | r：％s被摧毁"
L.northEastKeep ="冬拥堡垒塔楼(东北)"
L.southEastKeep ="冬拥堡垒塔楼(东南)"
L.northWestKeep ="冬拥堡垒塔楼(西北)"
L.southWestKeep ="冬拥堡垒塔楼(西南)"
L.northWest ="冬拥堡垒城墙-西北"
L.southWest ="冬拥堡垒城墙-西南"
L.south ="冬拥堡垒城墙-南墙"
L.southEast ="冬拥堡垒城墙-东南墙"
L.northEast ="冬拥堡垒城墙-东北墙"
L.innerWest ="冬拥堡垒城墙-内西墙"
L.innerSouth ="冬拥堡垒城墙-内南墙"
L.innerEast ="冬拥堡垒城墙-内东墙"
L.southGate ="冬拥堡垒大门"
L.mainEntrance ="冬拥堡垒"
L.westTower ="影目塔楼-西塔"
L.southTower ="冬缘塔楼-南塔"
L.eastTower ="火光塔楼-东塔"
