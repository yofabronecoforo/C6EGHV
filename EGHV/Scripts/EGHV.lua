--[[ =========================================================================
	C6GUE : Gameplay and Usability Enhancements for Civilization VI
	Copyright (C) 2020-2023 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin EGHV.lua gameplay script
=========================================================================== ]]

--[[ =========================================================================
	context sharing : initialize and/or fetch ExposedMembers here
	pre-init+ : these should be defined prior to any exposed globals
=========================================================================== ]]
-- fetch or initialize global exposed members
if not ExposedMembers.GUE then ExposedMembers.GUE = {}; end
GUE = ExposedMembers.GUE;
-- fetch any available Wondrous Goody Hut exposed members
WGH = ExposedMembers.WGH;

--[[ =========================================================================
	exposed globals : define any needed C6GUE globally shared component(s) here
	pre-init : these should be defined prior to Initialize()
=========================================================================== ]]
-- DebugEnabled is the global Debug flag; DebugPrint() successfully outputs if true ** 2021/09/21 this is now configured via a Frontend UI setting **
-- GUE.DebugEnabled = false;		-- legacy setting preserved for posterity ** 2021/09/21 uncommenting this will likely have undesired effects, so leave it alone **
GUE.DebugEnabled = GameConfiguration.GetValue("GAME_EGHV_DEBUG");

-- exposed member function DebugPrint( sMessage ) : print sMessage to the log file if DebugEnabled == true
function GUE.DebugPrint( sMessage ) if GUE.DebugEnabled then print("[DEBUG]: " .. sMessage); end end

-- make DebugPrint() more conveniently globally accessible, as otherwise this declaration must be made in a local scope within each function below
Dprint = GUE.DebugPrint;

-- RowOfDashes is exactly what it says on the tin
GUE.RowOfDashes = "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -";

-- the ruleset in use at startup; this influences other options
GUE.Ruleset = GameConfiguration.GetValue("RULESET");

-- fetch the current global era if a non-Standard ruleset is in use
GUE.CurrentEra = (GUE.Ruleset ~= "RULESET_STANDARD") and Game.GetEras():GetCurrentEra() or nil;

-- retrieve the current game turn
GUE.CurrentTurn = Game.GetCurrentGameTurn();

-- the big stupid table of difficulty levels; key = hash value returned by PlayerConfigurations:GetHandicapTypeID(), value = table of associated difficulty levels
GUE.DifficultyLevels = {};
for row in GameInfo.Difficulties() do GUE.DifficultyLevels[DB.MakeHash(row.DifficultyType)] = { DifficultyType = row.DifficultyType, Modifier = row.Index + 1 }; end

-- the number of available difficulty levels should equal the number of rows in the previous table
GUE.NumDifficultyLevels = #GUE.DifficultyLevels;

-- the big stupid table of game eras; key = Era, value = EraType
GUE.Eras = {};
for row in GameInfo.Eras() do GUE.Eras[(row.ChronologyIndex - 1)] = row.EraType; end

-- the number of available eras should equal the number of rows in the previous table
GUE.NumEras = #GUE.Eras;

-- initialize Barbarian and Free Cities Player ID values here. if these don't subsequently change, either they aren't present, or something is wrong
GUE.BarbarianID, GUE.FreeCitiesID = -1, -1;

-- user-selected number of City-States for the current session
GUE.CityStatesCount = GameConfiguration.GetValue("CITY_STATE_COUNT");

-- player Event queues; index -1 should represent rewards from huts popped via border expansion
GUE.PlayerEventQueues = {};
GUE.PlayerEventQueues[-1] = {};
GUE.PlayerEventQueues[-1].GoodyHutReward, GUE.PlayerEventQueues[-1].ImprovementActivated = {}, {};

-- set Major Player current Era for Standard ruleset
-- set Difficulty modifier and type here, based on the HandicapTypeID hash value
-- identify the actual Barbarian and Free Cities Player IDs, if they exist
-- generate an informational string for each identified Player to display during initialization
GUE.NumPlayers, GUE.NumCityStates = 0, 0;
GUE.PlayerInfo = {};
for p = 0, 63 do 
	local pPlayer, pPlayerConfig = Players[p], PlayerConfigurations[p];
	if (pPlayer ~= nil) and (pPlayerConfig ~= nil) then 
		local sCivTypeName = pPlayerConfig:GetCivilizationTypeName();
		local sPlayerInfo = "Player " .. p .. ": ";
		if pPlayer:IsMajor() then 
			local sHumanOrAI = pPlayer:IsHuman() and "Human" or "AI";
			sPlayerInfo = sPlayerInfo .. sHumanOrAI .. " Major (" .. sCivTypeName .. ")";
			pPlayer:SetProperty("DifficultyType", GUE.DifficultyLevels[pPlayerConfig:GetHandicapTypeID()].DifficultyType);
			pPlayer:SetProperty("Difficulty", GUE.DifficultyLevels[pPlayerConfig:GetHandicapTypeID()].Modifier);
			sPlayerInfo = sPlayerInfo .. " | Difficulty " .. pPlayer:GetProperty("Difficulty") .. " (" .. pPlayer:GetProperty("DifficultyType") .. ")";
			if pPlayer:GetProperty("VillagerSecretsLevel") == nil then
				pPlayer:SetProperty("VillagerSecretsLevel", -1);
			end
			if (GUE.Ruleset == "RULESET_STANDARD") then 
				pPlayer:SetProperty("Era", pPlayer:GetEras():GetEra()); 
				sPlayerInfo = sPlayerInfo .. " | Era " .. pPlayer:GetProperty("Era") .. " (" .. GUE.Eras[pPlayer:GetProperty("Era")] .. ")";
			end
			GUE.PlayerEventQueues[p] = {};
			GUE.PlayerEventQueues[p].GoodyHutReward, GUE.PlayerEventQueues[p].ImprovementActivated = {}, {};
			GUE.NumPlayers = GUE.NumPlayers + 1;
		elseif (sCivTypeName == "CIVILIZATION_FREE_CITIES") then 
			GUE.FreeCitiesID = p;
			sPlayerInfo = sPlayerInfo .. "Free Cities (" .. sCivTypeName .. ") ";
		elseif pPlayer:IsBarbarian() then 
			GUE.BarbarianID = p;
			sPlayerInfo = sPlayerInfo .. "Barbarians (" .. sCivTypeName .. ") ";
		elseif (sCivTypeName ~= nil) then 
			local sActiveOrReserved = (GUE.NumCityStates < GUE.CityStatesCount) and "active" or "reserved by game mode";
			sPlayerInfo = sPlayerInfo .. "City-State (" .. sCivTypeName .. ") is ".. sActiveOrReserved .. " at startup";
			GUE.NumCityStates = GUE.NumCityStates + 1;
		end
		table.insert(GUE.PlayerInfo, sPlayerInfo);
	end
end

-- fetch the value of the 'No Barbarians' setup option
GUE.NoBarbarians = GameConfiguration.GetValue("GAME_NO_BARBARIANS");

-- the database index value of the Barbarian Camp improvement, if applicable
if not GUE.NoBarbarians then GUE.BarbCampIndex = GameInfo.Improvements["IMPROVEMENT_BARBARIAN_CAMP"].Index; end

-- fetch the value of the 'No Tribal Villages' setup option
GUE.NoGoodyHuts = GameConfiguration.GetValue("GAME_NO_GOODY_HUTS");

-- initialize table of Wondrous Goody Hut rewared abilities; key = ModifierID, value = AbilityType
GUE.WGH_ModifierToAbility = { 
	["SAILOR_GOODY_RANDOMRESOURCE_SWITCH"] = "ABILITY_SAILOR_GOODY_RANDOMRESOURCE", ["SAILOR_GOODY_RANDOMUNIT_SWITCH"] = "ABILITY_SAILOR_GOODY_RANDOMUNIT", 
	["SAILOR_GOODY_RANDOMIMPROVEMENT_SWITCH"] = "ABILITY_SAILOR_GOODY_RANDOMIMPROVEMENT", ["SAILOR_GOODY_SIGHTBOMB_SWITCH"] = "ABILITY_SAILOR_GOODY_SIGHTBOMB", 
	["SAILOR_GOODY_RANDOMPOLICY_SWITCH"] = "ABILITY_SAILOR_GOODY_RANDOMPOLICY", ["SAILOR_GOODY_FORMATION_SWITCH"] = "ABILITY_SAILOR_GOODY_FORMATION", 
	["SAILOR_GOODY_WONDER_SWITCH"] = "ABILITY_SAILOR_GOODY_WONDER", ["SAILOR_GOODY_CITYSTATE_SWITCH"] = "ABILITY_SAILOR_GOODY_CITYSTATE", 
	["SAILOR_GOODY_SPY_SWITCH"] = "ABILITY_SAILOR_GOODY_SPY", ["SAILOR_GOODY_PRODUCTION_SWITCH"] = "ABILITY_SAILOR_GOODY_PRODUCTION", 
	["SAILOR_GOODY_TELEPORT_SWITCH"] = "ABILITY_SAILOR_GOODY_TELEPORT"
};

-- initialize table of fallback rewards; these will be used when the reward roller can't find a valid reward within the defined number of attempts
GUE.FallbackRewards = {};

-- initialize table of Wondrous Goody Hut rewards; this will be used for bonus reward purposes, and will be keyed to reward SubType
GUE.WGH_IsEnabled = false;
GUE.WGH_Rewards = {};

-- 
GUE.RewardTypeFunction = {};
GUE.GrantReward = {};

-- fetch additional info related to Goody Huts when 'No Tribal Villages' is NOT enabled
if not GUE.NoGoodyHuts then 
	-- the database index value of the Goody Hut improvement
	GUE.GoodyHutIndex = GameInfo.Improvements["IMPROVEMENT_GOODY_HUT"].Index;
	-- fetch the goody hut frequency percentage value
	GUE.GoodyHutFrequency = GameConfiguration.GetValue("GOODYHUT_FREQUENCY");
	-- the number of potential bonus rewards is the value of the "rewards per tribal village" game setting, minus 1
	GUE.BonusRewardsPerGoodyHut = GameConfiguration.GetValue("GAME_TOTAL_REWARDS") - 1;
	-- the number of available rewards in the bonus rewards table
	GUE.NumBonusRewards = 0;
	-- fetch the value of the 'Equalize Reward chances' setup option
	GUE.EqualizeRewards = GameConfiguration.GetValue("GAME_EQUALIZE_GOODY_HUTS");
	-- disable low hostility villagers if this "reward" was excluded via the Frontend picker
	GUE.LowHostilityAsReward = (GameConfiguration.GetValue("EXCLUDE_GOODYHUT_LOW_HOSTILITY_VILLAGERS") ~= 1) and true or false;
	-- disable mid hostility villagers if this "reward" was excluded via the Frontend picker
	GUE.MidHostilityAsReward = (GameConfiguration.GetValue("EXCLUDE_GOODYHUT_MID_HOSTILITY_VILLAGERS") ~= 1) and true or false;
	-- disable high hostility villagers if this "reward" was excluded via the Frontend picker
	GUE.HighHostilityAsReward = (GameConfiguration.GetValue("EXCLUDE_GOODYHUT_HIGH_HOSTILITY_VILLAGERS") ~= 1) and true or false;
	-- disable max hostility villagers if this "reward" was excluded via the Frontend picker
	GUE.MaxHostilityAsReward = (GameConfiguration.GetValue("EXCLUDE_GOODYHUT_MAX_HOSTILITY_VILLAGERS") ~= 1) and true or false;
	-- disable Hostile Villagers As Reward completely if all of the available Hostiles "rewards" were excluded via the Frontend picker
	GUE.HostilesAsReward = (GUE.LowHostilityAsReward or GUE.MidHostilityAsReward or GUE.HighHostilityAsReward or GUE.MaxHostilityAsReward) and true or false;
	-- fetch the value of the 'Hostiles After Reward' setup option; default value is 2 (for Maybe), when applicable
	GUE.HostilesAfterReward = GameConfiguration.GetValue("GAME_HOSTILES_CHANCE");
	-- the big stupid table of villager hostility after a reward; key = value of GAME_HOSTILES_CHANCE, value = hostility level
	GUE.HostilityLevels = { [1] = "Never", [2] = "Maybe", [3] = "Always", [4] = "Hyper" };
	-- initialize tables for valid (active) goody hut reward types and subtypes
	GUE.ValidBonusTypes, GUE.ValidBonusRewards = {}, {};
	-- initialize the exclusion tables; these contain any reward(s) that should not be granted as a bonus reward
	GUE.ExcludedRewardTypes, GUE.ExcludedRewards = { ["METEOR_GOODIES"] = "" }, { ["METEOR_GRANT_GOODIES"] = "" };
	-- the total number of available and active goody hut type(s) - these are the categories that individual rewards belong to
	GUE.NumGoodyHutTypes, GUE.ActiveGoodyHutTypes = 0, 0;
	-- identify active and valid bonus reward types
	for row in GameInfo.GoodyHuts() do 
		GUE.NumGoodyHutTypes = GUE.NumGoodyHutTypes + 1;
		-- increment the active types counter if the weight of this type is greater than zero
		if (row.Weight > 0) then 
			GUE.ActiveGoodyHutTypes = GUE.ActiveGoodyHutTypes + 1; 
			-- also add this type to the tables of valid bonus types and valid bonus rewards if it is not an excluded type
			if not GUE.ExcludedRewardTypes[row.GoodyHutType] then 
				table.insert(GUE.ValidBonusTypes, row.GoodyHutType); 
				GUE.ValidBonusRewards[row.GoodyHutType] = {};
			end
		end
	end
	-- the total number of available and active goody hut subtype(s) - these are the actual individual rewards
	GUE.NumGoodyHutRewards, GUE.ActiveGoodyHutRewards = 0, 0;
	-- identify active, fallback, Wondrous-type, and valid bonus reward subtypes
	for row in GameInfo.GoodyHutSubTypes() do 
		GUE.NumGoodyHutRewards = GUE.NumGoodyHutRewards + 1;
		-- identify fallback rewards
		if row.GoodyHut == "GOODYHUT_FALLBACK" then 
			table.insert(GUE.FallbackRewards, row);
		-- identify needed Wondrous data
		elseif row.GoodyHut == "GOODYHUT_SAILOR_WONDROUS" then 
			if not GUE.WGH_IsEnabled then GUE.WGH_IsEnabled = true; end
			GUE.WGH_Rewards[row.SubTypeGoodyHut] = { TypeHash = DB.MakeHash(row.GoodyHut), SubTypeHash = DB.MakeHash(row.SubTypeGoodyHut), ModifierID = row.ModifierID, AbilityType = GUE.WGH_ModifierToAbility[row.ModifierID] }; 
		end
		-- increment the active subtypes counter if the weight of this subtype is greater than zero
		if (row.Weight > 0) then 
			GUE.ActiveGoodyHutRewards = GUE.ActiveGoodyHutRewards + 1; 
			-- also add this subtype to the table of valid bonus subtypes if it is not an excluded type
			if not GUE.ExcludedRewards[row.SubTypeGoodyHut] then 
				GUE.ValidBonusRewards[row.GoodyHut][row.Tier] = GUE.ValidBonusRewards[row.GoodyHut][row.Tier] and GUE.ValidBonusRewards[row.GoodyHut][row.Tier] or {};
				table.insert(GUE.ValidBonusRewards[row.GoodyHut][row.Tier], row.SubTypeGoodyHut);
				GUE.NumBonusRewards = GUE.NumBonusRewards + 1;
			end
		end
	end
end

--[[ =========================================================================
	function AddModifierToPlayer( iPlayerID, sModifierID, bIsPermanent )
	attach Modifier with ID sModifierID to Player with ID iPlayerID
	this should be added to ExposedMembers in Initialize()
=========================================================================== ]]
-- function GUE.AddModifierToPlayer( iPlayerID, sModifierID, bIsPermanent )
function GUE.AddModifierToPlayer( iPlayerID, iUnitID, iTypeHash, iSubTypeHash, sRewardSubType, iX, iY, iTurn, iEra, tUnits, iXP, sAbilityType, sModifierID, bIsPermanent )
	Dprint("Calling AddModifierToPlayer() with the following arguments: iPlayerID = " .. iPlayerID .. " | sModifierID = " .. sModifierID .. " | bIsPermanent = " .. tostring(bIsPermanent));
	local pPlayer = Players[iPlayerID];
	if (pPlayer ~= nil) then
		if bIsPermanent then
			Dprint("Successfully fetched player data for Player " .. iPlayerID .. "; determining whether Modifier " .. sModifierID .. " has previously been attached to this Player . . .");
			local PlayerProperty = pPlayer:GetProperty(sModifierID);
			if (PlayerProperty == nil) then
				Dprint("This Modifier has 'NOT' already been attached to this Player; attempting to attach Modifier to Player . . .");
				pPlayer:AttachModifierByID(sModifierID);
				pPlayer:SetProperty(sModifierID, 1);
				Dprint("Modifier " .. sModifierID .. " successfully attached to Player " .. iPlayerID .. "; proceeding . . .");
			else
				Dprint("WARNING AddModifierToPlayer() this Modifier has already been attached to this Player; ignoring this Modifier and aborting");
			end
		else
			pPlayer:AttachModifierByID(sModifierID);
			Dprint("Bonus Goody Hut reward Modifier " .. sModifierID .. " successfully attached to Player " .. iPlayerID .. "; proceeding . . .");
		end
	else
		print("WARNING AddModifierToPlayer() unable to fetch player data for Player " .. iPlayerID .. "; ignoring this Player and aborting");
	end
end

--[[ =========================================================================
	listener function EGHV_OnTurnBegin( iTurn )
	for Expansion1 ruleset and beyond; global Era for all Players
	pre-init: this should be defined prior to Initialize()
=========================================================================== ]]
function EGHV_OnTurnBegin( iTurn )
	GUE.CurrentTurn = iTurn;			-- update the global current turn
	local iPreviousEra = GUE.CurrentEra;
	local iEraThisTurn = Game.GetEras():GetCurrentEra();		-- fetch the current era
	if (iPreviousEra ~= iEraThisTurn) then			-- true when the current era differs from the stored global era
		GUE.CurrentEra = iEraThisTurn;			-- update the global era
		Dprint("Turn " .. tostring(iTurn) .. ": The current global game Era has changed from " .. tostring(GUE.Eras[iPreviousEra]) .. " to " .. tostring(GUE.Eras[iEraThisTurn]));
		if (GUE.HostilesAfterReward > 2) then Dprint("Hostility > 2: Hostile villagers will now appear with increased intensity following most goody hut rewards");
		elseif (GUE.HostilesAfterReward > 1) then Dprint("Hostility > 1: Hostile villagers will now appear with increased frequency and intensity following most goody hut rewards");
		end
	-- else
	-- 	Dprint("Turn " .. tostring(iTurn) .. ": The current global game Era is " .. tostring(GUE.Eras[iEraThisTurn]));
	end
end

--[[ =========================================================================
	listener function EGHV_OnPlayerTurnStarted( iPlayerID )
	for Standard ruleset; per-Player Eras
	pre-init: this should be defined prior to Initialize()
=========================================================================== ]]
function EGHV_OnPlayerTurnStarted( iPlayerID )
	local iTurn = Game.GetCurrentGameTurn();
	if (GUE.CurrentTurn ~= iTurn) then GUE.CurrentTurn = iTurn; end
	local pPlayer = Players[iPlayerID];
	local pPlayerConfig = PlayerConfigurations[iPlayerID];
	if (pPlayer == nil) or (pPlayerConfig == nil) then
		Dprint("Turn " .. tostring(iTurn) .. " | Player " .. tostring(iPlayerID) .. ": Players and/or PlayerConfigurations data is 'nil' for this Player; aborting.");
		return;
	elseif not pPlayer:IsMajor() then	-- exit here if Player is not Major
		return;
	end
	local iPreviousEra = Players[iPlayerID]:GetProperty("Era");
	local iEraThisTurn = pPlayer:GetEras():GetEra();		-- fetch the current era for this Player
	if (iPreviousEra ~= iEraThisTurn) then			-- true when the current era differs from the stored era value for this Player
		Players[iPlayerID]:SetProperty("Era", iEraThisTurn);			-- update the era for this Player
		Dprint("Turn " .. tostring(iTurn) .. " | Player " .. tostring(iPlayerID) .. ": The current Era for this Player has changed from " .. tostring(GUE.Eras[iPreviousEra]) .. " to " .. tostring(GUE.Eras[iEraThisTurn]));
		if (GUE.HostilesAfterReward > 2) then Dprint("Hostility > 2: Hostile villagers will now appear with increased intensity following most goody hut rewards");
		elseif (GUE.HostilesAfterReward > 1) then Dprint("Hostility > 1: Hostile villagers will now appear with increased frequency and intensity following most goody hut rewards");
		end
	-- else
	-- 	Dprint("Turn " .. tostring(iTurn) .. " | Player " .. tostring(iPlayerID) .. ": The current Era for this Player is " .. tostring(GUE.Eras[iEraThisTurn]));
	end
end

--[[ =========================================================================
	listener function EGHV_OnGoodyHutReward( iPlayerID, iUnitID, iTypeHash, iSubTypeHash )
	fires whenever a goody hut is popped, including the meteor strike reward
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
function EGHV_OnGoodyHutReward( iPlayerID, iUnitID, iTypeHash, iSubTypeHash )
	-- abort here if this is the meteor strike reward, as Events.ImprovementActivated does not appear to fire for it, and we don't want to provide bonuses for it anyway
	if (GameInfo.GoodyHutsByHash[iTypeHash].GoodyHutType == "METEOR_GOODIES" and GameInfo.GoodyHutSubTypesByHash[iSubTypeHash].SubTypeGoodyHut == "METEOR_GRANT_GOODIES") then 
		return; 
	end
	Dprint("ENTER OnGoodyHutReward(iPlayerID " .. iPlayerID .. ", iUnitID " .. iUnitID .. ", iTypeHash " .. iTypeHash .. ", iSubTypeHash " .. iSubTypeHash .. ")");
	-- initialize the local event results table and store any pertinent argument(s) therein
	local tGHR = {};
	tGHR.PlayerID, tGHR.UnitID, tGHR.TypeHash, tGHR.SubTypeHash, tGHR.Units = iPlayerID, iUnitID, iTypeHash, iSubTypeHash, { Count = 0 };
	tGHR.IsExpand, tGHR.IsExplore = (iUnitID == -1 and iPlayerID == -1) and true or false, (iUnitID > -1 and iPlayerID > -1) and true or false;
	-- this fires when Events.GoodyHutReward has fired BEFORE Events.ImprovementActivated for this reward
	if (#GUE.PlayerEventQueues[iPlayerID].ImprovementActivated == 0) then 
		-- insert the local table into this Player's GoodyHutReward queue
		table.insert(GUE.PlayerEventQueues[iPlayerID].GoodyHutReward, tGHR);
		Dprint(string.format("GoodyHutReward fired FIRST; arguments pushed to GUE.PlayerEventQueues[%d].GoodyHutReward[%d]", iPlayerID, #GUE.PlayerEventQueues[iPlayerID].GoodyHutReward));
	-- this fires when Events.GoodyHutReward has fired AFTER Events.ImprovementActivated for this reward
	elseif (#GUE.PlayerEventQueues[iPlayerID].ImprovementActivated > 0) then 
		-- fetch the first index from this Player's ImprovementActivated queue, then remove it from said queue
		local tIA = GUE.PlayerEventQueues[iPlayerID].ImprovementActivated[1];
		table.remove(GUE.PlayerEventQueues[iPlayerID].ImprovementActivated, 1);
		Dprint(string.format("GoodyHutReward fired SECOND; arguments pulled from GUE.PlayerEventQueues[%d].ImprovementActivated[1] (%d item(s) remaining in this queue)", iPlayerID, #GUE.PlayerEventQueues[iPlayerID].ImprovementActivated));
		Dprint("Calling ValidateGoodyHutReward() with arguments from both queues . . .");
		-- use the consolidated arguments to validate and execute enhanced method(s), if any, on this reward
		GUE.ValidateGoodyHutReward(tIA, tGHR);
	end
	Dprint("EXIT OnGoodyHutReward()");
end

--[[ =========================================================================
	listener function EGHV_OnImprovementActivated( iX, iY, iOwnerID, iUnitID, iImprovementIndex, iImprovementOwnerID, iActivationType )
	fires whenever an improvement is activated, including any goody hut other than the meteor strike reward
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
function EGHV_OnImprovementActivated( iX, iY, iOwnerID, iUnitID, iImprovementIndex, iImprovementOwnerID, iActivationType )
	-- if the activated improvement IS NOT a barbarian camp AND IS NOT a goody hut, do nothing and abort
	if (iImprovementIndex ~= GUE.BarbCampIndex and iImprovementIndex ~= GUE.GoodyHutIndex) then return; end
	-- initialize flags for a barbarian camp and a goody hut
	local bIsBarbCamp, bIsGoodyHut = (iImprovementIndex == GUE.BarbCampIndex) and true or false, (iImprovementIndex == GUE.GoodyHutIndex) and true or false;
	-- determine whether this player is Sumeria and will generate a goody hut reward from clearing a barbarian camp
	local bIsSumeria = ((iOwnerID > -1 and PlayerConfigurations[iOwnerID] ~= nil and PlayerConfigurations[iOwnerID]:GetCivilizationTypeName() == "CIVILIZATION_SUMERIA") or (iImprovementOwnerID > -1 and PlayerConfigurations[iImprovementOwnerID] and PlayerConfigurations[iImprovementOwnerID]:GetCivilizationTypeName() == "CIVILIZATION_SUMERIA")) and true or false;
	-- if the activated improvement IS a barbarian camp AND this player IS NOT Sumeria, there should be nothing else to catch, so do nothing and abort
	if bIsBarbCamp and not bIsSumeria then return; end
	Dprint("ENTER OnImprovementActivated(iX " .. iX .. ", iY " .. iY .. ", iOwnerID " .. iOwnerID .. ", iUnitID " .. iUnitID .. ", iImprovementIndex " .. iImprovementIndex .. ", iImprovementOwnerID " .. iImprovementOwnerID .. ", iActivationType " .. iActivationType .. ")");
	-- initialize the local event results table and store any pertinent argument(s) therein
	local tIA = {};
	tIA.X, tIA.Y, tIA.OwnerID, tIA.ImprovementOwnerID, tIA.UnitID, tIA.ActivationType, tIA.Units = iX, iY, iOwnerID, iImprovementOwnerID, iUnitID, iActivationType, { Count = 0 };
	tIA.IsExpand, tIA.IsExplore = (iUnitID == -1 and iImprovementOwnerID > -1) and true or false, (iUnitID ~= -1 and iOwnerID > -1) and true or false;
	tIA.IsBarbCamp, tIA.IsGoodyHut, tIA.IsSumeria = bIsBarbCamp, bIsGoodyHut, bIsSumeria;
	-- this fires when Events.ImprovementActivated has fired BEFORE Events.GoodyHutReward for this reward
	if (#GUE.PlayerEventQueues[iOwnerID].GoodyHutReward == 0) then 
		-- insert the local table into this Player's ImprovementActivated queue
		table.insert(GUE.PlayerEventQueues[iOwnerID].ImprovementActivated, tIA);
		Dprint(string.format("ImprovementActivated fired FIRST; arguments pushed to GUE.PlayerEventQueues[%d].ImprovementActivated[%d]", iOwnerID, #GUE.PlayerEventQueues[iOwnerID].ImprovementActivated));
	-- this fires when Events.ImprovementActivated has fired AFTER Events.GoodyHutReward for this reward
	elseif (#GUE.PlayerEventQueues[iOwnerID].GoodyHutReward > 0) then 
		-- fetch the first index from this Player's GoodyHutReward queue, then remove it from said queue
		local tGHR = GUE.PlayerEventQueues[iOwnerID].GoodyHutReward[1];
		table.remove(GUE.PlayerEventQueues[iOwnerID].GoodyHutReward, 1);
		Dprint(string.format("ImprovementActivated fired SECOND; arguments pulled from GUE.PlayerEventQueues[%d].GoodyHutReward[1] (%d item(s) remaining in this queue)", iOwnerID, #GUE.PlayerEventQueues[iOwnerID].GoodyHutReward));
		Dprint("Calling ValidateGoodyHutReward() with arguments from both queues . . .");
		-- use the consolidated arguments to validate and execute enhanced method(s), if any, on this reward
		GUE.ValidateGoodyHutReward(tIA, tGHR);
	end
	Dprint("EXIT OnImprovementActivated()");
end

--[[ =========================================================================
	listener function EGHV_OnPlayerTurnDeactivated( iPlayerID )
	resets event argument queue(s) if their counts differ at the end of a Player's turn
	when this fires, some enhanced method(s) may not fire on any orphaned reward(s), and earlier enhanced method(s) may not have been entirely accurate in their delivery
		however, this should prevent similar future problem(s), unless the queues become misaligned again, in which case we end up back here
	as the queue(s) usually properly maintain themselves, this should only fire in rare circumstances; multiple firings in a session indicate something screwy in that session
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
function EGHV_OnPlayerTurnDeactivated( iPlayerID )
	-- exit here if Player is not Major
	if not Players[iPlayerID]:IsMajor() then return; end
	-- this fires when these queue(s) are misaligned in any way at end-of-turn
	if #GUE.PlayerEventQueues[iPlayerID].GoodyHutReward ~= #GUE.PlayerEventQueues[iPlayerID].ImprovementActivated then 
		-- reset argument queue(s), and initialize or increment the forced resets tracker
		GUE.PlayerEventQueues[iPlayerID].GoodyHutReward, GUE.PlayerEventQueues[iPlayerID].ImprovementActivated, GUE.ForcedQueueResets = {}, {}, (GUE.ForcedQueueResets) and GUE.ForcedQueueResets + 1 or 1;
		-- define function entry message(s)
		local sPriEntryMsg = "ERROR EG_OnPlayerTurnDeactivated() Resetting misaligned argument queue(s) at end-of-turn for iPlayerID " .. iPlayerID .. "; this has now happened " .. GUE.ForcedQueueResets 
			.. " total time(s) this session";
		-- print entry message(s) to the log when debugging
		print(sPriEntryMsg);
	end
end

--[[ =========================================================================
	function Initialize() : framework cribbed and modified
	this configures needed script components for use ingame
=========================================================================== ]]
function Initialize()
    print(GUE.RowOfDashes);
    print("Loading EGHV gameplay script EGHV.lua . . .");
    print(GUE.RowOfDashes);
	Dprint("Available Player(s):");
	for i, v in ipairs(GUE.PlayerInfo) do Dprint(v); end
    print("There are " .. GUE.NumPlayers .. " active major Player(s) and " .. GUE.CityStatesCount .. "/" .. GUE.NumCityStates .. " active/total City-State(s) at startup");
    print("Selected ruleset at startup: " .. GUE.Ruleset);
    if (GUE.Ruleset ~= "RULESET_STANDARD") then print("Global game Era at startup: " .. GUE.CurrentEra .. " (" .. GUE.Eras[GUE.CurrentEra] .. ")"); end
    print("Game turn at startup: " .. GUE.CurrentTurn);
    print(GUE.RowOfDashes);
    print("Configuring required hook(s) for ingame Event(s) . . .");
	if (GUE.Ruleset == "RULESET_STANDARD") then
		GameEvents.PlayerTurnStarted.Add(EGHV_OnPlayerTurnStarted);
		Dprint("Standard ruleset in use: EGHV_OnPlayerTurnStarted() successfully hooked to GameEvents.PlayerTurnStarted");
	else
		Events.TurnBegin.Add(EGHV_OnTurnBegin);
		Dprint("Non-Standard ruleset in use: EGHV_OnTurnBegin() successfully hooked to Events.TurnBegin");
	end
    Events.GoodyHutReward.Add(EGHV_OnGoodyHutReward);
    Dprint("EGHV_OnGoodyHutReward() successfully hooked to Events.GoodyHutReward");
    Events.ImprovementActivated.Add(EGHV_OnImprovementActivated);
    Dprint("EGHV_OnImprovementActivated() successfully hooked to Events.ImprovementActivated");
    Events.PlayerTurnDeactivated.Add(EGHV_OnPlayerTurnDeactivated);
    Dprint("EGHV_OnPlayerTurnDeactivated() successfully hooked to Events.PlayerTurnDeactivated");
    print(GUE.RowOfDashes);
	if GUE.WGH_IsEnabled then 
		include("Sailor_Goodies_Scripts_EGHV");
		print("Wondrous Goody Huts integration is enabled");
		print(GUE.RowOfDashes);
	end
	print("EGHV configuration complete. Proceeding . . .");
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
	end EGHV.lua gameplay script
=========================================================================== ]]
