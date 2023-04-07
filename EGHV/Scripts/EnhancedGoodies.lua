--[[ =========================================================================
	EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (C) 2020-2023 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin EnhancedGoodies.lua gameplay script
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
-- make DebugPrint() more conveniently globally accessible, as otherwise this declaration must be made in a local scope within each function below
Dprint = GUE.DebugPrint;
-- table of notification-related data for various reward types
GUE.Notification = GUE.Notification and GUE.Notification or {};
-- define Villager Secrets notification parameters
GUE.Notification.Secrets = {
	Title = Locale.Lookup("LOC_VILLAGER_SECRETS_NOTIFICATION_TITLE"),
	TypeHash = NotificationTypes.USER_DEFINED_2,
	Message = Locale.Lookup("LOC_VILLAGER_SECRETS_NOTIFICATION_MESSAGE")
};
-- table of individual unit rewards
GUE.GrantUnitRewards = {
	["GOODYHUT_GRANT_SCOUT"] = 1, ["GOODYHUT_GRANT_WARRIOR"] = 2, ["GOODYHUT_GRANT_SLINGER"] = 3, ["GOODYHUT_GRANT_SPEARMAN"] = 4, ["GOODYHUT_GRANT_HEAVY_CHARIOT"] = 5, ["GOODYHUT_GRANT_HORSEMAN"] = 6, 
	["GOODYHUT_GRANT_CATAPULT"] = 7, ["GOODYHUT_GRANT_BATTERING_RAM"] = 8, ["GOODYHUT_GRANT_MILITARY_ENGINEER"] = 9, ["GOODYHUT_GRANT_BUILDER"] = 10, ["GOODYHUT_GRANT_SETTLER"] = 11
};
-- define valid Villager Secrets reward(s) - these are the SubTypeGoodyHut values for any such rewards
GUE.VillagerSecrets = "GOODYHUT_UNLOCK_VILLAGER_SECRETS";
GUE.VillagerSecretsRewards = { 
	["GOODYHUT_VILLAGER_SECRETS_AMENITIES"] = { ModifierID = "VILLAGER_SECRETS_UNLOCK_AMENITIES_TOTEM", Building = GameInfo.Buildings["BUILDING_AMENITIES_TOTEM"].Index }, 
	["GOODYHUT_VILLAGER_SECRETS_CULTURE"] = { ModifierID = "VILLAGER_SECRETS_UNLOCK_CULTURE_TOTEM", Building = GameInfo.Buildings["BUILDING_CULTURE_TOTEM"].Index }, 
	["GOODYHUT_VILLAGER_SECRETS_FAITH"] = { ModifierID = "VILLAGER_SECRETS_UNLOCK_FAITH_TOTEM", Building = GameInfo.Buildings["BUILDING_FAITH_TOTEM"].Index }, 
	["GOODYHUT_VILLAGER_SECRETS_FOOD"] = { ModifierID = "VILLAGER_SECRETS_UNLOCK_FOOD_TOTEM", Building = GameInfo.Buildings["BUILDING_FOOD_TOTEM"].Index }, 
	["GOODYHUT_VILLAGER_SECRETS_GOLD"] = { ModifierID = "VILLAGER_SECRETS_UNLOCK_GOLD_TOTEM", Building = GameInfo.Buildings["BUILDING_GOLD_TOTEM"].Index }, 
	["GOODYHUT_VILLAGER_SECRETS_PRODUCTION"] = { ModifierID = "VILLAGER_SECRETS_UNLOCK_PRODUCTION_TOTEM", Building = GameInfo.Buildings["BUILDING_PRODUCTION_TOTEM"].Index }, 
	["GOODYHUT_VILLAGER_SECRETS_SCIENCE"] = { ModifierID = "VILLAGER_SECRETS_UNLOCK_SCIENCE_TOTEM", Building = GameInfo.Buildings["BUILDING_SCIENCE_TOTEM"].Index } 
};
if GUE.Ruleset == "RULESET_EXPANSION_2" then 
	GUE.VillagerSecretsRewards["GOODYHUT_VILLAGER_SECRETS_FAVOR"] = { ModifierID = "VILLAGER_SECRETS_UNLOCK_FAVOR_TOTEM", Building = GameInfo.Buildings["BUILDING_FAVOR_TOTEM"].Index }; 
end
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
-- unit ability rewards; key = goody hut subtype, value = associated ability
GUE.UnitAbilityRewards = { 
	["GOODYHUT_IMPROVED_HEALING"] = "ABILITY_IMPROVED_HEALING",
	["GOODYHUT_IMPROVED_MOVEMENT"] = "ABILITY_IMPROVED_MOVEMENT",
	["GOODYHUT_IMPROVED_SIGHT"] = "ABILITY_IMPROVED_SIGHT",
	["GOODYHUT_IMPROVED_STRENGTH"] = "ABILITY_IMPROVED_STRENGTH"
};
-- unit combat experience rewards; key = goody hut subtype, value = amount of XP to award
GUE.UnitXPRewards = { ["GOODYHUT_SMALL_EXPERIENCE"] = 5, ["GOODYHUT_MEDIUM_EXPERIENCE"] = 10, ["GOODYHUT_LARGE_EXPERIENCE"] = 15, ["GOODYHUT_HUGE_EXPERIENCE"] = 25 };
-- this table facilitates unit promotions via goody hut reward
GUE.PromotionsByClass = {};
for row in GameInfo.UnitPromotionClasses() do GUE.PromotionsByClass[row.PromotionClassType] = {}; end
for row in GameInfo.UnitPromotions() do table.insert(GUE.PromotionsByClass[row.PromotionClass], row.UnitPromotionType); end
-- this table facilitates unit promotions via goody hut reward
GUE.UnitUpgrades = {};
for row in GameInfo.UnitUpgrades() do GUE.UnitUpgrades[row.Unit] = row.UpgradeUnit; end

--[[ =========================================================================
	exposed member function GetGoodyHutPlots()
	does exactly what it says on the tin: gets all plots containing goody huts at init
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
function GUE.GetGoodyHutPlots()
	-- initialize the results table
	local tResults = {};
	-- identify the continent(s) in the current game session
	local tContinentsInUse = Map.GetContinentsInUse();
	-- iterate over the identified continents
	for j, k in ipairs(tContinentsInUse) do
		-- identify the plots in this continent
		local tContinentPlots = Map.GetContinentPlots(k);
		-- iterate over this continent's plots
		for i, v in ipairs(tContinentPlots) do
			-- the current plot
			local tPlot = Map.GetPlotByIndex(v);
			-- get the index of any improvement that exists on this plot
			local iImprovementIndex = (tPlot:GetImprovementType() ~= -1) and tPlot:GetImprovementType() or nil;
			-- the ImprovementType of the improvement that exists on this plot, if any
			local sImprovement = iImprovementIndex and GameInfo.Improvements[iImprovementIndex].ImprovementType or nil;
			-- add the current plot to the results table if it has a goody hut
			if sImprovement == "IMPROVEMENT_GOODY_HUT" then table.insert(tResults, tPlot); end
		end
	end
	-- return the results table and exit here
	return tResults;
end

--[[ =========================================================================
	exposed member function AddUnitToMap( iX, iY, iPlayerID, iTurn, iEra, sRewardSubType )
	spawns units belonging to iPlayerID near the plot at (x iX, y iY)
	ingame notifications sent to iPlayerID
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
-- function GUE.AddUnitToMap( iX, iY, iPlayerID, iTurn, iEra, sRewardSubType )
function GUE.AddUnitToMap( iPlayerID, iUnitID, iTypeHash, iSubTypeHash, sRewardSubType, iX, iY, iTurn, iEra, tUnits, iXP, sAbilityType, sModifierID, bIsPermanent )
	-- abort here if sRewardSubType is not a valid grant unit reward
	if GUE.GrantUnitRewards[sRewardSubType] == nil then return; end
	-- fetch the value assigned to this key in the unit rewards table
	local iUnitGrant = GUE.GrantUnitRewards[sRewardSubType];
	-- initialize the unit to place, defaulting to an empty string; if this doesn't change, there's a problem
	local sUnitGrant = "";
	-- verify the actual unit to place
	if iUnitGrant == 1 then sUnitGrant = GameInfo.UnitRewards[iEra].Recon;
	elseif iUnitGrant == 2 then sUnitGrant = GameInfo.UnitRewards[iEra].Melee;
	elseif iUnitGrant == 3 then sUnitGrant = GameInfo.UnitRewards[iEra].Ranged;
	elseif iUnitGrant == 4 then sUnitGrant = GameInfo.UnitRewards[iEra].AntiCavalry;
	elseif iUnitGrant == 5 then sUnitGrant = GameInfo.UnitRewards[iEra].HeavyCavalry;
	elseif iUnitGrant == 6 then sUnitGrant = GameInfo.UnitRewards[iEra].LightCavalry;
	elseif iUnitGrant == 7 then sUnitGrant = GameInfo.UnitRewards[iEra].Siege;
	elseif iUnitGrant == 8 then sUnitGrant = GameInfo.UnitRewards[iEra].Support;
	elseif iUnitGrant == 9 then sUnitGrant = "UNIT_MILITARY_ENGINEER";
	elseif iUnitGrant == 10 then sUnitGrant = "UNIT_BUILDER";
	elseif iUnitGrant == 11 then sUnitGrant = "UNIT_SETTLER";
	end
	-- place the identified unit
	UnitManager.InitUnitValidAdjacentHex(iPlayerID, sUnitGrant, iX, iY, 1);
	-- debugging log output
	print("Successfully placed a new " .. sUnitGrant .. " under the control of Player " .. iPlayerID .. " near plot (x " .. iX .. ", y " .. iY .. ")");
end

--[[ =========================================================================
	exposed member function AddXPToUnit( iX, iY, tUnits, iXP )
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
-- function GUE.AddXPToUnit( iX, iY, tUnits, iXP )
function GUE.AddXPToUnit( iPlayerID, iUnitID, iTypeHash, iSubTypeHash, sRewardSubType, iX, iY, iTurn, iEra, tUnits, iXP, sAbilityType, sModifierID, bIsPermanent )
	-- abort here if the supplied units table is nil
	if tUnits == nil then return; end
	-- iterate over the supplied units table
	for k, v in pairs(tUnits) do
		-- this unit's type and promotion class
		local sUnitType, sPromotionClass = v.UnitType, v.PromotionClass;
		-- data for this unit
		local pUnit = v.Table;
		-- shortcut to this unit's GetExperience() method
		local pUnitExperience = pUnit:GetExperience();
		-- true when this unit can earn experience
		if pUnitExperience ~= nil then
			-- add iXP experience to this unit
			pUnitExperience:ChangeExperience(iXP);
			-- debugging log output
			print("A " .. sUnitType .. " near plot (x " .. iX .. ", y " .. iY .. ") has received " .. iXP .. " experience points towards its next promotion");
		-- this unit can 'NOT' earn experience
		else
			-- debugging log output
			print("Combat experience is not a valid award for a " .. sUnitType .. " near plot (x " .. iX .. ", y " .. iY .. "); skipping this unit");
		end
	end
end

--[[ =========================================================================
	exposed member function AddAbilityToUnit( iX, iY, tUnits, sAbilityType )
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
-- function GUE.AddAbilityToUnit( iX, iY, tUnits, sAbilityType )
function GUE.AddAbilityToUnit( iPlayerID, iUnitID, iTypeHash, iSubTypeHash, sRewardSubType, iX, iY, iTurn, iEra, tUnits, iXP, sAbilityType, sModifierID, bIsPermanent )
	-- proceed if any unit(s) were found
	if tUnits ~= nil then
		-- iterate over all unit(s) in the passed table
		for k, v in pairs(tUnits) do
			-- this unit's type and promotion class
			local sUnitType, sPromotionClass = v.UnitType, v.PromotionClass;
			-- data for this unit
			local pUnit = v.Table;
			-- shortcut to this unit's GetAbility() method
			local pUnitAbility = pUnit:GetAbility();
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
						print("Military Unit Ability " .. sAbilityType .. " successfully attached to a " .. sUnitType .. " at plot (x " .. iX .. ", y " .. iY .. ")");
					-- this unit is NOT a valid combat unit; do nothing
					else
						-- debugging log output
						print("Military Unit Ability " .. sAbilityType .. " is not valid for a " .. sUnitType .. " at plot (x " .. iX .. ", y " .. iY .. "); skipping unit");
					end
				-- these abilities can be attached to any unit
				elseif (sAbilityType == "ABILITY_IMPROVED_SIGHT" or sAbilityType == "ABILITY_IMPROVED_MOVEMENT") then
					-- attach sAbilityType to this unit
					pUnitAbility:ChangeAbilityCount(sAbilityType, 1);
					-- debugging log output
					print("Unit Ability " .. sAbilityType .. " successfully attached to a " .. sUnitType .. " at plot (x " .. iX .. ", y " .. iY .. ")");
				end
			-- do not attach sAbilityType to this unit more than once
			else
				-- debugging log output
				print("Unit Ability " .. sAbilityType .. " was previously attached to a " .. sUnitType .. " at plot (x " .. iX .. ", y " .. iY .. "); skipping unit");
			end
		end
	end
end

--[[ =========================================================================
	exposed member function UpgradeUnit( iPlayerID, iX, iY, tUnits )
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
-- function GUE.UpgradeUnit( iPlayerID, iX, iY, tUnits )
function GUE.UpgradeUnit( iPlayerID, iUnitID, iTypeHash, iSubTypeHash, sRewardSubType, iX, iY, iTurn, iEra, tUnits, iXP, sAbilityType, sModifierID, bIsPermanent )
	-- abort here if the supplied Units table is nil
	if tUnits == nil then return; end
	-- initialize the results table and the new units tracker
	local tNewUnits, iNumNewUnits = {}, 0;
	-- iterate over the supplied units table
	for k, v in pairs(tUnits) do
		-- this unit's type and promotion class
		local sUnitType, sPromotionClass = v.UnitType, v.PromotionClass;
		-- true when this unit's type is a key in the unit upgrades table
		if GUE.UnitUpgrades[sUnitType] ~= nil then
			-- internal data for this unit
			local pUnit = v.Table;
			-- fetch the current (x, y) map coordinates of this unit
			local jX, jY = pUnit:GetX(), pUnit:GetY();
			-- shortcut to this unit's GetAbility() and GetExperience() methods
			local pUnitAbility, pUnitExperience = pUnit:GetAbility(), pUnit:GetExperience();
			-- initialize tables for this unit's abilities and promotions, and initialize the level tracker for this unit to 1
			local tAbilities, tPromotions, iLevel = {}, {}, 1;
			-- initialize the level table
			local tLevel = { 
				{ Min = 0, Max = 15 }, { Min = 15, Max = 45 }, { Min = 45, Max = 90 }, { Min = 90, Max = 150 }, 
				{ Min = 150, Max = 225 }, { Min = 225, Max = 315 }, { Min = 315, Max = 420 }, { Min = 420, Max = 540 }
			 };
			-- iterate over the unit ability rewards table to identify any abilities attached to this unit
			for k, v in pairs(GUE.UnitAbilityRewards) do tAbilities[v] = (pUnitAbility:GetAbilityCount(v) > 0) and true or false; end
			-- iterate over the promotions by class table to identify any promotions earned by this unit
			for i, v in ipairs(GUE.PromotionsByClass[sPromotionClass]) do 
				-- fetch the status of this promotion
				tPromotions[v] = pUnitExperience:HasPromotion(GameInfo.UnitPromotions[v].Index); 
				-- increment this unit's level tracker when this is true
				if (tPromotions[v] == true) then iLevel = iLevel + 1; end
			end
			-- flag for whether this unit has any promotions
			local bHasPromotions = (iLevel > 1) and true or false;
			-- fetch this unit's (1) minimum accrued combat experience, (2) total experience required for its next level, and (3) its veteran name, if any
			local iMinXP, iXPFNL, sVeteranName = tLevel[iLevel].Min, pUnitExperience:GetExperienceForNextLevel(), pUnitExperience:GetVeteranName();
			-- calculate the range for any potential bonus experience
			local iRangeXP = iXPFNL - iMinXP;
			-- get a random amount of combat experience to compensate for any potential lost XP; this should cap at ~ half the amount needed for the next promotion
			local iBonusXP = math.floor((TerrainBuilder.GetRandomNumber(iRangeXP, "Unit upgrade : compensation experience") / 2) + 1);
			-- initialize primary debugging message
			local sPriDebugMsg = "A ";
			-- adjust primary debugging message for unit veteran name, if applicable
			if (sVeteranName ~= nil and sVeteranName ~= "") then sPriDebugMsg = sPriDebugMsg .. "veteran "; end
			-- adjust primary debugging message to include map plot coordinates
			sPriDebugMsg = sPriDebugMsg .. sUnitType .. " at plot (x " .. iX .. ", y " .. iY .. ") ";
			-- adjust primary debugging message for no or invalid unit promotion class
			if GUE.PromotionsByClass[sPromotionClass] == nil then sPriDebugMsg = sPriDebugMsg .. "is 'NOT' eligible for promotion,";
			-- adjust primary debugging message for current unit promotion level
			else sPriDebugMsg = sPriDebugMsg .. "is Level " .. iLevel .. " with at least " .. iMinXP .. "/" .. iXPFNL .. " experience points,";
			end
			-- adjust primary debugging message for direct unit promotion path
			sPriDebugMsg = sPriDebugMsg .. " and has a valid upgrade path to " .. GUE.UnitUpgrades[sUnitType];
			-- initialize secondary debugging message
			local sSecDebugMsg = "Current promotions: ";
			-- adjust secondary debugging message for valid promotions for this unit
			for k, v in pairs(tPromotions) do sSecDebugMsg = sSecDebugMsg .. k .. " = " .. tostring(v) .. " "; end
			-- initialize tertiary debugging message
			local sTerDebugMsg = "Current abilities: ";
			-- adjust tertiary debugging message for valid abilities for this unit
			for k, v in pairs(tAbilities) do sTerDebugMsg = sTerDebugMsg .. k .. " = " .. tostring(v) .. " "; end
			-- debugging output
			Dprint(sPriDebugMsg);
			if GUE.PromotionsByClass[sPromotionClass] ~= nil then Dprint(sSecDebugMsg); end
			Dprint(sTerDebugMsg);
			-- true when this unit has not yet earned any promotions
			if not bHasPromotions then 
				-- debugging output
				local sQuadDebugMsg = "A " .. sUnitType .. " has NOT previously been promoted; 'upgrading' this unit to a " .. GUE.UnitUpgrades[sUnitType];
				-- "upgrade" this unit by (1) destroying this unit, and then (2) creating a new unit which this unit would upgrade to
				UnitManager.Kill(pUnit);
				UnitManager.InitUnit(iPlayerID, GUE.UnitUpgrades[sUnitType], jX, jY, 1);
				print(sQuadDebugMsg .. ", reapplying any earned abilities, and adding sufficient experience for its first promotion");
				-- iterate over all unit(s) found in this Plot
				for i, pUnit in ipairs(Units.GetUnitsInPlotLayerID(jX, jY, MapLayers.ANY)) do
					-- fetch this unit's ID and OwnerID
					local iThisUnitID, iThisUnitOwnerID = pUnit:GetID(), pUnit:GetOwner();
					-- make sure this unit belongs to this Player
					if iThisUnitOwnerID == iPlayerID then
						-- data for this unit
						local pUnitData = GameInfo.Units[pUnit:GetType()];
						-- true when this unit is the "upgraded" unit
						if pUnitData.UnitType == GUE.UnitUpgrades[sUnitType] then
							-- store the entire unit table for and select details about this unit in the results table, keyed to its ID
							tNewUnits[iThisUnitID] = { Table = pUnit, UnitType = pUnitData.UnitType, PromotionClass = pUnitData.PromotionClass };
							-- increment the units in plot tracker
							iNumNewUnits = iNumNewUnits + 1;
							-- shortcuts to this unit's GetExperience() and GetAbility() methods
							local pUnitExperience, pUnitAbility = pUnit:GetExperience(), pUnit:GetAbility();
							-- iterate over the existing abilities table for this new unit
							for k, v in pairs(tAbilities) do 
								-- true when the old unit had this ability
								if (v == true) then 
									-- initialize local debugging message
									local sPriInfoMsg = "Reapplying ability " .. k .. " . . . ";
									-- apply this ability to this new unit
									pUnitAbility:ChangeAbilityCount(k, 1);
									-- local debugging output
									Dprint(sPriInfoMsg .. "PASS!");
								end
							end
							-- remove this new unit's moves for this turn
							local sSecInfoMsg = "Adjusting 'upgraded' unit movement . . . ";
							UnitManager.FinishMoves(pUnit);
							Dprint(sSecInfoMsg .. "PASS!");
							-- grant huge experience reward to this unit
							local sPriInfoMsg = "Adding enough experience to this unit for its first promotion (" .. iXPFNL .. " XP) . . . ";
							pUnitExperience:ChangeExperience(iXPFNL);
							Dprint(sPriInfoMsg .. "PASS!");
						end
					end 
				end
			-- true when this unit has earned at least one promotion
			else 
				-- debugging output
				print("A " .. sUnitType .. " has previously been promoted; skipping 'upgrade' for this unit and adding sufficient experience for its next promotion");
				-- grant huge experience reward to this unit
				local sPriInfoMsg = "Adding enough experience to this unit for its next promotion (" .. iXPFNL .. " XP) . . . ";
				pUnitExperience:ChangeExperience(iXPFNL);
				Dprint(sPriInfoMsg .. "PASS!");
				-- store the entire unit table for and select details about this unit in the results table, keyed to its ID
				tNewUnits[k] = v;
			end
		-- true when this unit's type is NOT a key in the unit upgrades table
		else
			-- debugging output
			print("A " .. sUnitType .. " is not a valid target for this reward; skipping this unit");
			-- store the entire unit table for and select details about this unit in the results table, keyed to its ID
			tNewUnits[k] = v;
		end
	end
	-- return the results table
	return tNewUnits;
end

--[[ =========================================================================
	exposed member function GetPlayerCities()
	
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
function GUE.GetPlayerCities( pPlayer )
	-- initialize the results table
	local t = {};
	-- add this Player's City objects to and return the results table
	for _, pCity in pPlayer:GetCities():Members() do table.insert(t, pCity); end
	return t;
end

--[[ =========================================================================
	exposed member function AddPopulationToCity()
	
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
-- function GUE.AddPopulationToCity( iPlayerID, iTurn, iEra )
function GUE.AddPopulationToCity( iPlayerID, iUnitID, iTypeHash, iSubTypeHash, sRewardSubType, iX, iY, iTurn, iEra, tUnits, iXP, sAbilityType, sModifierID, bIsPermanent )
	-- Dprint(string.format("Turn %d | Era %d | Enter AddPopulationToCity( iPlayerID = %d, iTurn = %d, iEra = %d )", iTurn, iEra, iPlayerID, iTurn, iEra));
	-- fetch the Player object for Player iPlayerID
	local pPlayer = Players[iPlayerID];
	-- proceed here if the pPlayer object for iPlayerID represents a valid Player
	if (pPlayer ~= nil) then 
		-- initialize the new population amount and fetch this Player's City objects
		local iNewPop, tCities = 1, GUE.GetPlayerCities(pPlayer);
		-- pick a random City from the table of City objects and increase its population
		if #tCities > 0 then 
			local iCity = (#tCities > 1) and TerrainBuilder.GetRandomNumber(#tCities, "Random city roll") + 1 or 1;
			local pCity = tCities[iCity];
			pCity:ChangePopulation(iNewPop);
			print(string.format("The population of Player %d's City of %s (ID %d) has increased by %d", iPlayerID, Locale.Lookup(pCity:GetName()), pCity:GetID(), iNewPop));
		end
	-- do nothing if iPlayerID represents an invalid Player
	else 
		Dprint(string.format("'FAILED' to fetch player data for Player %d; doing nothing", iPlayerID));
	end
	-- Dprint(string.format("Turn %d | Era %d | Exit AddPopulationToCity()", iTurn, iEra));
end

--[[ =========================================================================
	exposed member function UnlockVillagerSecrets()
	unlocks the ability to construct the Tribal Totem building for Player with ID iPlayerID
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
-- function GUE.UnlockVillagerSecrets( iPlayerID, iTurn, iEra, sRewardSubType )
function GUE.UnlockVillagerSecrets( iPlayerID, iUnitID, iTypeHash, iSubTypeHash, sRewardSubType, iX, iY, iTurn, iEra, tUnits, iXP, sAbilityType, sModifierID, bIsPermanent )
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
		-- 
		if (PlayerProperty == nil) or (PlayerProperty == 0) then 
			-- log output
			print("The " .. sRewardSubType .. " Villager Secrets reward has 'NOT' previously been granted to Player " .. iPlayerID .. "; unlocking villager secrets for this player . . .");
			-- set an ingame Property for this Player to track future Villager Secrets reward(s)
			pPlayer:SetProperty(sRewardSubType, 1);
			Players[iPlayerID]:SetProperty("VillagerSecretsLevel", 1);
			-- unlock the tribal totem building
			GUE.AddModifierToPlayer(iPlayerID, iUnitID, iTypeHash, iSubTypeHash, sRewardSubType, iX, iY, iTurn, iEra, tUnits, iXP, sAbilityType, GUE.VillagerSecretsRewards[sRewardSubType].ModifierID, true);
			-- if sRewardSubType == "GOODYHUT_VILLAGER_SECRETS_FAVOR" then GUE.AddModifierToPlayer(iPlayerID, "BUILDING_FAVOR_TOTEM_FAVOR_MODIFIER", true); end
			-- send an ingame notification for each unlocked secret
			if Players[iPlayerID]:IsHuman() then NotificationManager.SendNotification(iPlayerID, GUE.Notification.Secrets.TypeHash, GUE.Notification.Secrets.Title, GUE.Notification.Secrets.Message); end
		-- this should fire any time after the first time this Player receives the Villager Secrets reward, until all defined secrets are unlocked
		elseif (PlayerProperty > 0) then 
			-- log output
			local sPriLogMsg = "The " .. sRewardSubType .. " Villager Secrets reward has previously been granted to Player " .. iPlayerID;
			-- 
			local tCities = {};
			for i, pCity in pPlayer:GetCities():Members() do 
				table.insert(tCities, pCity);
			end
			-- 
			local bValidCityFound = false;
			if #tCities > 0 then 
				for i, pCity in ipairs(tCities) do 
					if not bValidCityFound then 
						if not pCity:GetBuildings():HasBuilding(GUE.VillagerSecretsRewards[sRewardSubType].Building) then 
							local pPlot = Map.GetPlot(pCity:GetX(), pCity:GetY());
							local pQueue = pCity:GetBuildQueue();
							pQueue:CreateIncompleteBuilding(GUE.VillagerSecretsRewards[sRewardSubType].Building, pPlot:GetIndex(), 100);
							bValidCityFound = true;
						end
					end
				end
			end
			local sSecLogMsg = bValidCityFound and "; placing a free totem building in a 'random' City . . ." or ", and this Player has no valid City in which to place a totem building; skipping this reward . . .";
			print(sPriLogMsg .. sSecLogMsg);
			-- send an ingame notification for each unlocked secret
			if Players[iPlayerID]:IsHuman() then NotificationManager.SendNotification(iPlayerID, GUE.Notification.Secrets.TypeHash, GUE.Notification.Secrets.Title, GUE.Notification.Secrets.Message); end
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
	-- 
	local iPlayerID = (tGoodyHutReward.PlayerID > -1 and tImprovementActivated.OwnerID > -1 and tGoodyHutReward.PlayerID == tImprovementActivated.OwnerID) and tImprovementActivated.OwnerID or tImprovementActivated.ImprovementOwnerID; 
	-- fetch values from the passed ImprovementActivated table
	-- local iX, iY, iPlayerID, iUnitID = tImprovementActivated.X, tImprovementActivated.Y, tImprovementActivated.PlayerID, tImprovementActivated.UnitID;
	local iX, iY, iUnitID = tImprovementActivated.X, tImprovementActivated.Y, tImprovementActivated.UnitID;
	-- more values from the passed ImprovementActivated table
	local bIsExpand, bIsExplore, bIsBarbCamp, bIsGoodyHut, bIsSumeria = tImprovementActivated.IsExpand, tImprovementActivated.IsExplore, tImprovementActivated.IsBarbCamp, tImprovementActivated.IsGoodyHut, tImprovementActivated.IsSumeria;
	-- fetch values from the passed GoodyHutReward table
	local iTypeHash, iSubTypeHash = tGoodyHutReward.TypeHash, tGoodyHutReward.SubTypeHash;
	-- identify the current global or player Era
	local iEra, iTurn = (GUE.Ruleset == "RULESET_STANDARD") and Players[iPlayerID]:GetEras():GetEra() or Game.GetEras():GetCurrentEra(), Game.GetCurrentGameTurn();
	-- define function entry messages
	local sPriEntryMsg = "ENTER ValidateGoodyHutReward(iTurn " .. iTurn .. ", iEra " .. iEra .. ", iX " .. iX .. ", iY " .. iY 
		.. ", iPlayerID " .. iPlayerID .. ", iUnitID " .. iUnitID .. ", bIsExpand " .. tostring(bIsExpand) .. ", bIsExplore " .. tostring(bIsExplore) 
		.. ", bIsBarbCamp " .. tostring(bIsBarbCamp) .. ", bIsGoodyHut " .. tostring(bIsGoodyHut) .. ", bIsSumeria " .. tostring(bIsSumeria) 
		.. ", iTypeHash " .. iTypeHash .. ", iSubTypeHash " .. iSubTypeHash .. ")";
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
				tUnitsInPlot[iThisUnitID] = { 
					Table = pUnit, 
					UnitType = (pUnitData.UnitType ~= nil) and pUnitData.UnitType or "unknown unit type", 
					PromotionClass = (pUnitData.PromotionClass ~= nil) and pUnitData.PromotionClass or "unknown promotion class" 
				};
				-- increment the units in plot tracker
				iNumUnitsInPlot = iNumUnitsInPlot + 1;
			end 
		end 
	end
	-- initialize the hostiles as bonus reward and the replacement reward flag(s)
	local bHostilesAsBonusReward, bIsReplacement = false, false;
	-- fetch the type, subtype, hostile modifier, and tier of the received reward
	local sRewardType, sRewardSubType = GameInfo.GoodyHutsByHash[iTypeHash].GoodyHutType, GameInfo.GoodyHutSubTypesByHash[iSubTypeHash].SubTypeGoodyHut;
	local iThisRewardModifier, sRewardTier, sPriReplacementMsg = GameInfo.GoodyHutSubTypes[sRewardSubType].HostileModifier, GameInfo.GoodyHutSubTypes[sRewardSubType].Tier, "";
	-- determine if this reward should be replaced
	-- local bRequiresReplacement = ((sRewardSubType == GUE.VillagerSecrets and GUE.PlayerData[iPlayerID].VillagerSecretsLevel >= GUE.MaxSecretsLevel) or (GUE.WGH_Rewards[sRewardSubType] ~= nil and iUnitID == -1)) and true or false;
	local bRequiresReplacement = ((sRewardSubType == GUE.VillagerSecrets and Players[iPlayerID]:GetProperty("VillagerSecretsLevel") >= GUE.MaxSecretsLevel) or (GUE.WGH_Rewards[sRewardSubType] ~= nil and iUnitID == -1)) and true or false;
	
	-- this Player's Civilization type
	local sCivTypeName = PlayerConfigurations[iPlayerID]:GetCivilizationTypeName();
	-- the UnitType of iUnitID, if valid
	local sUnitType = (iNumUnitsInPlot > 0 and tUnitsInPlot[iUnitID]) and tUnitsInPlot[iUnitID].UnitType or nil;
	-- the PromotionClass of iUnitID, if valid
	local sPromotionClass = (iNumUnitsInPlot > 0 and tUnitsInPlot[iUnitID]) and tUnitsInPlot[iUnitID].PromotionClass or nil;
	-- define the log message
	local sPriLogMsg = "Turn " .. iTurn .. " | Era " .. iEra .. " | Player " .. iPlayerID .. " (" .. sCivTypeName .. ") ";
	if bIsBarbCamp then sPriLogMsg = sPriLogMsg .. "dispersed a " .. sRewardType .. " barbarian camp "
	elseif bIsGoodyHut then sPriLogMsg = sPriLogMsg ..  "discovered a " .. sRewardType .. " tribal village "
	end
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
		sPriLogMsg = sPriLogMsg .. "with an ";
		sPriLogMsg = (sUnitType == nil) and sPriLogMsg .. "unknown unit type" or sPriLogMsg .. sUnitType;
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
	-- local sReplacement = (bIsReplacement) and " replacement" or "";
	-- define the secondary log message
	local sSecLogMsg = ", and received a";
	-- more (obvious) pedantry
	if (sRewardTier == "Uncommon") then sSecLogMsg = sSecLogMsg .. "n"; end
	-- reflect the received reward and its rarity tier in the secondary log message
	sSecLogMsg = sSecLogMsg .. " " .. tostring(sRewardTier) .. " reward of " .. tostring(sRewardSubType);
	-- print the log message(s)
	print(sPriLogMsg .. sSecLogMsg);
	-- if the received reward is villager secrets, and the Player has already received it the maximum number of times, roll a replacement reward
	if bRequiresReplacement then 
		-- properly define the replacement reward message for the log
		if sRewardSubType == GUE.VillagerSecrets and Players[iPlayerID]:GetProperty("VillagerSecretsLevel") >= GUE.MaxSecretsLevel then 
			sPriReplacementMsg = string.format("VillagerSecretsLevel >= MaxSecretsLevel for Player %d", iPlayerID);
		elseif GUE.WGH_Rewards[sRewardSubType] ~= nil and iUnitID == -1 then 
			sPriReplacementMsg = string.format("Rewards of type %s are invalid when obtained via border expansion", sRewardType);
		end
		-- log output
		print(string.format("%s; rolling new reward to replace %s . . .", sPriReplacementMsg, sRewardSubType));
		-- set the replacement reward flag
		-- bIsReplacement = true;
		-- roll one new reward, and reset the hostile modifier, hostiles as bonus reward flag, reward subtype, and reward tier accordingly
		iThisRewardModifier, bHostilesAsBonusReward, sRewardSubType, sRewardTier = GUE.GetNewRewards(1, iPlayerID, iUnitID, iX, iY, sRewardSubType, iTurn, iEra, tUnitsInPlot, true);
		-- reset the requires replacement flag
		bRequiresReplacement = false;
	end
	-- 
	-- local tArgs = { 
	-- 	PlayerID = iPlayerID, X = iX, Y = iY, UnitID = iUnitID, UnitsInPlot = tUnitsInPlot, Turn = iTurn, Era = iEra, HostileModifier = iThisRewardModifier, Tier = sRewardTier, 
	-- 	TypeHash = iTypeHash, RewardType = sRewardType, SubtypeHash = iSubTypeHash, RewardSubtype = sRewardSubType, ModifierID = GameInfo.GoodyHutSubTypes[sRewardSubType].ModifierID, 
	-- 	Ability = GUE.UnitAbilityRewards[sRewardSubType] and GUE.UnitAbilityRewards[sRewardSubType] or nil, 
	-- 	XP = GUE.UnitXPRewards[sRewardSubType] and GUE.UnitXPRewards[sRewardSubType] or nil 
	-- };
	local sModifierID = GameInfo.GoodyHutSubTypes[sRewardSubType].ModifierID;
	local iXP = GUE.UnitXPRewards[sRewardSubType] and GUE.UnitXPRewards[sRewardSubType] or nil;
	local sAbility = GUE.UnitAbilityRewards[sRewardSubType] and GUE.UnitAbilityRewards[sRewardSubType] or nil;
	if (sModifierID == "GOODY_EGHV_DUMMY_REWARD") then 
		Dprint(string.format("Primary reward %s will be applied by EGHV . . .", sRewardSubType));
		GUE.GrantReward[iSubTypeHash](iPlayerID, iUnitID, iTypeHash, iSubTypeHash, sRewardSubType, iX, iY, iTurn, iEra, tUnitsInPlot, iXP, sAbility, sModifierID, false);
	elseif (sModifierID == "SAILOR_GOODY_EMPTY") then 
		Dprint(string.format("Primary reward %s has already been applied by WGH; proceeding . . .", sRewardSubType));
	else 
		Dprint(string.format("Primary reward %s has already been applied by gamecore; proceeding . . .", sRewardSubType));
	end
	-- -- execute the UnlockVillagerSecrets() enhanced method here if this reward is a valid Villager Secrets reward
	-- if (sRewardSubType == GUE.VillagerSecrets) or (GUE.VillagerSecretsRewards[sRewardSubType] ~= nil) then 
	-- 	-- this Player has villager secrets left to unlock, so unlock the next level
	-- 	-- if (GUE.PlayerData[iPlayerID].VillagerSecretsLevel < GUE.MaxSecretsLevel) then GUE.UnlockVillagerSecrets(iPlayerID, iTurn, iEra, sRewardSubType);
	-- 	if (Players[iPlayerID]:GetProperty("VillagerSecretsLevel") < GUE.MaxSecretsLevel) then GUE.UnlockVillagerSecrets(iPlayerID, iTurn, iEra, sRewardSubType);
	-- 	-- max villager secrets rewards already received by this Player ** 2021/07/28 this may not ever fire any more
	-- 	else
	-- 		-- debugging output
	-- 		Dprint("VillagerSecretsLevel >= MaxSecretsLevel for Player " .. iPlayerID .. "; rolling new reward to replace " .. sRewardSubType .. " . . .");
	-- 		-- set the replacement reward flag
	-- 		-- bIsReplacement = true;
	-- 		-- roll for one new reward
	-- 		iThisRewardModifier, bHostilesAsBonusReward = GUE.GetNewRewards(1, iPlayerID, iUnitID, iX, iY, sRewardSubType, iTurn, iEra, tUnitsInPlot, true);
	-- 	end
	-- -- execute the AddUnitToMap() enhanced method here if this reward is a free (military) unit reward
	-- elseif (GUE.GrantUnitRewards[sRewardSubType] ~= nil) then GUE.AddUnitToMap(iX, iY, iPlayerID, iTurn, iEra, sRewardSubType);
	-- -- execute the AddAbilityToUnit() enhanced method here if this reward is a unit ability reward
	-- elseif (GUE.UnitAbilityRewards[sRewardSubType] ~= nil and bIsExplore) then GUE.AddAbilityToUnit(iX, iY, tUnitsInPlot, GUE.UnitAbilityRewards[sRewardSubType]);
	-- -- execute the AddXPToUnit() enhanced method here if this reward is a unit experience reward
	-- elseif (GUE.UnitXPRewards[sRewardSubType] ~= nil) then GUE.AddXPToUnit(iX, iY, tUnitsInPlot, GUE.UnitXPRewards[sRewardSubType]);
	-- -- execute the UpgradeUnit() enhanced method here if this reward is the upgrade unit reward
	-- elseif (sRewardSubType == "GOODYHUT_GRANT_UPGRADE") then tUnitsInPlot = GUE.UpgradeUnit(iPlayerID, iX, iY, tUnitsInPlot);
	-- -- execute the CreateHostileVillagers() enhanced method here if this reward is a valid Hostile Villagers "reward"
	-- elseif (GUE.HostileVillagers[sRewardSubType] ~= nil) then GUE.CreateHostileVillagers(iX, iY, iPlayerID, iTurn, iEra, sRewardSubType);
	-- -- log output if the primary reward was of Wondrous-type
	-- elseif (GUE.WGH_Rewards[sRewardSubType] ~= nil) then Dprint("The Primary reward here is of Wondrous-type, and has already been processed by WGH");
	-- end
	-- no bonus reward(s) for Sumeria from a barbarian camp; nice try, Gilgamesh
	if bIsBarbCamp and bIsSumeria then 
		-- log output for a barbarian camp dispersed by Sumeria
		local sWarnMsg = "Skipping bonus reward(s) and hostile villagers check for reward obtained from dispersing barbarian camp";
		Dprint(sWarnMsg);
	-- 
	elseif GUE.HostileVillagers[sRewardSubType] then 
		print("Hostile villagers received as 'reward'; ignoring any further potential reward(s) from this Goody Hut");
	-- bonus reward(s) and hostile villagers, if applicable
	else
		-- initialize the hostile modifier for bonus reward(s)
		local iBonusRewardModifier = 0;
		-- roll for any bonus rewards and store the cumulative hostile modifier sum and status of the hostiles as bonus reward flag
		if not bHostilesAsBonusReward then iBonusRewardModifier, bHostilesAsBonusReward = GUE.GetNewRewards(GUE.BonusRewardsPerGoodyHut, iPlayerID, iUnitID, iX, iY, sRewardSubType, iTurn, iEra, tUnitsInPlot, false); end
		-- the difficulty modifier remains constant throughout the game
		-- local iDifficultyModifier = GUE.PlayerData[iPlayerID].Difficulty;
		local iDifficultyModifier = Players[iPlayerID]:GetProperty("Difficulty");
		-- hostile villagers will appear when the calculated hostiles chance below equals or exceeds this value
		local iSpawnThreshold = 100;
		-- roll for hostile villagers AFTER other enhanced method(s) here, IF hostiles after rewards are enabled AND this reward is NOT one of the guaranteed hostiles "rewards" AND hostiles were NOT a bonus reward
		if (GUE.HostilesAfterReward > 1) and (GUE.HostileVillagers[sRewardSubType] == nil) and not (bHostilesAsBonusReward) then
			-- determine villager hostility level
			local sHostilityLevel = GUE.DetermineVillagerHostility(bIsExpand, bIsIncreasedHostility, bIsDecreasedHostility, iDifficultyModifier, iThisRewardModifier, iBonusRewardModifier, iEra, iSpawnThreshold);
			-- spawn hostiles if the villagers are pissed enough
			if (GUE.HostileVillagers[sHostilityLevel] ~= nil) then GUE.CreateHostileVillagers(iPlayerID, iUnitID, iTypeHash, iSubTypeHash, sHostilityLevel, iX, iY, iTurn, iEra, tUnitsInPlot, iXP, sAbility, sModifierID, false); end
		end
	end
	-- define function exit message(s)
	local sPriExitMsg = "EXIT ValidateGoodyHutReward(): Turn " .. iTurn .. ", Era " .. iEra;
	-- print exit message(s) to the log when debugging
	Dprint(sPriExitMsg);
end

--[[ =========================================================================
	function Initialize()
	final configuration prior to startup
=========================================================================== ]]
function Initialize()
	-- log init messages
	print(GUE.RowOfDashes);
	print("Loading EGHV component script EnhancedGoodies.lua . . .");
	print(GUE.RowOfDashes);
    print("Configuring required ingame Enhanced Goodies component(s) for EGHV . . .");
	print("No Goody Huts: " .. tostring(GUE.NoGoodyHuts));
	if not GUE.NoGoodyHuts then 
		GUE.GoodyHutPlots = GUE.GetGoodyHutPlots();
		Dprint("There are " .. tostring(#GUE.GoodyHutPlots) .. " Goody Hut(s) on the selected map at startup");
		Dprint("Goody Hut Improvement index: " .. tostring(GUE.GoodyHutIndex));
		Dprint("There are " .. tostring(#GUE.FallbackRewards) .. " defined Fallback reward(s) for the current session");
		print("Goody Hut frequency: " .. tostring(GUE.GoodyHutFrequency) .. " %% of 'normal' distribution");
		print("Equalize all Reward chances: " .. tostring(GUE.EqualizeRewards));
		Dprint("Total number of defined Goody Hut type(s): " .. tostring(GUE.NumGoodyHutTypes));
		if (GUE.NumGoodyHutTypes > 0) then			-- print additional data for each available goody hut type when debugging
			for row in GameInfo.GoodyHutsByHash() do 
				local t = GameInfo.GoodyHuts[row.GoodyHutType];
				if (t.GoodyHutType ~= "GOODYHUT_ABILITIES" and t.GoodyHutType ~= "GOODYHUT_HOSTILES" and t.GoodyHutType ~= "GOODYHUT_MILITARY" and t.GoodyHutType ~= "GOODYHUT_PROMOTIONS" and t.GoodyHutType ~= "GOODYHUT_SAILOR_WONDROUS" and t.GoodyHutType ~= "GOODYHUT_SECRETS") then GUE.RewardTypeFunction[t.GoodyHutType] = GUE.AddModifierToPlayer;
				elseif (t.GoodyHutType == "GOODYHUT_ABILITIES") then GUE.RewardTypeFunction[t.GoodyHutType] = GUE.AddAbilityToUnit;
				elseif (t.GoodyHutType == "GOODYHUT_HOSTILES") then GUE.RewardTypeFunction[t.GoodyHutType] = GUE.CreateHostileVillagers;
				elseif (t.GoodyHutType == "GOODYHUT_MILITARY") then GUE.RewardTypeFunction[t.GoodyHutType] = GUE.AddUnitToMap;
				elseif (t.GoodyHutType == "GOODYHUT_PROMOTIONS") then GUE.RewardTypeFunction[t.GoodyHutType] = GUE.AddXPToUnit;
				elseif (t.GoodyHutType == "GOODYHUT_SAILOR_WONDROUS") then GUE.RewardTypeFunction[t.GoodyHutType] = WGH.Sailor_WGH;
				elseif (t.GoodyHutType == "GOODYHUT_SECRETS") then GUE.RewardTypeFunction[t.GoodyHutType] = GUE.UnlockVillagerSecrets;
				end
				Dprint(string.format("+ [%d]: Type %s, Weight %d", t.Hash, t.GoodyHutType, t.Weight));
				Dprint(string.format("+ + The default reward function for this Type is %s", tostring(GUE.RewardTypeFunction[t.GoodyHutType])));
			end
		end
		print("There are " .. GUE.ActiveGoodyHutTypes .. " enabled of " .. GUE.NumGoodyHutTypes .. " defined Goody Hut type(s)");
		Dprint("Total number of defined Goody Hut subtype(s): " .. tostring(GUE.NumGoodyHutRewards));
		if (GUE.NumGoodyHutRewards > 0) then			-- print additional data for each available goody hut subtype when debugging
			for row in GameInfo.GoodyHutSubTypesByHash() do 
				local t = GameInfo.GoodyHutSubTypes[row.SubTypeGoodyHut];
				if (t.SubTypeGoodyHut ~= "GOODYHUT_ADD_POP" and t.SubTypeGoodyHut ~= "GOODYHUT_GRANT_BUILDER" and t.SubTypeGoodyHut ~= "GOODYHUT_GRANT_SETTLER" and t.SubTypeGoodyHut ~= "GOODYHUT_GRANT_UPGRADE") then GUE.GrantReward[t.Hash] = GUE.RewardTypeFunction[t.GoodyHut];
				elseif (t.SubTypeGoodyHut == "GOODYHUT_GRANT_BUILDER" or t.SubTypeGoodyHut == "GOODYHUT_GRANT_SETTLER") then GUE.GrantReward[t.Hash] = GUE.AddUnitToMap;
				elseif (t.SubTypeGoodyHut == "GOODYHUT_GRANT_UPGRADE") then GUE.GrantReward[t.Hash] = GUE.UpgradeUnit;
				elseif (t.SubTypeGoodyHut == "GOODYHUT_ADD_POP") then GUE.GrantReward[t.Hash] = GUE.AddPopulationToCity;
				end
				Dprint(string.format("+ [%d]: GoodyHut %s, Subtype %s, Weight %d (%s), HostileModifier %d, ModifierID %s", t.Hash, t.GoodyHut, t.SubTypeGoodyHut, t.Weight, t.Tier, t.HostileModifier, t.ModifierID));
				Dprint(string.format("+ + GrantReward[%d] is %s", t.Hash, tostring(GUE.GrantReward[t.Hash])));
			end
		end
		print("There are " .. GUE.ActiveGoodyHutRewards .. " enabled of " .. GUE.NumGoodyHutRewards .. " defined Goody Hut subtype(s)");
	else
		print("'No Goody Huts' enabled; skipping Enhanced Goodies configuration");
	end
	print(GUE.RowOfDashes);
	print("Finished configuring required ingame Enhanced Goodies component(s); proceeding . . .");
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
	end EnhancedGoodies.lua gameplay script
=========================================================================== ]]
