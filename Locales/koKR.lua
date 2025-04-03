
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

L.hordeGate = "호드 관문"
L.allianceGate = "얼라이언스 관문"
L.gatePosition = "%s (%s)"
L.west = "서쪽"
L.front = "정면"
L.east = "동쪽"
L.hordeBoss = "호드 우두머리"
L.allianceBoss = "얼라이언스 우두머리"
L.galvangar = "갈반가르"
L.balinda = "발린다"
L.ivus = "이부스"
L.lokholar = "로크홀라"
L.handIn = "|cFF33FF99Capping|r: 퀘스트 아이템 자동 제출 중."
L.anchorTooltip = "옵션에 접근하려면 |cffeda55f오른쪽 클릭|r하세요"
L.anchorTooltipNote = "옵션을 열고 바를 잠그면 이 이동 앵커가 숨겨집니다."

--- Alliance IoC Workshop yells:
-- Gnomish Mechanic yells: I'm halfway there! Keep the Horde away from here.  They don't teach fighting in engineering school!
-- Gnomish Mechanic yells: It's broken already?! No worries. It's nothing I can't fix.
--- Horde IoC Workshop yells:
-- Goblin Mechanic yells: I'm about halfway done! Keep the Alliance away - fighting's not in my contract!
-- Goblin Mechanic yells: It's broken again?! I'll fix it... just don't expect the warranty to cover this.
--L.halfway = "halfway" -- Needs to match the in game text exactly
--L.broken = "broken" -- Needs to match the in game text exactly

-- Wintergrasp
L.damaged = "|cFF33FF99Capping|r: %s 손상됨"
L.destroyed = "|cFF33FF99Capping|r: %s 파괴됨"
L.northEastKeep = "북동쪽 요새 탑"
L.southEastKeep = "남동쪽 요새 탑"
L.northWestKeep = "북서쪽 요새 탑"
L.southWestKeep = "남서쪽 요새 탑"
L.northWest = "북서쪽 벽"
L.southWest = "남서쪽 벽"
L.south = "남쪽 벽"
L.southEast = "남동쪽 벽"
L.northEast = "북동쪽 벽"
L.innerWest = "서쪽 내벽"
L.innerSouth = "남쪽 내벽"
L.innerEast = "동쪽 내벽"
L.southGate = "남쪽 관문"
L.mainEntrance = "정문"
L.westTower = "서쪽 탑"
L.southTower = "남쪽 탑"
L.eastTower = "동쪽 탑"

-- Ashran
L.hordeGuardian = "호드 수호자"
L.allianceGuardian = "얼라이언스 수호자"
L.kronus = "크로너스"
L.fangraal = "팡그랄"

-- Arena
L.arenaStartTrigger = "투기장 전투가 시작되었습니다!" -- Needs to match the in game text exactly
L.arenaStart60s = "투기장 전투 시작 1분 전입니다!" -- Needs to match the in game text exactly
L.arenaStart30s = "투기장 전투 시작 30초 전입니다!" -- Needs to match the in game text exactly
L.arenaStart15s = "투기장 전투 시작 15초 전입니다!" -- Needs to match the in game text exactly
