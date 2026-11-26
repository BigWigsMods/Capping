
--------------------------------------------------------------------------------
-- Locals
--

local acr = LibStub("AceConfigRegistry-3.0")
local acd = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local LibSharedMedia = LibStub("LibSharedMedia-3.0")
local FONT = LibSharedMedia.MediaType and LibSharedMedia.MediaType.FONT or "font"
local STATUSBAR = LibSharedMedia.MediaType and LibSharedMedia.MediaType.STATUSBAR or "statusbar"
local BORDER = LibSharedMedia.MediaType and LibSharedMedia.MediaType.BORDER or "border"
local BACKGROUND = LibSharedMedia.MediaType and LibSharedMedia.MediaType.BACKGROUND or "background"
local cap = CappingFrame
local defaultProfile = cap.defaultProfile
local L
do
	local _, mod = ...
	L = mod.L
end

--------------------------------------------------------------------------------
-- Options
--

do
	local function IsBorderSetToNone() return cap.db.profile.borderName == "None" end
	local function IsBackgroundSetToNone() return cap.db.profile.backgroundName == "None" end
	local function IsTextDisabled() return not cap.db.profile.text end
	local function IsTimeDisabled() return not cap.db.profile.timeText end
	local function IsIconDisabled() return not cap.db.profile.icon end
	local function IsDetachedIconDisabled() return not cap.db.profile.icon or not cap.db.profile.detachedIcon end
	local function IsAnchorPointDefault() return cap.db.profile.position[5] == defaultProfile.position[5] end
	local function IsCopyCustomAnchorWidthEnabled() return cap.db.profile.copyCustomAnchorWidth end

	local function GetColor(info)
		local color = cap.db.profile[info[#info]]
		return color[1], color[2], color[3], color[4]
	end
	local function SetColor(info, r, g, b, a)
		cap.db.profile[info[#info]] = {r, g, b, a}
		cap.UpdateProfile()
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

	local anchorPointValues = {
		TOPLEFT = L.TOPLEFT,
		TOP = L.TOP,
		TOPRIGHT = L.TOPRIGHT,
		LEFT = L.left,
		CENTER = L.center,
		RIGHT = L.right,
		BOTTOMLEFT = L.BOTTOMLEFT,
		BOTTOM = L.BOTTOM,
		BOTTOMRIGHT = L.BOTTOMRIGHT,
	}

	local barClickOptions = {
		NONE = L.none,
		SAY = L.sayChat,
		INSTANCE_CHAT = L.raidChat,
	}
	local function SetBarClickOption(info, value)
		cap.db.profile[info[#info]] = value
		cap.UpdateBarClickState()
	end

	local acOptions = {
		name = "Capping",
		type = "group",
		childGroups = "tab",
		get = function(info)
			return cap.db.profile[info[#info]]
		end,
		set = function(info, value)
			cap.db.profile[info[#info]] = value
			cap.UpdateProfile()
		end,
		args = {
			introduction = {
				type = "description",
				name = L.introduction,
				order = 0,
				fontSize = "small",
				width = "full",
			},
			test = {
				type = "execute",
				name = L.test,
				order = 0.2,
				width = 1.5,
				func = function()
					cap:Test(L)
				end,
			},
			lock = {
				type = "toggle",
				name = L.lock,
				desc = L.lockDesc,
				order = 0.4,
				width = 1.5,
			},
			general = {
				name = L.general,
				order = 1,
				type = "group",
				args = {
					spacing = {
						type = "range",
						name = L.spacing,
						desc = L.spacingDesc,
						order = 1,
						min = 0,
						max = 20,
						step = 1,
						width = 1,
					},
					fill = {
						type = "toggle",
						name = L.fill,
						desc = L.fillDesc,
						order = 2,
						width = 1,
					},
					barTexture = {
						type = "select",
						name = L.texture,
						order = 3,
						width = 2,
						values = LibSharedMedia:List(STATUSBAR),
						itemControl = "DDI-Statusbar",
						get = function()
							for i, v in next, LibSharedMedia:List(STATUSBAR) do
								if v == cap.db.profile.barTexture then return i end
							end
						end,
						set = function(_, value)
							local list = LibSharedMedia:List(STATUSBAR)
							cap.db.profile.barTexture = list[value]
							cap.UpdateProfile()
						end,
					},
					borderSpacer = {
						type = "description",
						name = "\n\n",
						order = 4,
						width = "full",
					},
					borderHeader = {
						type = "header",
						name = L.border,
						order = 5,
					},
					borderName = {
						type = "select",
						name = L.borderName,
						order = 6,
						width = 1.5,
						values = LibSharedMedia:List(BORDER),
						get = function()
							for i, v in next, LibSharedMedia:List(BORDER) do
								if v == cap.db.profile.borderName then return i end
							end
						end,
						set = function(_, value)
							local list = LibSharedMedia:List(BORDER)
							cap.db.profile.borderName = list[value]
							cap.UpdateProfile()
						end,
					},
					borderColor = {
						type = "color",
						name = L.borderColor,
						order = 7,
						hasAlpha = true,
						width = 1.5,
						get = GetColor,
						set = SetColor,
						disabled = IsBorderSetToNone,
					},
					borderSize = {
						type = "range",
						name = L.borderSize,
						order = 8,
						min = 1,
						max = 32,
						step = 1,
						width = 1.5,
						disabled = IsBorderSetToNone,
					},
					borderOffset = {
						type = "range",
						name = L.borderOffset,
						order = 9,
						min = 0,
						max = 32,
						step = 1,
						width = 1.5,
						disabled = IsBorderSetToNone,
					},
					backgroundSpacer = {
						type = "description",
						name = "\n\n",
						order = 10,
						width = "full",
					},
					backgroundHeader = {
						type = "header",
						name = L.background,
						order = 11,
					},
					backgroundName = {
						type = "select",
						name = L.background,
						order = 12,
						width = 1.5,
						values = LibSharedMedia:List(BACKGROUND),
						get = function()
							for i, v in next, LibSharedMedia:List(BACKGROUND) do
								if v == cap.db.profile.backgroundName then return i end
							end
						end,
						set = function(_, value)
							local list = LibSharedMedia:List(BACKGROUND)
							cap.db.profile.backgroundName = list[value]
							cap.UpdateProfile()
						end,
					},
					backgroundColor = {
						type = "color",
						name = L.backgroundColor,
						order = 13,
						hasAlpha = true,
						width = 1.5,
						get = GetColor,
						set = SetColor,
						disabled = IsBackgroundSetToNone,
					},
					resetSpacer = {
						type = "description",
						name = "\n\n",
						order = 14,
						width = "full",
					},
					resetHeader = {
						type = "header",
						name = "",
						order = 15,
					},
					reset = {
						type = "execute",
						name = L.reset,
						desc = L.resetDesc,
						order = 16,
						func = function()
							cap.db.profile.spacing = defaultProfile.spacing
							cap.db.profile.fill = defaultProfile.fill
							cap.db.profile.barTexture = defaultProfile.barTexture
							cap.db.profile.borderName = defaultProfile.borderName
							cap.db.profile.borderColor = CopyTable(defaultProfile.borderColor)
							cap.db.profile.borderSize = defaultProfile.borderSize
							cap.db.profile.borderOffset = defaultProfile.borderOffset
							cap.db.profile.backgroundName = defaultProfile.backgroundName
							cap.db.profile.backgroundColor = CopyTable(defaultProfile.backgroundColor)
							cap.UpdateProfile()
						end,
					},
				},
			},
			text = {
				name = L.text,
				order = 2,
				type = "group",
				args = {
					font = {
						type = "select",
						name = L.font,
						order = 1,
						width = 1,
						values = LibSharedMedia:List(FONT),
						itemControl = "DDI-Font",
						get = function()
							for i, v in next, LibSharedMedia:List(FONT) do
								if v == cap.db.profile.font then return i end
							end
						end,
						set = function(_, value)
							local list = LibSharedMedia:List(FONT)
							cap.db.profile.font = list[value]
							cap.UpdateProfile()
						end,
					},
					outline = {
						type = "select",
						name = L.outline,
						order = 2,
						width = 1,
						values = {
							NONE = L.none,
							OUTLINE = L.thin,
							THICKOUTLINE = L.thick,
						},
					},
					monochrome = {
						type = "toggle",
						name = L.monochrome,
						desc = L.monochromeDesc,
						order = 3,
						width = 1,
					},
					textSpacer = {
						type = "description",
						name = "\n\n",
						order = 4,
						width = "full",
					},
					textHeader = {
						type = "header",
						name = L.text,
						order = 5,
					},
					text = {
						type = "toggle",
						name = L.text,
						desc = L.textDesc,
						order = 6,
						width = 1.5,
					},
					alignText = {
						type = "select",
						name = L.alignText,
						order = 7,
						width = 1.5,
						values = {
							LEFT = L.left,
							CENTER = L.center,
							RIGHT = L.right,
						},
						set = function(_, value)
							cap.db.profile.alignText = value
							cap.db.profile.textOffsetX = defaultProfile.textOffsetX
							cap.UpdateProfile()
						end,
						disabled = IsTextDisabled,
					},
					textOffsetX = {
						type = "range",
						name = L.positionX,
						desc = L.positionDesc,
						order = 8,
						width = 1.5,
						min = -100,
						max = 100,
						step = 1,
						disabled = IsTextDisabled,
					},
					textOffsetY = {
						type = "range",
						name = L.positionY,
						desc = L.positionDesc,
						order = 9,
						width = 1.5,
						min = -100,
						max = 100,
						step = 1,
						disabled = IsTextDisabled,
					},
					timeSpacer = {
						type = "description",
						name = "\n\n",
						order = 10,
						width = "full",
					},
					timeHeader = {
						type = "header",
						name = L.time,
						order = 11,
					},
					timeText = {
						type = "toggle",
						name = L.time,
						desc = L.timeDesc,
						order = 12,
						width = 1.5,
					},
					alignTime = {
						type = "select",
						name = L.alignTime,
						order = 13,
						width = 1.5,
						values = {
							LEFT = L.left,
							CENTER = L.center,
							RIGHT = L.right,
						},
						set = function(_, value)
							cap.db.profile.alignTime = value
							cap.db.profile.timeOffsetX = defaultProfile.timeOffsetX
							cap.UpdateProfile()
						end,
						disabled = IsTimeDisabled,
					},
					timeOffsetX = {
						type = "range",
						name = L.positionX,
						desc = L.positionDesc,
						order = 14,
						width = 1.5,
						min = -100,
						max = 100,
						step = 1,
						disabled = IsTimeDisabled,
					},
					timeOffsetY = {
						type = "range",
						name = L.positionY,
						desc = L.positionDesc,
						order = 15,
						width = 1.5,
						min = -100,
						max = 100,
						step = 1,
						disabled = IsTimeDisabled,
					},
					timeDecimals = {
						type = "range",
						name = L.cooldownDecimalsThreshold,
						desc = L.cooldownDecimalsThresholdDesc,
						order = 16,
						width = 3,
						min = 0,
						max = 60,
						step = 1,
						disabled = IsTimeDisabled,
					},
					resetSpacer = {
						type = "description",
						name = "\n\n",
						order = 17,
						width = "full",
					},
					resetHeader = {
						type = "header",
						name = "",
						order = 18,
					},
					reset = {
						type = "execute",
						name = L.reset,
						desc = L.resetDesc,
						order = 19,
						func = function()
							cap.db.profile.font = defaultProfile.font
							cap.db.profile.outline = defaultProfile.outline
							cap.db.profile.monochrome = defaultProfile.monochrome
							cap.db.profile.text = defaultProfile.text
							cap.db.profile.alignText = defaultProfile.alignText
							cap.db.profile.textOffsetX = defaultProfile.textOffsetX
							cap.db.profile.textOffsetY = defaultProfile.textOffsetY
							cap.db.profile.timeText = defaultProfile.timeText
							cap.db.profile.alignTime = defaultProfile.alignTime
							cap.db.profile.timeOffsetX = defaultProfile.timeOffsetX
							cap.db.profile.timeOffsetY = defaultProfile.timeOffsetY
							cap.db.profile.timeDecimals = defaultProfile.timeDecimals
							cap.UpdateProfile()
						end,
					},
				},
			},
			icon = {
				name = L.icon,
				order = 3,
				type = "group",
				args = {
					icon = {
						type = "toggle",
						name = L.icon,
						desc = L.iconDesc,
						order = 1,
						width = 1,
					},
					iconKeepAspectRatio = {
						type = "toggle",
						name = L.keepAspectRatio,
						desc = L.keepAspectRatioDesc,
						order = 2,
						width = 1,
						disabled = IsIconDisabled,
					},
					alignIcon = {
						type = "select",
						name = L.iconPosition,
						desc = L.iconPositionDesc,
						order = 3,
						width = 1,
						values = {
							LEFT = L.left,
							RIGHT = L.right,
						},
						disabled = IsIconDisabled,
					},
					iconWidthOffset = {
						type = "range",
						name = L.iconWidthOffset,
						order = 4,
						width = 1.5,
						min = -50,
						max = 50,
						step = 1,
						disabled = IsIconDisabled,
					},
					iconZoom = {
						type = "range",
						name = L.zoom,
						desc = L.zoomDesc,
						order = 5,
						width = 1.5,
						min = 0,
						max = 0.5,
						step = 0.01,
						isPercent = true,
						disabled = IsIconDisabled,
					},
					detachedIcon = {
						type = "toggle",
						name = L.detachedIcon,
						order = 6,
						width = 1.5,
						disabled = IsIconDisabled,
					},
					iconOffset = {
						type = "range",
						name = L.iconOffset,
						desc = L.positionDesc,
						order = 7,
						width = 1.5,
						min = 1,
						max = 100,
						step = 1,
						disabled = IsDetachedIconDisabled,
					},
					resetSpacer = {
						type = "description",
						name = "\n\n",
						order = 8,
						width = "full",
					},
					resetHeader = {
						type = "header",
						name = "",
						order = 9,
					},
					reset = {
						type = "execute",
						name = L.reset,
						desc = L.resetDesc,
						order = 10,
						func = function()
							cap.db.profile.icon = defaultProfile.icon
							cap.db.profile.iconKeepAspectRatio = defaultProfile.iconKeepAspectRatio
							cap.db.profile.alignIcon = defaultProfile.alignIcon
							cap.db.profile.iconWidthOffset = defaultProfile.iconWidthOffset
							cap.db.profile.iconZoom = defaultProfile.iconZoom
							cap.db.profile.detachedIcon = defaultProfile.detachedIcon
							cap.db.profile.iconOffset = defaultProfile.iconOffset
							cap.UpdateProfile()
						end,
					},
				},
			},
			bars = {
				name = L.bars,
				order = 4,
				type = "group",
				args = {
					growUp = {
						type = "toggle",
						name = L.growUpwards,
						desc = L.growingUpwardsDesc,
						order = 1,
						width = 1.5,
					},
					fontSize = {
						type = "range",
						name = L.fontSize,
						desc = L.fontSizeDesc,
						order = 2,
						width = 1.5,
						softMax = 100,
						max = 200,
						min = 10,
						step = 1,
					},
					sizeSpacer = {
						type = "description",
						name = "\n\n",
						order = 3,
						width = "full",
					},
					sizeHeader = {
						type = "header",
						name = L.size,
						order = 4,
					},
					width = {
						type = "range",
						name = L.width,
						min = cap.minBarWidth,
						max = cap.maxBarWidth,
						step = 1,
						order = 5,
						width = 1,
						disabled = IsCopyCustomAnchorWidthEnabled,
					},
					height = {
						type = "range",
						name = L.height,
						min = cap.minBarHeight,
						max = cap.maxBarHeight,
						step = 1,
						order = 6,
						width = 1,
					},
					barHeightOffset = {
						type = "range",
						name = L.barHeightOffset,
						min = -100,
						max = 0,
						step = 1,
						order = 7,
						width = 1,
						disabled = IsDetachedIconDisabled,
					},
					positionSpacer = {
						type = "description",
						name = "\n\n",
						order = 8,
						width = "full",
					},
					positionHeader = {
						type = "header",
						name = L.positionExact,
						order = 9,
					},
					posx = {
						type = "range",
						name = L.positionX,
						desc = L.positionDesc,
						min = -10000,
						max = 10000,
						softMin = -2048,
						softMax = 2048,
						step = 1,
						order = 10,
						width = 1.5,
						get = function()
							return cap.db.profile.position[3]
						end,
						set = function(_, value)
							cap.db.profile.position[3] = value
							cap.RefixPosition()
						end,
					},
					posy = {
						type = "range",
						name = L.positionY,
						desc = L.positionDesc,
						min = -10000,
						max = 10000,
						softMin = -2048,
						softMax = 2048,
						step = 1,
						order = 11,
						width = 1.5,
						get = function()
							return cap.db.profile.position[4]
						end,
						set = function(_, value)
							cap.db.profile.position[4] = value
							cap.RefixPosition()
						end,
					},
					customAnchorPoint = {
						type = "input",
						get = function()
							return cap.db.profile.position[5]
						end,
						set = function(_, value)
							if value ~= defaultProfile.position[5] then
								cap.db.profile.position[1] = "CENTER"
								cap.db.profile.position[2] = "CENTER"
								cap.db.profile.position[3] = 0
								cap.db.profile.position[4] = 0
								cap.db.profile.position[5] = value
							else
								cap.db.profile.position = CopyTable(defaultProfile.position)
								if cap.db.profile.copyCustomAnchorWidth then
									cap.db.profile.copyCustomAnchorWidth = defaultProfile.copyCustomAnchorWidth
									cap.db.profile.width = defaultProfile.width
								end
							end
							cap.UpdateProfile()
						end,
						validate = function(_, frameName)
							return cap.IsValidFrame(frameName)
						end,
						name = L.customAnchorPoint,
						order = 12,
						width = 1,
					},
					customAnchorPointSource = {
						type = "select",
						get = function()
							return cap.db.profile.position[1]
						end,
						set = function(_, value)
							if cap.IsValidFramePoint(value) then
								cap.db.profile.position[1] = value
								cap.UpdateProfile()
							end
						end,
						values = anchorPointValues,
						name = L.sourcePoint,
						order = 13,
						width = 1,
						disabled = IsAnchorPointDefault,
					},
					customAnchorPointDestination = {
						type = "select",
						get = function()
							return cap.db.profile.position[2]
						end,
						set = function(_, value)
							if cap.IsValidFramePoint(value) then
								cap.db.profile.position[2] = value
								cap.UpdateProfile()
							end
						end,
						values = anchorPointValues,
						name = L.destinationPoint,
						order = 14,
						width = 1,
						disabled = IsAnchorPointDefault,
					},
					copyCustomAnchorWidth = {
						type = "toggle",
						name = L.copyCustomAnchorWidth,
						desc = L.copyCustomAnchorWidthDesc,
						order = 15,
						width = "full",
						set = function(_, value)
							if not value then
								cap.db.profile.width = defaultProfile.width
							end
							cap.db.profile.copyCustomAnchorWidth = value
							cap.UpdateProfile()
						end,
						disabled = IsAnchorPointDefault,
					},
					resetSpacer = {
						type = "description",
						name = "\n\n",
						order = 16,
						width = "full",
					},
					resetHeader = {
						type = "header",
						name = "",
						order = 17,
					},
					reset = {
						type = "execute",
						name = L.reset,
						desc = L.resetDesc,
						order = 18,
						func = function()
							cap.db.profile.growUp = defaultProfile.growUp
							cap.db.profile.fontSize = defaultProfile.fontSize
							cap.db.profile.width = defaultProfile.width
							cap.db.profile.height = defaultProfile.height
							cap.db.profile.barHeightOffset = defaultProfile.barHeightOffset
							cap.db.profile.position = CopyTable(defaultProfile.position)
							cap.db.profile.copyCustomAnchorWidth = defaultProfile.copyCustomAnchorWidth
							cap.UpdateProfile()
						end,
					},
				},
			},
			colors = {
				name = L.colors,
				order = 5,
				type = "group",
				args = {
					colorText = {
						name = L.textColor,
						type = "color",
						hasAlpha = true,
						order = 1,
						width = 1.5,
						get = GetColor,
						set = SetColor,
					},
					colorTextShadow = {
						name = L.textShadow,
						type = "color",
						hasAlpha = true,
						order = 2,
						width = 1.5,
						get = GetColor,
						set = SetColor,
					},
					colorAlliance = {
						name = L.allianceBars,
						type = "color",
						hasAlpha = true,
						order = 3,
						width = 1.5,
						get = GetColor,
						set = SetColor,
					},
					colorHorde = {
						name = L.hordeBars,
						type = "color",
						hasAlpha = true,
						order = 4,
						width = 1.5,
						get = GetColor,
						set = SetColor,
					},
					colorQueue = {
						name = L.queueBars,
						type = "color",
						hasAlpha = true,
						order = 5,
						width = 1.5,
						get = GetColor,
						set = SetColor,
					},
					colorOther = {
						name = L.otherBars,
						type = "color",
						hasAlpha = true,
						order = 6,
						width = 1.5,
						get = GetColor,
						set = SetColor,
					},
					resetSpacer = {
						type = "description",
						name = "\n\n",
						order = 7,
						width = "full",
					},
					resetHeader = {
						type = "header",
						name = "",
						order = 8,
					},
					reset = {
						type = "execute",
						name = L.reset,
						desc = L.resetDesc,
						order = 9,
						func = function()
							cap.db.profile.colorText = CopyTable(defaultProfile.colorText)
							cap.db.profile.colorTextShadow = CopyTable(defaultProfile.colorTextShadow)
							cap.db.profile.colorAlliance = CopyTable(defaultProfile.colorAlliance)
							cap.db.profile.colorHorde = CopyTable(defaultProfile.colorHorde)
							cap.db.profile.colorQueue = CopyTable(defaultProfile.colorQueue)
							cap.db.profile.colorOther = CopyTable(defaultProfile.colorOther)
							cap.UpdateProfile()
						end,
					},
				},
			},
			features = {
				name = L.features,
				order = 6,
				type = "group",
				args = {
					queueBars = {
						type = "toggle",
						name = L.queueBars,
						desc = L.queueBarsDesc,
						order = 1,
					},
					useMasterForQueue = {
						type = "toggle",
						name = L.loudQueue,
						desc = L.loudQueueDesc,
						order = 2,
					},
					clickBarsHeader = {
						type = "header",
						name = L.clickableBars,
						order = 3,
					},
					barOnShift = {
						type = "select",
						name = L.shiftClick,
						desc = L.barClickDesc,
						order = 4,
						values = barClickOptions,
						set = SetBarClickOption,
					},
					barOnControl = {
						type = "select",
						name = L.controlClick,
						desc = L.barClickDesc,
						order = 5,
						values = barClickOptions,
						set = SetBarClickOption,
					},
					barOnAlt = {
						type = "select",
						name = L.altClick,
						desc = L.barClickDesc,
						order = 6,
						values = barClickOptions,
						set = SetBarClickOption,
					},
					autoTurnInHeader = {
						type = "header",
						name = "",
						order = 7,
					},
					autoTurnIn = {
						type = "toggle",
						name = L.autoTurnIn,
						desc = L.autoTurnInDesc,
						order = 8,
						width = "full",
					},
					resetSpacer = {
						type = "description",
						name = "\n\n",
						order = 9,
						width = "full",
					},
					resetHeader = {
						type = "header",
						name = "",
						order = 10,
					},
					reset = {
						type = "execute",
						name = L.reset,
						desc = L.resetDesc,
						order = 11,
						func = function()
							cap.db.profile.queueBars = defaultProfile.queueBars
							cap.db.profile.useMasterForQueue = defaultProfile.useMasterForQueue
							cap.db.profile.barOnShift = defaultProfile.barOnShift
							cap.db.profile.barOnControl = defaultProfile.barOnControl
							cap.db.profile.barOnAlt = defaultProfile.barOnAlt
							cap.db.profile.autoTurnIn = defaultProfile.autoTurnIn
							cap.UpdateProfile()
						end,
					},
				},
			},
			profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(cap.db),
		},
	}
	acOptions.args.profiles.order = 7
	acr:RegisterOptionsTable("Capping", acOptions, true)
end

--------------------------------------------------------------------------------
-- GUI
--

do
	local configFrame, currentlyOpenContainer = nil, nil
	local version = C_AddOns.GetAddOnMetadata("Capping", "Version")

	do
		local pendingRefresh = nil
		local function refreshConfig()
			pendingRefresh = nil
			if currentlyOpenContainer then
				acd:Open("Capping", currentlyOpenContainer)
			end
		end
		local tbl = {}
		acr.RegisterCallback(tbl, "ConfigTableChange", function(_, appName)
			if appName == "Capping" and currentlyOpenContainer then
				if not pendingRefresh then
					pendingRefresh = true
					C_Timer.After(0, refreshConfig)
				end
			end
		end)
	end

	function cap.OpenOptions()
		if not configFrame then
			local f = AceGUI:Create("Frame")
			configFrame = f
			f:SetTitle("Capping")
			if version then
				f:SetStatusText(" " .. version)
			end
			f:SetWidth(640)
			f:SetHeight(660)
			f:EnableResize(false)
			f:SetLayout("Fill")
			f:SetCallback("OnClose", function(widget)
				currentlyOpenContainer = nil
				configFrame = nil
				widget:ReleaseChildren()
				AceGUI:Release(widget)
			end)

			local container = AceGUI:Create("SimpleGroup")
			container:SetFullWidth(true)
			container:SetFullHeight(true)
			container:SetAutoAdjustHeight(false)
			f:AddChild(container)

			currentlyOpenContainer = container
			acd:Open("Capping", container)
			f:Show()
		end
	end
end

