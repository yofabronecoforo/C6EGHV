--[[ =========================================================================
	C6EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (C) 2020-2024 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin EGHV.lua gameplay script
=========================================================================== ]]
g_bIsWGHEnabled = (#(DB.Query("SELECT * FROM 'GoodyHutSubTypes' WHERE GoodyHut = 'GOODYHUT_SAILOR_WONDROUS'")) > 0);
-- g_iLoggingLevel = GameConfiguration.GetValue("GAME_EGHV_LOGGING");
g_iLoggingLevel = GameConfiguration.GetValue("GAME_ECFE_LOGGING");
g_sRowOfDashes = "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -";
print(g_sRowOfDashes);
print(string.format("Loading gameplay script EGHV.lua [Logging verbosity: %d] . . .", g_iLoggingLevel));
print(g_sRowOfDashes);

--[[ =========================================================================
	load component script files
=========================================================================== ]]
include("EGHV_Utilities");
include("EGHV_RewardGenerator");
include("EGHV_EventHooks");
if g_bIsWGHEnabled then include("EGHV_Sailor_Goodies_Scripts"); end

--[[ =========================================================================
	init global strings
=========================================================================== ]]
g_sRuleset = GameConfiguration.GetValue("RULESET");
g_sBarbCampName = Locale.Lookup(GameInfo.Improvements["IMPROVEMENT_BARBARIAN_CAMP"].Name);
g_sGoodyHutName = Locale.Lookup(GameInfo.Improvements["IMPROVEMENT_GOODY_HUT"].Name);

--[[ =========================================================================
	init global integers
=========================================================================== ]]
g_iBarbCampIndex = GameInfo.Improvements["IMPROVEMENT_BARBARIAN_CAMP"].Index;
g_iGoodyHutIndex = GameInfo.Improvements["IMPROVEMENT_GOODY_HUT"].Index;
g_iEncampmentIndex = GameInfo.Districts["DISTRICT_ENCAMPMENT"].Index;
g_iHarborIndex = GameInfo.Districts["DISTRICT_HARBOR"].Index;
-- g_iAnimalHusbandryIndex = GameInfo.Technologies["TECH_ANIMAL_HUSBANDRY"].Index;
-- g_iCodeOfLawsIndex = GameInfo.Civics["CIVIC_CODE_OF_LAWS"].Index;
g_iGoodyHutFrequency = GameConfiguration.GetValue("GOODYHUT_FREQUENCY");
g_iTotalRewardsPerGoodyHut = GameConfiguration.GetValue("GAME_TOTAL_REWARDS");
g_iBonusRewardsPerGoodyHut = g_iTotalRewardsPerGoodyHut - 1;
g_iCityStatesCount = GameConfiguration.GetValue("CITY_STATE_COUNT");
g_iHostilesAfterReward = GameConfiguration.GetValue("GAME_HOSTILES_CHANCE");
g_iCurrentEra = (g_sRuleset ~= "RULESET_STANDARD") and Game.GetEras():GetCurrentEra() or nil;
g_iCurrentTurn = Game.GetCurrentGameTurn();
g_iNumPlayers = 0;
g_iNumCityStates = 0;
g_iNumDifficultyLevels = 0;
g_iNumEras = 0;
g_iBarbarianID = -1;
g_iFreeCitiesID = -1;
g_iTotalTypeCount = 0;
g_iTotalRewardCount = 0;
g_iActiveTypeCount = 0;
g_iActiveRewardCount = 0;
g_iExpansionTypeCount = 0;
g_iExpansionRewardCount = 0;
g_iFallbackTypeCount = 0;
g_iFallbackRewardCount = 0;
g_iGameSpeedHash = GameConfiguration.GetGameSpeedType();
g_iUnlockVillagerSecrets = GameConfiguration.GetValue("GAME_UNLOCK_VILLAGER_SECRETS");
g_iBonusUnitOrPop = GameConfiguration.GetValue("GAME_BONUS_UNIT_OR_POP");
g_iHostilesMinTurn = GameConfiguration.GetValue("GAME_HOSTILES_MIN_TURN");

--[[ =========================================================================
	init global booleans
=========================================================================== ]]
g_bNoBarbarians = GameConfiguration.GetValue("GAME_NO_BARBARIANS");
g_bNoGoodyHuts = GameConfiguration.GetValue("GAME_NO_GOODY_HUTS");
g_bEqualizeRewards = GameConfiguration.GetValue("GAME_EQUALIZE_GOODY_HUTS");
g_bLowHostilityAsReward = (GameConfiguration.GetValue("EXCLUDE_GOODYHUT_LOW_HOSTILITY_VILLAGERS") ~= 1);
g_bMidHostilityAsReward = (GameConfiguration.GetValue("EXCLUDE_GOODYHUT_MID_HOSTILITY_VILLAGERS") ~= 1);
g_bHighHostilityAsReward = (GameConfiguration.GetValue("EXCLUDE_GOODYHUT_HIGH_HOSTILITY_VILLAGERS") ~= 1);
g_bMaxHostilityAsReward = (GameConfiguration.GetValue("EXCLUDE_GOODYHUT_MAX_HOSTILITY_VILLAGERS") ~= 1);
g_bHostilesAsReward = (g_bLowHostilityAsReward or g_bMidHostilityAsReward or g_bHighHostilityAsReward or g_bMaxHostilityAsReward);
g_bNoDuplicateRewards = GameConfiguration.GetValue("GAME_NO_DUPLICATE_REWARDS");

--[[ =========================================================================
	init global tables
=========================================================================== ]]
g_tHostilesAfterReward = { "Never", "Maybe", "Always", "Hyper" };                             -- table of Hostiles After Reward settings, indexed numerically
g_tHostilityAdverbs = { "SLIGHTLY", "* MODERATELY *", "** VERY **", "*** EXTREMELY ***" };    -- table of hostility adverbs for logging purposes, indexed numerically
g_tRewardTiers = { "Common", "Uncommon", "Rare", "Legendary", "Mythic" };                     -- table of reward tiers for logging purposes, indexed numerically
g_tExcludeGoodyHutsConfig = GameConfiguration.GetValue("EXCLUDE_GOODY_HUTS");                 -- table containing rewards excluded by the picker, indexed numerically
g_tGoodyHutPlots = g_bNoGoodyHuts and nil or GetGoodyHutPlots();                              -- table of plots containing goody huts, indexed numerically

g_tStrategicResources = {};    -- table of strategic resources, indexed numerically; each value is a table containing a resource type and its index as values
for row in GameInfo.Resources() do 
    if row.ResourceClassType == "RESOURCECLASS_STRATEGIC" then 
        table.insert(g_tStrategicResources, { ResourceType = row.ResourceType, Index = row.Index });
    end
end

-- table of ingame notifications, for new goody hut rewards, hostile 'rewards', bonus rewards, and villager secrets rewards
g_tNotification = { 
    Goody = { 
        Title = Locale.Lookup("LOC_NEW_GOODYHUT_NOTIFICATION_TITLE"), 
        TypeHash = NotificationTypes.USER_DEFINED_3, 
        Message = Locale.Lookup("LOC_NEW_GOODYHUT_NOTIFICATION_MESSAGE") 
    }, 
    Hostile = { 
        Title = Locale.Lookup("LOC_HOSTILE_VILLAGERS_NOTIFICATION_TITLE"), 
        UnitTypeHash = NotificationTypes.BARBARIANS_SIGHTED, 
        UnitMessage1 = Locale.Lookup("LOC_HOSTILE_VILLAGERS_UNIT_NOTIFICATION_MESSAGE_1"), 
        UnitMessage2 = Locale.Lookup("LOC_HOSTILE_VILLAGERS_UNIT_NOTIFICATION_MESSAGE_2"), 
        CampTypeHash = NotificationTypes.NEW_BARBARIAN_CAMP, 
        CampMessage = Locale.Lookup("LOC_HOSTILE_VILLAGERS_CAMP_NOTIFICATION_MESSAGE") 
    }, 
    Reward = { 
        Title = Locale.Lookup("LOC_REWARD_NOTIFICATION_TITLE"), 
        TypeHash = NotificationTypes.USER_DEFINED_1, 
        Message = Locale.Lookup("LOC_REWARD_NOTIFICATION_MESSAGE") 
    }, 
    Secret = { 
        Title = Locale.Lookup("LOC_VILLAGER_SECRETS_NOTIFICATION_TITLE"), 
        TypeHash = NotificationTypes.USER_DEFINED_2, 
        Message = Locale.Lookup("LOC_VILLAGER_SECRETS_NOTIFICATION_MESSAGE") 
    } 
};

g_tGameSpeeds = {};    -- table of available GameSpeeds, where key = GameSpeedType hash and value = gameplay DB row
for row in GameInfo.GameSpeeds() do 
    g_tGameSpeeds[DB.MakeHash(row.GameSpeedType)] = row;
end

g_tDifficultyLevels = {};    -- table of available game Difficulties, where key = DifficultyType hash and value = { DifficultyType, Hostile Modifier }
for row in GameInfo.Difficulties() do 
    g_tDifficultyLevels[DB.MakeHash(row.DifficultyType)] = { DifficultyType = row.DifficultyType, Modifier = row.Index + 1 };
    g_iNumDifficultyLevels = g_iNumDifficultyLevels + 1;
end

g_tEras = {};    -- table of available game Eras, where key = Era and value = EraType
for row in GameInfo.Eras() do 
    g_tEras[(row.ChronologyIndex - 1)] = row.EraType;
    g_iNumEras = g_iNumEras + 1;
end

-- 2023/11/10 the Event Queue system has been deprecated
-- g_tPlayerEventQueues = { [-1] = { GoodyHutReward = {}, ImprovementActivated = {} } };    -- per-Player Event queues; index -1 tracks goody huts popped via border expansion

g_tVillagerSecrets = DB.Query("SELECT * FROM GoodyHutSubTypes_EGHV WHERE GoodyHut = 'GOODYHUT_SECRETS'");
g_tPlayerInfo = {};    -- this table contains info that is logged during init; it otherwise does nothing
for p = 0, 63 do 
	local pPlayer, pPlayerConfig = Players[p], PlayerConfigurations[p];
	if (pPlayer ~= nil) and (pPlayerConfig ~= nil) then 
		local sCivTypeName = pPlayerConfig:GetCivilizationTypeName();
        if sCivTypeName ~= nil then 
            local sPlayerInfo = string.format("Player %d:", p);
		    if pPlayer:IsMajor() then 
                local bIsHuman = pPlayer:IsHuman();
	    		pPlayer:SetProperty("DifficultyType", g_tDifficultyLevels[pPlayerConfig:GetHandicapTypeID()].DifficultyType);
		    	pPlayer:SetProperty("Difficulty", g_tDifficultyLevels[pPlayerConfig:GetHandicapTypeID()].Modifier);
                sPlayerInfo = string.format("%s %s Major (%s) | Difficulty %d (%s)", sPlayerInfo, bIsHuman and "Human" or "AI", sCivTypeName, pPlayer:GetProperty("Difficulty"), pPlayer:GetProperty("DifficultyType"));
    			if (g_sRuleset == "RULESET_STANDARD") then 
	    			pPlayer:SetProperty("Era", pPlayer:GetEras():GetEra());
                    sPlayerInfo = string.format("%s | Era %d (%s)", sPlayerInfo, pPlayer:GetProperty("Era"), g_tEras[pPlayer:GetProperty("Era")]);
    			end
                if (bIsHuman and (g_iUnlockVillagerSecrets == 2 or g_iUnlockVillagerSecrets == 4)) or (not bIsHuman and g_iUnlockVillagerSecrets > 2) then 
                    for i, v in ipairs(g_tVillagerSecrets) do 
                        pPlayer:AttachModifierByID(v.ModifierID);
			            pPlayer:SetProperty(v.ModifierID, true);
                    end
                    sPlayerInfo = string.format("%s | All Villager Secrets unlocked", sPlayerInfo);
                end
	    		-- g_tPlayerEventQueues[p] = { GoodyHutReward = {}, ImprovementActivated = {} };
	    		g_iNumPlayers = g_iNumPlayers + 1;
		    elseif (sCivTypeName == "CIVILIZATION_FREE_CITIES") then 
			    g_iFreeCitiesID = p;
                sPlayerInfo = string.format("%s Free Cities (%s)", sPlayerInfo, sCivTypeName);
		    elseif pPlayer:IsBarbarian() then 
			    g_iBarbarianID = p;
                sPlayerInfo = string.format("%s Barbarians (%s)", sPlayerInfo, sCivTypeName);
		    else 
                sPlayerInfo = string.format("%s City-State (%s) is %s at startup", sPlayerInfo, sCivTypeName, (g_iNumCityStates < g_iCityStatesCount) and "active" or "reserved by game mode");
		    	g_iNumCityStates = g_iNumCityStates + 1;
            end
            table.insert(g_tPlayerInfo, sPlayerInfo);
		end
	end
end

g_tExcludedTypes = {};      -- table of excluded reward types, where key = reward type and value = true
g_tExcludedRewards = {};    -- table of excluded reward subtypes, where key = reward subtype and value = true
if g_tExcludeGoodyHutsConfig and #g_tExcludeGoodyHutsConfig > 0 then 
    for _, v in ipairs(g_tExcludeGoodyHutsConfig) do 
        g_tExcludedRewards[v] = true;
    end
end

g_tFallbackRewards = {};           -- table of Fallback rewards, indexed numerically; used by RewardGenerator in emergency situations
g_tGrantReward = {};               -- table of reward functions, where key = reward hash and value = function; used by RewardGenerator
g_tHostileRewards = {};            -- table of hostile villager rewards, where key = reward subtype and value = gameplay DB row
g_tVillagerTotems = {};            -- table of villager totem buildings, where key = reward subtype and value = totem building index
g_tActiveRewardsInfo = {};         -- this table contains info that is logged during init; it otherwise does nothing
g_tValidRewards = {};              -- master table of reward types and subtypes; used by RewardGenerator
g_tValidRewards.All = { Types = {}, Rewards = {} };          -- table of rewards that can be provided via unit exploration
g_tValidRewards.Expansion = { Types = {}, Rewards = {} };    -- table of rewards where RequiresUnit == false; these can be provided via border expansion
g_tValidRewards.Fallback = { Types = {}, Rewards = {} };     -- table of rewards that can be provided even when disabled via the picker, if obtaining a reward from All/Expansion fails
for row in GameInfo.GoodyHutSubTypes_EGHV() do 
    g_iTotalRewardCount = g_iTotalRewardCount + 1;
    if row.GoodyHut == "GOODYHUT_SAILOR_WONDROUS" then g_tGrantReward[row.Hash] = Sailor_WGH;
    elseif row.GoodyHut == "GOODYHUT_SECRETS" then 
        local sBuilding = string.gsub(row.ModifierID, "VILLAGER_SECRETS_UNLOCK", "BUILDING");
        g_tVillagerTotems[row.SubTypeGoodyHut] = GameInfo.Buildings[sBuilding].Index;
        g_tGrantReward[row.Hash] = UnlockVillagerSecrets;
    elseif row.GoodyHut == "GOODYHUT_GOODYHUTS" then g_tGrantReward[row.Hash] = PlaceImprovementInPlot;
    -- elseif row.SubTypeGoodyHut == "GOODYHUT_GRANT_TRADER" then g_tGrantReward[row.Hash] = PlaceUnitInCity;
    -- elseif row.Unit then g_tGrantReward[row.Hash] = PlaceUnitInPlot;
    elseif row.Unit then g_tGrantReward[row.Hash] = CreateUnitInPlot;
    elseif row.Experience then g_tGrantReward[row.Hash] = AddXPToUnit;
    elseif row.UpgradeUnit then g_tGrantReward[row.Hash] = UpgradeUnit;
    elseif row.Hostile then 
        g_tHostileRewards[row.Tier] = row.SubTypeGoodyHut;
        g_tGrantReward[row.Hash] = CreateHostileVillagers;
    elseif row.UnitAbility ~= nil then g_tGrantReward[row.Hash] = AttachAbilityToUnit;
    elseif row.SubTypeGoodyHut == "GOODYHUT_ADD_POP" then g_tGrantReward[row.Hash] = AddPopulationToCity;
    else g_tGrantReward[row.Hash] = AttachModifierToPlayer;
    end
    if row.Fallback then 
        g_iFallbackRewardCount = g_iFallbackRewardCount + 1;
        g_tValidRewards.Fallback.Rewards[row.GoodyHut] = g_tValidRewards.Fallback.Rewards[row.GoodyHut] or {};
        for w = 1, row.Weight do table.insert(g_tValidRewards.Fallback.Rewards[row.GoodyHut], row.SubTypeGoodyHut); end
    end
    if not g_tExcludedRewards[row.SubTypeGoodyHut] and (row.Weight > 0) then 
        g_iActiveRewardCount = g_iActiveRewardCount + 1;
        g_tActiveRewardsInfo[row.GoodyHut] = g_tActiveRewardsInfo[row.GoodyHut] or {};
        table.insert(g_tActiveRewardsInfo[row.GoodyHut], string.format("[+]: [Weight %d | Tier %d (%s)]: Hash %d | GrantReward %s | Reward %s | ModifierID %s | MinOneCity %s | RequiresUnit %s | Fallback %s", row.Weight, row.Tier, row.TierType, row.Hash, tostring(g_tGrantReward[row.Hash]), row.SubTypeGoodyHut, tostring(row.ModifierID), tostring(row.MinOneCity), tostring(row.RequiresUnit), tostring(row.Fallback)));
        g_tValidRewards.All.Rewards[row.GoodyHut] = g_tValidRewards.All.Rewards[row.GoodyHut] or {};
        for w = 1, row.Weight do table.insert(g_tValidRewards.All.Rewards[row.GoodyHut], row.SubTypeGoodyHut); end
        if not row.RequiresUnit then 
            g_iExpansionRewardCount = g_iExpansionRewardCount + 1;
            g_tValidRewards.Expansion.Rewards[row.GoodyHut] = g_tValidRewards.Expansion.Rewards[row.GoodyHut] or {};
            for w = 1, row.Weight do table.insert(g_tValidRewards.Expansion.Rewards[row.GoodyHut], row.SubTypeGoodyHut); end
        end
    end
end

g_tActiveTypesInfo = {};
g_tValidTypes = {};
for row in GameInfo.GoodyHuts_EGHV() do 
    g_iTotalTypeCount = g_iTotalTypeCount + 1;
    if g_tValidRewards.Fallback.Rewards[row.GoodyHutType] and #g_tValidRewards.Fallback.Rewards[row.GoodyHutType] > 0 then 
        g_iFallbackTypeCount = g_iFallbackTypeCount + 1;
        for w = 1, row.Weight do table.insert(g_tValidRewards.Fallback.Types, row.GoodyHutType); end
    else 
        g_tValidRewards.Fallback.Rewards[row.GoodyHutType] = nil;
    end
    if g_tValidRewards.All.Rewards[row.GoodyHutType] and #g_tValidRewards.All.Rewards[row.GoodyHutType] > 0 then 
        g_iActiveTypeCount = g_iActiveTypeCount + 1;
        table.insert(g_tActiveTypesInfo, { GoodyHutType = row.GoodyHutType, Weight = row.Weight });
        for w = 1, row.Weight do table.insert(g_tValidRewards.All.Types, row.GoodyHutType); end
        if g_tValidRewards.Expansion.Rewards[row.GoodyHutType] and #g_tValidRewards.Expansion.Rewards[row.GoodyHutType] > 0 then 
            g_iExpansionTypeCount = g_iExpansionTypeCount + 1;
            for w = 1, row.Weight do table.insert(g_tValidRewards.Expansion.Types, row.GoodyHutType); end
        else 
            g_tValidRewards.Expansion.Rewards[row.GoodyHutType] = nil;
        end
    else 
        g_tExcludedTypes[row.GoodyHutType] = true;
        g_tActiveRewardsInfo[row.GoodyHutType] = nil;
        g_tValidRewards.All.Rewards[row.GoodyHutType] = nil;
    end
end

--[[ =========================================================================
	function Initialize()
	logs pertinent configuration settings
    hooks event listeners to appropriate events on LoadScreenClose
=========================================================================== ]]
function Initialize() 
    if g_iLoggingLevel > 1 then 
        if g_iLoggingLevel > 2 then 
            print(g_sRowOfDashes);
            print("Initializing global settings . . .");
            print(g_sRowOfDashes);
            print(string.format("Selected game speed: %s | Cost multiplier: %d", g_tGameSpeeds[g_iGameSpeedHash].GameSpeedType, g_tGameSpeeds[g_iGameSpeedHash].CostMultiplier));
            print(string.format("Selected ruleset: %s", g_sRuleset));
            print(string.format("Game turn at startup: %s", g_iCurrentTurn));
            if g_sRuleset ~= "RULESET_STANDARD" then print(string.format("Global game Era at startup: %d (%s)", g_iCurrentEra, g_tEras[g_iCurrentEra])); end
        	print(g_sRowOfDashes);
            print(string.format("There are %d active major Players and %d/%d active/total %s at startup", g_iNumPlayers, g_iCityStatesCount, g_iNumCityStates, SingularOrPlural(g_iNumCityStates, "City-State")));
            for i, v in ipairs(g_tPlayerInfo) do print(v); end
        end
        print(g_sRowOfDashes);
        print("Finished initializing global settings; proceeding . . .");
        if g_iLoggingLevel > 2 then 
            print(g_sRowOfDashes);
            print("Initializing ingame Hostile Villager components . . .");
            print(g_sRowOfDashes);
            print(string.format("'No Barbarians': %s", tostring(g_bNoBarbarians)));
	        if not g_bNoBarbarians then print(string.format("Index of Barbarian Outpost improvement is %d", g_iBarbCampIndex)); end
            print(string.format("Hostile Villagers 'AFTER' Goody Hut reward: %s (%d)", g_tHostilesAfterReward[g_iHostilesAfterReward], g_iHostilesAfterReward));
            print(string.format("Hostile Villagers 'AS' potential Goody Hut 'reward': %s (Low: %s | Mid: %s | High: %s | Max: %s)", tostring(g_bHostilesAsReward), tostring(g_bLowHostilityAsReward), tostring(g_bMidHostilityAsReward), tostring(g_bHighHostilityAsReward), tostring(g_bMaxHostilityAsReward)));
            if (g_iHostilesAfterReward > 1) or g_bHostilesAsReward then 
                print(string.format("Hostile Villagers may appear beginning on Turn %s", g_iHostilesMinTurn));
            end
        	-- if g_iLoggingLevel > 3 and (g_bHostilesAsReward or g_iHostilesAfterReward > 1) then 
            if (g_bHostilesAsReward or g_iHostilesAfterReward > 1) then 
                print(g_sRowOfDashes);
		        print("Defined Hostile Unit 'reward(s)' by Era:");
        		for row in GameInfo.HostileUnits() do
	        		print(string.format("[%d] : Recon %s | Melee %s | Ranged %s | AntiCavalry %s | HeavyCavalry %s | LightCavalry %s | Siege %s | Support %s | NavalMelee %s | NavalRanged %s", row.Era, row.Recon, row.Melee, row.Ranged, row.AntiCavalry, row.HeavyCavalry, row.LightCavalry, row.Siege, row.Support, row.NavalMelee, row.NavalRanged));
		        end
        	else
	        	print("'No Barbarians' enabled and/or Hostile Villagers 'AFTER' and 'AS' reward disabled; skipping Hostile Unit configuration");
    	    end
        end
        print(g_sRowOfDashes);
        print("Finished initializing ingame Hostile Villager components; proceeding . . .");
        if g_iLoggingLevel > 2 then 
            print(g_sRowOfDashes);
        	print("Initializing ingame Reward Generator components . . .");
            print(g_sRowOfDashes);
            print(string.format("'No Tribal Villages': %s", tostring(g_bNoGoodyHuts)));
	        if not g_bNoGoodyHuts then 
                print(string.format("Index of Tribal Village improvement is %d", g_iGoodyHutIndex));
                print(string.format("Tribal Village frequency is %d%s of normal distribution", g_iGoodyHutFrequency, "%%"));
                print(string.format("There are %d Tribal Village(s) on the selected map at startup", #g_tGoodyHutPlots));
                print(string.format("Equalize all active reward weights: %s", tostring(g_bEqualizeRewards)));
                print(string.format("No Duplicate Rewards: %s", tostring(g_bNoDuplicateRewards)));
                print(string.format("Unlock Villager Secrets at startup: %d", g_iUnlockVillagerSecrets));
                local sBonusUnitOrPop = (g_iBonusUnitOrPop == 1) and "Always 1" or (g_iBonusUnitOrPop == 7) and "Always 2" or string.format("%d%s chance of 2, or 1", (math.floor(100 / g_iBonusUnitOrPop)), "%%");
                print(string.format("Amount of new units or citizens per grant reward: %s", sBonusUnitOrPop));
                print(string.format("Total reward(s) per Tribal Village: %s%d", (g_iTotalRewardsPerGoodyHut > 1) and "up to " or "", g_iTotalRewardsPerGoodyHut));
                print(g_sRowOfDashes);
                print(string.format("Enabled/Total %s: %d/%d in %d/%d %s | Total Type Weight: %d", SingularOrPlural(g_iTotalRewardCount, "reward"), g_iActiveRewardCount, g_iTotalRewardCount, g_iActiveTypeCount, g_iTotalTypeCount, SingularOrPlural(g_iTotalTypeCount, "type"), #g_tValidRewards.All.Types));
                print(string.format("Valid border expansion %s: %d in %d %s | Total Type Weight: %d", SingularOrPlural(g_iExpansionRewardCount, "reward"), g_iExpansionRewardCount, g_iExpansionTypeCount, SingularOrPlural(g_iExpansionTypeCount, "type"), #g_tValidRewards.Expansion.Types));
                print(string.format("Designated fallback %s: %d in %d %s | Total Type Weight: %d", SingularOrPlural(g_iFallbackRewardCount, "reward"), g_iFallbackRewardCount, g_iFallbackTypeCount, SingularOrPlural(g_iFallbackTypeCount, "type"), #g_tValidRewards.Fallback.Types));
                -- if g_iLoggingLevel > 3 then 
                    print("Available reward(s):");
                    for i, t in ipairs(g_tActiveTypesInfo) do 
                        print(string.format("[%d]: Type %s | Weight %d", i, t.GoodyHutType, t.Weight));
                        for _, r in ipairs(g_tActiveRewardsInfo[t.GoodyHutType]) do print(r); end
                        print(string.format("[*]: Total Weight of available reward(s) of this type: %d", #g_tValidRewards.All.Rewards[t.GoodyHutType]));
                    end
                    print(g_sRowOfDashes);
                    print("Strategic resource indices:");
                    for _, v in ipairs(g_tStrategicResources) do print(string.format("[%s]: %d", v.ResourceType, v.Index)); end
                    print(g_sRowOfDashes);
                    print("Combat experience promotion levels:");
                    for row in GameInfo.PromotionLevels() do print(string.format("[%d XPFNL] = Level %d | %d XP to Level %d", row.XPFNL, row.Level, row.XPTNL, (row.Level + 1))); end
                    print(g_sRowOfDashes);
                    print("Increased villager hostility target(s):");
                    for row in GameInfo.IncreasedHostilityTargets() do print(string.format("[%s]", row.UnitType)); end
                    print(g_sRowOfDashes);
                    print("Decreased villager hostility target(s):");
                    for row in GameInfo.DecreasedHostilityTargets() do print(string.format("[%s]", row.PromotionClass)); end
                    print(g_sRowOfDashes);
                    print("Villager Secrets rewards and corresponding Villager Totem building indices:");
                    for k, v in spairs(g_tVillagerTotems) do print(string.format("[%s]: %d", k, v)); end
                -- end
            else
		        print("'No Tribal Villages' enabled; skipping Reward Generator configuration");
    	    end
        end
        print(g_sRowOfDashes);
    	print("Finished initializing ingame Reward Generator components; proceeding . . .");
        print(g_sRowOfDashes);
        if g_iLoggingLevel > 2 and g_bIsWGHEnabled then 
	    	print("Wondrous Goody Huts integration is enabled");
		    print(g_sRowOfDashes);
    	end
    end
    print("Required hook(s) for ingame Event(s) will be configured on LoadScreenClose");
    Events.LoadScreenClose.Add(Init_EventHooks);
    print(g_sRowOfDashes);
    print("Finished loading gameplay script; proceeding . . .");
    if g_iLoggingLevel == 1 then print("Further EGHV log output will be suppressed"); end
    print(g_sRowOfDashes);
    -- cleanup
    g_tPlayerInfo = nil;
    g_tActiveRewardsInfo = nil;
    g_tActiveTypesInfo = nil;
    g_tVillagerSecrets = nil;
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
