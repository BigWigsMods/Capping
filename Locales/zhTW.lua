
if GetLocale() ~= "zhTW" then return end
local _, mod = ...
local L = mod.L

L.battleBegins = "開始"
L.finalScore = "預估最終比數：%d - %d"
L.flagRespawns = "旗幟已重置"

L.takenTheFlagTrigger = "^(.+)已經奪走了旗幟!"
L.hasTakenTheTrigger = "奪取了"
L.droppedTrigger = "丟掉了"
L.capturedTheTrigger = "佔據了"

--- Alterac Valley
--- This is the trigger option when talking to the NPC to auto hand in the quest items
--- This chat interaction only appears when the NPC is ready to start an upgrade, and you need to confirm it
L.upgradeToTrigger = "升級成"

L.hordeGate = "部落大門"
L.allianceGate = "聯盟大門"
L.gatePosition = "%s (%s)"
L.west = "碼頭"
L.front = "工坊"
L.east = "機場"
L.hordeBoss = "部落將軍"
L.allianceBoss = "聯盟將軍"
L.galvangar = "加爾凡加"
L.balinda = "巴琳達"
L.ivus = "伊弗斯"
L.lokholar = "洛克霍拉"
L.handIn = "|cFF33FF99Capping|r: 自動上交任務物品。"
L.anchorTooltip = "|cffeda55f右鍵點擊|r打開選項"
L.anchorTooltipNote = "打開選項，並鎖定位置，就能隱藏此綠色移動錨點。"

--- Alliance IoC Workshop yells:
-- Gnomish Mechanic yells: I'm halfway there! Keep the Horde away from here.  They don't teach fighting in engineering school!
-- Gnomish Mechanic yells: It's broken already?! No worries. It's nothing I can't fix.
--- Horde IoC Workshop yells:
-- Goblin Mechanic yells: I'm about halfway done! Keep the Alliance away - fighting's not in my contract!
-- Goblin Mechanic yells: It's broken again?! I'll fix it... just don't expect the warranty to cover this.
--L.halfway = "halfway" -- Needs to match the in game text exactly
--L.broken = "broken" -- Needs to match the in game text exactly

-- Wintergrasp
L.damaged = "|cFF33FF99Capping|r: %s 受到攻擊"
L.destroyed = "|cFF33FF99Capping|r: %s 被摧毀了"
L.northEastKeep = "冬握保壘哨塔 (東北)"
L.southEastKeep = "冬握保壘哨塔 (東南)"
L.northWestKeep = "冬握保壘哨塔 (西北)"
L.southWestKeep = "冬握保壘哨塔 (西南)"
L.northWest = "西北城牆"
L.southWest = "西南城牆"
L.south = "南面城牆"
L.southEast = "東南城牆"
L.northEast = "東北城牆"
L.innerWest = "西面內牆"
L.innerSouth = "南面內牆"
L.innerEast = "東面內牆"
L.southGate = "冬握堡壘城門"
L.mainEntrance = "冬握堡壘大門"
L.westTower = "西側焰望哨塔"
L.southTower = "南側冬際哨塔"
L.eastTower = "東側影景哨塔"

-- Ashran
L.hordeGuardian = "部落守衛"
L.allianceGuardian = "聯盟守衛"
--L.kronus = "Kronus"
--L.fangraal = "Fangraal"

-- Arena
--L.arenaStartTrigger = "The Arena battle has begun!" -- Needs to match the in game text exactly
--L.arenaStart60s = "One minute until the Arena battle begins!" -- Needs to match the in game text exactly
--L.arenaStart30s = "Thirty seconds until the Arena battle begins!" -- Needs to match the in game text exactly
--L.arenaStart15s = "Fifteen seconds until the Arena battle begins!" -- Needs to match the in game text exactly
