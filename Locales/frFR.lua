
if GetLocale() ~= "frFR" then return end
local _, mod = ...
local L = mod.L

L.battleBegins = "Début de la bataille"
L.finalScore = "Final : %d - %d"
L.flagRespawns = "Réapparition drapeau(x)"

L.takenTheFlagTrigger = "^(.+) a pris le drapeau !"
L.hasTakenTheTrigger = "s'est emparée"
L.droppedTrigger = "a été lâché"
L.capturedTheTrigger = "a pris le drapeau de"

L.hordeGate = "Porte de la Horde"
L.allianceGate = "Porte de l'Alliance"
L.gatePosition = "%s (%s)"
L.west = "Ouest"
L.front = "Devant"
L.east = "Est"
L.hordeBoss = "Chef de la Horde"
L.allianceBoss = "Chef de l'Alliance"
L.galvangar = "Galvangar" -- Capitaine Galvangar
L.balinda = "Balinda" -- Capitaine Balinda Gîtepierre
L.ivus = "Ivus" -- Ivus le Seigneur de la forêt
L.lokholar = "Lokholar" -- Lokholar le Seigneur des glaces
L.handIn = "|cFF33FF99Capping|r: Remise automatique des objets de quête."
L.anchorTooltip = "|cffeda55fClic droit|r pour accéder aux options."
L.anchorTooltipNote = "Ouvre les options et verrouille les barres afin de cacher l'ancre à déplacer."

--- Alliance IoC Workshop yells:
-- Mécano gnome crie : J'en suis à la moitié ! Tenez la Horde à distance. On n'apprend pas à se battre dans les écoles d'ingénieurs !
-- Mécano gnome crie : Déjà cassé ?! Pas de souci. Ce n'est que je ne puisse pas réparer.
--- Horde IoC Workshop yells:
-- Mécano goblin crie : J'en suis à la moitié ! Tenez l'alliance à distance - combattre n'est pas dans mon contrat !
-- Mécano goblin crie : C'est déjà cassé ?! Je le répare... Ne pensez pas que la garantie va couvrir ça.
L.halfway = "moitié"
L.broken = "cassé"

-- Wintergrasp
L.damaged = "|cFF33FF99Capping|r: %s endommagé"
L.destroyed = "|cFF33FF99Capping|r: %s détruit"
L.northEastKeep = "Tour de la Forteresse Nord-Est"
L.southEastKeep = "Tour de la Forteresse Sud-Est"
L.northWestKeep = "Tour de la Forteresse Nord-Ouest"
L.southWestKeep = "Tour de la Forteresse Sud-Ouest"
L.northWest = "Mur Nord-Ouest"
L.southWest = "Mur Sud-Ouest"
L.south = "Mur Sud"
L.southEast = "Mur Sud-Est"
L.northEast = "Mur Nord-Est"
L.innerWest = "Mur intérieur Ouest"
L.innerSouth = "Mur intérieur Sud"
L.innerEast = "Mur intérieur Est"
L.southGate = "Porte Sud"
L.mainEntrance = "Entrée principale"
L.westTower = "Tour Ouest"
L.southTower = "Tour Sud"
L.eastTower = "Tour Est"

-- Ashran
L.hordeGuardian = "Gardien de la Horde"
L.allianceGuardian = "Gardien de l'Alliance"
L.kronus = "Kronus"
L.fangraal = "Crograal"

-- Arena
L.arenaStartTrigger = "Le combat commence !" -- Needs to match the in game text exactly
L.arenaStart60s = "Le combat d'arène commence dans une minute !" -- Needs to match the in game text exactly
L.arenaStart30s = "Le combat d'arène commence dans trente secondes !" -- Needs to match the in game text exactly
L.arenaStart15s = "Le combat d'arène commence dans quinze secondes !" -- Needs to match the in game text exactly
