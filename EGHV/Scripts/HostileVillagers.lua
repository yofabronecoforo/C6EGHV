--[[ =========================================================================
	EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (C) 2020-2023 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin HostileVillagers.lua gameplay script
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
-- define Hostile Villagers notification parameters
GUE.Notification.Hostile = {
	Title = Locale.Lookup("LOC_HOSTILE_VILLAGERS_NOTIFICATION_TITLE"),
	UnitTypeHash = NotificationTypes.BARBARIANS_SIGHTED,
	UnitMessage1 = Locale.Lookup("LOC_HOSTILE_VILLAGERS_UNIT_NOTIFICATION_MESSAGE_1"),
	UnitMessage2 = Locale.Lookup("LOC_HOSTILE_VILLAGERS_UNIT_NOTIFICATION_MESSAGE_2"),
	CampTypeHash = NotificationTypes.NEW_BARBARIAN_CAMP,
	CampMessage = Locale.Lookup("LOC_HOSTILE_VILLAGERS_CAMP_NOTIFICATION_MESSAGE")
};

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
-- function GUE.CreateHostileVillagers( iX, iY, iPlayerID, iTurn, iEra, sRewardSubType )
function GUE.CreateHostileVillagers( iPlayerID, iUnitID, iTypeHash, iSubTypeHash, sRewardSubType, iX, iY, iTurn, iEra, tUnits, iXP, sAbilityType, sModifierID, bIsPermanent )
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
			-- send an ingame notification for the new barbarian camp when the player is human
			if Players[iPlayerID]:IsHuman() then NotificationManager.SendNotification(iPlayerID, GUE.Notification.Hostile.CampTypeHash, GUE.Notification.Hostile.Title, GUE.Notification.Hostile.CampMessage, sX, sY); end
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
					UnitManager.InitUnitValidAdjacentHex(GUE.BarbarianID, GameInfo.HostileUnits[iEra].HeavyCavalry, sX, sY, 1);
					-- log output
					print(sPriInfoMsg .. GameInfo.HostileUnits[iEra].HeavyCavalry .. sSecInfoMsg);
					-- add an Era-appropriate heavy cavalry unit to the table of units to spawn
					table.insert(tSpawnedUnits.Units, GameInfo.HostileUnits[iEra].HeavyCavalry);
				-- default to standard melee
				else
					-- place a standard melee unit based on the current Era
					UnitManager.InitUnitValidAdjacentHex(GUE.BarbarianID, GameInfo.HostileUnits[iEra].Melee, sX, sY, 1);
					-- log output
					print(sPriInfoMsg .. GameInfo.HostileUnits[iEra].Melee .. sSecInfoMsg);
					-- add an Era-appropriate melee unit to the table of units to spawn
					table.insert(tSpawnedUnits.Units, GameInfo.HostileUnits[iEra].Melee);
				end
			-- Horses were NOT located nearby: default to standard melee
			else
				-- place a standard melee unit based on the current Era
				UnitManager.InitUnitValidAdjacentHex(GUE.BarbarianID, GameInfo.HostileUnits[iEra].Melee, sX, sY, 1);
				-- log output
				print(sPriInfoMsg .. GameInfo.HostileUnits[iEra].Melee .. sSecInfoMsg);
				-- add an Era-appropriate melee unit to the table of units to spawn
				table.insert(tSpawnedUnits.Units, GameInfo.HostileUnits[iEra].Melee);
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
					UnitManager.InitUnitValidAdjacentHex(GUE.BarbarianID, GameInfo.HostileUnits[iEra].LightCavalry, sX, sY, 1);
					-- log output
					print(sPriInfoMsg .. GameInfo.HostileUnits[iEra].LightCavalry .. sSecInfoMsg);
					-- add an Era-appropriate light cavalry unit to the table of units to spawn
					table.insert(tSpawnedUnits.Units, GameInfo.HostileUnits[iEra].LightCavalry);
				-- default to standard ranged
				else
					-- place a standard ranged unit based on the current Era
					UnitManager.InitUnitValidAdjacentHex(GUE.BarbarianID, GameInfo.HostileUnits[iEra].Ranged, sX, sY, 1);
					-- log output
					print(sPriInfoMsg .. GameInfo.HostileUnits[iEra].Ranged .. sSecInfoMsg);
					-- add an Era-appropriate ranged unit to the table of units to spawn
					table.insert(tSpawnedUnits.Units, GameInfo.HostileUnits[iEra].Ranged);
				end
			-- Horses were NOT located nearby: default to standard ranged
			else
				-- place a standard ranged unit based on the current Era
				UnitManager.InitUnitValidAdjacentHex(GUE.BarbarianID, GameInfo.HostileUnits[iEra].Ranged, sX, sY, 1);
				-- log output
				print(sPriInfoMsg .. GameInfo.HostileUnits[iEra].Ranged .. sSecInfoMsg);
				-- add an Era-appropriate ranged unit to the table of units to spawn
				table.insert(tSpawnedUnits.Units, GameInfo.HostileUnits[iEra].Ranged);
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
			-- send an ingame notification for each spawned unit when the player is human
			if Players[iPlayerID]:IsHuman() then NotificationManager.SendNotification(iPlayerID, GUE.Notification.Hostile.UnitTypeHash, sHostileTitle, sHostileUnitMessage, nX, nY); end
		end
	end
	-- define function exit message(s)
	local sPriExitMsg = "Turn " .. iTurn .. " | Era " .. iEra .. " | Exit CreateHostileVillagers()";
	-- print exit message(s) to the log when debugging
	Dprint(sPriExitMsg);
end

--[[ =========================================================================
	function Initialize()
	final configuration prior to startup
=========================================================================== ]]
function Initialize()
	-- mostly log output below here
	print(GUE.RowOfDashes);
	print("Loading EGHV component script HostileVillagers.lua . . .");
	print(GUE.RowOfDashes);
	print("Configuring required ingame Hostile Villagers component(s) for EGHV . . .");
	print("No Barbarians: " .. tostring(GUE.NoBarbarians));
	if not GUE.NoBarbarians then 
		Dprint("Barbarian Camp Improvement index: " .. tostring(GUE.BarbCampIndex));
		Dprint("Hostile Villagers 'AFTER' Goody Hut reward: " .. tostring(GUE.HostilityLevels[GUE.HostilesAfterReward]) .. " (" .. tostring(GUE.HostilesAfterReward) .. ")");
		Dprint("Hostile Villagers 'AS' potential Goody Hut 'reward': " .. tostring(GUE.HostilesAsReward) .. " (Low: " .. tostring(GUE.LowHostilityAsReward) .. ", Mid: " .. tostring(GUE.MidHostilityAsReward) .. ", High: " .. tostring(GUE.HighHostilityAsReward) .. ", Max: " .. tostring(GUE.MaxHostilityAsReward) .. " )");
		-- log hostile unit reward(s) when debugging
		if (GUE.HostilesAsReward or GUE.HostilesAfterReward > 1) and GUE.DebugEnabled then
			Dprint("Defined Hostile Unit 'reward(s)' by Era:");
			for row in GameInfo.HostileUnits() do
				Dprint(string.format("%d : Recon %s | Melee %s | Ranged %s | AntiCavalry %s | HeavyCavalry %s | LightCavalry %s | Siege %s | Support %s | NavalMelee %s | NavalRanged %s", row.Era, row.Recon, row.Melee, row.Ranged, row.AntiCavalry, row.HeavyCavalry, row.LightCavalry, row.Siege, row.Support, row.NavalMelee, row.NavalRanged));
			end
		end
	else
		print("'No Barbarians' enabled; skipping Hostile Villagers configuration");
	end
	print(GUE.RowOfDashes);
	print("Finished configuring required ingame Hostile Villagers component(s); proceeding . . .");
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
