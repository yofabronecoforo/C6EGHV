-- /////////////////////////////////
-- Wondrous Goody Huts by Sailor Cat
-- (u_x)/ valkrana.moe
-- Minor edits of master file and Exposed Members integration by zzragnar0kzz
-- /////////////////////////////////
-- Exposed Members init
-- /////////////////////////////////
if not ExposedMembers.WGH then ExposedMembers.WGH = {}; end
WGH = ExposedMembers.WGH;
-- maximum distance from the city center of tiles owned by a city
WGH.CityRadius = 5;
-- Will gather valid tiles, considering features for placement only if not repeated
WGH.ValidFeatures = {
	GameInfo.Features["FEATURE_REEF"].Index,
	GameInfo.Features["FEATURE_VOLCANIC_SOIL"].Index
};
for _, row in ipairs(DB.Query("SELECT DISTINCT FeatureType FROM Feature_Removes")) do
	table.insert(WGH.ValidFeatures, GameInfo.Features[row.FeatureType].Index);
end
-- Unique units, hopefully avoiding heroes and great people. Air domain needlessly complicated.
WGH.UniqueUnits = {};
for _, row in ipairs(DB.Query("SELECT * FROM Units WHERE Domain != 'DOMAIN_AIR' AND ReligiousStrength = 0 AND TraitType NOT NULL AND CanRetreatWhenCaptured = 0 AND UnitType NOT LIKE 'UNIT_HERO%' AND UnitType NOT IN ('UNIT_BARBARIAN_RAIDER', 'UNIT_BARBARIAN_HORSEMAN')")) do
	local eraC, eraT = nil, nil;
	if row.PrereqTech ~= nil then
		eraT = GameInfo.Eras[GameInfo.Technologies[row.PrereqTech].EraType].Index;
	elseif row.PrereqCivic ~= nil then
		eraC = GameInfo.Eras[GameInfo.Civics[row.PrereqCivic].EraType].Index;
	end
    table.insert(WGH.UniqueUnits, {PrereqTech = row.PrereqTech, PrereqCivic = row.PrereqCivic, UnitType = row.UnitType, Domain = row.Domain, CivicEra = eraC, TechEra = eraT});
end
-- Filtering out some unwanted improvements. First list includes those that don't display,
-- second accounts for those granted by modifier outside techs. Now using era as in unique
-- units, and opting for uniques only.
WGH.UniqueImprovements = {};
for _, row in ipairs(DB.Query("SELECT * FROM Improvements WHERE RemoveOnEntry = 0 AND TraitType NOT NULL AND ImprovementType NOT IN ('IMPROVEMENT_BARBARIAN_CAMP', 'IMPROVEMENT_GOLF_COURSE', 'IMPROVEMENT_MEKEWAP', 'IMPROVEMENT_KAMPUNG', 'IMPROVEMENT_PAIRIDAEZA', 'IMPROVEMENT_POLDER', 'IMPROVEMENT_PYRAMID', 'IMPROVEMENT_FEITORIA') AND ImprovementType NOT IN (SELECT Value FROM ModifierArguments WHERE ModifierId IN (SELECT ModifierId FROM Modifiers WHERE ModifierType = 'MODIFIER_CITY_ADJUST_ALLOWED_IMPROVEMENT'))")) do
    table.insert(WGH.UniqueImprovements, {ImprovementType = row.ImprovementType, PrereqCivic = row.PrereqCivic, PrereqTech = row.PrereqTech});
end
-- /////////////////////////////////
-- Support Functions
-- /////////////////////////////////
-- All City plots
function WGH.GetCityPlots(pCity)
	local tTempTable = {};
	if pCity ~= nil then
		local iCityOwner 		= pCity:GetOwner();
		local iCityX, iCityY 	= pCity:GetX(), pCity:GetY();
		for dx = (WGH.CityRadius * -1), WGH.CityRadius do
			for dy = (WGH.CityRadius * -1), WGH.CityRadius do
				local plot = Map.GetPlotXYWithRangeCheck(iCityX, iCityY, dx, dy, WGH.CityRadius);
				if plot and (plot:GetOwner() == iCityOwner) and (pCity == Cities.GetPlotPurchaseCity(plot:GetIndex())) then	-- Belongs to city.
					if (not plot:IsImpassable()) and (not plot:IsNaturalWonder()) and (plot:GetImprovementType() == -1) and (plot:GetDistrictType() == -1) then -- Passable and no nat wonder, improvement, or district.
						table.insert(tTempTable, plot);
					end
				end
			end
		end
	end
	return tTempTable;
end
-- Resource tiles
function WGH.GetResourceTiles(tCities, repeatnum)
	local tTempTable = {};
	for _, pCity in ipairs(tCities) do
		if pCity ~= nil then
			local iCityOwner = pCity:GetOwner();
			local iCityX, iCityY = pCity:GetX(), pCity:GetY();
			for dx = (WGH.CityRadius * -1), WGH.CityRadius do
				for dy = (WGH.CityRadius * -1), WGH.CityRadius do
					local plot = Map.GetPlotXYWithRangeCheck(iCityX, iCityY, dx, dy, WGH.CityRadius);
					if plot and (plot:GetOwner() == iCityOwner) and (pCity == Cities.GetPlotPurchaseCity(plot:GetIndex())) then
						-- No mountain, resource, nat wonder, non-city district.
						if (not plot:IsMountain()) and (plot:GetResourceType() == -1) and (not plot:IsNaturalWonder()) and ((plot:GetDistrictType() == -1) or (plot:IsCity())) then
							if repeatnum == 0 then
								if plot:GetFeatureType() > -1 then
									if plot:IsCity() then
										table.insert(tTempTable, plot);
									else
										local feature = plot:GetFeatureType();
										for _, index in ipairs(WGH.ValidFeatures) do
											if index == feature then
												table.insert(tTempTable, plot);
												break;
											end
										end
									end
								end
							else
								table.insert(tTempTable, plot);
							end
						end
					end
				end
			end
		end
	end
	return tTempTable;
end
-- /////////////////////////////////
-- Hut Functions
-- /////////////////////////////////
-- // RANDOM RESOURCE
function WGH.WGH_Resource(playerID)
    local pPlayer           = Players[playerID];
    local pPlayerCities     = pPlayer:GetCities();
    local pCapital			= pPlayerCities:GetCapitalCity();
    local pPlayerTechs      = pPlayer:GetTechs();
    local tCities           = {};
    local tValidTiles       = {};
    local tValidResources   = {};
    local repeatnum			= 0;
    -- Gathering plots.
    if pCapital then
        for _, v in pPlayerCities:Members() do
            table.insert(tCities, v);
        end
        repeat
            tValidTiles = WGH.GetResourceTiles(tCities, repeatnum);
            local rollcount = 0;
            local maxrolls	= #tValidTiles;
            if next(tValidTiles) ~= nil then
                while rollcount < maxrolls do
                    local randTile = Game.GetRandNum(#tValidTiles, "WGH Tile Roller") + 1;
                    for i, tile in ipairs(tValidTiles) do
                        if i == randTile then
                            local tileTerrain = GameInfo.Terrains[tile:GetTerrainType()].TerrainType
                            -- Gathering resources.
                            for _, tRow in ipairs(DB.Query("SELECT * FROM Resources WHERE (Frequency > 0 OR SeaFrequency > 0) AND (ResourceType IN (SELECT ResourceType from Resource_ValidTerrains WHERE TerrainType = '" .. tileTerrain .. "'))")) do
                                if ((tRow.PrereqTech == nil) or (pPlayerTechs:HasTech(GameInfo.Technologies[tRow.PrereqTech].Index))) then
                                    if tile:GetImprovementType() > -1 then -- If existing improvement, only add if valid for the resource.
                                        local tileImprovement = GameInfo.Improvements[tile:GetImprovementType()].ImprovementType;
                                        local tResources = DB.Query("SELECT ResourceType FROM Improvement_ValidResources WHERE ImprovementType = '" .. tileImprovement .. "'");
                                        for _, v in ipairs(tResources) do
                                            if v.ResourceType == tRow.ResourceType then 
                                                table.insert(tValidResources, tRow);
                                            end
                                        end
                                    else
                                        table.insert(tValidResources, tRow);
                                    end
                                end
                            end
                            -- Spawning resource.
                            if next(tValidResources) ~= nil then
                                local randResource = Game.GetRandNum(#tValidResources, "WGH Resource Roller") + 1
                                for c, resource in ipairs(tValidResources) do
                                    if c == randResource then
                                        local rIndex = GameInfo.Resources[resource.ResourceType].Index
                                        ResourceBuilder.SetResourceType(tile, rIndex, 1)
                                        return true;
                                    end
                                end
                            end
                            table.remove(tValidTiles, i);
                            maxrolls = maxrolls - 1;
                        end
                    end
                    rollcount = rollcount + 1
                end
            end
            repeatnum = repeatnum + 1;
        until repeatnum > 1;
    else return false;
    end
end
-- // RANDOM UNIT
function WGH.WGH_Unit(playerID, iX, iY)
    local player            = Players[playerID];
    local playerEra 		= player:GetEras():GetEra();
    local pCap				= player:GetCities():GetCapitalCity();
    -- Dowsing for water...
    local tWaters           = {};
    local bWaters           = false;
	if pCap then
		local pCapRadius = 5
		for dx = (pCapRadius * -1), pCapRadius do
			for dy = (pCapRadius * -1), pCapRadius do
				local sPlotNearCap = Map.GetPlotXYWithRangeCheck(pCap:GetX(), pCap:GetY(), dx, dy, pCapRadius);
				if sPlotNearCap and ((sPlotNearCap:GetOwner() == player) or (sPlotNearCap:GetOwner() == -1)) then
					if GameInfo.Terrains[sPlotNearCap:GetTerrainType()].TerrainType == "TERRAIN_COAST" then
						table.insert(tWaters, sPlotNearCap);
					end
				end
			end
		end
	end
    if next(tWaters) ~= nil then
        bWaters = true;
    end
    -- Unit collection has been changed to use units from the current era,
    -- but no longer require the player have the prerequisite tech or civic.
    local tValidUnits = {};
    for _, unit in ipairs(WGH.UniqueUnits) do
        if ((playerEra == 0 and (unit.PrereqTech == nil and unit.PrereqCivic == nil)) or ((playerEra == unit.CivicEra) or (playerEra == unit.TechEra))) then
            if bWaters then
                table.insert(tValidUnits, unit);
            elseif unit.Domain == "DOMAIN_LAND" then
                table.insert(tValidUnits, unit);
            end
        end
    end
    if next(tValidUnits) ~= nil then
        -- Roll unit type.
        local randUnit = Game.GetRandNum(#tValidUnits, "Random Unique Unit Roll") + 1;
        for i, u in ipairs(tValidUnits) do
            if i == randUnit then
                local targetUnit = u.UnitType;
                if u.Domain == 'DOMAIN_SEA' then -- Sea spawn.
                    for _, tile in ipairs(tWaters) do
                        local spawnX, spawnY = tile:GetX(), tile:GetY();
                        UnitManager.InitUnit(playerID, targetUnit, spawnX, spawnY);
                        return true;
                    end
                else  -- Land spawn.
					if pCap then
						local capX, capY = pCap:GetX(), pCap:GetY();
						UnitManager.InitUnit(playerID, targetUnit, capX, capY);
					else
						UnitManager.InitUnit(playerID, targetUnit, iX, iY);
					end
                    return true;
                end
            end
        end
    else return false;
    end
end
-- // RANDOM IMPROVEMENT
function WGH.WGH_Improvement(playerID)
    local player            = Players[playerID];
    local playerEra 		= player:GetEras():GetEra();
	local playerCities		= player:GetCities();
    -- Rolling city.
    local iCities           = playerCities:GetCount();
    if iCities > 0 then
        for _, city in playerCities:Members() do
			-- Rolling tiles.
			local cityPlots = WGH.GetCityPlots(city);
			if #cityPlots > 0 then
				while #cityPlots > 0 do
					for i, tile in ipairs(cityPlots) do
						-- Gathering and validating improvements.
						local tValidImprovements = {};
						for _, imp in ipairs(WGH.UniqueImprovements) do
							if ((playerEra == 0 and (imp.PrereqTech == nil and imp.PrereqCivic == nil)) or ((playerEra == imp.CivicEra) or (playerEra == imp.TechEra))) then
								if ImprovementBuilder.CanHaveImprovement(tile, GameInfo.Improvements[imp.ImprovementType].Index, -1) then
									table.insert(tValidImprovements, imp);
								end
							end
						end
						-- Rolling improvements.
						if next(tValidImprovements) == nil then
							table.remove(cityPlots, i);
							break;
						else
							local randImp = Game.GetRandNum(#tValidImprovements, "Random Improvement Roller");
							for c, ui in ipairs(tValidImprovements) do
								if c == randImp then
									local index = GameInfo.Improvements[ui.ImprovementType].Index;
									ImprovementBuilder.SetImprovementType(tile, index, 1);
									return true;
								end
							end
						end
					end
				end
			end
        end
    end
    return false;
end
-- // SIGHT
function WGH.WGH_Sight(_1, _2, _3, _4, unitAbility)
    local abilityNum = unitAbility:GetAbilityCount("ABILITY_SAILOR_GOODY_WILDERNESS");
    if abilityNum == 0 then
        unitAbility:ChangeAbilityCount("ABILITY_SAILOR_GOODY_WILDERNESS", 1);
        return true;
    else return false;
    end
end
-- // FORMATION
function WGH.WGH_Formation(_1, _2, _3, unit, unitAbility)
    local formation = unit:GetMilitaryFormation();
    if formation > 1 or GameInfo.Units[unit:GetType()].FormationClass == 'FORMATION_CLASS_CIVILIAN' or GameInfo.Units[unit:GetType()].FormationClass == 'FORMATION_CLASS_SUPPORT' or string.find(GameInfo.Units[unit:GetType()].UnitType, "HERO") then
        return false;
    elseif formation == 1 then
        unitAbility:ChangeAbilityCount("ABILITY_SAILOR_GOODY_FORMATION_ARMY", 1);
        return true;
    else
        unitAbility:ChangeAbilityCount("ABILITY_SAILOR_GOODY_FORMATION_CORPS", 1);
        return true;
    end
end
-- // POLICY
function WGH.WGH_Policy(playerID)
    local player        = Players[playerID];
    local playerEraType = GameInfo.Eras[player:GetEras():GetEra()].EraType;
    local playerCulture = player:GetCulture();
    local tPolicyList   = {};
    for _, row in ipairs(DB.Query("SELECT PolicyType FROM Policies WHERE ((PolicyType IN (SELECT PolicyType FROM Policies WHERE PrereqCivic IN (SELECT CivicType FROM Civics WHERE EraType = '" .. playerEraType .. "'))) OR (PolicyType IN (SELECT PolicyType FROM Policies WHERE PrereqTech IN (SELECT TechnologyType FROM Technologies WHERE EraType = '" .. playerEraType .. "'))))")) do
		if not playerCulture:IsPolicyUnlocked(GameInfo.Policies[row.PolicyType].Index) then
			table.insert(tPolicyList, row)
		end
    end

	-- Rolling policy.
	if next(tPolicyList) ~= nil then
		local policyRoll = Game.GetRandNum(#tPolicyList-1, "Random Policy Roller")+1
        for i, policy in ipairs(tPolicyList) do
			if i == policyRoll then
                local index = GameInfo.Policies[policy.PolicyType].Index;
                playerCulture:UnlockPolicy(index);
                return true;
            end
        end
	else return false;
    end
end
-- // WONDER
-- Gather wonder plots to then use in filter below.
local tPlots = {};
for i = 0, Map.GetPlotCount()-1, 1 do		
	local plot = Map.GetPlotByIndex(i);
	if plot:IsNaturalWonder() == true then
		table.insert(tPlots, plot);
	end
end
local tWonderPlots = {};
for _, wonder in ipairs(DB.Query("SELECT * FROM Features WHERE NaturalWonder = 1")) do
	local rowIndex = GameInfo.Features[wonder.FeatureType].Index;
    if Map.GetFeatureCount(rowIndex) > 0 then
		for _, p in ipairs(tPlots) do
			local plotIndex = p:GetFeatureType();
			if plotIndex == rowIndex then
				local plots = p:GetFeature():GetPlots();
				table.insert(tWonderPlots, plots); -- Might need to add keys for water determination.
				break;
			end
		end
	end
end
-- Seaworthy tech. This could be better devised to account for seafaring and coastal dinghies,
-- but it isn't worth the effort.
local kanitech = DB.Query("SELECT * FROM Technologies WHERE TechnologyType IN (SELECT TechnologyType FROM TechnologyModifiers WHERE ModifierId = (SELECT ModifierId FROM Modifiers WHERE ModifierType = 'MODIFIER_PLAYER_UNITS_ADJUST_VALID_TERRAIN' AND ModifierId IN (SELECT ModifierId FROM ModifierArguments WHERE Value = 'TERRAIN_OCEAN')))")[1];
local kanindex = GameInfo.Technologies[kanitech.TechnologyType].Index;

function WGH.WGH_Wonder(playerID, iX, iY, unit)
    local playerVisibility 	= PlayersVisibility[playerID];
	local tempWonderPlots	= tWonderPlots;
	local bKani				= Players[playerID]:GetTechs():HasTech(kanindex);
	if playerVisibility ~= nil then
		for _, plots in ipairs(tWonderPlots) do
			local bUndiscovered = true;
			for _, plot in ipairs(plots) do
				-- Iterate each wonder's tiles until either an explored tile is found or
				-- we determine that all of that wonder's tiles haven't been explored.
				-- IIRC IsRevealed() checks both explored and revealed states.
				if playerVisibility:IsRevealed(plot) then
					bUndiscovered = false; -- Player has discovered this wonder.
					break;
				end
			end
			if bUndiscovered == true then
				for _, index in ipairs(plots) do
					local plot 			= Map.GetPlotByIndex(index);
					local plotX, plotY 	= plot:GetX(), plot:GetY();
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(plotX, plotY, direction);
						if adjacentPlot then
							if not adjacentPlot:IsCity() and not adjacentPlot:IsImpassable() then
								local bWater = adjacentPlot:IsWater();
								if (not bWater) or (bWater and bKani) then -- Water check.
									UnitManager.RestoreMovement(unit); -- Can't PlaceUnit without first restoring movement.
									UnitManager.PlaceUnit(unit, adjacentPlot:GetX(), adjacentPlot:GetY());
									UnitManager.RestoreMovement(unit); -- PlaceUnit consumes all movement.
									UnitManager.PlaceUnit(unit, iX, iY);
									UnitManager.RestoreMovement(unit); -- Might give some movement back that it didn't have before.
									return true;
								end
							end
						end
					end
				end
			end
		end
		return false; -- No applicable wonders.
	else return false;
	end
end
-- // CITY-STATE
function WGH.WGH_CityState(playerID)
	local player 			= Players[playerID];
	local playerDiplomacy 	= player:GetDiplomacy();
	for _, v in ipairs(PlayerManager.GetAliveMinorIDs()) do
		if not playerDiplomacy:HasMet(v) then
			playerDiplomacy:SetHasMet(v);
			player:GetInfluence():GiveFreeTokenToPlayer(v);
			return true;
		end
	end
	return false;
end
-- // SPY
function WGH.WGH_Spy(playerID)
	local player	= Players[playerID];
	local pCap 		= player:GetCities():GetCapitalCity();
	if pCap then
		player:AttachModifierByID("SAILOR_GOODY_SPY_CAPACITY");
		UnitManager.InitUnit(playerID, "UNIT_SPY", pCap:GetX(), pCap:GetY());
		return true;
	else return false;
	end
end
-- // PRODUCTION
function WGH.WGH_Production(playerID)
	local pCap = Players[playerID]:GetCities():GetCapitalCity();
	if pCap then
		local pQueue = pCap:GetBuildQueue();
		if pQueue:CurrentlyBuilding() ~= "NONE" then
			pQueue:FinishProgress();
			return true;
		else return false;
		end
	else return false;
	end
end
-- // TELEPORT
function WGH.WGH_Teleport(playerID, iX, iY, unit)
	-- Gather applicable land plots.
	local tTeleportTable	= {};
	local pCap				= Players[playerID]:GetCities():GetCapitalCity();
	local continentsInUse	= Map.GetContinentsInUse();
	if pCap then
		iX, iY = pCap:GetX(), pCap:GetY();
	end
	for _, continent in ipairs(continentsInUse) do
		local continentPlots = Map.GetContinentPlots(continent)
		for _, index in ipairs(continentPlots) do
			local plot = Map.GetPlotByIndex(index);
			if not plot:IsImpassable() and not plot:IsCity() and not plot:IsWater() and not plot:IsOwned() then
				if Map.GetPlotDistance(iX, iY, plot:GetX(), plot:GetY()) > 14 then
					table.insert(tTeleportTable, plot);
				end
			end
		end
	end
	-- Roll and yeet unit.
	if next(tTeleportTable) ~= nil then
		local randTP = Game.GetRandNum(#tTeleportTable, "TP Tile Roller") + 1;
		for i, tile in ipairs(tTeleportTable) do
			if i == randTP then
				local tX, tY = tile:GetX(), tile:GetY();
				UnitManager.RestoreMovement(unit); -- Can't PlaceUnit without first restoring movement.
				UnitManager.PlaceUnit(unit, tX, tY);
				UnitManager.RestoreMovement(unit); -- PlaceUnit consumes all movement. This restores it.
				UnitManager.InitUnit(playerID, "UNIT_SETTLER", tX, tY);
				return true;
			end
		end
	else return false;
	end
end
-- /////////////////////////////////
-- Expanded Goodies Main Function
-- /////////////////////////////////
-- List of variables used by hut function.
-- Resource: playerID; Unit: playerID, iX, iY; Improvement: playerID; Sight: unitAbility; Formation: unit, unitAbility; Policy: playerID; 
-- Wonder: playerID, iX, iY, unit; City-State: playerID; Spy: playerID; Production: playerID; Teleport: playerID, iX, iY, unit
WGH.Hutties = { 
	[1999084244]   = {Name = "RESOURCE",     Func = WGH.WGH_Resource}, 
	[1625079733]   = {Name = "UNIT",         Func = WGH.WGH_Unit}, 
	[-2106477136]  = {Name = "IMPROVEMENT",  Func = WGH.WGH_Improvement}, 
	[-1461129027]  = {Name = "SIGHT",        Func = WGH.WGH_Sight}, 
	[260349556]    = {Name = "FORMATION",    Func = WGH.WGH_Formation}, 
	[1157765560]   = {Name = "POLICY",       Func = WGH.WGH_Policy}, 
	[-2028412409]  = {Name = "WONDER",       Func = WGH.WGH_Wonder}, 
	[1379672131]   = {Name = "CITYSTATE",    Func = WGH.WGH_CityState}, 
	[-2099557375]  = {Name = "SPY",          Func = WGH.WGH_Spy}, 
	[913875234]    = {Name = "PRODUCTION",   Func = WGH.WGH_Production}, 
	[-861896920]   = {Name = "TELEPORT",     Func = WGH.WGH_Teleport}
};

function WGH.Sailor_WGH(playerID, unitID, goodytype, subgoodytype)
	if goodytype ~= -304388911 then return; end -- Wondrous only.
	if (playerID == -1) or (unitID == -1) then return; end -- Catch for nil. Thanks, zzragnar0kzz.
	local unit				= Players[playerID]:GetUnits():FindID(unitID);
	local unitAbility		= unit:GetAbility();
	local iX, iY			= unit:GetX(), unit:GetY();
	print("Wondrous Goody Activated:", subgoodytype, WGH.Hutties[subgoodytype].Name);
	local bSuccess = WGH.Hutties[subgoodytype].Func(playerID, iX, iY, unit, unitAbility);
	if not bSuccess then -- Random unique as fallback if reward can't be granted for any reason.
		WGH.WGH_Unit(playerID, iX, iY);
		if Players[playerID]:IsHuman() then -- Notify unique unit on failure.
			Game.AddWorldViewText(playerID, Locale.Lookup("LOC_WGH_FLOAT_FALLBACK"), iX, iY, 0);
		end
	end
end
-- Events.GoodyHutReward.Add(WGH.Sailor_WGH);
