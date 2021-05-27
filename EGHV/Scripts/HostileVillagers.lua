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

m_eGoodyHutFrequency = GameConfiguration.GetValue("GOODYHUT_FREQUENCY");	-- fetch the goody hut frequency percentage value

m_bIsNoHostilesAfterReward = false;
bIsAlwaysHostilesAfterReward = false;
bIsHyperHostilesAfterReward = false;

-- m_bIsNoHostilesAfterReward = GameConfiguration.GetValue("GAME_NO_HOSTILES_AFTER_REWARD");		-- fetch the value of the "No Hostiles After Reward" setup option
-- m_bIsNoHostilesAsReward = GameConfiguration.GetValue("GAME_NO_HOSTILES_AS_REWARD");
m_bIsRewardsEqualized = GameConfiguration.GetValue("GAME_EQUALIZE_GOODY_HUTS");					-- fetch the value of the "Equalize Rewarc chances" setup option

iHostilesAfterReward = GameConfiguration.GetValue("GAME_HOSTILES_CHANCE");
if (iHostilesAfterReward == 1) then
	m_bIsNoHostilesAfterReward = true;
elseif (iHostilesAfterReward == 3) or (iHostilesAfterReward == 4) then
	bIsAlwaysHostilesAfterReward = true;
	if (iHostilesAfterReward == 4) then bIsHyperHostilesAfterReward = true; end
end

m_eNumEras = 0;						-- the minimum number of in-game era(s) needs to be 1 or shit breaks

m_kEras = {};
for row in GameInfo.Eras() do
	m_eNumEras = m_eNumEras + 1;
	m_kEras[(row.ChronologyIndex - 1)] = row.EraType;
end

-- table of era starts; key = game turn, value = era that begins on that turn
-- this is a kludge, and is not entirely accurate, but is currently necessary for the script to function with the Standard ruleset; will be ignored if a different ruleset is in use
m_kEraStartTurns = { [1] = 0, [76] = 1, [136] = 2, [196] = 3, [256] = 4, [316] = 5, [376] = 6, [436] = 7 };

m_eCurrentEra = 0;									-- set the default era to 0; set the actual current game era below after determining the ruleset in use
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
m_kDifficultyLevels = {};
m_eNumDifficultyLevels = 0;
for row in GameInfo.Difficulties() do
	m_eNumDifficultyLevels = m_eNumDifficultyLevels + 1;
	m_kDifficultyLevels[DB.MakeHash(row.DifficultyType)] = { DifficultyType = row.DifficultyType, Level = m_eNumDifficultyLevels };
end

m_eDifficultyHash = PlayerConfigurations[0]:GetHandicapTypeID();				-- fetch the current difficulty level's hash value
m_eHostileSpawnDifficultyModifier = m_kDifficultyLevels[m_eDifficultyHash].Level;		-- fetch the current difficulty level

-- table of individual melee units to spawn; key = era to spawn in, value = unit to spawn
m_kHostileMeleeByEra = { [0] = "UNIT_WARRIOR", [1] = "UNIT_WARRIOR", [2] = "UNIT_SWORDSMAN", [3] = "UNIT_MAN_AT_ARMS", [4] = "UNIT_MUSKETMAN", [5] = "UNIT_LINE_INFANTRY", [6] = "UNIT_INFANTRY", [7] = "UNIT_INFANTRY", [8] = "UNIT_INFANTRY" };

-- ** 2021/04/22 ** ranged units spawned by this script don't seem to do anything but wait for death
-- table of individual ranged units to spawn; key = era to spawn in, value = unit to spawn
m_kHostileRangedByEra = { [0] = "UNIT_SLINGER", [1] = "UNIT_ARCHER", [2] = "UNIT_ARCHER", [3] = "UNIT_CROSSBOWMAN", [4] = "UNIT_CROSSBOWMAN", [5] = "UNIT_FIELD_CANNON", [6] = "UNIT_FIELD_CANNON", [7] = "UNIT_MACHINE_GUN", [8] = "UNIT_MACHINE_GUN" };

-- table of goody hut types; key = reward hash value from Events.GoodyHutReward, value = associated goody hut type
m_kGoodyHutTypes = {};
m_eNumGoodyHutTypes = 0;
for row in GameInfo.GoodyHuts() do
	m_eNumGoodyHutTypes = m_eNumGoodyHutTypes + 1;
	m_kGoodyHutTypes[DB.MakeHash(row.GoodyHutType)] = row.GoodyHutType;
end

--[[ =========================================================================
	the big stupid table of goody hut reward data : framework cribbed from [4] and modified
		key = subtype hash value from Events.GoodyHutReward, value = a small stupid table of associated reward data :
			GoodyHut is the type of goody hut reward
			SubTypeGoodyHut is the specific goody hut reward associated with this key
			Weight is the Weight value for this specific reward, as defined in the gameplay database
			Tier is the rarity value of this specific reward, based on its Weight value, generally from 6 (extremely common) to 1 (extremely rare)
			Description is the tag from the localization database to use as the body of any notification sent to the panel
=========================================================================== ]]
m_kGoodyHutRewardInfo = {};
m_eNumGoodyHutRewards = 0;
local iSubTypeHash = 0;
for row in GameInfo.GoodyHutSubTypes() do
	m_eNumGoodyHutRewards = m_eNumGoodyHutRewards + 1;
	iSubTypeHash = DB.MakeHash(row.SubTypeGoodyHut);
	m_kGoodyHutRewardInfo[iSubTypeHash] = { GoodyHut = row.GoodyHut, SubTypeGoodyHut = row.SubTypeGoodyHut, Weight = row.Weight, Tier = 0, Description = row.Description };
	if (row.SubTypeGoodyHut == "GOODYHUT_SPAWN_HOSTILE_VILLAGERS") then m_kGoodyHutRewardInfo[iSubTypeHash].Tier = 0;				-- maximum hostility for guaranteed hostile villagers rewards
	elseif (row.SubTypeGoodyHut == "METEOR_GRANT_GOODIES") then m_kGoodyHutRewardInfo[iSubTypeHash].Tier = row.Weight;					-- super-low hostility for meteor-strike rewards
	elseif (row.GoodyHut == "GOODYHUT_MILITARY") then m_kGoodyHutRewardInfo[iSubTypeHash].Tier = math.floor(row.Weight / 10);
	elseif (row.GoodyHut == "GOODYHUT_CULTURE" or row.GoodyHut == "GOODYHUT_DIPLOMACY" or row.GoodyHut == "GOODYHUT_FAITH" or row.GoodyHut == "GOODYHUT_GOLD" or row.GoodyHut == "GOODYHUT_SCIENCE" or row.GoodyHut == "GOODYHUT_SURVIVORS") then m_kGoodyHutRewardInfo[iSubTypeHash].Tier = math.floor(row.Weight / 20);
	elseif (row.Weight >= 100) then m_kGoodyHutRewardInfo[iSubTypeHash].Tier = 1;					-- near-maximum hostility for any other rewards with a defined large weight
	else m_kGoodyHutRewardInfo[iSubTypeHash].Tier = 2;				-- default rarity tier for unknown rewards, results in high hostility
	end
end
iSubTypeHash = nil;

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
		local sEraChangedMessage = "Turn " .. iTurn .. " : The current game era has changed from " .. m_kEras[iPreviousEra] .. " to " .. m_kEras[m_eCurrentEra];
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

-- fetch the Barbarian player ID here if 'No Barbarians' is NOT enabled
if not m_bIsNoBarbarians then m_eBarbarianPlayer = GetBarbarianId(); end

--[[ =========================================================================
	function ValidateAdjacentPlots() : framework cribbed from [3] and modified
=========================================================================== ]]
function ValidateAdjacentPlots(iX, iY)
	local tValidPlots = {};
	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
		local adjacentPlot = Map.GetAdjacentPlot(iX, iY, direction);
		if adjacentPlot and ImprovementBuilder.CanHaveImprovement(adjacentPlot, m_eBarbCamp, -1) then
			-- print("Plot (x " .. adjacentPlot:GetX() .. ", y " .. adjacentPlot:GetY() .. ") is a valid location for a barbarian camp");
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
	if bIsHyperHostilesAfterReward then iHostilityCurrentLevel = iHostilityCurrentLevel + 500; end

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
			if m_bIsNoHostilesAsReward or GameConfiguration.GetValue("EXCLUDE_GOODYHUT_SPAWN_HOSTILE_VILLAGERS") == 1 then		-- 2021/05/16 : not sure if this still fires
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

	-- local iDifficultyHash = PlayerConfigurations[iPlayerID]:GetHandicapTypeID();				-- fetch the current difficulty hash
	local iHostileSpawnDifficultyModifier = m_eHostileSpawnDifficultyModifier;		-- fetch the current difficulty level
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
	if bIsAlwaysHostilesAfterReward then iHostileSpawnChance = iHostileSpawnChance + 100; end		-- inflate this value if "Always Hostiles After Reward" is enabled
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
function Initialize( bIsDebugEnabled )
	local sRowOfDashes = "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -";
	print(sRowOfDashes);
	print(" Initializing HostileVillagers.lua . . .");
	print(sRowOfDashes);
	print(" Ruleset in use : " .. tostring(m_sRuleset));
	print(" No Barbarians : " .. tostring(m_bIsNoBarbarians));
	if not m_bIsNoBarbarians then
		print("   Barbarian player ID : " .. m_eBarbarianPlayer);
		print("   Barbarian Camp index : " .. m_eBarbCamp);
	end
	print(sRowOfDashes);
	print(" Available difficulty level(s) : " .. m_eNumDifficultyLevels);
	if bIsDebugEnabled then
		for k, v in pairs(m_kDifficultyLevels) do
			print("   [" .. k .. "] = " .. v.DifficultyType .. " (" .. v.Level .. ")");
		end
	end
	print(" Selected difficulty level : " .. m_kDifficultyLevels[m_eDifficultyHash].DifficultyType .. " (" .. m_kDifficultyLevels[m_eDifficultyHash].Level .. ")");
	print(" Number of defined game era(s) : " .. m_eNumEras .. " ( 0, " .. tostring(m_eNumEras - 1) .. ", 1 )");
	if bIsDebugEnabled then
		for i, v in ipairs(m_kEras) do
			print("   [" .. i .. "] = " .. v);
		end
	end
	print(" Active game era at startup : " .. m_kEras[m_eCurrentEra] .. " (" .. m_eCurrentEra .. ")");
	print(" Game turn at startup : " .. m_eCurrentTurn);
	print(sRowOfDashes);
	print(" No Goody Huts : " .. tostring(m_bIsNoGoodyHuts));
	if not m_bIsNoGoodyHuts then
		print("   Goody Hut frequency : " .. tostring(m_eGoodyHutFrequency) .. " %% 'normal' distribution");
		print("   Equalize all Reward chances : " .. tostring(m_bIsRewardsEqualized));
		if not m_bIsNoBarbarians then
			print("   Never Hostile Villagers after reward : " .. tostring(m_bIsNoHostilesAfterReward));
			print("   Always Hostile Villagers after reward : " .. tostring(bIsAlwaysHostilesAfterReward));
			print("   Hyper Hostile Villagers after reward : " .. tostring(bIsHyperHostilesAfterReward));
			-- print("   No Hostile Villagers AS Reward : " .. tostring(m_bIsNoHostilesAsReward));
		end
		print("   Goody Hut index : " .. m_eGoodyHut);
		print("   Number of defined Goody Hut type(s) : " .. m_eNumGoodyHutTypes);
		if bIsDebugEnabled and (m_eNumGoodyHutTypes > 0) then
			for k, v in pairs(m_kGoodyHutTypes) do
				print("     [" .. k .. "] = " .. v);
			end
		end
		print("   Number of defined Goody Hut subtype(s) : " .. m_eNumGoodyHutRewards);
		if bIsDebugEnabled and (m_eNumGoodyHutRewards > 0) then
			for k, v in pairs(m_kGoodyHutRewardInfo) do
				print("     [" .. k .. "] = Subtype : " .. v.SubTypeGoodyHut .. ", Tier : " .. v.Tier);
			end
		end
	end
	print(sRowOfDashes);
	print(" Random modifier for hostile villagers : 1 - " .. m_iRandomSeed);
	print(" Hostile villager spawn threshold : " .. m_iRandomSeed);
	print(" Ignoring first generated random value : " .. m_iDiscardSeed);
	-- events hooks
	print(" Adding Events hooks . . .");
	Events.LoadScreenClose.Add(OnLoadScreenClose);
	print(sRowOfDashes);
	sRowOfDashes = nil;
end

Initialize(false);
-- Initialize(true);

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
