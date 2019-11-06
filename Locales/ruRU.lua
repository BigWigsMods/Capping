
if GetLocale() ~= "ruRU" then return end
local _, mod = ...
local L = mod.L

L.battleBegins = "Начало сражения"
L.finalScore = "Финал: %d - %d"
L.flagRespawns = "Появление Флагов"

L.takenTheFlagTrigger = "^(.+) захватывает флаг!"
L.hasTakenTheTrigger = "захватил"
L.upgradeToTrigger = "Улучшено до" -- тут еще вопрос (!) проверить на проде // spellcheck on live
L.droppedTrigger = "уронил"
L.capturedTheTrigger = "захватил"

L.hordeGate = "Врата крепости Орды"
L.allianceGate = "Врата крепости Альянса"
L.gatePosition = "%s (%s)" -- тут точно нужен перевод?// check on live
L.west = "Запад"
L.front = "Передовая" -- тут еще вопрос (!) проверить на проде // spellcheck on live
L.east = "Восток"
L.hordeBoss = "Босс Орды"
L.allianceBoss = "Босс Альянса"
L.galvangar = "Гальвангар" -- Капитан Гальвангар <Капитан клана Северного Волка>
L.balinda = "Балинда" -- Капитан Балинда Каменный Очаг <Капитан клана Грозовой Вершины>
L.ivus = "Ивус" -- Ивус Лесной Властелин
L.lokholar = "Локолар" -- Локолар Владыка Льда
L.handIn = "|cFF33FF99Capping|r: Автоматическая сдача квестовых предметов." -- проверить на проде // spellcheck on live

--- Alliance IoC Workshop yells:
--Гном-механик кричит: Я уже почти закончил! Только не подпускай ко мне Орду – в инженерной школе не учат махать мечом!
--Гном-механик кричит: Уже сломалась? Не о чем беспокоиться. Я могу починить что угодно.
--- Horde IoC Workshop yells:
--Гоблинский механик кричит: я на полпути! Держите Альянс подальше - боевые действия не входят в мой контракт!
--Механик Гоблин кричит: «Он снова сломан ?!» Я исправлю это ... просто не ожидайте, что гарантия покроет это.
L.halfway = " по[^ ]+ти[! ]"
L.broken = "слома"

-- Wintergrasp
L.damaged = "|cFF33FF99Capping|r: %s подвергается нападению" -- проверить на проде, подумать над универсальным вариантом // spellcheck on live
L.destroyed = "|cFF33FF99Capping|r: %s разрушена" -- проверить на проде, подумать над универсальным вариантом // spellcheck on live
L.northEastKeep = "Северо-восточная башня крепости"
L.southEastKeep = "Юго-восточная башня крепости"
L.northWestKeep = "Северо-западная башня крепости"
L.southWestKeep = "Юго-западная башня крепости"
L.northWest = "Северо-западная стена"
L.southWest = "Юго-западная стена"
L.south = "Юная стена"
L.southEast = "Юго-восточная стена"
L.northEast = "Северо-восточная стена"
L.innerWest = "Внутренняя западная стена"
L.innerSouth = "Внутренняя южная стена"
L.innerEast = "Внутренняя востовная стена"
L.southGate = "Южные ворота"
L.mainEntrance = "Главный вход"
L.westTower = "Западная башня"
L.southTower = "Южная башня"
L.eastTower = "Восточная башня"
