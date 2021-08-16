--[[ =========================================================================
	EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (C) 2020-2021 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin EnhancedGoodies.lua gameplay script
=========================================================================== ]]
print("Loading gameplay script EnhancedGoodies.lua . . .");

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
-- make DebugPrint() more conveniently globally accessible, as otherwise this declaration must be made in a local scope within each function below
Dprint = GUE.DebugPrint;

-- QueueGoodyHutReward stores arguments from Event.GoodyHutReward for use by Event.ImprovementActivated
GUE.QueueGoodyHutReward = {};
-- QueueImprovementActivated stores arguments from Event.ImprovementActivated for use by Event.GoodyHutReward
GUE.QueueImprovementActivated = {};
-- table of notification-related data for various reward types
GUE.Notification = {
	-- hostiles type
	Hostile = {
		Title = Locale.Lookup("LOC_HOSTILE_VILLAGERS_NOTIFICATION_TITLE"),
		UnitTypeHash = NotificationTypes.BARBARIANS_SIGHTED,
		UnitMessage1 = Locale.Lookup("LOC_HOSTILE_VILLAGERS_UNIT_NOTIFICATION_MESSAGE_1"),
		UnitMessage2 = Locale.Lookup("LOC_HOSTILE_VILLAGERS_UNIT_NOTIFICATION_MESSAGE_2"),
		CampTypeHash = NotificationTypes.NEW_BARBARIAN_CAMP,
		CampMessage = Locale.Lookup("LOC_HOSTILE_VILLAGERS_CAMP_NOTIFICATION_MESSAGE")
	-- secrets type
	}, Secrets = {
		Title = Locale.Lookup("LOC_VILLAGER_SECRETS_NOTIFICATION_TITLE"),
		TypeHash = NotificationTypes.USER_DEFINED_2,
		Message = Locale.Lookup("LOC_VILLAGER_SECRETS_NOTIFICATION_MESSAGE")
	-- bonus rewards
	}, Reward = {
		Title = Locale.Lookup("LOC_BONUS_REWARD_NOTIFICATION_TITLE"),
		TypeHash = NotificationTypes.USER_DEFINED_1,
		Message = Locale.Lookup("LOC_BONUS_REWARD_NOTIFICATION_MESSAGE")
	}
};
-- table of units to spawn by Era
GUE.HostileUnitByEra = {
	[0] = { Melee = "UNIT_WARRIOR", Ranged = "UNIT_SLINGER", HeavyCavalry = "UNIT_BARBARIAN_HORSEMAN", LightCavalry = "UNIT_BARBARIAN_HORSE_ARCHER" },
	[1] = { Melee = "UNIT_WARRIOR", Ranged = "UNIT_ARCHER", HeavyCavalry = "UNIT_BARBARIAN_HORSEMAN", LightCavalry = "UNIT_BARBARIAN_HORSE_ARCHER" },
	[2] = { Melee = "UNIT_SWORDSMAN", Ranged = "UNIT_ARCHER", HeavyCavalry = "UNIT_KNIGHT", LightCavalry = "UNIT_BARBARIAN_HORSE_ARCHER" },
	[3] = { Melee = "UNIT_MAN_AT_ARMS", Ranged = "UNIT_CROSSBOWMAN", HeavyCavalry = "UNIT_KNIGHT", LightCavalry = "UNIT_HORSEMAN" },
	[4] = { Melee = "UNIT_MUSKETMAN", Ranged = "UNIT_CROSSBOWMAN", HeavyCavalry = "UNIT_KNIGHT", LightCavalry = "UNIT_HORSEMAN" },
	[5] = { Melee = "UNIT_LINE_INFANTRY", Ranged = "UNIT_FIELD_CANNON", HeavyCavalry = "UNIT_KNIGHT", LightCavalry = (GUE.Ruleset == "RULESET_EXPANSION_2") and "UNIT_COURSER" or "UNIT_HORSEMAN" },
	[6] = { Melee = "UNIT_INFANTRY", Ranged = "UNIT_FIELD_CANNON", HeavyCavalry = (GUE.Ruleset == "RULESET_EXPANSION_2") and "UNIT_CUIRASSIER" or "UNIT_KNIGHT", LightCavalry = (GUE.Ruleset == "RULESET_EXPANSION_2") and "UNIT_COURSER" or "UNIT_CAVALRY" },
	[7] = { Melee = "UNIT_INFANTRY", Ranged = "UNIT_MACHINE_GUN", HeavyCavalry = (GUE.Ruleset == "RULESET_EXPANSION_2") and "UNIT_CUIRASSIER" or "UNIT_KNIGHT", LightCavalry = "UNIT_CAVALRY" },
	[8] = { Melee = "UNIT_INFANTRY", Ranged = "UNIT_MACHINE_GUN", HeavyCavalry = (GUE.Ruleset == "RULESET_EXPANSION_2") and "UNIT_CUIRASSIER" or "UNIT_KNIGHT", LightCavalry = "UNIT_CAVALRY" }
};
-- define valid Villager Secrets reward(s) - these are the SubTypeGoodyHut values for any such rewards
GUE.VillagerSecrets = "GOODYHUT_UNLOCK_VILLAGER_SECRETS";
-- max number of villager secrets rewards per Player is this value + 1 (first unlock is level 0)
GUE.MaxSecretsLevel = 5;
-- define valid Hostile Villagers "reward(s)" - keys are the SubTypeGoodyHut values for any such rewards
GUE.HostileVillagers = { ["GOODYHUT_LOW_HOSTILITY_VILLAGERS"] = 1, ["GOODYHUT_MID_HOSTILITY_VILLAGERS"] = 2, ["GOODYHUT_HIGH_HOSTILITY_VILLAGERS"] = 3, ["GOODYHUT_MAX_HOSTILITY_VILLAGERS"] = 4 };
-- flag to indicate when Sumeria's civ ability has triggered
GUE.SumerianCivAbilityTrigger = 0;
-- table of units that can be captured, condemned, plundered, or forced to return to a nearby city; increased villager hostility
GUE.HighValueTargets = {
	["UNIT_SETTLER"] = "", ["UNIT_BUILDER"] = "", ["UNIT_TRADER"] = "", ["UNIT_COMANDANTE_GENERAL"] = "",
	["UNIT_MISSIONARY"] = "", ["UNIT_APOSTLE"] = "", ["UNIT_INQUISITOR"] = "", ["UNIT_GURU"] = "",
	["UNIT_GREAT_GENERAL"] = "", ["UNIT_GREAT_ADMIRAL"] = "", ["UNIT_GREAT_ENGINEER"] = "", ["UNIT_GREAT_MERCHANT"] = "",
	["UNIT_GREAT_PROPHET"] = "", ["UNIT_GREAT_SCIENTIST"] = "", ["UNIT_GREAT_WRITER"] = "", ["UNIT_GREAT_ARTIST"] = "",
	["UNIT_GREAT_MUSICIAN"] = ""
};
-- table of unit promotion classes that reduce villager hostility; most of these are military units
GUE.DecreasedHostilityPromotionClasses = {
	["PROMOTION_CLASS_ANTI_CAVALRY"] = "", ["PROMOTION_CLASS_HEAVY_CAVALRY"] = "", ["PROMOTION_CLASS_LIGHT_CAVALRY"] = "", ["PROMOTION_CLASS_MELEE"] = "", 
	["PROMOTION_CLASS_RANGED"] = "", ["PROMOTION_CLASS_GIANT_DEATH_ROBOT"] = "", ["PROMOTION_CLASS_MONK"] = "", ["PROMOTION_CLASS_NIHANG"] = "", 
	["PROMOTION_CLASS_ROCK_BAND"] = "", ["PROMOTION_CLASS_SIEGE"] = "", ["PROMOTION_CLASS_SUPPORT"] = "", ["PROMOTION_CLASS_VAMPIRE"] = ""
};
-- table of unit promotion classes that can receive certain unit ability rewards; most of these are military units
GUE.UnitAbilityValidPromotionClasses = {
	["PROMOTION_CLASS_ANTI_CAVALRY"] = "", ["PROMOTION_CLASS_HEAVY_CAVALRY"] = "", ["PROMOTION_CLASS_LIGHT_CAVALRY"] = "", ["PROMOTION_CLASS_MELEE"] = "", 
	["PROMOTION_CLASS_RANGED"] = "", ["PROMOTION_CLASS_GIANT_DEATH_ROBOT"] = "", ["PROMOTION_CLASS_MONK"] = "", ["PROMOTION_CLASS_NIHANG"] = "", 
	["PROMOTION_CLASS_ROCK_BAND"] = "", ["PROMOTION_CLASS_SIEGE"] = "", ["PROMOTION_CLASS_RECON"] = "", ["PROMOTION_CLASS_VAMPIRE"] = ""
};
-- the database Index value of the Horses resource
GUE.HorsesIndex = GameInfo.Resources["RESOURCE_HORSES"].Index;
-- table of adverbs for indicating villager hostility levels in log output
GUE.HostilityAdverbs = { "SLIGHTLY", "* MODERATELY *", "** VERY **", "*** EXTREMELY ***" };
-- sum of weights of enabled rewards; this will seed the RNG for any bonus reward rolls
GUE.TotalBonusRewardWeight = 0;
-- the number of potential bonus rewards is the value of the "rewards per tribal village" game setting, minus 1
GUE.BonusRewardsPerGoodyHut = GameConfiguration.GetValue("GAME_TOTAL_REWARDS") - 1;
-- the number of available rewards in the bonus rewards table
GUE.BonusRewardCount = 0;
-- initialize the exclusion table; this contains any reward(s) that should not be granted as a bonus reward
GUE.ExcludedRewards = { ["METEOR_GRANT_GOODIES"] = "" };
-- initialize the bonus rewards table; this should ultimately contain relevant data for all enabled reward(s)
GUE.ValidRewards = {};
-- true when the goody hut subtypes table exists AND the 'No Tribal Villages' setup option has NOT been set
if GUE.GoodyHutRewards and not GUE.NoGoodyHuts then
	-- iterate over the goody hut subtypes table
	for k, v in pairs(GUE.GoodyHutRewards) do
		-- fetch data for certain enabled rewards for the bonus rewards table
		if (v.Weight > 0) and not GUE.ExcludedRewards[v.SubTypeGoodyHut] then
			-- the start value of the range of valid random numbers that indicate this reward
			local iStartIndex = GUE.TotalBonusRewardWeight + 1;
			-- the cumulative weight of all valid reward(s)
			GUE.TotalBonusRewardWeight = GUE.TotalBonusRewardWeight + v.Weight;
			-- increment the total bonus rewards counter
			GUE.BonusRewardCount = GUE.BonusRewardCount + 1;
			-- put this item in the valid rewards table with the same key
			GUE.ValidRewards[k] = v;
			-- set the start index to the value obtained above
			GUE.ValidRewards[k].Start = iStartIndex;
			-- set the end index to the value obtained above
			GUE.ValidRewards[k].End = GUE.TotalBonusRewardWeight;
		end
	end
end
-- unit ability rewards; key = goody hut subtype, value = associated ability
GUE.UnitAbilityRewards = { 
	["GOODYHUT_IMPROVED_HEALING"] = "ABILITY_IMPROVED_HEALING",
	["GOODYHUT_IMPROVED_MOVEMENT"] = "ABILITY_IMPROVED_MOVEMENT",
	["GOODYHUT_IMPROVED_SIGHT"] = "ABILITY_IMPROVED_SIGHT",
	["GOODYHUT_IMPROVED_STRENGTH"] = "ABILITY_IMPROVED_STRENGTH"
};

--[[ =========================================================================
	exposed member function AddAbilityToUnit( iX, iY, tUnits, sAbilityType )
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
function GUE.AddAbilityToUnit( iX, iY, tUnits, sAbilityType )
	-- proceed if any unit(s) were found
	if tUnits ~= nil then
		-- iterate over all unit(s) in the passed table
		for k, v in pairs(tUnits) do
			local sUnitType = v.UnitType;
			-- this unit's promotion class
			local sPromotionClass = v.PromotionClass;
			-- data for this unit
			local pUnit = v.Table;
			-- shortcut to this unit's GetAbility() method
			local pUnitAbility	= pUnit:GetAbility();
			-- the number of times sAbilityType has been attached to this unit
			local iAbilityCount = pUnitAbility:GetAbilityCount(sAbilityType);
			-- attach sAbilityType to this unit when it has not previously been attached to the unit
			if iAbilityCount == nil or iAbilityCount == 0 then
				-- combat abilities require combat units
				if (sAbilityType == "ABILITY_IMPROVED_HEALING" or sAbilityType == "ABILITY_IMPROVED_STRENGTH") then
					-- this unit is a valid combat unit
					if (GUE.UnitAbilityValidPromotionClasses[sPromotionClass] ~= nil) then
						-- attach sAbilityType to this unit
						pUnitAbility:ChangeAbilityCount(sAbilityType, 1);
						-- debugging log output
						Dprint("Military Unit Ability " .. sAbilityType .. " successfully attached to a " .. sUnitType .. " at plot (x " .. iX .. ", y " .. iY .. ")");
					-- this unit is NOT a valid combat unit; do nothing
					else
						-- debugging log output
						Dprint("Military Unit Ability " .. sAbilityType .. " is not valid for a " .. sUnitType .. " at plot (x " .. iX .. ", y " .. iY .. "); skipping unit");
					end
				-- these abilities can be attached to any unit
				elseif (sAbilityType == "ABILITY_IMPROVED_SIGHT" or sAbilityType == "ABILITY_IMPROVED_MOVEMENT") then
					-- attach sAbilityType to this unit
					pUnitAbility:ChangeAbilityCount(sAbilityType, 1);
					-- debugging log output
					Dprint("Unit Ability " .. sAbilityType .. " successfully attached to a " .. sUnitType .. " at plot (x " .. iX .. ", y " .. iY .. ")");
				end
			-- do not attach sAbilityType to this unit more than once
			else
				-- debugging log output
				Dprint("Unit Ability " .. sAbilityType .. " was previously attached to a " .. sUnitType .. " at plot (x " .. iX .. ", y " .. iY .. "); skipping unit");
			end
		end
	end
end

--[[ =========================================================================
	exposed member function DetermineVillagerHostility( bIsExpand, bIsIncreasedHostility, bIsDecreasedHostility, iDifficultyModifier, iThisRewardModifier, iBonusRewardModifier, iEra, iSpawnThreshold )
	calculate villager hostility after a reward, based on popping method and/or unit, selected difficulty, current game/player Era, and rarity of any received reward(s)
	when this value equals or exceeds the spawn threshold, hostile villagers will appear
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
function GUE.DetermineVillagerHostility( bIsExpand, bIsIncreasedHostility, bIsDecreasedHostility, iDifficultyModifier, iThisRewardModifier, iBonusRewardModifier, iEra, iSpawnThreshold )
	-- define any informational message(s)
	local sPriInfoMsg = "The villagers are ";
	-- default to zero hostility
	local sHostilityLevel = "ZERO";
	-- this fluctuates depending on how the goody hut was found and/or what type of unit found it; the default value applies to recon and most civilian and religious units
	local iAdditionalModifier = 2;
	-- this is true if the goody hut was popped via border expansion or by a high-value target unit, such as a settler, builder, or great person (including comandante general)
	if (bIsExpand) or (bIsIncreasedHostility) then iAdditionalModifier = 3;
	-- this is true if the goody hut was popped by any unit whose promotion class is in the decreased hostility table, which is most military and some civilian and religious units
	elseif (bIsDecreasedHostility) then iAdditionalModifier = 1;
	end
	-- the era modifier increases with each successive game/player Era
	local iEraModifier = iEra + 1;
	-- the reward modifier is the sum of hostile reward modifiers from all rewards granted this turn
	local iRewardModifier = iThisRewardModifier + iBonusRewardModifier;
	-- calculate the base chance of hostile villagers appearing this turn
	local iBaseChance = ((iAdditionalModifier * iDifficultyModifier) + iRewardModifier) * iEraModifier;
	-- get a random modifier value 1-100, inclusive, if necessary
	local iRandomModifier = TerrainBuilder.GetRandomNumber(iSpawnThreshold, "Hostile villagers : spawn chance") + 1;
	-- add the random modifier to the base chance to determine the actual chance of hostile villagers appearing this turn, or set an override value with an "always hostile" setting
	local iHostilesChance = iBaseChance + iRandomModifier;
	-- inflate the hostiles chance here if necessary
	if (GUE.HostilesAfterReward > 2) then while (iHostilesChance < iSpawnThreshold) do iHostilesChance = iHostilesChance * 2; end end
	-- debugging message
	local sPriDebugMsg = "Initial villager hostility level: (((" .. iAdditionalModifier .. " * " .. iDifficultyModifier .. ") + " 
		.. iRewardModifier .. ") * " .. iEraModifier .. ") + " .. iRandomModifier .. " = " .. iHostilesChance .. " [Threshold: " .. iSpawnThreshold .. "]";
	local sSecDebugMsg = " [Hostiles After Reward: " .. GUE.HostilityLevels[GUE.HostilesAfterReward] .. "]";
	-- print the debugging message
	Dprint(sPriDebugMsg .. sSecDebugMsg);
	-- proceed to calculate hostility level if this is true
	if (iHostilesChance >= iSpawnThreshold) then
		-- adjust informational message(s)
		sPriInfoMsg = sPriInfoMsg .. "annoyed by the presence of outsiders, and will react aggressively"
		-- log output
		print(sPriInfoMsg);
		-- additional hostility modifier for hyper-hostile villagers after reward
		local iHostilityModifier = (GUE.HostilesAfterReward > 3) and 101 or 0;
		-- add the previously calculated hostiles chance to the additional hostility modifier to calculate the actual hostility level
		local iActualHostility = iHostilesChance + iHostilityModifier;
		-- table of low/mid/high/max hostility thresholds
		local tHostilityThresholds = { iSpawnThreshold, (iSpawnThreshold * 1.33), (iSpawnThreshold * 1.67), (iSpawnThreshold * 2) };
		-- debugging output
		Dprint("Adjusted villager hostility level: " .. iHostilesChance .. " + " .. iHostilityModifier .. " = " .. iActualHostility .. " [Low/Mid/High/Max: "
			.. tHostilityThresholds[1] .. "/" .. tHostilityThresholds[2] .. "/" .. tHostilityThresholds[3] .. "/" .. tHostilityThresholds[4] .. "]");
		-- max hostility
		if (iActualHostility >= tHostilityThresholds[4]) then sHostilityLevel = "GOODYHUT_MAX_HOSTILITY_VILLAGERS";
		-- high hostility
		elseif (iActualHostility >= tHostilityThresholds[3]) then sHostilityLevel = "GOODYHUT_HIGH_HOSTILITY_VILLAGERS";
		-- mid hostility
		elseif (iActualHostility >= tHostilityThresholds[2]) then sHostilityLevel = "GOODYHUT_MID_HOSTILITY_VILLAGERS";
		-- low hostility
		elseif (iActualHostility >= tHostilityThresholds[1]) then sHostilityLevel = "GOODYHUT_LOW_HOSTILITY_VILLAGERS";
		end
	else
		-- adjust informational message(s)
		sPriInfoMsg = sPriInfoMsg .. "unconcerned by the presence of outsiders"
		-- log output
		print(sPriInfoMsg);
	end
	-- return the selected hostility level
	return sHostilityLevel;
end

--[[ =========================================================================
	exposed member function CreateHostileVillagers( iX, iY, iPlayerID, iTurn, iEra, sRewardSubType )
	spawns hostile barbarian units near the plot at (x iX, y iY)
	hostility level determined by sRewardSubType
	ingame notifications sent to iPlayerID
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
function GUE.CreateHostileVillagers( iX, iY, iPlayerID, iTurn, iEra, sRewardSubType )
	-- define function entry messages
	local sPriEntryMsg = "Turn " .. iTurn .. " | Era " .. iEra .. " | Enter CreateHostileVillagers( iX = " .. iX .. ", iY = " .. iY
		.. ", iPlayerID = " .. iPlayerID .. ", iTurn = " .. iTurn .. ", iEra = " .. iEra .. ", sRewardSubType = " .. sRewardSubType .. " )";
	-- print entry messages to the log when debugging
	Dprint(sPriEntryMsg);
	-- fetch the hostilty level of the current "reward"
	local iHostilityLevel = GUE.HostileVillagers[sRewardSubType];
	-- the number of hostile melee unit(s) to spawn; this should always be at least 1, and may change depending on the hostility level
	local iMeleeHostiles = (iHostilityLevel == 3) and 2 or 1;
	-- the number of hostile ranged unit(s) to spawn; this defaults to 0, and may change depending on the hostility level
	local iRangedHostiles = (iHostilityLevel > 1) and 1 or 0;
	-- barbarian camp spawn flag; this will be set to true if the hostility level indicates that a barbarian camp should be placed
	local bSpawnBarbCamp = (iHostilityLevel == 4) and true or false;
	-- define the primary informational message
	local sPriInfoMsg = "The villagers are ";
	-- define the secondary informational message
	local sSecInfoMsg = " hostile, and react to the presence of outsiders by forming " .. iMeleeHostiles .. " hostile melee and " .. iRangedHostiles .. " hostile ranged unit(s)";
	-- adjust the secondary informational message for max hostility
	if (iHostilityLevel == 4) then sSecInfoMsg = sSecInfoMsg .. ", AND a new barbarian camp!"; end
	-- log output
	print(sPriInfoMsg .. GUE.HostilityAdverbs[iHostilityLevel] .. sSecInfoMsg);
	-- check nearby plots for (1) a valid location for a new barbarian camp, and (2) the presence of resources
	local tValidBarbCampPlots, bIsHorsesNearby, iNearbyHorses = GUE.GetValidSpawnPlots(iX, iY, iTurn, iEra);
	-- debugging output
	Dprint("Discovered " .. #tValidBarbCampPlots .. " valid plot(s) in which a barbarian camp or hostile unit may spawn");
	if bIsHorsesNearby then print("Horses discovered in " .. iNearbyHorses .. " nearby plot(s); any hostile unit(s) which spawn may be mounted"); end
	-- attempt to spawn a barbarian camp first, if the flag was set
	if (bSpawnBarbCamp) then
		-- when this fires, pick a valid adjacent plot and try to spawn a barbarian camp
		if tValidBarbCampPlots and #tValidBarbCampPlots > 0 then
			-- get a random index value
			local iSpawnPlotIndex = TerrainBuilder.GetRandomNumber(#tValidBarbCampPlots, "New barbarian camp plot index") + 1;
			-- fetch data for the Plot indicated by the random index
			local pSpawnPlot = tValidBarbCampPlots[iSpawnPlotIndex];
			-- fetch the (x, y) coordinates of the fetched Plot object
			local sX, sY = pSpawnPlot:GetX(), pSpawnPlot:GetY();
			-- remove the random index from the table
			table.remove(tValidBarbCampPlots, iSpawnPlotIndex);
			-- attempt to place the barbarian camp in the indicated Plot
			ImprovementBuilder.SetImprovementType(pSpawnPlot, GUE.BarbCampIndex, -1);
			-- log output
			print("A group of villagers have organized into a new barbarian camp at plot (x " .. sX .. ", y " .. sY .. ")!");
			-- send an ingame notification for the new barbarian camp
			NotificationManager.SendNotification(iPlayerID, GUE.Notification.Hostile.CampTypeHash, GUE.Notification.Hostile.Title, GUE.Notification.Hostile.CampMessage, sX, sY);
		-- no valid spawn plot(s) were identified, so try to compensate with additional units
		else
			-- adjust the number of hostile melee unit(s) to spawn
			iMeleeHostiles = 2;
			-- adjust the number of hostile ranged unit(s) to spawn
			iRangedHostiles = 2;
			-- log output
			print("There are no valid adjacent plot(s) in which a barbarian camp may spawn; attempting to spawn " .. iMeleeHostiles .. " hostile melee and " .. iRangedHostiles .. " hostile ranged unit(s) instead");
		end
	end
	-- when fewer valid plots remain in the table than the total number of hostile units to be placed, re-fetch the Plot objects for all immediately adjacent plots
	if (#tValidBarbCampPlots < (iMeleeHostiles + iRangedHostiles + 1)) then
		-- unit(s) can potentially spawn in plots that barbarian camps cannot, so some now-valid plot(s) may have been ignored during previous validation
		Dprint("Remaining count of valid plot(s) " .. #tValidBarbCampPlots .. " is less than the sum of hostile unit(s) to place; requerying adjacent plot(s) to identify any potentially now-valid plot(s)");
		-- search for valid Plot object(s) adjacent to (iX, iY) in every defined direction
		for d = 0, (DirectionTypes.NUM_DIRECTION_TYPES - 1), 1 do
			-- fetch the object for the adjacent Plot in this direction
			local pAdjacentPlot = Map.GetAdjacentPlot(iX, iY, d);
			-- when this check fails, assume an invalid object and do nothing
			if pAdjacentPlot then table.insert(tValidBarbCampPlots, pAdjacentPlot); end
		end
		-- debugging log output
		Dprint("There are now " .. #tValidBarbCampPlots .. " valid plot(s) in which a hostile unit may spawn");
	end
	-- tracker for the total number of hostile unit(s) to be spawned
	local tSpawnedUnits = { Count = 0, Plots = {}, Units = {} };
	-- (mounted) melee units will spawn if this is greater than zero; if this is 0 or less, something is wrong elsewhere
	if (iMeleeHostiles > 0) then
		-- place (mounted) melee units until iMeleeHostiles such units(s) have been placed
		for p = 1, iMeleeHostiles do
			-- get a random index value
			local iSpawnPlotIndex = TerrainBuilder.GetRandomNumber(#tValidBarbCampPlots, "Melee hostiles plot index") + 1;
			-- fetch data for the Plot indicated by the random index
			local pSpawnPlot = tValidBarbCampPlots[iSpawnPlotIndex];
			-- remove the random index from the table
			table.remove(tValidBarbCampPlots, iSpawnPlotIndex);
			-- fetch the (x, y) coordinates of the fetched Plot object
			local sX, sY = pSpawnPlot:GetX(), pSpawnPlot:GetY();
			-- informational messages
			local sPriInfoMsg = "A group of villagers have organized into a hostile ";
			local sSecInfoMsg = " near plot (x " .. sX .. ", y " .. sY .. ")!";
			-- Horses were located nearby: roll to choose mounted or standard melee
			if bIsHorsesNearby then
				-- modulo (%) returns the remainder from a division operation; there is a ~ 50% chance for "true" here with 1 Horses, and that chance gets greater with each additional Horses
				local bMountedSpawn = ((TerrainBuilder.GetRandomNumber(100, "Mounted or standard melee choice") % (iNearbyHorses + 1)) > 0) and true or false;
				-- substitute a mounted melee or heavy cavalry unit for this standard melee unit
				if bMountedSpawn then
					-- place a mounted melee or heavy cavalry unit based on the current Era
					UnitManager.InitUnitValidAdjacentHex(GUE.BarbarianID, GUE.HostileUnitByEra[iEra].HeavyCavalry, sX, sY, 1);
					-- log output
					print(sPriInfoMsg .. GUE.HostileUnitByEra[iEra].HeavyCavalry .. sSecInfoMsg);
					-- add an Era-appropriate heavy cavalry unit to the table of units to spawn
					table.insert(tSpawnedUnits.Units, GUE.HostileUnitByEra[iEra].HeavyCavalry);
				-- default to standard melee
				else
					-- place a standard melee unit based on the current Era
					UnitManager.InitUnitValidAdjacentHex(GUE.BarbarianID, GUE.HostileUnitByEra[iEra].Melee, sX, sY, 1);
					-- log output
					print(sPriInfoMsg .. GUE.HostileUnitByEra[iEra].Melee .. sSecInfoMsg);
					-- add an Era-appropriate melee unit to the table of units to spawn
					table.insert(tSpawnedUnits.Units, GUE.HostileUnitByEra[iEra].Melee);
				end
			-- Horses were NOT located nearby: default to standard melee
			else
				-- place a standard melee unit based on the current Era
				UnitManager.InitUnitValidAdjacentHex(GUE.BarbarianID, GUE.HostileUnitByEra[iEra].Melee, sX, sY, 1);
				-- log output
				print(sPriInfoMsg .. GUE.HostileUnitByEra[iEra].Melee .. sSecInfoMsg);
				-- add an Era-appropriate melee unit to the table of units to spawn
				table.insert(tSpawnedUnits.Units, GUE.HostileUnitByEra[iEra].Melee);
			end
			-- update the total spawned unit(s) tracker
			tSpawnedUnits.Count = tSpawnedUnits.Count + 1;
			table.insert(tSpawnedUnits.Plots, pSpawnPlot);
		end
	end
	-- (mounted) ranged units will spawn if this is greater than zero ** 2021/04/22 ** ranged units spawned by this script don't seem to do anything but wait for death
	if (iRangedHostiles > 0) then
		-- place (mounted) ranged units until iRangedHostiles such unit(s) have been placed
		for p = 1, iRangedHostiles do
			-- get a random index value
			local iSpawnPlotIndex = TerrainBuilder.GetRandomNumber(#tValidBarbCampPlots, "Ranged hostiles plot index") + 1;
			-- fetch data for the Plot indicated by the random index
			local pSpawnPlot = tValidBarbCampPlots[iSpawnPlotIndex];
			-- remove the random index from the table
			table.remove(tValidBarbCampPlots, iSpawnPlotIndex);
			-- fetch the (x, y) coordinates of the fetched Plot object
			local sX, sY = pSpawnPlot:GetX(), pSpawnPlot:GetY();
			-- informational messages
			local sPriInfoMsg = "A group of villagers have organized into a hostile ";
			local sSecInfoMsg = " near plot (x " .. sX .. ", y " .. sY .. ")!";
			-- Horses were located nearby: roll for mounted or standard ranged
			if bIsHorsesNearby then
				-- modulo (%) returns the remainder from a division operation; there is a ~ 50% chance for "true" here with 1 Horses, and that chance gets greater with each additional Horses
				local bMountedSpawn = ((TerrainBuilder.GetRandomNumber(100, "Mounted or standard ranged choice") % (iNearbyHorses + 1)) > 0) and true or false;
				-- substitute a mounted ranged or light cavalry unit for this standard ranged unit
				if bMountedSpawn then
					-- place a mounted ranged or light cavalry unit based on the current Era
					UnitManager.InitUnitValidAdjacentHex(GUE.BarbarianID, GUE.HostileUnitByEra[iEra].LightCavalry, sX, sY, 1);
					-- log output
					print(sPriInfoMsg .. GUE.HostileUnitByEra[iEra].LightCavalry .. sSecInfoMsg);
					-- add an Era-appropriate light cavalry unit to the table of units to spawn
					table.insert(tSpawnedUnits.Units, GUE.HostileUnitByEra[iEra].LightCavalry);
				-- default to standard ranged
				else
					-- place a standard ranged unit based on the current Era
					UnitManager.InitUnitValidAdjacentHex(GUE.BarbarianID, GUE.HostileUnitByEra[iEra].Ranged, sX, sY, 1);
					-- log output
					print(sPriInfoMsg .. GUE.HostileUnitByEra[iEra].Ranged .. sSecInfoMsg);
					-- add an Era-appropriate ranged unit to the table of units to spawn
					table.insert(tSpawnedUnits.Units, GUE.HostileUnitByEra[iEra].Ranged);
				end
			-- Horses were NOT located nearby: default to standard ranged
			else
				-- place a standard ranged unit based on the current Era
				UnitManager.InitUnitValidAdjacentHex(GUE.BarbarianID, GUE.HostileUnitByEra[iEra].Ranged, sX, sY, 1);
				-- log output
				print(sPriInfoMsg .. GUE.HostileUnitByEra[iEra].Ranged .. sSecInfoMsg);
				-- add an Era-appropriate ranged unit to the table of units to spawn
				table.insert(tSpawnedUnits.Units, GUE.HostileUnitByEra[iEra].Ranged);
			end
			-- update the total spawned unit(s) tracker
			tSpawnedUnits.Count = tSpawnedUnits.Count + 1;
			table.insert(tSpawnedUnits.Plots, pSpawnPlot);
		end
	end
	-- this will fire if one or more unit(s) were spawned, and displays an ingame notification for each such unit
	if (tSpawnedUnits.Count > 0) then
		-- send notifications until tSpawnedUnits.Count such notification(s) have been sent
		for n = 1, tSpawnedUnits.Count do
			-- fetch the (x, y) coordinates for this spawn Plot
			local nX, nY = tSpawnedUnits.Plots[n]:GetX(), tSpawnedUnits.Plots[n]:GetY();
			-- the hostile ingame notification title
			local sHostileTitle = GUE.Notification.Hostile.Title;
			-- the hostile ingame notification message
			local sHostileUnitMessage = GUE.Notification.Hostile.UnitMessage1 .. " " .. Locale.Lookup(GameInfo.Units[tSpawnedUnits.Units[n]].Name) .. " " .. GUE.Notification.Hostile.UnitMessage2;
			-- send an ingame notification for each spawned unit
			NotificationManager.SendNotification(iPlayerID, GUE.Notification.Hostile.UnitTypeHash, sHostileTitle, sHostileUnitMessage, nX, nY);
		end
	end
	-- define function exit message(s)
	local sPriExitMsg = "Turn " .. iTurn .. " | Era " .. iEra .. " | Exit CreateHostileVillagers()";
	-- print exit message(s) to the log when debugging
	Dprint(sPriExitMsg);
end

--[[ =========================================================================
	exposed member function GetValidAdjacentPlots( iX, iY, t )
	identifies valid existing Plot objects which are adjacent to (iX, iY)
	checks valid objects against t for any previously-identified object(s) and ignores them
	any non-duplicate objects are added to the results table and returned
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
function GUE.GetValidAdjacentPlots( iX, iY, t )
	-- initialize the results table; valid adjacent Plot object(s) go here
	local tValidPlots = {};
	-- place any object(s) currently in t in the results table
	for k, v in pairs(t) do tValidPlots[k] = v; end
	-- search for valid Plot object(s) adjacent to (iX, iY) in every defined direction
	for d = 0, (DirectionTypes.NUM_DIRECTION_TYPES - 1), 1 do
		-- fetch the object for the adjacent Plot in this direction
		local pAdjacentPlot = Map.GetAdjacentPlot(iX, iY, d);
		-- when this check fails, assume an invalid object and do nothing
		if pAdjacentPlot then tValidPlots[pAdjacentPlot] = true; end
	end
	-- return the results table
	return tValidPlots;
end

--[[ =========================================================================
	exposed member function ValidateNearbyPlots( t, iX, iY )
	identifies any valid nearby Plot object(s) in t in which a Barbarian Camp improvement may exist
		valid object(s) are added to the results table
	identifies Horses in any valid nearby Plot object(s)
		if found, a flag will be set and a tracker incremented, which will influence potential hostile unit selection
	returns a results table, one or more resources found flag(s), and one or more nearby resources tracker(s)
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
function GUE.ValidateNearbyPlots( t, iX, iY )
	-- initialize the results table; valid nearby Plot object(s) go here
	local tValidPlots = {};
	-- initialize the Horses found flag; this will be enabled if Horses are found in any valid object
	local bIsHorsesNearby = false;
	-- initialize the nearby Horses tracker; this will be incremented each time Horses are found in a valid object
	local iNearbyHorses = 0;
	-- iterate over the passed table to identify resources and valid barbarian camp locations
	for k, v in pairs(t) do
		-- fetch the (x, y) coordinates of this Plot
		local kX, kY = k:GetX(), k:GetY();
		-- debugging message(s)
		local sLocalDebugMsg = "Plot (x " .. kX .. ", y " .. kY .. ") ";
		-- the resource on this Plot, if any exists
		local pPlotResource = k:GetResourceType();
		-- this is true when Horses are present on this Plot
		if (pPlotResource ~= 1) and (pPlotResource == GUE.HorsesIndex) then
			-- debugging output
			Dprint(sLocalDebugMsg .. "* contains Horses * ");
			-- set the global Horses found flag if it has not already been set
			if not bIsHorsesNearby then bIsHorsesNearby = true; end
			-- increment the nearby Horses tracker
			iNearbyHorses = iNearbyHorses + 1;
		end
		-- this is true when this Plot is a valid location for a barbarian camp
		if ImprovementBuilder.CanHaveImprovement(k, GUE.BarbCampIndex, -1) then
			-- debugging output
			Dprint(sLocalDebugMsg .. "* is a valid location for a barbarian camp * ");
			-- add this Plot object to the table of valid Plot objects
			table.insert(tValidPlots, k); 
		end
	end
	-- return the results table and any flag(s) and any tracker(s)
	return tValidPlots, bIsHorsesNearby, iNearbyHorses;
end

--[[ =========================================================================
	exposed member function GetValidSpawnPlots( iX, iY, iTurn, iEra )
	identifies valid existing Plot objects within the indicated radius of (iX, iY); each call to GetValidAdjacentPlots() below increases this radius by 1 tile
	identifies whether a Barbarian Camp improvement may exist in any valid object(s)
		valid object(s) are added to the results table
	identifies whether Horses are present in any valid object(s)
		if found, a flag will be set and a tracker incremented, which will influence hostile unit selection
	returns a results table, one or more resources found flag(s), and one or more nearby resources tracker(s)
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
function GUE.GetValidSpawnPlots( iX, iY, iTurn, iEra )
	-- define function entry messages
	local sPriEntryMsg = "Turn " .. iTurn .. " | Era " .. iEra .. " | Enter GetValidSpawnPlots( iX = " .. iX .. ", iY = " .. iY 
		.. ", iTurn = " .. iTurn .. ", iEra = " .. iEra .. " )";
	-- print entry messages to the log when debugging
	Dprint(sPriEntryMsg);
	-- initialize local value(s): valid adjacent Plot(s) table, nearby Horses flag, nearby Horses tracker, additional adjacency radius
	local tValidPlots, bIsHorsesNearby, iNearbyHorses, iExtraAdjacencyRadius = {}, false, 0, 2;
	-- get any valid Plot(s) immediately adjacent to (iX, iY); results here will be keyed by Plot to ensure uniqueness of entries
	tValidPlots = GUE.GetValidAdjacentPlots(iX, iY, tValidPlots);
	-- get any new valid Plots(s) within iExtraAdjacencyRadius plots of any valid Plot(s) immediately adjacent to (iX, iY)
	for a = 1, iExtraAdjacencyRadius, 1 do
		-- get any new valid Plot(s) immediately adjacent to any previously-identified valid Plot(s)
		for k, v in pairs(tValidPlots) do
			-- fetch the (x, y) coordinates of this Plot
			local aX, aY = k:GetX(), k:GetY();
			-- get the valid Plot(s) immediately adjacent to this Plot
			tValidPlots = GUE.GetValidAdjacentPlots(aX, aY, tValidPlots);
		end
	end
	-- other stuff already uses a results table with integer keys and Plot values, so it will be converted here
	local tValidPlots, bIsHorsesNearby, iNearbyHorses = GUE.ValidateNearbyPlots(tValidPlots, ix, iY);
	-- define function exit message(s)
	local sPriExitMsg = "Turn " .. iTurn .. " | Era " .. iEra .. " | Exit GetValidSpawnPlots(); return tValidPlots, bIsHorsesNearby, iNearbyHorses";
	-- print exit message(s) to the log when debugging
	Dprint(sPriExitMsg);
	-- return the table of validated plots, the horses nearby flag, and the nearby horses tracker
	return tValidPlots, bIsHorsesNearby, iNearbyHorses;
end

--[[ =========================================================================
	exposed member function UnlockVillagerSecrets()
	unlocks the ability to construct the Tribal Totem building for Player with ID iPlayerID
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
function GUE.UnlockVillagerSecrets( iPlayerID, iTurn, iEra, sRewardSubType )
	-- define function entry messages
	local sPriEntryMsg = "Turn " .. iTurn .. " | Era " .. iEra .. " | Enter UnlockVillagerSecrets( iPlayerID = " .. iPlayerID
		.. ", iTurn = " .. iTurn .. ", iEra = " .. iEra .. ", sRewardSubType = " .. sRewardSubType .. " )";
	-- print entry messages to the log when debugging
	Dprint(sPriEntryMsg);
	-- fetch the Player object for Player iPlayerID
	local pPlayer = Players[iPlayerID];
	-- proceed here if the pPlayer object for iPlayerID represents a valid Player
	if (pPlayer ~= nil) then
		-- log output when debugging
		Dprint("Successfully fetched player data for Player " .. iPlayerID .. "; determining whether reward subtype " .. sRewardSubType .. " has previously been granted to this player . . .");
		-- fetch the ingame Player property for this Player for this reward
		local PlayerProperty = pPlayer:GetProperty(sRewardSubType);
		-- define the Unlock Tribal Totem prefix
		local sTribalTotem = "VILLAGER_SECRETS_UNLOCK_TRIBAL_TOTEM_LVL";
		-- this should fire the first time this Player receives the Villager Secrets reward
		if (PlayerProperty == nil) then
			-- log output
			print("The Villager Secrets reward has 'NOT' previously been granted to Player " .. iPlayerID .. "; unlocking basic villager secrets for this player . . .");
			-- set an ingame Property for this Player to track future Villager Secrets reward(s)
			pPlayer:SetProperty(sRewardSubType, 0);
			GUE.PlayerData[iPlayerID].VillagerSecretsLevel = 0;
			-- unlock the level 0 building
			local sUnlockTribalTotem = sTribalTotem .. "0";
			GUE.AddModifierToPlayer(iPlayerID, sUnlockTribalTotem, true);
			-- send an ingame notification for each unlocked secret
			NotificationManager.SendNotification(iPlayerID, GUE.Notification.Secrets.TypeHash, GUE.Notification.Secrets.Title, GUE.Notification.Secrets.Message);
		-- this should fire any time after the first time this Player receives the Villager Secrets reward, until all defined secrets are unlocked
		elseif (PlayerProperty < 5) then
			-- configure the unlock tracker for this Player
			local iNumUnlocks = PlayerProperty + 1;
			-- log output
			print("The Villager Secrets reward has previously been granted " .. iNumUnlocks .. " time(s) to Player " .. iPlayerID .. "; unlocking additional villager secrets for this player . . .");
			-- update the ingame Property for this Player to reflect the number of times this reward has been received
			pPlayer:SetProperty(sRewardSubType, iNumUnlocks);
			GUE.PlayerData[iPlayerID].VillagerSecretsLevel = iNumUnlocks;
			-- unlock the updated building indicated by the unlock tracker
			local sUnlockTribalTotem = sTribalTotem .. iNumUnlocks;
			GUE.AddModifierToPlayer(iPlayerID, sUnlockTribalTotem, true);
			-- send an ingame notification for each unlocked secret
			NotificationManager.SendNotification(iPlayerID, GUE.Notification.Secrets.TypeHash, GUE.Notification.Secrets.Title, GUE.Notification.Secrets.Message);
		-- this should fire any time after this Player has already received the Villager Secrets reward enough times to unlock all available defined secrets
		else
			print("The Villager Secrets reward has already been granted the maximum number of time(s) to Player " .. iPlayerID .. "; spawning hyper-aggressive hostile villagers instead . . .");
			Dprint("'STUB'");
		end
	-- do nothing if iPlayerID represents an invalid Player
	else
		Dprint("'FAILED' to fetch player data for Player " .. iPlayerID .. "; doing nothing.");
	end
	-- define function exit message(s)
	local sPriExitMsg = "Turn " .. iTurn .. " | Era " .. iEra .. " | Exit UnlockVillagerSecrets()";
	-- print exit message(s) to the log when debugging
	Dprint(sPriExitMsg);
end

--[[ =========================================================================
	exposed member function GetNewRewards()
	rolls iNumRewards new bonus reward(s) when bonus rewards are enabled
	rolls a replacement reward if sRewardSubType is the villagers secrets reward and Player iPlayerID has already received it the maximum number of times
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
function GUE.GetNewRewards( iNumRewards, iPlayerID, iX, iY, sRewardSubType, iTurn, iEra, tUnits )
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
					-- get a random number between 1 and TotalBonusRewardWeight
					local iBonusIndex = TerrainBuilder.GetRandomNumber(GUE.TotalBonusRewardWeight, "Bonus reward index") + 1;
					-- iterate over the enabled rewards table
					for k, v in pairs(GUE.ValidRewards) do
						-- true when iBonusIndex is in the range Start - End AND this is NOT the villager secrets reward when VillagerSecretsLevel meets or exceeds MaxSecretsLevel; k is the hash value of the reward
						if iBonusIndex >= v.Start and iBonusIndex <= v.End and not (v.SubTypeGoodyHut == GUE.VillagerSecrets and GUE.PlayerData[iPlayerID].VillagerSecretsLevel >= GUE.MaxSecretsLevel) then
							-- set the valid roll flag to indicate a successful new roll
							bIsValidRoll = true;
							-- fetch the object for the adjacent Plot in this direction ** 2021/07/26 this is hacky as fuck, and only works as long as n is always less than 6, which it *should* always be
							local pAdjacentPlot = Map.GetAdjacentPlot(iX, iY, (n - 1));
							-- fetch the (x, y) coordinates of the adjacent Plot object
							local aX, aY = pAdjacentPlot:GetX(), pAdjacentPlot:GetY();
							-- fetch the hostile modifier, subtype, reward modifier, rarity tier, and world view notification text for the current reward
							local iThisHostileModifier, sThisSubType, sThisModifier, sThisTier, sBonusRewardDesc = v.HostileModifier, v.SubTypeGoodyHut, v.ModifierID, v.Tier, Locale.Lookup(v.Description);
							-- these will ultimately contain the subtype and tier values of the last-rolled reward; they're only important for a replacement roll
							sNewSubType, sNewTier = sThisSubType, sThisTier;
							-- panel notification title
							local sBonusRewardTitle = GUE.Notification.Reward.Title;
							-- panel notification text
							local sBonusRewardMessage = GUE.Notification.Reward.Message .. " " .. sBonusRewardDesc .. ".";
							-- print log output if this is NOT a replacement roll for a presently-excluded reward
							if not (iNumRewards == 1 and sRewardSubType == GUE.VillagerSecrets and GUE.PlayerData[iPlayerID].VillagerSecretsLevel >= GUE.MaxSecretsLevel) then
								-- info message for logging
								local sPriInfoMsg = "The villagers also provide an additional " .. sThisTier .. " reward of " .. sThisSubType;
								-- log output
								print(sPriInfoMsg);
							end
							-- true when the rolled reward is a villager secrets reward
							if (sThisSubType == GUE.VillagerSecrets) then 
								-- true when this Player has received this reward fewer than the defined maximum amount of time(s)
								if (GUE.PlayerData[iPlayerID].VillagerSecretsLevel < GUE.MaxSecretsLevel) then
									GUE.UnlockVillagerSecrets(iPlayerID, iTurn, iEra, sThisSubType);
								else
									Dprint("VillagerSecretsLevel >= MaxSecretsLevel for Player " .. iPlayerID);
								end
							-- true when the rolled reward is a unit ability reward
							elseif (GUE.UnitAbilityRewards[sThisSubType] ~= nil) then GUE.AddAbilityToUnit(iX, iY, tUnits, GUE.UnitAbilityRewards[sThisSubType]);
							-- true when the rolled reward is a hostile villagers "reward"; set the bonus hostiles flag
							elseif GUE.HostileVillagers[sThisSubType] then bBonusHostiles = true;
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
							NotificationManager.SendNotification(iPlayerID, GUE.Notification.Reward.TypeHash, sBonusRewardTitle, sBonusRewardMessage, aX, aY);
						end
					end
					-- increment the rolls tracker and try again if the valid roll flag remains unset
					iNumRolls = iNumRolls + 1;
				end
				-- debugging log output
				if iNumRewards == 1 and sRewardSubType == GUE.VillagerSecrets and GUE.PlayerData[iPlayerID].VillagerSecretsLevel >= GUE.MaxSecretsLevel then
					-- single replacement reward
					Dprint("Found replacement reward in " .. iNumRolls .. " roll(s); New Initial Hostile modifier: " .. iSumModifiers);
				else
					-- bonus reward(s)
					Dprint("Found reward " .. n .. " of " .. iNumRewards .. " in " .. iNumRolls .. " roll(s); Cumulative Bonus Hostile modifier: " .. iSumModifiers);
				end
			end
		end
	end
	-- return the values of the cumulative modifier and the bonus hostiles flag
	return iSumModifiers, bBonusHostiles, sNewSubType, sNewTier;
end

--[[ =========================================================================
	exposed member function ValidateGoodyHutReward()
	use arguments consolidated from OnGoodyHutReward and OnImprovementActivated, and
		validate and execute any applicable enhanced method(s) on the current goody hut reward
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
function GUE.ValidateGoodyHutReward( tImprovementActivated, tGoodyHutReward )
	-- abort here if the queues are misaligned
	if (tImprovementActivated.IsExpand ~= tGoodyHutReward.IsExpand) or (tImprovementActivated.IsExplore ~= tGoodyHutReward.IsExplore) then
		-- define warning message(s)
		local sPriWarnMsg = "WARNING ValidateGoodyHutReward() Misaligned queues detected; skipping this reward";
		-- print warning message(s) to the log and abort
		print(sPriWarnMsg);
		return;
	end
	-- fetch values from the passed ImprovementActivated table
	local iX, iY, iPlayerID, iUnitID = tImprovementActivated.X, tImprovementActivated.Y, tImprovementActivated.PlayerID, tImprovementActivated.UnitID;
	-- more values from the passed ImprovementActivated table
	local bIsExpand, bIsExplore = tImprovementActivated.IsExpand, tImprovementActivated.IsExplore;
	-- fetch values from the passed GoodyHutReward table
	local iTypeHash, iSubTypeHash = tGoodyHutReward.TypeHash, tGoodyHutReward.SubTypeHash;
	-- identify the current global or player Era
	local iEra, iTurn = (GUE.Ruleset == "RULESET_STANDARD") and GUE.PlayerData[iPlayerID].Era or GUE.CurrentEra, GUE.CurrentTurn;
	-- define function entry messages
	local sPriEntryMsg = "ENTER ValidateGoodyHutReward( iTurn = " .. iTurn .. ", iEra = " .. iEra .. ", iX = " .. iX .. ", iY = " .. iY 
		.. ", iPlayerID = " .. iPlayerID .. ", iUnitID = " .. iUnitID .. ", bIsExpand = " .. tostring(bIsExpand) .. ", bIsExplore = " .. tostring(bIsExplore) 
		.. ", iTypeHash = " .. iTypeHash .. ", iSubTypeHash = " .. iSubTypeHash .. " )";
	-- print entry messages to the log when debugging
	Dprint(sPriEntryMsg);
	-- fetch data for the popping unit, if any, and initialize the units in plot table and tracker
	local pThisUnit, iNumUnitsInPlot, tUnitsInPlot = (iUnitID ~= -1) and Players[iPlayerID]:GetUnits():FindID(iUnitID) or nil, 0, {};
	-- current (x, y) Plot coordinates of the popping unit, if any; necessary if the unit has moved after popping a hut
	local jX, jY = pThisUnit and pThisUnit:GetX() or nil, pThisUnit and pThisUnit:GetY() or nil;
	-- fetch more data about the popping unit(s)
	if jX and jY then 
		-- iterate over all unit(s) found in this Plot
		for i, pUnit in ipairs(Units.GetUnitsInPlotLayerID(jX, jY, MapLayers.ANY)) do
			-- fetch this unit's ID and OwnerID
			local iThisUnitID, iThisUnitOwnerID = pUnit:GetID(), pUnit:GetOwner();
			-- make sure this unit belongs to this Player
			if iThisUnitOwnerID == iPlayerID then
				-- data for this unit
				local pUnitData = GameInfo.Units[pUnit:GetType()];
				-- store the entire unit table for and select details about this unit in the units in plot table table, keyed to its ID
				tUnitsInPlot[iThisUnitID] = { Table = pUnit, UnitType = pUnitData.UnitType, PromotionClass = pUnitData.PromotionClass };
				-- increment the units in plot tracker
				iNumUnitsInPlot = iNumUnitsInPlot + 1;
			end 
		end 
	end
	-- initialize the hostiles as bonus reward and the replacement reward flag(s)
	local bHostilesAsBonusReward, bIsReplacement = false, false;
	-- the hostile modifier of the received reward
	local iThisRewardModifier = GUE.GoodyHutRewards[iSubTypeHash].HostileModifier;
	-- fetch the type, subtype, and tier of the received reward
	local sRewardType, sRewardSubType, sRewardTier = GUE.GoodyHutTypes[iTypeHash].GoodyHutType, GUE.GoodyHutRewards[iSubTypeHash].SubTypeGoodyHut, GUE.GoodyHutRewards[iSubTypeHash].Tier;
	-- if the received reward is villager secrets, and the Player has already received it the maximum number of times, roll a replacement reward
	if sRewardSubType == GUE.VillagerSecrets and GUE.PlayerData[iPlayerID].VillagerSecretsLevel >= GUE.MaxSecretsLevel then 
		-- debugging output
		Dprint("VillagerSecretsLevel >= MaxSecretsLevel for Player " .. iPlayerID .. "; rolling new reward to replace " .. sRewardSubType .. " . . .");
		-- roll one new reward, and reset the hostile modifier, hostiles as bonus reward flag, reward subtype, and reward tier accordingly
		iThisRewardModifier, bHostilesAsBonusReward, sRewardSubType, sRewardTier = GUE.GetNewRewards(1, iPlayerID, iX, iY, sRewardSubType, iTurn, iEra, tUnitsInPlot);
		-- set the replacement reward flag
		bIsReplacement = true;
	end
	-- this Player's Civilization type
	local sCivTypeName = GUE.PlayerData[iPlayerID].CivTypeName;
	-- the Type and PromotionClass of iUnitID, if valid
	local sUnitType, sPromotionClass = (iNumUnitsInPlot > 0) and tUnitsInPlot[iUnitID].UnitType or nil, (iNumUnitsInPlot > 0) and tUnitsInPlot[iUnitID].PromotionClass or nil;
	-- define the log message
	local sPriLogMsg = "Turn " .. iTurn .. " | Era " .. iEra .. " | Player " .. iPlayerID .. " (" .. sCivTypeName .. ") found a " .. sRewardType .. " village ";
	-- initialize increased and decreased hostility flags
	local bIsIncreasedHostility, bIsDecreasedHostility = false, false;
	-- goody hut popped by exploration
	if bIsExplore then 
		-- if this Unit is a high-value target, set the increased hostility flag
		if GUE.HighValueTargets[sUnitType] ~= nil then bIsIncreasedHostility = true;
		-- if this Unit's promotion class is a decreased hostility class, set the decreased hostility unit flag
		elseif GUE.DecreasedHostilityPromotionClasses[sPromotionClass] ~= nil then bIsDecreasedHostility = true;
		end
		-- reflect an exploration reward with unit details in the log message
		sPriLogMsg = sPriLogMsg .. "with a " .. sUnitType;
		-- formation check
		if iNumUnitsInPlot > 1 then
			-- identify other unit(s) in the formation
			for k, v in pairs(tUnitsInPlot) do if k ~= iUnitID then sPriLogMsg = sPriLogMsg .. "/" .. v.UnitType; end end
			-- adjust log output
			sPriLogMsg = sPriLogMsg .. " formation"
		end
	-- goody hut popped via expansion
	elseif bIsExpand then
		-- reflect an expansion reward in the log message
		sPriLogMsg = sPriLogMsg .. "via border expansion";
	-- goody hut popped through unknown means
	else
		-- reflect other rewards in the log message
		sPriLogMsg = sPriLogMsg .. "through unknown means";
	end
	-- reflect the goody hut map coordinates in the log message
	sPriLogMsg = sPriLogMsg .. " at Plot (x " .. iX .. ", y " .. iY .. ")";
	-- pedantry - indicate if this is a replacement reward
	local sReplacement = (bIsReplacement) and " replacement" or "";
	-- define the secondary log message
	local sSecLogMsg = ", and received a";
	-- more (obvious) pedantry
	if (sRewardTier == "Uncommon") then sSecLogMsg = sSecLogMsg .. "n"; end
	-- reflect the received reward and its rarity tier in the secondary log message
	sSecLogMsg = sSecLogMsg .. " " .. sRewardTier .. sReplacement .. " reward of " .. sRewardSubType;
	-- print the log message(s)
	print(sPriLogMsg .. sSecLogMsg);
	-- execute the UnlockVillagerSecrets() enhanced method here if this reward is a valid Villager Secrets reward
	if (sRewardSubType == GUE.VillagerSecrets) then 
		-- this Player has villager secrets left to unlock, so unlock the next level
		if (GUE.PlayerData[iPlayerID].VillagerSecretsLevel < GUE.MaxSecretsLevel) then GUE.UnlockVillagerSecrets(iPlayerID, iTurn, iEra, sRewardSubType);
		-- max villager secrets rewards already received by this Player ** 2021/07/28 this may not ever fire any more
		else
			-- debugging output
			Dprint("VillagerSecretsLevel >= MaxSecretsLevel for Player " .. iPlayerID .. "; rolling new reward to replace " .. sRewardSubType .. " . . .");
			-- roll for one new reward
			iThisRewardModifier, bHostilesAsBonusReward = GUE.GetNewRewards(1, iPlayerID, iX, iY, sRewardSubType, iTurn, iEra, tUnitsInPlot);
		end
	-- execute the AddAbilityToUnit() enhanced method here if this reward is a unit ability reward
	elseif (GUE.UnitAbilityRewards[sRewardSubType] ~= nil and bIsExplore) then GUE.AddAbilityToUnit(iX, iY, tUnitsInPlot, GUE.UnitAbilityRewards[sRewardSubType]);
	-- execute the CreateHostileVillagers() enhanced method here if this reward is a valid Hostile Villagers "reward"
	elseif (GUE.HostileVillagers[sRewardSubType] ~= nil) then GUE.CreateHostileVillagers(iX, iY, iPlayerID, iTurn, iEra, sRewardSubType);
	end
	-- initialize the hostile modifier for bonus reward(s)
	local iBonusRewardModifier = 0;
	-- roll for any bonus rewards and store the cumulative hostile modifier sum and status of the hostiles as bonus reward flag
	if not bHostilesAsBonusReward then iBonusRewardModifier, bHostilesAsBonusReward = GUE.GetNewRewards(GUE.BonusRewardsPerGoodyHut, iPlayerID, iX, iY, sRewardSubType, iTurn, iEra, tUnitsInPlot); end
	-- the difficulty modifier remains constant throughout the game
	local iDifficultyModifier = GUE.PlayerData[iPlayerID].Difficulty;
	-- hostile villagers will appear when the calculated hostiles chance below equals or exceeds this value
	local iSpawnThreshold = 100;
	-- roll for hostile villagers AFTER other enhanced method(s) here, IF hostiles after rewards are enabled AND this reward is NOT one of the guaranteed hostiles "rewards" AND hostiles were NOT a bonus reward
	if (GUE.HostilesAfterReward > 1) and (GUE.HostileVillagers[sRewardSubType] == nil) and not (bHostilesAsBonusReward) then
		-- determine villager hostility level
		local sHostilityLevel = GUE.DetermineVillagerHostility(bIsExpand, bIsIncreasedHostility, bIsDecreasedHostility, iDifficultyModifier, iThisRewardModifier, iBonusRewardModifier, iEra, iSpawnThreshold);
		-- spawn hostiles if the villagers are pissed enough
		if (GUE.HostileVillagers[sHostilityLevel] ~= nil) then GUE.CreateHostileVillagers(iX, iY, iPlayerID, iTurn, iEra, sHostilityLevel); end
	end
	-- define function exit message(s)
	local sPriExitMsg = "EXIT ValidateGoodyHutReward(): Turn " .. iTurn .. ", Era " .. iEra;
	-- print exit message(s) to the log when debugging
	Dprint(sPriExitMsg);
end

--[[ =========================================================================
	hook function EG_OnGoodyHutReward() ** 2021/07/22 possible GoodyHutReward before ImprovementActivated for Sumeria's civ ability spotted **
	fires whenever a goody hut is popped, including the meteor strike reward
	pre-init : this should be defined and hooked to Events.GoodyHutReward in EG_OnLoadScreenClose() prior to Initialize()
=========================================================================== ]]
function EG_OnGoodyHutReward( iPlayerID, iUnitID, iTypeHash, iSubTypeHash )
	-- true when Sumeria's civilization ability has fired, or this is the meteor strike reward
	if GUE.SumerianCivAbilityTrigger > 0 or (GUE.GoodyHutTypes[iTypeHash].GoodyHutType == "METEOR_GOODIES" and GUE.GoodyHutRewards[iSubTypeHash].SubTypeGoodyHut == "METEOR_GRANT_GOODIES") then
		-- define local warning message(s)
		local sPriWarnMsg = "WARNING EG_OnGoodyHutReward() ";
		local sSecWarnMsg = (GUE.SumerianCivAbilityTrigger > 0) and "Ignoring reward received via Sumeria's civilization ability ( " .. GUE.SumerianCivAbilityTrigger .. " )" or "Ignoring meteor strike reward";
		-- if the Sumerian civ ability has triggered, decrement the counter
		if GUE.SumerianCivAbilityTrigger > 0 then GUE.SumerianCivAbilityTrigger = GUE.SumerianCivAbilityTrigger - 1; end
		-- print warning message(s) to the log and abort
		print(sPriWarnMsg .. sSecWarnMsg);
		return;
	end
	-- define function entry message(s)
	local sPriEntryMsg = "ENTER EG_OnGoodyHutReward( iPlayerID = " .. iPlayerID .. ", iUnitID = " .. iUnitID .. ", iTypeHash = " .. iTypeHash .. ", iSubTypeHash = " .. iSubTypeHash .. " )";
	-- print entry message(s) to the log when debugging
	Dprint(sPriEntryMsg);
	-- initialize the local event results table; any pertinent argument(s) go here
	local tGoodyHutReward = {};
	-- store all passed arguments within the results table
	tGoodyHutReward.PlayerID, tGoodyHutReward.UnitID, tGoodyHutReward.TypeHash, tGoodyHutReward.SubTypeHash, tGoodyHutReward.Units = iPlayerID, iUnitID, iTypeHash, iSubTypeHash, { Count = 0 };
	-- set the expansion and exploration flags based on the passed PlayerID and UnitID values
	tGoodyHutReward.IsExpand, tGoodyHutReward.IsExplore = (iUnitID == -1 and iPlayerID == -1) and true or false, (iUnitID > -1 and iPlayerID > -1) and true or false;
	-- this fires when Events.GoodyHutReward has fired BEFORE Events.ImprovementActivated this turn
	if (#GUE.QueueImprovementActivated == 0) then
		-- insert the local table into the global QueueGoodyHutReward
		table.insert(GUE.QueueGoodyHutReward, tGoodyHutReward);
		-- initialize debugging message(s)
		local sPriDebugMsg = "Events.GoodyHutReward fired FIRST; pushing argument(s) to GUE.QueueGoodyHutReward[ " .. #GUE.QueueGoodyHutReward .. " ]: ";
		local sSecDebugMsg = "iPlayerID = " .. tGoodyHutReward.PlayerID  .. ", iUnitID = " .. tGoodyHutReward.UnitID 
			.. ", bIsExpand = " .. tostring(tGoodyHutReward.IsExpand) .. ", bIsExplore = " .. tostring(tGoodyHutReward.IsExplore) 
			.. ", iTypeHash = " .. tGoodyHutReward.TypeHash .. ", iSubTypeHash = " .. tGoodyHutReward.SubTypeHash;
		-- debugging output
		Dprint(sPriDebugMsg .. sSecDebugMsg);
	-- this fires when Events.GoodyHutReward has fired AFTER Events.ImprovementActivated this turn
	elseif (#GUE.QueueImprovementActivated > 0) then
		-- initialize a table to store this other Event's fetched argument(s)
		tImprovementActivated = {};
		-- iterate over the first index in the global QueueGoodyHutReward and add its data to the other Event table
		for k, v in pairs(GUE.QueueImprovementActivated[1]) do tImprovementActivated[k] = v; end
		-- remove the first index from the global QueueGoodyHutReward
		table.remove(GUE.QueueImprovementActivated, 1);
		-- debugging log output
		local sPriDebugMsg = "Events.GoodyHutReward fired SECOND; pulling argument(s) from GUE.QueueImprovementActivated[ 1 ] ( " .. #GUE.QueueImprovementActivated .. " item(s) remaining in this queue )";
		Dprint(sPriDebugMsg);
		-- use the consolidated arguments to validate and execute enhanced method(s), if any, on this reward
		GUE.ValidateGoodyHutReward(tImprovementActivated, tGoodyHutReward);
	end
	-- define function exit message(s)
	local sPriExitMsg = "EXIT EG_OnGoodyHutReward()";
	-- print exit message(s) to the log when debugging
	Dprint(sPriExitMsg);
end

--[[ =========================================================================
	hook function EG_OnImprovementActivated() ** 2021/07/22 possible GoodyHutReward before ImprovementActivated for Sumeria's civ ability spotted **
	fires whenever an improvement is activated, including any goody hut other than the meteor strike reward
	pre-init : this should be defined and hooked to Events.ImprovementActivated in EG_OnLoadScreenClose() prior to Initialize()
=========================================================================== ]]
function EG_OnImprovementActivated( iX, iY, iOwnerID, iUnitID, iImprovementIndex, iImprovementOwnerID, iActivationType )
	-- Sumeria receives a random goody hut reward upon clearing a barbarian camp; this reward should be ignored, so set a flag if the Player is Sumeria, and abort
	if (iImprovementIndex == GUE.BarbCampIndex) then
		-- true when either iOwnerID or iImprovementOwnerID is Sumeria
		if (iOwnerID > -1 and GUE.PlayerData[iOwnerID] and GUE.PlayerData[iOwnerID].IsSumeria) or (iImprovementOwnerID > -1 and GUE.PlayerData[iImprovementOwnerID] and GUE.PlayerData[iImprovementOwnerID].IsSumeria) then 
			-- increment the Sumerian ability trigger
			GUE.SumerianCivAbilityTrigger = GUE.SumerianCivAbilityTrigger + 1;
			-- define local warning message(s)
			local sPriWarnMsg = "WARNING EG_OnImprovementActivated() Ignoring reward received via Sumeria's civilization ability ( " .. GUE.SumerianCivAbilityTrigger .. " )";
			-- print warning message(s) to the log
			print(sPriWarnMsg);
		end
		return;
	-- if the activated improvement is otherwise NOT a goody hut, do nothing and abort
	elseif (iImprovementIndex ~= GUE.GoodyHutIndex) then return;
	end
	-- define function entry messages
	local sPriEntryMsg = "ENTER EG_OnImprovementActivated( iX = " .. iX .. ", iY = " .. iY .. ", iOwnerID = " .. iOwnerID .. ", iUnitID = " .. iUnitID
		.. ", iImprovementIndex = " .. iImprovementIndex .. ", iImprovementOwnerID = " .. iImprovementOwnerID .. ", iActivationType = " .. iActivationType .. " )";
	-- print entry messages to the log when debugging
	Dprint(sPriEntryMsg);
	-- initialize the local event results table; any pertinent argument(s) go here
	local tImprovementActivated = {};
	-- store the passed (x, y) Plot coordinate values, and the OwnerID, ImprovementOwnerID, and UnitID values in the results table
	tImprovementActivated.X, tImprovementActivated.Y, tImprovementActivated.OwnerID, tImprovementActivated.ImprovementOwnerID, tImprovementActivated.UnitID = iX, iY, iOwnerID, iImprovementOwnerID, iUnitID;
	-- initialize the table of popping unit(s)
	tImprovementActivated.Units = { Count = 0 };
	-- set the expansion and exploration flags based on the passed UnitID, OwnerID, and ImprovementOwnerID values; store these flags in the results table
	tImprovementActivated.IsExpand, tImprovementActivated.IsExplore = (iUnitID == -1 and iImprovementOwnerID > -1) and true or false, (iUnitID ~= -1 and iOwnerID > -1) and true or false;
	-- set the PlayerID based on the status of the expansion flag; store this value in the results table
	tImprovementActivated.PlayerID = tImprovementActivated.IsExpand and iImprovementOwnerID or iOwnerID;
	-- this fires when Events.ImprovementActivated has fired BEFORE Events.GoodyHutReward this turn
	if (#GUE.QueueGoodyHutReward == 0) then
		-- insert the local table into the global QueueImprovementActivated
		table.insert(GUE.QueueImprovementActivated, tImprovementActivated);
		-- initialize debugging message(s)
		local sPriDebugMsg = "Events.ImprovementActivated fired FIRST; pushing argument(s) to GUE.QueueImprovementActivated[ " .. #GUE.QueueImprovementActivated .. " ]: ";
		local sSecDebugMsg = "iX = " .. tImprovementActivated.X .. ", iY = " .. tImprovementActivated.Y .. ", iPlayerID = " .. tImprovementActivated.PlayerID  .. ", iUnitID = " .. tImprovementActivated.UnitID 
			.. ", bIsExpand = " .. tostring(tImprovementActivated.IsExpand) .. ", bIsExplore = " .. tostring(tImprovementActivated.IsExplore);
		-- debugging log output
		Dprint(sPriDebugMsg .. sSecDebugMsg);
	-- this fires when Events.ImprovementActivated has fired AFTER Events.GoodyHutReward this turn
	elseif (#GUE.QueueGoodyHutReward > 0) then
		-- initialize a table to store this other Event's fetched argument(s)
		tGoodyHutReward = {};
		-- iterate over the first index in the global QueueGoodyHutReward and add its data to the other Event table
		for k, v in pairs(GUE.QueueGoodyHutReward[1]) do tGoodyHutReward[k] = v; end
		-- remove the first index from the global QueueGoodyHutReward
		table.remove(GUE.QueueGoodyHutReward, 1);
		-- debugging log output
		local sPriDebugMsg = "Events.ImprovementActivated fired SECOND; pulling argument(s) from GUE.QueueGoodyHutReward[ 1 ] ( " .. #GUE.QueueGoodyHutReward .. " item(s) remaining in this queue )";
		Dprint(sPriDebugMsg);
		-- use the consolidated arguments to validate and execute enhanced method(s), if any, on this reward
		GUE.ValidateGoodyHutReward(tImprovementActivated, tGoodyHutReward);
	end
	-- define function exit message(s)
	local sPriExitMsg = "EXIT EG_OnImprovementActivated()";
	-- print exit message(s) to the log when debugging
	Dprint(sPriExitMsg);
end

--[[ =========================================================================
	hook function EG_OnPlayerTurnDeactivated()
	resets event argument queue(s) if their counts differ at the end of a Player's turn
	when this fires, some enhanced method(s) may not fire on any orphaned reward(s), and earlier enhanced method(s) may not have been entirely accurate in their delivery
		however, this should prevent similar future problem(s), unless the queues become misaligned again, in which case we end up back here
	as the queue(s) usually properly maintain themselves, this should only fire in rare circumstances; multiple firings in a session indicate something screwy in that session
	pre-init : this should be defined and hooked to Events.PlayerTurnDeactivated in EG_OnLoadScreenClose() prior to Initialize()
=========================================================================== ]]
function EG_OnPlayerTurnDeactivated( iPlayerID )
	-- this fires when these queue(s) are misaligned in any way at end-of-turn
	if #GUE.QueueGoodyHutReward ~= #GUE.QueueImprovementActivated then
		-- reset argument queue(s), and initialize or increment the forced resets tracker
		GUE.QueueGoodyHutReward, GUE.QueueImprovementActivated, GUE.ForcedQueueResets = {}, {}, (GUE.ForcedQueueResets) and GUE.ForcedQueueResets + 1 or 1;
		-- define function entry message(s)
		local sPriEntryMsg = "WARNING EG_OnPlayerTurnDeactivated() Resetting misaligned argument queue(s) at end-of-turn for iPlayerID " .. iPlayerID .. "; this has now happened " .. GUE.ForcedQueueResets 
			.. " total time(s) this session";
		-- print entry message(s) to the log when debugging
		print(sPriEntryMsg);
	end
end

--[[ =========================================================================
	function EG_OnLoadScreenClose()
	custom hooks should go here unless they need to be somewhere else
	init : this should be hooked to Events.LoadScreenClose in Initialize()
=========================================================================== ]]
function EG_OnLoadScreenClose()
	-- no valid log output occurs here, so put any needed log commentary elsewhere
	Events.GoodyHutReward.Add(EG_OnGoodyHutReward);
	Events.ImprovementActivated.Add(EG_OnImprovementActivated);
	Events.PlayerTurnDeactivated.Add(EG_OnPlayerTurnDeactivated);
end

--[[ =========================================================================
	function Initialize()
	final configuration prior to startup
=========================================================================== ]]
function Initialize()
	-- log init messages
	print(GUE.RowOfDashes);
    print("Configuring Enhanced Goodies component(s) . . .");
	-- bonus reward config
	print(GUE.RowOfDashes);
	print("Bonus Reward(s) per Tribal Village: " .. GUE.BonusRewardsPerGoodyHut);
	print("Configuring bonus reward(s) . . .");
	-- 
	if not GUE.NoGoodyHuts and GUE.BonusRewardCount > 0 then
		for k, v in pairs(GUE.ValidRewards) do
			Dprint("+ [" .. v.Start .. " - " .. v.End .. "]: Subtype " .. v.SubTypeGoodyHut .. ", ModifierID " .. v.ModifierID .. ", Weight " .. v.Weight);
		end
		print("There are " .. GUE.BonusRewardCount .. " eligible reward(s) in the bonus rewards table; Cumulative Weight/RNG Seed Value: " .. GUE.TotalBonusRewardWeight);
	else
		print("There are 'zero' eligible reward(s) in the bonus rewards table, or the 'No Tribal Villages' setup option is enabled; skipping . . .");
	end
    -- Events hooks
	print(GUE.RowOfDashes);
	print("Configuring hook(s) for ingame Event(s) . . .");
	Events.LoadScreenClose.Add(EG_OnLoadScreenClose);
	Dprint("Successfully added hook function EG_OnLoadScreenClose() to Events.LoadScreenClose");
	Dprint(" + Successfully added hook function EG_OnGoodyHutReward() to Events.GoodyHutReward");
	Dprint(" + Successfully added hook function EG_OnImprovementActivated() to Events.ImprovementActivated");
	Dprint(" + Successfully added hook function EG_OnPlayerTurnDeactivated() to Events.PlayerTurnDeactivated");
	Dprint("Finished configuring hook(s) for ingame Event(s); proceeding . . .");
	print(GUE.RowOfDashes);
	print("Finished initializing and configuring required component(s); proceeding . . .");
end

-- execute function Initialize() here
-- GUE.DebugEnabled = true;
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
	end EnhancedGoodies.lua gameplay script
=========================================================================== ]]

--[[ =========================================================================
	hook function Old_EG_OnGoodyHutReward() ** 2021/07/22 possible GoodyHutReward before ImprovementActivated for Sumeria's civ ability spotted ** DEPRECATED **
	fires whenever a goody hut is popped, including the meteor strike reward
	pre-init : this should be defined and hooked to Events.GoodyHutReward in EG_OnLoadScreenClose() prior to Initialize()
=========================================================================== ]]
-- function Old_EG_OnGoodyHutReward( iPlayerID, iUnitID, iTypeHash, iSubTypeHash )
-- 	-- if the Sumerian civ ability has triggered, reset the flag and abort
-- 	if (GUE.SumerianCivAbilityTrigger) then
-- 		-- define local warning message(s)
-- 		local sPriWarnMsg = "WARNING EG_OnGoodyHutReward() Ignoring reward received via Sumeria's civilization ability";
-- 		-- print warning message(s) to the log when debugging
-- 		print(sPriWarnMsg);
-- 		-- reset the Sumerian civ ability flag
-- 		GUE.SumerianCivAbilityTrigger = false;
-- 		return;
-- 	-- otherwise do nothing and abort if this is the meteor strike reward
-- 	elseif (GUE.GoodyHutTypes[iTypeHash].GoodyHutType == "METEOR_GOODIES") and (GUE.GoodyHutRewards[iSubTypeHash].SubTypeGoodyHut == "METEOR_GRANT_GOODIES") then
-- 		-- define local warning message(s)
-- 		local sLocalWarnMsg = "WARNING EG_OnGoodyHutReward() Ignoring the meteor strike reward . . .";
-- 		-- print warning message(s) to the log when debugging
-- 		print(sLocalWarnMsg);
-- 		return;
-- 	end
-- 	-- define function entry message(s)
-- 	local sPriEntryMsg = "Enter EG_OnGoodyHutReward( iPlayerID = " .. iPlayerID .. ", iUnitID = " .. iUnitID
-- 		.. ", iTypeHash = " .. iTypeHash .. ", iSubTypeHash = " .. iSubTypeHash .. " )";
-- 	-- print entry message(s) to the log when debugging
-- 	Dprint(sPriEntryMsg);
-- 	-- define a local table for any pertinent argument(s) to be stored or passed
-- 	local tCurrentArgs = {};
-- 	-- store any argument(s) which are pertinent in this local table
-- 	tCurrentArgs.PlayerID = iPlayerID;
-- 	tCurrentArgs.UnitID_GHR = iUnitID;
-- 	tCurrentArgs.TypeHash = iTypeHash;
-- 	tCurrentArgs.SubTypeHash = iSubTypeHash;
-- 	-- this fires when Events.GoodyHutReward has fired BEFORE Events.ImprovementActivated this turn
-- 	if (#GUE.QueueImprovementActivated == 0) then
-- 		-- define local info message(s)
-- 		local sPriInfoMsg = "Events.GoodyHutReward fired FIRST for the current reward; adding pertinent argument(s) to the end of GUE.QueueGoodyHutReward . . .";
-- 		-- print info message(s) to the log when debugging
-- 		Dprint(sPriInfoMsg);
-- 		-- insert the local table into the global QueueGoodyHutReward
-- 		table.insert(GUE.QueueGoodyHutReward, tCurrentArgs);
-- 		-- define local info message(s)
-- 		local sSecInfoMsg = "GUE.QueueGoodyHutReward now contains " .. #GUE.QueueGoodyHutReward .. " item(s)";
-- 		-- print info message(s) to the log when debugging
-- 		Dprint(sSecInfoMsg);
-- 	-- this fires when Events.GoodyHutReward has fired AFTER Events.ImprovementActivated this turn
-- 	elseif (#GUE.QueueImprovementActivated > 0) then
-- 		-- define local info message(s)
-- 		local sPriInfoMsg = "Events.GoodyHutReward fired SECOND for the current reward; pulling pertinent argument(s) from the front of GUE.QueueImprovementActivated . . .";
-- 		-- print info message(s) to the log when debugging
-- 		Dprint(sPriInfoMsg);
-- 		-- iterate over the first index in the global QueueImprovementActivated and add its data to the local table
-- 		for k, v in pairs(GUE.QueueImprovementActivated[1]) do tCurrentArgs[k] = v; end
-- 		-- remove the first index from the global QueueImprovementActivated
-- 		table.remove(GUE.QueueImprovementActivated, 1);
-- 		-- fetch pertinent existing argument(s) from the local table
-- 		local iX = tCurrentArgs.PlotX;
-- 		local iY = tCurrentArgs.PlotY;
-- 		local iOwnerID = tCurrentArgs.OwnerID;
-- 		local iUnitID_IA = tCurrentArgs.UnitID_IA;
-- 		local iImprovementIndex = tCurrentArgs.ImprovementIndex;
-- 		local iImprovementOwnerID = tCurrentArgs.ImprovementOwnerID;
-- 		local iActivationType = tCurrentArgs.ActivationType;
-- 		-- define local info message(s)
-- 		local sSecInfoMsg = "Fetched argument(s): iX = " .. iX .. ", iY = " .. iY .. ", iOwnerID = " .. iOwnerID .. ", iUnitID_IA = " .. iUnitID_IA
-- 			.. ", iImprovementIndex = " .. iImprovementIndex .. ", iImprovementOwnerID = " .. iImprovementOwnerID .. ", iActivationType = " .. iActivationType;
-- 		local sTerInfoMsg = "GUE.QueueImprovementActivated now contains " .. #GUE.QueueImprovementActivated .. " item(s)";
-- 		-- print info message(s) to the log when debugging
-- 		Dprint(sSecInfoMsg);
-- 		Dprint(sTerInfoMsg);
-- 		-- use the consolidated arguments to validate and execute enhanced method(s), if any, on this reward
-- 		GUE.ValidateGoodyHutReward(tCurrentArgs);
-- 	-- strange things are afoot at the Circle K if this fires
-- 	else
-- 		-- define local warning message(s)
-- 		local sLocalWarnMsg = "WARNING EG_OnGoodyHutReward() GUE.QueueImprovementActivated appears to be undefined, so something weird but non-game-breaking has definitely happened here; proceeding . . .";
-- 		-- print warning message(s) to the log when debugging
-- 		print(sLocalWarnMsg);
-- 	end
-- 	-- define function exit message(s)
-- 	local sPriExitMsg = "Exit EG_OnGoodyHutReward()";
-- 	-- print exit message(s) to the log when debugging
-- 	Dprint(sPriExitMsg);
-- end

--[[ =========================================================================
	hook function EG_OnImprovementActivated() ** 2021/07/22 possible GoodyHutReward before ImprovementActivated for Sumeria's civ ability spotted ** DEPRECATED **
	fires whenever an improvement is activated, including any goody hut other than the meteor strike reward
	pre-init : this should be defined and hooked to Events.ImprovementActivated in EG_OnLoadScreenClose() prior to Initialize()
=========================================================================== ]]
-- function Old_EG_OnImprovementActivated( iX, iY, iOwnerID, iUnitID, iImprovementIndex, iImprovementOwnerID, iActivationType )
-- 	-- Sumeria receives a random goody hut reward upon clearing a barbarian camp; this reward should be ignored, so set the flag and abort
-- 	if (iImprovementIndex == GUE.BarbCampIndex) then
-- 		-- check iOwnerID to see if this Player is Sumeria
-- 		if (iOwnerID > -1) then
-- 			if (GUE.PlayerData[iOwnerID] ~= nil) then
-- 				if (GUE.PlayerData[iOwnerID].CivTypeName == "CIVILIZATION_SUMERIA") then
-- 					GUE.SumerianCivAbilityTrigger = true;
-- 				end
-- 			end
-- 		-- check iImprovementOwnerID to see if this Player is Sumeria
-- 		elseif (iImprovementOwnerID > -1) then
-- 			if (GUE.PlayerData[iImprovementOwnerID] ~= nil) then
-- 				if (GUE.PlayerData[iImprovementOwnerID].CivTypeName == "CIVILIZATION_SUMERIA") then
-- 					GUE.SumerianCivAbilityTrigger = true;
-- 				end
-- 			end
-- 		end
-- 		-- this is true when this Player is Sumeria
-- 		if (GUE.SumerianCivAbilityTrigger) then
-- 			-- define local warning message(s)
-- 			local sPriWarnMsg = "WARNING EG_OnImprovementActivated() Ignoring reward received via Sumeria's civilization ability";
-- 			-- print warning message(s) to the log when debugging
-- 			print(sPriWarnMsg);
-- 		end
-- 		return;
-- 	-- if the activated improvement is otherwise NOT a goody hut, do nothing and abort
-- 	elseif (iImprovementIndex ~= GUE.GoodyHutIndex) then
-- 		return;
-- 	end
-- 	-- define function entry messages
-- 	local sPriEntryMsg = "Enter EG_OnImprovementActivated( iX = " .. iX .. ", iY = " .. iY
-- 		.. ", iOwnerID = " .. iOwnerID .. ", iUnitID = " .. iUnitID
-- 		.. ", iImprovementIndex = " .. iImprovementIndex .. ", iImprovementOwnerID = " .. iImprovementOwnerID
-- 		.. ", iActivationType = " .. iActivationType .. " )";
-- 	-- print entry messages to the log when debugging
-- 	Dprint(sPriEntryMsg);
-- 	-- define a local table for any pertinent argument(s)
-- 	local tCurrentArgs = {};
	
-- 	-- store any argument(s) which are pertinent in this local table
-- 	tCurrentArgs.PlotX = iX;
-- 	tCurrentArgs.PlotY = iY;
-- 	tCurrentArgs.OwnerID = iOwnerID;
-- 	tCurrentArgs.UnitID_IA = iUnitID;
-- 	tCurrentArgs.ImprovementIndex = iImprovementIndex;
-- 	tCurrentArgs.ImprovementOwnerID = iImprovementOwnerID;
-- 	tCurrentArgs.ActivationType = iActivationType;
-- 	-- this fires when Events.ImprovementActivated has fired BEFORE Events.GoodyHutReward this turn
-- 	if (#GUE.QueueGoodyHutReward == 0) then
-- 		-- define local info message(s)
-- 		local sPriInfoMsg = "Events.ImprovementActivated fired FIRST for the current reward; adding pertinent argument(s) to the end of GUE.QueueImprovementActivated . . .";
-- 		-- print info message(s) to the log when debugging
-- 		Dprint(sPriInfoMsg);
-- 		-- insert the local table into the global QueueImprovementActivated
-- 		table.insert(GUE.QueueImprovementActivated, tCurrentArgs);
-- 		-- define local info message(s)
-- 		local sSecInfoMsg = "GUE.QueueImprovementActivated now contains " .. #GUE.QueueImprovementActivated .. " item(s)";
-- 		-- print info message(s) to the log when debugging
-- 		Dprint(sSecInfoMsg);
-- 	-- this fires when Events.ImprovementActivated has fired AFTER Events.GoodyHutReward this turn
-- 	elseif (#GUE.QueueGoodyHutReward > 0) then
-- 		-- define local info message(s)
-- 		local sPriInfoMsg = "Events.ImprovementActivated fired SECOND for the current reward; pulling pertinent argument(s) from the front of GUE.QueueGoodyHutReward . . .";
-- 		-- print info message(s) to the log when debugging
-- 		Dprint(sPriInfoMsg);
-- 		-- iterate over the first index in the global QueueGoodyHutReward and add its data to the local table
-- 		for k, v in pairs(GUE.QueueGoodyHutReward[1]) do tCurrentArgs[k] = v; end
-- 		-- remove the first index from the global QueueGoodyHutReward
-- 		table.remove(GUE.QueueGoodyHutReward, 1);
-- 		-- fetch pertinent existing argument(s) from the local table
-- 		local iPlayerID = tCurrentArgs.PlayerID;
-- 		local iUnitID_GHR = tCurrentArgs.UnitID_GHR;
-- 		local iSubTypeHash = tCurrentArgs.SubTypeHash;
-- 		local iTypeHash = tCurrentArgs.TypeHash;
-- 		-- define local info message(s)
-- 		local sSecInfoMsg = "Fetched argument(s): iPlayerID = " .. iPlayerID .. ", iUnitID_GHR = " .. iUnitID_GHR
-- 			.. ", iTypeHash = " .. iTypeHash .. ", iSubTypeHash = " .. iSubTypeHash;
-- 		local sTerInfoMsg = "GUE.QueueGoodyHutReward now contains " .. #GUE.QueueGoodyHutReward .. " item(s)";
-- 		-- print info message(s) to the log when debugging
-- 		Dprint(sSecInfoMsg);
-- 		Dprint(sTerInfoMsg);
-- 		-- use the consolidated arguments to validate and execute enhanced method(s), if any, on this reward
-- 		GUE.ValidateGoodyHutReward(tCurrentArgs);
-- 	-- strange things are afoot at the Circle K if this fires
-- 	else
-- 		-- define local warning message(s)
-- 		local sLocalWarnMsg = "WARNING EG_OnImprovementActivated() GUE.QueueGoodyHutReward appears to be undefined, so something weird but non-game-breaking has definitely happened here; proceeding . . .";
-- 		-- print warning message(s) to the log when debugging
-- 		print(sLocalWarnMsg);
-- 	end
-- 	-- define function exit message(s)
-- 	local sPriExitMsg = "Exit EG_OnImprovementActivated()";
-- 	-- print exit message(s) to the log when debugging
-- 	Dprint(sPriExitMsg);
-- end

--[[ =========================================================================
	exposed member function ValidateGoodyHutReward()
	use arguments consolidated from OnGoodyHutReward and OnImprovementActivated, and
		validate and execute any applicable enhanced method(s) on the current goody hut reward
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
-- function GUE.OldValidateGoodyHutReward( tArgs )
-- 	-- fetch the current global turn
-- 	local iTurn = GUE.CurrentTurn;
-- 	-- define the "true" Player here with a screwy value; if this value doesn't get changed below, there is a problem
-- 	local iPlayerID = -2;
-- 	-- PlayerID most likely represents the "true" Player
-- 	if (tArgs.PlayerID > -1) then iPlayerID = tArgs.PlayerID;
-- 	-- OwnerID likely represents the "true" Player IF PlayerID is invalid
-- 	elseif (tArgs.OwnerID > -1) then iPlayerID = tArgs.OwnerID;
-- 	-- ImprovementOwnerID likely represents the "true" Player IF both PlayerID AND OwnerID are invalid
-- 	elseif (tArgs.ImprovementOwnerID > -1) then iPlayerID = tArgs.ImprovementOwnerID;
-- 	end
-- 	-- identify the current global or player Era
-- 	local iEra = (GUE.Ruleset == "RULESET_STANDARD") and GUE.PlayerData[iPlayerID].Era or GUE.CurrentEra;
-- 	-- define function entry messages
-- 	local sPriEntryMsg = "Turn " .. iTurn .. " | Era " .. iEra
-- 		.. " | Enter ValidateGoodyHutReward( PlotX = " .. tArgs.PlotX .. ", PlotY = " .. tArgs.PlotY
-- 		.. ", OwnerID = " .. tArgs.OwnerID .. ", UnitID_IA = " .. tArgs.UnitID_IA
-- 		.. ", ImprovementIndex = " .. tArgs.ImprovementIndex .. ", ImprovementOwnerID = " .. tArgs.ImprovementOwnerID
-- 		.. ", ActivationType = " .. tArgs.ActivationType
-- 		.. ", PlayerID = " .. tArgs.PlayerID .. ", UnitID_GHR = " .. tArgs.UnitID_GHR
-- 		.. ", TypeHash = " .. tArgs.TypeHash .. ", SubTypeHash = " .. tArgs.SubTypeHash .. " )";
-- 	-- print entry messages to the log when debugging
-- 	Dprint(sPriEntryMsg);
-- 	-- spot check for equality between OwnerID and PlayerID; these values not being equal may indicate a problem
-- 	if (tArgs.OwnerID ~= tArgs.PlayerID) then
-- 		-- define local warning message(s)
-- 		local sLocalWarnMsg = "WARNING ValidateGoodyHutReward() OwnerID " .. tArgs.OwnerID .. " ~= PlayerID " .. tArgs.PlayerID
-- 			.. "; possible misalignment between Events.GoodyHutReward and Events.ImprovementActivated detected; proceeding regardless . . .";
-- 		-- print warning message(s) to the log when debugging
-- 		print(sLocalWarnMsg);
-- 	end
-- 	-- spot check for equality between UnitID_IA and UnitID_GHR
-- 	if (tArgs.UnitID_IA ~= tArgs.UnitID_GHR) then
-- 		-- define local warning message(s)
-- 		local sLocalWarnMsg = "WARNING ValidateGoodyHutReward() UnitID_IA " .. tArgs.UnitID_IA .. " ~= UnitID_GHR " .. tArgs.UnitID_GHR
-- 			.. "; possible misalignment between Events.GoodyHutReward and Events.ImprovementActivated detected; proceeding regardless . . .";
-- 		-- print warning message(s) to the log when debugging
-- 		print(sLocalWarnMsg);
-- 	end
-- 	-- initialize flag(s) that direct log output depending on whether this hut was popped by a unit or via border expansion
-- 	local bIsExpand = ((tArgs.UnitID_IA == -1) and (tArgs.UnitID_GHR == -1)) and true or false;
-- 	local bIsExplore = ((tArgs.UnitID_IA ~= -1) and (tArgs.UnitID_GHR ~= -1)) and true or false;
-- 	-- table of this Unit's data
-- 	local pUnit_IA = bIsExplore and Players[tArgs.OwnerID]:GetUnits():FindID(tArgs.UnitID_IA) or nil;
-- 	-- local pUnit_IA = Players[tArgs.OwnerID]:GetUnits():FindID(tArgs.UnitID_IA);
-- 	if (pUnit_IA == nil) then pUnit_IA = bIsExplore and Players[tArgs.ImprovementOwnerID]:GetUnits():FindID(tArgs.UnitID_IA) or nil; end
-- 	-- if (pUnit_IA == nil) then pUnit_IA = Players[tArgs.ImprovementOwnerID]:GetUnits():FindID(tArgs.UnitID_IA); end
-- 	local pUnit_GHR = bIsExplore and Players[tArgs.PlayerID]:GetUnits():FindID(tArgs.UnitID_GHR) or nil;
-- 	-- local pUnit_GHR = Players[tArgs.PlayerID]:GetUnits():FindID(tArgs.UnitID_GHR);
-- 	-- focused table of this Unit's data
-- 	local tUnitData_IA = bIsExplore and GameInfo.Units[pUnit_IA:GetType()] or nil;
-- 	local tUnitData_GHR = bIsExplore and GameInfo.Units[pUnit_GHR:GetType()] or nil;
-- 	-- local tUnitData_IA = GameInfo.Units[pUnit_IA:GetType()];
-- 	-- local tUnitData_GHR = GameInfo.Units[pUnit_GHR:GetType()];
-- 	-- this Unit's type
-- 	local sUnitType_IA = bIsExplore and tUnitData_IA.UnitType or nil;
-- 	local sUnitType_GHR = bIsExplore and tUnitData_GHR.UnitType or nil;
-- 	-- local sUnitType_IA = tUnitData_IA.UnitType;
-- 	-- local sUnitType_GHR = tUnitData_GHR.UnitType;
-- 	-- this Unit's promotion class
-- 	local sUnitPromotionClass_IA = bIsExplore and tUnitData_IA.PromotionClass or nil;
-- 	local sUnitPromotionClass_GHR = bIsExplore and tUnitData_GHR.PromotionClass or nil;
-- 	local sUnitPromotionClass = (sUnitPromotionClass_IA == sUnitPromotionClass_GHR) and sUnitPromotionClass_IA or nil;
-- 	-- local sUnitPromotionClass_IA = tUnitData_IA.PromotionClass;
-- 	-- local sUnitPromotionClass_GHR = tUnitData_GHR.PromotionClass;
-- 	-- strange things are afoot at the Circle K if this fires
-- 	if ((tArgs.UnitID_IA == -1) and (tArgs.UnitID_GHR ~= -1)) or ((tArgs.UnitID_IA ~= -1) and (tArgs.UnitID_GHR == -1)) then
-- 		-- define local warning message(s)
-- 		local sLocalWarnMsg = "WARNING ValidateGoodyHutReward() UnitID_IA " .. tArgs.UnitID_IA .. " ~= UnitID_GHR " .. tArgs.UnitID_GHR
-- 			.. "; probable misalignment between Events.GoodyHutReward and Events.ImprovementActivated detected; proceeding regardless . . .";
-- 		-- print warning message(s) to the log when debugging
-- 		print(sLocalWarnMsg);
-- 	end
-- 	-- this fires when the local iPlayerID still has the value it was declared with, and indicates a problem
-- 	if (iPlayerID == -2) then
-- 		-- define local error message(s)
-- 		local sPriErrorMsg = "ERROR ValidateGoodyHutReward() PlayerID " .. iPlayerID .. " is invalid; definite misalignment between Events.GoodyHutReward and Events.ImprovementActivated has occurred";
-- 		local sSecErrorMsg = "Resetting argument queue(s) . . .";
-- 		-- print error message(s) to the log when debugging
-- 		print(sPriErrorMsg);
-- 		print(sSecErrorMsg);
-- 		-- reset the argument queue(s)
-- 		GUE.QueueGoodyHutReward = {};
-- 		GUE.QueueImprovementActivated = {};
-- 		-- define function exit message(s)
-- 		local sPriExitMsg = "Turn " .. iTurn .. " | Era " .. iEra .. " | Exit ValidateGoodyHutReward()";
-- 		-- print exit message(s) to the log when debugging, then abort
-- 		Dprint(sPriExitMsg);
-- 		return;
-- 	end
-- 	-- initialize the hostiles as bonus reward and the replacement reward flag(s)
-- 	local bHostilesAsBonusReward, bIsReplacement = false, false;
-- 	-- the hostile modifier of the received reward
-- 	local iThisRewardModifier = GUE.GoodyHutRewards[tArgs.SubTypeHash].HostileModifier;
-- 	-- fetch the type, subtype, and tier of the received reward
-- 	local sRewardType, sRewardSubType, sRewardTier = GUE.GoodyHutTypes[tArgs.TypeHash].GoodyHutType, GUE.GoodyHutRewards[tArgs.SubTypeHash].SubTypeGoodyHut, GUE.GoodyHutRewards[tArgs.SubTypeHash].Tier;
-- 	-- if the received reward is villager secrets, and the Player has already received it the maximum number of times, roll a replacement reward
-- 	if sRewardSubType == GUE.VillagerSecrets and GUE.PlayerData[iPlayerID].VillagerSecretsLevel >= GUE.MaxSecretsLevel then 
-- 		-- debugging output
-- 		Dprint("VillagerSecretsLevel >= MaxSecretsLevel for Player " .. iPlayerID .. "; rolling new reward to replace " .. sRewardSubType .. " . . .");
-- 		-- roll one new reward, and reset the hostile modifier, hostiles as bonus reward flag, reward subtype, and reward tier accordingly
-- 		iThisRewardModifier, bHostilesAsBonusReward, sRewardSubType, sRewardTier = GUE.GetNewRewards(1, iPlayerID, tArgs.PlotX, tArgs.PlotY, sRewardSubType, iTurn, iEra);
-- 		-- set the replacement reward flag
-- 		bIsReplacement = true;
-- 	end
-- 	-- this Player's Civilization type
-- 	local sCivTypeName = GUE.PlayerData[iPlayerID].CivTypeName;
-- 	-- define the log message
-- 	local sPriLogMsg = "Turn " .. iTurn .. " | Era " .. iEra .. " | Player " .. iPlayerID .. " (" .. sCivTypeName .. ") found a " .. sRewardType .. " village ";
-- 	-- great person flag
-- 	local bIsIncreasedHostility = false;
-- 	-- increased hostility unit flag
-- 	local bIsDecreasedHostility = false;
-- 	-- goody hut popped by exploration
-- 	if bIsExplore then
-- 		-- -- table of this Unit's data
-- 		-- local pUnit_IA = Players[tArgs.OwnerID]:GetUnits():FindID(tArgs.UnitID_IA);
-- 		-- if (pUnit_IA == nil) then pUnit_IA = Players[tArgs.ImprovementOwnerID]:GetUnits():FindID(tArgs.UnitID_IA); end
-- 		-- local pUnit_GHR = Players[tArgs.PlayerID]:GetUnits():FindID(tArgs.UnitID_GHR);
-- 		-- -- focused table of this Unit's data
-- 		-- local tUnitData_IA = GameInfo.Units[pUnit_IA:GetType()];
-- 		-- local tUnitData_GHR = GameInfo.Units[pUnit_GHR:GetType()];
-- 		-- -- this Unit's type
-- 		-- local sUnitType_IA = tUnitData_IA.UnitType;
-- 		-- local sUnitType_GHR = tUnitData_GHR.UnitType;
-- 		-- -- this Unit's promotion class
-- 		-- local sUnitPromotionClass_IA = tUnitData_IA.PromotionClass;
-- 		-- local sUnitPromotionClass_GHR = tUnitData_GHR.PromotionClass;
-- 		-- if this Unit is a high-value target, set the increased hostility flag
-- 		if (GUE.HighValueTargets[sUnitType_IA] ~= nil) or (GUE.HighValueTargets[sUnitType_GHR] ~= nil) then
-- 			bIsIncreasedHostility = true;
-- 		-- if this Unit's promotion class is a decreased hostility class, set the decreased hostility unit flag
-- 		elseif (GUE.DecreasedHostilityPromotionClasses[sUnitPromotionClass_IA] ~= nil) or (GUE.DecreasedHostilityPromotionClasses[sUnitPromotionClass_GHR] ~= nil) then
-- 			bIsDecreasedHostility = true;
-- 		end
-- 		-- reflect an exploration reward with unit details in the log message
-- 		sPriLogMsg = sPriLogMsg .. "with a ";
-- 		if (sUnitType_IA == sUnitType_GHR) then sPriLogMsg = sPriLogMsg .. sUnitType_IA;
-- 		elseif (sUnitType_IA ~= sUnitType_GHR) then sPriLogMsg = sPriLogMsg .. sUnitType_IA .. "/" .. sUnitType_GHR;
-- 		end
-- 	-- goody hut popped via expansion
-- 	elseif bIsExpand then
-- 		-- reflect an expansion reward in the log message
-- 		sPriLogMsg = sPriLogMsg .. "via border expansion";
-- 	-- goody hut popped through unknown means
-- 	else
-- 		-- reflect other rewards in the log message
-- 		sPriLogMsg = sPriLogMsg .. "through unknown means";
-- 	end
-- 	-- reflect the goody hut map coordinates in the log message
-- 	sPriLogMsg = sPriLogMsg .. " at plot (x " .. tArgs.PlotX .. ", y " .. tArgs.PlotY .. ")";
-- 	-- pedantry - indicate if this is a replacement reward
-- 	local sReplacement = (bIsReplacement) and " replacement" or "";
-- 	-- define the secondary log message
-- 	local sSecLogMsg = ", and received a";
-- 	-- more (obvious) pedantry
-- 	if (sRewardTier == "Uncommon") then sSecLogMsg = sSecLogMsg .. "n"; end
-- 	-- reflect the received reward and its rarity tier in the secondary log message
-- 	sSecLogMsg = sSecLogMsg .. " " .. sRewardTier .. sReplacement .. " reward of " .. sRewardSubType;
-- 	-- print the log message(s)
-- 	print(sPriLogMsg .. sSecLogMsg);
-- 	-- execute the UnlockVillagerSecrets() enhanced method here if this reward is a valid Villager Secrets reward
-- 	if (sRewardSubType == GUE.VillagerSecrets) then 
-- 		-- this Player has villager secrets left to unlock, so unlock the next level
-- 		if (GUE.PlayerData[iPlayerID].VillagerSecretsLevel < GUE.MaxSecretsLevel) then GUE.UnlockVillagerSecrets(iPlayerID, iTurn, iEra, sRewardSubType);
-- 		-- max villager secrets rewards already received by this Player ** 2021/07/28 this may not ever fire any more
-- 		else
-- 			-- debugging output
-- 			Dprint("VillagerSecretsLevel >= MaxSecretsLevel for Player " .. iPlayerID .. "; rolling new reward to replace " .. sRewardSubType .. " . . .");
-- 			-- roll for one new reward
-- 			iThisRewardModifier, bHostilesAsBonusReward = GUE.GetNewRewards(1, iPlayerID, tArgs.PlotX, tArgs.PlotY, sRewardSubType, iTurn, iEra);
-- 		end
-- 	-- execute the AddAbilityToUnit() enhanced method here if this reward is a unit ability reward
-- 	elseif (GUE.UnitAbilityRewards[sRewardSubType] ~= nil and bIsExplore) then GUE.AddAbilityToUnit(tArgs.PlotX, tArgs.PlotY, GUE.UnitAbilityRewards[sRewardSubType]);
-- 	-- execute the CreateHostileVillagers() enhanced method here if this reward is a valid Hostile Villagers "reward"
-- 	elseif (GUE.HostileVillagers[sRewardSubType] ~= nil) then GUE.CreateHostileVillagers(tArgs.PlotX, tArgs.PlotY, iPlayerID, iTurn, iEra, sRewardSubType);
-- 	end
-- 	-- initialize the hostile modifier for bonus reward(s)
-- 	local iBonusRewardModifier = 0;
-- 	-- roll for any bonus rewards and store the cumulative hostile modifier sum and status of the hostiles as bonus reward flag
-- 	if not bHostilesAsBonusReward then iBonusRewardModifier, bHostilesAsBonusReward = GUE.GetNewRewards(GUE.BonusRewardsPerGoodyHut, iPlayerID, tArgs.PlotX, tArgs.PlotY, sRewardSubType, iTurn, iEra); end
-- 	-- the difficulty modifier remains constant throughout the game
-- 	local iDifficultyModifier = GUE.PlayerData[iPlayerID].Difficulty;
-- 	-- hostile villagers will appear when the calculated hostiles chance below equals or exceeds this value
-- 	local iSpawnThreshold = 100;
-- 	-- roll for hostile villagers AFTER other enhanced method(s) here, IF hostiles after rewards are enabled AND this reward is NOT one of the guaranteed hostiles "rewards" AND hostiles were NOT a bonus reward
-- 	if (GUE.HostilesAfterReward > 1) and (GUE.HostileVillagers[sRewardSubType] == nil) and not (bHostilesAsBonusReward) then
-- 		-- determine villager hostility level
-- 		local sHostilityLevel = GUE.DetermineVillagerHostility(bIsExpand, bIsIncreasedHostility, bIsDecreasedHostility, iDifficultyModifier, iThisRewardModifier, iBonusRewardModifier, iEra, iSpawnThreshold);
-- 		-- spawn hostiles if the villagers are pissed enough
-- 		if (GUE.HostileVillagers[sHostilityLevel] ~= nil) then GUE.CreateHostileVillagers(tArgs.PlotX, tArgs.PlotY, iPlayerID, iTurn, iEra, sHostilityLevel); end
-- 	end
-- 	-- define function exit message(s)
-- 	local sPriExitMsg = "Turn " .. iTurn .. " | Era " .. iEra .. " | Exit ValidateGoodyHutReward()";
-- 	-- print exit message(s) to the log when debugging
-- 	Dprint(sPriExitMsg);
-- end
