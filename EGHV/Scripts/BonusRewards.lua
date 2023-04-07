--[[ =========================================================================
	EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (C) 2020-2023 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin BonusRewards.lua gameplay script
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
	exposed globals : define any needed EGHV globally shared component(s) here
	pre-init : these should be defined prior to Initialize()
=========================================================================== ]]
-- make DebugPrint() more conveniently globally accessible, as otherwise this declaration must be made in a local scope within each function below
Dprint = GUE.DebugPrint;
-- fetch or initialize the global notifications table
GUE.Notification = (GUE.Notification) and GUE.Notification or {};
-- define Bonus Rewards notification parameters
GUE.Notification.Reward = {
	Title = Locale.Lookup("LOC_BONUS_REWARD_NOTIFICATION_TITLE"),
	TypeHash = NotificationTypes.USER_DEFINED_1,
	Message = Locale.Lookup("LOC_BONUS_REWARD_NOTIFICATION_MESSAGE")
};

--[[ =========================================================================

=========================================================================== ]]
function GUE.GetNewRewardSubtype( iNumRolls, iType, sType, sTier )
	-- identify any matching rewards in the selected tier, randomly if more than one exists
	local iNumMatchingRewards = (GUE.ValidBonusRewards[sType][sTier] ~= nil) and #GUE.ValidBonusRewards[sType][sTier] or 0;
	local iSubtype = (iNumMatchingRewards > 0) and TerrainBuilder.GetRandomNumber(iNumMatchingRewards, "Random subtype index") + 1 or nil;
	local sSubtype = (iSubtype > 0) and GUE.ValidBonusRewards[sType][sTier][iSubtype] or nil;
	Dprint(string.format("Roll %d: [%d/%d][%s][%d/%d]: %s | %s", iNumRolls, iType, #GUE.ValidBonusTypes, sTier, iSubtype, iNumMatchingRewards, sType, sSubtype));
	return sSubtype;
end

--[[ =========================================================================
	rolls a replacement reward if sRewardSubType is the villagers secrets reward and Player iPlayerID has already received it the maximum number of times
=========================================================================== ]]
function GUE.RollReward( iPlayerID, iUnitID, iTurn )
	-- initialize roll counter and fallback, valid roll, and bonus hostiles flags
	local iNumRolls, bIsValidRoll, bBonusHostiles = 0, false, false;
	-- initialize reward type, subtype, and tier
	local sType, sSubtype, sTier = "GOODYHUT_DUMMY", "GOODY_DUMMY_REWARD", "Common";
	-- continue until a valid reward is rolled
	while not bIsValidRoll do 
		-- increment the roll counter
		iNumRolls = iNumRolls + 1;
		-- enable the fallback and valid roll flags if the roll counter exceeds the number of active rewards
		if (iNumRolls > GUE.ActiveGoodyHutRewards) then 
			Dprint("Number of rolls exceeds the amount of active reward(s) without identifying a valid bonus reward; resorting to Fallback reward . . .");
			-- pick a random fallback reward and fetch its type, subtype, and tier from its row in the ingame DB table
			local iFallbackIndex = TerrainBuilder.GetRandomNumber(#GUE.FallbackRewards, "Random Fallback reward index value") + 1;
			local t = GUE.FallbackRewards[iFallbackIndex];
			sType, sSubtype, sTier = t.GoodyHut, t.SubTypeGoodyHut, t.Tier;
			Dprint(string.format("Roll %d: [Fallback][%s][%d/%d]: %s | %s", iNumRolls, sTier, iFallbackIndex, #GUE.FallbackRewards, sType, sSubtype));
			-- enable the valid roll flag
			bIsValidRoll = true;
		-- proceed with rolling a reward
		else 
			-- get a random reward type index and the reward type corresponding to this index
			local iType = TerrainBuilder.GetRandomNumber(#GUE.ValidBonusTypes, "Random type index") + 1;
			sType = GUE.ValidBonusTypes[iType];
			-- reroll if the selected type is Wondrous and the goody hut wasn't popped by a unit
			if (sType == "GOODYHUT_SAILOR_WONDROUS" and (iPlayerID == -1 or iUnitID == -1)) then 
				Dprint(string.format("Roll %d: Rewards of type %s are invalid when obtained via border expansion; rerolling . . .", iNumRolls, sType));
			-- proceed
			else
				-- initialize legendary, rare, and uncommon thresholds; reset these thresholds if reward chances have been equalized
				local iLegendary, iRare, iUncommon = 95, 85, 55;
				if (GUE.EqualizeRewards) then iLegendary, iRare, iUncommon = 75, 50, 25; end
				-- initialize the mythic tier flag; if it's enabled, reset reward tier and set roll value; otherwise get a random roll value
				local bIsMythic = (sType == "GOODYHUT_SECRETS" or sType == "GOODYHUT_SAILOR_WONDROUS") and true or false;
				if (bIsMythic) then sTier = "Mythic"; end
				local iNewTierRoll = (bIsMythic) and 100 or TerrainBuilder.GetRandomNumber(GameInfo.GoodyHuts[sType].Weight, "Random tier roll") + 1;
				-- if reward type is not mythic, determine the reward tier corresponding to the above roll
				if not bIsMythic then 
					if iNewTierRoll > iLegendary and GUE.ValidBonusRewards[sType]["Legendary"] ~= nil then sTier = "Legendary";
					elseif iNewTierRoll > iRare and GUE.ValidBonusRewards[sType]["Rare"] ~= nil then sTier = "Rare";
					elseif iNewTierRoll > iUncommon and GUE.ValidBonusRewards[sType]["Uncommon"] ~= nil then sTier = "Uncommon";
					end
				end
				-- determine reward subtype based on type and tier
				sSubtype = GUE.GetNewRewardSubtype(iNumRolls, iType, sType, sTier);
				-- when the selected subtype is valid but its minimum turn requirement has not been met, drop down a tier until it has, or the roll counter exceeds the amount of active rewards
				while (sSubtype ~= nil and iTurn < GameInfo.GoodyHutSubTypes[sSubtype].Turn and iNumRolls <= GUE.ActiveGoodyHutRewards) do 
					-- increment the roll counter
					iNumRolls = iNumRolls + 1;
					Dprint("Minimum Turn requirement not met for the selected reward; downgrading Tier . . .");
					-- reset reward tier
					if sTier == "Legendary" then sTier = "Rare";
					elseif sTier == "Rare" then sTier = "Uncommon";
					elseif sTier == "Uncommon" then sTier = "Common";
					end
					-- determine reward subtype based on type and new tier
					sSubtype = GUE.GetNewRewardSubtype(iNumRolls, iType, sType, sTier);
				end
				-- enable the valid roll flag if the selected reward subtype is valid and the roll counter does not yet exceed the amount of active rewards
				if (sSubtype ~= nil and iNumRolls <= GUE.ActiveGoodyHutRewards) then bIsValidRoll = true; end
			end
		end
	end
	return iNumRolls, sType, sSubtype, sTier;
end

--[[ =========================================================================
	exposed member function GetNewRewards()
	calls RollReward to roll iNumRewards new bonus reward(s) when bonus rewards are enabled
	calls the appropriate function(s) to apply bonus reward(s)
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
function GUE.GetNewRewards( iNumRewards, iPlayerID, iUnitID, iX, iY, sRewardSubtype, iTurn, iEra, tUnits, bIsReplacement )
	-- initialize bonus hostiles flag, total rolls and cumulative modifier counters, and reward type, subtype, and tier
	local bBonusHostiles, iNumRolls, iSumModifiers = false, 0, 0;
	local sType, sSubtype, sTier = "", "", "";
	-- do nothing if there are no bonus rewards, or if sRewardSubtype is a hostile villager "reward" - no bonus rewards if the villagers are already pissed, right?
	if (iNumRewards > 0) and not GUE.HostileVillagers[sRewardSubtype] then 
		-- loop up to iNumRewards time(s)
		for n = 1, iNumRewards, 1 do 
			-- roll a new reward
			iNumRolls, sType, sSubtype, sTier = GUE.RollReward(iPlayerID, iUnitID, iTurn);
			-- do nothing if a valid subtype was not obtained above
			if (sSubtype == nil or sSubtype == "" or sSubtype == "GOODY_DUMMY_REWARD") then 
				print(string.format("An error has occurred while obtaining bonus reward %d of %d", n, iNumRewards));
			-- proceed if we have a valid subtype
			elseif (sSubtype ~= nil and sSubtype ~= "" and sSubtype ~= "GOODY_DUMMY_REWARD") then 
				-- use this reward's row in the ingame DB table to initialize the hostile modifer and reward modifier values
				local t = GameInfo.GoodyHutSubTypes[sSubtype];
				local iHostileModifier, sModifier = t.HostileModifier, t.ModifierID;
				local iTypeHash, iSubTypeHash = GameInfo.GoodyHuts[sType].Hash, GameInfo.GoodyHutSubTypes[sSubtype].Hash;
				local iXP, sAbility = GUE.UnitXPRewards[sSubtype] and GUE.UnitXPRewards[sSubtype] or nil, GUE.UnitAbilityRewards[sSubtype] and GUE.UnitAbilityRewards[sSubtype] or nil;
				-- the cumulative hostile modifier value of all received bonus reward(s)
				iSumModifiers = iSumModifiers + iHostileModifier;
				-- panel notification title and text
				local sRewardTitle, sRewardMessage = GUE.Notification.Reward.Title, string.format("%s %s.", GUE.Notification.Reward.Message, Locale.Lookup(t.Description));
				-- fetch the object for the adjacent Plot in this direction ** 2021/07/26 this is hacky as fuck, and only works as long as n is always less than 6, which it *should* always be
				local pAdjacentPlot = Map.GetAdjacentPlot(iX, iY, (n - 1));
				-- fetch the (x, y) coordinates of the adjacent Plot object
				local aX, aY = pAdjacentPlot:GetX(), pAdjacentPlot:GetY();
				if bIsReplacement then 
					Dprint(string.format("Found replacement reward in %d roll(s); new initial hostile modifier: %d", iNumRolls, iSumModifiers));
					print(string.format("The villagers instead provide a replacement %s %s reward of %s", sTier, sType, sSubtype));
				else 
					Dprint(string.format("Found bonus reward %d of %d in %d roll(s); cumulative bonus hostile modifier: %d", n, iNumRewards, iNumRolls, iSumModifiers));
					print(string.format("The villagers also provide an additional %s %s reward of %s", sTier, sType, sSubtype));
				end
				-- 
				GUE.GrantReward[iSubTypeHash](iPlayerID, iUnitID, iTypeHash, iSubTypeHash, sSubtype, iX, iY, iTurn, iEra, tUnits, iXP, sAbility, sModifier, false);
				-- send an ingame notification for each received bonus reward and display popup text if the player is human
				if Players[iPlayerID]:IsHuman() then 
					NotificationManager.SendNotification(iPlayerID, GUE.Notification.Reward.TypeHash, sRewardTitle, sRewardMessage, aX, aY);
					Game.AddWorldViewText(iPlayerID, Locale.Lookup(t.Description), iX, iY, 0);
				end
				-- true when the rolled reward is a hostile villagers "reward"; create hostiles and abort
				if GUE.HostileVillagers[sSubtype] then 
					bBonusHostiles = true;
					print("Hostile villagers received as 'reward'; ignoring any further potential reward(s) from this Goody Hut");
					return iSumModifiers, bBonusHostiles, sSubtype, sTier;
				end
				-- -- true when the rolled reward is a hostile villagers "reward"; create hostiles and abort
				-- if GUE.HostileVillagers[sSubtype] then 
				-- 	bBonusHostiles = true;
				-- 	GUE.CreateHostileVillagers(iX, iY, iPlayerID, iTurn, iEra, sSubtype);
				-- 	print("Hostile villagers received as 'reward'; ignoring any further potential reward(s) from this Goody Hut");
				-- 	return iSumModifiers, bBonusHostiles, sSubtype, sTier;
				-- -- true when the rolled reward is a villager secrets reward
				-- elseif (sSubtype == GUE.VillagerSecrets) or (GUE.VillagerSecretsRewards[sSubtype] ~= nil) then 
				-- 	-- true when this Player has received this reward fewer than the defined maximum amount of time(s)
				-- 	if (Players[iPlayerID]:GetProperty("VillagerSecretsLevel") < GUE.MaxSecretsLevel) then
				-- 		GUE.UnlockVillagerSecrets(iPlayerID, iTurn, iEra, sSubtype);
				-- 	-- do nothing when false ** 2023/04/02 this may not ever fire any more **
				-- 	else
				-- 		Dprint("VillagerSecretsLevel >= MaxSecretsLevel for Player " .. iPlayerID);
				-- 	end
				-- -- true when the rolled reward is a free unit
				-- elseif (GUE.GrantUnitRewards[sSubtype] ~= nil) then GUE.AddUnitToMap(iX, iY, iPlayerID, iTurn, iEra, sSubtype);
				-- -- true when the rolled reward is a unit ability reward
				-- elseif (GUE.UnitAbilityRewards[sSubtype] ~= nil) then GUE.AddAbilityToUnit(iX, iY, tUnits, GUE.UnitAbilityRewards[sSubtype]);
				-- -- true when the rolled reward is a unit experience reward
				-- elseif (GUE.UnitXPRewards[sSubtype] ~= nil) then GUE.AddXPToUnit(iX, iY, tUnits, GUE.UnitXPRewards[sSubtype]);
				-- -- true when the rolled reward is the 'upgrade unit' reward
				-- elseif (sSubtype == "GOODYHUT_GRANT_UPGRADE") then tUnits = GUE.UpgradeUnit(iPlayerID, iX, iY, tUnits);
				-- -- true when the rolled reward is of Wondrous-type
				-- elseif (GUE.WGH_Rewards[sSubtype] ~= nil) then
				-- 	-- true when the primary reward was earned via border expansion ** 2023/04/02 this check should be handled in RollReward(), so this shouldn't ever fire **
				-- 	-- if (iPlayerID == -1) or (iUnitID == -1) then
				-- 	-- 	Dprint("Wondrous-type Bonus reward(s) are invalid Border Expansion rewards; skipping this bonus reward");
				-- 		-- bIsValidRoll = false;
				-- 	-- true when the primary reward was earned via unit exploration
				-- 	-- else
				-- 		-- the Type and SubType hash values for this reward
				-- 		local iTypeHash, iSubTypeHash = GUE.WGH_Rewards[sSubtype].TypeHash, GUE.WGH_Rewards[sSubtype].SubTypeHash;
				-- 		-- WGH setup parameters; these enable a Wondrous-type reward as a bonus reward
				-- 		local pPlayer = Players[iPlayerID];
				-- 		local pPlayerUnits = pPlayer:GetUnits();
				-- 		local pThisUnit = pPlayerUnits:FindID(iUnitID);
				-- 		local pThisUnitAbility = pThisUnit:GetAbility();
				-- 		-- apply this ability to trigger a Wondrous-type bonus reward
				-- 		pThisUnitAbility:ChangeAbilityCount(GUE.WGH_Rewards[sSubtype].AbilityType, 1);
				-- 		-- debugging output
				-- 		Dprint(string.format("Wondrous-type Bonus reward %s identified; application will be handled by WGH", sSubtype));
				-- 		-- call WGH to handle this bonus reward; as far as it's concerned, this is the primary reward from a popped goody hut
				-- 		WGH.Sailor_WGH(iPlayerID, iUnitID, iTypeHash, iSubTypeHash);
				-- 	-- end
				-- -- 
				-- elseif (sSubtype == "GOODYHUT_ADD_POP") then 
				-- 	GUE.AddPopulationToCity(iPlayerID, iTurn, iEra);
				-- -- true for any other rolled reward; attach its modifier to (re) apply the reward
				-- else 
				-- 	GUE.AddModifierToPlayer(iPlayerID, sModifier, false);
				-- end
			end
		end
	end
	-- return the values of the cumulative modifier and the bonus hostiles flag
	return iSumModifiers, bBonusHostiles, sSubtype, sTier;
end

--[[ =========================================================================
	function Initialize()
	final configuration prior to startup
=========================================================================== ]]
function Initialize()
    print(GUE.RowOfDashes);
    print("Loading EGHV component script BonusRewards.lua . . .");
    print(GUE.RowOfDashes);
	print("Configuring required ingame Bonus Rewards component(s) for EGHV . . .");
	-- log valid reward(s) if applicable
	if not GUE.NoGoodyHuts and GUE.NumBonusRewards > 0 and GUE.BonusRewardsPerGoodyHut > 0 then 
		print("Bonus Reward(s) per Tribal Village: " .. GUE.BonusRewardsPerGoodyHut);
		Dprint("Available Bonus Reward(s):");
		for i, v in ipairs(GUE.ValidBonusTypes) do 
			Dprint("+ Type index " .. tostring(i) .. " [" .. tostring(v) .. "]");
			for a, b in pairs(GUE.ValidBonusRewards[v]) do 
				Dprint("+ + " .. tostring(a) .. " (" .. tostring(#b) .. ")");
				for y, z in ipairs(b) do 
					Dprint("+ + + [" .. tostring(y) .. "] - " .. tostring(z));
				end
			end
		end
		print("There are " .. GUE.NumBonusRewards .. " eligible reward(s) in the bonus rewards table");
	else
		print("There are 'zero' eligible reward(s) in the bonus rewards table, or the 'No Tribal Villages' setup option is enabled; skipping . . .");
	end
    print(GUE.RowOfDashes);
	-- print(" * * * Reward Roller Test * * *");
	-- local iNumRolls, sType, sSubtype, sTier = GUE.RollReward(0, 0, GUE.CurrentTurn);
	-- print(string.format("Selected Reward: %s %s (%s)", sTier, sType, sSubtype));
	-- print(GUE.RowOfDashes);
	print("Finished configuring required ingame Bonus Rewards component(s); proceeding . . .");
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
	end BonusRewards.lua gameplay script
=========================================================================== ]]
