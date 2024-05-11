--[[ =========================================================================
	C6EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (c) 2020-2024 yofabronecoforo (zzragnar0kzz)
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin gamesetuplogic_eghv.lua configuration script
=========================================================================== ]]
print("[+]: Loading GameSetupLogic_EGHV.lua UI script . . .");

--[[ =========================================================================
	NEW: does exactly what it says on the tin
=========================================================================== ]]
function LogGameStartProceed() 
	print("[i]: Proceeding with game start . . .");
	return nil;
end

--[[ =========================================================================
	NEW: does the following at game start:
	(1) aborts when No Tribal Villages is enabled
	(2) enables No Tribal Villages and aborts when goody hut distribution is set to 0% of map baseline
	(3) when No Barbarians is enabled, ensures hostile "rewards" are excluded and disables hostiles after rewards
	(4) aborts when the excluded rewards table is empty or nil
	(5) enables No Tribal Villages and aborts when the excluded rewards table contains all rewards for the selected ruleset
	(6) validates and logs any rewards excluded via the Goody Huts picker
=========================================================================== ]]
function ExcludeGoodyHuts() 
	local iLoggingLevel = GameConfiguration.GetValue("GAME_ECFE_LOGGING");           -- get the ingame logging verbosity level to control log output
	local print = (iLoggingLevel > 1) and print or function (s, ...) return; end;    -- disable print function locally when logging level is not Normal or higher

	if GameConfiguration.GetValue("GAME_NO_GOODY_HUTS") then 
		print("[i]: Setup option 'No Tribal Villages' is enabled.");
		return LogGameStartProceed();
	end
	
	if GameConfiguration.GetValue("GOODYHUT_FREQUENCY") == 0 then 
		print("[!]: Tribal Village distribution set to '0%%' of map baseline. Setup option 'No Tribal Villages' will be enabled.");
		GameConfiguration.SetValue("GAME_NO_GOODY_HUTS", true);
		return LogGameStartProceed();
	end
	
	local sRuleset = GameConfiguration.GetValue("RULESET");    -- ruleset at game start

	-- goody hut parameter domains keyed to ruleset
	local tGoodyHutDomains = {};
	for _, v in ipairs(DB.ConfigurationQuery("SELECT DISTINCT Key2 AS 'Ruleset', Domain FROM Parameters WHERE ParameterId = 'GoodyHuts'")) do 
		tGoodyHutDomains[v.Ruleset] = v.Domain;
	end

	-- all valid goody hut rewards for the selected ruleset
	local tAllGoodyHuts = {};
	for _, v in ipairs(DB.ConfigurationQuery("SELECT SubTypeGoodyHut FROM TribalVillages WHERE Domain = ?", tGoodyHutDomains[sRuleset])) do 
		tAllGoodyHuts[(#tAllGoodyHuts + 1)] = v.SubTypeGoodyHut;
	end

	-- get and parse the goody hut exclusion table
    local excludeGoodyHutsConfig = GameConfiguration.GetValue("EXCLUDE_GOODY_HUTS") or {};
	local tExcludedRewards = {};
	for _, v in ipairs(excludeGoodyHutsConfig) do tExcludedRewards[v] = true; end
	
	if GameConfiguration.GetValue("GAME_NO_BARBARIANS") then 
		print(string.format("[!]: Setup option 'No Barbarians' is enabled. All hostile 'rewards' will be excluded and hostiles after reward disabled."));
		for _, v in ipairs(DB.ConfigurationQuery("SELECT SubTypeGoodyHut FROM TribalVillages WHERE Domain = ? AND SubTypeGoodyHut LIKE '%HOSTILITY%'", tGoodyHutDomains[sRuleset])) do 
			if not tExcludedRewards[v.SubTypeGoodyHut] then table.insert(excludeGoodyHutsConfig, v.SubTypeGoodyHut); end
		end
		GameConfiguration.SetValue("EXCLUDE_GOODY_HUTS", excludeGoodyHutsConfig);
		GameConfiguration.SetValue("GAME_HOSTILES_CHANCE", 1);
	end
	
	if #excludeGoodyHutsConfig == 0 then 
		print("[i]: There are no Tribal Village reward exclusions. All rewards for the selected ruleset will be available.");
		return LogGameStartProceed();
	end
	
	if (#excludeGoodyHutsConfig == #tAllGoodyHuts) then 
		print("[!]: All available Tribal Village rewards for the selected ruleset have been excluded. Setup option 'No Tribal Villages' will be enabled.");
		GameConfiguration.SetValue("GAME_NO_GOODY_HUTS", true);
		return LogGameStartProceed();
	end
	
	if iLoggingLevel > 2 then 
		print(string.format("[i]: Identifying %d excluded Tribal Village reward%s . . .", #excludeGoodyHutsConfig, (#excludeGoodyHutsConfig ~= 1) and "s" or ""));
		for _, v in ipairs(excludeGoodyHutsConfig) do 
			print(string.format("[-]: %s", v));
		end
	end
	print(string.format("[!]: %d of %d Tribal Village reward%s for the selected ruleset will be disabled.", #excludeGoodyHutsConfig, #tAllGoodyHuts, (#tAllGoodyHuts ~= 1) and "s" or ""));
	return LogGameStartProceed();
end

--[[ =========================================================================
	OVERRIDE: pass arguments to pre-EGHV CreatePickerDriverByParameter() if parameter is not the Goody Hut picker
	otherwise create and return a driver for the Goody Hut picker
=========================================================================== ]]
Pre_EGHV_CreatePickerDriverByParameter = CreatePickerDriverByParameter;
function CreatePickerDriverByParameter(o, parameter, parent) 
	if parameter.ParameterId ~= "GoodyHuts" then 
		return Pre_EGHV_CreatePickerDriverByParameter(o, parameter, parent);
	end

	if(parent == nil) then
		parent = GetControlStack(parameter.GroupId);
	end
			
	-- Get the UI instance
	local c :object = g_ButtonParameterManager:GetInstance();	

	local parameterId = parameter.ParameterId;
	local button = c.Button;

	-- print(string.format("[+]: Creating driver for %s picker . . .", parameterId));

	button:RegisterCallback( Mouse.eLClick, function()
		LuaEvents.GoodyHutPicker_Initialize(o.Parameters[parameterId], g_GameParameters);
		Controls.GoodyHutPicker:SetHide(false);
	end);
	button:SetToolTipString(parameter.Description .. ECFE.Content.Tooltips[GameConfiguration.GetValue("RULESET")][parameterId]);    -- show content sources in tooltip text

	-- Store the root control, NOT the instance table.
	g_SortingMap[tostring(c.ButtonRoot)] = parameter;

	c.ButtonRoot:ChangeParent(parent);
	if c.StringName ~= nil then
		c.StringName:SetText(parameter.Name);
	end

	local cache = {};

	local kDriver :table = {
		Control = c,
		Cache = cache,
		UpdateValue = function(value, p)
			local valueText = value and value.Name or nil;
			local valueAmount :number = 0;

			-- only amounts displayed by valueText change now so updates to it have been removed here; can this be further simplified?
			if(valueText == nil) then 
				if(value == nil) then 
					if (parameter.UxHint ~= nil and parameter.UxHint == "InvertSelection") then 
						valueAmount = #p.Values;    -- all available items
					end
				elseif(type(value) == "table") then 
					local count = #value;
					if (parameter.UxHint ~= nil and parameter.UxHint == "InvertSelection") then 
						if(count == 0) then 
							valueAmount = #p.Values;    -- all available items
						else 
							valueAmount = #p.Values - count;
						end
					else 
						if(count == #p.Values) then 
							valueAmount = #p.Values;    -- all available items
						else 
							valueAmount = count;
						end
					end
				end
			end

			-- update valueText here
			valueText = string.format("%s %d of %d", Locale.Lookup("LOC_PICKER_SELECTED_TEXT"), valueAmount, #p.Values);

			-- add update to tooltip text here
			if(cache.ValueText ~= valueText) or (cache.ValueAmount ~= valueAmount) then 
				local button = c.Button;
				button:LocalizeAndSetText(valueText);
				cache.ValueText = valueText;
				cache.ValueAmount = valueAmount;
				button:SetToolTipString(parameter.Description .. ECFE.Content.Tooltips[GameConfiguration.GetValue("RULESET")][parameterId]);    -- show content sources in tooltip text
			end
		end,
		UpdateValues = function(values, p) 
			-- Values are refreshed when the window is open.
		end,
		SetEnabled = function(enabled, p)
			c.Button:SetDisabled(not enabled or #p.Values <= 1);
		end,
		SetVisible = function(visible)
			c.ButtonRoot:SetHide(not visible);
		end,
		Destroy = function()
			g_ButtonParameterManager:ReleaseInstance(c);
		end,
	};	

	return kDriver;
end

--[[ =========================================================================
	OVERRIDE: pass arguments to pre-EGHV GameParameters_UI_DefaultCreateParameterDriver() if parameter is not the Goody Hut frequency slider
	otherwise create and return a control for the Goody Hut frequency slider
=========================================================================== ]]
Pre_EGHV_GameParameters_UI_DefaultCreateParameterDriver = GameParameters_UI_DefaultCreateParameterDriver;
function GameParameters_UI_DefaultCreateParameterDriver(o, parameter, parent) 
	if (parameter.ParameterId ~= "GoodyHutFrequency") then 
		return Pre_EGHV_GameParameters_UI_DefaultCreateParameterDriver(o, parameter, parent);
	end

	if(parent == nil) then
		parent = GetControlStack(parameter.GroupId);
	end

	local control;
	
	-- If there is no parent, don't visualize the control.  This is most likely a player parameter.
	if(parent == nil) then
		return;
	end;

	local minimumValue = parameter.Values.MinimumValue;
	local maximumValue = parameter.Values.MaximumValue;
	local perStepValue = 25;
	
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
		local value = perStepValue * stepNum;
				
		-- This method can get called pretty frequently, try and throttle it.
		if(parameter.Value ~= perStepValue * stepNum) then
			o:SetParameterValue(parameter, value);
			BroadcastGameConfigChanges();
		end
	end);

	control = {
		Control = c,
		UpdateValue = function(value)
			if(value) then
				c.OptionSlider:SetStep(value / perStepValue);
				c.NumberDisplay:SetText(tostring(value) .. "%");
			end
		end,
		UpdateValues = function(values)
			c.OptionSlider:SetNumSteps(values.MaximumValue / perStepValue);
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

	return control;
end

--[[ =========================================================================
	OVERRIDE: pass arguments to pre-EGHV CreateSimpleParameterDriver() if parameter is not the Goody Hut frequency slider
	otherwise create and return a control for the Goody Hut frequency slider
=========================================================================== ]]
Pre_EGHV_CreateSimpleParameterDriver = CreateSimpleParameterDriver;
function CreateSimpleParameterDriver(o, parameter, parent) 
	if (parameter.ParameterId ~= "GoodyHutFrequency") then 
		return Pre_EGHV_CreateSimpleParameterDriver(o, parameter, parent);
	end

	if(parent == nil) then
		parent = GetControlStack(parameter.GroupId);
	end

	local control;
	
	-- If there is no parent, don't visualize the control.  This is most likely a player parameter.
	if(parent == nil) then
		return;
	end;

	local minimumValue = parameter.Values.MinimumValue;
	local maximumValue = parameter.Values.MaximumValue;
	local perStepValue = 25;

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
		if(parameter.Value ~= perStepValue * stepNum) then
			o:SetParameterValue(parameter, value);
			Network.BroadcastGameConfig();
		end
	end);

	control = {
		Control = c,
		UpdateValue = function(value)
			if(value) then
				c.OptionSlider:SetStep(value / perStepValue);
				c.NumberDisplay:SetText(tostring(value) .. "%");
			end
		end,
		UpdateValues = function(values)
			c.OptionSlider:SetNumSteps(values.MaximumValue / perStepValue);
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
	
	return control;
end

--[[ =========================================================================
	end gamesetuplogic_eghv.lua configuration script
=========================================================================== ]]
