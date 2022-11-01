
if GetLocale() ~= "koKR" then return end
local _, mod = ...
local L = mod.L

L.battleBegins = "전투 개시"
L.finalScore = "종료: %d - %d"
L.flagRespawns = "깃발 생성"

L.takenTheFlagTrigger = "^(.+)|1이;가; 깃발을 차지했습니다!"
L.hasTakenTheTrigger = "점령했습니다"
L.droppedTrigger = "([^ ]*)|1이;가; ([^!]*) 깃발을 떨어뜨렸습니다!"
L.capturedTheTrigger = "([^ ]*)|1이;가; ([^!]*) 깃발 쟁탈에 성공했습니다!"

--- Alterac Valley
--- This is the trigger option when talking to the NPC to auto hand in the quest items
--- This chat interaction only appears when the NPC is ready to start an upgrade, and you need to confirm it
L.upgradeToTrigger = "추가 전리품"

--L.hordeGate = "Horde Gate"
--L.allianceGate = "Alliance Gate"
--L.gatePosition = "%s (%s)"
--L.west = "West"
--L.front = "Front"
--L.east = "East"
--L.hordeBoss = "Horde Boss"
--L.allianceBoss = "Alliance Boss"
--L.galvangar = "Galvangar"
--L.balinda = "Balinda"
--L.ivus = "Ivus"
--L.lokholar = "Lokholar"
--L.handIn = "|cFF33FF99Capping|r: Automatically handing in quest items."
L.anchorTooltip = "옵션에 접근하려면 |cffeda55f오른쪽 클릭|r하세요"
--L.anchorTooltipNote = "Open the options and lock the bars to hide this moving anchor."

--- Alliance IoC Workshop yells:
-- Gnomish Mechanic yells: I'm halfway there! Keep the Horde away from here.  They don't teach fighting in engineering school!
-- Gnomish Mechanic yells: It's broken already?! No worries. It's nothing I can't fix.
--- Horde IoC Workshop yells:
-- Goblin Mechanic yells: I'm about halfway done! Keep the Alliance away - fighting's not in my contract!
-- Goblin Mechanic yells: It's broken again?! I'll fix it... just don't expect the warranty to cover this.
--L.halfway = "halfway" -- Needs to match the in game text exactly
--L.broken = "broken" -- Needs to match the in game text exactly

-- Wintergrasp
--L.damaged = "|cFF33FF99Capping|r: %s Damaged"
--L.destroyed = "|cFF33FF99Capping|r: %s Destroyed"
--L.northEastKeep = "North-East Fortress Tower"
--L.southEastKeep = "South-East Fortress Tower"
--L.northWestKeep = "North-West Fortress Tower"
--L.southWestKeep = "South-West Fortress Tower"
--L.northWest = "North-West Wall"
--L.southWest = "South-West Wall"
--L.south = "South Wall"
--L.southEast = "South-East Wall"
--L.northEast = "North-East Wall"
--L.innerWest = "Inner-West Wall"
--L.innerSouth = "Inner-South Wall"
--L.innerEast = "Inner-East Wall"
--L.southGate = "South Gate"
--L.mainEntrance = "Main Entrance"
--L.westTower = "West Tower"
--L.southTower = "South Tower"
--L.eastTower = "East Tower"

-- Ashran
--L.hordeGuardian = "Horde Guardian"
--L.allianceGuardian = "Alliance Guardian"
L.kronus = "크로너스"
L.fangraal = "팡그랄"

-- Arena
--L.arenaStartTrigger = "The Arena battle has begun!" -- Needs to match the in game text exactly
--L.arenaStart60s = "One minute until the Arena battle begins!" -- Needs to match the in game text exactly
--L.arenaStart30s = "Thirty seconds until the Arena battle begins!" -- Needs to match the in game text exactly
--L.arenaStart15s = "Fifteen seconds until the Arena battle begins!" -- Needs to match the in game text exactly
