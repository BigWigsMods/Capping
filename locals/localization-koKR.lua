if GetLocale() ~= "koKR" then return end

local _, addon = ...
--- ko translations initially provided by McKabi
addon.L = {
	-- options menu
	["Auto Quest Turnins"] = "자동 퀘스트 반납",
	["Bar"] = "바",
	["Width"] = "너비",
	["Height"] = "높이",
	["Texture"] = "텍스쳐",
	["Map Scale"] = "지도 크기 비율",
	["Hide Border"] = "테두리 숨기기",
	["Port Timer"] = "입장 시간",
	["Wait Timer"] = "대기 시간",
	["Show/Hide Anchor"] = "고정기 표시/숨기기",
	["Narrow Map Mode"] = "좁은 지도 모드",
	["Narrow Anchor Left"] = "좁은 지도 좌측 고정",
	["Test"] = "시험",
	["Flip Growth"] = "바 위로 쌓기",
	["Single Group"] = "단일 그룹",
	["Move Scoreboard"] = "점수판 이동",
	["Spacing"] = "간격",
	["Request Sync"] = "동기화 요청",
	["Fill Grow"] = "왼쪽부터 채우기",
	["Fill Right"] = "오른쪽부터 채우기",
	["Font"] = "글꼴",
	["Time Position"] = "시간 위치",
	["Border Width"] = "테두리 너비",
	["Send to BG"] = "전장으로 전송",
	["Send to SAY"] = "일반 대화로 전송",
	["Cancel Timer"] = "취소 타이머",
	["Move Capture Bar"] = "점령시간 바 이동",
	["Move Vehicle Seat"] = "차량 좌석 이동",

	-- etc timers
	["Battle Begins"] = "전투 개시", -- bar text for bg gates opening
	["1 minute"] = "1분",
	["60 seconds"] = "60초",
	["30 seconds"] = "30초",
	["15 seconds"] = "15초",
	["One minute until"] = "1분 전",
	["Forty five seconds"] = "45초 전",
	["Thirty seconds until"] = "30초 전",
	["Fifteen seconds until"] = "15초 전",
	["%s: %s - %d:%02d remaining"] = "%s: %s - %d:%02d 남음", -- chat message after shift left-clicking a bar

	-- AB
	["Bases: (%d+)  Resources: (%d+)/(%d+)"] = "거점: (%d+)  자원: (%d+)/(%d+)", -- arathi basin scoreboard
	["has assaulted"] = "공격했습니다",
	["claims the"] = "넘어갈 것입니다",
	["has taken the"] = "점령했습니다",
	["has defended the"] = "방어했습니다",
	["Final: %d - %d"] = "종료: %d - %d", -- final score text
	["wins %d-%d"] = "승리 %d-%d", -- final score chat message

	-- WSG
	["was picked up by (.+)!"] = "([^ ]*)|1이;가; ([^!]*) 깃발을 손에 넣었습니다!",
	--["was picked up by (.+)!2"] = "([^ ]*)|1이;가; ([^!]*) 깃발을 손에 넣었습니다!2",
	["dropped"] = "([^ ]*)|1이;가; ([^!]*) 깃발을 떨어뜨렸습니다!",
	["captured the"] = "([^ ]*)|1이;가; ([^!]*) 깃발 쟁탈에 성공했습니다!",
	["Flag respawns"] = "깃발 생성",
	["%s's flag carrier: %s (%s)"] = "%s의 깃발 운반자: %s (%s)", -- chat message

	-- AV
	 -- patterns
	["Upgrade to"] = "추가 전리품", -- the option to upgrade units in AV
	["Wicked, wicked, mortals!"] = "사악하디 사악한 필멸의 생명체들이여, 숲이 울부짖는구나!", -- what Ivus says after being summoned
	["Ivus begins moving"] = "이부스 이동 시작",
	["WHO DARES SUMMON LOKHOLAR"] = "누가 감히 이 로크홀라를 소환한 것이냐?", -- what Lok says after being summoned
	["The Ice Lord has arrived!"] = "얼음 군주께서 당도하셨어요!",
	["Lokholar begins moving"] = "로크홀라 이동 시작",


	-- EotS
	["^(.+) has taken the flag!"] = "^(.+)|1이;가; 깃발을 차지했습니다!",
	["Bases: (%d+)  Victory Points: (%d+)/(%d)"] = "거점: (%d+)  승점: (%d+)/(%d)",

	-- IoC
	 -- node keywords (text is also displayed on timer bar)
	["Alliance Keep"] = "얼라이언스 요새",
	["Horde Keep"] = "호드 요새",
	 -- Siege Engine keyphrases
	["Goblin"] = "작업장",  -- Horde mechanic name keyword
	["seaforium bombs"] = "시포리움 폭탄",  -- start (after capturing the workshop)
	["It's broken"] = true,  -- start again (after engine is destroyed)
	["halfway"] = true,  -- middle
}

