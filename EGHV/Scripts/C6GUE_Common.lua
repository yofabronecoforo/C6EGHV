--[[ =========================================================================
	C6GUE : Gameplay and Usability Enhancements for Civilization VI
	Copyright (C) 2020-2021 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin C6GUE_Common.lua shared components
=========================================================================== ]]

--[[ =========================================================================
	function GetContentFlags() : query available content flags
=========================================================================== ]]
function GetContentFlags()
    print("C6GUE: Parsing contents of Configuration table ContentFlags . . .");
    local t = {};
    local sQuery = "SELECT * from ContentFlags";
	local tResult = DB.ConfigurationQuery(sQuery);
    if tResult and #tResult > 0 then
        local definedFlags = 0;
        for i, v in ipairs(tResult) do
            definedFlags = definedFlags + 1;
            t[i] = { Name = v.Name, Id = v.Id, CityStates = v.CityStates, GoodyHuts = v.GoodyHuts, Leaders = v.Leaders, NaturalWonders = v.NaturalWonders, SQL = v.SQL, Tooltip = v.Tooltip };
        end
        print("C6GUE: Finished parsing Configuration table ContentFlags; " .. definedFlags .. " defined content flag(s) found.");
        return t;
	else
        print("C6GUE: Configuration table ContentFlags is empty or undefined; unable to parse content flag(s).");
        return nil;
	end
end

--[[ =========================================================================
	function GetAvailableContent() : query enabled content details
=========================================================================== ]]
function GetAvailableContent(sContent)
    if (sContent ~= nil and C6GUE.ContentQueries[sContent] ~= nil) then
        local sChecking:string = "C6GUE: * ";
        local sQuery:string = C6GUE.ContentQueries[sContent];
        local tResult:table = DB.ConfigurationQuery(sQuery);
        if(tResult and #tResult > 0) then
            C6GUE[sContent].IsEnabled = true;
            C6GUE.ActiveItems = C6GUE.ActiveItems + 1;
            sChecking = sChecking .. sContent .. " is active.";
        else
            sChecking = sChecking .. sContent .. " is 'NOT active'.";
        end
        print(sChecking);
    end
end

--[[ =========================================================================
	function GetToolTipText() : refresh tooltip text for all pickers based on available content
=========================================================================== ]]
function GetToolTipText()
    print("C6GUE: Refreshing ruleset-based tooltip text for picker window buttons . . .");
    -- start with a header and Standard content for all picker tooltips
    for k, v in pairs(C6GUE.CityStatesTooltip) do C6GUE.CityStatesTooltip[k] = Locale.Lookup("LOC_STANDARD_TT"); end
    for k, v in pairs(C6GUE.GoodyHutsTooltip) do C6GUE.GoodyHutsTooltip[k] = Locale.Lookup("LOC_STANDARD_TT"); end
    for k, v in pairs(C6GUE.LeadersTooltip) do C6GUE.LeadersTooltip[k] = Locale.Lookup("LOC_STANDARD_TT"); end
    for k, v in pairs(C6GUE.NaturalWondersTooltip) do C6GUE.NaturalWondersTooltip[k] = Locale.Lookup("LOC_STANDARD_TT"); end
    -- update tooltip text based on enabled content
    for i, v in ipairs(C6GUE.ValidContent) do
        if C6GUE[v.Name].IsEnabled then
            if (v.Name ~= "Expansion1" and v.Name ~= "Expansion2") then       -- non-Expansion content generally applies to all rulesets
                if C6GUE[v.Name].ProvidesCityStates then
                    for k, x in pairs(C6GUE.CityStatesTooltip) do C6GUE.CityStatesTooltip[k] = C6GUE.CityStatesTooltip[k] .. Locale.Lookup(v.Tooltip); end
                end
                if C6GUE[v.Name].ProvidesGoodyHuts then
                    for k, x in pairs(C6GUE.GoodyHutsTooltip) do C6GUE.GoodyHutsTooltip[k] = C6GUE.GoodyHutsTooltip[k] .. Locale.Lookup(v.Tooltip); end
                end
                if C6GUE[v.Name].ProvidesLeaders then
                    for k, x in pairs(C6GUE.LeadersTooltip) do C6GUE.LeadersTooltip[k] = C6GUE.LeadersTooltip[k] .. Locale.Lookup(v.Tooltip); end
                end
                if C6GUE[v.Name].ProvidesNaturalWonders then
                    for k, x in pairs(C6GUE.NaturalWondersTooltip) do C6GUE.NaturalWondersTooltip[k] = C6GUE.NaturalWondersTooltip[k] .. Locale.Lookup(v.Tooltip); end
                end
            elseif (v.Name == "Expansion1") then       -- Expansion 1 and beyond
                if C6GUE[v.Name].ProvidesCityStates then
                    C6GUE.CityStatesTooltip["RULESET_EXPANSION_1"] = C6GUE.CityStatesTooltip["RULESET_EXPANSION_1"] .. Locale.Lookup(v.Tooltip);
                    C6GUE.CityStatesTooltip["RULESET_EXPANSION_2"] = C6GUE.CityStatesTooltip["RULESET_EXPANSION_2"] .. Locale.Lookup(v.Tooltip);
                end
                if C6GUE[v.Name].ProvidesGoodyHuts then
                    C6GUE.GoodyHutsTooltip["RULESET_EXPANSION_1"] = C6GUE.GoodyHutsTooltip["RULESET_EXPANSION_1"] .. Locale.Lookup(v.Tooltip);
                    C6GUE.GoodyHutsTooltip["RULESET_EXPANSION_2"] = C6GUE.GoodyHutsTooltip["RULESET_EXPANSION_2"] .. Locale.Lookup(v.Tooltip);
                end
                if C6GUE[v.Name].ProvidesLeaders then
                    C6GUE.LeadersTooltip["RULESET_EXPANSION_1"] = C6GUE.LeadersTooltip["RULESET_EXPANSION_1"] .. Locale.Lookup(v.Tooltip);
                    C6GUE.LeadersTooltip["RULESET_EXPANSION_2"] = C6GUE.LeadersTooltip["RULESET_EXPANSION_2"] .. Locale.Lookup(v.Tooltip);
                end
                if C6GUE[v.Name].ProvidesNaturalWonders then
                    C6GUE.NaturalWondersTooltip["RULESET_EXPANSION_1"] = C6GUE.NaturalWondersTooltip["RULESET_EXPANSION_1"] .. Locale.Lookup(v.Tooltip);
                    C6GUE.NaturalWondersTooltip["RULESET_EXPANSION_2"] = C6GUE.NaturalWondersTooltip["RULESET_EXPANSION_2"] .. Locale.Lookup(v.Tooltip);
                end
            elseif (v.Name == "Expansion2") then       -- Expansion 2 and beyond
                if C6GUE[v.Name].ProvidesCityStates then C6GUE.CityStatesTooltip["RULESET_EXPANSION_2"] = C6GUE.CityStatesTooltip["RULESET_EXPANSION_2"] .. Locale.Lookup(v.Tooltip); end
                if C6GUE[v.Name].ProvidesGoodyHuts then C6GUE.GoodyHutsTooltip["RULESET_EXPANSION_2"] = C6GUE.GoodyHutsTooltip["RULESET_EXPANSION_2"] .. Locale.Lookup(v.Tooltip); end
                if C6GUE[v.Name].ProvidesLeaders then C6GUE.LeadersTooltip["RULESET_EXPANSION_2"] = C6GUE.LeadersTooltip["RULESET_EXPANSION_2"] .. Locale.Lookup(v.Tooltip); end
                if C6GUE[v.Name].ProvidesNaturalWonders then C6GUE.NaturalWondersTooltip["RULESET_EXPANSION_2"] = C6GUE.NaturalWondersTooltip["RULESET_EXPANSION_2"] .. Locale.Lookup(v.Tooltip); end
            end
        end
    end
    for k, v in pairs(C6GUE.CityStatesTooltip) do print("C6GUE: CityStatesTooltip[" .. k .. "]: " .. v); end
    for k, v in pairs(C6GUE.GoodyHutsTooltip) do print("C6GUE: GoodyHutsTooltip[" .. k .. "]: " .. v); end
    for k, v in pairs(C6GUE.LeadersTooltip) do print("C6GUE: LeadersTooltip[" .. k .. "]: " .. v); end
    for k, v in pairs(C6GUE.NaturalWondersTooltip) do print("C6GUE: NaturalWondersTooltip[" .. k .. "]: " .. v); end
    print("C6GUE: Finished refreshing tooltip text to reflect available content.");
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
	context sharing
=========================================================================== ]]
ExposedMembers.C6GUE = ExposedMembers.C6GUE or {};

C6GUE = ExposedMembers.C6GUE;

C6GUE.ActiveItems = ExposedMembers.C6GUE.ActiveItems or 0;
C6GUE.KnownItems = ExposedMembers.C6GUE.KnownItems or 0;
C6GUE.ValidItems = ExposedMembers.C6GUE.ValidItems or 0;

C6GUE.CityStatesTooltip = ExposedMembers.C6GUE.CityStatesTooltip or { ["RULESET_STANDARD"] = "", ["RULESET_EXPANSION_1"] = "", ["RULESET_EXPANSION_2"] = "" };
C6GUE.GoodyHutsTooltip = ExposedMembers.C6GUE.GoodyHutsTooltip or { ["RULESET_STANDARD"] = "", ["RULESET_EXPANSION_1"] = "", ["RULESET_EXPANSION_2"] = "" };
C6GUE.LeadersTooltip = ExposedMembers.C6GUE.LeadersTooltip or { ["RULESET_STANDARD"] = "", ["RULESET_EXPANSION_1"] = "", ["RULESET_EXPANSION_2"] = "" };
C6GUE.NaturalWondersTooltip = ExposedMembers.C6GUE.NaturalWondersTooltip or { ["RULESET_STANDARD"] = "", ["RULESET_EXPANSION_1"] = "", ["RULESET_EXPANSION_2"] = "" };

C6GUE.ContentQueries = ExposedMembers.C6GUE.ContentQueries or {};
C6GUE.ValidContent = ExposedMembers.C6GUE.ValidContent or {};

C6GUE.ContentChecked = ExposedMembers.C6GUE.ContentChecked or false;
if not C6GUE.ContentChecked then
    C6GUE.ValidContent = GetContentFlags();

    print("C6GUE: Validating available content . . .");
    for i, v in ipairs(C6GUE.ValidContent) do       -- check for known content
        C6GUE.ContentQueries[v.Name] = v.SQL;       -- add this content to the table of SQL queries indexed by name
        C6GUE.KnownItems = C6GUE.KnownItems + 1;        -- increment the known items counter
        C6GUE[v.Name] = ExposedMembers.C6GUE[v.Name] or {};     -- table for this item
        C6GUE[v.Name].IsEnabled = ExposedMembers.C6GUE[v.Name].IsEnabled or false;      -- is this item enabled?
        C6GUE[v.Name].ProvidesCityStates = ExposedMembers.C6GUE[v.Name].ProvidesCityStates or false;
        C6GUE[v.Name].ProvidesGoodyHuts = ExposedMembers.C6GUE[v.Name].ProvidesGoodyHuts or false;
        C6GUE[v.Name].ProvidesLeaders = ExposedMembers.C6GUE[v.Name].ProvidesLeaders or false;
        C6GUE[v.Name].ProvidesNaturalWonders = ExposedMembers.C6GUE[v.Name].ProvidesNaturalWonders or false;
        C6GUE[v.Name].WasChecked = ExposedMembers.C6GUE[v.Name].WasChecked or false;        -- was this item checked?
        if not C6GUE[v.Name].WasChecked then
            GetAvailableContent(v.Name);                    -- check for this content
            if (v.CityStates > 0) then C6GUE[v.Name].ProvidesCityStates = true; end
            if (v.GoodyHuts > 0) then C6GUE[v.Name].ProvidesGoodyHuts = true; end
            if (v.Leaders > 0) then C6GUE[v.Name].ProvidesLeaders = true; end
            if (v.NaturalWonders > 0) then C6GUE[v.Name].ProvidesNaturalWonders = true; end
            C6GUE[v.Name].WasChecked = true;                -- mark this content as checked
            C6GUE.ValidItems = C6GUE.ValidItems + 1;        -- increment the valid items counter
        end
    end
    C6GUE.ContentChecked = true;        -- set to true when all known content has been individually checked
    print("C6GUE: Finished validating " .. C6GUE.ValidItems .. " of " .. C6GUE.KnownItems .. " known item(s): [ " .. C6GUE.ActiveItems .. " ] active.");
    
    GetToolTipText();
end

--[[ =========================================================================
	references
=========================================================================== ]]
-- 2021/05/14 : Modding.IsModActive() does not appear to work in Frontend context, hence the stuff above
-- local bIsExpansion1:boolean = Modding.IsModActive("1B28771A-C749-434B-9053-D1380C553DE9");
-- local bIsExpansion2:boolean = Modding.IsModActive("4873eb62-8ccc-4574-b784-dda455e74e68");

--[[ =========================================================================
    end C6GUE_Common.lua shared components
=========================================================================== ]]
