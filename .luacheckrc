std = "lua51"
max_line_length = false
codes = true
exclude_files = {
	"**/Libs",
}
ignore = {
	"111/SLASH_Capping1", -- slash handlers
	"113/BasicMessageDialog", -- Alterac Valley popup
	"212/self", -- (W212) unused argument self
}
globals = {
	-- Addon
	"CappingAPI",
	"CappingFrame",
	"LibStub",

	-- WoW (general API)
	"Ambiguate",
	"bit",
	"C_AddOns",
	"C_AreaPoiInfo",
	"C_ChatInfo",
	"C_CurrencyInfo",
	"C_CVar",
	"C_EncodingUtil",
	"C_GossipInfo",
	"C_Item",
	"C_Map",
	"C_Minimap",
	"C_PvP",
	"C_QuestLog",
	"C_Spell",
	"C_Texture",
	"C_Timer",
	"C_UIFileAsset",
	"C_UIWidgetManager",
	"CombatLogGetCurrentEventInfo",
	"CompleteQuest",
	"CreateFrame",
	"GetBattlefieldEstimatedWaitTime",
	"GetBattlefieldPortExpiration",
	"GetBattlefieldStatus",
	"GetBattlefieldTimeWaited",
	"GetBattlegroundInfo",
	"geterrorhandler",
	"GetGameType",
	"GetInstanceInfo",
	"GetLocale",
	"GetNumBattlegroundTypes",
	"GetNumQuestRewards",
	"GetQuestReward",
	"GetRealZoneText",
	"GetTime",
	"InCombatLockdown",
	"IsAltKeyDown",
	"IsControlKeyDown",
	"IsInGroup",
	"IsInRaid",
	"IsLoggedIn",
	"IsQuestCompletable",
	"IsShiftKeyDown",
	"PlaySound",
	"RaidNotice_AddMessage", -- XXX remove
	"RaidBossEmoteFrame", -- XXX remove
	"RaidWarningFrame",
	"RaidWarningUtil",
	"RequestBattlefieldScoreData",
	"StopSound",
	"strmatch",
	"strsplit",
	"UnitFactionGroup",
	"UnitGUID",
	"UnitHealth",
	"UnitHealthMax",
	"UnitIsMercenary",
	"UnitName",
	"UnitPosition",
	"WOW_PROJECT_ID", -- XXX remove
	"WOW_PROJECT_MAINLINE", -- XXX remove

	-- WoW (global tables)
	"SlashCmdList",
	"TimerTracker",
	"UIParent",

	-- WoW (global strings)
	"ARENA",

	-- Classic WoW
	"GetBattlefieldScore",
}
