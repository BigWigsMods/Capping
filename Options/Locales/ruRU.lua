
if GetLocale() ~= "ruRU" then return end
local _, mod = ...
local L = mod.L

--- Options
--L.introduction = "The options below can always be accessed by typing the following command in chat: /capping"
L.general = "Общие" -- возможно нужно заменить на главные
L.test = "Тест"
L.lock = "Закреплен"
--L.lockDesc = "Enable the lock to hide the bar moving anchor, preventing the bars from being moved."
L.barIcon = "Иконка полоски"
L.showTime = "Показ времени"
L.fillBar = "Заполнение полоски"
L.font = "Шрифт"
L.fontSize = "Размер шрифта"
L.monochrome = "Монохромный текст"
L.outline = "Контур"
L.none = "Нет"
L.thin = "Тонкий"
L.thick = "Толстый"
L.texture = "Текстура"
L.barSpacing = "Расстояние полоски"
L.barWidth = "Ширина полоски"
L.barHeight = "Высота полоски"
L.alignText = "Выровнить текст"
L.alignTime = "Выровнить время"
L.alignIcon = "Выровнить иконки"
L.left = "Влево"
L.center = "По центру"
L.right = "Вправо"
L.growUpwards = "Направить вверх"
L.textColor = "Цвет текста"
L.allianceBars = "Полоски Альянса"
L.hordeBars = "Полоски Орды"
L.queueBars = "Полоски очерди"
L.otherBars = "Иные полоски"
L.barBackground = "Задний план полоски"

--- Features
L.features = "Возможности" -- возможно нужно заменить
L.queueBarsDesc = "Включить полоски, отображающие в какие очереди вы записаны и ориентировочное время до окончания ожидания" -- Enable the bars showing which queues you have joined and the estimated time you will be in the queue for."
L.barClickDesc = "Установить модификаторы клавиатуры, используя которые, при клике по полоске, будут направляться оповещения в чат. Если установить 'Нет' для всех 3х полосок, будут разрешены клики 'сквозь' строки" -- "Configure the keyboard modifier you wish to use for specific chat output when clicking on a bar. Setting all 3 to 'None' will disable clickable bars, allowing you to click through them."
L.shiftClick = "Shift + клик"
L.controlClick = "Control + клик"
L.altClick = "Alt + клик"
L.sayChat = "Общий (/s) чат"
L.raidChat = "Группой чат"
L.clickableBars = "Полоски, реагирующие на клик"
L.loudQueue = "Звук очереди" -- loud, посмотреть на проде // spellcheck on live
L.loudQueueDesc = "Когда наступит очередь, звуковое оповещение будет принудительно направлено через основной звуковой канал" -- посмотреть на проде // spellcheck on live // "When the queue is ready the sound notification will be forced to play over the 'Master' sound channel."
--L.autoTurnIn = "Auto Turn-In"
--L.autoTurnInDesc = "Automatically turn in quest items in zones like Alterac Valley and Ashran."
