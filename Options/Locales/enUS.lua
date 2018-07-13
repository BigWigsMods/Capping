
local _, mod = ...
if not mod.L then -- Support repo users by checking if it already exists
	mod.L = {}
end
local L = mod.L

-- Options
L.general = "General"
L.test = "Test"
L.lock = "Lock"
L.barIcon = "Bar Icon"
L.showTime = "Show Time"
L.fillBar = "Fill Bar"
L.font = "Font"
L.fontSize = "Font Size"
L.monochrome = "Monochrome Text"
L.outline = "Outline"
L.none = "None"
L.thin = "Thin"
L.thick = "Thick"
L.texture = "Texture"
L.barSpacing = "Bar Spacing"
L.barWidth = "Bar Width"
L.barHeight = "Bar Height"
L.alignText = "Align Text"
L.alignTime = "Align Time"
L.alignIcon = "Align Bar Icon"
L.left = "Left"
L.center = "Center"
L.right = "Right"
L.growUpwards = "Grow Upwards"
L.textColor = "Text Color"
L.allianceBars = "Alliance Bars"
L.hordeBars = "Horde Bars"
L.queueBars = "Queue Bars"
L.otherBars = "Other Bars"
L.barBackground = "Bar Background"

