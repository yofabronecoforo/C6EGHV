--[[ =========================================================================
	C6GUE : Gameplay and Usability Enhancements for Civilization VI
	Copyright (C) 2020-2021 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin gameplay script
=========================================================================== ]]

--[[ =========================================================================
	context sharing : initialize and/or fetch ExposedMembers here
	pre-init+ : these should be defined prior to any exposed globals
=========================================================================== ]]
-- fetch or initialize global exposed members
if not ExposedMembers.GUE then ExposedMembers.GUE = {}; end
GUE = ExposedMembers.GUE;

--[[ =========================================================================
	exposed globals : define any needed C6GUE globally shared component(s) here
	pre-init : these should be defined prior to Initialize()
=========================================================================== ]]
-- exposed member function DebugPrint( sMessage ) : print sMessage to the log file if DebugEnabled == true
function GUE.DebugPrint( sMessage ) if GUE.DebugEnabled then print("[DEBUG]: " .. sMessage); end end
-- DebugEnabled is the global Debug flag; DebugPrint() successfully outputs if true ** 2021/09/21 this is now configured via a Frontend UI setting **
-- GUE.DebugEnabled = false;		-- legacy setting preserved for posterity ** 2021/09/21 uncommenting this will likely have undesired effects, so leave it alone **
GUE.DebugEnabled = GameConfiguration.GetValue("GAME_EGHV_DEBUG");
-- make DebugPrint() more conveniently globally accessible, as otherwise this declaration must be made in a local scope within each function below
Dprint = GUE.DebugPrint;
-- RowOfDashes is exactly what it says on the tin
GUE.RowOfDashes = "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -";

--[[ =========================================================================
	function GetHostileModifier( tGoodyHutTypes, sGoodyHutType, iWeight ) : 
		fetch the hostile villager modifier for the goody hut reward of Type sGoodyHutType with Weight iWeight
	this should be added to ExposedMembers in Initialize()
=========================================================================== ]]
function GUE.GetHostileModifier( tGoodyHutTypes, sGoodyHutType, iWeight )
	local iTypeWeight = tGoodyHutTypes[DB.MakeHash(sGoodyHutType)].Weight;
	if (iWeight == 0) then return 0;
	elseif (iWeight >= iTypeWeight) or (iWeight >= 100) then return 5;
	elseif (sGoodyHutType == "METEOR_GOODIES") then return -1;
	elseif (sGoodyHutType == "GOODYHUT_MILITARY") then 
		if (iWeight >= 20) then return 1;
		elseif (iWeight >= 15) then return 2;
		elseif (iWeight >= 10) then return 3;
		elseif (iWeight >= 5) then return 4;
		elseif (iWeight >= 1) then return 5;
		else return "'* UNRECOGNIZED *'";
		end
	elseif (iWeight >= 40) then return 1;
	elseif (iWeight >= 30) then return 2;
	elseif (iWeight >= 20) then return 3;
	elseif (iWeight >= 10) then return 4;
	elseif (iWeight >= 1) then return 5;
	else return "'* UNRECOGNIZED *'";
	end
end

--[[ =========================================================================
	function GetRewardTier( sGoodyHutType, iWeight ) : 
		fetch the named tier for the goody hut reward of Type sGoodyHutType with Weight iWeight
	this should be added to ExposedMembers in Initialize()
=========================================================================== ]]
function GUE.GetRewardTier( sGoodyHutType, iWeight )
	if (iWeight == 0) then return "'Disabled'";
	elseif (iWeight >= 100) then return "Specialized";
	elseif (sGoodyHutType == "GOODYHUT_MILITARY") then 
		if (iWeight >= 20) then return "Common";
		elseif (iWeight >= 15) then return "Uncommon";
		elseif (iWeight >= 10) then return "Rare";
		elseif (iWeight >= 5) then return "Legendary";
		elseif (iWeight >= 1) then return "Mythic";
		else return "'* UNRECOGNIZED *'";
		end
	elseif (iWeight >= 40) then return "Common";
	elseif (iWeight >= 30) then return "Uncommon";
	elseif (iWeight >= 20) then return "Rare";
	elseif (iWeight >= 10) then return "Legendary";
	elseif (iWeight >= 1) then return "Mythic";
	else return "'* UNRECOGNIZED *'";
	end
end

--[[ =========================================================================
	function GetGoodyHutsData() : 
		fetches the current session's goody-hut-related data
		generates additional log output if DebugEnabled = true
		returns fetched values
	this should be added to ExposedMembers in Initialize()
=========================================================================== ]]
function GUE.GetGoodyHutsData( bIsNoBarbarians )
	-- fetch the value of the 'Equalize Reward chances' setup option
	local bEqualizeRewards = GameConfiguration.GetValue("GAME_EQUALIZE_GOODY_HUTS");
	-- disable low hostility villagers if this "reward" was excluded via the Frontend picker
	local bLowHostilityAsReward = (GameConfiguration.GetValue("EXCLUDE_GOODYHUT_LOW_HOSTILITY_VILLAGERS") ~= 1) and true or false;
	-- disable mid hostility villagers if this "reward" was excluded via the Frontend picker
	local bMidHostilityAsReward = (GameConfiguration.GetValue("EXCLUDE_GOODYHUT_MID_HOSTILITY_VILLAGERS") ~= 1) and true or false;
	-- disable high hostility villagers if this "reward" was excluded via the Frontend picker
	local bHighHostilityAsReward = (GameConfiguration.GetValue("EXCLUDE_GOODYHUT_HIGH_HOSTILITY_VILLAGERS") ~= 1) and true or false;
	-- disable max hostility villagers if this "reward" was excluded via the Frontend picker
	local bMaxHostilityAsReward = (GameConfiguration.GetValue("EXCLUDE_GOODYHUT_MAX_HOSTILITY_VILLAGERS") ~= 1) and true or false;
	-- disable Hostile Villagers As Reward completely if all of the available Hostiles "rewards" were excluded via the Frontend picker
	local bHostilesAsReward = (bLowHostilityAsReward or bMidHostilityAsReward or bHighHostilityAsReward or bMaxHostilityAsReward) and true or false;
	-- fetch the goody hut frequency percentage value
	local iGoodyHutFrequency = GameConfiguration.GetValue("GOODYHUT_FREQUENCY");
	-- the database index value of the Goody Hut improvement
	local iGoodyHutIndex = GameInfo.Improvements["IMPROVEMENT_GOODY_HUT"].Index;
	-- fetch the value of the 'Hostiles After Reward' setup option; default value is 2 (for Maybe), when applicable
	local iHostilesAfterReward = GameConfiguration.GetValue("GAME_HOSTILES_CHANCE");
	-- the total number of available goody hut subtype(s) - these are the actual individual rewards
	local iNumGoodyHutRewards = 0;
	-- the total number of available goody hut type(s) - these are the categories that individual rewards belong to
	local iNumGoodyHutTypes = 0;
	-- the number of enabled goody hut subtype(s)
	local iActiveGoodyHutRewards = 0;
	-- the number of enabled goody hut type(s)
	local iActiveGoodyHutTypes = 0;
	-- the big stupid table of goody hut types data; key = type hash value from Events.GoodyHutReward, value = a small stupid table of associated data
	local tGoodyHutTypes = {};
	for row in GameInfo.GoodyHuts() do
		iNumGoodyHutTypes = iNumGoodyHutTypes + 1;
		tGoodyHutTypes[DB.MakeHash(row.GoodyHutType)] = {
			GoodyHutType = row.GoodyHutType,		-- GoodyHutType is the type of goody hut reward
			Weight = row.Weight			-- Weight is the Weight value for this type; generally, the sum of the Weight value(s) of any associated subtype(s) will equal this value
		};
		if (row.Weight ~= 0) then iActiveGoodyHutTypes = iActiveGoodyHutTypes + 1; end
	end
	-- the big stupid table of goody hut subtype (reward) data; key = subtype hash value from Events.GoodyHutReward, value = a small stupid table of associated data
	local tGoodyHutRewards = tGoodyHutRewards or {};
	for row in GameInfo.GoodyHutSubTypes() do
		iNumGoodyHutRewards = iNumGoodyHutRewards + 1;
		tGoodyHutRewards[DB.MakeHash(row.SubTypeGoodyHut)] = {
			GoodyHut = row.GoodyHut,				-- GoodyHut is the type of goody hut reward
			SubTypeGoodyHut = row.SubTypeGoodyHut,				-- SubTypeGoodyHut is the specific goody hut reward associated with a given hash/key
			Weight = row.Weight,				-- Weight is the Weight value for this specific reward, as defined in the gameplay database
			Tier = GUE.GetRewardTier(row.GoodyHut, row.Weight),
			HostileModifier = GUE.GetHostileModifier(tGoodyHutTypes, row.GoodyHut, row.Weight),
			ModifierID = row.ModifierID,				-- ModifierID is the ingame Modifier that is applied when this specific reward is received
			Description = row.Description,
			BonusModifierID = row.BonusModifierID
		};
		if (row.Weight ~= 0) then iActiveGoodyHutRewards = iActiveGoodyHutRewards + 1; end
	end
	-- the big stupid table of villager hostility after a reward; key = value of iHostilesReward, value = hostility level
	local tHostilityLevels = { [1] = "Never", [2] = "Maybe", [3] = "Always", [4] = "Hyper" };
	-- 
	return iActiveGoodyHutTypes, iActiveGoodyHutRewards, bEqualizeRewards, bHostilesAsReward, iGoodyHutFrequency, iGoodyHutIndex, iHostilesAfterReward, iNumGoodyHutRewards, iNumGoodyHutTypes, tGoodyHutRewards, tGoodyHutTypes, tHostilityLevels;
end

--[[ =========================================================================
	member function GetBarbariansData() : 
		fetches the current session's barbarians-related data
		generates additional log output if DebugEnabled = true
		returns fetched values
=========================================================================== ]]
function GUE.GetBarbariansData()
	-- the database index value of the Barbarian Camp improvement
	local iBarbCampIndex = GameInfo.Improvements["IMPROVEMENT_BARBARIAN_CAMP"].Index;
	Dprint("Barbarian Camp Improvement index: " .. tostring(iBarbCampIndex));
	return iBarbCampIndex;
end

--[[ =========================================================================
	member function GetGameSetupData() : framework cribbed from [4] and modified
		fetches essential game setup options
		generates lots of big stupid tables
		generates lots of additional log output if DebugEnabled = true
		returns generated and fetched values
=========================================================================== ]]
function GUE.GetGameSetupData()
	-- fetch the value of the 'No Barbarians' setup option
	local bNoBarbarians = GameConfiguration.GetValue("GAME_NO_BARBARIANS");
	-- fetch the value of the 'No Tribal Villages' setup option
	local bNoGoodyHuts = GameConfiguration.GetValue("GAME_NO_GOODY_HUTS");
	-- the Barbarians Player ID; default value is 63, when applicable
	local iBarbarianID = 63;
	-- user-selected number of City-States for the current session
	local iCityStatesCount = GameConfiguration.GetValue("CITY_STATE_COUNT");
	-- set the global game era to 0; set the actual current global game era below after determining the ruleset in use
	local iCurrentEra = 0;
	-- retrieve the current game turn at startup
	local iCurrentTurn = Game.GetCurrentGameTurn();
	-- the Free Cities Player ID; default value is 62, when applicable
	local iFreeCitiesID = 62;
	-- the actual number of City-States present will be incremented below, when applicable; when this exceeds iCityStatesCount, the excess are reserved by game mode
	local iNumCityStates = 0;
	-- the number of available difficulty levels
	local iNumDifficultyLevels = 0;
	-- the number of in-game era(s)
	local iNumEras = 0;
	-- the number of major Player(s)
	local iNumPlayers = 0;
	-- the ruleset in use at startup; this influences other options
	local sRuleset = GameConfiguration.GetValue("RULESET");
	-- the big stupid table of City-States info; data for present City-States goes here
	local tCityStatesData = {};
	-- the big stupid table of difficulty levels; key = hash value from PlayerConfigurations:GetHandicapTypeID(), value = table of associated difficulty levels
	local tDifficultyLevels = {};
	for row in GameInfo.Difficulties() do
		iNumDifficultyLevels = iNumDifficultyLevels + 1;
		tDifficultyLevels[DB.MakeHash(row.DifficultyType)] = { DifficultyType = row.DifficultyType, Modifier = iNumDifficultyLevels };
	end
	-- the big stupid table of game eras; key = Era, value = EraType
	local tEras = {};
	for row in GameInfo.Eras() do
		iNumEras = iNumEras + 1;
		tEras[(row.ChronologyIndex - 1)] = row.EraType;
	end
	-- the big stupid table of major Players info; data for present Major Players goes here
	local tPlayerData = {};
	-- populate big stupid tables
	for p = 0, 63 do
		local pPlayer = Players[p];
		local pPlayerConfig = PlayerConfigurations[p];
		if (pPlayer ~= nil) and (pPlayerConfig ~= nil) then
			local sCivTypeName = pPlayerConfig:GetCivilizationTypeName();
			if pPlayer:IsMajor() then
				tPlayerData[p] = {};
				tPlayerData[p].CivTypeName = sCivTypeName;
				tPlayerData[p].IsMaori = (sCivTypeName == "CIVILIZATION_MAORI") and true or false;
				tPlayerData[p].IsSumeria = (sCivTypeName == "CIVILIZATION_SUMERIA") and true or false;
				tPlayerData[p].DifficultyHash = pPlayerConfig:GetHandicapTypeID();
				tPlayerData[p].DifficultyType = tDifficultyLevels[tPlayerData[p].DifficultyHash].DifficultyType;
				tPlayerData[p].Difficulty = tDifficultyLevels[tPlayerData[p].DifficultyHash].Modifier;
				tPlayerData[p].VillagerSecretsLevel = -1;
				tPlayerData[p].IsHuman = pPlayer:IsHuman();
				if (sRuleset == "RULESET_STANDARD") then tPlayerData[p].Era = pPlayer:GetEras():GetEra(); end
			elseif pPlayer:IsBarbarian() then iBarbarianID = p;
			elseif (sCivTypeName ~= nil) then
				if (sCivTypeName == "CIVILIZATION_FREE_CITIES") then iFreeCitiesID = p; end
				tCityStatesData[p]= {};
				tCityStatesData[p].CivTypeName = sCivTypeName;
			end
		end
	end
	if (sRuleset ~= "RULESET_STANDARD") then iCurrentEra = Game.GetEras():GetCurrentEra(); end
	-- 
	return bNoBarbarians, bNoGoodyHuts, sRuleset, tPlayerData, tEras, tDifficultyLevels, iCityStatesCount, tCityStatesData, iBarbarianID, iCurrentEra, iCurrentTurn, iFreeCitiesID;
end

--[[ =========================================================================
	function AddModifierToPlayer( iPlayerID, sModifierID, bIsPermanent )
	attach Modifier with ID sModifierID to Player with ID iPlayerID
	this should be added to ExposedMembers in Initialize()
=========================================================================== ]]
function GUE.AddModifierToPlayer( iPlayerID, sModifierID, bIsPermanent )
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
	function Initialize() : framework cribbed and modified
	this configures needed script components for use ingame
=========================================================================== ]]
function Initialize()
	print(GUE.RowOfDashes);
	print("Loading EGHV component script EGHV_Common.lua . . .");
	-- 2021/09/29 this is probably the beginning of the way; revist post v4
	-- -- 
	-- GUE.Rewards = { 
	-- 	Types = { All = {}, Disabled = {}, Enabled = {}, Valid = {} },
	-- 	Subtypes = { All = {}, Disabled = {}, Enabled = {}, Valid = {} }
	-- };
	-- -- 
	-- if GUE.DebugEnabled then print(GUE.RowOfDashes); end
	-- Dprint("Configuring global EGHV components . . .");
	-- GUE.Ruleset = GameConfiguration.GetValue("RULESET");
	-- Dprint("Selected ruleset: " .. GUE.Ruleset);
	-- GUE.NoBarbarians = GameConfiguration.GetValue("GAME_NO_BARBARIANS");
	-- Dprint("No Barbarians: " .. tostring(GUE.NoBarbarians));
	-- GUE.NoGoodyHuts = GameConfiguration.GetValue("GAME_NO_GOODY_HUTS");
	-- Dprint("No Tribal Villages: " .. tostring(GUE.NoGoodyHuts));
	-- for row in GameInfo.GoodyHuts() do 
	-- 	table.insert(GUE.Rewards.Types.All, row);
	-- 	if row.Weight == 0 then table.insert(GUE.Rewards.Types.Disabled, row); 
	-- 	else table.insert(GUE.Rewards.Types.Enabled, row); 
	-- 	end
	-- end
	-- Dprint("Goody Hut reward types: " .. #GUE.Rewards.Types.Enabled .. " enabled of " .. #GUE.Rewards.Types.All .. " total; " .. #GUE.Rewards.Types.Disabled .. " disabled");
	-- for i, v in ipairs(GUE.Rewards.Types.Enabled) do GUE.Rewards.Types.Valid[DB.MakeHash(v.GoodyHutType)] = v; end
	-- for k, v in pairs(GUE.Rewards.Types.Valid) do Dprint("+ [" .. k .. "]: GoodyHutType " .. v.GoodyHutType .. " (Weight " .. v.Weight .. ")"); end
	-- for row in GameInfo.GoodyHutSubTypes() do 
	-- 	table.insert(GUE.Rewards.Subtypes.All, row);
	-- 	if row.Weight == 0 then table.insert(GUE.Rewards.Subtypes.Disabled, row); 
	-- 	else table.insert(GUE.Rewards.Subtypes.Enabled, row); 
	-- 	end
	-- end
	-- Dprint("Goody Hut reward subtypes: " .. #GUE.Rewards.Subtypes.Enabled .. " enabled of " .. #GUE.Rewards.Subtypes.All .. " total; " .. #GUE.Rewards.Subtypes.Disabled .. " disabled");
	-- for i, v in ipairs(GUE.Rewards.Subtypes.Enabled) do 
	-- 	local iSubTypeHash = DB.MakeHash(v.SubTypeGoodyHut);
	-- 	GUE.Rewards.Subtypes.Valid[iSubTypeHash] = v;
	-- 	GUE.Rewards.Subtypes.Valid[iSubTypeHash].Tier = GUE.GetRewardTier(v.GoodyHut, v.Weight);
	-- 	GUE.Rewards.Subtypes.Valid[iSubTypeHash].HostileModifier = GUE.GetHostileModifier(GUE.Rewards.Types.Valid, v.GoodyHut, v.Weight);
	-- end
	-- for k, v in pairs(GUE.Rewards.Subtypes.Valid) do 
	-- 	Dprint("+ [" .. k .. "]: GoodyHut " .. v.GoodyHut .. ", Subtype " .. v.SubTypeGoodyHut .. ", Weight " .. v.Weight .. " (" .. v.Tier .. "), HostileModifier " .. v.HostileModifier .. ", ModifierID " .. v.ModifierID);
	-- end
	-- 
	print(GUE.RowOfDashes);
	print("Configuring required ingame common component(s) for EGHV . . .");
	-- fetch game setup data
	GUE.NoBarbarians, GUE.NoGoodyHuts, GUE.Ruleset,
		GUE.PlayerData, GUE.Eras, GUE.DifficultyLevels, GUE.CityStatesCount, GUE.CityStatesData,
		GUE.BarbarianID, GUE.CurrentEra, GUE.CurrentTurn, GUE.FreeCitiesID = GUE.GetGameSetupData();
	print("Successfully retrieved essential game setup data");
	-- fetch goody huts data when they are enabled
	if not GUE.NoGoodyHuts then
		GUE.ActiveGoodyHutTypes, GUE.ActiveGoodyHutRewards, GUE.EqualizeRewards, GUE.HostilesAsReward,
			GUE.GoodyHutFrequency, GUE.GoodyHutIndex, GUE.HostilesAfterReward, GUE.NumGoodyHutRewards, GUE.NumGoodyHutTypes,
			GUE.OldGoodyHutRewards, GUE.OldGoodyHutTypes, GUE.HostilityLevels = GUE.GetGoodyHutsData( GUE.NoBarbarians );
		print("Successfully retrieved available goody huts data");
	else
		print("'No Goody Huts' enabled; available goody huts data 'NOT' retrieved");
	end
	print(GUE.RowOfDashes);
	print("Finished configuring required ingame common component(s); proceeding . . .");
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
	end IngameExposedMembers.lua gameplay script
=========================================================================== ]]
