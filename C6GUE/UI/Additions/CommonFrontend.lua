--[[ =========================================================================
	EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (C) 2020-2023 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin CommonFrontend.lua frontend script
=========================================================================== ]]
print("Loading CommonFrontend.lua . . .");

--[[ =========================================================================
	global defines
=========================================================================== ]]
bEGHV_IsEnabled 	= Modding.IsModEnabled("a4b1fac6-8c9e-4873-a1c1-7ddf08dbbf11");
bENWS_IsEnabled 	= Modding.IsModEnabled("d0afae5b-02f8-4d01-bd54-c2bbc3d89858");
bYnAMP_IsEnabled 	= Modding.IsModEnabled("36e88483-48fe-4545-b85f-bafc50dde315");

tCityStatesTooltip 		= {};
tGoodyHutsTooltip 		= {};
tLeadersTooltip 		= {};
tNaturalWondersTooltip 	= {};

--[[ =========================================================================
	NEW: append localized text to picker tooltips
=========================================================================== ]]
function UpdateTooltipText( r, s, t )
	if t.CityStates then tCityStatesTooltip[r] = tCityStatesTooltip[r] .. s; end
	if t.GoodyHuts then tGoodyHutsTooltip[r] = tGoodyHutsTooltip[r] .. s; end
	if t.Leaders then tLeadersTooltip[r] = tLeadersTooltip[r] .. s; end
	if t.NaturalWonders then tNaturalWondersTooltip[r] = tNaturalWondersTooltip[r] .. s; end
end

--[[ =========================================================================
	NEW: validate active content and set tooltip strings
	Modding.IsModActive() does not appear to work in Frontend context, so we're using IsModInstalled() and IsModEnabled() instead
=========================================================================== ]]
function RefreshActiveContentTooltips()
	-- 
	local iKnownItems, iActiveItems 	= 0, 0;
	local sStandard 					= Locale.Lookup("LOC_STANDARD_TT");
	-- (re)set tooltip string tables
    tCityStatesTooltip 		= { ["RULESET_STANDARD"] = sStandard, ["RULESET_EXPANSION_1"] = sStandard, ["RULESET_EXPANSION_2"] = sStandard };
    tGoodyHutsTooltip 		= { ["RULESET_STANDARD"] = sStandard, ["RULESET_EXPANSION_1"] = sStandard, ["RULESET_EXPANSION_2"] = sStandard };
    tLeadersTooltip 		= { ["RULESET_STANDARD"] = sStandard, ["RULESET_EXPANSION_1"] = sStandard, ["RULESET_EXPANSION_2"] = sStandard };
    tNaturalWondersTooltip 	= { ["RULESET_STANDARD"] = sStandard, ["RULESET_EXPANSION_1"] = sStandard, ["RULESET_EXPANSION_2"] = sStandard };
	-- query ContentFlags and parse results for active content
	print("Querying Configuration table ContentFlags for known content . . .");
	local tContent = DB.ConfigurationQuery("SELECT DISTINCT * from ContentFlags");
	if tContent and #tContent > 0 then 
		iKnownItems = #tContent;
		print(string.format("Identified %d known item(s); parsing for active content and updating picker tooltip text accordingly . . .", iKnownItems));
		for i, v in ipairs(tContent) do 
			if (Modding.IsModInstalled(v.GUID) and Modding.IsModEnabled(v.GUID)) then 
				iActiveItems 	= iActiveItems + 1;
				local sTooltip 	= Locale.Lookup(v.Tooltip);
				if v.Base then UpdateTooltipText("RULESET_STANDARD", sTooltip, v); end
				if v.XP1 then UpdateTooltipText("RULESET_EXPANSION_1", sTooltip, v); end
				if v.XP2 then UpdateTooltipText("RULESET_EXPANSION_2", sTooltip, v); end
			end
		end
		print(string.format("Picker tooltip text updated to reflect %d active of %d known item(s); proceeding . . .", iActiveItems, iKnownItems));
	else
		print("Configuration table ContentFlags is empty or undefined, proceeding without parsing content flag(s) . . .");
	end
end

--[[ =========================================================================
	NEW: update a specific picker's tooltip text based on selected ruleset
=========================================================================== ]]
function UpdateButtonToolTip(parameterId)
    local sRuleset = GameConfiguration.GetValue("RULESET");
	if (parameterId == "CityStates") then return tCityStatesTooltip[sRuleset];
	elseif (parameterId == "LeaderPool1" or parameterId == "LeaderPool2") then return tLeadersTooltip[sRuleset];
	elseif (parameterId == "GoodyHutConfig" and bEGHV_IsEnabled) then return tGoodyHutsTooltip[sRuleset];
	elseif (parameterId == "NaturalWonders" and bENWS_IsEnabled) then return tNaturalWondersTooltip[sRuleset];
	else
		if (parameterId == "NaturalWonders") then return tNaturalWondersTooltip[sRuleset];
		else return;
		end
	end
end

--[[ =========================================================================
	NEW: check for Goody Huts marked as excluded within the picker and set a game configuration value for each one found
	these values will be used to disable excluded Goody Huts when ingame content is loaded
	when all available Goody Huts for the selected ruleset are excluded, manually set the "No Goody Huts" setup option
	when the "No Barbarians" setup option is enabled, manually disable hostiles after reward, and exclude hostile villager "rewards" from the available pool
=========================================================================== ]]
function ExcludeGoodyHuts() 
	local iLoggingLevel = bEGHV_IsEnabled and GameConfiguration.GetValue("GAME_EGHV_LOGGING") or 4;
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
	NEW: this driver is for launching the picker indicated by parameter in a separate window
	since there were only 2 lines that differed between the various original picker drivers, they have been condensed here
	picker button text is modified to reflect the amount of selected items for selections of everything, and tooltip text is modified to reflect source(s) of available content
	any new picker(s) can be handled by adding new and/or modifying existing (else)if statement(s) below
	the original drivers for the city-states and leader pickers should still exist in an unmodified state
=========================================================================== ]]
function CreatePickerDriverByParameter(o, parameter, parent)

	if(parent == nil) then
		parent = GetControlStack(parameter.GroupId);
	end
			
	-- Get the UI instance
	local c :object = g_ButtonParameterManager:GetInstance();	

	local parameterId = parameter.ParameterId;
	local button = c.Button;

	-- define picker based on parameterId
	if (parameterId == "CityStates") then												-- built-in city-state picker
		button:RegisterCallback( Mouse.eLClick, function()
			LuaEvents.CityStatePicker_Initialize(o.Parameters[parameterId], g_GameParameters);
			Controls.CityStatePicker:SetHide(false);
		end);
	elseif (parameterId == "LeaderPool1" or parameterId == "LeaderPool2") then			-- built-in leader picker
		button:RegisterCallback( Mouse.eLClick, function()
			LuaEvents.LeaderPicker_Initialize(o.Parameters[parameterId], g_GameParameters);
			Controls.LeaderPicker:SetHide(false);
		end);
	elseif (parameterId == "GoodyHutConfig" and bEGHV_IsEnabled) then					-- EGHV : Goody Hut picker
		button:RegisterCallback( Mouse.eLClick, function()
			LuaEvents.GoodyHutPicker_Initialize(o.Parameters[parameterId]);
			Controls.GoodyHutPicker:SetHide(false);
		end);
	elseif (parameterId == "NaturalWonders" and bENWS_IsEnabled) then					-- ENWS : Natural Wonder picker
		button:RegisterCallback( Mouse.eLClick, function()
			LuaEvents.NaturalWonderPicker_Initialize(o.Parameters[parameterId]);
			Controls.NaturalWonderPicker:SetHide(false);
		end);
	else																				-- fallback to generic multi-select window
		button:RegisterCallback( Mouse.eLClick, function()
			LuaEvents.MultiSelectWindow_Initialize(o.Parameters[parameterId]);
			Controls.MultiSelectWindow:SetHide(false);
		end);
	end
	button:SetToolTipString(parameter.Description .. UpdateButtonToolTip(parameterId));		-- update button tooltip text

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

			local priorityAmount :number = 0;
			if (parameterId == "NaturalWonders" and bENWS_IsEnabled) then 
				priorityAmount = GameConfiguration.GetValue("PRIORITY_NATURAL_WONDERS_COUNT") or 0;
			end
			local priorityText = (priorityAmount > 0) and string.format(", %s %d", Locale.Lookup("LOC_PICKER_PRIORITIZED_TEXT"), priorityAmount) or "";

			if(valueText == nil) then
				if(value == nil) then
					if (parameter.UxHint ~= nil and parameter.UxHint == "InvertSelection") then
						valueText = "LOC_SELECTION_EVERYTHING";
						valueAmount = #p.Values; 	-- display count for selections of "everything"
					else
						valueText = "LOC_SELECTION_NOTHING";
					end
				elseif(type(value) == "table") then
					local count = #value;
					if (parameter.UxHint ~= nil and parameter.UxHint == "InvertSelection") then
						if(count == 0) then
							valueText = "LOC_SELECTION_EVERYTHING";
							valueAmount = #p.Values; 	-- display count for selections of "everything"
						elseif(count == #p.Values) then
							valueText = "LOC_SELECTION_NOTHING";
						else
							valueText = "LOC_SELECTION_CUSTOM";
							valueAmount = #p.Values - count;
						end
					else
						if(count == 0) then
							valueText = "LOC_SELECTION_NOTHING";
						elseif(count == #p.Values) then
							valueText = "LOC_SELECTION_EVERYTHING";
							valueAmount = #p.Values; 	-- display count for selections of "everything"
						else
							valueText = "LOC_SELECTION_CUSTOM";
							valueAmount = count;
						end
					end
				end
			end

			if(cache.ValueText ~= valueText) or (cache.ValueAmount ~= valueAmount) or (cache.PriorityAmount ~= priorityAmount) then
				local button = c.Button;
				valueText = string.format("%s %d of %d%s", Locale.Lookup("LOC_PICKER_SELECTED_TEXT"), valueAmount, #p.Values, priorityText);
				button:LocalizeAndSetText(valueText);
				-- 	button:LocalizeAndSetText(valueText, valueAmount);
				cache.ValueText = valueText;
				cache.ValueAmount = valueAmount;
				cache.PriorityAmount = priorityAmount;
				button:SetToolTipString(parameter.Description .. UpdateButtonToolTip(parameterId)); 	-- update button tooltip text
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
	end CommonFrontend.lua frontend script
=========================================================================== ]]
