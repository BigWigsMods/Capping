std = "lua51"
max_line_length = false
codes = true
exclude_files = {
	"**/Libs",
}
ignore = {
	"11/SLASH_Capping1", -- slash handlers
}
globals = {
	-- Addon
	"CappingFrame",
	"LibStub",

	-- WoW (general API)
	"C_AreaPoiInfo",
	"C_ChatInfo",
	"C_CurrencyInfo",
	"C_CVar",
	"C_GossipInfo",
	"C_PvP",
	"C_Texture",
	"C_Timer",
	"C_UIWidgetManager",
	"CreateFrame",
	"EnableAddOn",
	"GetLocale",
	"IsAltKeyDown",
	"IsControlKeyDown",
	"IsInGroup",
	"IsShiftKeyDown",
	"LoadAddOn",
	"ReloadUI",
	"SendChatMessage",
	"SlashCmdList",
	"UIParent",

	-- WoW (global strings)
	"ARENA",
	"TIME_REMAINING",
}
