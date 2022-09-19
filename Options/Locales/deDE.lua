if GetLocale() ~= "deDE" then return end
local _, mod = ...
local L = mod.L

--- Options
--L.introduction = "The options below can always be accessed by typing the following command in chat: /capping"
L.general = "Generell"
L.test = "Test"
L.lock = "Fenster fixieren"
--L.lockDesc = "Enable the lock to hide the bar moving anchor, preventing the bars from being moved."
L.barIcon = "Leistensymbol"
L.showTime = "Zeit anzeigen"
L.fillBar = "Leiste füllen"
L.font = "Schriftart"
L.fontSize = "Schriftgröße"
L.monochrome = "Monochromer Text"
L.outline = "Umriss"
L.none = "Keine"
L.thin = "Dünn"
L.thick = "Dick"
L.texture = "Textur"
L.barSpacing = "Leistenabstand"
L.barWidth = "Leistenbreite"
L.barHeight = "Leistenhöhe"
L.alignText = "Text ausrichten"
L.alignTime = "Zeit ausrichten"
L.alignIcon = "Leiste ausrichten Symbol"
L.left = "Links"
L.center = "Zentriert"
L.right = "Rechts"
L.growUpwards = "Nach oben erweitern"
L.textColor = "Schriftfarbe"
L.allianceBars = "Allianz Leisten"
L.hordeBars = "Horde Leisten"
L.queueBars = "Warteschlangen Leisten"
L.otherBars = "Andere Leisten"
L.barBackground = "Leistenhintergrund"

--- Features
L.features = "Eigenschaften"
L.queueBarsDesc = "Aktivieren Sie die Leisten, die anzeigen, welchen Warteschlangen Sie beigetreten sind und wie lange Sie sich voraussichtlich in Ihnen befinden werden."
L.barClickDesc = "Konfigurieren Sie den Tastaturmodifikator, den Sie für bestimmte Chatausgaben beim Klicken auf eine Leiste verwenden möchten. Wenn Sie alle 3 auf 'Keine' setzen, werden klickbare Leisten deaktiviert, so dass Sie sich durch sie hindurchklicken können."
L.shiftClick = "Shift-Klick"
L.controlClick = "Control-Klick"
L.altClick = "Alt-Klick"
L.sayChat = "Sagen Chat"
L.raidChat = "Gruppenchat"
L.clickableBars = "Klickbare Leisten"
L.loudQueue = "Laute Warteschlange"
L.loudQueueDesc = "Wenn die Warteschlange bereit ist, wird eine akustische Benachrichtigung, über den 'Haupt'-Tonkanal abgespielt."
