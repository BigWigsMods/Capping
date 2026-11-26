
--------------------------------------------------------------------------------
-- Locals
--

local addonName, mod = ...
local frame = CreateFrame("Frame", "CappingFrame", UIParent)
local L = mod.L

local format, type = string.format, type
local db, core
local zoneIds = {}

local activeBars = { }
frame.bars = activeBars

local candy = LibStub("LibCandyBar-3.0")
local LibSharedMedia = LibStub("LibSharedMedia-3.0")
local FONT = LibSharedMedia.MediaType and LibSharedMedia.MediaType.FONT or "font"
local STATUSBAR = LibSharedMedia.MediaType and LibSharedMedia.MediaType.STATUSBAR or "statusbar"
local BORDER = LibSharedMedia.MediaType and LibSharedMedia.MediaType.BORDER or "border"
local BACKGROUND = LibSharedMedia.MediaType and LibSharedMedia.MediaType.BACKGROUND or "background"
local minBarWidth, minBarHeight, maxBarWidth, maxBarHeight = 120, 10, 550, 100
frame.minBarWidth = minBarWidth
frame.maxBarWidth = maxBarWidth
frame.minBarHeight = minBarHeight
frame.maxBarHeight = maxBarHeight
local backdropTbl = {}

local function GetIconTexCoord(width, height, baseTexCoord)
	local zoom = baseTexCoord and 1 or (1 - db.profile.iconZoom) -- Don't zoom POI/atlas icons since they don't have spell icon borders
	local zoomedOffset = 1 - ((1 - zoom) / 2)
	local offsetX, offsetY = zoomedOffset, zoomedOffset

	if db.profile.iconKeepAspectRatio then
		if width > height then
			offsetY = 1 - (1 - (height / width) * zoom) / 2
		elseif height > width then
			offsetX = 1 - (1 - (width / height) * zoom) / 2
		end
	end

	local u1, u2, v1, v2 = 1 - offsetX, offsetX, 1 - offsetY, offsetY
	if baseTexCoord then
		local left, right, top, bottom = baseTexCoord[1], baseTexCoord[2], baseTexCoord[3], baseTexCoord[4]
		local du = right - left
		local dv = bottom - top
		return left + du * u1, left + du * u2, top + dv * v1, top + dv * v2
	end
	return u1, u2, v1, v2
end

--------------------------------------------------------------------------------
-- Profile
--

local defaults = {
	profile = {
		lock = false,
		position = {"CENTER", "CENTER", 0, 0, "UIParent"},
		copyCustomAnchorWidth = false,
		fontSize = 10,
		barTexture = "Blizzard Raid Bar",
		outline = "NONE",
		monochrome = false,
		font = LibSharedMedia:GetDefault("font"),
		width = 200,
		height = 20,
		barHeightOffset = 0,
		icon = true,
		detachedIcon = false,
		iconOffset = 2,
		iconWidthOffset = 0,
		iconZoom = 0.14,
		iconKeepAspectRatio = true,
		text = true,
		textOffsetX = 0,
		textOffsetY = 0,
		timeText = true,
		timeOffsetX = 0,
		timeOffsetY = 0,
		timeDecimals = 10,
		fill = false,
		growUp = false,
		spacing = 0,
		alignText = "LEFT",
		alignTime = "RIGHT",
		alignIcon = "LEFT",
		borderName = "None",
		borderColor = {0, 0, 0, 1},
		borderOffset = 0,
		borderSize = 1,
		backgroundName = "Solid",
		backgroundColor = {0, 0, 0, 0.75},
		colorText = {1, 1, 1, 1},
		colorTextShadow = {0, 0, 0, 1},
		colorAlliance = {0, 0, 1, 1},
		colorHorde = {1, 0, 0, 1},
		colorQueue = {0.6, 0.6, 0.6, 1},
		colorOther = {1, 1, 0, 1},
		queueBars = true,
		useMasterForQueue = true,
		barOnShift = "SAY",
		barOnControl = "INSTANCE_CHAT",
		barOnAlt = "NONE",
		autoTurnIn = true,
	},
}
frame.defaultProfile = defaults.profile

local barFont, barFontFlags, barTexture = nil, nil, nil
local RefixPosition, UpdateMover, UpdateProfile, NotifyOptions, ApplyBarLayout
do
	local bitband, pcall = bit.band, pcall
	local defaultProfile = defaults.profile
	local activeAnchorFrame = nil
	local hookedAnchorFrames = {}

	local validFramePoints = {
		["TOPLEFT"] = true, ["TOPRIGHT"] = true, ["BOTTOMLEFT"] = true, ["BOTTOMRIGHT"] = true,
		["TOP"] = true, ["BOTTOM"] = true, ["LEFT"] = true, ["RIGHT"] = true, ["CENTER"] = true,
	}
	local function IsValidFramePoint(point)
		return validFramePoints[point]
	end
	frame.IsValidFramePoint = IsValidFramePoint

	local function IsValidFrame(frameName)
		if type(frameName) ~= "string" then return false end
		local targetFrame = _G[frameName]
		if targetFrame == frame or frameName == "CappingTooltip" then return false end
		if type(targetFrame) ~= "table" or type(targetFrame.IsObjectType) ~= "function" or type(targetFrame.IsForbidden) ~= "function" or type(targetFrame.GetWidth) ~= "function" then
			return false
		else
			local success, isForbidden = pcall(targetFrame.IsForbidden, targetFrame)
			if not success or isForbidden then return false end

			local isFrameSuccess, isFrame = pcall(targetFrame.IsObjectType, targetFrame, "Frame")
			if not isFrameSuccess or not isFrame then return false end

			local hasWidthResult, width = pcall(targetFrame.GetWidth, targetFrame)
			if not hasWidthResult or type(width) ~= "number" then return false end
		end

		-- Frames with forbidden aspects, Enum.ForbiddenAspect.UntrustedLayoutScriptExecution = 8
		if type(targetFrame.GetInheritableForbiddenAspects) == "function" then
			local success, value = pcall(targetFrame.GetInheritableForbiddenAspects, targetFrame, 1)
			if not success or bitband(value, 8) == 8 then return false end
		end

		return true
	end
	frame.IsValidFrame = IsValidFrame

	local IsValidMediaPath
	do
		local IsKnownFile = C_UIFileAsset and C_UIFileAsset.IsKnownFile
		function IsValidMediaPath(mediaPath)
			if type(mediaPath) ~= "string" then
				return false
			elseif IsKnownFile then
				local result = IsKnownFile(mediaPath)
				return result
			else
				return true
			end
		end
	end

	local function CopyTable(settingsTable)
		local copy = {}
		for key, value in next, settingsTable do
			if type(value) == "table" then
				copy[key] = CopyTable(value)
			else
				copy[key] = value
			end
		end
		return copy
	end

	local function ValidateColor(current, default, alphaLimit)
		for i = 1, 3 do
			local n = current[i]
			if type(n) ~= "number" or n < 0 or n > 1 then
				current[1] = default[1] -- If 1 entry is bad, reset the whole table
				current[2] = default[2]
				current[3] = default[3]
				current[4] = default[4]
				return
			end
		end
		if alphaLimit then
			if type(current[4]) ~= "number" or current[4] < alphaLimit or current[4] > 1 then
				current[4] = default[4]
			end
		elseif current[4] then
			current[4] = nil
		end
	end

	function NotifyOptions()
		local acr = LibStub("AceConfigRegistry-3.0", true)
		if acr then
			acr:NotifyChange("Capping")
		end
	end

	local function HookScript(self, width)
		if self == activeAnchorFrame then
			width = math.floor(width+0.5)
			if width < minBarWidth then
				width = minBarWidth
			elseif width > maxBarWidth then
				width = maxBarWidth
			end
			if width ~= db.profile.width then
				db.profile.width = width
				frame:SetWidth(width)
				for bar in next, activeBars do
					bar:SetWidth(width)
				end
				frame.RearrangeBars()
				NotifyOptions()
			end
		end
	end

	function RefixPosition()
		local pos = db.profile.position
		frame:ClearAllPoints()
		if pos[5] == defaultProfile.position[5] or IsValidFrame(pos[5]) then
			frame:SetPoint(pos[1], pos[5], pos[2], pos[3], pos[4])
		else
			frame:SetPoint(defaultProfile.position[1], defaultProfile.position[5], defaultProfile.position[2], defaultProfile.position[3], defaultProfile.position[4])
		end
	end
	frame.RefixPosition = RefixPosition

	function UpdateMover()
		local mover = frame.mover
		if db.profile.lock then
			frame:StopMovingOrSizing()
			frame:SetMovable(false)
			frame:SetClampRectInsets(0, 0, 0, 0)
			mover:Hide()
		else
			mover:ClearAllPoints()
			if db.profile.growUp then
				mover:SetPoint("TOPLEFT", frame, "BOTTOMLEFT")
				mover:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT")
			else
				mover:SetPoint("BOTTOMLEFT", frame, "TOPLEFT")
				mover:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT")
			end
			if db.profile.position[5] == defaultProfile.position[5] then
				frame:SetMovable(true)
				if db.profile.growUp then
					frame:SetClampRectInsets(0, 0, 0, -15)
				else
					frame:SetClampRectInsets(0, 0, 15, 0)
				end
			else
				frame:StopMovingOrSizing()
				frame:SetMovable(false)
				frame:SetClampRectInsets(0, 0, 0, 0)
			end
			mover:Show()
		end
	end

	local function ValidateMainSettings()
		for k, v in next, db.profile do
			local defaultType = type(defaultProfile[k])
			if defaultType == "nil" then
				db.profile[k] = nil
			elseif type(v) ~= defaultType then
				if defaultType == "table" then
					db.profile[k] = CopyTable(defaultProfile[k])
				else
					db.profile[k] = defaultProfile[k]
				end
			end
		end

		ValidateColor(db.profile.borderColor, defaultProfile.borderColor, 0)
		ValidateColor(db.profile.backgroundColor, defaultProfile.backgroundColor, 0)
		ValidateColor(db.profile.colorText, defaultProfile.colorText, 0)
		ValidateColor(db.profile.colorTextShadow, defaultProfile.colorTextShadow, 0)
		ValidateColor(db.profile.colorAlliance, defaultProfile.colorAlliance, 0)
		ValidateColor(db.profile.colorHorde, defaultProfile.colorHorde, 0)
		ValidateColor(db.profile.colorQueue, defaultProfile.colorQueue, 0)
		ValidateColor(db.profile.colorOther, defaultProfile.colorOther, 0)

		if db.profile.borderOffset < 0 or db.profile.borderOffset > 32 or math.floor(db.profile.borderOffset+0.5) ~= db.profile.borderOffset then
			db.profile.borderOffset = defaultProfile.borderOffset
		end
		if db.profile.borderSize < 1 or db.profile.borderSize > 32 or math.floor(db.profile.borderSize+0.5) ~= db.profile.borderSize then
			db.profile.borderSize = defaultProfile.borderSize
		end
		if db.profile.fontSize < 10 or db.profile.fontSize > 200 or math.floor(db.profile.fontSize+0.5) ~= db.profile.fontSize then
			db.profile.fontSize = defaultProfile.fontSize
		end
		if db.profile.outline ~= "NONE" and db.profile.outline ~= "OUTLINE" and db.profile.outline ~= "THICKOUTLINE" then
			db.profile.outline = defaultProfile.outline
		end
		if db.profile.alignText ~= "LEFT" and db.profile.alignText ~= "CENTER" and db.profile.alignText ~= "RIGHT" then
			db.profile.alignText = defaultProfile.alignText
		end
		if db.profile.alignTime ~= "LEFT" and db.profile.alignTime ~= "CENTER" and db.profile.alignTime ~= "RIGHT" then
			db.profile.alignTime = defaultProfile.alignTime
		end
		if db.profile.alignIcon ~= "LEFT" and db.profile.alignIcon ~= "RIGHT" then
			db.profile.alignIcon = defaultProfile.alignIcon
		end
		if db.profile.barOnShift ~= "NONE" and db.profile.barOnShift ~= "SAY" and db.profile.barOnShift ~= "INSTANCE_CHAT" then
			db.profile.barOnShift = defaultProfile.barOnShift
		end
		if db.profile.barOnControl ~= "NONE" and db.profile.barOnControl ~= "SAY" and db.profile.barOnControl ~= "INSTANCE_CHAT" then
			db.profile.barOnControl = defaultProfile.barOnControl
		end
		if db.profile.barOnAlt ~= "NONE" and db.profile.barOnAlt ~= "SAY" and db.profile.barOnAlt ~= "INSTANCE_CHAT" then
			db.profile.barOnAlt = defaultProfile.barOnAlt
		end
		if db.profile.iconOffset < 1 or db.profile.iconOffset > 100 or math.floor(db.profile.iconOffset+0.5) ~= db.profile.iconOffset then
			db.profile.iconOffset = defaultProfile.iconOffset
		end
		if db.profile.iconWidthOffset < -50 or db.profile.iconWidthOffset > 50 or math.floor(db.profile.iconWidthOffset+0.5) ~= db.profile.iconWidthOffset then
			db.profile.iconWidthOffset = defaultProfile.iconWidthOffset
		end
		if db.profile.iconZoom < 0 or db.profile.iconZoom > 0.5 then
			db.profile.iconZoom = defaultProfile.iconZoom
		end
		if db.profile.textOffsetX < -100 or db.profile.textOffsetX > 100 or math.floor(db.profile.textOffsetX+0.5) ~= db.profile.textOffsetX then
			db.profile.textOffsetX = defaultProfile.textOffsetX
		end
		if db.profile.textOffsetY < -100 or db.profile.textOffsetY > 100 or math.floor(db.profile.textOffsetY+0.5) ~= db.profile.textOffsetY then
			db.profile.textOffsetY = defaultProfile.textOffsetY
		end
		if db.profile.timeOffsetX < -100 or db.profile.timeOffsetX > 100 or math.floor(db.profile.timeOffsetX+0.5) ~= db.profile.timeOffsetX then
			db.profile.timeOffsetX = defaultProfile.timeOffsetX
		end
		if db.profile.timeOffsetY < -100 or db.profile.timeOffsetY > 100 or math.floor(db.profile.timeOffsetY+0.5) ~= db.profile.timeOffsetY then
			db.profile.timeOffsetY = defaultProfile.timeOffsetY
		end
		if db.profile.timeDecimals < 0 or db.profile.timeDecimals > 60 or math.floor(db.profile.timeDecimals+0.5) ~= db.profile.timeDecimals then
			db.profile.timeDecimals = defaultProfile.timeDecimals
		end
		if db.profile.spacing < 0 or db.profile.spacing > 20 or math.floor(db.profile.spacing+0.5) ~= db.profile.spacing then
			db.profile.spacing = defaultProfile.spacing
		end
		if db.profile.width < minBarWidth or db.profile.width > maxBarWidth or math.floor(db.profile.width+0.5) ~= db.profile.width then
			db.profile.width = defaultProfile.width
		end
		if db.profile.height < minBarHeight or db.profile.height > maxBarHeight or math.floor(db.profile.height+0.5) ~= db.profile.height then
			db.profile.height = defaultProfile.height
		end
		if db.profile.barHeightOffset < -100 or db.profile.barHeightOffset > 0 or math.floor(db.profile.barHeightOffset+0.5) ~= db.profile.barHeightOffset then
			db.profile.barHeightOffset = defaultProfile.barHeightOffset
		end

		local pos = db.profile.position
		if type(pos[1]) ~= "string" or type(pos[2]) ~= "string"
		or type(pos[3]) ~= "number" or type(pos[4]) ~= "number"
		or not IsValidFramePoint(pos[1]) or not IsValidFramePoint(pos[2])
		or pos[3] < -10000 or pos[3] > 10000 or pos[4] < -10000 or pos[4] > 10000 then
			db.profile.position = CopyTable(defaultProfile.position)
			db.profile.copyCustomAnchorWidth = defaultProfile.copyCustomAnchorWidth
		else
			local x = math.floor(pos[3]+0.5)
			if x ~= pos[3] then
				pos[3] = x
			end
			local y = math.floor(pos[4]+0.5)
			if y ~= pos[4] then
				pos[4] = y
			end
			if type(pos[5]) ~= "string" or pos[5] == "" then
				pos[5] = defaultProfile.position[5]
			end
		end
	end

	local function ValidateMediaSettings()
		local fontPath = LibSharedMedia:IsValid(FONT, db.profile.font) and LibSharedMedia:Fetch(FONT, db.profile.font)
		if not fontPath or not IsValidMediaPath(fontPath) then
			db.profile.font = defaultProfile.font
		end
		local texturePath = LibSharedMedia:IsValid(STATUSBAR, db.profile.barTexture) and LibSharedMedia:Fetch(STATUSBAR, db.profile.barTexture)
		if not texturePath or not IsValidMediaPath(texturePath) then
			db.profile.barTexture = defaultProfile.barTexture
		end
		if db.profile.borderName ~= "None" then
			local borderPath = LibSharedMedia:IsValid(BORDER, db.profile.borderName) and LibSharedMedia:Fetch(BORDER, db.profile.borderName)
			if not borderPath or not IsValidMediaPath(borderPath) then
				db.profile.borderName = defaultProfile.borderName -- If the border is suddenly invalid then reset the size and offset also
				db.profile.borderSize = defaultProfile.borderSize
				db.profile.borderOffset = defaultProfile.borderOffset
			end
		end
		if db.profile.backgroundName ~= "None" then
			local backgroundPath = LibSharedMedia:IsValid(BACKGROUND, db.profile.backgroundName) and LibSharedMedia:Fetch(BACKGROUND, db.profile.backgroundName)
			if not backgroundPath or not IsValidMediaPath(backgroundPath) then
				db.profile.backgroundName = defaultProfile.backgroundName
			end
		end
	end

	local function ValidateAnchorFrame()
		activeAnchorFrame = nil
		if db.profile.position[5] ~= defaultProfile.position[5] then
			if not IsValidFrame(db.profile.position[5]) then
				db.profile.position = CopyTable(defaultProfile.position)
				db.profile.copyCustomAnchorWidth = defaultProfile.copyCustomAnchorWidth
				db.profile.width = defaultProfile.width
			elseif db.profile.copyCustomAnchorWidth then
				local targetFrame = _G[db.profile.position[5]]
				if not hookedAnchorFrames[targetFrame] then
					local success = pcall(frame.HookScript, targetFrame, "OnSizeChanged", HookScript)
					if not success then
						db.profile.copyCustomAnchorWidth = defaultProfile.copyCustomAnchorWidth
						db.profile.width = defaultProfile.width
						return
					end
					hookedAnchorFrames[targetFrame] = true
				end
				activeAnchorFrame = targetFrame

				local width = math.floor(targetFrame:GetWidth()+0.5)
				if width < minBarWidth then
					width = minBarWidth
				elseif width > maxBarWidth then
					width = maxBarWidth
				end
				db.profile.width = width
			end
		elseif db.profile.copyCustomAnchorWidth then
			db.profile.copyCustomAnchorWidth = defaultProfile.copyCustomAnchorWidth
			db.profile.width = defaultProfile.width
		end
	end

	local function RebuildStyleCache()
		if db.profile.monochrome and db.profile.outline ~= "NONE" then
			barFontFlags = "MONOCHROME," .. db.profile.outline
		elseif db.profile.monochrome then
			barFontFlags = "MONOCHROME"
		elseif db.profile.outline ~= "NONE" then
			barFontFlags = db.profile.outline
		else
			barFontFlags = nil
		end
		barFont = LibSharedMedia:Fetch(FONT, db.profile.font)
		barTexture = LibSharedMedia:Fetch(STATUSBAR, db.profile.barTexture)
		local inset = db.profile.borderName ~= "None" and math.floor(db.profile.borderSize / 4) or 0
		backdropTbl = {
			bgFile = db.profile.backgroundName ~= "None" and LibSharedMedia:Fetch(BACKGROUND, db.profile.backgroundName) or nil,
			edgeFile = db.profile.borderName ~= "None" and LibSharedMedia:Fetch(BORDER, db.profile.borderName) or nil,
			edgeSize = db.profile.borderName ~= "None" and db.profile.borderSize or nil,
			insets = { left = inset, right = inset, top = inset, bottom = inset },
		}
	end

	function ApplyBarLayout(bar)
		local height = db.profile.height
		local iconWidth = height
		if db.profile.icon and db.profile.iconWidthOffset ~= 0 then
			iconWidth = math.max(height + db.profile.iconWidthOffset, 1)
			bar.candyBarIconFrame:SetWidth(iconWidth)
		end

		local barHeightOffset = 0
		if db.profile.icon and db.profile.detachedIcon then
			barHeightOffset = db.profile.barHeightOffset
			if -barHeightOffset >= height then
				barHeightOffset = 0
			end
			bar.candyBarIconFrame:ClearAllPoints()
			bar.candyBarBar:ClearAllPoints()
			if db.profile.alignIcon == "LEFT" then
				bar.candyBarIconFrame:SetPoint("TOPLEFT", bar, "TOPLEFT", -db.profile.iconOffset, 0)
				bar.candyBarIconFrame:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", -db.profile.iconOffset, 0)
				bar.candyBarBar:SetPoint("TOPLEFT", bar, "TOPLEFT", iconWidth, barHeightOffset)
				bar.candyBarBar:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", iconWidth, 0)
				bar.candyBarBar:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 0, barHeightOffset)
				bar.candyBarBar:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
			else
				bar.candyBarIconFrame:SetPoint("TOPRIGHT", bar, "TOPRIGHT", db.profile.iconOffset, 0)
				bar.candyBarIconFrame:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", db.profile.iconOffset, 0)
				bar.candyBarBar:SetPoint("TOPRIGHT", bar, "TOPRIGHT", -iconWidth, barHeightOffset)
				bar.candyBarBar:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -iconWidth, 0)
				bar.candyBarBar:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, barHeightOffset)
				bar.candyBarBar:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 0, 0)
			end
		elseif db.profile.icon and db.profile.iconWidthOffset ~= 0 then
			bar.candyBarBar:ClearAllPoints()
			if db.profile.alignIcon == "LEFT" then
				bar.candyBarBar:SetPoint("TOPLEFT", bar, "TOPLEFT", iconWidth, 0)
				bar.candyBarBar:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", iconWidth, 0)
				bar.candyBarBar:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 0, 0)
				bar.candyBarBar:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
			else
				bar.candyBarBar:SetPoint("TOPRIGHT", bar, "TOPRIGHT", -iconWidth, 0)
				bar.candyBarBar:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -iconWidth, 0)
				bar.candyBarBar:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
				bar.candyBarBar:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 0, 0)
			end
		end

		bar.candyBarLabel:ClearAllPoints()
		bar.candyBarLabel:SetPoint("TOPLEFT", bar.candyBarBar, "TOPLEFT", 2 + db.profile.textOffsetX, -barHeightOffset / 2 + db.profile.textOffsetY)
		bar.candyBarLabel:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "BOTTOMRIGHT", -2 + db.profile.textOffsetX, barHeightOffset / 2 + db.profile.textOffsetY)
		bar.candyBarDuration:ClearAllPoints()
		bar.candyBarDuration:SetPoint("TOPLEFT", bar.candyBarBar, "TOPLEFT", 2 + db.profile.timeOffsetX, -barHeightOffset / 2 + db.profile.timeOffsetY)
		bar.candyBarDuration:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "BOTTOMRIGHT", -2 + db.profile.timeOffsetX, barHeightOffset / 2 + db.profile.timeOffsetY)

		if db.profile.borderName ~= "None" or db.profile.backgroundName ~= "None" then
			local border = bar.candyBarBackdrop
			border:ClearAllPoints()
			local borderOffset = db.profile.borderName ~= "None" and db.profile.borderOffset or 0
			if db.profile.icon and db.profile.detachedIcon then
				border:SetPoint("TOPLEFT", bar.candyBarBar, "TOPLEFT", -borderOffset, borderOffset)
				border:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "BOTTOMRIGHT", borderOffset, -borderOffset)
				local iconBorder = bar.candyBarIconFrameBackdrop
				iconBorder:ClearAllPoints()
				if db.profile.alignIcon == "LEFT" then
					iconBorder:SetPoint("TOPLEFT", bar, "TOPLEFT", -db.profile.iconOffset - borderOffset, borderOffset)
					iconBorder:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", -db.profile.iconOffset + iconWidth + borderOffset, -borderOffset)
				else
					iconBorder:SetPoint("TOPLEFT", bar, "TOPRIGHT", db.profile.iconOffset - iconWidth - borderOffset, borderOffset)
					iconBorder:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", db.profile.iconOffset + borderOffset, -borderOffset)
				end
				iconBorder:Show()
				iconBorder:SetBackdrop(backdropTbl)
				if db.profile.backgroundName ~= "None" then
					iconBorder:SetBackdropColor(db.profile.backgroundColor[1], db.profile.backgroundColor[2], db.profile.backgroundColor[3], db.profile.backgroundColor[4])
				end
				if db.profile.borderName ~= "None" then
					iconBorder:SetBackdropBorderColor(db.profile.borderColor[1], db.profile.borderColor[2], db.profile.borderColor[3], db.profile.borderColor[4])
				end
			else
				bar.candyBarIconFrameBackdrop:ClearBackdrop()
				bar.candyBarIconFrameBackdrop:Hide()
				border:SetPoint("TOPLEFT", bar, "TOPLEFT", -borderOffset, borderOffset)
				border:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", borderOffset, -borderOffset)
			end
			border:Show()
			border:SetBackdrop(backdropTbl)
			if db.profile.backgroundName ~= "None" then
				border:SetBackdropColor(db.profile.backgroundColor[1], db.profile.backgroundColor[2], db.profile.backgroundColor[3], db.profile.backgroundColor[4])
			end
			if db.profile.borderName ~= "None" then
				border:SetBackdropBorderColor(db.profile.borderColor[1], db.profile.borderColor[2], db.profile.borderColor[3], db.profile.borderColor[4])
			end
		else
			bar.candyBarBackdrop:ClearBackdrop()
			bar.candyBarBackdrop:Hide()
			bar.candyBarIconFrameBackdrop:ClearBackdrop()
			bar.candyBarIconFrameBackdrop:Hide()
		end

		return iconWidth
	end

	function UpdateProfile()
		ValidateMainSettings()
		if IsLoggedIn() then
			ValidateMediaSettings()
			ValidateAnchorFrame()
		end
		RebuildStyleCache()

		frame:SetSize(db.profile.width, db.profile.height)
		UpdateMover()
		RefixPosition()

		for bar in next, activeBars do
			bar:SetSize(db.profile.width, db.profile.height)
			bar:SetTexture(barTexture)
			bar:SetFont(barFont, db.profile.fontSize, barFontFlags)
			if not bar.paused then
				bar:SetFill(db.profile.fill)
			end
			bar:SetLabelVisibility(db.profile.text)
			bar.candyBarLabel:SetJustifyH(db.profile.alignText)
			if not bar.paused then
				bar:SetTimeVisibility(db.profile.timeText)
				bar:SetDecimalsThreshold(db.profile.timeDecimals)
			end
			bar.candyBarDuration:SetJustifyH(db.profile.alignTime)
			bar:SetIconVisibility(db.profile.icon)
			bar:SetIconPosition(db.profile.alignIcon)
			local colorid = bar:Get("capping:colorid")
			local color = colorid and db.profile[colorid]
			if color then
				bar:SetColor(color[1], color[2], color[3], color[4])
			end
			bar:SetTextColor(db.profile.colorText[1], db.profile.colorText[2], db.profile.colorText[3], db.profile.colorText[4])
			bar:SetShadowColor(db.profile.colorTextShadow[1], db.profile.colorTextShadow[2], db.profile.colorTextShadow[3], db.profile.colorTextShadow[4])

			local iconWidth = ApplyBarLayout(bar)

			-- For SetJustifyH to update, it requires a SetText with different text.
			-- So we store the value, reset the text, and set it again.
			local labelText = bar:GetLabel()
			bar.candyBarLabel:ClearText()
			bar:SetLabel(labelText)
			if bar.paused then
				local durationText = bar.candyBarDuration:GetText()
				if durationText and durationText ~= "" then
					bar.candyBarDuration:ClearText()
					bar.candyBarDuration:SetText(durationText)
				end
			end

			local baseTexCoord = bar:Get("capping:icontexcoord")
			bar.candyBarIconFrame:SetTexCoord(GetIconTexCoord(iconWidth, db.profile.height, baseTexCoord))
		end

		if not db.profile.queueBars then
			for bar in next, activeBars do
				if bar:Get("capping:queueid") and bar:Get("capping:colorid") == "colorQueue" then
					activeBars[bar] = nil
					bar:Stop()
				end
			end
		end

		frame.UpdateBarClickState()
		frame.RearrangeBars()
	end
	frame.UpdateProfile = UpdateProfile

	db = LibStub("AceDB-3.0"):New("CappingSettings", defaults, true)
	frame.db = db
	do
		local function OnProfileUpdate()
			UpdateProfile()
			NotifyOptions()
		end
		db.RegisterCallback(frame, "OnProfileChanged", OnProfileUpdate)
		db.RegisterCallback(frame, "OnProfileCopied", OnProfileUpdate)
		db.RegisterCallback(frame, "OnProfileReset", OnProfileUpdate)
	end

	ValidateMainSettings()
	RebuildStyleCache()
end

--------------------------------------------------------------------------------
-- API
--
do
	local API = {}
	local public = {}
	do
		local BarOnClick, IsClickModifierDown, EnsureModifierEvent, UnregisterModifierEvent
		do
			local modifierEventRegistered = false

			local function HasClickModifierEnabled()
				return db.profile.barOnShift ~= "NONE" or db.profile.barOnControl ~= "NONE" or db.profile.barOnAlt ~= "NONE"
			end

			function IsClickModifierDown()
				return (db.profile.barOnShift ~= "NONE" and IsShiftKeyDown())
					or (db.profile.barOnControl ~= "NONE" and IsControlKeyDown())
					or (db.profile.barOnAlt ~= "NONE" and IsAltKeyDown())
			end

			local function UpdateBarMouseState()
				local enabled = IsClickModifierDown()
				for bar in next, activeBars do
					bar:EnableMouse(enabled)
				end
			end

			function EnsureModifierEvent()
				if not modifierEventRegistered and HasClickModifierEnabled() then
					modifierEventRegistered = true
					core:RegisterEvent("MODIFIER_STATE_CHANGED", UpdateBarMouseState)
				end
			end

			function UnregisterModifierEvent()
				if modifierEventRegistered and not next(activeBars) then
					modifierEventRegistered = false
					core:UnregisterEvent("MODIFIER_STATE_CHANGED")
				end
			end

			frame.UpdateBarClickState = function()
				local shouldListen = next(activeBars) ~= nil and HasClickModifierEnabled()
				if shouldListen and not modifierEventRegistered then
					modifierEventRegistered = true
					core:RegisterEvent("MODIFIER_STATE_CHANGED", UpdateBarMouseState)
				elseif not shouldListen and modifierEventRegistered then
					modifierEventRegistered = false
					core:UnregisterEvent("MODIFIER_STATE_CHANGED")
				end
				UpdateBarMouseState()
			end

			local hordeFaction = _G.FACTION_HORDE == "Horde" and "Horde" or "Horde/".._G.FACTION_HORDE
			local allianceFaction = _G.FACTION_ALLIANCE == "Alliance" and "Alliance" or "Alliance/".._G.FACTION_ALLIANCE

			local function ReportBar(bar, channel)
				if not activeBars[bar] then return end
				if channel == "INSTANCE_CHAT" and not IsInGroup(2) then channel = "RAID" end -- LE_PARTY_CATEGORY_INSTANCE = 2
				local custom = bar:Get("capping:customchat")
				if not custom then
					local timeLeft = bar.durationBinding:GetFormattedText()
					if not timeLeft or timeLeft == "" then return end
					if not timeLeft:find("[:%.]") then
						timeLeft = #timeLeft == 1 and "0:0"..timeLeft or "0:"..timeLeft
					end
					local label = bar:GetLabel()
					local englishName = bar:Get("capping:englishname")
					if englishName and englishName ~= label then
						label = englishName .."/".. label
					end
					local colorid = bar:Get("capping:colorid")
					local faction = colorid == "colorHorde" and hordeFaction or colorid == "colorAlliance" and allianceFaction or nil
					if faction then
						C_ChatInfo.SendChatMessage(format("Capping: %s - %s (%s)", timeLeft, label, faction), channel)
					else
						C_ChatInfo.SendChatMessage(format("Capping: %s - %s", timeLeft, label), channel)
					end
				else
					local msg = custom(bar)
					if msg then
						C_ChatInfo.SendChatMessage(format("Capping: %s", msg), channel)
					end
				end
			end
			function BarOnClick(bar)
				if IsShiftKeyDown() and db.profile.barOnShift ~= "NONE" then
					ReportBar(bar, db.profile.barOnShift)
				elseif IsControlKeyDown() and db.profile.barOnControl ~= "NONE" then
					ReportBar(bar, db.profile.barOnControl)
				elseif IsAltKeyDown() and db.profile.barOnAlt ~= "NONE" then
					ReportBar(bar, db.profile.barOnAlt)
				else
					UpdateBarMouseState()
				end
			end
		end

		local RearrangeBars
		do
			-- Ripped from BigWigs bar sorter
			local function barSorter(a, b)
				local idA = a:Get("capping:priority")
				local idB = b:Get("capping:priority")
				if idA and not idB then
					return true
				elseif idB and not idA then
					return
				else
					return a:GetRemainingTime() < b:GetRemainingTime()
				end
			end
			RearrangeBars = function()
				local tmp = {}
				for bar in next, activeBars do
					tmp[#tmp + 1] = bar
				end
				table.sort(tmp, barSorter)
				local lastBar = nil
				local up = db.profile.growUp
				for i = 1, #tmp do
					local bar = tmp[i]
					local spacing = db.profile.spacing
					bar:ClearAllPoints()
					if up then
						if lastBar then -- Growing from a bar
							bar:SetPoint("BOTTOMLEFT", lastBar, "TOPLEFT", 0, spacing)
							bar:SetPoint("BOTTOMRIGHT", lastBar, "TOPRIGHT", 0, spacing)
						else -- Growing from the anchor
							bar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
						end
						lastBar = bar
					else
						if lastBar then -- Growing from a bar
							bar:SetPoint("TOPLEFT", lastBar, "BOTTOMLEFT", 0, -spacing)
							bar:SetPoint("TOPRIGHT", lastBar, "BOTTOMRIGHT", 0, -spacing)
						else -- Growing from the anchor
							bar:SetPoint("TOPLEFT", frame, "TOPLEFT")
						end
						lastBar = bar
					end
				end
			end
			frame.RearrangeBars = RearrangeBars
		end

		function API:StartBar(name, remaining, icon, colorid, priority, maxBarTime)
			for bar in next, activeBars do
				if bar:GetLabel() == name then
					activeBars[bar] = nil
					bar:Stop()
				end
			end
			local bar = candy:New(barTexture, db.profile.width, db.profile.height)
			activeBars[bar] = true

			bar:Set("capping:colorid", colorid)
			if priority then
				bar:Set("capping:priority", priority)
			end
			local iconTex, baseTexCoord
			if type(icon) == "table" then
				iconTex = icon[1]
				baseTexCoord = {icon[2], icon[3], icon[4], icon[5]}
				bar:Set("capping:icontexcoord", baseTexCoord)
			else
				iconTex = icon
			end

			bar:SetParent(frame)
			bar:SetFrameLevel(100)
			bar:SetDuration(remaining)
			bar:SetFont(barFont, db.profile.fontSize, barFontFlags)
			local barColor = db.profile[colorid]
			bar:SetColor(barColor[1], barColor[2], barColor[3], barColor[4])
			bar:SetBackgroundColor(0, 0, 0, 0)
			bar:SetTextColor(db.profile.colorText[1], db.profile.colorText[2], db.profile.colorText[3], db.profile.colorText[4])
			bar:SetShadowColor(db.profile.colorTextShadow[1], db.profile.colorTextShadow[2], db.profile.colorTextShadow[3], db.profile.colorTextShadow[4])
			bar.candyBarLabel:SetJustifyH(db.profile.alignText)
			bar.candyBarDuration:SetJustifyH(db.profile.alignTime)
			bar:SetLabelVisibility(db.profile.text)
			bar:SetTimeVisibility(db.profile.timeText)
			bar:SetDecimalsThreshold(db.profile.timeDecimals)
			bar:SetIconVisibility(db.profile.icon)
			bar:SetIconPosition(db.profile.alignIcon)
			bar:SetFill(db.profile.fill)
			bar:SetScript("OnMouseUp", BarOnClick)
			local clickEnabled = IsClickModifierDown()
			bar:EnableMouse(clickEnabled)
			EnsureModifierEvent()
			bar:Start(maxBarTime)
			local iconWidth = ApplyBarLayout(bar)
			bar:SetLabel(name)
			bar:SetIcon(iconTex, GetIconTexCoord(iconWidth, db.profile.height, baseTexCoord))
			RearrangeBars()
			return bar
		end
		public.StartBar = API.StartBar

		function API:StopBar(text)
			local dirty = nil
			for bar in next, activeBars do
				if bar:GetLabel() == text then
					activeBars[bar] = nil
					bar:Stop()
					dirty = true
				end
			end
			if dirty then
				if next(activeBars) then
					RearrangeBars()
				else
					UnregisterModifierEvent()
				end
			end
		end
		public.StopBar = API.StopBar
		CappingAPI = public

		function API:StopBarByData(data, value)
			local dirty = nil
			for bar in next, activeBars do
				if bar:Get(data) == value then
					activeBars[bar] = nil
					bar:Stop()
					dirty = true
				end
			end
			if dirty then
				if next(activeBars) then
					RearrangeBars()
				else
					UnregisterModifierEvent()
				end
			end
		end

		function API:StopBarContainingData(data)
			local dirty = nil
			for bar in next, activeBars do
				if bar:Get(data) then
					activeBars[bar] = nil
					bar:Stop()
					dirty = true
				end
			end
			if dirty then
				if next(activeBars) then
					RearrangeBars()
				else
					UnregisterModifierEvent()
				end
			end
		end

		candy.RegisterCallback(API, "LibCandyBar_Stop", function(_, bar)
			if activeBars[bar] then
				activeBars[bar] = nil
				if next(activeBars) then
					RearrangeBars()
				else
					UnregisterModifierEvent()
				end
			end
		end)

		function API:StopAllBars()
			for bar in next, activeBars do
				activeBars[bar] = nil
				bar:Stop()
			end
			UnregisterModifierEvent()
		end
	end

	function API:GetBar(text)
		for bar in next, activeBars do
			if bar:GetLabel() == text then
				return bar
			end
		end
	end

	function API:GetBarByData(data, value)
		for bar in next, activeBars do
			if bar:Get(data) == value then
				return bar
			end
		end
	end

	do
		local eventMap = {}
		frame:SetScript("OnEvent", function(_, event, ...)
			for k,v in next, eventMap[event] do
				if type(v) == "function" then
					v(...)
				else
					k[v](k, ...)
				end
			end
		end)

		function API:RegisterEvent(event, func)
			if not eventMap[event] then eventMap[event] = {} end
			eventMap[event][self] = func or event
			frame:RegisterEvent(event)
		end
		function API:UnregisterEvent(event)
			if not eventMap[event] then return end
			eventMap[event][self] = nil
			if not next(eventMap[event]) then
				frame:UnregisterEvent(event)
				eventMap[event] = nil
			end
		end
	end

	function API:RegisterZone(id)
		zoneIds[id] = self
	end

	local Timer = C_Timer.After
	function API:Timer(duration, func)
		Timer(duration, func)
	end

	do
		local unitTable1 = {
			"target", "targettarget",
			"mouseover", "mouseovertarget",
			"focus", "focustarget",
			"nameplate1", "nameplate2", "nameplate3", "nameplate4", "nameplate5", "nameplate6", "nameplate7", "nameplate8", "nameplate9", "nameplate10",
			"nameplate11", "nameplate12", "nameplate13", "nameplate14", "nameplate15", "nameplate16", "nameplate17", "nameplate18", "nameplate19", "nameplate20",
			"nameplate21", "nameplate22", "nameplate23", "nameplate24", "nameplate25", "nameplate26", "nameplate27", "nameplate28", "nameplate29", "nameplate30",
			"nameplate31", "nameplate32", "nameplate33", "nameplate34", "nameplate35", "nameplate36", "nameplate37", "nameplate38", "nameplate39", "nameplate40",
		}
		local unitTable2 = {
			"nameplate1target", "nameplate2target", "nameplate3target", "nameplate4target", "nameplate5target",
			"nameplate6target", "nameplate7target", "nameplate8target", "nameplate9target", "nameplate10target",
			"nameplate11target", "nameplate12target", "nameplate13target", "nameplate14target", "nameplate15target",
			"nameplate16target", "nameplate17target", "nameplate18target", "nameplate19target", "nameplate20target",
			"nameplate21target", "nameplate22target", "nameplate23target", "nameplate24target", "nameplate25target",
			"nameplate26target", "nameplate27target", "nameplate28target", "nameplate29target", "nameplate30target",
			"nameplate31target", "nameplate32target", "nameplate33target", "nameplate34target", "nameplate35target",
			"nameplate36target", "nameplate37target", "nameplate38target", "nameplate39target", "nameplate40target",
		}
		local unitTable3 = {
			"raid1target", "raid2target", "raid3target", "raid4target", "raid5target",
			"raid6target", "raid7target", "raid8target", "raid9target", "raid10target",
			"raid11target", "raid12target", "raid13target", "raid14target", "raid15target",
			"raid16target", "raid17target", "raid18target", "raid19target", "raid20target",
			"raid21target", "raid22target", "raid23target", "raid24target", "raid25target",
			"raid26target", "raid27target", "raid28target", "raid29target", "raid30target",
			"raid31target", "raid32target", "raid33target", "raid34target", "raid35target",
			"raid36target", "raid37target", "raid38target", "raid39target", "raid40target"
		}
		local collection, reset, blocked, started = {}, {}, {}, false
		local count1, count2, count3 = #unitTable1, #unitTable2, #unitTable3
		local UnitGUID, strsplit = UnitGUID, strsplit
		local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
		local SendAddonMessage = C_ChatInfo.SendAddonMessage
		local curMod = nil

		local function parse2()
			if started then
				for i = 1, count2 do
					local unit = unitTable2[i]
					local guid = UnitGUID(unit)
					if guid then
						local _, _, _, _, _, strid = strsplit("-", guid)
						if strid and collection[strid] and not blocked[strid] then
							local maxHP = UnitHealthMax(unit)
							if maxHP > 0 then
								blocked[strid] = true
								local hp = UnitHealth(unit) / maxHP * 100
								SendAddonMessage("Capping", format("%s:%.1f", strid, hp), "INSTANCE_CHAT")
							end
						end
					end
				end
			end
		end
		local function parse3()
			if started then
				for i = 1, count3 do
					local unit = unitTable3[i]
					local guid = UnitGUID(unit)
					if guid then
						local _, _, _, _, _, strid = strsplit("-", guid)
						if strid and collection[strid] and not blocked[strid] then
							local maxHP = UnitHealthMax(unit)
							if maxHP > 0 then
								blocked[strid] = true
								local hp = UnitHealth(unit) / maxHP * 100
								SendAddonMessage("Capping", format("%s:%.1f", strid, hp), "INSTANCE_CHAT")
							end
						end
					end
				end
			end
		end
		local function HealthScan()
			if started then
				Timer(1, HealthScan)
				Timer(0.01, parse2) -- Break up parsing
				Timer(0.02, parse3)

				for id, counter in next, reset do
					reset[id] = counter + 1
					if counter > 20 then
						local tbl = collection[id]:Get("capping:hpdata")
						collection[id]:Stop()
						reset[id] = nil
						collection[id] = tbl
					end
				end

				for k in next, blocked do
					blocked[k] = nil
				end
				for i = 1, count1 do
					local unit = unitTable1[i]
					local guid = UnitGUID(unit)
					if guid then
						local _, _, _, _, _, strid = strsplit("-", guid)
						if strid and collection[strid] and not blocked[strid] then
							local maxHP = UnitHealthMax(unit)
							if maxHP > 0 then
								blocked[strid] = true
								local hp = UnitHealth(unit) / maxHP * 100
								SendAddonMessage("Capping", format("%s:%.1f", strid, hp), "INSTANCE_CHAT")
							end
						end
					end
				end
			end
		end

		local function HealthUpdate(prefix, msg, channel)
			if prefix == "Capping" and channel == "INSTANCE_CHAT" then
				local strid, strhp = strsplit(":", msg)
				local hp = tonumber(strhp)
				if strid and hp and collection[strid] and hp <= 100 and hp >= 0 and (hp < 0) ~= (hp >= 0) then -- Check hp is 0-100 and isn't NaN
					if collection[strid].candyBarBar then
						if hp > 0 and hp < 100 then
							reset[strid] = 0
						end
						collection[strid].candyBarBar:SetValue(hp)
						collection[strid].candyBarDuration:SetFormattedText("%.1f%%", hp)
					elseif hp < 100 and hp > 0 then
						local tbl = collection[strid]
						local bar = curMod:StartBar(tbl[1], 100, tbl[3], tbl[4], true)
						bar:Pause()
						bar:SetTimeVisibility(true)
						bar.candyBarBar:SetValue(hp)
						bar.candyBarDuration:SetFormattedText("%.1f%%", hp)
						bar:Set("capping:customchat", function(candyBar)
							if tbl[1] ~= tbl[2] then
								return tbl[2] .."/".. tbl[1] .." - ".. candyBar.candyBarDuration:GetText()
							else
								return tbl[1] .." - ".. candyBar.candyBarDuration:GetText()
							end
						end)
						bar:Set("capping:hpdata", tbl)
						reset[strid] = 0
						collection[strid] = bar
					end
				end
			end
		end

		function API:SetupHealthCheck(npcId, npcName, englishName, icon, color)
			curMod = self
			collection[npcId] = {npcName, englishName, icon, color}
			if not started then
				started = true
				C_ChatInfo.RegisterAddonMessagePrefix("Capping")
				core:RegisterEvent("CHAT_MSG_ADDON", HealthUpdate)
				Timer(1, HealthScan)
			end
		end

		function API:StopHealthCheck()
			started = false
			collection, reset, blocked = {}, {}, {}
			core:UnregisterEvent("CHAT_MSG_ADDON")
		end
	end

	do
		local prevText = ""
		local prevTime, prevAScore, prevHScore, prevAIncrease, prevHIncrease = 0, 0, 0, 0, 0
		local timeBetweenEachTick, prevTick, prevTimeToWin = 0, 0, 0
		local maxscore, ascore, hscore, aIncrease, hIncrease = 0, 0, 0, 0, 0
		local aRemain, hRemain, aTicksToWin, hTicksToWin = 0, 0, 0, 0
		local aBases, hBases, prevABases, prevHBases = 0, 0, 0, 0
		local aTime, hTime = 0, 0
		local prevfinalAScore, prevfinalHScore = 0, 0
		local curMod = nil

		local function UpdatePredictor()
			if aIncrease ~= prevAIncrease or hIncrease ~= prevHIncrease or timeBetweenEachTick ~= prevTick then
				if aIncrease > 65 or hIncrease > 65 --[[or aIncrease < 0 or hIncrease < 0]] then -- Scores can reduce in DG
					curMod:StopBar(prevText) -- >65 increase means captured a flag/cart in EotS/DG
					prevAIncrease, prevHIncrease = -1, -1
					return
				end
				prevAIncrease, prevHIncrease, prevTick = aIncrease, hIncrease, timeBetweenEachTick
				if hTicksToWin < aTicksToWin then -- Horde is winning
					local timeToWin = hTicksToWin * timeBetweenEachTick
					local finalAScore = ascore + (hTicksToWin * aIncrease)
					local txt = format(L.finalScore, finalAScore, maxscore)
					if txt ~= prevText or timeToWin ~= prevTimeToWin then
						prevTimeToWin = timeToWin
						curMod:StopBar(prevText)
						if timeToWin > 0 then
							curMod:StartBar(txt, timeToWin-0.5, 132485, "colorHorde") -- 132485 = Interface/Icons/INV_BannerPVP_01
						end
						prevText = txt
					end
				elseif aTicksToWin < hTicksToWin then -- Alliance is winning
					local timeToWin = aTicksToWin * timeBetweenEachTick
					local finalHScore = hscore + (aTicksToWin * hIncrease)
					local txt = format(L.finalScore, maxscore, finalHScore)
					if txt ~= prevText or timeToWin ~= prevTimeToWin then
						prevTimeToWin = timeToWin
						curMod:StopBar(prevText)
						if timeToWin > 0 then
							curMod:StartBar(txt, timeToWin-0.5, 132486, "colorAlliance") -- 132486 = Interface/Icons/INV_BannerPVP_02
						end
						prevText = txt
					end
				else -- Draw or neither faction has bases
					if aTicksToWin < 10000 then
						local timeToWin = aTicksToWin * timeBetweenEachTick
						local txt = format(L.finalScore, maxscore, maxscore)
						if txt ~= prevText or timeToWin ~= prevTimeToWin then
							prevTimeToWin = timeToWin
							curMod:StopBar(prevText)
							if timeToWin > 0 then
								curMod:StartBar(txt, timeToWin-0.5, 136001, "colorOther") -- 136001 = Interface/Icons/spell_misc_hellifrepvpcombatmorale
							end
							prevText = txt
						end
					elseif prevText ~= "" then
						prevTimeToWin = 0
						curMod:StopBar(prevText)
						prevText = ""
					end
				end
			end
		end

		local GetIconAndTextWidgetVisualizationInfo = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo
		local ceil, floor = math.ceil, math.floor
		local function ScorePredictor(widgetInfo)
			if widgetInfo and (widgetInfo.widgetID == 3116 or widgetInfo.widgetID == 3117) then
				local dataTbl = GetIconAndTextWidgetVisualizationInfo(widgetInfo.widgetID)
				if not dataTbl or not dataTbl.text then return end
				if prevTime == 0 then
					local allianceTbl = GetIconAndTextWidgetVisualizationInfo(3116)
					local hordeTbl = GetIconAndTextWidgetVisualizationInfo(3117)
					if not allianceTbl or not allianceTbl.text or not hordeTbl or not hordeTbl.text then return end
					prevTime = GetTime()
					local ascoreStr, maxscoreStr = string.match(allianceTbl.text, "(%d+)/(%d+)")
					prevAScore = tonumber(ascoreStr) or 0
					maxscore = tonumber(maxscoreStr) or maxscore
					prevHScore = tonumber(string.match(hordeTbl.text, "(%d+)/%d+")) or 0
					return
				end

				local t = GetTime()
				local elapsed = t - prevTime
				prevTime = t
				if elapsed > 0.5 then
					-- If there's only 1 update, it could be either alliance or horde, so we update both stats in this one
					local allianceTbl = GetIconAndTextWidgetVisualizationInfo(3116)
					local hordeTbl = GetIconAndTextWidgetVisualizationInfo(3117)
					if not allianceTbl or not allianceTbl.text or not hordeTbl or not hordeTbl.text then return end
					local ascoreStr, maxscoreStr = string.match(allianceTbl.text, "(%d+)/(%d+)")
					ascore = tonumber(ascoreStr) or 0
					maxscore = tonumber(maxscoreStr) or maxscore
					hscore = tonumber(string.match(hordeTbl.text, "(%d+)/%d+")) or 0
					aIncrease = ascore - prevAScore
					hIncrease = hscore - prevHScore
					aRemain = maxscore - ascore
					hRemain = maxscore - hscore
					-- Always round ticks upwards. 1.2 ticks will always be 2 ticks to end.
					-- If ticks are 0 (no bases) then set to a random huge number (10,000)
					aTicksToWin = ceil(aIncrease == 0 and 10000 or aRemain / aIncrease)
					hTicksToWin = ceil(hIncrease == 0 and 10000 or hRemain / hIncrease)
					-- Round to the closest time
					timeBetweenEachTick = elapsed % 1 >= 0.5 and ceil(elapsed) or floor(elapsed)
					prevAScore, prevHScore = ascore, hscore
					Timer(0.5, UpdatePredictor)
				else
					-- If elapsed < 0.5 then the event fired twice because both alliance and horde have bases.
					-- If only one faction has bases, the event only fires once.
					-- Unfortunately we need to wait for the 2nd event to fire to know the true stats for the other faction.
					-- In this one where we have 2 updates, we overwrite the stats from the 1st update.
					if widgetInfo.widgetID == 3116 then
						ascore = tonumber(string.match(dataTbl.text, "(%d+)/%d+")) or 0
						aIncrease = ascore - prevAScore
						aRemain = maxscore - ascore
						-- Always round ticks upwards. 1.2 ticks will always be 2 ticks to end.
						-- If ticks are 0 (no bases) then set to a random huge number (10,000)
						aTicksToWin = ceil(aIncrease == 0 and 10000 or aRemain / aIncrease)
						prevAScore = ascore
					else
						hscore = tonumber(string.match(dataTbl.text, "(%d+)/%d+")) or 0
						hIncrease = hscore - prevHScore
						hRemain = maxscore - hscore
						-- Always round ticks upwards. 1.2 ticks will always be 2 ticks to end.
						-- If ticks are 0 (no bases) then set to a random huge number (10,000)
						hTicksToWin = ceil(hIncrease == 0 and 10000 or hRemain / hIncrease)
						prevHScore = hscore
					end
				end
			end
		end

		local abTable = {0.8333, 1.1111, 1.6667, 3.3333, 30}
		local function ScorePredictorAB(widgetInfo)
			if widgetInfo and (widgetInfo.widgetID == 1893 or widgetInfo.widgetID == 1894) then
				local dataTbl = GetIconAndTextWidgetVisualizationInfo(widgetInfo.widgetID)
				if not dataTbl or not dataTbl.text then return end

				local curTime = GetTime()

				local allianceTbl = GetIconAndTextWidgetVisualizationInfo(1893)
				local hordeTbl = GetIconAndTextWidgetVisualizationInfo(1894)
				if not allianceTbl or not allianceTbl.text or not hordeTbl or not hordeTbl.text then return end
				local aBasesStr, ascoreStr, maxscoreStr = string.match(allianceTbl.text, "(%d)[^%d]+(%d+)/(%d+)")
				aBases, ascore = tonumber(aBasesStr), tonumber(ascoreStr)
				maxscore = tonumber(maxscoreStr) or maxscore
				local hBasesStr, hscoreStr = string.match(hordeTbl.text, "(%d)[^%d]+(%d+)/%d+")
				hBases, hscore = tonumber(hBasesStr), tonumber(hscoreStr)
				if not aBases or not ascore or not hBases or not hscore then return end

				-- Hackjob backport of original code
				local aTicked, hTicked = false, false
				if aBases == 0 then
					aTime = 0
				elseif ascore ~= prevAScore then
					prevAScore, aTime, aTicked = ascore, curTime, true
				end
				if hBases == 0 then
					hTime = 0
				elseif hscore ~= prevHScore then
					prevHScore, hTime, hTicked = hscore, curTime, true
				end
				if not aTicked and not hTicked then return end

				local apps, hpps = abTable[aBases] or 0, abTable[hBases] or 0
				local ATimeRemain = ((maxscore - ascore) / apps) - (aTime > 0 and (curTime - aTime) or 0)
				if ATimeRemain > 10000 then ATimeRemain = 10000 end
				local HTimeRemain = ((maxscore - hscore) / hpps) - (hTime > 0 and (curTime - hTime) or 0)
				if HTimeRemain > 10000 then HTimeRemain = 10000 end

				local basesChanged = aBases ~= prevABases or hBases ~= prevHBases
				if aTicked or aBases == 0 then
					prevABases = aBases
				end
				if hTicked or hBases == 0 then
					prevHBases = hBases
				end
				if HTimeRemain < ATimeRemain then -- Horde is winning
					local finalAScore = 10 * math.floor((HTimeRemain * apps + ascore + 5) * 0.1)
					finalAScore = (finalAScore < 0 and 0) or (finalAScore < maxscore and finalAScore) or (maxscore - 10)
					local txt = format(L.finalScore, finalAScore, maxscore)
					if basesChanged or (txt ~= prevText and finalAScore ~= (prevfinalAScore+10)) then
						curMod:StopBar(prevText)
						if HTimeRemain > 0 then
							curMod:StartBar(txt, HTimeRemain, 132485, "colorHorde") -- 132485 = Interface/Icons/INV_BannerPVP_01
						end
						prevText = txt
						prevfinalAScore = finalAScore
					end
				elseif ATimeRemain < HTimeRemain then -- Alliance is winning
					local finalHScore = 10 * math.floor((ATimeRemain * hpps + hscore + 5) * 0.1)
					finalHScore = (finalHScore < 0 and 0) or (finalHScore < maxscore and finalHScore) or (maxscore - 10)
					local txt = format(L.finalScore, maxscore, finalHScore)
					if basesChanged or (txt ~= prevText and finalHScore ~= (prevfinalHScore+10)) then
						curMod:StopBar(prevText)
						if ATimeRemain > 0 then
							curMod:StartBar(txt, ATimeRemain, 132486, "colorAlliance") -- 132486 = Interface/Icons/INV_BannerPVP_02
						end
						prevText = txt
						prevfinalHScore = finalHScore
					end
				else -- Draw or neither faction has bases
					if ATimeRemain < 10000 then
						local txt = format(L.finalScore, maxscore, maxscore)
						if basesChanged or txt ~= prevText then
							curMod:StopBar(prevText)
							if ATimeRemain > 0 then
								curMod:StartBar(txt, ATimeRemain, 136001, "colorOther") -- 136001 = Interface/Icons/spell_misc_hellifrepvpcombatmorale
							end
							prevText = txt
							prevfinalAScore, prevfinalHScore = maxscore, maxscore
						end
					elseif prevText ~= "" then
						curMod:StopBar(prevText)
						prevText = ""
						prevfinalAScore, prevfinalHScore = 0, 0
					end
				end
			end
		end
		function API:StartScoreEstimator()
			prevText = ""
			curMod = self
			prevTime, prevAScore, prevHScore, prevAIncrease, prevHIncrease = 0, 0, 0, 0, 0
			timeBetweenEachTick, prevTick, prevTimeToWin = 0, 0, 0
			maxscore, ascore, hscore, aIncrease, hIncrease = 1600, 0, 0, 0, 0
			aRemain, hRemain, aTicksToWin, hTicksToWin = 0, 0, 0, 0

			self:RegisterEvent("UPDATE_UI_WIDGET", ScorePredictor)
		end
		function API:StartScoreEstimatorAB()
			prevText = ""
			curMod = self
			prevTime, prevAScore, prevHScore, prevAIncrease, prevHIncrease = 0, 0, 0, 0, 0
			timeBetweenEachTick, prevTick, prevTimeToWin = 0, 0, 0
			maxscore, ascore, hscore, aIncrease, hIncrease = 1600, 0, 0, 0, 0
			aRemain, hRemain, aTicksToWin, hTicksToWin = 0, 0, 0, 0
			prevABases, prevHBases = 0, 0
			aTime, hTime = 0, 0
			prevfinalAScore, prevfinalHScore = 0, 0

			self:RegisterEvent("UPDATE_UI_WIDGET", ScorePredictorAB)
		end
		function API:StopScoreEstimator()
			self:UnregisterEvent("UPDATE_UI_WIDGET")
		end
	end

	do
		local GetPOITextureCoords = C_Minimap.GetPOITextureCoords
		-- Easy world map icon checker
		--local start = function(self) self:StartMoving() end
		--local stop = function(self) self:StopMovingOrSizing() end
		--local frames = {}
		--do
		--	local f = CreateFrame("Frame", nil, UIParent)
		--	f:SetPoint("CENTER")
		--	f:SetSize(24,24)
		--	f:EnableMouse(true)
		--	f:SetMovable(true)
		--	f:RegisterForDrag("LeftButton")
		--	f:SetScript("OnDragStart", start)
		--	f:SetScript("OnDragStop", stop)
		--	frames[1] = f
		--	local tx = f:CreateTexture()
		--	tx:SetAllPoints(f)
		--	tx:SetTexture(136441) -- Interface\\Minimap\\POIIcons
		--	tx:SetTexCoord(GetPOITextureCoords(1))
		--	local n = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		--	n:SetPoint("BOTTOM", f, "TOP")
		--	n:SetText(1)
		--end
		--for i = 2, 200 do
		--	local f = CreateFrame("Frame", nil, UIParent)
		--	f:SetPoint("LEFT", frames[i-1], "RIGHT", 10, 0)
		--	f:SetSize(24,24)
		--	f:EnableMouse(true)
		--	f:SetMovable(true)
		--	f:RegisterForDrag("LeftButton")
		--	f:SetScript("OnDragStart", start)
		--	f:SetScript("OnDragStop", stop)
		--	frames[i] = f
		--	local tx = f:CreateTexture()
		--	tx:SetAllPoints(f)
		--	tx:SetTexture(136441) -- Interface\\Minimap\\POIIcons
		--	tx:SetTexCoord(GetPOITextureCoords(i))
		--	local n = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		--	n:SetPoint("BOTTOM", f, "TOP")
		--	n:SetText(i)
		--end
		local iconDataConflict = {
			-- Graveyard
			[4] = "colorAlliance",
			[14] = "colorHorde",
			-- Tower
			[9] = "colorAlliance",
			[12] = "colorHorde",
			-- Mine/Stone
			[17] = "colorAlliance",
			[19] = "colorHorde",
			-- Lumber/Wood
			[22] = "colorAlliance",
			[24] = "colorHorde",
			-- Blacksmith/Anvil
			[27] = "colorAlliance",
			[29] = "colorHorde",
			-- Farm/House
			[32] = "colorAlliance",
			[34] = "colorHorde",
			-- Stables/Horse
			[37] = "colorAlliance",
			[39] = "colorHorde",
			-- Workshop/Tent
			[137] = "colorAlliance",
			[139] = "colorHorde",
			-- Hangar/Mushroom
			[142] = "colorAlliance",
			[144] = "colorHorde",
			-- Docks/Anchor
			[147] = "colorAlliance",
			[149] = "colorHorde",
			-- Oil/Refinery
			[152] = "colorAlliance",
			[154] = "colorHorde",
			-- Market
			[208] = "colorAlliance",
			[209] = "colorHorde",
			-- Ruins
			[213] = "colorAlliance",
			[214] = "colorHorde",
			-- Shrine
			[218] = "colorAlliance",
			[219] = "colorHorde",
		}
		local atlasColors = nil
		local poiEnglishNames = nil
		local capTime = 0
		local curMod = nil
		local path = {136441}
		local GetIconData = function(icon)
			path[2], path[3], path[4], path[5] = GetPOITextureCoords(icon)
			return path
		end
		local landmarkCache = {}
		local reportedUnknownPOIs = {}
		local GetAreaPOIForMap = C_AreaPoiInfo.GetAreaPOIForMap
		local GetAreaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo
		local GetAtlasInfo = C_Texture.GetAtlasInfo
		local GetSpellName = C_Spell.GetSpellName
		local GetBestMapForUnit = C_Map.GetBestMapForUnit
		local IsRatedSoloRBG = C_PvP.IsRatedSoloRBG or function() return false end

		local function ReportUnknownPOI(areaPoiID, name, mapID, icon)
			if not reportedUnknownPOIs[areaPoiID] then
				reportedUnknownPOIs[areaPoiID] = true
				print("|cFF33FF99Capping|r: NEW POI ID FOUND, TELL THE DEVS!", areaPoiID, name, mapID, icon)
				geterrorhandler()("|cFF33FF99Capping|r: NEW POI ID FOUND, TELL THE DEVS! ".. tostring(areaPoiID) ..", ".. tostring(name) ..", ".. tostring(mapID) ..", ".. tostring(icon))
			end
		end

		local function UpdatePOI()
			local curMapID = GetBestMapForUnit("player")
			if not curMapID then return end
			if type(capTime) == "table" then
				if IsRatedSoloRBG() then
					capTime = capTime[1]
				else
					capTime = capTime[2]
				end
			end
			local pois = GetAreaPOIForMap(curMapID)
			for i = 1, #pois do
				local tbl = GetAreaPOIInfo(curMapID, pois[i])
				if tbl then
					local name, icon, atlasName, areaPoiID = tbl.name, tbl.textureIndex, tbl.atlasName, tbl.areaPoiID
					if icon then
						local prevIcon = landmarkCache[name]
						if prevIcon ~= icon then
							landmarkCache[name] = icon
							if iconDataConflict[icon] then
								local bar = curMod:StartBar(name, capTime, GetIconData(icon), iconDataConflict[icon])
								bar:Set("capping:poiid", areaPoiID)
								if poiEnglishNames then
									local englishName = poiEnglishNames[areaPoiID]
									if englishName then
										bar:Set("capping:englishname", englishName)
									else
										ReportUnknownPOI(areaPoiID, name, curMapID, icon)
									end
								end
								if icon == 137 or icon == 139 then -- Workshop in IoC
									curMod:StopBar((GetSpellName(56661))) -- Build Siege Engine
								end
							else
								curMod:StopBar(name)
								if (icon == 136 or icon == 138) and (prevIcon == 137 or prevIcon == 139) then -- Workshop in IoC
									curMod:StartBar(GetSpellName(56661), 181, 252187, icon == 136 and "colorAlliance" or "colorHorde") -- Build Siege Engine, 252187 = ability_vehicle_siegeengineram
								elseif icon == 2 or icon == 3 or icon == 151 or icon == 153 or icon == 18 or icon == 20 then
									-- Horde mine, Alliance mine, Alliance Refinery, Horde Refinery, Alliance Quarry, Horde Quarry
									local _, _, _, id = UnitPosition("player")
									if id == 30 or id == 628 or id == 2197 then -- Alterac Valley, IoC, Korrak's Revenge (WoW 15th)
										local bar = curMod:StartBar(name, 3600, GetIconData(icon), (icon == 3 or icon == 151 or icon == 18) and "colorAlliance" or "colorHorde", true) -- Paused bar for mine status
										bar:Pause()
										bar:SetFill(false)
										bar:SetTimeVisibility(false)
										bar:Set("capping:customchat", function() end)
									end
								end
							end
						end
					elseif atlasName then
						if landmarkCache[name] ~= atlasName then
							--print(name, atlasName)
							landmarkCache[name] = atlasName
							if atlasColors and atlasColors[atlasName] then
								local atlasTbl = GetAtlasInfo(atlasName)
								local iconTbl = atlasTbl and { -- Begin Icon Texture
									atlasTbl.file,
									atlasTbl.leftTexCoord,
									atlasTbl.rightTexCoord,
									atlasTbl.topTexCoord,
									atlasTbl.bottomTexCoord,
								} -- End Icon Texture
								local bar = curMod:StartBar(
									name,
									capTime,
									iconTbl,
									atlasColors[atlasName] -- Color
								)
								bar:Set("capping:poiid", areaPoiID)
								if poiEnglishNames then
									local englishName = poiEnglishNames[areaPoiID]
									if englishName then
										bar:Set("capping:englishname", englishName)
									else
										ReportUnknownPOI(areaPoiID, name, curMapID, atlasName)
									end
								end
								--if atlasName == WORKSHOPHORDE or atlasName == WORKSHOPALLIANCE then -- Workshop in IoC
								--	curMod:StopBar((GetSpellName(56661))) -- Build Siege Engine
								--end
							else
								curMod:StopBar(name)
								--if icon == 136 or icon == 138 then -- Workshop in IoC
								--	curMod:StartBar(GetSpellName(56661), 181, 252187, icon == 136 and "colorAlliance" or "colorHorde") -- Build Siege Engine, 252187 = ability_vehicle_siegeengineram
								--elseif icon == 2 or icon == 3 or icon == 151 or icon == 153 or icon == 18 or icon == 20 then
								--	-- Horde mine, Alliance mine, Alliance Refinery, Horde Refinery, Alliance Quarry, Horde Quarry
								--	local _, _, _, id = UnitPosition("player")
								--	if id == 30 or id == 628 then -- Alterac Valley, IoC
								--		local bar = curMod:StartBar(name, 3600, GetIconData(icon), (icon == 3 or icon == 151 or icon == 18) and "colorAlliance" or "colorHorde", true) -- Paused bar for mine status
								--		bar:Pause()
								--		bar:SetTimeVisibility(false)
								--		bar:Set("capping:customchat", function() end)
								--	end
								--end
							end
						end
					end
				end
			end
		end

		function API:StartFlagCaptures(bgcaptime, colors, englishNames)
			atlasColors = colors
			poiEnglishNames = englishNames
			capTime = bgcaptime -- cap time
			landmarkCache = {}
			curMod = self
			self:RegisterEvent("AREA_POIS_UPDATED", UpdatePOI)
		end

		function API:StopFlagCaptures()
			poiEnglishNames = nil
			self:UnregisterEvent("AREA_POIS_UPDATED")
		end

		function API:RestoreFlagCaptures(inProgressDataTbl, maxBarTime)
			local uiMapID = GetBestMapForUnit("player")
			if not uiMapID then return end
			local pois = GetAreaPOIForMap(uiMapID)
			for i = 1, #pois do
				local tbl = GetAreaPOIInfo(uiMapID, pois[i])
				if tbl then
					local name, icon, areaPoiID = tbl.name, tbl.textureIndex, tbl.areaPoiID
					local timer = inProgressDataTbl[areaPoiID]
					if timer and iconDataConflict[icon] then
						landmarkCache[name] = icon
						local bar = self:StartBar(name, timer, GetIconData(icon), iconDataConflict[icon], nil, maxBarTime)
						bar:Set("capping:poiid", areaPoiID)
						if poiEnglishNames then
							local englishName = poiEnglishNames[areaPoiID]
							if englishName then
								bar:Set("capping:englishname", englishName)
							else
								ReportUnknownPOI(areaPoiID, name, uiMapID, icon)
							end
						end
					end
				end
			end
		end
	end

	do
		local GetOptions = C_GossipInfo.GetOptions
		local SelectOption = C_GossipInfo.SelectOption
		function API:GetGossipNumOptions()
			local gossipOptions = GetOptions()
			return #gossipOptions
		end
		function API:GetGossipID(id)
			local gossipOptions = GetOptions()
			for i = 1, #gossipOptions do
				local gossipTable = gossipOptions[i]
				if gossipTable.gossipOptionID == id then
					return true
				end
			end
		end
		function API:SelectGossipID(id)
			SelectOption(id)
		end
	end

	do
		local GetAvailableQuests = C_GossipInfo.GetAvailableQuests
		local SelectAvailableQuest = C_GossipInfo.SelectAvailableQuest
		function API:GetGossipAvailableQuestID(id)
			local gossipOptions = GetAvailableQuests()
			for i = 1, #gossipOptions do
				local gossipTable = gossipOptions[i]
				if gossipTable.questID == id then
					return true
				end
			end
		end
		function API:SelectGossipAvailableQuestID(id)
			SelectAvailableQuest(id)
		end
	end

	function mod:NewMod()
		local t = {}
		for k,v in next, API do
			t[k] = v
		end
		return t, L, frame
	end
end

--------------------------------------------------------------------------------
-- Core
--

core = mod:NewMod()
function core:PLAYER_LOGIN()
	self:UnregisterEvent("PLAYER_LOGIN")
	UpdateProfile()
	-- Fix flag carriers for some people
	C_CVar.SetCVar("showArenaEnemyCastbar", "1")
	C_CVar.SetCVar("showArenaEnemyFrames", "1")
	C_CVar.SetCVar("showArenaEnemyPets", "1")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end
core:RegisterEvent("PLAYER_LOGIN")

do
	local prevZone = nil
	local GetInstanceInfo = GetInstanceInfo
	function core:PLAYER_ENTERING_WORLD()
		local _, instanceType, _, _, _, _, _, id = GetInstanceInfo()
		if zoneIds[id] then
			prevZone = id
			self:RegisterEvent("PLAYER_LEAVING_WORLD")
			zoneIds[id]:EnterZone(id)
		elseif zoneIds[instanceType] then
			prevZone = instanceType
			self:RegisterEvent("PLAYER_LEAVING_WORLD")
			zoneIds[instanceType]:EnterZone(id)
		end
	end
	function core:PLAYER_LEAVING_WORLD()
		self:UnregisterEvent("PLAYER_LEAVING_WORLD")
		self:StopAllBars()
		zoneIds[prevZone]:ExitZone()
		prevZone = nil
	end
end

function core:Test(locale)
	core:StartBar(locale.queueBars, 100, 236396, "colorQueue") -- Interface/Icons/Achievement_BG_winWSG
	core:StartBar(locale.otherBars, 75, 132333, "colorOther") -- Interface/Icons/Ability_warrior_battleshout
	core:StartBar(locale.allianceBars, 45, 132486, "colorAlliance") -- Interface/Icons/INV_BannerPVP_02
	core:StartBar(locale.hordeBars, 25, 132485, "colorHorde") -- Interface/Icons/INV_BannerPVP_01
end
frame.Test = core.Test

--------------------------------------------------------------------------------
-- Options
--

do
	frame:SetSize(db.profile.width, db.profile.height)
	frame:SetClampedToScreen(true)
	frame:Show()

	local mover = CreateFrame("Frame", nil, frame)
	mover:SetHeight(15)
	mover:EnableMouse(true)
	mover:RegisterForDrag("LeftButton")
	frame.mover = mover

	local bg = mover:CreateTexture()
	bg:SetAllPoints(mover)
	bg:SetColorTexture(0, 1, 0, 0.3)
	local header = mover:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	header:SetAllPoints(mover)
	header:SetText(addonName)

	UpdateMover()
	RefixPosition()

	local tooltip = CreateFrame("GameTooltip", "CappingTooltip", UIParent, "GameTooltipTemplate")
	mover:SetScript("OnEnter", function(f)
		tooltip:ClearLines()
		tooltip:SetOwner(f, db.profile.growUp and "ANCHOR_BOTTOM" or "ANCHOR_TOP")
		tooltip:AddLine(L.anchorTooltip, 0.2, 1, 0.2, 1)
		tooltip:AddLine(L.anchorTooltipNote, 1, 1, 1, 1)
		tooltip:Show()
	end)
	mover:SetScript("OnLeave", function() tooltip:Hide() end)
	mover:SetScript("OnHide", function() tooltip:Hide() end)
	mover:SetScript("OnDragStart", function()
		if db.profile.position[5] == defaults.profile.position[5] then
			frame:StartMoving()
		end
	end)
	mover:SetScript("OnDragStop", function()
		if db.profile.position[5] == defaults.profile.position[5] then
			frame:StopMovingOrSizing()
			local point, _, relPoint, x, y = frame:GetPoint()
			x = math.floor(x+0.5)
			y = math.floor(y+0.5)
			db.profile.position = {point, relPoint, x, y, defaults.profile.position[5]}
			RefixPosition()
			NotifyOptions()
		end
	end)
	local function openOpts()
		C_AddOns.EnableAddOn("Capping_Options") -- Make sure it wasn't left disabled for whatever reason
		C_AddOns.LoadAddOn("Capping_Options")
		if frame.OpenOptions then
			frame.OpenOptions()
		end
	end
	SlashCmdList.Capping = openOpts
	SLASH_Capping1 = "/capping"
	mover:SetScript("OnMouseUp", function(_, btn)
		if btn == "RightButton" then
			openOpts()
		end
	end)
end
