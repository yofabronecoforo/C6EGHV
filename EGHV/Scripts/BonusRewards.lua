--[[ =========================================================================
	EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (C) 2020-2021 zzragnar0kzz
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
	exposed member function GetNewRewards()
	rolls iNumRewards new bonus reward(s) when bonus rewards are enabled
	rolls a replacement reward if sRewardSubType is the villagers secrets reward and Player iPlayerID has already received it the maximum number of times
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
function GUE.GetNewRewards( iNumRewards, iPlayerID, iUnitID, iX, iY, sRewardSubType, iTurn, iEra, tUnits )
	-- initialize the cumulative hostile reward modifier
	local iSumModifiers = 0;
	-- initialize the hostiles as bonus reward flag
	local bBonusHostiles = false;
	-- initialize the subtype and tier return values
	local sNewSubType, sNewTier = "", "";
	-- do nothing if there are no bonus rewards, or if sRewardSubType is a hostile villager "reward" - no bonus rewards if the villagers are already pissed, right?
	if (iNumRewards > 0) and not GUE.HostileVillagers[sRewardSubType] then 
		-- loop up to iNumRewards times
		for n = 1, iNumRewards, 1 do
			-- no more bonus rewards if hostile villagers have been received as a bonus "reward"
			if not bBonusHostiles then
				-- initialize the rolls tracker and valid roll flag
				local iNumRolls, bIsValidRoll = 0, false;
				-- loop until the valid roll flag has been set
				while not bIsValidRoll do 
					-- initialize (1) the bonus reward subtype index to a dummy value, and (2) the bonus reward type index to a random value
					local iRandomTypeIndex = TerrainBuilder.GetRandomNumber(GUE.TotalBonusRewardTypeWeight, "Bonus reward type index") + 1;
					-- 
					local iBonusTypeIndex = ((((GUE.TotalBonusRewardTypeWeight * 2) + iRandomTypeIndex) ^ 2) % GUE.TotalBonusRewardTypeWeight) + 1;
					-- initialize primary debugging message
					local sPriDebugMsg = "Bonus reward: Type index " .. iBonusTypeIndex;
					-- iterate over the valid bonus reward types table
					for k, v in pairs(GUE.ValidRewardTypes) do 
						-- true when the random value is in the Start - End range for this reward type
						if iBonusTypeIndex >= v.Start and iBonusTypeIndex <= v.End then 
							-- adjust primary debugging message
							sPriDebugMsg = sPriDebugMsg .. " (" .. v.GoodyHutType .. ")";
							-- 
							local iRandomSubTypeIndex = TerrainBuilder.GetRandomNumber(v.TotalSubTypeWeight, "Bonus reward subtype index") + 1;
							-- get a fresh random value limited to the sum of the weights of all subtypes of this type
							local iBonusSubTypeIndex = ((((v.TotalSubTypeWeight * 2) + iRandomSubTypeIndex) ^ 2) % v.TotalSubTypeWeight) + 1;
							-- initialize secondary debugging message
							local sSecDebugMsg = "Subtype index " .. iBonusSubTypeIndex;
							-- iterate over the valid bonus reward subtypes table
							for a, b in pairs(GUE.ValidBonusRewards) do 
								-- true when the fresh random subtype value is in the Start - End range for this reward subtype, AND this reward subtype has not been excluded
								if b.GoodyHut == v.GoodyHutType and iBonusSubTypeIndex >= b.Start and iBonusSubTypeIndex <= b.End and not (b.SubTypeGoodyHut == GUE.VillagerSecrets and GUE.PlayerData[iPlayerID].VillagerSecretsLevel >= GUE.MaxSecretsLevel) and not (GUE.WGH_Rewards[b.SubTypeGoodyHut] ~= nil and iUnitID == -1) then 
									-- set the valid roll flag to indicate a successful new roll
									bIsValidRoll = true;
									-- adjust secondary debugging message
									sSecDebugMsg = sSecDebugMsg .. " (" .. b.SubTypeGoodyHut .. ")";
									-- debugging output
									Dprint(sPriDebugMsg .. ", " .. sSecDebugMsg);
									-- fetch the object for the adjacent Plot in this direction ** 2021/07/26 this is hacky as fuck, and only works as long as n is always less than 6, which it *should* always be
									local pAdjacentPlot = Map.GetAdjacentPlot(iX, iY, (n - 1));
									-- fetch the (x, y) coordinates of the adjacent Plot object
									local aX, aY = pAdjacentPlot:GetX(), pAdjacentPlot:GetY();
									-- fetch the hostile modifier, subtype, reward modifier, rarity tier, and world view notification text for the current reward
									local iThisHostileModifier, sThisType, sThisSubType, sThisModifier, sThisTier, sBonusRewardDesc = b.HostileModifier, b.GoodyHut, b.SubTypeGoodyHut, b.ModifierID, b.Tier, Locale.Lookup(b.Description);
									-- these will ultimately contain the subtype and tier values of the last-rolled reward; they're only important for a replacement roll
									sNewSubType, sNewTier = sThisSubType, sThisTier;
									-- panel notification title
									local sBonusRewardTitle = GUE.Notification.Reward.Title;
									-- panel notification text
									local sBonusRewardMessage = GUE.Notification.Reward.Message .. " " .. sBonusRewardDesc .. ".";
									-- print log output if this is NOT a replacement roll for a presently-excluded reward
									if not (iNumRewards == 1 and ((sRewardSubType == GUE.VillagerSecrets and GUE.PlayerData[iPlayerID].VillagerSecretsLevel >= GUE.MaxSecretsLevel) or (GUE.WGH_Rewards[sRewardSubType] ~= nil and iUnitID == -1))) then
										-- info message for logging
										local sPriInfoMsg = "The villagers also provide an additional " .. sThisTier .. " " .. sThisType .. " reward of " .. sThisSubType;
										-- log output
										print(sPriInfoMsg);
									end
									-- true when the rolled reward is a villager secrets reward
									if (sThisSubType == GUE.VillagerSecrets) or (GUE.VillagerSecretsRewards[sThisSubType] ~= nil) then 
										-- true when this Player has received this reward fewer than the defined maximum amount of time(s)
										if (GUE.PlayerData[iPlayerID].VillagerSecretsLevel < GUE.MaxSecretsLevel) then
											GUE.UnlockVillagerSecrets(iPlayerID, iTurn, iEra, sThisSubType);
										-- log output when false
										else
											Dprint("VillagerSecretsLevel >= MaxSecretsLevel for Player " .. iPlayerID);
										end
									-- true when the rolled reward is a free unit
									elseif (GUE.GrantUnitRewards[sThisSubType] ~= nil) then GUE.AddUnitToMap(iX, iY, iPlayerID, iTurn, iEra, sThisSubType);
									-- true when the rolled reward is a unit ability reward
									elseif (GUE.UnitAbilityRewards[sThisSubType] ~= nil) then GUE.AddAbilityToUnit(iX, iY, tUnits, GUE.UnitAbilityRewards[sThisSubType]);
									-- true when the rolled reward is a unit experience reward
									elseif (GUE.UnitXPRewards[sThisSubType] ~= nil) then GUE.AddXPToUnit(iX, iY, tUnits, GUE.UnitXPRewards[sThisSubType]);
									-- true when the rolled reward is a hostile villagers "reward"; set the bonus hostiles flag
									elseif GUE.HostileVillagers[sThisSubType] then bBonusHostiles = true;
									-- true when the rolled reward is the 'upgrade unit' reward
									elseif (sThisSubType == "GOODYHUT_GRANT_UPGRADE") then tUnits = GUE.UpgradeUnit(iPlayerID, iX, iY, tUnits);
									-- true when the rolled reward is of Wondrous-type
									elseif (GUE.WGH_Rewards[sThisSubType] ~= nil) then
										-- true when the primary reward was earned via border expansion
										if (iPlayerID == -1) or (iUnitID == -1) then
											-- debugging output
											Dprint("Wondrous-type Bonus reward(s) are invalid Border Expansion rewards; skipping this bonus reward");
										-- true when the primary reward was earned via unit exploration
										else
											-- the Type and SubType hash values for this reward
											local iTypeHash, iSubTypeHash = GUE.WGH_Rewards[sThisSubType].TypeHash, GUE.WGH_Rewards[sThisSubType].SubTypeHash;
											-- WGH setup parameters; these enable a Wondrous-type reward as a bonus reward
											local pPlayer = Players[iPlayerID];
											local pPlayerUnits = pPlayer:GetUnits();
											local pThisUnit = pPlayerUnits:FindID(iUnitID);
											local pThisUnitAbility = pThisUnit:GetAbility();
											-- apply this ability to trigger a Wondrous-type bonus reward
											pThisUnitAbility:ChangeAbilityCount(GUE.WGH_Rewards[sThisSubType].AbilityType, 1);
											-- debugging output
											Dprint("Wondrous-type Bonus reward " .. tostring(GUE.WGH_Rewards[sThisSubType].AbilityType) .. " successfully applied; WGH will handle the rest");
											-- call WGH to handle this bonus reward; as far as it's concerned, this is the reward from a popped goody hut
											WGH.Sailor_Expanded_Goodies(iPlayerID, iUnitID, iTypeHash, iSubTypeHash);
										end
									-- true for any other rolled reward; attach its modifier to (re) apply the reward
									else GUE.AddModifierToPlayer(iPlayerID, sThisModifier, false);
									end
									-- the cumulative hostile modifier value of all received reward(s), including the first non-bonus reward
									iSumModifiers = iSumModifiers + iThisHostileModifier;
									-- spawn hostile villagers here if the bonus hostiles flag was set above; there will be no further bonus rewards after this one
									if bBonusHostiles then GUE.CreateHostileVillagers(iX, iY, iPlayerID, iTurn, iEra, sThisSubType); end
									-- display world view notification
									Game.AddWorldViewText(iPlayerID, sBonusRewardDesc, iX, iY, 0);
									-- send an ingame notification for each received bonus reward
									if GUE.PlayerData[iPlayerID].IsHuman then NotificationManager.SendNotification(iPlayerID, GUE.Notification.Reward.TypeHash, sBonusRewardTitle, sBonusRewardMessage, aX, aY); end
								end
							end
							-- increment the rolls tracker and try again if the valid roll flag remains unset
							iNumRolls = iNumRolls + 1;
							-- infinite loop prevention; this fires when the current value of iNumRolls exceeds the amount of available goody hut rewards
							if iNumRolls > GUE.NumGoodyHutRewards then 
								-- debugging output
								Dprint("Maximum number of attempts reached; resorting to fallback reward . . .");
								-- divide the current value of iBonusIndex by the count of available fallback rewards; add 1 to the remainder and store the result
								local iFallbackIndex = (iBonusIndex % #GUE.FallbackRewards) + 1;
								-- apply the fallback reward represented by the index value obtained above
								GUE.AddModifierToPlayer(iPlayerID, GUE.FallbackRewards[iFallbackIndex], false);
								-- set the valid roll flag to indicate a successful new roll
								bIsValidRoll = true;
							end
						end
					end
				end
				-- debugging log output
				if iNumRewards == 1 and ((sRewardSubType == GUE.VillagerSecrets and GUE.PlayerData[iPlayerID].VillagerSecretsLevel >= GUE.MaxSecretsLevel) or (GUE.WGH_Rewards[sRewardSubType] ~= nil and iUnitID == -1)) then
					-- single replacement reward
					Dprint("Found replacement reward in " .. iNumRolls .. " roll(s); New Initial Hostile modifier: " .. iSumModifiers);
				else
					-- bonus reward(s)
					Dprint("Found reward " .. n .. " of " .. iNumRewards .. " in " .. iNumRolls .. " roll(s); Cumulative Bonus Hostile modifier: " .. iSumModifiers);
				end
				-- 
				if bBonusHostiles then print("Hostile villagers received as 'reward'; ignoring any further potential reward(s) from this Goody Hut"); end
			end
		end
	end
	-- return the values of the cumulative modifier and the bonus hostiles flag
	return iSumModifiers, bBonusHostiles, sNewSubType, sNewTier;
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
	if not GUE.NoGoodyHuts and GUE.BonusRewardCount > 0 and GUE.BonusRewardsPerGoodyHut > 0 then
        print("Bonus Reward(s) per Tribal Village: " .. GUE.BonusRewardsPerGoodyHut);
        Dprint("Available Bonus Reward(s):");
		for k, v in pairs(GUE.ValidRewardTypes) do 
			Dprint("+ [" .. v.Start .. " - " .. v.End .. "]: Type " .. v.GoodyHutType .. ", Weight " .. v.Weight .. ", Combined Subtype Weight " .. v.TotalSubTypeWeight);
			for a, b in pairs(GUE.ValidBonusRewards) do 
				if b.GoodyHut == v.GoodyHutType then 
					Dprint("+ + [" .. b.Start .. " - " .. b.End .. "]: Subtype " .. b.SubTypeGoodyHut .. ", ModifierID " .. b.ModifierID .. ", Weight " .. b.Weight);
				end
			end
		end
		print("There are " .. GUE.BonusRewardCount .. " eligible reward(s) in the bonus rewards table; Cumulative Weight/RNG Seed Value: " .. GUE.TotalBonusRewardTypeWeight);
	else
		print("There are 'zero' eligible reward(s) in the bonus rewards table, or the 'No Tribal Villages' setup option is enabled; skipping . . .");
	end
    print(GUE.RowOfDashes);
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
