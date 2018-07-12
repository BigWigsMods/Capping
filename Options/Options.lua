
local acr = LibStub("AceConfigRegistry-3.0")
local acd = LibStub("AceConfigDialog-3.0")
local media = LibStub("LibSharedMedia-3.0")
local lit = LegionInvasionTimer
local L
do
	local _, mod = ...
	L = mod.L
end

local function updateFlags()
	local flags = nil
	if lit.db.monochrome and lit.db.outline ~= "NONE" then
		flags = "MONOCHROME," .. lit.db.outline
	elseif lit.db.monochrome then
		flags = "MONOCHROME"
	elseif lit.db.outline ~= "NONE" then
		flags = lit.db.outline
	end
	return flags
end

local function disabled()
	return lit.db.mode == 2
end

local acOptions = {
	type = "group",
	name = "Capping",
	get = function(info)
		return lit.db[info[#info]]
	end,
	set = function(info, value)
		lit.db[info[#info]] = value
	end,
	args = {
		lock = {
			type = "toggle",
			name = L.lock,
			order = 1,
			set = function(info, value)
				lit.db.lock = value
				if value then
					lit:EnableMouse(false)
					lit.bg:Hide()
					lit.header:Hide()
				else
					lit:EnableMouse(true)
					lit.bg:Show()
					lit.header:Show()
				end
			end,
			disabled = disabled,
		},
		icon = {
			type = "toggle",
			name = L.barIcon,
			order = 2,
			set = function(info, value)
				lit.db.icon = value
				for bar in next, lit.bars do
					bar:SetIcon(value and 236292) -- Interface\\Icons\\Ability_Warlock_DemonicEmpowerment
				end
			end,
			disabled = disabled,
		},
		timeText = {
			type = "toggle",
			name = L.showTime,
			order = 3,
			set = function(info, value)
				lit.db.timeText = value
				for bar in next, lit.bars do
					bar:SetTimeVisibility(value)
				end
			end,
			disabled = disabled,
		},
		fill = {
			type = "toggle",
			name = L.fillBar,
			order = 4,
			set = function(info, value)
				lit.db.fill = value
				for bar in next, lit.bars do
					bar:SetFill(value)
				end
			end,
			disabled = disabled,
		},
		font = {
			type = "select",
			name = L.font,
			order = 5,
			values = media:List("font"),
			itemControl = "DDI-Font",
			get = function()
				for i, v in next, media:List("font") do
					if v == lit.db.font then return i end
				end
			end,
			set = function(info, value)
				local list = media:List("font")
				local font = list[value]
				lit.db.font = font
				for bar in next, lit.bars do
					bar.candyBarLabel:SetFont(media:Fetch("font", font), lit.db.fontSize, updateFlags())
					bar.candyBarDuration:SetFont(media:Fetch("font", font), lit.db.fontSize, updateFlags())
				end
			end,
			disabled = disabled,
		},
		fontSize = {
			type = "range",
			name = L.fontSize,
			order = 6,
			max = 200,
			min = 1,
			step = 1,
			set = function(info, value)
				lit.db.fontSize = value
				for bar in next, lit.bars do
					bar.candyBarLabel:SetFont(media:Fetch("font", lit.db.font), value, updateFlags())
					bar.candyBarDuration:SetFont(media:Fetch("font", lit.db.font), value, updateFlags())
				end
			end,
			disabled = disabled,
		},
		monochrome = {
			type = "toggle",
			name = L.monochrome,
			order = 7,
			set = function(info, value)
				lit.db.monochrome = value
				for bar in next, lit.bars do
					bar.candyBarLabel:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
					bar.candyBarDuration:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
				end
			end,
			disabled = disabled,
		},
		outline = {
			type = "select",
			name = L.outline,
			order = 8,
			values = {
				NONE = L.none,
				OUTLINE = L.thin,
				THICKOUTLINE = L.thick,
			},
			set = function(info, value)
				lit.db.outline = value
				for bar in next, lit.bars do
					bar.candyBarLabel:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
					bar.candyBarDuration:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
				end
			end,
			disabled = disabled,
		},
		barTexture = {
			type = "select",
			name = L.texture,
			order = 9,
			values = media:List("statusbar"),
			itemControl = "DDI-Statusbar",
			width = "full",
			get = function()
				for i, v in next, media:List("statusbar") do
					if v == lit.db.barTexture then return i end
				end
			end,
			set = function(info, value)
				local list = media:List("statusbar")
				local texture = list[value]
				lit.db.barTexture = texture
				for bar in next, lit.bars do
					bar:SetTexture(media:Fetch("statusbar", texture))
				end
			end,
			disabled = disabled,
		},
		width = {
			type = "range",
			name = L.barWidth,
			order = 10,
			max = 2000,
			min = 10,
			step = 1,
			set = function(info, value)
				lit.db.width = value
				for bar in next, lit.bars do
					bar:SetWidth(value)
				end
			end,
			disabled = disabled,
		},
		height = {
			type = "range",
			name = L.barHeight,
			order = 11,
			max = 100,
			min = 5,
			step = 1,
			set = function(info, value)
				lit.db.height = value
				for bar in next, lit.bars do
					bar:SetHeight(value)
				end
			end,
			disabled = disabled,
		},
		alignIcon = {
			type = "select",
			name = L.alignIcon,
			order = 12,
			values = {
				LEFT = L.left,
				RIGHT = L.right,
			},
			set = function(info, value)
				lit.db.alignIcon = value
				for bar in next, lit.bars do
					bar:SetIconPosition(value)
				end
			end,
			disabled = function() return disabled() or not lit.db.icon end,
		},
		spacing = {
			type = "range",
			name = L.barSpacing,
			order = 13,
			max = 100,
			min = 0,
			step = 1,
			set = function(info, value)
				lit.db.spacing = value
				lit.RearrangeBars()
			end,
			disabled = disabled,
		},
		alignZone = {
			type = "select",
			name = L.alignZone,
			order = 14,
			values = {
				LEFT = L.left,
				CENTER = L.center,
				RIGHT = L.right,
			},
			set = function(info, value)
				lit.db.alignZone = value
				for bar in next, lit.bars do
					bar.candyBarLabel:SetJustifyH(value)
				end
			end,
			disabled = disabled,
		},
		alignTime = {
			type = "select",
			name = L.alignTime,
			order = 15,
			values = {
				LEFT = L.left,
				CENTER = L.center,
				RIGHT = L.right,
			},
			set = function(info, value)
				lit.db.alignTime = value
				for bar in next, lit.bars do
					bar.candyBarDuration:SetJustifyH(value)
				end
			end,
			disabled = disabled,
		},
		growUp = {
			type = "toggle",
			name = L.growUpwards,
			order = 16,
			set = function(info, value)
				lit.db.growUp = value
				lit.RearrangeBars()
			end,
			disabled = disabled,
		},
		colorText = {
			name = L.textColor,
			type = "color",
			hasAlpha = true,
			order = 17,
			get = function()
				return unpack(lit.db.colorText)
			end,
			set = function(info, r, g, b, a)
				lit.db.colorText = {r, g, b, a}
				for bar in next, lit.bars do
					bar:SetTextColor(r, g, b, a)
				end
			end,
			disabled = disabled,
		},
		colorComplete = {
			name = L.completedBar,
			type = "color",
			hasAlpha = true,
			order = 18,
			get = function()
				return unpack(lit.db.colorComplete)
			end,
			set = function(info, r, g, b, a)
				lit.db.colorComplete = {r, g, b, a}
				for bar in next, lit.bars do
					if bar:Get("LegionInvasionTimer:complete") == 1 then
						bar:SetColor(r, g, b, a)
					end
				end
			end,
			disabled = disabled,
		},
		colorIncomplete = {
			name = L.incompleteBar,
			type = "color",
			hasAlpha = true,
			order = 19,
			get = function()
				return unpack(lit.db.colorIncomplete)
			end,
			set = function(info, r, g, b, a)
				lit.db.colorIncomplete = {r, g, b, a}
				for bar in next, lit.bars do
					if bar:Get("LegionInvasionTimer:complete") == 0 then
						bar:SetColor(r, g, b, a)
					end
				end
			end,
			disabled = disabled,
		},
		colorNext = {
			name = L.nextBar,
			type = "color",
			hasAlpha = true,
			order = 20,
			get = function()
				return unpack(lit.db.colorNext)
			end,
			set = function(info, r, g, b, a)
				lit.db.colorNext = {r, g, b, a}
				for bar in next, lit.bars do
					local tag = bar:Get("LegionInvasionTimer:complete")
					if tag ~= 0 and tag ~= 1 then
						bar:SetColor(r, g, b, a)
					end
				end
			end,
			disabled = disabled,
		},
		colorBarBackground = {
			name = L.barBackground,
			type = "color",
			hasAlpha = true,
			order = 21,
			get = function()
				return unpack(lit.db.colorBarBackground)
			end,
			set = function(info, r, g, b, a)
				lit.db.colorBarBackground = {r, g, b, a}
				for bar in next, lit.bars do
					if bar then
						bar.candyBarBackground:SetVertexColor(r, g, b, a)
					end
				end
			end,
			disabled = disabled,
		},
		tooltipHeader = {
			type = "header",
			name = L.tooltipHeader,
			order = 22,
		},
		tooltip12hr = {
			type = "toggle",
			name = L.tooltip12hr,
			order = 23,
		},
		tooltipHideAchiev = {
			type = "toggle",
			name = L.tooltipHideAchiev,
			order = 24,
		},
		tooltipHideNethershard = {
			type = "toggle",
			name = L.hide:format((GetCurrencyInfo(1226))),
			order = 25,
		},
		tooltipHideWarSupplies = {
			type = "toggle",
			name = L.hide:format((GetCurrencyInfo(1342))),
			order = 26,
		},
		miscSeparator = {
			type = "header",
			name = "",
			order = 27,
		},
		hideInRaid = {
			type = "toggle",
			name = L.hideInRaid,
			order = 28,
			disabled = function() 
				return lit.db.mode == 2 or lit.db.mode == 3
			end,
		},
		mode = {
			type = "select",
			name = L.mode,
			order = 29,
			values = {
				[1] = L.modeBar,
				[2] = L.modeBroker,
				[3] = L.modeBarOnMap,
			},
			set = function(info, value)
				lit.db.mode = value
				if value == 2 then
					lit.db.lock = true
				end
				if value == 3 then
					lit.db.hideInRaid = nil
				end
				ReloadUI()
			end,
		},
	},
}

acr:RegisterOptionsTable(acOptions.name, acOptions, true)
acd:SetDefaultSize(acOptions.name, 400, 640)

