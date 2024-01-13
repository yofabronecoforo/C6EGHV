--[[ =========================================================================
	C6EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (C) 2020-2024 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin gamesetuplogic_eghv.lua configuration script
=========================================================================== ]]
print("[+]: Loading GameSetupLogic_EGHV.lua . . .");

--[[ =========================================================================
	store original function(s) that will be overwritten below
=========================================================================== ]]
-- BASE_GameParameters_UI_DefaultCreateParameterDriver = (BASE_GameParameters_UI_DefaultCreateParameterDriver ~= nil) and BASE_GameParameters_UI_DefaultCreateParameterDriver or GameParameters_UI_DefaultCreateParameterDriver;
-- BASE_MapSize_ValueNeedsChanging = MapSize_ValueNeedsChanging;
-- BASE_MapSize_ValueChanged = MapSize_ValueChanged;

--[[ =========================================================================
	NEW: check for Goody Huts marked as excluded within the picker and set a game configuration value for each one found
	these values will be used to disable excluded Goody Huts when ingame content is loaded
	when all available Goody Huts for the selected ruleset are excluded, manually set the "No Goody Huts" setup option
	when the "No Barbarians" setup option is enabled, manually disable hostiles after reward, and exclude hostile villager "rewards" from the available pool
=========================================================================== ]]
function ExcludeGoodyHuts() 
	-- local iLoggingLevel = bEGHV_IsEnabled and GameConfiguration.GetValue("GAME_EGHV_LOGGING") or 4;
	local iLoggingLevel = GameConfiguration.GetValue("GAME_ECFE_LOGGING");
    local excludeGoodyHutsConfig = GameConfiguration.GetValue("EXCLUDE_GOODY_HUTS") or {};
	local tExcludedRewards = {};
	for _, v in ipairs(excludeGoodyHutsConfig) do tExcludedRewards[v] = true; end
	local sRuleset = GameConfiguration.GetValue("RULESET");
    local sDomain = (sRuleset == "RULESET_EXPANSION_2") and "Expansion2GoodyHuts" or (sRuleset == "RULESET_EXPANSION_1") and "Expansion1GoodyHuts" or "StandardGoodyHuts";
	local sPrefix = "EXCLUDE_";
	if GameConfiguration.GetValue("GAME_NO_BARBARIANS") then 
		GameConfiguration.SetValue("GOODYHUTS_EXCLUDED", 1);
		local tHostileRewards = DB.ConfigurationQuery("SELECT * FROM TribalVillages WHERE Domain = ? AND SubTypeGoodyHut LIKE '%HOSTILITY%'", sDomain);
		if iLoggingLevel > 1 then 
			local sRewards = (#tHostileRewards == 1) and "reward" or "rewards";
			print(string.format("[*]: The 'No Barbarians' setup option is enabled; disabling hostile villagers after reward, and ensuring %d defined hostile villager '%s' are disabled . . .", #tHostileRewards, sRewards));
		end
		GameConfiguration.SetValue("GAME_HOSTILES_CHANCE", 1);
		for _, v in ipairs(tHostileRewards) do 
			local sGHSetting = sPrefix .. v.SubTypeGoodyHut;    -- this no longer affects anything other than some log output during gameplay script init
			GameConfiguration.SetValue(sGHSetting, 1);          -- same as above
			if not tExcludedRewards[v.SubTypeGoodyHut] then table.insert(excludeGoodyHutsConfig, v.SubTypeGoodyHut); end
		end
		GameConfiguration.SetValue("EXCLUDE_GOODY_HUTS", excludeGoodyHutsConfig);
	end
	tExcludedRewards = nil;
	if #excludeGoodyHutsConfig > 0 then 
		GameConfiguration.SetValue("GOODYHUTS_EXCLUDED", 1);
		if iLoggingLevel > 1 then 
			local sIsOrAre = (#excludeGoodyHutsConfig == 1) and "is" or "are";
			local sRewards = (#excludeGoodyHutsConfig == 1) and "reward" or "rewards";
			print("[*]: Excluding any rewards that were explicitly disabled in the picker or implicitly disabled by way of the 'No Barbarians' setup option . . .");
			if iLoggingLevel > 2 then for _, v in ipairs(excludeGoodyHutsConfig) do print(string.format("[-]: %s", v)); end end
			print(string.format("[*]: There %s %d Tribal Village %s marked as 'excluded'", sIsOrAre, #excludeGoodyHutsConfig, sRewards));
		end
		local tGoodyHuts = DB.ConfigurationQuery("SELECT * FROM TribalVillages WHERE Domain = ?", sDomain);
		if (#excludeGoodyHutsConfig == #tGoodyHuts) then 
			if iLoggingLevel > 1 then print("[*]: All available Tribal Village rewards for the selected ruleset have been marked as 'excluded'; enabling setup option 'No Tribal Villages' to attempt to ensure total exclusion"); end
			GameConfiguration.SetValue("GAME_NO_GOODY_HUTS", true);
		end
	else
		if iLoggingLevel > 1 then print("[*]: No Tribal Village rewards have been marked as 'excluded'"); end
	end
	return;
end

--[[ =========================================================================
	OVERRIDE: if this parameter is the Goody Hut frequency slider, configure its control
	otherwise, call the original GameParameters_UI_DefaultCreateParameterDriver() to configure this parameter's control
=========================================================================== ]]
Pre_EGHV_GameParameters_UI_DefaultCreateParameterDriver = GameParameters_UI_DefaultCreateParameterDriver;
function GameParameters_UI_DefaultCreateParameterDriver(o, parameter, parent) 
	-- store the original value of parent if the original function must be called, which is the most likely outcome
	local ORIGINAL_parent = parent;

	if(parent == nil) then
		parent = GetControlStack(parameter.GroupId);
	end

	local control;
	
	-- If there is no parent, don't visualize the control.  This is most likely a player parameter.
	if(parent == nil) then
		return;
	end;

	if (g_bIsEnabledEGHV and parameter.ParameterId == "GoodyHutFrequency") then	-- configure the Goody Huts frequency slider
		local minimumValue = parameter.Values.MinimumValue;
		local maximumValue = parameter.Values.MaximumValue;
	
		-- Get the UI instance
		local c = g_SliderParameterManager:GetInstance();	
	
		-- Store the root control, NOT the instance table.
		g_SortingMap[tostring(c.Root)] = parameter;
	
		c.Root:ChangeParent(parent);
		if c.StringName ~= nil then
			c.StringName:SetText(parameter.Name);
		end
	
		c.OptionTitle:SetText(parameter.Name);
		c.Root:SetToolTipString(parameter.Description);
		c.OptionSlider:RegisterSliderCallback(function()
			local stepNum = c.OptionSlider:GetStep();
			local value = minimumValue * stepNum;
				
			-- This method can get called pretty frequently, try and throttle it.
			if(parameter.Value ~= minimumValue * stepNum) then
				o:SetParameterValue(parameter, value);
				BroadcastGameConfigChanges();
			end
		end);
	
	
		control = {
			Control = c,
			UpdateValue = function(value)
				if(value) then
					c.OptionSlider:SetStep(value / minimumValue);
					c.NumberDisplay:SetText(tostring(value) .. "%");
				end
			end,
			UpdateValues = function(values)
				c.OptionSlider:SetNumSteps(values.MaximumValue / values.MinimumValue);
				minimumValue = values.MinimumValue;
				maximumValue = values.MaximumValue;
			end,
			SetEnabled = function(enabled, parameter)
				c.OptionSlider:SetHide(not enabled or parameter.Values == nil or parameter.Values.MinimumValue == parameter.Values.MaximumValue);
			end,
			SetVisible = function(visible, parameter)
				c.Root:SetHide(not visible or parameter.Value == nil );
			end,
			Destroy = function()
				g_SliderParameterManager:ReleaseInstance(c);
			end,
		};
	else -- call original function with ORIGINAL_parent in case parent changed above
		control = Pre_EGHV_GameParameters_UI_DefaultCreateParameterDriver(o, parameter, ORIGINAL_parent);
	end

	return control;
end

--[[ =========================================================================
	OVERRIDE: if this parameter is the Goody Hut frequency slider, configure its control
	otherwise, call the original CreateSimpleParameterDriver() to configure this parameter's control
=========================================================================== ]]
Pre_EGHV_CreateSimpleParameterDriver = CreateSimpleParameterDriver;
function CreateSimpleParameterDriver(o, parameter, parent) 
	-- store the original value of parent if the original function must be called, which is the most likely outcome
	local ORIGINAL_parent = parent;

	if(parent == nil) then
		parent = GetControlStack(parameter.GroupId);
	end

	local control;
	
	-- If there is no parent, don't visualize the control.  This is most likely a player parameter.
	if(parent == nil) then
		return;
	end;

	if (g_bIsEnabledEGHV and parameter.ParameterId == "GoodyHutFrequency") then	-- configure the Goody Hut frequency slider
		local minimumValue = parameter.Values.MinimumValue;
		local maximumValue = parameter.Values.MaximumValue;

		-- Get the UI instance
		local c = g_SimpleSliderParameterManager:GetInstance();	
		
		-- Store the root control, NOT the instance table.
		g_SortingMap[tostring(c.Root)] = parameter;
		
		c.Root:ChangeParent(parent);

		local name = Locale.ToUpper(parameter.Name);
		if c.StringName ~= nil then
			c.StringName:SetText(name);
		end
			
		c.OptionTitle:SetText(name);
		c.Root:SetToolTipString(parameter.Description);

		c.OptionSlider:RegisterSliderCallback(function()
			local stepNum = c.OptionSlider:GetStep();
			local value = minimumValue * stepNum;
			
			-- This method can get called pretty frequently, try and throttle it.
			if(parameter.Value ~= minimumValue * stepNum) then
				o:SetParameterValue(parameter, value);
				Network.BroadcastGameConfig();
			end
		end);

		control = {
			Control = c,
			UpdateValue = function(value)
				if(value) then
					c.OptionSlider:SetStep(value / minimumValue);
					c.NumberDisplay:SetText(tostring(value) .. "%");
				end
			end,
			UpdateValues = function(values)
				c.OptionSlider:SetNumSteps(values.MaximumValue / values.MinimumValue);
			end,
			SetEnabled = function(enabled, parameter)
				c.OptionSlider:SetHide(not enabled or parameter.Values == nil or parameter.Values.MinimumValue == parameter.Values.MaximumValue);
			end,
			SetVisible = function(visible, parameter)
				c.Root:SetHide(not visible or parameter.Value == nil );
			end,
			Destroy = function()
				g_SimpleSliderParameterManager:ReleaseInstance(c);
			end,
		};
	else -- call original function with ORIGINAL_parent in case parent changed above
		control = Pre_EGHV_CreateSimpleParameterDriver(o, parameter, ORIGINAL_parent);
	end

	return control;
end

--[[ =========================================================================
	OVERRIDE: replace MapSize_ValueNeedsChanging() wholesale to include necessary changes and avoid multiple DB queries
=========================================================================== ]]
-- function MapSize_ValueNeedsChanging(p)
-- 	local results = CachedQuery("SELECT * from MapSizes where Domain = ? and MapSizeType = ? LIMIT 1", p.Value.Domain, p.Value.Value);

-- 	-- define min/max/default values for Players, City States, and Natural Wonders; NW values will be used for the slider(s) if ENWS is present
-- 	local minPlayers = 2;
-- 	local maxPlayers = 2;
-- 	local defPlayers = 2;
-- 	local minCityStates = 0;
-- 	local maxCityStates = 0;
-- 	local defCityStates = 0;
-- 	local minNaturalWonders = 0;
-- 	local maxNaturalWonders = 0;
-- 	local defNaturalWonders = 0;

-- 	-- results should only contain one table, so iterating over it is kinda stupid; access values in results[1] directly here instead
-- 	if(results) then
-- 		minPlayers = results[1].MinPlayers;
-- 		maxPlayers = results[1].MaxPlayers;
-- 		defPlayers = results[1].DefaultPlayers;
-- 		minCityStates = results[1].MinCityStates;
-- 		maxCityStates = results[1].MaxCityStates;
-- 		defCityStates = results[1].DefaultCityStates;
-- 		if (results[1].MinNaturalWonders ~= nil) then minNaturalWonders = results[1].MinNaturalWonders; end
-- 		if (results[1].MaxNaturalWonders ~= nil) then maxNaturalWonders = results[1].MaxNaturalWonders; end
-- 		if (results[1].DefaultNaturalWonders ~= nil) then defNaturalWonders = results[1].DefaultNaturalWonders; end
-- 	end

-- 	-- TODO: Add Min/Max city states, set defaults.
-- 	if(MapConfiguration.GetMinMajorPlayers() ~= minPlayers) then
-- 		SetupParameters_Log("Min Major Players: " .. MapConfiguration.GetMinMajorPlayers() .. " should be " .. minPlayers);
-- 		return true;
-- 	elseif(MapConfiguration.GetMaxMajorPlayers() ~= maxPlayers) then
-- 		SetupParameters_Log("Max Major Players: " .. MapConfiguration.GetMaxMajorPlayers() .. " should be " .. maxPlayers);
-- 		return true;
-- 	elseif(MapConfiguration.GetMinMinorPlayers() ~= minCityStates) then
-- 		SetupParameters_Log("Min Minor Players: " .. MapConfiguration.GetMinMinorPlayers() .. " should be " .. minCityStates);
-- 		return true;
-- 	elseif(MapConfiguration.GetMaxMinorPlayers() ~= maxCityStates) then
-- 		SetupParameters_Log("Max Minor Players: " .. MapConfiguration.GetMaxMinorPlayers() .. " should be " .. maxCityStates);
-- 		return true;
-- 	elseif(MapConfiguration.GetValue("MAP_MIN_NATURAL_WONDERS") ~= minNaturalWonders) then
-- 		if (MapConfiguration.GetValue("MAP_MIN_NATURAL_WONDERS") == nil) then
-- 			MapConfiguration.SetValue("MAP_MIN_NATURAL_WONDERS", minNaturalWonders);
-- 		end
-- 		SetupParameters_Log("Min Natural Wonders: ", MapConfiguration.GetValue("MAP_MIN_NATURAL_WONDERS"), " should be ", minNaturalWonders);
-- 		return true;
-- 	elseif(MapConfiguration.GetValue("MAP_MAX_NATURAL_WONDERS") ~= maxNaturalWonders) then
-- 		if (MapConfiguration.GetValue("MAP_MAX_NATURAL_WONDERS") == nil) then
-- 			MapConfiguration.SetValue("MAP_MAX_NATURAL_WONDERS", maxNaturalWonders);
-- 		end
-- 		SetupParameters_Log("Max Natural Wonders: ", MapConfiguration.GetValue("MAP_MAX_NATURAL_WONDERS"), " should be ", maxNaturalWonders);
-- 		return true;
-- 	end

-- 	return false;
-- end

--[[ =========================================================================
	OVERRIDE: replace MapSize_ValueChanged() wholesale to include necessary changes and avoid multiple DB queries
=========================================================================== ]]
-- function MapSize_ValueChanged(p)
-- 	SetupParameters_Log("MAP SIZE CHANGED");

-- 	-- The map size has changed!
-- 	-- Adjust the number of players to match the default players of the map size.
-- 	local results = CachedQuery("SELECT * from MapSizes where Domain = ? and MapSizeType = ? LIMIT 1", p.Value.Domain, p.Value.Value);

-- 	-- initialize min/max/default values for Players, City States, and Natural Wonders; NW values will be used for the slider(s) if ENWS is present
-- 	local minPlayers = 2;
-- 	local maxPlayers = 2;
-- 	local defPlayers = 2;
-- 	local minCityStates = 0;
-- 	local maxCityStates = 0;
-- 	local defCityStates = 0;
-- 	local minNaturalWonders = 0;
-- 	local maxNaturalWonders = 0;
-- 	local defNaturalWonders = 0;

-- 	-- results should only contain one table, so iterating over it is kinda stupid; access values in results[1] directly here instead and change the above values as needed
-- 	if(results) then
-- 		minPlayers = results[1].MinPlayers;
-- 		maxPlayers = results[1].MaxPlayers;
-- 		defPlayers = results[1].DefaultPlayers;
-- 		minCityStates = results[1].MinCityStates;
-- 		maxCityStates = results[1].MaxCityStates;
-- 		defCityStates = results[1].DefaultCityStates;
-- 		if (results[1].MinNaturalWonders ~= nil) then minNaturalWonders = results[1].MinNaturalWonders; end
-- 		if (results[1].MaxNaturalWonders ~= nil) then maxNaturalWonders = results[1].MaxNaturalWonders; end
-- 		if (results[1].DefaultNaturalWonders ~= nil) then defNaturalWonders = results[1].DefaultNaturalWonders; end
-- 	end

-- 	-- set min/max/default values for Players, City States, and Natural Wonders
-- 	MapConfiguration.SetMinMajorPlayers(minPlayers);
-- 	MapConfiguration.SetMaxMajorPlayers(maxPlayers);
-- 	MapConfiguration.SetMinMinorPlayers(minCityStates);
-- 	MapConfiguration.SetMaxMinorPlayers(maxCityStates);
-- 	GameConfiguration.SetValue("CITY_STATE_COUNT", defCityStates);
-- 	MapConfiguration.SetValue("MAP_MIN_NATURAL_WONDERS", minNaturalWonders);
-- 	MapConfiguration.SetValue("MAP_MAX_NATURAL_WONDERS", maxNaturalWonders);
-- 	GameConfiguration.SetValue("NATURAL_WONDER_COUNT", defNaturalWonders);

-- 	-- Clamp participating player count in network multiplayer so we only ever auto-spawn players up to the supported limit. 
-- 	local mpMaxSupportedPlayers = 8; -- The officially supported number of players in network multiplayer games.
-- 	local participatingCount = defPlayers + GameConfiguration.GetHiddenPlayerCount();
-- 	if GameConfiguration.IsNetworkMultiplayer() or GameConfiguration.IsPlayByCloud() then
-- 		participatingCount = math.clamp(participatingCount, 0, mpMaxSupportedPlayers);
-- 	end

-- 	SetupParameters_Log("Setting participating player count to " .. tonumber(participatingCount));
-- 	local playerCountChange = GameConfiguration.SetParticipatingPlayerCount(participatingCount);
-- 	Network.BroadcastGameConfig(true);

-- 	-- NOTE: This used to only be called if playerCountChange was non-zero.
-- 	-- This needs to be called more frequently than that because each player slot entry's add/remove button
-- 	-- needs to be potentially updated to reflect the min/max player constraints.
-- 	if(GameSetup_PlayerCountChanged) then
-- 		GameSetup_PlayerCountChanged();
-- 	end
-- end

--[[ =========================================================================
	log successful loading of this component
=========================================================================== ]]
print("[i]: Finished loading GameSetupLogic_EGHV.lua, proceeding . . .");

--[[ =========================================================================
	end gamesetuplogic_eghv.lua configuration script
=========================================================================== ]]
