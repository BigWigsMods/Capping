std = "lua51"
max_line_length = false
codes = true
exclude_files = {
	"**/Libs",
}
ignore = {
	"111/SLASH_Capping1", -- slash handlers
	"212/self", -- (W212) unused argument self
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
	"C_Minimap",
	"C_PvP",
	"C_Texture",
	"C_Timer",
	"C_UIWidgetManager",
	"CombatLogGetCurrentEventInfo",
	"CompleteQuest",
	"CreateFrame",
	"EnableAddOn",
	"GetBattlefieldEstimatedWaitTime",
	"GetBattlefieldPortExpiration",
	"GetBattlefieldStatus",
	"GetBattlefieldTimeWaited",
	"GetBattlegroundInfo",
	"GetInstanceInfo",
	"GetItemCount",
	"GetLocale",
	"GetNumBattlegroundTypes",
	"GetPOITextureCoords",
	"GetQuestReward",
	"GetRealmName",
	"GetSpellInfo",
	"GetTime",
	"IsAltKeyDown",
	"IsControlKeyDown",
	"IsInGroup",
	"IsQuestCompletable",
	"IsShiftKeyDown",
	"LoadAddOn",
	"PlaySound",
	"RaidNotice_AddMessage",
	"RaidWarningFrame_OnEvent",
	"ReloadUI",
	"RequestBattlefieldScoreData",
	"SendChatMessage",
	"StopSound",
	"strmatch",
	"strsplit",
	"UnitGUID",
	"UnitHealth",
	"UnitHealthMax",
	"UnitName",
	"UnitPosition",

	-- WoW (global tables)
	"RaidBossEmoteFrame",
	"SlashCmdList",
	"TimerTracker",
	"UIParent",

	-- WoW (global strings)
	"ARENA",
	"TIME_REMAINING",

	-- Classic WoW
	"GetBattlefieldScore",
	"GetGossipOptions",
	"GetNumGossipActiveQuests",
	"SelectGossipActiveQuest",
	"SelectGossipAvailableQuest",
	"SelectGossipOption",
}
