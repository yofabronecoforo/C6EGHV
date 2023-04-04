--[[ =========================================================================
	EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (C) 2020-2023 zzragnar0kzz
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
	begin modified AdvancedSetup.lua frontend script
=========================================================================== ]]
-- print("C6GUE: Loading modified AdvancedSetup.lua . . .");

-- ===========================================================================
--	Single Player Create Game w/ Advanced Options
-- ===========================================================================
include("InstanceManager");
include("PlayerSetupLogic");
include("Civ6Common");
include("SupportFunctions");
include("PopupDialog");

-- C6GUE shared components
-- include("C6GUE_Common");
-- ExposedMembers.C6GUE = ExposedMembers.C6GUE or {};
-- C6GUE = ExposedMembers.C6GUE;
-- C6GUE.TestFunction();

-- ===========================================================================
-- ===========================================================================

local PULLDOWN_TRUNCATE_OFFSET:number = 40;

local MIN_SCREEN_Y			:number = 768;
local SCREEN_OFFSET_Y		:number = 61;
local MIN_SCREEN_OFFSET_Y	:number = -53;

local MAX_SIDEBAR_Y			:number = 960;

-- ===========================================================================
-- ===========================================================================

-- Instance managers for dynamic simple game options.
g_SimpleBooleanParameterManager = InstanceManager:new("SimpleBooleanParameterInstance", "CheckBox", Controls.CheckBoxParent);
g_SimpleGameModeParameterManager = InstanceManager:new("GameModeSelectorInstance", "Top", Controls.CheckBoxParent);
g_SimplePullDownParameterManager = InstanceManager:new("SimplePullDownParameterInstance", "Root", Controls.PullDownParent);
g_SimpleSliderParameterManager = InstanceManager:new("SimpleSliderParameterInstance", "Root", Controls.SliderParent);
g_SimpleStringParameterManager = InstanceManager:new("SimpleStringParameterInstance", "Root", Controls.EditBoxParent);

-- Instance managers for Game Mode placard and details flyouts
local m_gameModeToolTipHeaderIM = InstanceManager:new("HeaderInstance", "Top", Controls.GameModeInfoStack );
local m_gameModeToolTipHeaderIconIM = InstanceManager:new("IconInstance", "Top", Controls.GameModeInfoStack );

g_kMapData = {};	-- Global set of map data; enough for map selection context to do it's thing. (Parameter list still truly owns the data.)

local m_NonLocalPlayerSlotManager	:table = InstanceManager:new("NonLocalPlayerSlotInstance", "Root", Controls.NonLocalPlayersSlotStack);
local m_singlePlayerID				:number = 0;			-- The player ID of the human player in singleplayer.
local m_AdvancedMode				:boolean = false;
local m_RulesetData					:table = {};
local m_BasicTooltipData			:table = {};
local m_WorldBuilderImport          :boolean = false;

local m_pWarningPopup:table = PopupDialog:new("CityStateWarningPopup");

-- ===========================================================================
-- Override hiding game setup to release simplified instances.
-- ===========================================================================
GameSetup_HideGameSetup = HideGameSetup;
function HideGameSetup(func)
	GameSetup_HideGameSetup(func);
	g_SimpleBooleanParameterManager:ResetInstances();
	g_SimpleGameModeParameterManager:ResetInstances();
	g_SimplePullDownParameterManager:ResetInstances();
	g_SimpleSliderParameterManager:ResetInstances();
	g_SimpleStringParameterManager:ResetInstances();
end

-- ===========================================================================
-- Input Handler
-- ===========================================================================
function OnInputHandler( pInputStruct:table )
	local uiMsg = pInputStruct:GetMessageType();
	if uiMsg == KeyEvents.KeyUp then
		local key:number = pInputStruct:GetKey();
		if key == Keys.VK_ESCAPE then
			OnBackButton();
		end
	end
	return true;
end

local _UI_BeforeRefresh = UI_BeforeRefresh;
function UI_BeforeRefresh()
	
	if(_UI_BeforeRefresh) then
		_UI_BeforeRefresh();
	end

	-- Reset basic setup container states
	Controls.CreateGame_GameDifficultyContainer:SetHide(true);
	Controls.CreateGame_SpeedPulldownContainer:SetHide(true);
	Controls.CreateGame_MapTypeContainer:SetHide(true);
	Controls.CreateGame_MapSizeContainer:SetHide(true);
end

local _UI_AfterRefresh = GameParameters_UI_AfterRefresh;
function GameParameters_UI_AfterRefresh(o)
	
	if(_UI_AfterRefresh) then
		_UI_AfterRefresh(o);
	end
	
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

	local stacks = {};
	table.insert(stacks, Controls.CreateGame_ExtraParametersStack);
	table.insert(stacks, Controls.CreateGame_GameModeParametersStack);

	for i,v in ipairs(stacks) do
		v:SortChildren(sort);
	end

	for i,v in ipairs(stacks) do
		v:CalculateSize();
		v:ReprocessAnchoring();
	end
	   
	Controls.CreateGameOptions:CalculateSize();
	Controls.CreateGameOptions:ReprocessAnchoring();

	if Controls.CreateGame_ParametersScrollPanel then
		Controls.CreateGame_ParametersScrollPanel:CalculateInternalSize();
	end

end

-- Override for SetupParameters to filter ruleset values by non-scenario only.
function GameParameters_FilterValues(o, parameter, values)
	values = o.Default_Parameter_FilterValues(o, parameter, values);
	if(parameter.ParameterId == "Ruleset") then
		local new_values = {};
		for i,v in ipairs(values) do
			local data = GetRulesetData(v.Value);
			if(not data.IsScenario) then
				table.insert(new_values, v);
			end
		end
		values = new_values;
	end

	return values;
end

function GetRulesetData(rulesetType)
	if not m_RulesetData[rulesetType] then
		local query:string = "SELECT Description, LongDescription, IsScenario, ScenarioSetupPortrait, ScenarioSetupPortraitBackground from Rulesets where RulesetType = ? LIMIT 1";
		local result:table = DB.ConfigurationQuery(query, rulesetType);
		if result and #result > 0 then
			m_RulesetData[rulesetType] = result[1];
		else
			m_RulesetData[rulesetType] = {};
		end
	end
	return m_RulesetData[rulesetType];
end

-- Cache frequently accessed data.
local _cachedMapDomain = nil;
local _cachedMapData = nil;
function GetMapData( domain:string, file:string )
	-- Refresh the cache if needed.
	if(_cachedMapData == nil or _cachedMapDomain ~= domain) then
		_cachedMapDomain = domain;
		_cachedMapData = {};
		local query = "SELECT File, Image, StaticMap from Maps where Domain = ?";
		local results = DB.ConfigurationQuery(query, domain);
		if(results) then		
			for i,v in ipairs(results) do
				_cachedMapData[v.File] = v;
			end
		end
	end 

	local mapInfo = _cachedMapData[file];
	if(mapInfo) then
		local isOfficial = mapInfo.IsOfficial;
		if(isOfficial == nil) then
			local modId,path = Modding.ParseModUri(mapInfo.File);
			isOfficial = (modId == nil) or Modding.IsModOfficial(modId);
			mapInfo.IsOfficial = isOfficial;
		end
		
		return mapInfo;
	else
		-- return nothing.
		return nil;
	end
end

-- ===========================================================================
--	Build a sub-set of SetupParameters that can be used to populate a
--	map selection screen.
--
--	To send maps:		LuaEvents.MapSelect_PopulatedMaps( g_kMapData );
--	To receive choice:	LuaEvents.MapSelect_SetMapByValue( value );
-- ===========================================================================
function BuildMapSelectData( kMapParameters:table )
	-- Sanity checks
	if kMapParameters == nil then 
		UI.DataError("Unable to build data for map selection; NIL kMapParameter passed in.);");
		return;
	end

	g_kMapData = {};	-- Clear out existing data.

	-- Loop through maps, create subset of data that is enough to show
	-- content in a map select context as well as match up with the
	-- selection.
	-- Note that "Value" in the table below may be one of the following:
	--	somename.lua									- A map script that is generated
	--	{GUID}somefile.Civ6Map							- World builder map prefixed with a GUID
	--	../..Assets/Maps/SomeFolder/myMap.Civ6Map		- World builder map in another folder
	--	{GUID}../..Assets/Maps/SomeFolder/myMap.Civ6Map	- World builder map in another folder
	local kMapCollection:table = kMapParameters.Values;
	for i,kMapData in ipairs( kMapCollection ) do
		local kExtraInfo :table = GetMapData(kMapData.Domain, kMapData.Value);

		local mapData = {
			RawName			= kMapData.RawName,
			RawDescription	= kMapData.RawDescription,
			SortIndex		= kMapData.SortIndex,
			QueryIndex		= kMapData.QueryIndex,
			Hash			= kMapData.Hash,
			Value			= kMapData.Value,
			Name			= kMapData.Name,
			Texture			= nil,
			IsWorldBuilder	= false,
			IsOfficial		= false,
		};

		if(kExtraInfo) then
			mapData.IsOfficial		= kExtraInfo.IsOfficial;
			mapData.Texture			= kExtraInfo.Image;
			mapData.IsWorldBuilder	= kExtraInfo.StaticMap;
		end
		table.insert(g_kMapData, mapData);
	end

	table.sort(g_kMapData, SortMapsByName);
end

-- ===========================================================================
function SortMapsByName(a, b)
	return Locale.Compare(a.Name, b.Name) == -1;
end

-- ===========================================================================
--	LuaEvent
--	Called from the MapSelect popup for what map was selected.
--	value	the map to set for the game.
-- ===========================================================================
function OnSetMapByValue( value: string )
	local kParameters	:table = g_GameParameters["Parameters"];
	local kMapParameters:table = kParameters["Map"];
	local kMapCollection:table = kMapParameters.Values;
	local isFound		:boolean = false;
	for i,kMapData in ipairs( kMapCollection ) do
		if kMapData.Value == value then
			g_GameParameters:SetParameterValue(kMapParameters, kMapData);
			Network.BroadcastGameConfig();			
			isFound = true;
			break;	
		end
	end
	if (not isFound) then
		UI.DataError("Unable to set the game's map to a map with the value '"..tostring(value).."'");
	end
end

function OnSetParameterValues(pid: string, values: table)
	local indexed_values = {};
	if(values) then
		for i,v in ipairs(values) do
			indexed_values[v] = true;
		end
	end

	if(g_GameParameters) then
		local kParameter: table = g_GameParameters.Parameters and g_GameParameters.Parameters[pid] or nil;
		if(kParameter and kParameter.Values ~= nil) then
			local resolved_values = {};
			for i,v in ipairs(kParameter.Values) do
				if(indexed_values[v.Value]) then
					table.insert(resolved_values, v);
				end
			end		
			g_GameParameters:SetParameterValue(kParameter, resolved_values);
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

-- ===========================================================================
function CreatePulldownDriver(o, parameter, c, container)

	local cache = {};
	local driver = {
		Control = c,
		Container = container,
		UpdateValue = function(value)
			local valueText = value and value.Name or nil;
			local button = c:GetButton();
			if(cache.ValueText ~= valueText or cache.ValueDescription ~= valueDescription) then
				local truncateWidth = button:GetSizeX() - PULLDOWN_TRUNCATE_OFFSET;
				TruncateStringWithTooltip(button, truncateWidth, valueText);
				cache.ValueText = valueText;
			end		
			button:LocalizeAndSetToolTip(value.RawDescription);
		end,
		UpdateValues = function(values)
			-- If container was included, hide it if there is only 1 possible value.
			if(#values == 1 and container ~= nil) then
				container:SetHide(true);
			else
				if(container) then
					container:SetHide(false);
				end

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
					c:ClearEntries();
					for i,v in ipairs(values) do
						local entry = {};
						c:BuildEntry( "InstanceOne", entry );
						entry.Button:SetText(v.Name);
						if v.RawDescription then
							entry.Button:SetToolTipString(Locale.Lookup(v.RawDescription));
						else
							entry.Button:SetToolTipString(v.Description);
						end

						entry.Button:RegisterCallback(Mouse.eLClick, function()
							o:SetParameterValue(parameter, v);
							Network.BroadcastGameConfig();
						end);
					end
					c:CalculateInternals();
					cache.Values = values;
				end
			end			
		end,
		SetEnabled = function(enabled, parameter)
			c:SetDisabled(not enabled or #parameter.Values <= 1);
		end,
		SetVisible = function(visible, parameter)
			container:SetHide(not visible or parameter.Value == nil);
		end,	
		Destroy = nil,		-- It's a fixed control, no need to delete.
	};
	
	return driver;	
end

-- ===========================================================================
--	Driver for the simple menu's "Map Select"
-- ===========================================================================
function CreateSimpleMapPopupDriver(o, parameter )
	local uiMapPopupButton:object = Controls.MapSelectButton;
	local kDriver :table = {
		UpdateValues = function(o, parameter) 
			BuildMapSelectData(parameter);
		end,
		UpdateValue = function( kValue:table )
			local valueText			:string = kValue and kValue.Name or nil;
			local valueDescription	:string = kValue and kValue.Description or nil
			uiMapPopupButton:SetText( valueText );
			uiMapPopupButton:SetToolTipString( valueDescription );
		end
	}
	return kDriver;
end

-- ===========================================================================
--	Used to launch popups
--	o				main object of all the parameters
--	parameter		the parameter being changed
--	activateFunc	The function to be called when the button is pressed
--	parent			(optional) The parent control to connect to
--
--	RETURNS:		A 'driver' that represents a UI control and various common
--					functions that manipulate the control in a setup screen.
-- ===========================================================================
function CreateButtonPopupDriver(o, parameter, activateFunc, parent )

	-- Sanity check
	if(activateFunc == nil) then
		UI.DataError("Ignoring creating popup button because no callback function was passed in. Parameters: name="..parameter.Name..", groupID="..tostring(parameter.GroupId));
		return {}
	end

	-- Apply defaults
	if(parent == nil) then
		parent = GetControlStack(parameter.GroupId);
	end
			
	-- Get the UI instance
	local c :object = g_ButtonParameterManager:GetInstance();	

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
		UpdateValue = function(value)
			local valueText = value and value.Name or nil;
			local valueDescription = value and value.Description or nil
			if(cache.ValueText ~= valueText or cache.ValueDescription ~= valueDescription) then
				local button = c.Button;
				button:RegisterCallback( Mouse.eLClick, activateFunc );					
				button:SetText(valueText);
				button:SetToolTipString(valueDescription);
				cache.ValueText = valueText;
				cache.ValueDescription = valueDescription;
			end
		end,
		UpdateValues = function(values, p) 
			BuildMapSelectData(p);
		end,
		SetEnabled = function(enabled, parameter)
			c.Button:SetDisabled(not enabled or #parameter.Values <= 1);
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

	-- C6GUE : define picker based on parameterId
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
	elseif (parameterId == "GoodyHutConfig" and C6GUE.EGHV.IsEnabled) then				-- C6GUE : EGHV : Goody Hut picker
		button:RegisterCallback( Mouse.eLClick, function()
			LuaEvents.GoodyHutPicker_Initialize(o.Parameters[parameterId]);
			Controls.GoodyHutPicker:SetHide(false);
		end);
	elseif (parameterId == "NaturalWonders" and C6GUE.ENWS.IsEnabled) then				-- C6GUE : ENWS : Natural Wonder picker
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
-- This driver is for launching a multi-select option in a separate window.
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
-- 	button:SetToolTipString(parameter.Description);

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
-- 						-- EGHV : Display count for selections of "everything"
-- 						valueAmount = #p.Values;
-- 					else
-- 						valueText = "LOC_SELECTION_NOTHING";
-- 					end
-- 				elseif(type(value) == "table") then
-- 					local count = #value;
-- 					if (parameter.UxHint ~= nil and parameter.UxHint == "InvertSelection") then
-- 						if(count == 0) then
-- 							valueText = "LOC_SELECTION_EVERYTHING";
-- 							-- EGHV : Display count for selections of "everything"
-- 							valueAmount = #p.Values;
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
-- 							-- EGHV : Display count for selections of "everything"
-- 							valueAmount = #p.Values;
-- 						else
-- 							valueText = "LOC_SELECTION_CUSTOM";
-- 							valueAmount = count;
-- 						end
-- 					end
-- 				end
-- 			end				

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
-- Override parameter behavior for basic setup screen.
g_ParameterFactories["Ruleset"] = function(o, parameter)
	
	local drivers = {};
	-- Basic setup version.
	-- Use an explicit table.
	table.insert(drivers, CreatePulldownDriver(o, parameter, Controls.CreateGame_GameRuleset, Controls.CreateGame_RulesetContainer));

	-- Advanced setup version.
	-- Create the parameter dynamically like we normally would...
	table.insert(drivers, GameParameters_UI_CreateParameterDriver(o, parameter));

	return drivers;
end
g_ParameterFactories["GameDifficulty"] = function(o, parameter)

	local drivers = {};
	-- Basic setup version.
	-- Use an explicit table.
	table.insert(drivers, CreatePulldownDriver(o, parameter, Controls.CreateGame_GameDifficulty, Controls.CreateGame_GameDifficultyContainer));

	-- Advanced setup version.
	-- Create the parameter dynamically like we normally would...
	table.insert(drivers, GameParameters_UI_CreateParameterDriver(o, parameter));

	return drivers;
end

-- ===========================================================================
g_ParameterFactories["GameSpeeds"] = function(o, parameter)

	local drivers = {};
	-- Basic setup version.
	-- Use an explicit table.
	table.insert(drivers, CreatePulldownDriver(o, parameter, Controls.CreateGame_SpeedPulldown, Controls.CreateGame_SpeedPulldownContainer));

	-- Advanced setup version.
	-- Create the parameter dynamically like we normally would...
	table.insert(drivers, GameParameters_UI_CreateParameterDriver(o, parameter));

	return drivers;
end

-- ===========================================================================
g_ParameterFactories["Map"] = function(o, parameter)

	local drivers = {};

    if (m_WorldBuilderImport) then
        return drivers;
    end

	-- Basic setup version.
	table.insert(drivers, CreateSimpleMapPopupDriver(o, parameter) );
	
	-- Advanced setup version.	
	table.insert( drivers, CreateButtonPopupDriver(o, parameter, OnMapSelect) );

	return drivers;
end

-- ===========================================================================
g_ParameterFactories["MapSize"] = function(o, parameter)

	local drivers = {};

    if (m_WorldBuilderImport) then
        return drivers;
    end

	-- Basic setup version.
	-- Use an explicit table.
	table.insert(drivers, CreatePulldownDriver(o, parameter, Controls.CreateGame_MapSize, Controls.CreateGame_MapSizeContainer));

	-- Advanced setup version.
	-- Create the parameter dynamically like we normally would...
	table.insert(drivers, GameParameters_UI_CreateParameterDriver(o, parameter));

	return drivers;
end

function CreateSimpleParameterDriver(o, parameter, parent)

	-- print(tostring(parameter.ParameterId));

	if(parent == nil) then
		parent = GetControlStack(parameter.GroupId);
	end

	local control;
	
	-- If there is no parent, don't visualize the control.  This is most likely a player parameter.
	if(parent == nil) then
		return;
	end;

	if(parameter.GroupId == "GameModes") then
		local c = g_SimpleGameModeParameterManager:GetInstance();	
		
		-- Store the root control, NOT the instance table.
		g_SortingMap[tostring(c.Top)] = parameter;		
		
		local name = Locale.ToUpper(parameter.Name);
		c.CheckBox:RegisterCallback(Mouse.eLClick, function()
			o:SetParameterValue(parameter, not c.CheckBox:IsSelected());
			Network.BroadcastGameConfig();
		end);	
		c.GameModeIcon:SetIcon("ICON_" .. parameter.ParameterId);
		c.Top:ChangeParent(parent);

		control = {
			UpdateValue = function(value, parameter)
				c.CheckBox:SetSelected(value);
			end,
			Control = c,
			SetEnabled = function(enabled)
				c.CheckBox:SetDisabled(not enabled);
			end,
			SetVisible = function(visible)
				c.CheckBox:SetHide(not visible);
			end,
			Destroy = function()
				g_SimpleGameModeParameterManager:ReleaseInstance(c);
			end,
		};
		c.CheckBox:RegisterCallback( Mouse.eMouseEnter, function() OnGameModeMouseEnter(parameter) end);
		c.CheckBox:RegisterCallback( Mouse.eMouseExit, function() OnGameModeMouseExit(parameter) end);

		if(Controls.NoGameModesContainer:IsHidden() == false)then
			Controls.NoGameModesContainer:SetHide(true);
		end

	elseif(parameter.Domain == "bool") then
		local c = g_SimpleBooleanParameterManager:GetInstance();	
		
		-- Store the root control, NOT the instance table.
		g_SortingMap[tostring(c.CheckBox)] = parameter;		
		
		local name = Locale.ToUpper(parameter.Name);
		c.CheckBox:SetText(name);
		c.CheckBox:SetToolTipString(parameter.Description);
		c.CheckBox:RegisterCallback(Mouse.eLClick, function()
			o:SetParameterValue(parameter, not c.CheckBox:IsSelected());
			Network.BroadcastGameConfig();
		end);
		c.CheckBox:ChangeParent(parent);

		control = {
			Control = c,
			UpdateValue = function(value, parameter)
				
				-- Sometimes the parameter name is changed, be sure to update it.
				c.CheckBox:SetText(parameter.Name);
				c.CheckBox:SetToolTipString(parameter.Description);
				
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
				g_SimpleBooleanParameterManager:ReleaseInstance(c);
			end,
		};

	elseif(parameter.Domain == "int" or parameter.Domain == "uint" or parameter.Domain == "text") then
		local c = g_SimpleStringParameterManager:GetInstance();		

		-- Store the root control, NOT the instance table.
		g_SortingMap[tostring(c.Root)] = parameter;
		
		local name = Locale.ToUpper(parameter.Name);	
		c.StringName:SetText(name);
		c.Root:SetToolTipString(parameter.Description);
		c.StringEdit:SetEnabled(true);

		local canChangeEnableState = true;

		if(parameter.Domain == "int") then
			c.StringEdit:SetNumberInput(true);
			c.StringEdit:SetMaxCharacters(16);
			c.StringEdit:RegisterCommitCallback(function(textString)
				o:SetParameterValue(parameter, tonumber(textString));	
				Network.BroadcastGameConfig();
			end);
		elseif(parameter.Domain == "uint") then
			c.StringEdit:SetNumberInput(true);
			c.StringEdit:SetMaxCharacters(16);
			c.StringEdit:RegisterCommitCallback(function(textString)
				local value = math.max(tonumber(textString) or 0, 0);
				o:SetParameterValue(parameter, value);	
				Network.BroadcastGameConfig();
			end);
		else
			c.StringEdit:SetNumberInput(false);
			c.StringEdit:SetMaxCharacters(64);
			if UI.HasFeature("TextEntry") == true then
				c.StringEdit:RegisterCommitCallback(function(textString)
					o:SetParameterValue(parameter, textString);	
					Network.BroadcastGameConfig();
				end);
			else
				canChangeEnableState = false;
				c.StringEdit:SetEnabled(false);
			end
		end

		c.Root:ChangeParent(parent);

		control = {
			Control = c,
			UpdateValue = function(value)
				c.StringEdit:SetText(Locale.Lookup(value));
			end,
			SetEnabled = function(enabled)
				if canChangeEnableState then
					c.Root:SetDisabled(not enabled);
					c.StringEdit:SetDisabled(not enabled);
				end
			end,
			SetVisible = function(visible)
				c.Root:SetHide(not visible);
			end,
			Destroy = function()
				g_SimpleStringParameterManager:ReleaseInstance(c);
			end,
		};
	elseif (C6GUE.EGHV.IsEnabled and parameter.ParameterId == "GoodyHutFrequency") then			-- configure the Goody Huts frequency slider
		-- print(" *** : Configuring Goody Hut Frequency slider");
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
	elseif (parameter.Values and parameter.Values.Type == "IntRange") then -- Range
		-- print(" *** : Configuring slider : " .. tostring(parameter.ParameterId));
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
			
			-- This method can get called pretty frequently, try and throttle it.
			if(parameter.Value ~= minimumValue + stepNum) then
				o:SetParameterValue(parameter, minimumValue + stepNum);
				Network.BroadcastGameConfig();
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
	elseif (parameter.Values) then -- MultiValue
		
		-- Get the UI instance
		local c = g_SimplePullDownParameterManager:GetInstance();	
		
		-- Store the root control, NOT the instance table.
		g_SortingMap[tostring(c.Root)] = parameter;

		c.Root:ChangeParent(parent);
		if c.StringName ~= nil then
			local name = Locale.ToUpper(parameter.Name);
			c.StringName:SetText(name);
		end

		control = {
			Control = c,
			UpdateValue = function(value)
				local button = c.PullDown:GetButton();
				button:SetText( value and value.Name or nil);
				button:SetToolTipString(value and value.Description or nil);
			end,
			UpdateValues = function(values)
				c.PullDown:ClearEntries();

				for i,v in ipairs(values) do
					local entry = {};
					c.PullDown:BuildEntry( "InstanceOne", entry );
					entry.Button:SetText(v.Name);
					entry.Button:SetToolTipString(v.Description);

					entry.Button:RegisterCallback(Mouse.eLClick, function()
						o:SetParameterValue(parameter, v);
						Network.BroadcastGameConfig();
					end);
				end
				c.PullDown:CalculateInternals();
			end,
			SetEnabled = function(enabled, parameter)
				c.PullDown:SetDisabled(not enabled or #parameter.Values <= 1);
			end,
			SetVisible = function(visible)
				c.Root:SetHide(not visible);
			end,
			Destroy = function()
				g_SimplePullDownParameterManager:ReleaseInstance(c);
			end,
		};	
	end

	return control;
end

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

-- The method used to create a UI control associated with the parameter.
-- Returns either a control or table that will be used in other parameter view related hooks.
function GameParameters_UI_CreateParameter(o, parameter)
	local func = g_ParameterFactories[parameter.ParameterId];

	local control;
	if(func)  then
		control = func(o, parameter);
	elseif(parameter.GroupId == "BasicGameOptions" or parameter.GroupId == "BasicMapOptions") then	
		control = {
			CreateSimpleParameterDriver(o, parameter, Controls.CreateGame_ExtraParametersStack),
			GameParameters_UI_CreateParameterDriver(o, parameter)
		};
	elseif(parameter.GroupId == "GameModes") then	
		control = {
			CreateSimpleParameterDriver(o, parameter, Controls.CreateGame_GameModeParametersStack),
			GameParameters_UI_CreateParameterDriver(o, parameter)
		};	
	else
		control = GameParameters_UI_CreateParameterDriver(o, parameter);
	end

	o.Controls[parameter.ParameterId] = control;
end

-- ===========================================================================
-- Remove player handler.
function RemovePlayer(voidValue1, voidValue2, control)
	print("Removing Player " .. tonumber(voidValue1));
	local playerConfig = PlayerConfigurations[voidValue1];
	playerConfig:SetLeaderTypeName(nil);
	
	GameConfiguration.RemovePlayer(voidValue1);

	GameSetup_PlayerCountChanged();
end

-- ===========================================================================
-- Add UI entries for all the players.  This does not set the
-- UI values of the player.
-- ===========================================================================
function RefreshPlayerSlots()

	RebuildPlayerParameters();
	m_NonLocalPlayerSlotManager:ResetInstances();

	local player_ids = GameConfiguration.GetParticipatingPlayerIDs();

	local minPlayers = MapConfiguration.GetMinMajorPlayers() or 2;
	local maxPlayers = MapConfiguration.GetMaxMajorPlayers() or 2;
	local can_remove = #player_ids > minPlayers;
	local can_add = #player_ids < maxPlayers;

	Controls.AddAIButton:SetHide(not can_add);

	print("There are " .. #player_ids .. " participating players.");

	Controls.BasicTooltipContainer:DestroyAllChildren();
	Controls.BasicPlacardContainer:DestroyAllChildren();
	Controls.AdvancedTooltipContainer:DestroyAllChildren();
	
	local basicTooltip = {};
	ContextPtr:BuildInstanceForControl( "CivToolTip", basicTooltip, Controls.BasicTooltipContainer );
	local basicPlacard	:table = {};
	ContextPtr:BuildInstanceForControl( "LeaderPlacard", basicPlacard, Controls.BasicPlacardContainer );

	m_BasicTooltipData = {
		InfoStack			= basicTooltip.InfoStack,
		InfoScrollPanel		= basicTooltip.InfoScrollPanel;
		CivToolTipSlide		= basicTooltip.CivToolTipSlide;
		CivToolTipAlpha		= basicTooltip.CivToolTipAlpha;
		UniqueIconIM		= InstanceManager:new("IconInfoInstance",	"Top",	basicTooltip.InfoStack );		
		HeaderIconIM		= InstanceManager:new("IconInstance",		"Top",	basicTooltip.InfoStack );
		CivHeaderIconIM		= InstanceManager:new("CivIconInstance",	"Top",	basicTooltip.InfoStack );
		HeaderIM			= InstanceManager:new("HeaderInstance",		"Top",	basicTooltip.InfoStack );
		HasLeaderPlacard	= true;
		LeaderBG			= basicPlacard.LeaderBG;
		LeaderImage			= basicPlacard.LeaderImage;
		DummyImage			= basicPlacard.DummyImage;
		CivLeaderSlide		= basicPlacard.CivLeaderSlide;
		CivLeaderAlpha		= basicPlacard.CivLeaderAlpha;
	};

	local advancedTooltip	:table = {};
	ContextPtr:BuildInstanceForControl( "CivToolTip", advancedTooltip, Controls.AdvancedTooltipContainer );

	local advancedTooltipData : table = {
		InfoStack			= advancedTooltip.InfoStack,
		InfoScrollPanel		= advancedTooltip.InfoScrollPanel;
		CivToolTipSlide		= advancedTooltip.CivToolTipSlide;
		CivToolTipAlpha		= advancedTooltip.CivToolTipAlpha;
		UniqueIconIM		= InstanceManager:new("IconInfoInstance",	"Top",	advancedTooltip.InfoStack );		
		HeaderIconIM		= InstanceManager:new("IconInstance",		"Top",	advancedTooltip.InfoStack );
		CivHeaderIconIM		= InstanceManager:new("CivIconInstance",	"Top",	advancedTooltip.InfoStack );
		HeaderIM			= InstanceManager:new("HeaderInstance",		"Top",	advancedTooltip.InfoStack );
		HasLeaderPlacard	= false;
	};

	for i, player_id in ipairs(player_ids) do	
		if(m_singlePlayerID == player_id) then
			SetupLeaderPulldown(player_id, Controls, "Basic_LocalPlayerPulldown", "Basic_LocalPlayerCivIcon",  "Basic_LocalPlayerCivIconBG", "Basic_LocalPlayerLeaderIcon", "Basic_LocalPlayerScrollText", m_BasicTooltipData);
			SetupLeaderPulldown(player_id, Controls, "Advanced_LocalPlayerPulldown", "Advanced_LocalPlayerCivIcon", "Advanced_LocalPlayerCivIconBG", "Advanced_LocalPlayerLeaderIcon", "Advanced_LocalPlayerScrollText", advancedTooltipData, "Advanced_LocalColorPullDown");
		else
			local ui_instance = m_NonLocalPlayerSlotManager:GetInstance();
			
			-- Assign the Remove handler
			if(can_remove) then
				ui_instance.RemoveButton:SetVoid1(player_id);
				ui_instance.RemoveButton:RegisterCallback(Mouse.eLClick, RemovePlayer);
			end
			ui_instance.RemoveButton:SetHide(not can_remove);
			
			SetupLeaderPulldown(player_id, ui_instance,"PlayerPullDown",nil,nil,nil,nil,advancedTooltipData);
		end
	end

	Controls.NonLocalPlayersSlotStack:CalculateSize();
	Controls.NonLocalPlayersSlotStack:ReprocessAnchoring();
	Controls.NonLocalPlayersStack:CalculateSize();
	Controls.NonLocalPlayersStack:ReprocessAnchoring();
	Controls.NonLocalPlayersPanel:CalculateInternalSize();
	Controls.NonLocalPlayersPanel:CalculateSize();

	-- Queue another refresh
	GameSetup_RefreshParameters();
end

-- ===========================================================================
-- Called every time parameters have been refreshed.
-- This is a useful spot to perform validation.
function UI_PostRefreshParameters()
	-- Most of the options self-heal due to the setup parameter logic.
	-- However, player options are allowed to be in an 'invalid' state for UI
	-- This way, instead of hiding/preventing the user from selecting an invalid player
	-- we can allow it, but display an error message explaining why it's invalid.

	-- This is primarily used to present ownership errors and custom constraint errors.
	Controls.StartButton:SetDisabled(false);
	Controls.StartButton:SetToolTipString(nil);

	local game_err = GetGameParametersError();
	if(game_err) then
		Controls.StartButton:SetDisabled(true);
		Controls.StartButton:LocalizeAndSetToolTip("LOC_SETUP_PARAMETER_ERROR");
	end
	
	local player_ids = GameConfiguration.GetParticipatingPlayerIDs();
	for i, player_id in ipairs(player_ids) do	
		local err = GetPlayerParameterError(player_id);
		if(err) then
			Controls.StartButton:SetDisabled(true);
			Controls.StartButton:LocalizeAndSetToolTip("LOC_SETUP_PLAYER_PARAMETER_ERROR");
			Controls.ConflictPopup:SetHide(false);
		end
	end

	-- TTP[20948]: Display leader placard for the currently selected leader
	local playerConfig = PlayerConfigurations[m_singlePlayerID];
	if(playerConfig and m_BasicTooltipData) then
		local selectedLeader = playerConfig:GetLeaderTypeID();
		if(selectedLeader ~= -1) then
			local leaderType = playerConfig:GetLeaderTypeName();
			local info = GetPlayerInfo(playerConfig:GetValue("LEADER_DOMAIN"), leaderType);
			DisplayCivLeaderToolTip(info, m_BasicTooltipData, false);
		end
	end
	
	Controls.CreateGameOptions:CalculateSize();
	Controls.CreateGameOptions:ReprocessAnchoring();
end

-------------------------------------------------------------------------------
-- Event Listeners
-------------------------------------------------------------------------------
function OnFinishedGameplayContentConfigure(result)
	if(ContextPtr and not ContextPtr:IsHidden() and result.Success) then
		GameSetup_RefreshParameters();
	end
end

-- ===========================================================================
function GameSetup_PlayerCountChanged()
	print("Player Count Changed");
	RefreshPlayerSlots();
end

-- ===========================================================================
function OnShow()

	 m_WorldBuilderImport = false;
	local bWorldBuilder = GameConfiguration.IsWorldBuilderEditor();

	if (bWorldBuilder) then
		Controls.WindowTitle:LocalizeAndSetText("{LOC_SETUP_CREATE_MAP:upper}");

        if (MapConfiguration.GetScript() == "WBImport.lua") then
            m_WorldBuilderImport = true;
        end

		-- KLUDGE: Ideally setup parameters in a group should have some sort of control mechanism for whether or not the group should show.
		Controls.CreateGame_LocalPlayerContainer:SetHide(true);
		Controls.PlayersSection:SetHide(true);
		Controls.VictoryParametersHeader:SetHide(true);
		
    else
		Controls.CreateGame_LocalPlayerContainer:SetHide(false);
		Controls.PlayersSection:SetHide(false);
		Controls.VictoryParametersHeader:SetHide(false);
		
		Controls.WindowTitle:LocalizeAndSetText("{LOC_SETUP_CREATE_GAME:upper}");
	end

	RefreshPlayerSlots();	-- Will trigger a game parameter refresh.
	AutoSizeGridButton(Controls.DefaultButton,133,36,15,"H");
	AutoSizeGridButton(Controls.CloseButton,133,36,10,"H");
	-- the map size and type dropdowns don't make sense on a map import

    if (m_WorldBuilderImport) then
        Controls.CreateGame_MapType:SetDisabled(true);
        Controls.CreateGame_MapSize:SetDisabled(true);
        Controls.StartButton:LocalizeAndSetText("LOC_LOAD_TILED");
		MapConfiguration.SetScript("WBImport.lua");
    elseif(bWorldBuilder) then
		Controls.CreateGame_MapType:SetDisabled(false);
        Controls.CreateGame_MapSize:SetDisabled(false);
        Controls.StartButton:LocalizeAndSetText("LOC_SETUP_WORLDBUILDER_START");
	else
        Controls.CreateGame_MapType:SetDisabled(false);
        Controls.CreateGame_MapSize:SetDisabled(false);
        Controls.StartButton:LocalizeAndSetText("LOC_START_GAME");
    end
end

-- ===========================================================================
function OnHide()
	HideGameSetup();
	ReleasePlayerParameters();
	m_RulesetData = {};
end


-- ===========================================================================
-- Button Handlers
-- ===========================================================================

-- ===========================================================================
function OnAddAIButton()
	-- Search for an empty slot number and mark the slot as computer.
	-- Then dispatch the player count changed event.
	local iPlayer = 0;
	while(true) do
		local playerConfig = PlayerConfigurations[iPlayer];
		
		-- If we've reached the end of the line, exit.
		if(playerConfig == nil) then
			break;
		end

		-- Find a suitable slot to add the AI.
		if (playerConfig:GetSlotStatus() == SlotStatus.SS_CLOSED) then
			playerConfig:SetSlotStatus(SlotStatus.SS_COMPUTER);
			playerConfig:SetMajorCiv();

			GameSetup_PlayerCountChanged();
			break;
		end

		-- Increment the AI, this assumes that either player config will hit nil 
		-- or we'll reach a suitable slot.
		iPlayer = iPlayer + 1;
	end
end

-- ===========================================================================
function OnAdvancedSetup()
	local bWorldBuilder = GameConfiguration.IsWorldBuilderEditor();

	Controls.CreateGameWindow:SetHide(true);
	Controls.AdvancedOptionsWindow:SetHide(false);
	Controls.LoadConfig:SetHide(bWorldBuilder);
	Controls.SaveConfig:SetHide(bWorldBuilder);
	Controls.ButtonStack:CalculateSize();

	m_AdvancedMode = true;
end

-- ===========================================================================
function OnMapSelect()
	LuaEvents.MapSelect_PopulatedMaps( g_kMapData );
	Controls.MapSelectWindow:SetHide(false);
end

-- ===========================================================================
function OnDefaultButton()
	print("Reseting Setup Parameters");

	local bWorldBuilder = GameConfiguration.IsWorldBuilderEditor();
	GameConfiguration.SetToDefaults();
	GameConfiguration.SetWorldBuilderEditor(bWorldBuilder);
	
	-- In World Builder we want to default to Standard Rules.
	if(not bWorldBuilder) then
		-- Kludge:  SetToDefaults assigns the ruleset to be standard.
		-- Clear this value so that the setup parameters code can guess the best 
		-- default.
		GameConfiguration.SetValue("RULESET", nil);
	end

	GameConfiguration.RegenerateSeeds();
	return GameSetup_PlayerCountChanged();
end

-- ===========================================================================
function OnStartButton()
	-- Is WorldBuilder active?
	if (GameConfiguration.IsWorldBuilderEditor()) then
        if (m_WorldBuilderImport) then
            MapConfiguration.SetScript("WBImport.lua");
			local loadGameMenu = ContextPtr:LookUpControl( "/FrontEnd/MainMenu/LoadGameMenu" );
			UIManager:QueuePopup(loadGameMenu, PopupPriority.Current);	
		else
			UI.SetWorldRenderView( WorldRenderView.VIEW_2D );
			UI.PlaySound("Set_View_2D");
			Network.HostGame(ServerType.SERVER_TYPE_NONE);
		end
    else
        local showCityStatesWarning:boolean = ShouldShowCityStatesWarning();
        local showLeaderPoolWarning:boolean = ShouldShowLeaderPoolWarning();
		if showCityStatesWarning then
			ShowCityStateWarning(showLeaderPoolWarning);
        elseif showLeaderPoolWarning then
            ShowLeaderPoolWarning();
        else
			-- > EGHV : Get excluded Goody Hut reward(s)
			local excludedGoodyHuts = {};
			local excludeGoodyHutsConfig = GameConfiguration.GetValue("EXCLUDE_GOODY_HUTS");
			if(excludeGoodyHutsConfig and #excludeGoodyHutsConfig > 0) then
				print(#excludeGoodyHutsConfig .. " Tribal Village reward(s) marked as 'excluded':");
				local iNumGoodyHuts = 0;
				local sRuleset = GameConfiguration.GetValue("RULESET");
				local sDomain = "StandardGoodyHuts";
				if (sRuleset == "RULESET_EXPANSION_1") then sDomain = "Expansion1GoodyHuts"; end
				if (sRuleset == "RULESET_EXPANSION_2") then sDomain = "Expansion2GoodyHuts"; end
				local sQuery = "SELECT * FROM TribalVillages WHERE Domain = ?";
				local tGoodyHuts = DB.ConfigurationQuery(sQuery, sDomain);
				for i, v in ipairs(tGoodyHuts) do
					iNumGoodyHuts = iNumGoodyHuts + 1;
				end

				if (#excludeGoodyHutsConfig == iNumGoodyHuts) then
					print(" *** All available Tribal Village reward(s) for the selected ruleset marked as 'excluded'; enabling option 'No Tribal Villages' to attempt to ensure total exclusion");
					GameConfiguration.SetValue("GAME_NO_GOODY_HUTS", true);
				end

				GameConfiguration.SetValue("GOODYHUTS_EXCLUDED", 1);
				local sPrefix = "EXCLUDE_"
				for i, v in ipairs(excludeGoodyHutsConfig) do
					local sGHSetting = sPrefix .. v;
					GameConfiguration.SetValue(sGHSetting, 1);
					print(" - " .. sGHSetting);
				end
			else
				print("No Tribal Village rewards have been marked as 'excluded'.");
			end
			local tExcludeHostileVillagers = { 
				"EXCLUDE_GOODYHUT_LOW_HOSTILITY_VILLAGERS",
				"EXCLUDE_GOODYHUT_MID_HOSTILITY_VILLAGERS", 
				"EXCLUDE_GOODYHUT_HIGH_HOSTILITY_VILLAGERS", 
				"EXCLUDE_GOODYHUT_MAX_HOSTILITY_VILLAGERS"
			};
			local bNoBarbarians = GameConfiguration.GetValue("GAME_NO_BARBARIANS");
			if bNoBarbarians then
				GameConfiguration.SetValue("GOODYHUTS_EXCLUDED", 1);
				print("The 'No Barbarians' setup option is enabled; ensuring " .. #tExcludeHostileVillagers .. " defined hostile villager reward(s) are disabled . . .")
				for i, v in ipairs(tExcludeHostileVillagers) do
					GameConfiguration.SetValue(v, 1);
					print(" - " .. v);
				end
			end
			-- < EGHV
            HostGame();
		end
	end
end

-- ===========================================================================
function ShowCityStateWarning(showLeaderPoolWarningNext:boolean)
    if showLeaderPoolWarningNext then
        m_pWarningPopup:ShowOkCancelDialog(Locale.Lookup("LOC_CITY_STATE_PICKER_TOO_FEW_WARNING"), ShowLeaderPoolWarning);
    else
        m_pWarningPopup:ShowOkCancelDialog(Locale.Lookup("LOC_CITY_STATE_PICKER_TOO_FEW_WARNING"), HostGame);
    end
end

-- ===========================================================================
function ShowLeaderPoolWarning()
    m_pWarningPopup:ShowOkCancelDialog(Locale.Lookup("LOC_LEADER_POOL_TOO_FEW_WARNING"), HostGame);
end

-- ===========================================================================
function HostGame()
	-- Start a normal game
	UI.PlaySound("Set_View_3D");
	Network.HostGame(ServerType.SERVER_TYPE_NONE);
end

-- ===========================================================================
function ShouldShowCityStatesWarning()
	local kParameters:table = g_GameParameters["Parameters"];

    -- No City-States for this game so don't worry about it
	if kParameters["CityStates"] == nil then
		return false;
	end

	local cityStateSlots:number = kParameters["CityStateCount"].Value;
	local totalCityStates:number = #kParameters["CityStates"].AllValues;
	local excludedCityStates:number = kParameters["CityStates"].Value ~= nil and #kParameters["CityStates"].Value or 0;

    -- Too few city-states selected in the city-state picker
	if (totalCityStates - excludedCityStates) < cityStateSlots then
		return true;
	end

	return false;
end

-- ===========================================================================
function ShouldShowLeaderPoolWarning()
    -- Determine how many players are trying to use leader pool 1 and 2
    local numPool1Players:number = 0;
    local numPool2Players:number = 0
    local player_ids = GameConfiguration.GetParticipatingPlayerIDs();
    for i, player_id in ipairs(player_ids) do	
	    local playerConfig = PlayerConfigurations[player_id];
	    if(playerConfig) then
            local pool_id:number = playerConfig:GetLeaderRandomPoolID();
			if pool_id == LeaderRandomPoolTypes.LEADER_RANDOM_POOL_1 then
				numPool1Players = numPool1Players + 1;
			elseif pool_id == LeaderRandomPoolTypes.LEADER_RANDOM_POOL_2 then
				numPool2Players = numPool2Players + 1;
	        end
        end
    end

    local kParameters:table = g_GameParameters["Parameters"];

    -- Check if leader pool 1 has enough leaders for all the players who selected it
    if numPool1Players > 0 then
        local kPool1Param:table = kParameters["LeaderPool1"];
        if kPool1Param then
            if kPool1Param.Value ~= nil then
                local numLeadersInPool:number = #kPool1Param.AllValues - #kPool1Param.Value;
                if numLeadersInPool ~= 0 and numPool1Players > numLeadersInPool then
                    return true;
                end
            end
        end
    end

    -- Check if leader pool 2 has enough leaders for all the players who selected it
    if numPool2Players > 0 then
        local kPool2Param:table = kParameters["LeaderPool2"];
        if kPool2Param then
            if kPool2Param.Value ~= nil then
                local numLeadersInPool:number = #kPool2Param.AllValues - #kPool2Param.Value;
                if numLeadersInPool ~= 0 and numPool2Players > numLeadersInPool then
                    return true;
                end
            end
        end
    end

    return false;
end

----------------------------------------------------------------    
function OnBackButton()
	if(m_AdvancedMode) then
		Controls.CreateGameWindow:SetHide(false);
		Controls.AdvancedOptionsWindow:SetHide(true);
		Controls.LoadConfig:SetHide(true);
		Controls.SaveConfig:SetHide(true);
		Controls.ButtonStack:CalculateSize();
		
		UpdateCivLeaderToolTip();					-- Need to make sure we update our placard/flyout card if we make a change in advanced setup and then come back
		m_AdvancedMode = false;		
	else
		LuaEvents.MapSelect_ClearMapData();
		UIManager:DequeuePopup( MapSelectWindow );
		UIManager:DequeuePopup( ContextPtr );
		Controls.NoGameModesContainer:SetHide(false);
	end
end

-- ===========================================================================
--	Realize the animated flyouts with description, icons, and portraits for 
--  the currently hovered game mode toggle.
-- ===========================================================================
function OnGameModeMouseEnter(kGameModeData : table)
	m_gameModeToolTipHeaderIM:ResetInstances();
	m_gameModeToolTipHeaderIconIM:ResetInstances();
	if(Controls.GameModeToolTipSlide:IsReversing())then
		Controls.GameModeSlide:Reverse();
		Controls.GameModeAlpha:Reverse();
		Controls.GameModeToolTipSlide:Reverse();
		Controls.GameModeToolTipAlpha:Reverse();
	else
		Controls.GameModeSlide:Play();
		Controls.GameModeAlpha:Play();
		Controls.GameModeToolTipSlide:Play();
		Controls.GameModeToolTipAlpha:Play();
	end
	local gameModeHeader : table = m_gameModeToolTipHeaderIM:GetInstance();
	gameModeHeader.Header:SetText(Locale.Lookup(kGameModeData.RawName));

	local gameModeDescription : table = m_gameModeToolTipHeaderIconIM:GetInstance();
	gameModeDescription.Description:SetText(kGameModeData.Description);
	gameModeDescription.Header:SetHide(true);

	local gameModeInfo : table = GetGameModeInfo(kGameModeData.ConfigurationId);
	if(gameModeInfo ~= nil)then
		gameModeDescription.Icon:SetIcon(gameModeInfo.Icon);

		if(gameModeInfo.UnitIcon)then
			local gameModeUnitDescription : table = m_gameModeToolTipHeaderIconIM:GetInstance();
			gameModeUnitDescription.Description:SetText(Locale.Lookup(gameModeInfo.UnitDescription));
			gameModeUnitDescription.Icon:SetIcon(gameModeInfo.UnitIcon);
			gameModeUnitDescription.Header:SetText(Locale.ToUpper(gameModeInfo.UnitName));
		end
		if(gameModeInfo.Portrait)then
			Controls.GameModeImage:SetTexture(gameModeInfo.Portrait);
		end
		if(gameModeInfo.Background)then
			Controls.GameModeBG:SetTexture(gameModeInfo.Background);
		end
	end
end

function OnGameModeMouseExit(kGameModeData : table)
	if(not Controls.GameModeToolTipSlide:IsReversing())then
		Controls.GameModeSlide:Reverse();
		Controls.GameModeAlpha:Reverse();
		Controls.GameModeToolTipSlide:Reverse();
		Controls.GameModeToolTipAlpha:Reverse();
	else
		Controls.GameModeSlide:Play();
		Controls.GameModeAlpha:Play();
		Controls.GameModeToolTipSlide:Play();
		Controls.GameModeToolTipAlpha:Play();
	end
end

-- ===========================================================================
function OnLoadConfig()

	local loadGameMenu = ContextPtr:LookUpControl( "/FrontEnd/MainMenu/LoadGameMenu" );
	local kParameters = {
		FileType = SaveFileTypes.GAME_CONFIGURATION
	};

	UIManager:QueuePopup(loadGameMenu, PopupPriority.Current, kParameters);
end

-- ===========================================================================
function OnSaveConfig()

	local saveGameMenu = ContextPtr:LookUpControl( "/FrontEnd/MainMenu/SaveGameMenu" );
	local kParameters = {
		FileType = SaveFileTypes.GAME_CONFIGURATION
	};
    
	UIManager:QueuePopup(saveGameMenu, PopupPriority.Current, kParameters);	
end

----------------------------------------------------------------    
-- ===========================================================================
--	Handle Window Sizing
-- ===========================================================================

function Resize()
	local screenX, screenY:number = UIManager:GetScreenSizeVal();
	if(screenY >= MIN_SCREEN_Y + (Controls.LogoContainer:GetSizeY() + Controls.LogoContainer:GetOffsetY() * 2)) then
		Controls.MainWindow:SetSizeY(screenY - (Controls.LogoContainer:GetSizeY() + Controls.LogoContainer:GetOffsetY() * 2));
		Controls.CreateGameWindow:SetSizeY(SCREEN_OFFSET_Y + Controls.MainWindow:GetSizeY() - (Controls.ButtonStack:GetSizeY() + Controls.LogoContainer:GetSizeY()));
		Controls.AdvancedOptionsWindow:SetSizeY(SCREEN_OFFSET_Y + Controls.MainWindow:GetSizeY() - (Controls.ButtonStack:GetSizeY() + Controls.LogoContainer:GetSizeY()));
	else
		Controls.MainWindow:SetSizeY(screenY);
		Controls.CreateGameWindow:SetSizeY(MIN_SCREEN_OFFSET_Y + Controls.MainWindow:GetSizeY() - (Controls.ButtonStack:GetSizeY()));
		Controls.AdvancedOptionsWindow:SetSizeY(MIN_SCREEN_OFFSET_Y + Controls.MainWindow:GetSizeY() - (Controls.ButtonStack:GetSizeY()));
	end

	local iSidebarSize = Controls.CreateGameWindow:GetSizeY();
	if iSidebarSize > MAX_SIDEBAR_Y then
		iSidebarSize = MAX_SIDEBAR_Y;
	end
	Controls.BasicPlacardContainer:SetSizeY(iSidebarSize);
	Controls.BasicTooltipContainer:SetSizeY(iSidebarSize);
	Controls.GameModePlacardContainer:SetSizeY(iSidebarSize);
	Controls.GameModeTooltipContainer:SetSizeY(iSidebarSize);
end

-- ===========================================================================
function OnUpdateUI( type:number, tag:string, iData1:number, iData2:number, strData1:string )   
  if type == SystemUpdateUI.ScreenResize then
    Resize();
  end
end

-- ===========================================================================
function OnBeforeMultiplayerInviteProcessing()
	-- We're about to process a game invite.  Get off the popup stack before we accidentally break the invite!
	UIManager:DequeuePopup( ContextPtr );
end

-- ===========================================================================
function OnShutdown()
	Events.FinishedGameplayContentConfigure.Remove(OnFinishedGameplayContentConfigure);
	Events.SystemUpdateUI.Remove( OnUpdateUI );
	Events.BeforeMultiplayerInviteProcessing.Remove( OnBeforeMultiplayerInviteProcessing );

	LuaEvents.MapSelect_SetMapByValue.Remove( OnSetMapByValue );
	LuaEvents.MultiSelectWindow_SetParameterValues.Remove(OnSetParameterValues);
	LuaEvents.CityStatePicker_SetParameterValues.Remove(OnSetParameterValues);
    LuaEvents.CityStatePicker_SetParameterValue.Remove(OnSetParameterValue);
	LuaEvents.LeaderPicker_SetParameterValues.Remove(OnSetParameterValues);
	
	LuaEvents.GoodyHutPicker_SetParameterValues.Remove(OnSetParameterValues);				-- C6GUE : EGHV
	LuaEvents.NaturalWonderPicker_SetParameterValues.Remove(OnSetParameterValues);			-- C6GUE : ENWS
end

-- ===========================================================================
--
-- ===========================================================================
function Initialize()

	ContextPtr:SetShutdown( OnShutdown );
	ContextPtr:SetInputHandler( OnInputHandler, true );
	ContextPtr:SetShowHandler( OnShow );
	ContextPtr:SetHideHandler( OnHide );

	Controls.AddAIButton:RegisterCallback( Mouse.eLClick, OnAddAIButton );
	Controls.AddAIButton:RegisterCallback( Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
	Controls.AdvancedSetupButton:RegisterCallback( Mouse.eLClick, OnAdvancedSetup );
	Controls.AdvancedSetupButton:RegisterCallback( Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
	Controls.DefaultButton:RegisterCallback( Mouse.eLClick, OnDefaultButton);
	Controls.DefaultButton:RegisterCallback( Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
	Controls.StartButton:RegisterCallback( Mouse.eLClick, OnStartButton );
	Controls.StartButton:RegisterCallback( Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
	Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnBackButton );
	Controls.CloseButton:RegisterCallback( Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
	Controls.LoadConfig:RegisterCallback( Mouse.eLClick, OnLoadConfig );
	Controls.LoadConfig:RegisterCallback( Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
	Controls.SaveConfig:RegisterCallback( Mouse.eLClick, OnSaveConfig );
	Controls.SaveConfig:RegisterCallback( Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
	Controls.MapSelectButton:RegisterCallback( Mouse.eLClick, OnMapSelect );
	Controls.MapSelectButton:RegisterCallback( Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
	Controls.ConflictConfirmButton:RegisterCallback( Mouse.eLClick, function() Controls.ConflictPopup:SetHide(true); end);
	Controls.ConflictConfirmButton:RegisterCallback( Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
	
	Events.FinishedGameplayContentConfigure.Add(OnFinishedGameplayContentConfigure);
	Events.SystemUpdateUI.Add( OnUpdateUI );
	Events.BeforeMultiplayerInviteProcessing.Add( OnBeforeMultiplayerInviteProcessing );

	LuaEvents.MapSelect_SetMapByValue.Add( OnSetMapByValue );
	LuaEvents.MultiSelectWindow_SetParameterValues.Add(OnSetParameterValues);
	LuaEvents.CityStatePicker_SetParameterValues.Add(OnSetParameterValues);
    LuaEvents.CityStatePicker_SetParameterValue.Add(OnSetParameterValue);
	LuaEvents.LeaderPicker_SetParameterValues.Add(OnSetParameterValues);
	
	LuaEvents.GoodyHutPicker_SetParameterValues.Add(OnSetParameterValues);				-- C6GUE : EGHV
	LuaEvents.NaturalWonderPicker_SetParameterValues.Add(OnSetParameterValues);			-- C6GUE : ENWS

	Resize();
end
Initialize();

--[[ =========================================================================
	end modified AdvancedSetup.lua frontend script
=========================================================================== ]]
