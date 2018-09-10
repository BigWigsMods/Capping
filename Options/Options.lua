
local acr = LibStub("AceConfigRegistry-3.0")
local acd = LibStub("AceConfigDialog-3.0")
local media = LibStub("LibSharedMedia-3.0")
local adbo = LibStub("AceDBOptions-3.0")
local cap = CappingFrame
local L
do
	local _, mod = ...
	L = mod.L
end

local function updateFlags()
	local flags = nil
	if cap.db.profile.monochrome and cap.db.profile.outline ~= "NONE" then
		flags = "MONOCHROME," .. cap.db.profile.outline
	elseif cap.db.profile.monochrome then
		flags = "MONOCHROME"
	elseif cap.db.profile.outline ~= "NONE" then
		flags = cap.db.profile.outline
	end
	return flags
end

local barClickOptions = {
	NONE = L.none,
	SAY = L.sayChat,
	INSTANCE_CHAT = L.raidChat,
}
local barClickSetOptions = function(info, value)
	cap.db.profile[info[#info]] = value
	if cap.db.profile.barOnShift ~= "NONE" or cap.db.profile.barOnControl ~= "NONE" or cap.db.profile.barOnAlt ~= "NONE" then
		for bar in next, cap.bars do
			bar:EnableMouse(true)
		end
	else
		for bar in next, cap.bars do
			bar:EnableMouse(false)
		end
	end
end

local acOptions = {
	name = "Capping",
	type = "group", childGroups = "tab",
	get = function(info)
		return cap.db.profile[info[#info]]
	end,
	set = function(info, value)
		cap.db.profile[info[#info]] = value
	end,
	args = {
		general = {
			name = L.general,
			order = 1, type = "group",
			args = {
				test = {
					type = "execute",
					name = L.test,
					order = 0.1,
					width = 2,
					func = function()
						cap:Test(L)
					end,
				},
				lock = {
					type = "toggle",
					name = L.lock,
					order = 1,
					set = function(_, value)
						cap.db.profile.lock = value
						if value then
							value = false
							cap.bg:Hide()
							cap.header:Hide()
						else
							value = true
							cap.bg:Show()
							cap.header:Show()
						end
						cap:EnableMouse(value)
						cap:SetMovable(value)
					end,
				},
				icon = {
					type = "toggle",
					name = L.barIcon,
					order = 2,
					set = function(_, value)
						cap.db.profile.icon = value
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
					set = function(_, value)
						cap.db.profile.timeText = value
						for bar in next, cap.bars do
							bar:SetTimeVisibility(value)
						end
					end,
				},
				fill = {
					type = "toggle",
					name = L.fillBar,
					order = 4,
					set = function(_, value)
						cap.db.profile.fill = value
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
							if v == cap.db.profile.font then return i end
						end
					end,
					set = function(_, value)
						local list = media:List("font")
						local font = list[value]
						cap.db.profile.font = font
						for bar in next, cap.bars do
							bar.candyBarLabel:SetFont(media:Fetch("font", font), cap.db.profile.fontSize, updateFlags())
							bar.candyBarDuration:SetFont(media:Fetch("font", font), cap.db.profile.fontSize, updateFlags())
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
					set = function(_, value)
						cap.db.profile.fontSize = value
						for bar in next, cap.bars do
							bar.candyBarLabel:SetFont(media:Fetch("font", cap.db.profile.font), value, updateFlags())
							bar.candyBarDuration:SetFont(media:Fetch("font", cap.db.profile.font), value, updateFlags())
						end
					end,
				},
				monochrome = {
					type = "toggle",
					name = L.monochrome,
					order = 7,
					set = function(_, value)
						cap.db.profile.monochrome = value
						for bar in next, cap.bars do
							bar.candyBarLabel:SetFont(media:Fetch("font", cap.db.profile.font), cap.db.profile.fontSize, updateFlags())
							bar.candyBarDuration:SetFont(media:Fetch("font", cap.db.profile.font), cap.db.profile.fontSize, updateFlags())
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
					set = function(_, value)
						cap.db.profile.outline = value
						for bar in next, cap.bars do
							bar.candyBarLabel:SetFont(media:Fetch("font", cap.db.profile.font), cap.db.profile.fontSize, updateFlags())
							bar.candyBarDuration:SetFont(media:Fetch("font", cap.db.profile.font), cap.db.profile.fontSize, updateFlags())
						end
					end,
				},
				barTexture = {
					type = "select",
					name = L.texture,
					order = 9,
					values = media:List("statusbar"),
					itemControl = "DDI-Statusbar",
					width = 2,
					get = function()
						for i, v in next, media:List("statusbar") do
							if v == cap.db.profile.barTexture then return i end
						end
					end,
					set = function(_, value)
						local list = media:List("statusbar")
						local texture = list[value]
						cap.db.profile.barTexture = texture
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
					set = function(_, value)
						cap.db.profile.width = value
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
					set = function(_, value)
						cap.db.profile.height = value
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
					set = function(_, value)
						cap.db.profile.alignIcon = value
						for bar in next, cap.bars do
							bar:SetIconPosition(value)
						end
					end,
					disabled = function() return not cap.db.profile.icon end,
				},
				spacing = {
					type = "range",
					name = L.barSpacing,
					order = 13,
					max = 100,
					min = 0,
					step = 1,
					set = function(_, value)
						cap.db.profile.spacing = value
						cap.RearrangeBars()
					end,
				},
				alignText = {
					type = "select",
					name = L.alignText,
					order = 14,
					values = {
						LEFT = L.left,
						CENTER = L.center,
						RIGHT = L.right,
					},
					set = function(_, value)
						cap.db.profile.alignText = value
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
					set = function(_, value)
						cap.db.profile.alignTime = value
						for bar in next, cap.bars do
							bar.candyBarDuration:SetJustifyH(value)
						end
					end,
				},
				growUp = {
					type = "toggle",
					name = L.growUpwards,
					order = 16,
					width = 2,
					set = function(_, value)
						cap.db.profile.growUp = value
						cap.RearrangeBars()
					end,
				},
				colorText = {
					name = L.textColor,
					type = "color",
					hasAlpha = true,
					order = 17,
					get = function()
						return unpack(cap.db.profile.colorText)
					end,
					set = function(_, r, g, b, a)
						cap.db.profile.colorText = {r, g, b, a}
						for bar in next, cap.bars do
							bar:SetTextColor(r, g, b, a)
						end
					end,
				},
				colorBarBackground = {
					name = L.barBackground,
					type = "color",
					hasAlpha = true,
					order = 18,
					get = function()
						return unpack(cap.db.profile.colorBarBackground)
					end,
					set = function(_, r, g, b, a)
						cap.db.profile.colorBarBackground = {r, g, b, a}
						for bar in next, cap.bars do
							if bar then
								bar.candyBarBackground:SetVertexColor(r, g, b, a)
							end
						end
					end,
				},
				colorAlliance = {
					name = L.allianceBars,
					type = "color",
					hasAlpha = true,
					order = 19,
					get = function()
						return unpack(cap.db.profile.colorAlliance)
					end,
					set = function(_, r, g, b, a)
						cap.db.profile.colorAlliance = {r, g, b, a}
						for bar in next, cap.bars do
							if bar:Get("capping:colorid") == "colorAlliance" then
								bar:SetColor(r, g, b, a)
							end
						end
					end,
				},
				colorHorde = {
					name = L.hordeBars,
					type = "color",
					hasAlpha = true,
					order = 20,
					get = function()
						return unpack(cap.db.profile.colorHorde)
					end,
					set = function(_, r, g, b, a)
						cap.db.profile.colorHorde = {r, g, b, a}
						for bar in next, cap.bars do
							if bar:Get("capping:colorid") == "colorHorde" then
								bar:SetColor(r, g, b, a)
							end
						end
					end,
				},
				colorQueue = {
					name = L.queueBars,
					type = "color",
					hasAlpha = true,
					order = 21,
					get = function()
						return unpack(cap.db.profile.colorQueue)
					end,
					set = function(_, r, g, b, a)
						cap.db.profile.colorQueue = {r, g, b, a}
						for bar in next, cap.bars do
							if bar:Get("capping:colorid") == "colorQueue" then
								bar:SetColor(r, g, b, a)
							end
						end
					end,
				},
				colorOther = {
					name = L.otherBars,
					type = "color",
					hasAlpha = true,
					order = 22,
					get = function()
						return unpack(cap.db.profile.colorOther)
					end,
					set = function(_, r, g, b, a)
						cap.db.profile.colorOther = {r, g, b, a}
						for bar in next, cap.bars do
							if bar:Get("capping:colorid") == "colorOther" then
								bar:SetColor(r, g, b, a)
							end
						end
					end,
				},
			},
		},
		features = {
			name = L.features,
			order = 2, type = "group",
			args = {
				queueBars = {
					type = "toggle",
					name = L.queueBars,
					desc = L.queueBarsDesc,
					order = 1,
					set = function(_, value)
						cap.db.profile.queueBars = value
						if not value then
							for bar in next, cap.bars do
								if bar:Get("capping:queueid") then
									bar:Stop()
								end
							end
						end
					end,
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
					set = barClickSetOptions,
				},
				barOnControl = {
					type = "select",
					name = L.controlClick,
					desc = L.barClickDesc,
					order = 5,
					values = barClickOptions,
					set = barClickSetOptions,
				},
				barOnAlt = {
					type = "select",
					name = L.altClick,
					desc = L.barClickDesc,
					order = 6,
					values = barClickOptions,
					set = barClickSetOptions,
				},
			},
		},
		profiles = adbo:GetOptionsTable(cap.db),
	},
}
acOptions.args.profiles.order = 3

acr:RegisterOptionsTable(acOptions.name, acOptions, true)
acd:SetDefaultSize(acOptions.name, 420, 640)

