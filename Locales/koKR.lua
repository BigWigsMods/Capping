
if GetLocale() ~= "koKR" then return end
local _, mod = ...
local L = mod.L

L.battleBegins = "전투 개시"
L.finalScore = "종료: %d - %d"
L.flagRespawns = "깃발 생성"

L.takenTheFlagTrigger = "^(.+)|1이;가; 깃발을 차지했습니다!"
L.hasTakenTheTrigger = "점령했습니다"
L.upgradeToTrigger = "추가 전리품"
L.droppedTrigger = "([^ ]*)|1이;가; ([^!]*) 깃발을 떨어뜨렸습니다!"
L.capturedTheTrigger = "([^ ]*)|1이;가; ([^!]*) 깃발 쟁탈에 성공했습니다!"
