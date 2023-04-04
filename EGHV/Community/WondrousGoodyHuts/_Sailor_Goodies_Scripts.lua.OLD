-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Wondrous Goody Huts by SailorCat
-- Special Thanks: Gedemon
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- // Exposed Members init - anything in this table is available across contexts, and, more importantly for us, across scripts and post-script without a bunch of cludgy includes
if not ExposedMembers.WGH then ExposedMembers.WGH = {}; end
WGH = ExposedMembers.WGH;

-- // Debug
local debug = 0
if debug == 1 then
	local sContinentsInUse = Map.GetContinentsInUse()
	for i, k in ipairs(sContinentsInUse) do
		local sContinentPlots = Map.GetContinentPlots(k)
		for i, v in ipairs(sContinentPlots) do
			local sPlot = Map.GetPlotByIndex(v)
			if sPlot:GetImprovementType() ~= -1 then
				local sPlotIndex = sPlot:GetImprovementType()
				local sPlotImpType = GameInfo.Improvements[sPlotIndex].ImprovementType
				if sPlotImpType == "IMPROVEMENT_GOODY_HUT" then
					local sPlayerVisibility = PlayersVisibility[0]
					local sVisibility = sPlayerVisibility:GetVisibilityCount(sPlot)
					sPlayerVisibility:ChangeVisibilityCount(sPlot, 1)
				end
			end
		end
	end
end

-- // Gathering wonder plots for later...
WGH.SailorWonderTable = {}
for i = 0, Map.GetPlotCount()-1, 1 do		
	local pPlot = Map.GetPlotByIndex(i)
	if pPlot:IsNaturalWonder() == true then
		table.insert(WGH.SailorWonderTable, pPlot)
	end
end

-- Door's stuck! this is called in the listener when applying a reward fails, and supplies a default reward with appropriate World View text
function WGH.Sailor_Goody_DoorStuck( pPlayer, pOwner, iX, iY, sMessage )
	-- print("Door's stuck! Spawning unit instead.")
	local sTargetUnit, iSpawnX, iSpawnY = WGH.Sailor_Goody_RandomUnit(pPlayer, iX, iY) -- // Call Random Unit Roller Function
	UnitManager.InitUnit(pOwner, sTargetUnit, iSpawnX, iSpawnY)
	if pPlayer:IsHuman() then
		Game.AddWorldViewText(pOwner, Locale.Lookup(sMessage), iX, iY, 0)
	end
	print("Door's stuck! Spawning a " .. sTargetUnit .. " for Player " .. pOwner .. " near plot (x " .. iSpawnX .. ", y " .. iSpawnY .. ") instead.")
	return
end

-- table of temporarily excluded city objects keyed to ID: a city goes here after receiving a production burst reward, and will receive no further such rewards while in this table
WGH.ExcludedCities = {}

-- removes a city from the temporarily excluded cities table when it has something in its production queue, allowing it to receive a production burst reward (again)
function WGH.IncludeCity( playerID, cityID, productionID, objectID, bCancelled )
	if WGH.ExcludedCities[cityID] then 
		WGH.ExcludedCities[cityID] = nil
		print("Door's unstuck in city " .. cityID .. " (Player " .. playerID .. ")")
	end
end

-- clears the temporarily excluded cities table at the end of each Player's turn, since chances are good that no city has an empty queue at that time
function WGH.ResetExcludedCities( playerID )
	WGH.ExcludedCities = {}
end

-- returns a (possibly empty) table of city objects, and a (random) city object or nil; facilitates spy and production burst rewards in cities other than the capital, and a fallback
function WGH.GetPlayerCities( pPlayer )
	local tCities = {}
	for i, pCity in pPlayer:GetCities():Members() do 
		table.insert(tCities, pCity)
	end
	if #tCities > 1 then 
		local iRandIndex = TerrainBuilder.GetRandomNumber(#tCities, "Random Player City Grabber") + 1
		return tCities, tCities[iRandIndex]
	elseif #tCities == 1 then 
		return tCities, tCities[1]
	else 
		return tCities, nil
	end
end

-- ///////////////////////////////////////////////////////
-- Expanded Goodies Main Function
-- ///////////////////////////////////////////////////////
function WGH.Sailor_Expanded_Goodies(playerID, unitID, iUnknown1, iUnknown2)
	if (playerID == -1) or (unitID == -1) then return; end -- // Catch for nil. Thanks, zzragnar0kzz.
	local abilityResource		= "ABILITY_SAILOR_GOODY_RANDOMRESOURCE"
	local abilityUnit			= "ABILITY_SAILOR_GOODY_RANDOMUNIT"
	local abilityImprovement	= "ABILITY_SAILOR_GOODY_RANDOMIMPROVEMENT"
	local abilitySight			= "ABILITY_SAILOR_GOODY_SIGHTBOMB"
	local abilityFormation		= "ABILITY_SAILOR_GOODY_FORMATION"
	local abilityPolicy			= "ABILITY_SAILOR_GOODY_RANDOMPOLICY"
	local abilityWonder			= "ABILITY_SAILOR_GOODY_WONDER"
	local abilityCityState		= "ABILITY_SAILOR_GOODY_CITYSTATE"
	local abilitySpy			= "ABILITY_SAILOR_GOODY_SPY"
	local abilityProduction		= "ABILITY_SAILOR_GOODY_PRODUCTION"
	local abilityTeleport		= "ABILITY_SAILOR_GOODY_TELEPORT"
	local tDoorStuckText    = { 
		[abilityResource] = "[COLOR_LIGHTBLUE]Valid placement for resource not found! Spawning unit instead.[ENDCOLOR]", 
		[abilityUnit] = "", 
		[abilityImprovement] = "[COLOR_LIGHTBLUE]Valid placement for improvement not found! Spawning unit instead.[ENDCOLOR]", 
		[abilitySight] = "[COLOR_LIGHTBLUE]Unit already has ability! Spawning unit instead.[ENDCOLOR]", 
		[abilityFormation] = "[COLOR_LIGHTBLUE]Can't apply formation! Spawning unit instead.[ENDCOLOR]", 
		[abilityPolicy] = "[COLOR_LIGHTBLUE]Valid policy not found! Spawning unit instead.[ENDCOLOR]", 
		[abilityWonder] = "[COLOR_LIGHTBLUE]Valid wonder not found! Spawning unit instead.[ENDCOLOR]", 
		[abilityCityState] = "[COLOR_LIGHTBLUE]Valid city-state not found! Spawning unit instead.[ENDCOLOR]", 
		[abilitySpy] = "[COLOR_LIGHTBLUE]Failed to place a Spy! Spawning unit instead.[ENDCOLOR]", 
		[abilityProduction] = "[COLOR_LIGHTBLUE]No valid city production queue found! Spawning unit instead.[ENDCOLOR]", 
		[abilityTeleport] = "[COLOR_LIGHTBLUE]Valid teleportation spot not found! Spawning unit instead.[ENDCOLOR]" 
	}
	local sPlayer			= Players[playerID]
	local sPlayerUnits		= sPlayer:GetUnits()
	local sUnit				= sPlayerUnits:FindID(unitID)
	local iX, iY			= sUnit:GetX(), sUnit:GetY()
	local unitList:table	= Units.GetUnitsInPlotLayerID(iX, iY, MapLayers.ANY)
	if unitList ~= nil then
		for i, pUnit in ipairs(unitList) do
			local pUnitAbility	= pUnit:GetAbility()
			local pOwner		= pUnit:GetOwner()
			local pPlayer		= Players[pOwner]

			local switchRandResource		= pUnitAbility:GetAbilityCount(abilityResource)
			local switchRandUnit			= pUnitAbility:GetAbilityCount(abilityUnit)
			local switchRandImprovement		= pUnitAbility:GetAbilityCount(abilityImprovement)
			local switchSightBomb			= pUnitAbility:GetAbilityCount(abilitySight)
			local switchFormation			= pUnitAbility:GetAbilityCount(abilityFormation)
			local switchRandPolicy			= pUnitAbility:GetAbilityCount(abilityPolicy)
			local switchWonder				= pUnitAbility:GetAbilityCount(abilityWonder)
			local switchCityState			= pUnitAbility:GetAbilityCount(abilityCityState)
			local switchSpy					= pUnitAbility:GetAbilityCount(abilitySpy)
			local switchProduction			= pUnitAbility:GetAbilityCount(abilityProduction)
			local switchTeleport			= pUnitAbility:GetAbilityCount(abilityTeleport)
			
			-- // Random Resource
			if switchRandResource == 1 then 
				print("//// Wondrous Goody Type Activated: Random Resource")
				local pTile, iResource = WGH.Sailor_Goody_RandomResource(pPlayer) -- // Call Random Resource Roller Function
				if pTile ~= nil then
					ResourceBuilder.SetResourceType(pTile, iResource, 1)
					if pPlayer:IsHuman() then
						-- // UI Notification...
						local iTileX, iTileY = pTile:GetX(), pTile:GetY()
						Game.AddWorldViewText(pOwner, Locale.Lookup("[COLOR_LIGHTBLUE]Resource spawned![ENDCOLOR]"), iTileX, iTileY, 0)
						local iGoodyNotifType	= NotificationTypes.USER_DEFINED_4
						local sGoodyNotifText	= Locale.Lookup("Wondrous resource found!")
						local resourceStr		= Locale.Lookup(GameInfo.Resources[iResource].Name)
						local iNotifDesc		= "A source of " .. resourceStr .. " has been found."
						NotificationManager.SendNotification(playerID, iGoodyNotifType, sGoodyNotifText, iNotifDesc, iTileX, iTileY)
					end
				else -- // Catch for nil: random unit spawner...
					WGH.Sailor_Goody_DoorStuck( pPlayer, pOwner, iX, iY, tDoorStuckText[abilityResource] )
				end
				pUnitAbility:ChangeAbilityCount(abilityResource, -switchRandResource)
			-- // Random Unit
			elseif switchRandUnit == 1 then 
				print("//// Wondrous Goody Type Activated: Random Unit")
				local sTargetUnit, iSpawnX, iSpawnY = WGH.Sailor_Goody_RandomUnit(pPlayer, iX, iY) -- // Call Random Unit Roller Function
				UnitManager.InitUnit(pOwner, sTargetUnit, iSpawnX, iSpawnY)
				pUnitAbility:ChangeAbilityCount(abilityUnit, -switchRandUnit)
			-- // Random Improvement
			elseif switchRandImprovement == 1 then 
				print("//// Wondrous Goody Type Activated: Random Improvement")
				local pTile, iImprovement = WGH.Sailor_Goody_RandomImprovement(pPlayer) -- // Call Random Improvement Roller Function
				if pTile ~= nil then
					ImprovementBuilder.SetImprovementType(pTile, iImprovement, 1)
				else -- // Catch for nil: random unit spawner...
					WGH.Sailor_Goody_DoorStuck( pPlayer, pOwner, iX, iY, tDoorStuckText[abilityImprovement] )
				end
				pUnitAbility:ChangeAbilityCount(abilityImprovement, -switchRandImprovement)
			-- // Sight
			elseif switchSightBomb == 1 then 
				print("//// Wondrous Goody Type Activated: Wilderness Training")
				local sAbility = pUnitAbility:GetAbilityCount("ABILITY_SAILOR_GOODY_WILDERNESS")
				if sAbility == 0 then
					pUnitAbility:ChangeAbilityCount("ABILITY_SAILOR_GOODY_WILDERNESS", 1)
				else -- // Catch for when unit likely already has ability: random unit spawner...
					WGH.Sailor_Goody_DoorStuck( pPlayer, pOwner, iX, iY, tDoorStuckText[abilitySight] )
				end
				pUnitAbility:ChangeAbilityCount(abilitySight, -switchSightBomb)
			-- // Formation
			elseif switchFormation == 1 then 
				print("//// Wondrous Goody Type Activated: Formation")
				local pUnitFormation = pUnit:GetMilitaryFormation()
				-- // Catch for army or invalid unit: random unit spawner...
				if pUnitFormation > 1 or GameInfo.Units[pUnit:GetType()].FormationClass == 'FORMATION_CLASS_CIVILIAN' or GameInfo.Units[pUnit:GetType()].FormationClass == 'FORMATION_CLASS_SUPPORT' or string.find(GameInfo.Units[pUnit:GetType()].UnitType, "HERO") then
					WGH.Sailor_Goody_DoorStuck( pPlayer, pOwner, iX, iY, tDoorStuckText[abilityFormation] )
				elseif pUnitFormation == 1 then -- // Formation: Corps --> Army
					local armyAbility = pUnitAbility:GetAbilityCount("ABILITY_SAILOR_GOODY_FORMATION_ARMY")
					pUnitAbility:ChangeAbilityCount("ABILITY_SAILOR_GOODY_FORMATION_ARMY", 1)
				else -- // Formation: None --> Corps
					local corpsAbility = pUnitAbility:GetAbilityCount("ABILITY_SAILOR_GOODY_FORMATION_CORPS")
					pUnitAbility:ChangeAbilityCount("ABILITY_SAILOR_GOODY_FORMATION_CORPS", 1)
				end
				pUnitAbility:ChangeAbilityCount(abilityFormation, -switchFormation)
			-- // RandomPolicy
			elseif switchRandPolicy == 1 then 
				print("//// Wondrous Goody Type Activated: Policy")
				local pPlayerCulture = pPlayer:GetCulture()
				local iPolicy = WGH.Sailor_Goody_RandomPolicy(pPlayer) -- // Call Random Policy Roller Function
				if iPolicy ~= nil then
					pPlayerCulture:UnlockPolicy(iPolicy)
				else -- // Catch for nil: random unit spawner...
					WGH.Sailor_Goody_DoorStuck( pPlayer, pOwner, iX, iY, tDoorStuckText[abilityPolicy] )
				end
				pUnitAbility:ChangeAbilityCount(abilityPolicy, -switchRandPolicy)
			-- // Wonder
			elseif switchWonder == 1 then 
				local pPlayerVisibility = PlayersVisibility[pPlayer:GetID()]
				print("//// Wondrous Goody Type Activated: Wonder")
				local wonTable = WGH.Sailor_Goody_Wonder(pPlayer, pPlayerVisibility) -- // Call Random Wonder Roller Function
				if wonTable ~= nil then
					for k, v in ipairs(wonTable) do
						local pVisibility = pPlayerVisibility:GetVisibilityCount(v)
						pPlayerVisibility:ChangeVisibilityCount(v, 1)
					end
				else -- // Catch for nil: random unit spawner...
					WGH.Sailor_Goody_DoorStuck( pPlayer, pOwner, iX, iY, tDoorStuckText[abilityWonder] )
				end
				pUnitAbility:ChangeAbilityCount(abilityWonder, -switchWonder)
			-- // City-State
			elseif switchCityState == 1 then 
				print("//// Wondrous Goody Type Activated: City-State")
				local pPlayerDiplomacy = pPlayer:GetDiplomacy()
				local sTargetCS = WGH.Sailor_Goody_CityState(pOwner, pPlayer, pPlayerDiplomacy) -- // Call Random City-State Roller Function
				if sTargetCS ~= nil then
					pPlayerDiplomacy:SetHasMet(sTargetCS)
				else -- // Catch for nil: random unit spawner...
					WGH.Sailor_Goody_DoorStuck( pPlayer, pOwner, iX, iY, tDoorStuckText[abilityCityState] )
				end
				pUnitAbility:ChangeAbilityCount(abilityCityState, -switchCityState)
			-- // Spy
			elseif switchSpy == 1 then 
				print("//// Wondrous Goody Type Activated: Spy")
				pPlayer:AttachModifierByID("SAILOR_GOODY_SPY_CAPACITY")
				local t, pCity = WGH.GetPlayerCities( pPlayer )
				if pCity ~= nil then 
					UnitManager.InitUnit(pOwner, "UNIT_SPY", pCity:GetX(), pCity:GetY())
				else 
					WGH.Sailor_Goody_DoorStuck( pPlayer, pOwner, iX, iY, tDoorStuckText[abilitySpy] )
				end
				pUnitAbility:ChangeAbilityCount(abilitySpy, -switchSpy)
			-- // Production
			elseif switchProduction == 1 then 
				print("//// Wondrous Goody Type Activated: Production")
				local tCities, o = WGH.GetPlayerCities( pPlayer )
				if #tCities > 0 then -- // Find a city with a valid production queue
					local bValidCityFound = false
					for i, pCity in ipairs(tCities) do 
						if not bValidCityFound then 
							local cityID = pCity:GetID()
							if not WGH.ExcludedCities[cityID] then 
								local pQueue = pCity:GetBuildQueue()
								if pQueue ~= nil then 
									WGH.ExcludedCities[cityID] = pCity
									pQueue:FinishProgress()
									bValidCityFound = true
								end
							end
						end
					end
					if not bValidCityFound then -- // Catch for no valid production queues: random unit spawner...
						WGH.Sailor_Goody_DoorStuck( pPlayer, pOwner, iX, iY, tDoorStuckText[abilityProduction] )
					end
				else -- // Catch for no cities: random unit spawner...
					WGH.Sailor_Goody_DoorStuck( pPlayer, pOwner, iX, iY, tDoorStuckText[abilityProduction] )
				end
				pUnitAbility:ChangeAbilityCount(abilityProduction, -switchProduction)
			-- // Teleport
			elseif switchTeleport == 1 then 
				print("//// Wondrous Goody Type Activated: Expedition")
				local sTargetPlot = WGH.Sailor_Goody_Teleport(pUnit, iX, iY, pPlayer) -- // Call Random Tile Roller Function
				if sTargetPlot ~= nil then
					UnitManager.RestoreMovement(pUnit) -- Can't PlaceUnit without first restoring movement.
					UnitManager.PlaceUnit(pUnit, sTargetPlot:GetX(), sTargetPlot:GetY())
					UnitManager.RestoreMovement(pUnit) -- PlaceUnit consumes all movement. This restores it.
					UnitManager.InitUnit(pOwner, "UNIT_SETTLER", sTargetPlot:GetX(), sTargetPlot:GetY())
				else -- // Catch for nil: random unit spawner... 
					WGH.Sailor_Goody_DoorStuck( pPlayer, pOwner, iX, iY, tDoorStuckText[abilityTeleport] )
				end
				pUnitAbility:ChangeAbilityCount(abilityTeleport, -switchTeleport)
			else 
			end
		end
	end
end
Events.GoodyHutReward.Add(WGH.Sailor_Expanded_Goodies)
Events.CityProductionChanged.Add(WGH.IncludeCity)
Events.PlayerTurnDeactivated.Add(WGH.ResetExcludedCities)

-- ///////////////////////////////////////////////////////
-- Grabbing City Plots
-- ///////////////////////////////////////////////////////
function WGH.GetCityPlots(pCity, resourceSwitch)
	local iCityRadius = 5
	local tTempTable = {}
	if pCity ~= nil then
		local iCityOwner = pCity:GetOwner()
		local iCityX, iCityY = pCity:GetX(), pCity:GetY()
		for dx = (iCityRadius * -1), iCityRadius do
			for dy = (iCityRadius * -1), iCityRadius do
				local pPlotNearCity = Map.GetPlotXYWithRangeCheck(iCityX, iCityY, dx, dy, iCityRadius);
				if pPlotNearCity and (pPlotNearCity:GetOwner() == iCityOwner) and (pCity == Cities.GetPlotPurchaseCity(pPlotNearCity:GetIndex())) then
					local invalidTile = 0
					if (not pPlotNearCity:IsMountain())	and (not pPlotNearCity:IsNaturalWonder()) and (pPlotNearCity:GetImprovementType() == -1) then
						local pCityDistricts = pCity:GetDistricts()
						for i = 0, pCityDistricts:GetNumDistricts() - 1 do
							local pDistrict = pCityDistricts:GetDistrictByIndex(i)
							local iPlotX, iPlotY = pPlotNearCity:GetX(), pPlotNearCity:GetY()
							local iDistrictX, iDistrictY = pDistrict:GetX(), pDistrict:GetY()
							if (iPlotX == iDistrictX) and (iPlotY == iDistrictY) then
								invalidTile = 1
							end
						end
						if invalidTile == 0 then 
							table.insert(tTempTable, pPlotNearCity)
						end
					end
				end
			end
		end
	end
	return tTempTable
end

-- ///////////////////////////////////////////////////////
-- Random Resource Roller
-- ///////////////////////////////////////////////////////
function WGH.Sailor_WondrousTileCollector(tCities)
	local iCityRadius	= 5
	local tTempTable	= {}
	for k, pCity in ipairs(tCities) do
		if pCity ~= nil then
			local iCityOwner = pCity:GetOwner()
			local iCityX, iCityY = pCity:GetX(), pCity:GetY()
			for dx = (iCityRadius * -1), iCityRadius do
				for dy = (iCityRadius * -1), iCityRadius do
					local _Plot = Map.GetPlotXYWithRangeCheck(iCityX, iCityY, dx, dy, iCityRadius);
					if _Plot and (_Plot:GetOwner() == iCityOwner) and (pCity == Cities.GetPlotPurchaseCity(_Plot:GetIndex())) then
						if (not _Plot:IsMountain()) and (_Plot:GetResourceType() == -1) and (not _Plot:IsNaturalWonder()) and ((_Plot:GetDistrictType() == -1) or (GameInfo.Districts  [_Plot:GetDistrictType()].DistrictType == "DISTRICT_CITY_CENTER")) then
							if _Plot:GetFeatureType() > -1 then
								if GameInfo.Features[_Plot:GetFeatureType()].FeatureType ~= "FEATURE_GEOTHERMAL_FISSURE" then
									table.insert(tTempTable, _Plot)
								end
							else
								table.insert(tTempTable, _Plot)
							end
						end
					end
				end
			end
		end
	end
	return tTempTable
end

function WGH.Sailor_Goody_RandomResource(pPlayer)
	local pPlayerCities     = pPlayer:GetCities()
	local pPlayerTechs      = pPlayer:GetTechs()
	local tCities           = {}
	local tValidTiles       = {}
	local tValidResources   = {}
	local dTile             = 0
	local dResource         = 0
	-- // Gathering plots...
	for k, v in pPlayerCities:Members() do
		table.insert(tCities, v)
	end
	tValidTiles = WGH.Sailor_WondrousTileCollector(tCities)
	if next(tValidTiles) ~= nil then
		dTile = TerrainBuilder.GetRandomNumber(#tValidTiles, "Goody Tile Roller") + 1
		for i, _Tile in ipairs(tValidTiles) do
			if i == dTile then
				local _TileTerrain = GameInfo.Terrains[_Tile:GetTerrainType()].TerrainType
				-- // Gathering resources...
				for k, tRow in ipairs(DB.Query("SELECT * FROM Resources WHERE (Frequency > 0 OR SeaFrequency > 0) AND (ResourceType IN (SELECT ResourceType from Resource_ValidTerrains WHERE TerrainType = '" .. _TileTerrain .. "'))")) do
					if ((tRow.PrereqTech == nil) or (pPlayerTechs:HasTech(GameInfo.Technologies[tRow.PrereqTech].Index))) then
						if _Tile:GetImprovementType() > -1 then
							local _TileIMPROVEMENT = GameInfo.Improvements[_Tile:GetImprovementType()].ImprovementType
							local tQuery = DB.Query("SELECT ResourceType FROM Improvement_ValidResources WHERE ImprovementType = '" .. _TileIMPROVEMENT .. "'")
							for k, v in ipairs(tQuery) do
								if v.ResourceType == tRow.ResourceType then 
									table.insert(tValidResources, tRow)
								end
							end
						else
							table.insert(tValidResources, tRow)
						end
					end
				end
				if next(tValidResources) ~= nil then
					dResource = TerrainBuilder.GetRandomNumber(#tValidResources, "Goody Resource Roller") + 1
					for c, _Resource in ipairs(tValidResources) do
						if c == dResource then
							local iResource = GameInfo.Resources[_Resource.ResourceType].Index
							return _Tile, iResource
						end
					end
				end
			end
		end
	end
end

-- ///////////////////////////////////////////////////////
-- Random Unit Roller
-- ///////////////////////////////////////////////////////
function WGH.Sailor_Goody_RandomUnit(pPlayer, iX, iY)
    local pPlayerEras		= pPlayer:GetEras()
    local pPlayerEra		= pPlayerEras:GetEra()
    local pPlayerEraType	= GameInfo.Eras[pPlayerEra].EraType
    local pPlayerTechs		= pPlayer:GetTechs()
    local pPlayerCulture	= pPlayer:GetCulture()
    local pPlayerCities		= pPlayer:GetCities()
    local pCap				= pPlayerCities:GetCapitalCity()
    local sailorGoodyEraGap = 3

    -- // Dowsing for water...
    local sWaterTable = {}
	if pCap then
		local pCapRadius = 5
		for dx = (pCapRadius * -1), pCapRadius do
			for dy = (pCapRadius * -1), pCapRadius do
				local sPlotNearCap = Map.GetPlotXYWithRangeCheck(pCap:GetX(), pCap:GetY(), dx, dy, pCapRadius);
				if sPlotNearCap and ((sPlotNearCap:GetOwner() == pPlayer) or (sPlotNearCap:GetOwner() == -1)) then
					local pPlotTerrainIndex = sPlotNearCap:GetTerrainType()
					local pPlotTerrainType = GameInfo.Terrains[pPlotTerrainIndex].TerrainType
					if pPlotTerrainType == "TERRAIN_COAST" then
						table.insert(sWaterTable, sPlotNearCap)
					end
				end
			end
		end
	end
    local sailorWaterSwitch = ""
    if next(sWaterTable) ~= nil then
        sailorWaterSwitch = "Domain != 'DOMAIN_AIR'"
        else sailorWaterSwitch = "Domain = 'DOMAIN_LAND'"
    end

    -- // Unit collection...
    local tValidUnits = {}
    for i, tRow in ipairs(DB.Query("SELECT * FROM Units WHERE " .. sailorWaterSwitch .. " AND ReligiousStrength = 0 AND TraitType NOT NULL AND CanRetreatWhenCaptured = 0 AND UnitType NOT LIKE 'UNIT_HERO%' AND UnitType NOT IN ('UNIT_SPY', 'UNIT_BARBARIAN_RAIDER')")) do
        if not((pPlayerEra > sailorGoodyEraGap) and (tRow.Combat > 0) and (tRow.PrereqTech == nil) and (tRow.PrereqCivic == nil)) then --/ Catching starting units...
			if (((tRow.PrereqTech == nil) or (pPlayerTechs:HasTech(GameInfo.Technologies[tRow.PrereqTech].Index) and ((pPlayerEra - GameInfo.Eras[GameInfo.Technologies[tRow.PrereqTech].EraType].Index) <= sailorGoodyEraGap)))
			 and ((tRow.PrereqCivic == nil) or (pPlayerCulture:HasCivic(GameInfo.Civics[tRow.PrereqCivic].Index) and ((pPlayerEra - GameInfo.Eras[GameInfo.Civics[tRow.PrereqCivic].EraType].Index) <= sailorGoodyEraGap)))) then
            table.insert(tValidUnits, tRow)
			end
        end
    end

    if next(tValidUnits) ~= nil then
        -- // Roll unit type...
        sailorRandomUnitNum = TerrainBuilder.GetRandomNumber(#tValidUnits, "Unit Roll") + 1
        for i, nUnit in ipairs(tValidUnits) do
            if i == sailorRandomUnitNum then
                local sTargetUnit = nUnit.UnitType
                if nUnit.Domain == 'DOMAIN_SEA' then --/ Sea spawn...
                    sailorWaterTileRoll = TerrainBuilder.GetRandomNumber(#sWaterTable, "Water Tile Roll") + 1
                    for i, nTile in ipairs(sWaterTable) do
                        if i == sailorWaterTileRoll then
                            local iWaterX, iWaterY = nTile:GetX(), nTile:GetY()
                            return sTargetUnit, iWaterX, iWaterY
                        end
                    end
                else  -- // Land spawn...
					if pCap then
						local iCapX, iCapY = pCap:GetX(), pCap:GetY()
						return sTargetUnit, iCapX, iCapY
					else
						return sTargetUnit, iX, iY
					end
                end
            end
        end
    end
end

-- ///////////////////////////////////////////////////////
-- Random Improvement Roller by SailorCat
-- ///////////////////////////////////////////////////////
function WGH.Sailor_Goody_RandomImprovement(pPlayer)
	local tValidTiles		= {}
	local resourceSwitch	= 0
	local pPlayerCities		= pPlayer:GetCities()

    -- // Rolling city...
    local iNumberofCities = 0
    for i, pIterCity in pPlayerCities:Members() do
        iNumberofCities = iNumberofCities + 1
    end

    if iNumberofCities > 0 then
        for i, pIterCity in pPlayerCities:Members() do
			local pCityLoc = pIterCity:GetName()

			-- // Rolling tiles...
			local pCityPlots = WGH.GetCityPlots(pIterCity, resourceSwitch)
			local iNumberofTiles = 0
			for k, v in ipairs(pCityPlots) do
				iNumberofTiles = iNumberofTiles + 1
			end

			if iNumberofTiles > 0 then
				while iNumberofTiles > 0 do
					local iRandom2 = TerrainBuilder.GetRandomNumber(iNumberofTiles, "Tile Roller")+1
					for i, pTile in ipairs(pCityPlots) do
						if i == iRandom2 then
							-- /// Gathering and validating improvements...
							local tValidImprovements = {}
							local pPlayerTechs = pPlayer:GetTechs()
							local pPlayerCulture = pPlayer:GetCulture()
							if pTile:GetResourceType() > -1 then -- // Resource check...
								local pResource = GameInfo.Resources[pTile:GetResourceType()].ResourceType
								local tQuery = DB.Query("SELECT ImprovementType FROM Improvement_ValidResources WHERE ResourceType = '" .. pResource .. "' AND ImprovementType NOT IN ('IMPROVEMENT_CORPORATION', 'IMPROVEMENT_INDUSTRY')")
								for k, v in ipairs(tQuery) do
									local iImprovement = GameInfo.Improvements[v.ImprovementType].Index
									if GameInfo.Resources[pTile:GetResourceType()].PrereqTech ~= nil then
										local resourceTech = GameInfo.Resources[pResource].PrereqTech
										if pPlayerTechs:HasTech(GameInfo.Technologies[resourceTech].Index) then
											return pTile, iImprovement
										end
									else
										return pTile, iImprovement
									end
								end
							else
								for i, tRow in ipairs(DB.Query("SELECT * FROM Improvements WHERE RemoveOnEntry = 0 AND ImprovementType NOT IN ('IMPROVEMENT_BARBARIAN_CAMP', 'IMPROVEMENT_SAILOR_WATCHTOWER', 'IMPROVEMENT_CORPORATION', 'IMPROVEMENT_INDUSTRY', 'IMPROVEMENT_GOLF_COURSE', 'IMPROVEMENT_MEKEWAP', 'IMPROVEMENT_KAMPUNG', 'IMPROVEMENT_PAIRIDAEZA', 'IMPROVEMENT_POLDER', 'IMPROVEMENT_PYRAMID', 'IMPROVEMENT_FEITORIA')")) do
									local pTileImprovement = tRow.ImprovementType
									if ((tRow.PrereqTech == nil) or (pPlayerTechs:HasTech(GameInfo.Technologies[tRow.PrereqTech].Index))) and ((tRow.PrereqCivic == nil) or (pPlayerCulture:HasCivic(GameInfo.Civics[tRow.PrereqCivic].Index))) then
										print("Improvement:", tRow.ImprovementType, "Tech:", tRow.PrereqTech, "Civic:", tRow.CivicType)
									-- // Gotta do terrain and feature piecemeal or things will conflict...
										if pTile:GetFeatureType() > -1 then -- // Feature check...
											local pTileFeature = GameInfo.Features[pTile:GetFeatureType()].FeatureType
											local tQuery = DB.Query("SELECT FeatureType FROM Improvement_ValidFeatures WHERE ImprovementType = '" .. pTileImprovement .. "'")
											for k, v in ipairs(tQuery) do
												if v.FeatureType == pTileFeature then
													table.insert(tValidImprovements, tRow)
												end
											end
										else -- // Terrain check...
											local pTileTerrain = pTile:GetTerrainType()
											local pTileTerrainType = GameInfo.Terrains[pTileTerrain].TerrainType
											local tQuery = DB.Query("SELECT TerrainType FROM Improvement_ValidTerrains WHERE ImprovementType = '" .. pTileImprovement .. "'")
											for k, v in ipairs(tQuery) do
												if v.TerrainType == pTileTerrainType then 
													table.insert(tValidImprovements, tRow)
												end
											end
										end
									end
								end
							end

							-- // Rolling improvements...
							local iNumberofImprovements = 0
							for i, pImprovement in ipairs(tValidImprovements) do
								iNumberofImprovements = iNumberofImprovements + 1
							end
							--if next(tValidImprovements) == nil then
							if iNumberofImprovements == 0 then 
								iNumberofTiles = iNumberofTiles - 1
								table.remove(pCityPlots, i)
								break 
							else
								local iRandom3 = TerrainBuilder.GetRandomNumber(#tValidImprovements-1, "Improvement Roller")+1
								for i, pImprovement in ipairs(tValidImprovements) do
									if i == iRandom3 then
										local pImprovementRolled = pImprovement.ImprovementType
										local iImprovement = GameInfo.Improvements[pImprovementRolled].Index
										return pTile, iImprovement
									end
								end
							end
						end
					end
				end
			end
        end
    end
end

-- ///////////////////////////////////////////////////////
-- Random Policy Roller
-- ///////////////////////////////////////////////////////
function WGH.Sailor_Goody_RandomPolicy(pPlayer)
    local pPlayerEras = pPlayer:GetEras()
    local pPlayerEra = pPlayerEras:GetEra()
    local pPlayerEraType = GameInfo.Eras[pPlayerEra].EraType

    -- // Policy check...
    local pPlayerCulture = pPlayer:GetCulture()
    local tPolicyList = {}
    for i, pRow in ipairs(DB.Query("SELECT PolicyType FROM Policies WHERE ((PolicyType IN (SELECT PolicyType FROM Policies WHERE PrereqCivic IN (SELECT CivicType FROM Civics WHERE EraType = '" .. pPlayerEraType .. "'))) OR (PolicyType IN (SELECT PolicyType FROM Policies WHERE PrereqTech IN (SELECT TechnologyType FROM Technologies WHERE EraType = '" .. pPlayerEraType .. "'))))")) do
		if not pPlayerCulture:IsPolicyUnlocked(GameInfo.Policies[pRow.PolicyType].Index) then
			table.insert(tPolicyList, pRow)
		end
    end

	-- // Rolling policy...
	if next(tPolicyList) ~= nil then
		iPolicyRoll = TerrainBuilder.GetRandomNumber(#tPolicyList-1, "Policy Roller")+1
        for i, pPolicy in ipairs(tPolicyList) do
			if i == iPolicyRoll then
				local pPolicyRolled = pPolicy.PolicyType
                local iPolicy = GameInfo.Policies[pPolicyRolled].Index
                return iPolicy
            end
        end
	end
end

-- ///////////////////////////////////////////////////////
-- Wonder Indiana Jones
-- ///////////////////////////////////////////////////////
function WGH.Sailor_Goody_Wonder(pPlayer, pPlayerVisibility)
	if pPlayerVisibility ~= nil then
		for i, pPlot in ipairs(WGH.SailorWonderTable) do
			if not pPlayerVisibility:IsRevealed(pPlot:GetX(), pPlot:GetY()) then
				local pPlotWonder = pPlot:GetFeatureType()
				local pPlotWonderType = GameInfo.Features[pPlotWonder].FeatureType
				local targetTiles = GameInfo.Features[pPlotWonder].Tiles
				local tilesHidden = 1
				local wonderVisible = false
				while (tilesHidden < targetTiles) and (wonderVisible == false) do
					for i, sPlot in ipairs(WGH.SailorWonderTable) do
						if sPlot ~= pPlot then
							local sPlotWonder = sPlot:GetFeatureType()
							local sPlotWonderType = GameInfo.Features[sPlotWonder].FeatureType
							if sPlotWonderType == pPlotWonderType then
								if not pPlayerVisibility:IsRevealed(sPlot:GetX(), sPlot:GetY()) then
									tilesHidden = tilesHidden + 1
								else wonderVisible = true
								end
							end
						end
					end
				end
				if (tilesHidden == targetTiles) and (wonderVisible == false) then
					local wonderTable = {}
					for i, iPlot in ipairs(WGH.SailorWonderTable) do
						if iPlot:GetFeatureType() == pPlotWonder then
							table.insert(wonderTable, iPlot)
						end
					end
					return wonderTable
				end
			end		
		end
	end
end

-- ///////////////////////////////////////////////////////
-- City-State Greetings Card
-- ///////////////////////////////////////////////////////
function WGH.Sailor_Goody_CityState(pOwner, pPlayer, pPlayerDiplomacy)
	for i, v in ipairs(PlayerManager.GetAliveIDs()) do
		if v ~= pOwner then
		local oPlayer = Players[v]
		local civType = PlayerConfigurations[v]:GetCivilizationLevelTypeName()
			if civType == "CIVILIZATION_LEVEL_CITY_STATE" then
				if not pPlayerDiplomacy:HasMet(v) then
					return v
				end
			end
		end
	end
end

-- ///////////////////////////////////////////////////////
-- Unit Yeeter
-- ///////////////////////////////////////////////////////
function WGH.Sailor_Goody_Teleport(pUnit, iX, iY, pPlayer)
	-- // Gather applicable land plots.
	local tTeleportTable	= {}
	local pCap				= pPlayer:GetCities():GetCapitalCity()
	local sContinentsInUse	= Map.GetContinentsInUse()
	if pCap then
		iX, iY = pCap:GetX(), pCap:GetY()
	end
	for i, k in ipairs(sContinentsInUse) do
		local sContinentPlots = Map.GetContinentPlots(k)
		for i, v in ipairs(sContinentPlots) do
			local sPlot = Map.GetPlotByIndex(v)
			if not sPlot:IsImpassable() and not sPlot:IsCity() and not sPlot:IsWater() and not sPlot:IsOwned() then
				local pPlotDistance = Map.GetPlotDistance(iX, iY, sPlot:GetX(), sPlot:GetY())
				if pPlotDistance > 17 then
					table.insert(tTeleportTable, sPlot)
				end
			end
		end
	end
	-- // Roll and yeet unit.
	if next(tTeleportTable) ~= nil then
		local iRandomTP = TerrainBuilder.GetRandomNumber(#tTeleportTable, "TP Tile Roller")+1
		for i, pTile in ipairs(tTeleportTable) do
			if i == iRandomTP then
				return pTile
			end
		end
	end
end
