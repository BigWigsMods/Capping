
local acr = LibStub("AceConfigRegistry-3.0")
local acd = LibStub("AceConfigDialog-3.0")
local media = LibStub("LibSharedMedia-3.0")
local cap = CappingFrame
local L
do
	local _, mod = ...
	L = mod.L
end

local function updateFlags()
	local flags = nil
	if cap.db.monochrome and cap.db.outline ~= "NONE" then
		flags = "MONOCHROME," .. cap.db.outline
	elseif cap.db.monochrome then
		flags = "MONOCHROME"
	elseif cap.db.outline ~= "NONE" then
		flags = cap.db.outline
	end
	return flags
end

local acOptions = {
	type = "group",
	name = "Capping",
	get = function(info)
		return cap.db[info[#info]]
	end,
	set = function(info, value)
		cap.db[info[#info]] = value
	end,
	args = {
		test = {
			type = "execute",
			name = "TEST", -- XXX
			order = 0.1,
			width = "full",
			func = function()
				cap:Test()
			end,
		},
		lock = {
			type = "toggle",
			name = L.lock,
			order = 1,
			set = function(info, value)
				cap.db.lock = value
				if value then
					cap:EnableMouse(false)
					cap.bg:Hide()
					cap.header:Hide()
				else
					cap:EnableMouse(true)
					cap.bg:Show()
					cap.header:Show()
				end
			end,
		},
		icon = {
			type = "toggle",
			name = L.barIcon,
			order = 2,
			set = function(info, value)
				cap.db.icon = value
				for bar in next, cap.bars do
					if value then
						bar:SetIcon(bar:Get("capping:iconoptionrestore") or 236396) -- Interface/Icons/Achievement_BG_winWSG
					else
						bar:Set("capping:iconoptionrestore", bar:GetIcon())
						bar:SetIcon(nil)
					end
				end
			end,
		},
		timeText = {
			type = "toggle",
			name = L.showTime,
			order = 3,
			set = function(info, value)
				cap.db.timeText = value
				for bar in next, cap.bars do
					bar:SetTimeVisibility(value)
				end
			end,
		},
		fill = {
			type = "toggle",
			name = L.fillBar,
			order = 4,
			set = function(info, value)
				cap.db.fill = value
				for bar in next, cap.bars do
					bar:SetFill(value)
				end
			end,
		},
		font = {
			type = "select",
			name = L.font,
			order = 5,
			values = media:List("font"),
			itemControl = "DDI-Font",
			get = function()
				for i, v in next, media:List("font") do
					if v == cap.db.font then return i end
				end
			end,
			set = function(info, value)
				local list = media:List("font")
				local font = list[value]
				cap.db.font = font
				for bar in next, cap.bars do
					bar.candyBarLabel:SetFont(media:Fetch("font", font), cap.db.fontSize, updateFlags())
					bar.candyBarDuration:SetFont(media:Fetch("font", font), cap.db.fontSize, updateFlags())
				end
			end,
		},
		fontSize = {
			type = "range",
			name = L.fontSize,
			order = 6,
			max = 200,
			min = 1,
			step = 1,
			set = function(info, value)
				cap.db.fontSize = value
				for bar in next, cap.bars do
					bar.candyBarLabel:SetFont(media:Fetch("font", cap.db.font), value, updateFlags())
					bar.candyBarDuration:SetFont(media:Fetch("font", cap.db.font), value, updateFlags())
				end
			end,
		},
		monochrome = {
			type = "toggle",
			name = L.monochrome,
			order = 7,
			set = function(info, value)
				cap.db.monochrome = value
				for bar in next, cap.bars do
					bar.candyBarLabel:SetFont(media:Fetch("font", cap.db.font), cap.db.fontSize, updateFlags())
					bar.candyBarDuration:SetFont(media:Fetch("font", cap.db.font), cap.db.fontSize, updateFlags())
				end
			end,
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
				cap.db.outline = value
				for bar in next, cap.bars do
					bar.candyBarLabel:SetFont(media:Fetch("font", cap.db.font), cap.db.fontSize, updateFlags())
					bar.candyBarDuration:SetFont(media:Fetch("font", cap.db.font), cap.db.fontSize, updateFlags())
				end
			end,
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
					if v == cap.db.barTexture then return i end
				end
			end,
			set = function(info, value)
				local list = media:List("statusbar")
				local texture = list[value]
				cap.db.barTexture = texture
				for bar in next, cap.bars do
					bar:SetTexture(media:Fetch("statusbar", texture))
				end
			end,
		},
		width = {
			type = "range",
			name = L.barWidth,
			order = 10,
			max = 2000,
			min = 10,
			step = 1,
			set = function(info, value)
				cap.db.width = value
				for bar in next, cap.bars do
					bar:SetWidth(value)
				end
			end,
		},
		height = {
			type = "range",
			name = L.barHeight,
			order = 11,
			max = 100,
			min = 5,
			step = 1,
			set = function(info, value)
				cap.db.height = value
				for bar in next, cap.bars do
					bar:SetHeight(value)
				end
			end,
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
				cap.db.alignIcon = value
				for bar in next, cap.bars do
					bar:SetIconPosition(value)
				end
			end,
			disabled = function() return not cap.db.icon end,
		},
		spacing = {
			type = "range",
			name = L.barSpacing,
			order = 13,
			max = 100,
			min = 0,
			step = 1,
			set = function(info, value)
				cap.db.spacing = value
				cap.RearrangeBars()
			end,
		},
		alignText = {
			type = "select",
			name = "Align Text", -- XXX
			order = 14,
			values = {
				LEFT = L.left,
				CENTER = L.center,
				RIGHT = L.right,
			},
			set = function(info, value)
				cap.db.alignText = value
				for bar in next, cap.bars do
					bar.candyBarLabel:SetJustifyH(value)
				end
			end,
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
				cap.db.alignTime = value
				for bar in next, cap.bars do
					bar.candyBarDuration:SetJustifyH(value)
				end
			end,
		},
		growUp = {
			type = "toggle",
			name = L.growUpwards,
			order = 16,
			set = function(info, value)
				cap.db.growUp = value
				cap.RearrangeBars()
			end,
		},
		colorText = {
			name = L.textColor,
			type = "color",
			hasAlpha = true,
			order = 17,
			get = function()
				return unpack(cap.db.colorText)
			end,
			set = function(info, r, g, b, a)
				cap.db.colorText = {r, g, b, a}
				for bar in next, cap.bars do
					bar:SetTextColor(r, g, b, a)
				end
			end,
		},
		colorAlliance = {
			name = "Alliance", -- XXX
			type = "color",
			hasAlpha = true,
			order = 18,
			get = function()
				return unpack(cap.db.colorAlliance)
			end,
			set = function(info, r, g, b, a)
				cap.db.colorAlliance = {r, g, b, a}
				for bar in next, cap.bars do
					if bar:Get("capping:colorid") == "colorAlliance" then
						bar:SetColor(r, g, b, a)
					end
				end
			end,
		},
		colorHorde = {
			name = "Horde", -- XXX
			type = "color",
			hasAlpha = true,
			order = 19,
			get = function()
				return unpack(cap.db.colorHorde)
			end,
			set = function(info, r, g, b, a)
				cap.db.colorHorde = {r, g, b, a}
				for bar in next, cap.bars do
					if bar:Get("capping:colorid") == "colorHorde" then
						bar:SetColor(r, g, b, a)
					end
				end
			end,
		},
		colorQueueWait = {
			name = "Queue", -- XXX
			type = "color",
			hasAlpha = true,
			order = 20,
			get = function()
				return unpack(cap.db.colorQueueWait)
			end,
			set = function(info, r, g, b, a)
				cap.db.colorQueueWait = {r, g, b, a}
				for bar in next, cap.bars do
					if bar:Get("capping:colorid") == "colorQueueWait" then
						bar:SetColor(r, g, b, a)
					end
				end
			end,
		},
		colorQueueReady = {
			name = "Queue Ready", -- XXX
			type = "color",
			hasAlpha = true,
			order = 20.1,
			get = function()
				return unpack(cap.db.colorQueueReady)
			end,
			set = function(info, r, g, b, a)
				cap.db.colorQueueReady = {r, g, b, a}
				for bar in next, cap.bars do
					if bar:Get("capping:colorid") == "colorQueueReady" then
						bar:SetColor(r, g, b, a)
					end
				end
			end,
		},
		colorBarBackground = {
			name = L.barBackground,
			type = "color",
			hasAlpha = true,
			order = 21,
			get = function()
				return unpack(cap.db.colorBarBackground)
			end,
			set = function(info, r, g, b, a)
				cap.db.colorBarBackground = {r, g, b, a}
				for bar in next, cap.bars do
					if bar then
						bar.candyBarBackground:SetVertexColor(r, g, b, a)
					end
				end
			end,
		},
		--tooltipHeader = {
		--	type = "header",
		--	name = L.tooltipHeader,
		--	order = 22,
		--},
		--tooltip12hr = {
		--	type = "toggle",
		--	name = L.tooltip12hr,
		--	order = 23,
		--},
		--tooltipHideAchiev = {
		--	type = "toggle",
		--	name = L.tooltipHideAchiev,
		--	order = 24,
		--},
		--tooltipHideNethershard = {
		--	type = "toggle",
		--	name = L.hide:format((GetCurrencyInfo(1226))),
		--	order = 25,
		--},
		--tooltipHideWarSupplies = {
		--	type = "toggle",
		--	name = L.hide:format((GetCurrencyInfo(1342))),
		--	order = 26,
		--},
		--miscSeparator = {
		--	type = "header",
		--	name = "",
		--	order = 27,
		--},
		--hideInRaid = {
		--	type = "toggle",
		--	name = L.hideInRaid,
		--	order = 28,
		--	disabled = function() 
		--		return cap.db.mode == 2 or cap.db.mode == 3
		--	end,
		--},
		--mode = {
		--	type = "select",
		--	name = L.mode,
		--	order = 29,
		--	values = {
		--		[1] = L.modeBar,
		--		[2] = L.modeBroker,
		--		[3] = L.modeBarOnMap,
		--	},
		--	set = function(info, value)
		--		cap.db.mode = value
		--		if value == 2 then
		--			cap.db.lock = true
		--		end
		--		if value == 3 then
		--			cap.db.hideInRaid = nil
		--		end
		--		ReloadUI()
		--	end,
		--},
	},
}

acr:RegisterOptionsTable(acOptions.name, acOptions, true)
acd:SetDefaultSize(acOptions.name, 400, 640)

