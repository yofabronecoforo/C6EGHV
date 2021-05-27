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
	begin modified HostGame.lua frontend script
=========================================================================== ]]
-- print("C6GUE: Loading modified HostGame.lua . . .");

-------------------------------------------------
-- Multiplayer Host Game Screen
-------------------------------------------------
include("LobbyTypes");		--MPLobbyTypes
include("ButtonUtilities");
include("InstanceManager");
include("PlayerSetupLogic");
include("PopupDialog");
include("Civ6Common");

-- C6GUE shared components
-- include("C6GUE_Common");
-- ExposedMembers.C6GUE = ExposedMembers.C6GUE or {};
-- C6GUE = ExposedMembers.C6GUE;
-- C6GUE.TestFunction();

-- ===========================================================================
--	CONSTANTS
-- ===========================================================================
local LOC_GAME_SETUP		:string = Locale.Lookup("LOC_MULTIPLAYER_GAME_SETUP");
local LOC_STAGING_ROOM		:string = Locale.ToUpper(Locale.Lookup("LOC_MULTIPLAYER_STAGING_ROOM"));
local RELOAD_CACHE_ID		:string = "HostGame";

local MIN_SCREEN_Y			:number = 768;
local SCREEN_OFFSET_Y		:number = 20;
local MIN_SCREEN_OFFSET_Y	:number = -93;
--local SCROLL_SIZE_DEFAULT	:number = 620;
--local SCROLL_SIZE_IN_SESSION:number = 662;

-- ===========================================================================
--	Globals
-- ===========================================================================
local m_lobbyModeName:string = MPLobbyTypes.STANDARD_INTERNET;
local m_shellTabIM:table = InstanceManager:new("ShellTab", "TopControl", Controls.ShellTabs);
local m_kPopupDialog:table;
local m_pCityStateWarningPopup:table = PopupDialog:new("CityStateWarningPopup");


function OnSetParameterValues(pid: string, values: table)
	local indexed_values = {};
	if(values) then
		for i,v in ipairs(values) do
			indexed_values[v] = true;
		end
	end

	if(g_GameParameters) then
		local parameter = g_GameParameters.Parameters and g_GameParameters.Parameters[pid] or nil;
		if(parameter and parameter.Values ~= nil) then
			local resolved_values = {};
			for i,v in ipairs(parameter.Values) do
				if(indexed_values[v.Value]) then
					table.insert(resolved_values, v);
				end
			end		
			g_GameParameters:SetParameterValue(parameter, resolved_values);
			Network.BroadcastGameConfig();	
		end
	end	
end

-- ===========================================================================
function OnSetParameterValue(pid: string, value: number)
	if(g_GameParameters) then
		local kParameter: table = g_GameParameters.Parameters and g_GameParameters.Parameters[pid] or nil;
		if(kParameter and kParameter.Value ~= nil) then	
            g_GameParameters:SetParameterValue(kParameter, value);
			Network.BroadcastGameConfig();	
		end
	end	
end

--[[ =========================================================================
	This driver is for launching the picker indicated by parameter in a separate window
		Since there were only 2 lines that differed between the various picker drivers, we've condensed them here
		Any new picker(s) can be handled by adding new and/or modifing existing (else)if statement(s) below
=========================================================================== ]]
function CreatePickerDriverByParameter(o, parameter, parent)

	if(parent == nil) then
		parent = GetControlStack(parameter.GroupId);
	end
			
	-- Get the UI instance
	local c :object = g_ButtonParameterManager:GetInstance();	

	local parameterId = parameter.ParameterId;
	local button = c.Button;
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
	elseif (parameterId == "GoodyHutConfig" and C6GUE.EGHV.IsEnabled) then							-- C6GUE : EGHV : Goody Hut picker
		button:RegisterCallback( Mouse.eLClick, function()
			LuaEvents.GoodyHutPicker_Initialize(o.Parameters[parameterId]);
			Controls.GoodyHutPicker:SetHide(false);
		end);
	elseif (parameterId == "NaturalWonders" and C6GUE.ENWS.IsEnabled) then							-- C6GUE : ENWS : Natural Wonder picker
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
		
			if(valueText == nil) then
				if(value == nil) then
					if (parameter.UxHint ~= nil and parameter.UxHint == "InvertSelection") then
						valueText = "LOC_SELECTION_EVERYTHING";
						-- EGHV : Display count for selections of "everything"
						valueAmount = #p.Values;
					else
						valueText = "LOC_SELECTION_NOTHING";
					end
				elseif(type(value) == "table") then
					local count = #value;
					if (parameter.UxHint ~= nil and parameter.UxHint == "InvertSelection") then
						if(count == 0) then
							valueText = "LOC_SELECTION_EVERYTHING";
							-- EGHV : Display count for selections of "everything"
							valueAmount = #p.Values;
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
							-- EGHV : Display count for selections of "everything"
							valueAmount = #p.Values;
						else
							valueText = "LOC_SELECTION_CUSTOM";
							valueAmount = count;
						end
					end
				end
			end				

			if(cache.ValueText ~= valueText) or (cache.ValueAmount ~= valueAmount) then
				local button = c.Button;			
				button:LocalizeAndSetText(valueText, valueAmount);
				cache.ValueText = valueText;
				cache.ValueAmount = valueAmount;
				-- C6GUE : update button tooltip text
				button:SetToolTipString(parameter.Description .. UpdateButtonToolTip(parameterId));
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

-- ===========================================================================
-- * DEPRECATED * This driver is for launching a multi-select option in a separate window.
-- ===========================================================================
-- function CreateMultiSelectWindowDriver(o, parameter, parent)

-- 	if(parent == nil) then
-- 		parent = GetControlStack(parameter.GroupId);
-- 	end
			
-- 	-- Get the UI instance
-- 	local c :object = g_ButtonParameterManager:GetInstance();	

-- 	local parameterId = parameter.ParameterId;
-- 	local button = c.Button;
-- 	button:RegisterCallback( Mouse.eLClick, function()
-- 		LuaEvents.MultiSelectWindow_Initialize(o.Parameters[parameterId]);
-- 		Controls.MultiSelectWindow:SetHide(false);
-- 	end);

-- 	-- Store the root control, NOT the instance table.
-- 	g_SortingMap[tostring(c.ButtonRoot)] = parameter;

-- 	c.ButtonRoot:ChangeParent(parent);
-- 	if c.StringName ~= nil then
-- 		c.StringName:SetText(parameter.Name);
-- 	end

-- 	local cache = {};

-- 	local kDriver :table = {
-- 		Control = c,
-- 		Cache = cache,
-- 		UpdateValue = function(value, p)
-- 			local valueText = value and value.Name or nil;
-- 			local valueAmount :number = 0;
		
-- 			if(valueText == nil) then
-- 				if(value == nil) then
-- 					if (parameter.UxHint ~= nil and parameter.UxHint == "InvertSelection") then
-- 						valueText = "LOC_SELECTION_EVERYTHING";
-- 					else
-- 						valueText = "LOC_SELECTION_NOTHING";
-- 					end
-- 				elseif(type(value) == "table") then
-- 					local count = #value;
-- 					if (parameter.UxHint ~= nil and parameter.UxHint == "InvertSelection") then
-- 						if(count == 0) then
-- 							valueText = "LOC_SELECTION_EVERYTHING";
-- 						elseif(count == #p.Values) then
-- 							valueText = "LOC_SELECTION_NOTHING";
-- 						else
-- 							valueText = "LOC_SELECTION_CUSTOM";
-- 							valueAmount = #p.Values - count;
-- 						end
-- 					else
-- 						if(count == 0) then
-- 							valueText = "LOC_SELECTION_NOTHING";
-- 						elseif(count == #p.Values) then
-- 							valueText = "LOC_SELECTION_EVERYTHING";
-- 						else
-- 							valueText = "LOC_SELECTION_CUSTOM";
-- 							valueAmount = count;
-- 						end
-- 					end
-- 				end
-- 			end				

-- 			c.Button:SetToolTipString(parameter.Description);

-- 			if(cache.ValueText ~= valueText) or (cache.ValueAmount ~= valueAmount) then
-- 				local button = c.Button;			
-- 				button:LocalizeAndSetText(valueText, valueAmount);
-- 				cache.ValueText = valueText;
-- 				cache.ValueAmount = valueAmount;
-- 			end
-- 		end,
-- 		UpdateValues = function(values, p) 
-- 			-- Values are refreshed when the window is open.
-- 		end,
-- 		SetEnabled = function(enabled, p)
-- 			c.Button:SetDisabled(not enabled or #p.Values <= 1);
-- 		end,
-- 		SetVisible = function(visible)
-- 			c.ButtonRoot:SetHide(not visible);
-- 		end,
-- 		Destroy = function()
-- 			g_ButtonParameterManager:ReleaseInstance(c);
-- 		end,
-- 	};	

-- 	return kDriver;
-- end

-- ===========================================================================
-- * DEPRECATED * This driver is for launching the city-state picker in a separate window.
-- ===========================================================================
-- function CreateCityStatePickerDriver(o, parameter, parent)

-- 	if(parent == nil) then
-- 		parent = GetControlStack(parameter.GroupId);
-- 	end
			
-- 	-- Get the UI instance
-- 	local c :object = g_ButtonParameterManager:GetInstance();	

-- 	local parameterId = parameter.ParameterId;
-- 	local button = c.Button;
-- 	button:RegisterCallback( Mouse.eLClick, function()
-- 		LuaEvents.CityStatePicker_Initialize(o.Parameters[parameterId], g_GameParameters);
-- 		Controls.CityStatePicker:SetHide(false);
-- 	end);

-- 	-- Store the root control, NOT the instance table.
-- 	g_SortingMap[tostring(c.ButtonRoot)] = parameter;

-- 	c.ButtonRoot:ChangeParent(parent);
-- 	if c.StringName ~= nil then
-- 		c.StringName:SetText(parameter.Name);
-- 	end

-- 	local cache = {};

-- 	local kDriver :table = {
-- 		Control = c,
-- 		Cache = cache,
-- 		UpdateValue = function(value, p)
-- 			local valueText = value and value.Name or nil;
-- 			local valueAmount :number = 0;
		
-- 			if(valueText == nil) then
-- 				if(value == nil) then
-- 					if (parameter.UxHint ~= nil and parameter.UxHint == "InvertSelection") then
-- 						valueText = "LOC_SELECTION_EVERYTHING";
-- 					else
-- 						valueText = "LOC_SELECTION_NOTHING";
-- 					end
-- 				elseif(type(value) == "table") then
-- 					local count = #value;
-- 					if (parameter.UxHint ~= nil and parameter.UxHint == "InvertSelection") then
-- 						if(count == 0) then
-- 							valueText = "LOC_SELECTION_EVERYTHING";
-- 						elseif(count == #p.Values) then
-- 							valueText = "LOC_SELECTION_NOTHING";
-- 						else
-- 							valueText = "LOC_SELECTION_CUSTOM";
-- 							valueAmount = #p.Values - count;
-- 						end
-- 					else
-- 						if(count == 0) then
-- 							valueText = "LOC_SELECTION_NOTHING";
-- 						elseif(count == #p.Values) then
-- 							valueText = "LOC_SELECTION_EVERYTHING";
-- 						else
-- 							valueText = "LOC_SELECTION_CUSTOM";
-- 							valueAmount = count;
-- 						end
-- 					end
-- 				end
-- 			end				

-- 			c.Button:SetToolTipString(parameter.Description);

-- 			if(cache.ValueText ~= valueText) or (cache.ValueAmount ~= valueAmount) then
-- 				local button = c.Button;			
-- 				button:LocalizeAndSetText(valueText, valueAmount);
-- 				cache.ValueText = valueText;
-- 				cache.ValueAmount = valueAmount;
-- 			end
-- 		end,
-- 		UpdateValues = function(values, p) 
-- 			-- Values are refreshed when the window is open.
-- 		end,
-- 		SetEnabled = function(enabled, p)
-- 			c.Button:SetDisabled(not enabled or #p.Values <= 1);
-- 		end,
-- 		SetVisible = function(visible)
-- 			c.ButtonRoot:SetHide(not visible);
-- 		end,
-- 		Destroy = function()
-- 			g_ButtonParameterManager:ReleaseInstance(c);
-- 		end,
-- 	};	

-- 	return kDriver;
-- end

-- ===========================================================================
-- * DEPRECATED * This driver is for launching the leader picker in a separate window.
-- ===========================================================================
-- function CreateLeaderPickerDriver(o, parameter, parent)

-- 	if(parent == nil) then
-- 		parent = GetControlStack(parameter.GroupId);
-- 	end
			
-- 	-- Get the UI instance
-- 	local c :object = g_ButtonParameterManager:GetInstance();	

-- 	local parameterId:string = parameter.ParameterId;
-- 	local button:table = c.Button;
-- 	button:RegisterCallback( Mouse.eLClick, function()
-- 		LuaEvents.LeaderPicker_Initialize(o.Parameters[parameterId], g_GameParameters);
-- 		Controls.LeaderPicker:SetHide(false);
-- 	end);
-- 	button:SetToolTipString(parameter.Description);

-- 	-- Store the root control, NOT the instance table.
-- 	g_SortingMap[tostring(c.ButtonRoot)] = parameter;

-- 	c.ButtonRoot:ChangeParent(parent);
-- 	if c.StringName ~= nil then
-- 		c.StringName:SetText(parameter.Name);
-- 	end

-- 	local cache:table = {};

-- 	local kDriver :table = {
-- 		Control = c,
-- 		Cache = cache,
-- 		UpdateValue = function(value, p)
-- 			local valueText = value and value.Name or nil;
-- 			local valueAmount :number = 0;

-- 			-- Remove random leaders from the Values table that is used to determine number of leaders selected
-- 			for i = #p.Values, 1, -1 do
-- 				local kItem:table = p.Values[i];
-- 				if kItem.Value == "RANDOM" or kItem.Value == "RANDOM_POOL1" or kItem.Value == "RANDOM_POOL2" then
-- 					table.remove(p.Values, i);
-- 				end
-- 			end
		
-- 			if(valueText == nil) then
-- 				if(value == nil) then
-- 					if (parameter.UxHint ~= nil and parameter.UxHint == "InvertSelection") then
-- 						valueText = "LOC_SELECTION_EVERYTHING";
-- 					else
-- 						valueText = "LOC_SELECTION_NOTHING";
-- 					end
-- 				elseif(type(value) == "table") then
-- 					local count = #value;
-- 					if (parameter.UxHint ~= nil and parameter.UxHint == "InvertSelection") then
-- 						if(count == 0) then
-- 							valueText = "LOC_SELECTION_EVERYTHING";
-- 						elseif(count == #p.Values) then
-- 							valueText = "LOC_SELECTION_NOTHING";
-- 						else
-- 							valueText = "LOC_SELECTION_CUSTOM";
-- 							valueAmount = #p.Values - count;
-- 						end
-- 					else
-- 						if(count == 0) then
-- 							valueText = "LOC_SELECTION_NOTHING";
-- 						elseif(count == #p.Values) then
-- 							valueText = "LOC_SELECTION_EVERYTHING";
-- 						else
-- 							valueText = "LOC_SELECTION_CUSTOM";
-- 							valueAmount = count;
-- 						end
-- 					end
-- 				end
-- 			end				

-- 			if(cache.ValueText ~= valueText) or (cache.ValueAmount ~= valueAmount) then
-- 				local button:table = c.Button;			
-- 				button:LocalizeAndSetText(valueText, valueAmount);
-- 				cache.ValueText = valueText;
-- 				cache.ValueAmount = valueAmount;
-- 			end
-- 		end,
-- 		UpdateValues = function(values, p) 
-- 			-- Values are refreshed when the window is open.
-- 		end,
-- 		SetEnabled = function(enabled, p)
-- 			c.Button:SetDisabled(not enabled or #p.Values <= 1);
-- 		end,
-- 		SetVisible = function(visible)
-- 			c.ButtonRoot:SetHide(not visible);
-- 		end,
-- 		Destroy = function()
-- 			g_ButtonParameterManager:ReleaseInstance(c);
-- 		end,
-- 	};	

-- 	return kDriver;
-- end

function GameParameters_UI_CreateParameterDriver(o, parameter, ...)
	-- EGHV : the various picker drivers have been condensed into CreatePickerDriverByParameter()
	local parameterId = parameter.ParameterId;
	if(parameterId == "CityStates" or parameterId == "LeaderPool1" or parameterId == "LeaderPool2") then -- or parameterId == "GoodyHutConfig") then
		if GameConfiguration.IsWorldBuilderEditor() then
			return nil;
		end
		return CreatePickerDriverByParameter(o, parameter);
	elseif(parameterId == "GoodyHutConfig" and C6GUE.EGHV.IsEnabled) then
		if GameConfiguration.IsWorldBuilderEditor() then
			return nil;
		end
		return CreatePickerDriverByParameter(o, parameter);
	elseif(parameterId == "NaturalWonders" and C6GUE.ENWS.IsEnabled) then
		if GameConfiguration.IsWorldBuilderEditor() then
			return nil;
		end
		return CreatePickerDriverByParameter(o, parameter);
	elseif(parameter.Array) then								-- fallback for generic multi-select window; no WorldBuilder check
		-- return CreateMultiSelectWindowDriver(o, parameter);
		return CreatePickerDriverByParameter(o, parameter);
	else
		return GameParameters_UI_DefaultCreateParameterDriver(o, parameter, ...);
	end
end

-- * DEPRECATED *
-- function GameParameters_UI_CreateParameterDriver(o, parameter, parent, ...)
-- 	if(parameter.ParameterId == "CityStates") then
-- 		return CreateCityStatePickerDriver(o, parameter);
-- 	elseif(parameter.ParameterId == "LeaderPool1" or parameter.ParameterId == "LeaderPool2") then
-- 		return CreateLeaderPickerDriver(o, parameter);
-- 	elseif(parameter.Array) then
-- 		return CreateMultiSelectWindowDriver(o, parameter);
-- 	else
-- 		return GameParameters_UI_DefaultCreateParameterDriver(o, parameter, parent, ...);
-- 	end
-- end

-- The method used to create a UI control associated with the parameter.
-- Returns either a control or table that will be used in other parameter view related hooks.
function GameParameters_UI_CreateParameter(o, parameter)
	local func = g_ParameterFactories[parameter.ParameterId];

	local control;
	if(func)  then
		control = func(o, parameter);
	else
		control = GameParameters_UI_CreateParameterDriver(o, parameter);
	end

	o.Controls[parameter.ParameterId] = control;
end


-- ===========================================================================
-- Perform validation on setup parameters.
-- ===========================================================================
function UI_PostRefreshParameters()
	-- Most of the options self-heal due to the setup parameter logic.
	-- However, player options are allowed to be in an 'invalid' state for UI
	-- This way, instead of hiding/preventing the user from selecting an invalid player
	-- we can allow it, but display an error message explaining why it's invalid.

	-- This is ily used to present ownership errors and custom constraint errors.
	Controls.SaveConfigButton:SetDisabled(false);
	Controls.ConfirmButton:SetDisabled(false);
	Controls.ConfirmButton:SetToolTipString(nil);

	local game_err = GetGameParametersError();
	if(game_err) then
		Controls.SaveConfigButton:SetDisabled(true);
		Controls.ConfirmButton:SetDisabled(true);
		Controls.ConfirmButton:LocalizeAndSetToolTip("LOC_SETUP_PARAMETER_ERROR");

	end
end

-- ===========================================================================
--	Input Handler
-- ===========================================================================
function OnInputHandler( uiMsg, wParam, lParam )
	if uiMsg == KeyEvents.KeyUp then
		if wParam == Keys.VK_ESCAPE then
			LuaEvents.Multiplayer_ExitShell();
		end
	end
	return true;
end

-- ===========================================================================
function OnShow()
	
	RebuildPlayerParameters(true);
	GameSetup_RefreshParameters();
	


	-- Hide buttons if we're already in a game
	local isInSession:boolean = Network.IsInSession();
	Controls.ModsButton:SetHide(isInSession);
	Controls.ConfirmButton:SetHide(isInSession);
	
	ShowDefaultButton();
	ShowLoadConfigButton();
	Controls.LoadButton:SetHide(not GameConfiguration.IsHotseat() or isInSession);

	--[[
	local sizeY:number = isInSession and SCROLL_SIZE_IN_SESSION or SCROLL_SIZE_DEFAULT;
	Controls.DecoGrid:SetSizeY(sizeY);
	Controls.DecoBorder:SetSizeY(sizeY + 6);
	Controls.ParametersScrollPanel:SetSizeY(sizeY - 2);
	--]]

	RealizeShellTabs();
end

-- ===========================================================================
function ShowDefaultButton()
	local showDefaultButton = not GameConfiguration.IsSavedGame()
								and not Network.IsInSession();

	Controls.DefaultButton:SetHide(not showDefaultButton);
end

function ShowLoadConfigButton()
	local showLoadConfig = not GameConfiguration.IsSavedGame()
								and not Network.IsInSession();

	Controls.LoadConfigButton:SetHide(not showLoadConfig);
end

-- ===========================================================================
function OnHide( isHide, isInit )
	ReleasePlayerParameters();
	HideGameSetup();
end

-------------------------------------------------
-- Restore Default Settings Button Handler
-------------------------------------------------
function OnDefaultButton()
	print("Resetting Setup Parameters");

	-- Get the game name since we wish to persist this.
	local gameMode = GameModeTypeForMPLobbyType(m_lobbyModeName);
	local gameName = GameConfiguration.GetValue("GAME_NAME");
	GameConfiguration.SetToDefaults(gameMode);
	GameConfiguration.RegenerateSeeds();

	-- Kludge:  SetToDefaults assigns the ruleset to be standard.
	-- Clear this value so that the setup parameters code can guess the best 
	-- default.
	GameConfiguration.SetValue("RULESET", nil);
	
	-- Only assign GAME_NAME if the value is valid.
	if(gameName and #gameName > 0) then
		GameConfiguration.SetValue("GAME_NAME", gameName);
	end
	return GameSetup_RefreshParameters();
end

-------------------------------------------------------------------------------
-- Event Listeners
-------------------------------------------------------------------------------
Events.FinishedGameplayContentConfigure.Add(function(result)
	if(ContextPtr and not ContextPtr:IsHidden() and result.Success) then
		GameSetup_RefreshParameters();
	end
end);

-------------------------------------------------
-- Mods Setting Button Handler
-- TODO: Remove this, and place contents mods screen into the ParametersStack (in the SecondaryParametersStack, or in its own ModsStack)
-------------------------------------------------
function ModsButtonClick()
	UIManager:QueuePopup(Controls.ModsMenu, PopupPriority.Current);	
end


-- ===========================================================================
--	Host Game Button Handler
-- ===========================================================================
function OnConfirmClick()
	-- UINETTODO - Need to be able to support coming straight to this screen as a dedicated server
	--SERVER_TYPE_STEAM_DEDICATED,	// Steam Game Server, host does not play.

	local serverType = ServerTypeForMPLobbyType(m_lobbyModeName);
	print("OnConfirmClick() m_lobbyModeName: " .. tostring(m_lobbyModeName) .. " serverType: " .. tostring(serverType));
	
	-- GAME_NAME must not be empty.
	local gameName = GameConfiguration.GetValue("GAME_NAME");	
	if(gameName == nil or #gameName == 0) then
		GameConfiguration.SetToDefaultGameName();
	end
	
	if AreNoCityStatesInGame() or AreAllCityStateSlotsUsed() then
		HostGame(serverType);
	else
		m_pCityStateWarningPopup:ShowOkCancelDialog(Locale.Lookup("LOC_CITY_STATE_PICKER_TOO_FEW_WARNING"), function() HostGame(serverType); end);
	end
end

-- ===========================================================================
function HostGame(serverType:number)
	Network.HostGame(serverType);
end

-- ===========================================================================
function AreNoCityStatesInGame()
	local kParameters:table = g_GameParameters["Parameters"];
	return (kParameters["CityStates"] == nil);
end

-- ===========================================================================
function AreAllCityStateSlotsUsed()
	
	local kParameters		:table = g_GameParameters["Parameters"];
	local cityStateSlots	:number = kParameters["CityStateCount"].Value;
	local totalCityStates	:number = #kParameters["CityStates"].AllValues;
	local excludedCityStates:number = kParameters["CityStates"].Value ~= nil and #kParameters["CityStates"].Value or 0;

	if (totalCityStates - excludedCityStates) < cityStateSlots then
		return false;
	end

	return true;
end

-------------------------------------------------
-- Load Configuration Button Handler
-------------------------------------------------
function OnLoadConfig()
	local serverType = ServerTypeForMPLobbyType(m_lobbyModeName);
	LuaEvents.HostGame_SetLoadGameServerType(serverType);
	local kParameters = {};
	kParameters.FileType = SaveFileTypes.GAME_CONFIGURATION;
	UIManager:QueuePopup(Controls.LoadGameMenu, PopupPriority.Current, kParameters);
end

-------------------------------------------------
-- Load Configuration Button Handler
-------------------------------------------------
function OnSaveConfig()
	local kParameters = {};
	kParameters.FileType = SaveFileTypes.GAME_CONFIGURATION;
	UIManager:QueuePopup(Controls.SaveGameMenu, PopupPriority.Current, kParameters);
end

function OnAbandoned(eReason)
	if (not ContextPtr:IsHidden()) then

		-- We need to CheckLeaveGame before triggering the reason popup because the reason popup hides the host game screen.
		-- and would block the leave game incorrectly.  This fixes TTP 22192.  See CheckLeaveGame() in stagingroom.lua.
		CheckLeaveGame();

		if (eReason == KickReason.KICK_HOST) then
			LuaEvents.MultiplayerPopup( "LOC_GAME_ABANDONED_KICKED", "LOC_GAME_ABANDONED_KICKED_TITLE" );
		elseif (eReason == KickReason.KICK_NO_HOST) then
			LuaEvents.MultiplayerPopup( "LOC_GAME_ABANDONED_HOST_LOSTED", "LOC_GAME_ABANDONED_HOST_LOSTED_TITLE" );
		elseif (eReason == KickReason.KICK_NO_ROOM) then
			LuaEvents.MultiplayerPopup( "LOC_GAME_ABANDONED_ROOM_FULL", "LOC_GAME_ABANDONED_ROOM_FULL_TITLE" );
		elseif (eReason == KickReason.KICK_VERSION_MISMATCH) then
			LuaEvents.MultiplayerPopup( "LOC_GAME_ABANDONED_VERSION_MISMATCH", "LOC_GAME_ABANDONED_VERSION_MISMATCH_TITLE" );
		elseif (eReason == KickReason.KICK_MOD_ERROR) then
			LuaEvents.MultiplayerPopup( "LOC_GAME_ABANDONED_MOD_ERROR", "LOC_GAME_ABANDONED_MOD_ERROR_TITLE" );
		elseif (eReason == KickReason.KICK_MOD_MISSING) then
			local modMissingErrorStr = Modding.GetLastModErrorString();
			LuaEvents.MultiplayerPopup( modMissingErrorStr, "LOC_GAME_ABANDONED_MOD_MISSING_TITLE" );
		elseif (eReason == KickReason.KICK_MATCH_DELETED) then
			LuaEvents.MultiplayerPopup( "LOC_GAME_ABANDONED_MATCH_DELETED", "LOC_GAME_ABANDONED_MATCH_DELETED_TITLE" );
		else
			LuaEvents.MultiplayerPopup( "LOC_GAME_ABANDONED_CONNECTION_LOST", "LOC_GAME_ABANDONED_CONNECTION_LOST_TITLE");
		end
		LuaEvents.Multiplayer_ExitShell();
	end
end

function CheckLeaveGame()
	-- Leave the network session if we're in a state where the host game should be triggering the exit.
	if not ContextPtr:IsHidden()	-- If the screen is not visible, this exit might be part of a general UI state change (like Multiplayer_ExitShell)
									-- and should not trigger a game exit.
		and Network.IsInSession()	-- Still in a network session.
		and not Network.IsInGameStartedState() then -- Don't trigger leave game if we're being used as an ingame screen. Worldview is handling this instead.
		print("HostGame::CheckLeaveGame() leaving the network session.");
		Network.LeaveGame();
	end
end

-- ===========================================================================
-- Event Handler: LeaveGameComplete
-- ===========================================================================
function OnLeaveGameComplete()
	-- We just left the game, we shouldn't be open anymore.
	UIManager:DequeuePopup( ContextPtr );
end

-- ===========================================================================
-- Event Handler: BeforeMultiplayerInviteProcessing
-- ===========================================================================
function OnBeforeMultiplayerInviteProcessing()
	-- We're about to process a game invite.  Get off the popup stack before we accidently break the invite!
	UIManager:DequeuePopup( ContextPtr );
end

-- ===========================================================================
-- Event Handler: ChangeMPLobbyMode
-- ===========================================================================
function OnChangeMPLobbyMode(newLobbyMode)
	m_lobbyModeName = newLobbyMode;
end

-- ===========================================================================
function RealizeShellTabs()
	m_shellTabIM:ResetInstances();

	local gameSetup:table = m_shellTabIM:GetInstance();
	gameSetup.Button:SetText(LOC_GAME_SETUP);
	gameSetup.SelectedButton:SetText(LOC_GAME_SETUP);
	gameSetup.Selected:SetHide(false);

	AutoSizeGridButton(gameSetup.Button,250,32,10,"H");
	AutoSizeGridButton(gameSetup.SelectedButton,250,32,20,"H");
	gameSetup.TopControl:SetSizeX(gameSetup.Button:GetSizeX());

	if Network.IsInSession() then
		local stagingRoom:table = m_shellTabIM:GetInstance();
		stagingRoom.Button:SetText(LOC_STAGING_ROOM);
		stagingRoom.SelectedButton:SetText(LOC_STAGING_ROOM);
		stagingRoom.Button:RegisterCallback( Mouse.eLClick, function() LuaEvents.HostGame_ShowStagingRoom() end );
		stagingRoom.Selected:SetHide(true);

		AutoSizeGridButton(stagingRoom.Button,250,32,20,"H");
		AutoSizeGridButton(stagingRoom.SelectedButton,250,32,20,"H");
		stagingRoom.TopControl:SetSizeX(stagingRoom.Button:GetSizeX());
	end

	Controls.ShellTabs:CalculateSize();
	Controls.ShellTabs:ReprocessAnchoring();
end

-------------------------------------------------
-- Leave the screen
-------------------------------------------------
function HandleExitRequest()
	-- Check to see if the screen needs to also leave the network session.
	CheckLeaveGame();

	UIManager:DequeuePopup( ContextPtr );
end

-- ===========================================================================
function OnRaiseHostGame()
	-- "Raise" means the host game screen is being shown for a fresh game.  Game configuration need to be defaulted.
	local gameMode = GameModeTypeForMPLobbyType(m_lobbyModeName);
	GameConfiguration.SetToDefaults(gameMode);

	-- Kludge:  SetToDefaults assigns the ruleset to be standard.
	-- Clear this value so that the setup parameters code can guess the best 
	-- default.
	GameConfiguration.SetValue("RULESET", nil);

	UIManager:QueuePopup( ContextPtr, PopupPriority.Current );
end

-- ===========================================================================
function OnEnsureHostGame()
	-- "Ensure" means the host game screen needs to be shown for a game in progress (don't default game configuration).
	if ContextPtr:IsHidden() then
		UIManager:QueuePopup( ContextPtr, PopupPriority.Current );
	end
end

-- ===========================================================================
function OnInit(isReload:boolean)
	if isReload then
		LuaEvents.GameDebug_GetValues( RELOAD_CACHE_ID );
	end
end

-- ===========================================================================
function OnShutdown()
	-- Cache values for hotloading...
	LuaEvents.GameDebug_AddValue(RELOAD_CACHE_ID, "isHidden", ContextPtr:IsHidden());
	LuaEvents.MultiSelectWindow_SetParameterValues.Remove(OnSetParameterValues);
	LuaEvents.CityStatePicker_SetParameterValues.Remove(OnSetParameterValues);
	LuaEvents.CityStatePicker_SetParameterValue.Remove(OnSetParameterValue);
	LuaEvents.LeaderPicker_SetParameterValues.Remove(OnSetParameterValues);

	LuaEvents.GoodyHutPicker_SetParameterValues.Remove(OnSetParameterValues);				-- C6GUE : EGHV
	LuaEvents.NaturalWonderPicker_SetParameterValues.Remove(OnSetParameterValues);			-- C6GUE : ENWS
end

-- ===========================================================================
function OnGameDebugReturn( context:string, contextTable:table )
	if context == RELOAD_CACHE_ID and contextTable["isHidden"] == false then
		UIManager:QueuePopup( ContextPtr, PopupPriority.Current );
	end	
end

-- ===========================================================================
-- Load Game Button Handler
-- ===========================================================================
function LoadButtonClick()
	local serverType = ServerTypeForMPLobbyType(m_lobbyModeName);
	LuaEvents.HostGame_SetLoadGameServerType(serverType);
	UIManager:QueuePopup(Controls.LoadGameMenu, PopupPriority.Current);	
end

-- ===========================================================================
function Resize()
	local screenX, screenY:number = UIManager:GetScreenSizeVal();
	if(screenY >= MIN_SCREEN_Y + (Controls.LogoContainer:GetSizeY()+ Controls.LogoContainer:GetOffsetY() * 2)) then
		Controls.MainWindow:SetSizeY(screenY-(Controls.LogoContainer:GetSizeY() + Controls.LogoContainer:GetOffsetY() * 2));
		Controls.DecoBorder:SetSizeY(SCREEN_OFFSET_Y + Controls.MainWindow:GetSizeY()-(Controls.BottomButtonStack:GetSizeY() + Controls.LogoContainer:GetSizeY()));
	else
		Controls.MainWindow:SetSizeY(screenY);
		Controls.DecoBorder:SetSizeY(MIN_SCREEN_OFFSET_Y + Controls.MainWindow:GetSizeY()-(Controls.BottomButtonStack:GetSizeY()));
	end
	Controls.MainGrid:ReprocessAnchoring();
end

-- ===========================================================================
function OnUpdateUI( type:number, tag:string, iData1:number, iData2:number, strData1:string )   
  if type == SystemUpdateUI.ScreenResize then
	Resize();
  end
end

-- ===========================================================================
function OnExitGame()
	LuaEvents.Multiplayer_ExitShell();
end

-- ===========================================================================
function OnExitGameAskAreYouSure()
	if Network.IsInSession() then
		if (not m_kPopupDialog:IsOpen()) then
			m_kPopupDialog:AddText(	  Locale.Lookup("LOC_GAME_MENU_QUIT_WARNING"));
			m_kPopupDialog:AddButton( Locale.Lookup("LOC_COMMON_DIALOG_NO_BUTTON_CAPTION"), nil );
			m_kPopupDialog:AddButton( Locale.Lookup("LOC_COMMON_DIALOG_YES_BUTTON_CAPTION"), OnExitGame, nil, nil, "PopupButtonInstanceRed" );
			m_kPopupDialog:Open();
		end
	else
		OnExitGame();
	end
end

-- ===========================================================================
function Initialize()
	
	Events.SystemUpdateUI.Add(OnUpdateUI);

	ContextPtr:SetInitHandler(OnInit);
	ContextPtr:SetShutdown(OnShutdown);
	ContextPtr:SetInputHandler(OnInputHandler);
	ContextPtr:SetShowHandler(OnShow);
	ContextPtr:SetHideHandler(OnHide);

	Controls.DefaultButton:RegisterCallback( Mouse.eLClick, OnDefaultButton);
	Controls.LoadConfigButton:RegisterCallback( Mouse.eLClick, OnLoadConfig);
	Controls.SaveConfigButton:RegisterCallback( Mouse.eLClick, OnSaveConfig);
	Controls.ConfirmButton:RegisterCallback( Mouse.eLClick, OnConfirmClick );
	Controls.ModsButton:RegisterCallback( Mouse.eLClick, ModsButtonClick );

	Events.MultiplayerGameAbandoned.Add( OnAbandoned );
	Events.LeaveGameComplete.Add( OnLeaveGameComplete );
	Events.BeforeMultiplayerInviteProcessing.Add( OnBeforeMultiplayerInviteProcessing );
	
	LuaEvents.ChangeMPLobbyMode.Add( OnChangeMPLobbyMode );
	LuaEvents.GameDebug_Return.Add(OnGameDebugReturn);
	LuaEvents.Lobby_RaiseHostGame.Add( OnRaiseHostGame );
	LuaEvents.MainMenu_RaiseHostGame.Add( OnRaiseHostGame );
	LuaEvents.Multiplayer_ExitShell.Add( HandleExitRequest );
	LuaEvents.StagingRoom_EnsureHostGame.Add( OnEnsureHostGame );
	LuaEvents.Mods_UpdateHostGameSettings.Add(GameSetup_RefreshParameters);		-- TODO: Remove when mods are managed by this screen

	LuaEvents.MultiSelectWindow_SetParameterValues.Add(OnSetParameterValues);
	LuaEvents.CityStatePicker_SetParameterValues.Add(OnSetParameterValues);
	LuaEvents.CityStatePicker_SetParameterValue.Add(OnSetParameterValue);
	LuaEvents.LeaderPicker_SetParameterValues.Add(OnSetParameterValues);
	
	LuaEvents.GoodyHutPicker_SetParameterValues.Add(OnSetParameterValues);				-- C6GUE : EGHV
	LuaEvents.NaturalWonderPicker_SetParameterValues.Add(OnSetParameterValues);			-- C6GUE : ENWS

	Controls.BackButton:RegisterCallback( Mouse.eLClick, OnExitGameAskAreYouSure);
	Controls.LoadButton:RegisterCallback( Mouse.eLClick, LoadButtonClick );

	ResizeButtonToText( Controls.DefaultButton );
	ResizeButtonToText( Controls.BackButton );
	Resize();

	-- Custom popup setup	
	m_kPopupDialog = PopupDialog:new( "InGameTopOptionsMenu" );
end
Initialize();

--[[ =========================================================================
	end modified HostGame.lua frontend script
=========================================================================== ]]
