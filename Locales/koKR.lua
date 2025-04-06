
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
L.handIn = "|cFF33FF99Capping|r: 퀘스트 아이템 자동 반납 중."
L.anchorTooltip = "옵션에 접근하려면 |cffeda55f오른쪽 클릭|r하세요"
L.anchorTooltipNote = "옵션을 열고 바를 잠그면 이 이동 앵커가 숨겨집니다."

--- Alliance IoC Workshop yells:
-- 노움 정비사의 외침: 반쯤 됐다고! 호드가 절 못 때리게 해주세요. 기계 공학 학교에서는 싸움은 안 가르친다구요!
-- 노움 정비사의 외침: 벌써 부서졌어요?! 괜찮아요. 제가 못 고칠 정도는 아니에요.
--- Horde IoC Workshop yells:
-- 고블린 정비사의 외침: 반쯤 됐다고! 얼라이언스 놈들이 가까이 못 오게 해줘. 계약서에 전투 얘긴 없었다고!
-- 고블린 정비사의 외침: 또 부서졌어요?! 제가 고쳐드릴게요... 다만 보증이 적용될 거라고 기대하지 마세요.
L.halfway = "반쯤" -- Needs to match the in game text exactly
L.broken = "부서" -- Needs to match the in game text exactly

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
