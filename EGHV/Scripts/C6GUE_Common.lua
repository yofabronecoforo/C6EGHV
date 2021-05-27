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
