--[[ =========================================================================
	EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (C) 2020-2021 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin HostileVillagers.lua gameplay script
=========================================================================== ]]

--[[ =========================================================================
	global defines
=========================================================================== ]]
m_eGoodyHut = GameInfo.Improvements["IMPROVEMENT_GOODY_HUT"].Index;			-- the database index value of the goody hut improvement
m_eBarbCamp	= GameInfo.Improvements["IMPROVEMENT_BARBARIAN_CAMP"].Index;	-- the database index value of the barbarian camp improvement

m_sRuleset = GameConfiguration.GetValue("RULESET");				-- fetch the ruleset in use at startup

m_bIsNoGoodyHuts = GameConfiguration.GetValue("GAME_NO_GOODY_HUTS");		-- fetch the status of the No Goody Huts setup option
m_bIsNoBarbarians = GameConfiguration.GetValue("GAME_NO_BARBARIANS");		-- fetch the status of the No Barbarians setup option

m_bIsNoHostilesAfterReward = GameConfiguration.GetValue("GAME_NO_HOSTILES_AFTER_REWARD");
m_bIsNoHostilesAsReward = GameConfiguration.GetValue("GAME_NO_HOSTILES_AS_REWARD");

m_eNumEras = 1;						-- the minimum number of in-game era(s) needs to be 1 or shit breaks
m_sQuery = "SELECT * FROM Eras";	-- sqlite query to determine the actual number of in-game era(s)
m_kEras = DB.Query(m_sQuery);		-- the result of the above sqlite query

if m_kEras and #m_kEras > 0 then m_eNumEras = #m_kEras; end		-- set the number of in-game era(s) to the count of items returned by the above sqlite query

-- table of era starts; key = game turn, value = era that begins on that turn
-- this is a kludge, and is not entirely accurate, but is currently necessary for the script to function with the Standard ruleset; will be ignored if a different ruleset is in use
m_kEraStartTurns = { [1] = 0, [76] = 1, [136] = 2, [196] = 3, [256] = 4, [316] = 5, [376] = 6, [436] = 7 };

m_eCurrentEra = 0									-- set the default era to 0; set the actual current game era below after determining the ruleset in use
m_eCurrentTurn = Game.GetCurrentGameTurn();			-- retrieve the current game turn at startup

if (m_sRuleset == "RULESET_STANDARD") then			-- retrieve the current game era at startup; this is a pain with the Standard ruleset, since Game.GetEras():GetCurrentEra() does not appear to exist here
	if m_eCurrentTurn >= 436 then m_eCurrentEra = 7;			-- information
	elseif m_eCurrentTurn >= 376 then m_eCurrentEra = 6;		-- atomic
	elseif m_eCurrentTurn >= 316 then m_eCurrentEra = 5;		-- modern
	elseif m_eCurrentTurn >= 256 then m_eCurrentEra = 4;		-- industrial
	elseif m_eCurrentTurn >= 196 then m_eCurrentEra = 3;		-- renaissance
	elseif m_eCurrentTurn >= 136 then m_eCurrentEra = 2;		-- medieval
	elseif m_eCurrentTurn >= 76 then m_eCurrentEra = 1;			-- classical
	end
else												-- Game.GetEras():GetCurrentEra() exists in expansion rulesets, so use that instead
	m_eCurrentEra = Game.GetEras():GetCurrentEra();
end

m_iRandomSeed = 100;		-- used to seed TerrainBuilder.GetRandomNumber(n), which returns a value in range 0 - (n - 1) inclusive

m_iDiscardSeed = TerrainBuilder.GetRandomNumber(m_iRandomSeed, "Hostile villagers : RNG pump & dump");		-- throw away the first value that TerrainBuilder.GetRandomNumber spits out

m_iHostileSightedNotificationHash = NotificationTypes.BARBARIANS_SIGHTED;							-- hash value of the indicated notification type
m_sHostileSpawnTitle = Locale.Lookup("LOC_HOSTILE_VILLAGERS_NOTIFICATION_TITLE");					-- title of notification for hostile villagers
m_sHostileSpawnUnitMessage = Locale.Lookup("LOC_HOSTILE_VILLAGERS_UNIT_NOTIFICATION_MESSAGE");		-- body of notification when a unit spawns
m_sHostileSpawnCampMessage = Locale.Lookup("LOC_HOSTILE_VILLAGERS_CAMP_NOTIFICATION_MESSAGE");		-- body of notification when a camp spawns

-- table of difficulty levels; key = hash value from PlayerConfigurations:GetHandicapTypeID(), value = table of associated difficulty levels
m_kDifficultyLevels = {
	[1078608846]	= { DifficultyType = "DIFFICULTY_SETTLER", Level = 1 },
	[1329626265]	= { DifficultyType = "DIFFICULTY_CHIEFTAIN", Level = 2 },
	[-966254459]	= { DifficultyType = "DIFFICULTY_WARLORD", Level = 3 },
	[-179952465]	= { DifficultyType = "DIFFICULTY_PRINCE", Level = 4 },
	[675933641]		= { DifficultyType = "DIFFICULTY_KING", Level = 5 },
	[1499830429]	= { DifficultyType = "DIFFICULTY_EMPEROR", Level = 6 },
	[575051378]		= { DifficultyType = "DIFFICULTY_IMMORTAL", Level = 7 },
	[1543611863]	= { DifficultyType = "DIFFICULTY_DEITY", Level = 8 }
};

-- table of individual melee units to spawn; key = era to spawn in, value = unit to spawn
m_kHostileMeleeByEra = { [0] = "UNIT_WARRIOR", [1] = "UNIT_WARRIOR", [2] = "UNIT_SWORDSMAN", [3] = "UNIT_MAN_AT_ARMS", [4] = "UNIT_MUSKETMAN", [5] = "UNIT_LINE_INFANTRY", [6] = "UNIT_INFANTRY", [7] = "UNIT_INFANTRY", [8] = "UNIT_INFANTRY" };

-- ** 2021/04/22 ** ranged units spawned by this script don't seem to do anything but wait for death
-- table of individual ranged units to spawn; key = era to spawn in, value = unit to spawn
m_kHostileRangedByEra = { [0] = "UNIT_SLINGER", [1] = "UNIT_ARCHER", [2] = "UNIT_ARCHER", [3] = "UNIT_CROSSBOWMAN", [4] = "UNIT_CROSSBOWMAN", [5] = "UNIT_FIELD_CANNON", [6] = "UNIT_FIELD_CANNON", [7] = "UNIT_MACHINE_GUN", [8] = "UNIT_MACHINE_GUN" };

-- table of goody hut types; key = reward hash value from Events.GoodyHutReward, value = associated goody hut type
m_kGoodyHutTypes = {
	-- built-in types
	[301278043]		= "GOODYHUT_CULTURE",
	[-2010932837]	= "GOODYHUT_GOLD",
	[-1897648434]	= "GOODYHUT_FAITH",
	[1623514478]	= "GOODYHUT_MILITARY",
	[-1068790248]	= "GOODYHUT_SCIENCE",
	[1892398955]	= "GOODYHUT_SURVIVORS",
	-- Gathering Storm types
	[392580697]		= "GOODYHUT_DIPLOMACY",
	-- EGHV types
	[1861842132]	= "GOODYHUT_HOSTILES"
}

--[[ =========================================================================
	the big stupid table of goody hut reward data : framework cribbed from [4] and modified
		key = subtype hash value from Events.GoodyHutReward, value = a small stupid table of associated reward data :
			SubTypeGoodyHut is the specific goody hut reward associated with the key
			Tier is the rarity value of the reward, from 6 (extremely common) to 1 (extremely rare)
			Description is the tag from the localization database to use as the body of any notification sent to the panel
=========================================================================== ]]
m_kGoodyHutRewardInfo = {
	-- EGHV culture-type rewards
	[2066007186]	= { SubTypeGoodyHut = "GOODYHUT_ONE_CIVIC", Tier = 4, Description = "LOC_GOODYHUT_CULTURE_ONE_CIVIC_DESCRIPTION" },
	[-1560984545]	= { SubTypeGoodyHut = "GOODYHUT_TWO_CIVICS", Tier = 3, Description = "LOC_GOODYHUT_CULTURE_TWO_CIVICS_DESCRIPTION" },
	[-824659778]	= { SubTypeGoodyHut = "GOODYHUT_SMALL_CHANGE_CULTURE", Tier = 2, Description = "LOC_GOODYHUT_CULTURE_SMALL_CHANGE_DESCRIPTION" },
	[-1615934897]	= { SubTypeGoodyHut = "GOODYHUT_SMALL_MODIFIER_CULTURE", Tier = 1, Description = "LOC_GOODYHUT_CULTURE_SMALL_MODIFIER_DESCRIPTION" },
	-- EGHV faith-type rewards
	[1084480174]	= { SubTypeGoodyHut = "GOODYHUT_SMALL_CHANGE_FAITH", Tier = 2, Description = "LOC_GOODYHUT_FAITH_SMALL_CHANGE_DESCRIPTION" },
	[1572322819]	= { SubTypeGoodyHut = "GOODYHUT_SMALL_MODIFIER_FAITH", Tier = 1, Description = "LOC_GOODYHUT_FAITH_SMALL_MODIFIER_DESCRIPTION" },
	-- EGHV gold-type rewards
	[2139117074]	= { SubTypeGoodyHut = "GOODYHUT_ADD_TRADE_ROUTE", Tier = 3, Description = "LOC_GOODYHUT_ADD_TRADE_ROUTE_DESCRIPTION" },
	[-1372363028]	= { SubTypeGoodyHut = "GOODYHUT_SMALL_CHANGE_GOLD", Tier = 2, Description = "LOC_GOODYHUT_GOLD_SMALL_CHANGE_DESCRIPTION" },
	[222801916]		= { SubTypeGoodyHut = "GOODYHUT_SMALL_MODIFIER_GOLD", Tier = 1, Description = "LOC_GOODYHUT_GOLD_SMALL_MODIFIER_DESCRIPTION" },
	-- EGHV military-type rewards
	[359564910]		= { SubTypeGoodyHut = "GOODYHUT_GRANT_WARRIOR", Tier = 5, Description = "LOC_GOODYHUT_MILITARY_GRANT_MELEE_UNIT_DESCRIPTION" },
	[-1607386473]	= { SubTypeGoodyHut = "GOODYHUT_GRANT_SLINGER", Tier = 5, Description = "LOC_GOODYHUT_MILITARY_GRANT_RANGED_UNIT_DESCRIPTION" },
	[-1569174051]	= { SubTypeGoodyHut = "GOODYHUT_GRANT_SPEARMAN", Tier = 5, Description = "LOC_GOODYHUT_MILITARY_GRANT_ANTI_CAVALRY_UNIT_DESCRIPTION" },
	[971311701]		= { SubTypeGoodyHut = "GOODYHUT_GRANT_MILITARY_ENGINEER", Tier = 4, Description = "LOC_GOODYHUT_MILITARY_GRANT_MILITARY_ENGINEER_DESCRIPTION" },
	[1424219521]	= { SubTypeGoodyHut = "GOODYHUT_GRANT_MEDIC", Tier = 4, Description = "LOC_GOODYHUT_MILITARY_GRANT_MEDIC_DESCRIPTION" },
	[-620620448]	= { SubTypeGoodyHut = "GOODYHUT_GRANT_HORSEMAN", Tier = 3, Description = "LOC_GOODYHUT_MILITARY_GRANT_LIGHT_CAVALRY_UNIT_DESCRIPTION" },
	[-249550326]	= { SubTypeGoodyHut = "GOODYHUT_GRANT_HEAVY_CHARIOT", Tier = 3, Description = "LOC_GOODYHUT_MILITARY_GRANT_HEAVY_CAVALRY_UNIT_DESCRIPTION" },
	[-833622945]	= { SubTypeGoodyHut = "GOODYHUT_SMALL_CHANGE_PRODUCTION", Tier = 2, Description = "LOC_GOODYHUT_PRODUCTION_SMALL_CHANGE_DESCRIPTION" },
	[385855644]		= { SubTypeGoodyHut = "GOODYHUT_SMALL_MODIFIER_PRODUCTION", Tier = 1, Description = "LOC_GOODYHUT_PRODUCTION_SMALL_MODIFIER_DESCRIPTION" },
	-- EGHV science-type rewards
	[342022628]		= { SubTypeGoodyHut = "GOODYHUT_TWO_TECHS", Tier = 3, Description = "LOC_GOODYHUT_SCIENCE_TWO_TECHS_DESCRIPTION" },
	[526786045]		= { SubTypeGoodyHut = "GOODYHUT_SMALL_CHANGE_SCIENCE", Tier = 2, Description = "LOC_GOODYHUT_SCIENCE_SMALL_CHANGE_DESCRIPTION" },
	[1309697804]	= { SubTypeGoodyHut = "GOODYHUT_SMALL_MODIFIER_SCIENCE", Tier = 1, Description = "LOC_GOODYHUT_SCIENCE_SMALL_MODIFIER_DESCRIPTION" },
	-- EGHV survivors-type rewards
	[1034048074]	= { SubTypeGoodyHut = "GOODYHUT_SMALL_CHANGE_FOOD", Tier = 2, Description = "LOC_GOODYHUT_FOOD_SMALL_CHANGE_DESCRIPTION" },
	[-1630102694]	= { SubTypeGoodyHut = "GOODYHUT_SMALL_MODIFIER_FOOD", Tier = 1, Description = "LOC_GOODYHUT_FOOD_SMALL_MODIFIER_DESCRIPTION" },
	-- EGHV diplomacy-type rewards
	[1915551099]	= { SubTypeGoodyHut = "GOODYHUT_TWO_ENVOYS", Tier = 3, Description = "LOC_GOODYHUT_DIPLOMACY_ENVOYS_DESCRIPTION" },							-- requires Gathering Storm
	[896143518]		= { SubTypeGoodyHut = "GOODYHUT_TWO_GOVERNOR_TITLES", Tier = 2, Description = "LOC_GOODYHUT_DIPLOMACY_GOVERNOR_TITLES_DESCRIPTION" },		-- requires Gathering Storm
	[-755814703]	= { SubTypeGoodyHut = "GOODYHUT_SMALL_BOOST_FAVOR", Tier = 1, Description = "LOC_GOODYHUT_DIPLOMACY_SMALL_BOOST_FAVOR_DESCRIPTION" },		-- requires Gathering Storm
	-- existing diplomacy-type rewards
	[-842336157]	= { SubTypeGoodyHut = "GOODYHUT_FAVOR", Tier = 6, Description = "LOC_GOODYHUT_DIPLOMACY_FAVOR_DESCRIPTION" },							-- requires Gathering Storm
	[1171999597]	= { SubTypeGoodyHut = "GOODYHUT_ENVOY", Tier = 5, Description = "LOC_GOODYHUT_DIPLOMACY_ENVOY_DESCRIPTION" },							-- requires Gathering Storm
	[-1140666915]	= { SubTypeGoodyHut = "GOODYHUT_GOVERNOR_TITLE", Tier = 4, Description = "LOC_GOODYHUT_DIPLOMACY_GOVERNOR_TITLE_DESCRIPTION" },			-- requires Gathering Storm
	-- existing culture-type rewards
	[-1593446804]	= { SubTypeGoodyHut = "GOODYHUT_ONE_CIVIC_BOOST", Tier = 6, Description = "placeholder" },			-- no built-in description tag for this reward
	[-367235253]	= { SubTypeGoodyHut = "GOODYHUT_TWO_CIVIC_BOOSTS", Tier = 5, Description = "placeholder" },			-- no built-in description tag for this reward
	-- existing faith-type rewards
	[313124344]		= { SubTypeGoodyHut = "GOODYHUT_SMALL_FAITH", Tier = 6, Description = "LOC_GOODYHUT_SMALL_FAITH_DESCRIPTION" },
	[173418224]		= { SubTypeGoodyHut = "GOODYHUT_MEDIUM_FAITH", Tier = 5, Description = "LOC_GOODYHUT_MEDIUM_FAITH_DESCRIPTION" },
	[1747194442]	= { SubTypeGoodyHut = "GOODYHUT_LARGE_FAITH", Tier = 4, Description = "LOC_GOODYHUT_LARGE_FAITH_DESCRIPTION" },
	[2109989822]	= { SubTypeGoodyHut = "GOODYHUT_ONE_RELIC", Tier = 3, Description = "LOC_GOODYHUT_CULTURE_RELIC_DESCRIPTION" },			-- moved from culture-type for balancing
	-- existing gold-type rewards
	[-856816033]	= { SubTypeGoodyHut = "GOODYHUT_SMALL_GOLD", Tier = 6, Description = "LOC_GOODYHUT_SMALL_GOLD_DESCRIPTION" },
	[-2073396856]	= { SubTypeGoodyHut = "GOODYHUT_MEDIUM_GOLD", Tier = 5, Description = "LOC_GOODYHUT_MEDIUM_GOLD_DESCRIPTION" },
	[725818580]		= { SubTypeGoodyHut = "GOODYHUT_LARGE_GOLD", Tier = 4, Description = "LOC_GOODYHUT_LARGE_GOLD_DESCRIPTION" },
	-- existing military-type rewards
	[0]				= { SubTypeGoodyHut = "GOODYHUT_GRANT_UPGRADE", Tier = 7, Description = "LOC_GOODYHUT_MILITARY_GRANT_UPGRADE_DESCRIPTION" },	-- disabled by default, and disabled by EGHV
	[1721956964] 	= { SubTypeGoodyHut = "GOODYHUT_HEAL", Tier = 7, Description = "LOC_GOODYHUT_MILITARY_HEAL_DESCRIPTION" },						-- enabled by default, but disabled by EGHV
	[-1085383998]	= { SubTypeGoodyHut = "GOODYHUT_RESOURCES", Tier = 6, Description = "LOC_GOODYHUT_MILITARY_RESOURCES_DESCRIPTION" },			-- requires Gathering Storm
	[-897059678]	= { SubTypeGoodyHut = "GOODYHUT_GRANT_EXPERIENCE", Tier = 6, Description = "LOC_GOODYHUT_MILITARY_GRANT_EXPERIENCE_DESCRIPTION" },
	[-945185595]	= { SubTypeGoodyHut = "GOODYHUT_GRANT_SCOUT", Tier = 6, Description = "LOC_GOODYHUT_MILITARY_GRANT_UNIT_DESCRIPTION" },
	-- existing science-type rewards
	[51039867]		= { SubTypeGoodyHut = "GOODYHUT_ONE_TECH_BOOST", Tier = 6, Description = "placeholder" },			-- no built-in description tag for this reward
	[1570455183]	= { SubTypeGoodyHut = "GOODYHUT_TWO_TECH_BOOSTS", Tier = 5, Description = "placeholder" },			-- no built-in description tag for this reward
	[294222921]		= { SubTypeGoodyHut = "GOODYHUT_ONE_TECH", Tier = 4, Description = "LOC_GOODYHUT_SCIENCE_ONE_TECH_DESCRIPTION" },
	-- existing survivors-type rewards
	[1038837136]	= { SubTypeGoodyHut = "GOODYHUT_ADD_POP", Tier = 6, Description = "LOC_GOODYHUT_SURVIVORS_ADD_POP_DESCRIPTION" },
	[-317814676]	= { SubTypeGoodyHut = "GOODYHUT_GRANT_BUILDER", Tier = 5, Description = "LOC_GOODYHUT_SURVIVORS_GRANT_UNIT_DESCRIPTION" },
	[-2134131563]	= { SubTypeGoodyHut = "GOODYHUT_GRANT_TRADER", Tier = 4, Description = "LOC_GOODYHUT_SURVIVORS_GRANT_UNIT_DESCRIPTION" },
	[750739574]		= { SubTypeGoodyHut = "GOODYHUT_GRANT_SETTLER", Tier = 3, Description = "LOC_GOODYHUT_SURVIVORS_GRANT_UNIT_DESCRIPTION" },		-- disabled by default, but enabled by EGHV
	-- EGHV : hostiles-type "reward"
	[-657161256]	= { SubTypeGoodyHut = "GOODYHUT_SPAWN_HOSTILE_VILLAGERS", Tier = 0, Description = "LOC_GOODYHUT_SPAWN_HOSTILE_VILLAGERS_DESCRIPTION" }		-- tier 0 for maximum hostility
};

--[[ =========================================================================
	function OnTurnBegin() : framework cribbed from [5] and modified
=========================================================================== ]]
function OnTurnBegin(iTurn)
	m_eCurrentTurn = iTurn;			-- update the global current turn

	local bIsEraChanged = false;

	local iPreviousEra = m_eCurrentEra;

	if (m_sRuleset == "RULESET_STANDARD") then			-- Standard ruleset in use
		if m_kEraStartTurns[m_eCurrentTurn] then
			m_eCurrentEra = m_kEraStartTurns[m_eCurrentTurn];			-- update the global era
			bIsEraChanged = true;
		end
	else				-- non-Standard ruleset in use
		local iEraThisTurn = Game.GetEras():GetCurrentEra();		-- fetch the current era
		if (iPreviousEra ~= iEraThisTurn) then			-- true when the current era differs from the stored global era
			m_eCurrentEra = iEraThisTurn;			-- update the global era
			bIsEraChanged = true;
		end
	end

	if bIsEraChanged then
		local sEraChangedMessage = "Turn " .. iTurn .. " : The current game era has changed from " .. iPreviousEra .. " to " .. m_eCurrentEra;

		if not m_bIsNoBarbarians and not m_bIsNoHostilesAfterReward then
			sEraChangedMessage = sEraChangedMessage .. "; hostile villagers will appear after rewards with increased frequency and intensity";
		end

		print(sEraChangedMessage);
	end
end

--[[ =========================================================================
	function GetBarbarianId() : framework cribbed from [2] and modified
=========================================================================== ]]
function GetBarbarianId()
	if m_bIsNoBarbarians then return -1; end			-- return an obviously screwy number if 'No Barbarians' is enabled, and do nothing else
	for p = 63, 0, -1 do
		local pPlayer = Players[p];
		local pPlayerConfig = PlayerConfigurations[p];
		if (pPlayer ~= nil) and (pPlayerConfig ~= nil) and (pPlayerConfig:GetCivilizationTypeName() == "CIVILIZATION_BARBARIAN") then
			return p;			-- return p as the Barbarian player ID
		end
	end
	return -2;			-- return an even screwier number, because something is very wrong if this fires
end

-- fetch the Barbarian player ID, if any
m_eBarbarianPlayer = GetBarbarianId();

--[[ =========================================================================
	function ValidateAdjacentPlots() : framework cribbed from [3] and modified
=========================================================================== ]]
function ValidateAdjacentPlots(iX, iY)
	local tValidPlots = {};
	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
		local adjacentPlot = Map.GetAdjacentPlot(iX, iY, direction);
		if adjacentPlot and ImprovementBuilder.CanHaveImprovement(adjacentPlot, m_eBarbCamp, -1) then
			print("Plot (x " .. adjacentPlot:GetX() .. ", y " .. adjacentPlot:GetY() .. ") is a valid location for a barbarian camp");
			table.insert(tValidPlots, adjacentPlot);
		end
	end
	return tValidPlots;
end

--[[ =========================================================================
	function CreateHostileVillagers() : framework cribbed from [2] and modified
=========================================================================== ]]
function CreateHostileVillagers(iPlayerID, tHostilityModifiers, iX, iY)
	local iHostilityMaxLevel = m_iRandomSeed * 2.5;				-- above this threshold, spawn additional unit(s)
	local iHostilityPissedLevel = iHostilityMaxLevel * 2;			-- above this threshold, spawn a camp
	local iHostilityEraModifier = tHostilityModifiers.Era;

	local iHostilityBaseLevel = math.floor(tHostilityModifiers.Unit * 3);
	local iHostilityRewardModifier = tHostilityModifiers.Tier;
	local iHostilityRandomModifier = TerrainBuilder.GetRandomNumber(m_iRandomSeed, "Hostile villagers : spawn chance") + 1;

	-- hostility will greatly fluctuate with (1) the current difficulty, (2) popping with a non-recon unit, (3) rarity of the earned reward, and (4) the current game era
	local iHostilityCurrentLevel = (iHostilityBaseLevel * iHostilityEraModifier * iHostilityRewardModifier) + iHostilityRandomModifier;

	local iNumHostileMelee = 1;		-- the default number of hostile melee unit(s) to spawn
	local iNumHostileRanged = 0;		-- the default number of hostile ranged unit(s) to spawn
	local bSpawnBarbCamp = false;			-- spawn a camp when this is true

	local sHostilityMessage = "The villagers are hostile!";
	if (iHostilityCurrentLevel >= iHostilityPissedLevel) then			-- spawn the default number of melee unit(s) and a camp, which will also spawn one anti-cavalry unit and one other unit
		sHostilityMessage = "The villagers are * EXTREMELY * hostile!!!";
		bSpawnBarbCamp = true;
	elseif (iHostilityCurrentLevel >= iHostilityMaxLevel) then			-- spawn additional melee unit(s)
		sHostilityMessage = "The villagers are VERY hostile!!";
		iNumHostileMelee = iNumHostileMelee + 1;
	end
	print(sHostilityMessage .. " [ hostility level : ( U " .. tHostilityModifiers.Unit .. " : B " .. iHostilityBaseLevel .. ", T " .. iHostilityRewardModifier .. ", E " .. iHostilityEraModifier .. ", R " .. iHostilityRandomModifier .. " ) " .. iHostilityCurrentLevel .. " / " .. iHostilityMaxLevel .. " / " .. iHostilityPissedLevel .. " ]");

	if (bSpawnBarbCamp) then			-- attempt to spawn a camp first, if the flag was set
		local tCurrentValidBarbCampPlots = ValidateAdjacentPlots(iX, iY);		-- check adjacent plots for a valid location for a new camp
		if tCurrentValidBarbCampPlots and #tCurrentValidBarbCampPlots > 0 then		-- pick a valid adjacent plot and try to spawn the camp when true
			print("Discovered " .. #tCurrentValidBarbCampPlots .. " valid plot(s) in which a barbarian camp may spawn");
			local iSpawnPlotIndex = TerrainBuilder.GetRandomNumber(#tCurrentValidBarbCampPlots, "Hostile villagers : new camp plot index") + 1;		-- get a random index value
			local pSpawnPlot = tCurrentValidBarbCampPlots[iSpawnPlotIndex];			-- obtain plot data from the random index

			ImprovementBuilder.SetImprovementType(pSpawnPlot, m_eBarbCamp, -1);		-- place camp here
			print("A group of villagers have organized into a new barbarian camp at plot (x " .. pSpawnPlot:GetX() .. ", y " .. pSpawnPlot:GetY() .. ")!");

			NotificationManager.SendNotification(iPlayerID, m_iHostileSightedNotificationHash, m_sHostileSpawnTitle, m_sHostileSpawnCampMessage, pSpawnPlot:GetX(), pSpawnPlot:GetY());
		else		-- no valid spawn plot(s) were identified, so try to compensate with more units
			print("There are no valid plot(s) in which a barbarian camp may spawn; attempting to spawn additional unit(s) instead");
			iNumHostileMelee = iNumHostileMelee + 1;
			iNumHostileRanged = iNumHostileRanged + 1;
		end
	end

	-- notification(s) are currently targeted to random plot(s) near the firing plot; need to figure out the lucky spawn plot(s) before they can be targeted correctly
	local iNotificationX = iX - 1;
	local iNotificationY = iY - 1;
	local iNumSpawnedUnits = 0;

	-- no units will spawn if this is 0 or less, which probably means something is wrong elsewhere
	if (iNumHostileMelee > 0) then
		for p = 1, iNumHostileMelee do
			UnitManager.InitUnitValidAdjacentHex(m_eBarbarianPlayer, m_kHostileMeleeByEra[m_eCurrentEra], iX, iY, 1);
			print("A group of villagers have organized into a hostile " .. m_kHostileMeleeByEra[m_eCurrentEra] .. " near plot (x " .. iX .. ", y " .. iY .. ")!");
			iNumSpawnedUnits = iNumSpawnedUnits + 1;
		end
	end

	-- ** 2021/04/22 ** ranged units spawned by this script don't seem to do anything but wait for death
	-- no units will spawn if this is 0 or less, which might mean something is wrong elsewhere
	if (iNumHostileRanged > 0) then
		for p = 1, iNumHostileRanged do
			UnitManager.InitUnitValidAdjacentHex(m_eBarbarianPlayer, m_kHostileRangedByEra[m_eCurrentEra], iX, iY, 1);
			print("A group of villagers have organized into a hostile " .. m_kHostileRangedByEra[m_eCurrentEra] .. " near plot (x " .. iX .. ", y " .. iY .. ")!");
			iNumSpawnedUnits = iNumSpawnedUnits + 1;
		end
	end

	if (iNumSpawnedUnits > 0) then
		for z = 1, iNumSpawnedUnits do
			if ((z % 2) == 0) then
				iNotificationX = iNotificationX + 1;
			elseif ((z % 2) == 1) then
				iNotificationY = iNotificationY + 1;
			else
				print("Strange things are afoot at the Circle K")
			end
			NotificationManager.SendNotification(iPlayerID, m_iHostileSightedNotificationHash, m_sHostileSpawnTitle, m_sHostileSpawnUnitMessage, iNotificationX, iNotificationY);
		end
	end
end

--[[ =========================================================================
	function OnGoodyHutReward() : cobbled together from [1] and from [4]
=========================================================================== ]]
function OnGoodyHutReward(iPlayerID, iUnitID, iRewardHash, iSubTypeHash)
	if (iPlayerID == -1) or (iUnitID == -1) then return; end			-- do nothing if the activating player's or unit's ID is -1

	local pPlayer = Players[iPlayerID];						-- table of the current player's data
	local pUnit = pPlayer:GetUnits():FindID(iUnitID);		-- ?

	local iX = pUnit:GetX();
	local iY = pUnit:GetY();

	local iRewardTier = 6;

	local tUnitData = GameInfo.Units[pUnit:GetType()];		-- table of this unit's data

	local sUnitType = tUnitData.UnitType;					-- the activating unit's type
	local sUnitPromotionClass = tUnitData.PromotionClass;	-- the activating unit's promotion class
	local sCivTypeName = PlayerConfigurations[iPlayerID]:GetCivilizationTypeName();			-- the current player's civilization type name
	local sOnGoodyHutRewardMessagePrimary = "Turn " .. m_eCurrentTurn .. " | Era " .. m_eCurrentEra .. " | Player " .. iPlayerID .. " [ " .. sCivTypeName .. " ] found a ";
	local sOnGoodyHutRewardMessageSecondary = "The " .. sUnitType .. " received a ";

	local bIsRewardHostileVillagers = false;

	if m_kGoodyHutTypes[iRewardHash] and m_kGoodyHutRewardInfo[iSubTypeHash] then
		iRewardTier = m_kGoodyHutRewardInfo[iSubTypeHash].Tier;		-- set the rarity tier value
		sOnGoodyHutRewardMessagePrimary = sOnGoodyHutRewardMessagePrimary .. m_kGoodyHutTypes[iRewardHash] .. " village at plot (x " .. iX .. ", y " .. iY .. ")";
		if (m_kGoodyHutRewardInfo[iSubTypeHash].SubTypeGoodyHut == "GOODYHUT_SPAWN_HOSTILE_VILLAGERS") then
			sOnGoodyHutRewardMessageSecondary = sOnGoodyHutRewardMessageSecondary .. "'reward' of " .. m_kGoodyHutRewardInfo[iSubTypeHash].SubTypeGoodyHut;
			if m_bIsNoHostilesAsReward then
				sOnGoodyHutRewardMessageSecondary = sOnGoodyHutRewardMessageSecondary .. "; 'No Hostiles As Reward' enabled";
			else
				bIsRewardHostileVillagers = true;
			end
		else
			sOnGoodyHutRewardMessageSecondary = sOnGoodyHutRewardMessageSecondary .. "Tier " .. m_kGoodyHutRewardInfo[iSubTypeHash].Tier .. " reward of " .. m_kGoodyHutRewardInfo[iSubTypeHash].SubTypeGoodyHut;
		end
	else
		sOnGoodyHutRewardMessagePrimary = sOnGoodyHutRewardMessagePrimary .. iRewardHash .. " village at plot (x " .. iX .. ", y " .. iY .. ") [ 'undefined goody hut' ]";
		sOnGoodyHutRewardMessageSecondary = sOnGoodyHutRewardMessageSecondary .. "reward of " .. iSubTypeHash .. " [ 'undefined goody hut subtype' ]";
	end

	print(sOnGoodyHutRewardMessagePrimary);

	if m_bIsNoBarbarians then			-- display the secondary message and terminate here if 'No Barbarians' is enabled
		sOnGoodyHutRewardMessageSecondary = sOnGoodyHutRewardMessageSecondary .. "; 'No Barbarians' enabled";
		print(sOnGoodyHutRewardMessageSecondary);
		return;
	end

	local iDifficultyHash = PlayerConfigurations[iPlayerID]:GetHandicapTypeID();				-- fetch the current difficulty hash
	local iHostileSpawnDifficultyModifier = m_kDifficultyLevels[iDifficultyHash].Level;		-- fetch the current difficulty level
	local iHostileSpawnEraModifier = m_eCurrentEra + 1;			-- set the era modifier
	local iHostileSpawnUnitModifier = iHostileSpawnDifficultyModifier;		-- set the unit modifier to the difficulty level
	if (sUnitType ~= "UNIT_BUILDER" and sUnitType ~= "UNIT_SETTLER" and sUnitType ~= "UNIT_MEDIC" and sUnitPromotionClass ~= "PROMOTION_CLASS_RECON") then
		iHostileSpawnUnitModifier = math.floor(iHostileSpawnUnitModifier * 1.5);			-- increase the unit modifier if the popping unit is non-recon and non-civilian
	end

	local iHostileSpawnRewardModifier = 7 - iRewardTier;			-- this will be larger for rarer rewards

	-- collect needed values computed above into a table for ease of transferring to CreateHostileVillagers()
	local tHostileSpawnModifiers = { Difficulty = iHostileSpawnDifficultyModifier, Unit = iHostileSpawnUnitModifier, Tier = iHostileSpawnRewardModifier, Era = iHostileSpawnEraModifier };

	if (bIsRewardHostileVillagers) then			-- guaranteed hostile villagers
		sOnGoodyHutRewardMessageSecondary = sOnGoodyHutRewardMessageSecondary .. " [ hostile spawn : 'guaranteed' ]";
		print(sOnGoodyHutRewardMessageSecondary);
		CreateHostileVillagers(iPlayerID, tHostileSpawnModifiers, iX, iY);		-- attempt to create hostile(s) adjacent to the former hut
		return;			-- do nothing else
	end

	if m_bIsNoHostilesAfterReward then
		sOnGoodyHutRewardMessageSecondary = sOnGoodyHutRewardMessageSecondary .. "; 'No Hostiles After Reward' enabled";
		print(sOnGoodyHutRewardMessageSecondary);
		return;
	end

	-- the hostile spawn chance will fluctuate with (1) the current difficulty, (2) popping with a non-recon unit, (3) rarity of the earned reward, and (4) the current game era
	local iHostileSpawnBaseModifier = (iHostileSpawnUnitModifier + iHostileSpawnRewardModifier) * iHostileSpawnEraModifier;
	local iHostileSpawnRandomModifier = TerrainBuilder.GetRandomNumber(m_iRandomSeed, "Hostile villagers : spawn chance") + 1;
	local iHostileSpawnChance = iHostileSpawnBaseModifier + iHostileSpawnRandomModifier;
	local sHostileSpawnInfo = " [ hostile spawn : ( D " .. iHostileSpawnDifficultyModifier .. " : U " .. iHostileSpawnUnitModifier .. ", T " .. iHostileSpawnRewardModifier .. ", E " .. iHostileSpawnEraModifier .. ", R " .. iHostileSpawnRandomModifier .. " ) " .. iHostileSpawnChance .. " / " .. m_iRandomSeed .. " ]";
	sOnGoodyHutRewardMessageSecondary = sOnGoodyHutRewardMessageSecondary .. sHostileSpawnInfo;

	print(sOnGoodyHutRewardMessageSecondary);
	if (iHostileSpawnChance > m_iRandomSeed) then
		CreateHostileVillagers(iPlayerID, tHostileSpawnModifiers, iX, iY);		-- attempt to create hostile(s) adjacent to the former hut
	else
		print("The villagers are unconcerned by the presence of outsiders; no nasty surprises here.");
	end
end

--[[ =========================================================================
	function OnLoadScreenClose() : framework cribbed from [1] and modified
=========================================================================== ]]
function OnLoadScreenClose()
	-- custom hooks should go here unless they need to be somewhere else; OnLoadScreenClose gets hooked to Events.LoadScreenClose in Initialize()
	Events.GoodyHutReward.Add(OnGoodyHutReward);
	Events.TurnBegin.Add(OnTurnBegin);
end

--[[ =========================================================================
	function Initialize()
=========================================================================== ]]
function Initialize()
	print("Initializing HostileVillagers.lua . . .");
	print("---------------------------------------");
	print("Ruleset in use : " .. tostring(m_sRuleset));
	print("No Barbarians : " .. tostring(m_bIsNoBarbarians));
	print("No Goody Huts : " .. tostring(m_bIsNoGoodyHuts));
	print("No Hostile Villagers AFTER Reward : " .. tostring(m_bIsNoHostilesAfterReward));
	print("No Hostile Villagers AS Reward : " .. tostring(m_bIsNoHostilesAsReward));
	print("Defined game era(s) : " .. m_eNumEras .. " ( 0, " .. tostring(m_eNumEras - 1) .. ", 1 )");
	print("Active game era at startup : " .. m_eCurrentEra);
	print("Game turn at startup : " .. m_eCurrentTurn);
	print("Barbarian player ID : " .. m_eBarbarianPlayer);
	print("Goody Hut index : " .. m_eGoodyHut);
	print("Barbarian Camp index : " .. m_eBarbCamp);
	print("Random modifier for hostile villagers : 1 - " .. m_iRandomSeed);
	print("Hostile villager spawn threshold : " .. m_iRandomSeed);
	print("Ignoring first generated random value : " .. m_iDiscardSeed);
	print("---------------------------------------");

	-- event hooks
	Events.LoadScreenClose.Add(OnLoadScreenClose);
end

Initialize();

--[[ =========================================================================
	references
==============================================================================

	[1] web : https://forums.civfanatics.com/threads/getting-an-extra-bonus-from-goody-huts.616695/#post-14780879
	[2] web : https://steamcommunity.com/sharedfiles/filedetails/?id=2164194796
	[3] web : https://forums.civfanatics.com/threads/add-a-feature-to-a-plot-during-game-time-with-lua.645149/#post-15435909
	[4] web : https://forums.civfanatics.com/threads/ongoodyhutreward-event-what-are-the-parameters.642591/#post-15398744
	[5] web : https://forums.civfanatics.com/threads/how-do-you-catch-an-era-change-event-in-lua.614454/#post-15144387

=========================================================================== ]]

--[[ =========================================================================
	end HostileVillagers.lua gameplay script
=========================================================================== ]]
