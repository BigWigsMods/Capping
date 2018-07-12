
local _, addon = ...
addon.L = {
	-- options menu
	["Auto Quest Turnins"] = "Auto Quest Turnins",
	["Bar"] = "Timer Bar",
	["Width"] = "Width",
	["Height"] = "Height",
	["Texture"] = "Texture",
	["Map Scale"] = "Map Scale",
	["Hide Border"] = "Hide Border",
	["Port Timer"] = "Port Timer",
	["Wait Timer"] = "Wait Timer",
	["Show/Hide Anchor"] = "Show/Hide Anchor",
	["Narrow Map Mode"] = "Narrow Map Mode",
	["Narrow Anchor Left"] = "Narrow Anchor Left",
	["Test"] = "Test",
	["Flip Growth"] = "Flip Bar Stack",
	["Single Group"] = "Single Group",
	["Move Scoreboard"] = "Move Scoreboard",
	["Spacing"] = "Spacing",
	["Request Sync"] = "Request Sync",
	["Fill Grow"] = "Fill Grow",
	["Fill Right"] = "Fill Right",
	["Font"] = "Font",
	["Time Position"] = "Time Position",
	["Border Width"] = "Border Width",
	["Send to BG"] = "Send to BG",
	["Send to SAY"] = "Send to SAY",
	["Cancel Timer"] = "Cancel Timer",
	["Move Capture Bar"] = "Move Capture Bar",
	["Move Vehicle Seat"] = "Move Vehicle Seat",
	["Hide Capping Start Time"] = "Hide Capping Start Time",
	["Hide Blizzard Start Timer"] = "Hide Blizzard Start Timer",

	-- etc timers
	["Battle Begins"] = "Battle Begins", -- bar text for bg gates opening
	["1 minute"] = "1 minute",
	["60 seconds"] = "60 seconds",
	["30 seconds"] = "30 seconds",
	["15 seconds"] = "15 seconds",
	["One minute until"] = "One minute until",
	["Forty five seconds"] = "Forty five seconds",
	["Thirty seconds until"] = "Thirty seconds until",
	["Fifteen seconds until"] = "Fifteen seconds until",
	["%s: %s - %d:%02d"] = "%s: %s - %d:%02d", -- chat message after shift left-clicking a bar

	-- AB
	["Bases: (%d+)  Resources: (%d+)/(%d+)"] = "Bases: (%d+)  Resources: (%d+)/(%d+)", -- arathi basin scoreboard
	["has assaulted"] = "has assaulted",
	["claims the"] = "claims the",
	["has taken the"] = "has taken the",
	["has defended the"] = "has defended the",
	["Final: %d - %d"] = "Final: %d - %d", -- final score text
	["wins %d-%d"] = "wins %d-%d", -- final score chat message

	-- WSG
	["was picked up by (.+)!"] = "was picked up by (.+)!",
	["was picked up by (.+)!2"] = "was picked up by (.+)!2",
	["dropped"] = "dropped",
	["captured the"] = "captured the",
	["Flag respawns"] = "Flag respawns",
	["%s's flag carrier: %s (%s)"] = "%s's flag carrier: %s (%s)", -- chat message

	-- AV
	 -- patterns
	["Upgrade to"] = "Upgrade to", -- the option to upgrade units in AV
	["Wicked, wicked, mortals!"] = "Wicked, wicked, mortals!", -- what Ivus says after being summoned
	["Ivus begins moving"] = "Ivus begins moving",
	["WHO DARES SUMMON LOKHOLAR"] = "WHO DARES SUMMON LOKHOLAR", -- what Lok says after being summoned
	["The Ice Lord has arrived!"] = "The Ice Lord has arrived!",
	["Lokholar begins moving"] = "Lokholar begins moving",

	-- EotS
	["^(.+) has taken the flag!"] = "^(.+) has taken the flag!",
	["Bases: (%d+)  Victory Points: (%d+)/(%d+)"] = "Bases: (%d+)  Victory Points: (%d+)/(%d+)",

	-- IoC
	 -- node keywords (text is also displayed on timer bar)
	["Alliance Keep"] = "Alliance Keep",
	["Horde Keep"] = "Horde Keep",
	 -- Siege Engine keyphrases
	["Goblin"] = "Goblin",  -- Horde mechanic name keyword
	["seaforium bombs"] = "seaforium bombs",  -- start (after capturing the workshop)
	["It's broken"] = "It's broken",  -- start again (after engine is destroyed)
	["halfway"] = "halfway",  -- middle
}

