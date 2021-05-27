--[[ =========================================================================
	EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (C) 2020-2021 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	C6GUE : Gameplay and Usability Enhancements for Civilization VI
	Copyright (C) 2020-2021 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin C6GUE_Common.lua shared components
=========================================================================== ]]

--[[ =========================================================================
	context sharing : fetch (or initialize) ExposedMembers
=========================================================================== ]]
ExposedMembers.C6GUE = ExposedMembers.C6GUE or {};
C6GUE = ExposedMembers.C6GUE;

--[[ =========================================================================
	member function TestFunction() : print some generic output
=========================================================================== ]]
C6GUE.TestFunction = ExposedMembers.C6GUE.TestFunction or function()
    print("Entering C6GUE.TestFunction() . . .");
end

--[[ =========================================================================
	function CheckContentChanges() : poll for content changes
=========================================================================== ]]
function CheckContentChanges( mods )
    if (#mods ~= #C6GUE.InstalledContent) then
        C6GUE.InstalledContent = Modding.GetInstalledMods();
        return true;
    end
    for i, v in ipairs(C6GUE.ValidContent) do
        if (Modding.IsModInstalled(v.GUID) ~= C6GUE[v.Name].IsInstalled) then return true; end
        if (Modding.IsModEnabled(v.GUID) ~= C6GUE[v.Name].IsEnabled) then return true; end
    end
    return false;
end

--[[ =========================================================================
	function GetDefaultTooltipText() : does exactly what it says on the tin
=========================================================================== ]]
function GetDefaultTooltipText()
    -- (re)set exposed tables
    C6GUE.CityStatesTooltip = {};
    C6GUE.GoodyHutsTooltip = {};
    C6GUE.LeadersTooltip = {};
    C6GUE.NaturalWondersTooltip = {};
    -- (re)set default tooltip strings
    for k, v in pairs( { ["RULESET_STANDARD"] = "", ["RULESET_EXPANSION_1"] = "", ["RULESET_EXPANSION_2"] = "" } ) do
        C6GUE.CityStatesTooltip[k] = Locale.Lookup("LOC_STANDARD_TT");
        C6GUE.GoodyHutsTooltip[k] = Locale.Lookup("LOC_STANDARD_TT");
        C6GUE.LeadersTooltip[k] = Locale.Lookup("LOC_STANDARD_TT");
        C6GUE.NaturalWondersTooltip[k] = Locale.Lookup("LOC_STANDARD_TT");
    end
end

--[[ =========================================================================
	function GetUserContentFlags() : fetch user-defined content flags
=========================================================================== ]]
function GetUserContentFlags()
    print("C6GUE: Parsing contents of Configuration table ContentFlags for user content, if any . . .");
    C6GUE.UserItems = 0;            -- (re)set tracking counters
    local t = {};
    local sQuery = "SELECT DISTINCT * from ContentFlags";
	local tResult = DB.ConfigurationQuery(sQuery);
    if tResult and #tResult > 0 then
        for i, v in ipairs(tResult) do
            C6GUE.UserItems = C6GUE.UserItems + 1;
            t = { Id = v.Id, Name = v.Name, GUID = v.GUID, CityStates = v.CityStates, GoodyHuts = v.GoodyHuts, Leaders = v.Leaders, NaturalWonders = v.NaturalWonders, Base = v.Base, XP1 = v.XP1, XP2 = v.XP2, Tooltip = v.Tooltip };
            if t.CityStates > 0 then t.CityStates = true; else t.CityStates = false; end
            if t.GoodyHuts > 0 then t.GoodyHuts = true; else t.GoodyHuts = false; end
            if t.Leaders > 0 then t.Leaders = true; else t.Leaders = false; end
            if t.NaturalWonders > 0 then t.NaturalWonders = true; else t.NaturalWonders = false; end
            if t.Base > 0 then t.Base = true; else t.Base = false; end
            if t.XP1 > 0 then t.XP1 = true; else t.XP1 = false; end
            if t.XP2 > 0 then t.XP2 = true; else t.XP2 = false; end
            table.insert(C6GUE.ValidContent, t);
        end
        print("C6GUE: Finished parsing Configuration table ContentFlags; " .. C6GUE.UserItems .. " defined content flag(s) found.");
	else
        print("C6GUE: Configuration table ContentFlags is empty or undefined; unable to parse content flag(s).");
	end
end

--[[ =========================================================================
	function RefreshActiveContentTooltips() : validate active content and set tooltip strings
=========================================================================== ]]
function RefreshActiveContentTooltips()
    -- (re)set default tooltip text
    GetDefaultTooltipText();
    -- (re)set ValidContent
    C6GUE.ValidContent = {};
    for i, v in ipairs(C6GUE.KnownContent) do table.insert(C6GUE.ValidContent, v); end
    -- (re)set tracking counters
    C6GUE.ActiveItems = 0;
    C6GUE.AvailableItems = 0;
    -- fetch user content
    GetUserContentFlags();
    -- (re)set active content flags
    print("C6GUE: Parsing " .. #C6GUE.ValidContent .. " known item(s); identifying active content and updating tooltip text . . .");
    for i, v in ipairs(C6GUE.ValidContent) do
        C6GUE[v.Name] = {};
        C6GUE[v.Name].IsInstalled = Modding.IsModInstalled(v.GUID);
        C6GUE[v.Name].IsEnabled = Modding.IsModEnabled(v.GUID);
        C6GUE[v.Name].ProvidesCityStates = v.CityStates;
        C6GUE[v.Name].ProvidesGoodyHuts = v.GoodyHuts;
        C6GUE[v.Name].ProvidesLeaders = v.Leaders;
        C6GUE[v.Name].ProvidesNaturalWonders = v.NaturalWonders;
        C6GUE[v.Name].Rulesets = { ["RULESET_STANDARD"] = v.Base, ["RULESET_EXPANSION_1"] = v.XP1, ["RULESET_EXPANSION_2"] = v.XP2 };
        local sAvailability = " * " .. v.Name .. " : Installed : " .. tostring(C6GUE[v.Name].IsInstalled);
        if C6GUE[v.Name].IsInstalled then
            C6GUE.AvailableItems = C6GUE.AvailableItems + 1;
            sAvailability = sAvailability .. " | Enabled : " .. tostring(C6GUE[v.Name].IsEnabled);
            if C6GUE[v.Name].IsEnabled then
                C6GUE.ActiveItems = C6GUE.ActiveItems + 1;
                sAvailability = sAvailability .. " | Provides :";
                if not v.CityStates and not v.GoodyHuts and not v.Leaders and not v.NaturalWonders then
                    sAvailability = sAvailability .. " 'no additional content'";
                else
                    if v.CityStates then sAvailability = sAvailability .. " [City-States]"; end
                    if v.GoodyHuts then sAvailability = sAvailability .. " [Goody Huts]"; end
                    if v.Leaders then sAvailability = sAvailability .. " [Leaders]"; end
                    if v.NaturalWonders then sAvailability = sAvailability .. " [Natural Wonders]"; end
                end
            end
        end
        -- print(sAvailability);
        if C6GUE[v.Name].IsEnabled then
            for k, x in pairs(C6GUE[v.Name].Rulesets) do
                if x and v.CityStates then C6GUE.CityStatesTooltip[k] = C6GUE.CityStatesTooltip[k] .. Locale.Lookup(v.Tooltip); end
                if x and v.GoodyHuts then C6GUE.GoodyHutsTooltip[k] = C6GUE.GoodyHutsTooltip[k] .. Locale.Lookup(v.Tooltip); end
                if x and v.Leaders then C6GUE.LeadersTooltip[k] = C6GUE.LeadersTooltip[k] .. Locale.Lookup(v.Tooltip); end
                if x and v.NaturalWonders then C6GUE.NaturalWondersTooltip[k] = C6GUE.NaturalWondersTooltip[k] .. Locale.Lookup(v.Tooltip); end
            end
        end
    end
    print("C6GUE: Finished identifying active content and updating tooltip(s); " .. C6GUE.AvailableItems .. " of " .. #C6GUE.ValidContent .. " known item(s) are available [ " .. C6GUE.ActiveItems .. " active ]");
    -- print("C6GUE: Current ruleset-based tooltip text for picker windows:");
    -- for k, v in pairs(C6GUE.CityStatesTooltip) do print("C6GUE: CityStatesTooltip[" .. k .. "]: " .. v); end
    -- for k, v in pairs(C6GUE.GoodyHutsTooltip) do print("C6GUE: GoodyHutsTooltip[" .. k .. "]: " .. v); end
    -- for k, v in pairs(C6GUE.LeadersTooltip) do print("C6GUE: LeadersTooltip[" .. k .. "]: " .. v); end
    -- for k, v in pairs(C6GUE.NaturalWondersTooltip) do print("C6GUE: NaturalWondersTooltip[" .. k .. "]: " .. v); end
end

--[[ =========================================================================
	function UpdateButtonToolTip() : update a specific picker's tooltip text based on selected ruleset
=========================================================================== ]]
function UpdateButtonToolTip(parameterId)
    local sRuleset = GameConfiguration.GetValue("RULESET");
	if (parameterId == "CityStates") then return C6GUE.CityStatesTooltip[sRuleset];
	elseif (parameterId == "LeaderPool1" or parameterId == "LeaderPool2") then return C6GUE.LeadersTooltip[sRuleset];
	elseif (parameterId == "GoodyHutConfig" and C6GUE.EGHV.IsEnabled) then return C6GUE.GoodyHutsTooltip[sRuleset];
	elseif (parameterId == "NaturalWonders" and C6GUE.ENWS.IsEnabled) then return C6GUE.NaturalWondersTooltip[sRuleset];
	else
		if (parameterId == "NaturalWonders") then return C6GUE.NaturalWondersTooltip[sRuleset];
		else return;
		end
	end
end

--[[ =========================================================================
	additional members
=========================================================================== ]]
C6GUE.InstalledContent = ExposedMembers.C6GUE.InstalledContent or Modding.GetInstalledMods();

C6GUE.KnownContent = ExposedMembers.C6GUE.KnownContent or {
    { Id = "DLC01", Name = "Aztec", GUID = "02A8BDDE-67EA-4D38-9540-26E685E3156E", CityStates = false, GoodyHuts = false, Leaders = true, NaturalWonders = false, Base = true, XP1 = true, XP2 = true, Tooltip = "LOC_DLC_AZTEC_TT" },
    { Id = "DLC02", Name = "Poland", GUID = "3809975F-263F-40A2-A747-8BFB171D821A", CityStates = false, GoodyHuts = false, Leaders = true, NaturalWonders = false, Base = true, XP1 = true, XP2 = true, Tooltip = "LOC_DLC_POLAND_TT" },
    { Id = "DLC03", Name = "Vikings", GUID = "2F6E858A-28EF-46B3-BEAC-B985E52E9BC1", CityStates = true, GoodyHuts = false, Leaders = true, NaturalWonders = true, Base = true, XP1 = true, XP2 = true, Tooltip = "LOC_DLC_VIKINGS_TT" },
    { Id = "DLC04", Name = "Australia", GUID = "E3F53C61-371C-440B-96CE-077D318B36C0", CityStates = false, GoodyHuts = false, Leaders = true, NaturalWonders = true, Base = true, XP1 = true, XP2 = true, Tooltip = "LOC_DLC_AUSTRALIA_TT" },
    { Id = "DLC05", Name = "Persia", GUID = "E2749E9A-8056-45CD-901B-C368C8E83DEB", CityStates = false, GoodyHuts = false, Leaders = true, NaturalWonders = false, Base = true, XP1 = true, XP2 = true, Tooltip = "LOC_DLC_PERSIA_TT" },
    { Id = "DLC06", Name = "Nubia", GUID = "643EA320-8E1A-4CF1-A01C-00D88DDD131A", CityStates = false, GoodyHuts = false, Leaders = true, NaturalWonders = false, Base = true, XP1 = true, XP2 = true, Tooltip = "LOC_DLC_NUBIA_TT" },
    { Id = "DLC07", Name = "Khmer", GUID = "1F367231-A040-4793-BDBB-088816853683", CityStates = false, GoodyHuts = false, Leaders = true, NaturalWonders = true, Base = true, XP1 = true, XP2 = true, Tooltip = "LOC_DLC_KHMER_TT" },
    { Id = "DLC08", Name = "Maya", GUID = "9DE86512-DE1A-400D-8C0A-AB46EBBF76B9", CityStates = true, GoodyHuts = false, Leaders = true, NaturalWonders = true, Base = true, XP1 = true, XP2 = true, Tooltip = "LOC_DLC_MAYA_TT" },
    { Id = "DLC09", Name = "Ethiopia", GUID = "1B394FE9-23DC-4868-8F0A-5220CB8FB427", CityStates = false, GoodyHuts = false, Leaders = true, NaturalWonders = false, Base = true, XP1 = true, XP2 = true, Tooltip = "LOC_DLC_ETHIOPIA_TT" },
    { Id = "DLC10", Name = "Byzantium", GUID = "A1100FC4-70F2-4129-AC27-2A65A685ED08", CityStates = false, GoodyHuts = false, Leaders = true, NaturalWonders = false, Base = true, XP1 = true, XP2 = true, Tooltip = "LOC_DLC_BYZANTIUM_TT" },
    { Id = "DLC11", Name = "Babylon", GUID = "8424840C-92EF-4426-A9B4-B4E0CB818049", CityStates = true, GoodyHuts = false, Leaders = true, NaturalWonders = false, Base = true, XP1 = true, XP2 = true, Tooltip = "LOC_DLC_BABYLON_STK_TT" },
    { Id = "DLC12", Name = "Vietnam", GUID = "A3F42CD4-6C3E-4F5A-BC81-BE29E0C0B87C", CityStates = false, GoodyHuts = false, Leaders = true, NaturalWonders = false, Base = true, XP1 = true, XP2 = true, Tooltip = "LOC_DLC_VIETNAM_TT" },
    { Id = "DLC13", Name = "Portugal", GUID = "FFDF4E79-DEE2-47BB-919B-F5739106627A", CityStates = false, GoodyHuts = false, Leaders = true, NaturalWonders = false, Base = true, XP1 = true, XP2 = true, Tooltip = "LOC_DLC_PORTUGAL_TT" },
    { Id = "XP1", Name = "Expansion1", GUID = "1B28771A-C749-434B-9053-D1380C553DE9", CityStates = false, GoodyHuts = false, Leaders = true, NaturalWonders = true, Base = false, XP1 = true, XP2 = true, Tooltip = "LOC_XP1_TT" },
    { Id = "XP2", Name = "Expansion2", GUID = "4873eb62-8ccc-4574-b784-dda455e74e68", CityStates = true, GoodyHuts = true, Leaders = true, NaturalWonders = true, Base = false, XP1 = false, XP2 = true, Tooltip = "LOC_XP2_TT" },
    -- { Id = "WGH", Name = "WondrousGoodyHuts", GUID = "2d90451f-08c9-47de-bce8-e9b7fdecbe92", CityStates = false, GoodyHuts = true, Leaders = false, NaturalWonders = false, Base = true, XP1 = true, XP2 = true, Tooltip = "LOC_WGH_TT" },
    { Id = "C6GUE01", Name = "ENWS", GUID = "d0afae5b-02f8-4d01-bd54-c2bbc3d89858", CityStates = false, GoodyHuts = false, Leaders = false, NaturalWonders = false, Base = true, XP1 = true, XP2 = true, Tooltip = "LOC_ENWS_TT" },
    { Id = "C6GUE02", Name = "EGHV", GUID = "a4b1fac6-8c9e-4873-a1c1-7ddf08dbbf11", CityStates = false, GoodyHuts = true, Leaders = false, NaturalWonders = false, Base = true, XP1 = true, XP2 = true, Tooltip = "LOC_EGHV_TT" }
};

C6GUE.ContentCheckedAtStartup = ExposedMembers.C6GUE.ContentCheckedAtStartup or false;
C6GUE.RefreshContent = ExposedMembers.C6GUE.RefreshContent or false;

if not C6GUE.ContentCheckedAtStartup then
    print("C6GUE: Performing startup content check . . .");
    RefreshActiveContentTooltips();
    C6GUE.ContentCheckedAtStartup = true;
end

--[[ =========================================================================
	references
        everything above springs from this:
            local bIsExpansion1:boolean = Modding.IsModActive("1B28771A-C749-434B-9053-D1380C553DE9");
            local bIsExpansion2:boolean = Modding.IsModActive("4873eb62-8ccc-4574-b784-dda455e74e68");
        2021/05/22 : Modding.IsModActive() does not appear to work in Frontend context, so we're using IsModInstalled() and IsModEnabled() instead
=========================================================================== ]]

--[[ =========================================================================
    end C6GUE_Common.lua shared components
=========================================================================== ]]


--[[ =========================================================================
	begin modified GameSetupLogic.lua frontend script
=========================================================================== ]]
-- print("C6GUE: Loading modified GameSetupLogic.lua . . .");

-------------------------------------------------
-- Game Setup Logic
-------------------------------------------------
include( "InstanceManager" );
include ("SetupParameters");

-- C6GUE shared components
-- include("C6GUE_Common");
-- ExposedMembers.C6GUE = ExposedMembers.C6GUE or {};
-- C6GUE = ExposedMembers.C6GUE;
-- C6GUE.TestFunction();

-- Instance managers for dynamic game options (parent is set dynamically).
g_BooleanParameterManager	= InstanceManager:new("BooleanParameterInstance",	"CheckBox");
g_PullDownParameterManager	= InstanceManager:new("PullDownParameterInstance",	"Root");
g_SliderParameterManager	= InstanceManager:new("SliderParameterInstance",	"Root");
g_StringParameterManager	= InstanceManager:new("StringParameterInstance",	"StringRoot");
g_ButtonParameterManager	= InstanceManager:new("ButtonParameterInstance",	"ButtonRoot");

g_ParameterFactories = {};

-- This is a mapping of instanced controls to their parameters.
-- It's used to cross reference the parameter from the control
-- in order to sort that control.
g_SortingMap = {};

-------------------------------------------------------------------------------
-- Determine which UI stack the parameters should be placed in.
-------------------------------------------------------------------------------
function GetControlStack(group)
	
	local gameModeParametersStack = Controls.GameModeParameterStack;
	if(gameModeParametersStack == nil) then
		gameModeParametersStack = Controls.PrimaryParametersStack;
	end

	local triage = {

		["BasicGameOptions"] = Controls.PrimaryParametersStack,
		["GameOptions"] = Controls.PrimaryParametersStack,
		["BasicMapOptions"] = Controls.PrimaryParametersStack,
		["MapOptions"] = Controls.PrimaryParametersStack,
		["GameModes"] = gameModeParametersStack;
		["Victories"] = Controls.VictoryParameterStack,
		["AdvancedOptions"] = Controls.SecondaryParametersStack,
	};

	-- Triage or default to advanced.
	return triage[group];
end

-------------------------------------------------------------------------------
-- This function wrapper allows us to override this function and prevent
-- network broadcasts for every change made - used currently in Options.lua
-------------------------------------------------------------------------------
function BroadcastGameConfigChanges()
	Network.BroadcastGameConfig();
end

-------------------------------------------------------------------------------
-- Parameter Hooks
-------------------------------------------------------------------------------
function Parameters_Config_EndWrite(o, config_changed)
	SetupParameters.Config_EndWrite(o, config_changed);
	
	-- Dispatch a Lua event notifying that the configuration has changed.
	-- This will eventually be handled by the configuration layer itself.
	if(config_changed) then
		SetupParameters_Log("Marking Configuration as Changed.");
		if(GameSetup_ConfigurationChanged) then
			GameSetup_ConfigurationChanged();
		end
	end
end

function GameParameters_SyncAuxConfigurationValues(o, parameter)
	local result = SetupParameters.Parameter_SyncAuxConfigurationValues(o, parameter);
	
	-- If we don't already need to resync and the parameter is MapSize, perform additional checks.
	if(not result and parameter.ParameterId == "MapSize" and MapSize_ValueNeedsChanging) then
		return MapSize_ValueNeedsChanging(parameter);
	end

	return result;
end

function GameParameters_WriteAuxParameterValues(o, parameter)
	SetupParameters.Config_WriteAuxParameterValues(o, parameter);

	-- Some additional work if the parameter is MapSize.
	if(parameter.ParameterId == "MapSize" and MapSize_ValueChanged) then	
		MapSize_ValueChanged(parameter);
	end
	if(parameter.ParameterId == "Ruleset" and GameSetup_PlayerCountChanged) then
		GameSetup_PlayerCountChanged();
	end
end

-------------------------------------------------------------------------------
-- Hook to determine whether a parameter is relevant to this setup.
-- Parameters not relevant will be completely ignored.
-------------------------------------------------------------------------------
function GetRelevantParameters(o, parameter)

	-- If we have a player id, only care about player parameters.
	if(o.PlayerId ~= nil and parameter.ConfigurationGroup ~= "Player") then
		return false;

	-- If we don't have a player id, ignore any player parameters.
	elseif(o.PlayerId == nil and parameter.ConfigurationGroup == "Player") then
		return false;

	elseif(not GameConfiguration.IsAnyMultiplayer()) then
		return parameter.SupportsSinglePlayer;

	elseif(GameConfiguration.IsHotseat()) then
		return parameter.SupportsHotSeat;

	elseif(GameConfiguration.IsLANMultiplayer()) then
		return parameter.SupportsLANMultiplayer;

	elseif(GameConfiguration.IsInternetMultiplayer()) then
		return parameter.SupportsInternetMultiplayer;

	elseif(GameConfiguration.IsPlayByCloud()) then
		return parameter.SupportsPlayByCloud;
	end
	
	return true;
end


function GameParameters_UI_DefaultCreateParameterDriver(o, parameter, parent)

	if(parent == nil) then
		parent = GetControlStack(parameter.GroupId);
	end

	local control;
	
	-- If there is no parent, don't visualize the control.  This is most likely a player parameter.
	if(parent == nil) then
		return;
	end;

	if(parameter.Domain == "bool") then
		local c = g_BooleanParameterManager:GetInstance();	
		
		-- Store the root control, NOT the instance table.
		g_SortingMap[tostring(c.CheckBox)] = parameter;		
			
		--c.CheckBox:GetTextButton():SetText(parameter.Name);
		c.CheckBox:SetText(parameter.Name);

		
		local tooltip = parameter.Description;
		if(parameter.Invalid) then
			tooltip = string.format("[COLOR_RED]%s[ENDCOLOR][NEWLINE]%s", Locale.Lookup(parameter.InvalidReason), tooltip);
		end

		c.CheckBox:SetToolTipString(tooltip);
		c.CheckBox:RegisterCallback(Mouse.eLClick, function()
			o:SetParameterValue(parameter, not c.CheckBox:IsSelected());
			BroadcastGameConfigChanges();
		end);
		c.CheckBox:ChangeParent(parent);

		control = {
			Control = c,
			UpdateValue = function(value, parameter)
				
				-- Sometimes the parameter name is changed, be sure to update it.
				c.CheckBox:SetText(parameter.Name);

				local tooltip = parameter.Description;
				if(parameter.Invalid) then
					tooltip = string.format("[COLOR_RED]%s[ENDCOLOR][NEWLINE]%s", Locale.Lookup(parameter.InvalidReason), tooltip);
				end

				c.CheckBox:SetToolTipString(tooltip);
				
				-- We have to invalidate the selection state in order
				-- to trick the button to use the right vis state..
				-- Please change this to a real check box in the future...please
				c.CheckBox:SetSelected(not value);
				c.CheckBox:SetSelected(value);
			end,
			SetEnabled = function(enabled)
				c.CheckBox:SetDisabled(not enabled);
			end,
			SetVisible = function(visible)
				c.CheckBox:SetHide(not visible);
			end,
			Destroy = function()
				g_BooleanParameterManager:ReleaseInstance(c);
			end,
		};

	elseif(parameter.Domain == "int" or parameter.Domain == "uint" or parameter.Domain == "text") then
		local c = g_StringParameterManager:GetInstance();		

		-- Store the root control, NOT the instance table.
		g_SortingMap[tostring(c.StringRoot)] = parameter;
				
		c.StringName:SetText(parameter.Name);
		c.StringRoot:SetToolTipString(parameter.Description);
		c.StringEdit:SetEnabled(true);

		local canChangeEnableState = true;

		if(parameter.Domain == "int") then
			c.StringEdit:SetNumberInput(true);
			c.StringEdit:SetMaxCharacters(16);
			c.StringEdit:RegisterCommitCallback(function(textString)
				o:SetParameterValue(parameter, tonumber(textString));	
				BroadcastGameConfigChanges();
			end);
		elseif(parameter.Domain == "uint") then
			c.StringEdit:SetNumberInput(true);
			c.StringEdit:SetMaxCharacters(16);
			c.StringEdit:RegisterCommitCallback(function(textString)
				local value = math.max(tonumber(textString) or 0, 0);
				o:SetParameterValue(parameter, value);	
				BroadcastGameConfigChanges();
			end);
		else
			c.StringEdit:SetNumberInput(false);
			c.StringEdit:SetMaxCharacters(64);
			if UI.HasFeature("TextEntry") == true then
				c.StringEdit:RegisterCommitCallback(function(textString)
					o:SetParameterValue(parameter, textString);	
					BroadcastGameConfigChanges();
				end);
			else
				canChangeEnableState = false;
				c.StringEdit:SetEnabled(false);
			end
		end

		c.StringRoot:ChangeParent(parent);

		control = {
			Control = c,
			UpdateValue = function(value)
				c.StringEdit:SetText(value);
			end,
			SetEnabled = function(enabled)
				if canChangeEnableState then
					c.StringRoot:SetDisabled(not enabled);
					c.StringEdit:SetDisabled(not enabled);
				end
			end,
			SetVisible = function(visible)
				c.StringRoot:SetHide(not visible);
			end,
			Destroy = function()
				g_StringParameterManager:ReleaseInstance(c);
			end,
		};
	elseif (C6GUE.EGHV.IsEnabled and parameter.ParameterId == "GoodyHutFrequency") then			-- configure the Goody Huts frequency slider
	-- elseif (parameter.ParameterId == "GoodyHutFrequency") then			-- configure the Goody Huts frequency slider
		-- print(" *** : Configuring Goody Hut Frequency slider");
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
					c.NumberDisplay:SetText(tostring(value));
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
	elseif (parameter.Values and parameter.Values.Type == "IntRange") then -- Range
		
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
			
			-- This method can get called pretty frequently, try and throttle it.
			if(parameter.Value ~= minimumValue + stepNum) then
				o:SetParameterValue(parameter, minimumValue + stepNum);
				BroadcastGameConfigChanges();
			end
		end);


		control = {
			Control = c,
			UpdateValue = function(value)
				if(value) then
					c.OptionSlider:SetStep(value - minimumValue);
					c.NumberDisplay:SetText(tostring(value));
				end
			end,
			UpdateValues = function(values)
				c.OptionSlider:SetNumSteps(values.MaximumValue - values.MinimumValue);
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
	elseif (parameter.Values and parameter.Array) then -- MultiValue Array
		
		-- NOTE: This is a limited fall-back implementation of the multi-select parameters.

		-- Get the UI instance
		local c = g_PullDownParameterManager:GetInstance();	

		-- Store the root control, NOT the instance table.
		g_SortingMap[tostring(c.Root)] = parameter;

		c.Root:ChangeParent(parent);
		if c.StringName ~= nil then
			c.StringName:SetText(parameter.Name);
		end

		local cache = {};

		control = {
			Control = c,
			Cache = cache,
			UpdateValue = function(value, p)
				local valueText = Locale.Lookup("LOC_SELECTION_NOTHING");
				if(type(value) == "table") then
					local count = #value;
					if (parameter.UxHint ~= nil and parameter.UxHint == "InvertSelection") then
						if(count == 0) then
							valueText = Locale.Lookup("LOC_SELECTION_EVERYTHING");
						elseif(count == #p.Values) then
							valueText = Locale.Lookup("LOC_SELECTION_NOTHING");
						else
							valueText = Locale.Lookup("LOC_SELECTION_CUSTOM", #p.Values-count);
						end
					else
						if(count == 0) then
							valueText = Locale.Lookup("LOC_SELECTION_NOTHING");
						elseif(count == #p.Values) then
							valueText = Locale.Lookup("LOC_SELECTION_EVERYTHING");
						else
							valueText = Locale.Lookup("LOC_SELECTION_CUSTOM", count);
						end
					end
				end

				if(cache.ValueText ~= valueText) then
					local button = c.PullDown:GetButton();
					button:SetText(valueText);
					cache.ValueText = valueText;
				end
			end,
			UpdateValues = function(values)
				-- Do nothing.
			end,
			SetEnabled = function(enabled, parameter)
				c.PullDown:SetDisabled(true);
			end,
			SetVisible = function(visible)
				c.Root:SetHide(not visible);
			end,
			Destroy = function()
				g_PullDownParameterManager:ReleaseInstance(c);
			end,
		};
	elseif (parameter.Values) then -- MultiValue
		
		-- Get the UI instance
		local c = g_PullDownParameterManager:GetInstance();	

		-- Store the root control, NOT the instance table.
		g_SortingMap[tostring(c.Root)] = parameter;

		c.Root:ChangeParent(parent);
		if c.StringName ~= nil then
			c.StringName:SetText(parameter.Name);
		end

		local cache = {};

		control = {
			Control = c,
			Cache = cache,
			UpdateValue = function(value)
				local valueText = value and value.Name or nil;
				local valueDescription = value and value.Description or nil

				-- If value.Description doesn't exist, try value.RawDescription.
				-- This allows dropdowns on Advanced Setup to properly track the user selection.
				if valueDescription == nil and value and value.RawDescription then
					valueDescription = Locale.Lookup(value.RawDescription);
				end

				if(cache.ValueText ~= valueText or cache.ValueDescription ~= valueDescription) then
					local button = c.PullDown:GetButton();
					button:SetText(valueText);
					button:SetToolTipString(valueDescription);
					cache.ValueText = valueText;
					cache.ValueDescription = valueDescription;
				end
			end,
			UpdateValues = function(values)
				local refresh = false;
				local cValues = cache.Values;
				if(cValues and #cValues == #values) then
					for i,v in ipairs(values) do
						local cv = cValues[i];
						if(cv == nil) then
							refresh = true;
							break;
						elseif(cv.QueryId ~= v.QueryId or cv.QueryIndex ~= v.QueryIndex or cv.Invalid ~= v.Invalid or cv.InvalidReason ~= v.InvalidReason) then
							refresh = true;
							break;
						end
					end
				else
					refresh = true;
				end
				
				if(refresh) then
					c.PullDown:ClearEntries();			
					for i,v in ipairs(values) do
						local entry = {};
						c.PullDown:BuildEntry( "InstanceOne", entry );
						entry.Button:SetText(v.Name);
						entry.Button:SetToolTipString(Locale.Lookup(v.RawDescription));

						entry.Button:RegisterCallback(Mouse.eLClick, function()
							o:SetParameterValue(parameter, v);
							BroadcastGameConfigChanges();
						end);
					end
					cache.Values = values;
					c.PullDown:CalculateInternals();
				end
			end,
			SetEnabled = function(enabled, parameter)
				c.PullDown:SetDisabled(not enabled or #parameter.Values <= 1);
			end,
			SetVisible = function(visible)
				c.Root:SetHide(not visible);
			end,
			Destroy = function()
				g_PullDownParameterManager:ReleaseInstance(c);
			end,
		};	
	end

	return control;
end

-- The method used to create a UI control associated with the parameter.
-- Returns either a control or table that will be used in other parameter view related hooks.
function GameParameters_UI_CreateParameter(o, parameter)
	local func = g_ParameterFactories[parameter.ParameterId];

	local control;
	if(func)  then
		control = func(o, parameter);
	else
		control = GameParameters_UI_DefaultCreateParameterDriver(o, parameter);
	end

	o.Controls[parameter.ParameterId] = control;
end


-- Called whenever a parameter is no longer relevant and should be destroyed.
function UI_DestroyParameter(o, parameter)
	local control = o.Controls[parameter.ParameterId];
	if(control) then
		if(control.Destroy) then
			control.Destroy();
		end

		for i,v in ipairs(control) do
			if(v.Destroy) then
				v.Destroy();
			end	
		end
		o.Controls[parameter.ParameterId] = nil;
	end
end

-- Called whenever a parameter's possible values have been updated.
function UI_SetParameterPossibleValues(o, parameter)
	local control = o.Controls[parameter.ParameterId];
	if(control) then
		if(control.UpdateValues) then
			control.UpdateValues(parameter.Values, parameter);
		end

		for i,v in ipairs(control) do
			if(v.UpdateValues) then
				v.UpdateValues(parameter.Values, parameter);
			end	
		end
	end
end

-- Called whenever a parameter's value has been updated.
function UI_SetParameterValue(o, parameter)
	local control = o.Controls[parameter.ParameterId];
	if(control) then
		if(control.UpdateValue) then
			control.UpdateValue(parameter.Value, parameter);
		end

		for i,v in ipairs(control) do
			if(v.UpdateValue) then
				v.UpdateValue(parameter.Value, parameter);
			end	
		end
	end
end

-- Called whenever a parameter is enabled.
function UI_SetParameterEnabled(o, parameter)
	local control = o.Controls[parameter.ParameterId];
	if(control) then
		if(control.SetEnabled) then
			control.SetEnabled(parameter.Enabled, parameter);
		end

		for i,v in ipairs(control) do
			if(v.SetEnabled) then
				v.SetEnabled(parameter.Enabled, parameter);
			end	
		end
	end
end

-- Called whenever a parameter is visible.
function UI_SetParameterVisible(o, parameter)
	local control = o.Controls[parameter.ParameterId];
	if(control) then
		if(control.SetVisible) then
			control.SetVisible(parameter.Visible, parameter);
		end

		for i,v in ipairs(control) do
			if(v.SetVisible) then
				v.SetVisible(parameter.Visible, parameter);
			end	
		end
	end
end

-------------------------------------------------------------------------------
-- Called after a refresh was performed.
-- Update all of the game option stacks and scroll panels.
-------------------------------------------------------------------------------
function GameParameters_UI_AfterRefresh(o)

	-- All parameters are provided with a sort index and are manipulated
	-- in that particular order.
	-- However, destroying and re-creating parameters can get expensive
	-- and thus is avoided.  Because of this, some parameters may be 
	-- created in a bad order.  
	-- It is up to this function to ensure order is maintained as well
	-- as refresh/resize any containers.
	-- FYI: Because of the way we're sorting, we need to delete instances
	-- rather than release them.  This is because releasing merely hides it
	-- but it still gets thrown in for sorting, which is frustrating.
	local sort = function(a,b)
	
		-- ForgUI requires a strict weak ordering sort.

		local ap = g_SortingMap[tostring(a)];
		local bp = g_SortingMap[tostring(b)];

		if(ap == nil and bp ~= nil) then
			return true;
		elseif(ap == nil and bp == nil) then
			return tostring(a) < tostring(b);
		elseif(ap ~= nil and bp == nil) then
			return false;
		else
			return o.Utility_SortFunction(ap, bp);
		end
	end

	local stacks = {	
		{Controls.PrimaryParametersStack},
		{Controls.SecondaryParametersStack,Controls.SecondaryParametersHeader},
		{Controls.GameModeParameterStack,Controls.GameModeParametersHeader},
		{Controls.VictoryParameterStack,Controls.VictoryParametersHeader}
	};

	for i,v in ipairs(stacks) do
		local s = v[1];
		local h = v[2];
		if(s) then
			local children = s:GetChildren();
		
			local hide = true;
			for _,c in ipairs(children) do
				if(c:IsVisible()) then
					hide = false;			
					break;
				end
			end

			if(h) then
				h:SetHide(hide);
			end

			s:SetHide(hide);
		end
	end

	for i,v in ipairs(stacks) do
		local s = v[1];
		if(s and s:IsVisible()) then
			s:SortChildren(sort);
		end
	end

	for i,v in ipairs(stacks) do
		local s = v[1];
		if(s) then
			s:CalculateSize();
			s:ReprocessAnchoring();
		end
	end
	   
	Controls.ParametersStack:CalculateSize();
	Controls.ParametersStack:ReprocessAnchoring();

	if Controls.ParametersScrollPanel then
		Controls.ParametersScrollPanel:CalculateInternalSize();
	end
end

-------------------------------------------------------------------------------
-- Perform any additional operations on relevant parameters.
-- In this case, adjust the parameter group so that they are sorted properly.
-------------------------------------------------------------------------------
function GameParameters_PostProcess(o, parameter)
	
	-- Move all groups into 1 singular group for sorting purposes.
	--local triage = {
		--["BasicGameOptions"] = "GameOptions",
		--["BasicMapOptions"] = "GameOptions",
		--["MapOptions"] = "GameOptions",
	--};
--
	--parameter.GroupId = triage[parameter.GroupId] or parameter.GroupId;
end

-- Generate the game setup parameters and populate the UI.
function BuildGameSetup(createParameterFunc)

	-- If BuildGameSetup is called twice, call HideGameSetup to reset things.
	if(g_GameParameters) then
		HideGameSetup();
	end

	print("Building Game Setup");

	g_GameParameters = SetupParameters.new();
	g_GameParameters.Config_EndWrite = Parameters_Config_EndWrite;
	g_GameParameters.Parameter_GetRelevant = GetRelevantParameters;
	g_GameParameters.Parameter_PostProcess = GameParameters_PostProcess;
	g_GameParameters.Parameter_SyncAuxConfigurationValues = GameParameters_SyncAuxConfigurationValues;
	g_GameParameters.Config_WriteAuxParameterValues = GameParameters_WriteAuxParameterValues;
	g_GameParameters.UI_BeforeRefresh = UI_BeforeRefresh;
	g_GameParameters.UI_AfterRefresh = GameParameters_UI_AfterRefresh;
	g_GameParameters.UI_CreateParameter = createParameterFunc ~= nil and createParameterFunc or GameParameters_UI_CreateParameter;
	g_GameParameters.UI_DestroyParameter = UI_DestroyParameter;
	g_GameParameters.UI_SetParameterPossibleValues = UI_SetParameterPossibleValues;
	g_GameParameters.UI_SetParameterValue = UI_SetParameterValue;
	g_GameParameters.UI_SetParameterEnabled = UI_SetParameterEnabled;
	g_GameParameters.UI_SetParameterVisible = UI_SetParameterVisible;

	-- Optional overrides.
	if(GameParameters_FilterValues) then
		g_GameParameters.Default_Parameter_FilterValues = g_GameParameters.Parameter_FilterValues;
		g_GameParameters.Parameter_FilterValues = GameParameters_FilterValues;
	end

	g_GameParameters:Initialize();
	g_GameParameters:FullRefresh();
end

-- Generate the game setup parameters and populate the UI.
function BuildHeadlessGameSetup()

	-- If BuildGameSetup is called twice, call HideGameSetup to reset things.
	if(g_GameParameters) then
		HideGameSetup();
	end

	print("Building Headless Game Setup");

	g_GameParameters = SetupParameters.new();
	g_GameParameters.Config_EndWrite = Parameters_Config_EndWrite;
	g_GameParameters.Parameter_GetRelevant = GetRelevantParameters;
	g_GameParameters.Parameter_PostProcess = GameParameters_PostProcess;
	g_GameParameters.Parameter_SyncAuxConfigurationValues = GameParameters_SyncAuxConfigurationValues;
	g_GameParameters.Config_WriteAuxParameterValues = GameParameters_WriteAuxParameterValues;

	g_GameParameters.UpdateVisualization = function() end
	g_GameParameters.UI_AfterRefresh = nil;
	g_GameParameters.UI_CreateParameter = nil;
	g_GameParameters.UI_DestroyParameter = nil;
	g_GameParameters.UI_SetParameterPossibleValues = nil;
	g_GameParameters.UI_SetParameterValue = nil;
	g_GameParameters.UI_SetParameterEnabled = nil;
	g_GameParameters.UI_SetParameterVisible = nil;

	-- Optional overrides.
	if(GameParameters_FilterValues) then
		g_GameParameters.Default_Parameter_FilterValues = g_GameParameters.Parameter_FilterValues;
		g_GameParameters.Parameter_FilterValues = GameParameters_FilterValues;
	end

	g_GameParameters:Initialize();
end

-- ===========================================================================
-- Hide game setup parameters.
function HideGameSetup(hideParameterFunc)
	print("Hiding Game Setup");

	-- Shutdown and nil out the game parameters.
	if(g_GameParameters) then
		g_GameParameters:Shutdown();
		g_GameParameters = nil;
	end

	-- Reset all UI instances.
	if(hideParameterFunc == nil) then
		g_BooleanParameterManager:ResetInstances();
		g_PullDownParameterManager:ResetInstances();
		g_SliderParameterManager:ResetInstances();
		g_StringParameterManager:ResetInstances();
		g_ButtonParameterManager:ResetInstances();
	else
		hideParameterFunc();
	end
end

-- ===========================================================================
function MapSize_ValueNeedsChanging(p)
	local results = CachedQuery("SELECT * from MapSizes where Domain = ? and MapSizeType = ? LIMIT 1", p.Value.Domain, p.Value.Value);

	local minPlayers = 2;
	local maxPlayers = 2;
	local defPlayers = 2;
	local minCityStates = 0;
	local maxCityStates = 0;
	local defCityStates = 0;

	-- C6GUE : define values for the Natural Wonders slider(s); these will be used if ENWS is present
	local minNaturalWonders = 0;
	local maxNaturalWonders = 0;
	local defNaturalWonders = 0;

	if(results) then
		for i, v in ipairs(results) do
			minPlayers = v.MinPlayers;
			maxPlayers = v.MaxPlayers;
			defPlayers = v.DefaultPlayers;
			minCityStates = v.MinCityStates;
			maxCityStates = v.MaxCityStates;
			defCityStates = v.DefaultCityStates;
			-- if (C6GUE.ENWS.IsEnabled) then									-- C6GUE : fetch current values here if ENWS is present
			if (v.MinNaturalWonders ~= nil) then minNaturalWonders = v.MinNaturalWonders; end
			if (v.MaxNaturalWonders ~= nil) then maxNaturalWonders = v.MaxNaturalWonders; end
			if (v.DefaultNaturalWonders ~= nil) then defNaturalWonders = v.DefaultNaturalWonders; end
			-- end
		end
	end

	-- TODO: Add Min/Max city states, set defaults.
	if(MapConfiguration.GetMinMajorPlayers() ~= minPlayers) then
		SetupParameters_Log("Min Major Players: " .. MapConfiguration.GetMinMajorPlayers() .. " should be " .. minPlayers);
		return true;
	elseif(MapConfiguration.GetMaxMajorPlayers() ~= maxPlayers) then
		SetupParameters_Log("Max Major Players: " .. MapConfiguration.GetMaxMajorPlayers() .. " should be " .. maxPlayers);
		return true;
	elseif(MapConfiguration.GetMinMinorPlayers() ~= minCityStates) then
		SetupParameters_Log("Min Minor Players: " .. MapConfiguration.GetMinMinorPlayers() .. " should be " .. minCityStates);
		return true;
	elseif(MapConfiguration.GetMaxMinorPlayers() ~= maxCityStates) then
		SetupParameters_Log("Max Minor Players: " .. MapConfiguration.GetMaxMinorPlayers() .. " should be " .. maxCityStates);
		return true;
	-- C6GUE : Additional elseifs to set parameters for the Natural Wonders slider(s) when ENWS is present
	-- elseif(C6GUE.ENWS.IsEnabled and MapConfiguration.GetValue("MAP_MIN_NATURAL_WONDERS") ~= minNaturalWonders) then
	elseif(MapConfiguration.GetValue("MAP_MIN_NATURAL_WONDERS") ~= minNaturalWonders) then
		if (MapConfiguration.GetValue("MAP_MIN_NATURAL_WONDERS") == nil) then
			MapConfiguration.SetValue("MAP_MIN_NATURAL_WONDERS", minNaturalWonders);
		end
		SetupParameters_Log("Min Natural Wonders: ", MapConfiguration.GetValue("MAP_MIN_NATURAL_WONDERS"), " should be ", minNaturalWonders);
		return true;
	-- elseif(C6GUE.ENWS.IsEnabled and MapConfiguration.GetValue("MAP_MAX_NATURAL_WONDERS") ~= maxNaturalWonders) then
	elseif(MapConfiguration.GetValue("MAP_MAX_NATURAL_WONDERS") ~= maxNaturalWonders) then
		if (MapConfiguration.GetValue("MAP_MAX_NATURAL_WONDERS") == nil) then
			MapConfiguration.SetValue("MAP_MAX_NATURAL_WONDERS", maxNaturalWonders);
		end
		SetupParameters_Log("Max Natural Wonders: ", MapConfiguration.GetValue("MAP_MAX_NATURAL_WONDERS"), " should be ", maxNaturalWonders);
		return true;
	end

	return false;
end

function MapSize_ValueChanged(p)
	SetupParameters_Log("MAP SIZE CHANGED");

	-- The map size has changed!
	-- Adjust the number of players to match the default players of the map size.
	local results = CachedQuery("SELECT * from MapSizes where Domain = ? and MapSizeType = ? LIMIT 1", p.Value.Domain, p.Value.Value);

	local minPlayers = 2;
	local maxPlayers = 2;
	local defPlayers = 2;
	local minCityStates = 0;
	local maxCityStates = 0;
	local defCityStates = 0;

	-- C6GUE : define values for the Natural Wonders slider(s); these will be used if ENWS is present
	local minNaturalWonders = 0;
	local maxNaturalWonders = 0;
	local defNaturalWonders = 0;

	if(results) then
		for i, v in ipairs(results) do
			minPlayers = v.MinPlayers;
			maxPlayers = v.MaxPlayers;
			defPlayers = v.DefaultPlayers;
			minCityStates = v.MinCityStates;
			maxCityStates = v.MaxCityStates;
			defCityStates = v.DefaultCityStates;
			-- if (C6GUE.ENWS.IsEnabled) then									-- C6GUE : fetch current values here if ENWS is present
			if (v.MinNaturalWonders ~= nil) then minNaturalWonders = v.MinNaturalWonders; end
			if (v.MaxNaturalWonders ~= nil) then maxNaturalWonders = v.MaxNaturalWonders; end
			if (v.DefaultNaturalWonders ~= nil) then defNaturalWonders = v.DefaultNaturalWonders; end
			-- end
		end
	end

	MapConfiguration.SetMinMajorPlayers(minPlayers);
	MapConfiguration.SetMaxMajorPlayers(maxPlayers);
	MapConfiguration.SetMinMinorPlayers(minCityStates);
	MapConfiguration.SetMaxMinorPlayers(maxCityStates);
	GameConfiguration.SetValue("CITY_STATE_COUNT", defCityStates);
	-- if (C6GUE.ENWS.IsEnabled) then				-- C6GUE : Set new values for the Natural Wonders slider(s) when ENWS is present
		MapConfiguration.SetValue("MAP_MIN_NATURAL_WONDERS", minNaturalWonders);
		MapConfiguration.SetValue("MAP_MAX_NATURAL_WONDERS", maxNaturalWonders);
		GameConfiguration.SetValue("NATURAL_WONDER_COUNT", defNaturalWonders);
	-- end

	-- Clamp participating player count in network multiplayer so we only ever auto-spawn players up to the supported limit. 
	local mpMaxSupportedPlayers = 8; -- The officially supported number of players in network multiplayer games.
	local participatingCount = defPlayers + GameConfiguration.GetHiddenPlayerCount();
	if GameConfiguration.IsNetworkMultiplayer() or GameConfiguration.IsPlayByCloud() then
		participatingCount = math.clamp(participatingCount, 0, mpMaxSupportedPlayers);
	end

	SetupParameters_Log("Setting participating player count to " .. tonumber(participatingCount));
	local playerCountChange = GameConfiguration.SetParticipatingPlayerCount(participatingCount);
	Network.BroadcastGameConfig(true);


	-- NOTE: This used to only be called if playerCountChange was non-zero.
	-- This needs to be called more frequently than that because each player slot entry's add/remove button
	-- needs to be potentially updated to reflect the min/max player constraints.
	if(GameSetup_PlayerCountChanged) then
		GameSetup_PlayerCountChanged();
	end
end

function GetGameModeInfo(gameModeType)
	local item_query : string = "SELECT * FROM GameModeItems where GameModeType = ? ORDER BY SortIndex";
	local item_results : table = CachedQuery(item_query, gameModeType);

	return item_results[1];
end

--[[ =========================================================================
	end modified GameSetupLogic.lua frontend script
=========================================================================== ]]
