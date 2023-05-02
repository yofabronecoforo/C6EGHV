--[[ =========================================================================
	EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (C) 2020-2023 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin HostGame_EGHV.lua frontend script
=========================================================================== ]]
print("Loading HostGame_EGHV.lua . . .");

--[[ =========================================================================
	store original function(s) that will be overwritten below
=========================================================================== ]]
BASE_CreateSimpleParameterDriver = (BASE_CreateSimpleParameterDriver ~= nil) and BASE_CreateSimpleParameterDriver or CreateSimpleParameterDriver;
-- BASE_GameParameters_UI_CreateParameterDriver = GameParameters_UI_CreateParameterDriver;
BASE_OnShow = (BASE_OnShow ~= nil) and BASE_OnShow or OnShow;
BASE_HostGame = (BASE_HostGame ~= nil) and BASE_HostGame or HostGame;
BASE_OnShutdown = (BASE_OnShutdown ~= nil) and BASE_OnShutdown or OnShutdown;

--[[ =========================================================================
	OVERRIDE: if this parameter is the Goody Hut frequency slider, configure its control
	otherwise, call the original CreateSimpleParameterDriver() to configure this parameter's control
=========================================================================== ]]
function CreateSimpleParameterDriver(o, parameter, parent)
	-- store the original value of parent if the original function must be called, which is the most likely outcome
	local BASE_parent = parent;

	if(parent == nil) then
		parent = GetControlStack(parameter.GroupId);
	end

	local control;
	
	-- If there is no parent, don't visualize the control.  This is most likely a player parameter.
	if(parent == nil) then
		return;
	end;

	if (bEGHV_IsEnabled and parameter.ParameterId == "GoodyHutFrequency") then	-- configure the Goody Hut frequency slider
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
					c.NumberDisplay:SetText(tostring(value));
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
	else -- call original function with BASE_parent in case parent changed above
		control = BASE_CreateSimpleParameterDriver(o, parameter, BASE_parent);
	end

	return control;
end

--[[ =========================================================================
	OVERRIDE: the various picker drivers have been condensed into CreatePickerDriverByParameter()
    these drivers are preserved but are no longer required, nor is the original GameParameters_UI_CreateParameterDriver()
=========================================================================== ]]
function GameParameters_UI_CreateParameterDriver(o, parameter, ...)
	local parameterId = parameter.ParameterId;
	if(parameterId == "CityStates" or parameterId == "LeaderPool1" or parameterId == "LeaderPool2" or (parameterId == "GoodyHutConfig" and bEGHV_IsEnabled) or (parameterId == "NaturalWonders" and bENWS_IsEnabled)) then 
		if GameConfiguration.IsWorldBuilderEditor() then
			return nil;
		end
		return CreatePickerDriverByParameter(o, parameter);
	elseif(parameter.Array) then								-- fallback for generic multi-select window; no WorldBuilder check
		return CreatePickerDriverByParameter(o, parameter);
	else
		return GameParameters_UI_DefaultCreateParameterDriver(o, parameter, ...);
	end
end

--[[ =========================================================================
	OVERRIDE: refresh active content tooltips and call original OnShow()
=========================================================================== ]]
function OnShow()
    RefreshActiveContentTooltips();
    BASE_OnShow();
end

--[[ =========================================================================
	OVERRIDE: exclude Goody Huts and call original HostGame()
=========================================================================== ]]
function HostGame(serverType:number)
    ExcludeGoodyHuts();
    BASE_HostGame(serverType);
end

--[[ =========================================================================
	OVERRIDE: call original OnShutdown() and remove LuaEvent listeners for the modified Goody Hut and Natural Wonder pickers
=========================================================================== ]]
function OnShutdown()
    BASE_OnShutdown();
    LuaEvents.GoodyHutPicker_SetParameterValues.Remove(OnSetParameterValues);				-- EGHV
	LuaEvents.NaturalWonderPicker_SetParameterValues.Remove(OnSetParameterValues);			-- ENWS
end

--[[ =========================================================================
	reset context pointers with modified functions
=========================================================================== ]]
ContextPtr:SetShutdown( OnShutdown );
ContextPtr:SetShowHandler( OnShow );

--[[ =========================================================================
	add new LuaEvent listeners for the modified Goody Hut and Natural Wonder pickers
=========================================================================== ]]
LuaEvents.GoodyHutPicker_SetParameterValues.Add(OnSetParameterValues);				-- EGHV
LuaEvents.NaturalWonderPicker_SetParameterValues.Add(OnSetParameterValues);			-- ENWS

--[[ =========================================================================
	end HostGame_EGHV.lua frontend script
=========================================================================== ]]
