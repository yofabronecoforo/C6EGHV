--[[ =========================================================================
	EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (C) 2020-2023 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	C6GUE : Gameplay and Usability Enhancements for Civilization VI
	Copyright (C) 2020-2023 zzragnar0kzz
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
C6GUE.EGHV = C6GUE.EGHV or {};
C6GUE.ENWS = C6GUE.ENWS or {};
C6GUE.EGHV.IsEnabled = C6GUE.EGHV.IsEnabled or Modding.IsModEnabled("a4b1fac6-8c9e-4873-a1c1-7ddf08dbbf11");
C6GUE.ENWS.IsEnabled = C6GUE.ENWS.IsEnabled or Modding.IsModEnabled("d0afae5b-02f8-4d01-bd54-c2bbc3d89858");

--[[ =========================================================================
	member function TestFunction() : print some generic output
=========================================================================== ]]
C6GUE.TestFunction = ExposedMembers.C6GUE.TestFunction or function()
    print("Entering C6GUE.TestFunction() . . .");
end

--[[ =========================================================================
	function UpdateTooltipText() : append localized text to picker tooltips
=========================================================================== ]]
function UpdateTooltipText( r, s, t )
	if t.CityStates then C6GUE.CityStatesTooltip[r] = C6GUE.CityStatesTooltip[r] .. s; end
	if t.GoodyHuts then C6GUE.GoodyHutsTooltip[r] = C6GUE.GoodyHutsTooltip[r] .. s; end
	if t.Leaders then C6GUE.LeadersTooltip[r] = C6GUE.LeadersTooltip[r] .. s; end
	if t.NaturalWonders then C6GUE.NaturalWondersTooltip[r] = C6GUE.NaturalWondersTooltip[r] .. s; end
end

--[[ =========================================================================
	function RefreshActiveContentTooltips() : validate active content and set tooltip strings
=========================================================================== ]]
function RefreshActiveContentTooltips()
	-- 
	C6GUE.KnownItems, C6GUE.ActiveItems = 0, 0;
	local sStandard = Locale.Lookup("LOC_STANDARD_TT");
	-- (re)set exposed tables
    C6GUE.CityStatesTooltip = { ["RULESET_STANDARD"] = sStandard, ["RULESET_EXPANSION_1"] = sStandard, ["RULESET_EXPANSION_2"] = sStandard };
    C6GUE.GoodyHutsTooltip = { ["RULESET_STANDARD"] = sStandard, ["RULESET_EXPANSION_1"] = sStandard, ["RULESET_EXPANSION_2"] = sStandard };
    C6GUE.LeadersTooltip = { ["RULESET_STANDARD"] = sStandard, ["RULESET_EXPANSION_1"] = sStandard, ["RULESET_EXPANSION_2"] = sStandard };
    C6GUE.NaturalWondersTooltip = { ["RULESET_STANDARD"] = sStandard, ["RULESET_EXPANSION_1"] = sStandard, ["RULESET_EXPANSION_2"] = sStandard };
	-- 
	print("EGHV: Querying Configuration table ContentFlags for known content . . .");
	local tContent = DB.ConfigurationQuery("SELECT DISTINCT * from ContentFlags");
	if tContent and #tContent > 0 then 
		C6GUE.KnownItems = #tContent;
		print(string.format("EGHV: Identified %d known item(s); parsing for active content and updating picker tooltip text accordingly . . .", C6GUE.KnownItems));
		for i, v in ipairs(tContent) do 
			if (Modding.IsModInstalled(v.GUID) and Modding.IsModEnabled(v.GUID)) then 
				C6GUE.ActiveItems = C6GUE.ActiveItems + 1;
				local sTooltip = Locale.Lookup(v.Tooltip);
				if v.Base then UpdateTooltipText("RULESET_STANDARD", sTooltip, v); end
				if v.XP1 then UpdateTooltipText("RULESET_EXPANSION_1", sTooltip, v); end
				if v.XP2 then UpdateTooltipText("RULESET_EXPANSION_2", sTooltip, v); end
			end
		end
		print(string.format("EGHV: Picker tooltip text updated to reflect %d active of %d known item(s); proceeding . . .", C6GUE.ActiveItems, C6GUE.KnownItems));
	else
		print("EGHV: Configuration table ContentFlags is empty or undefined, proceeding without parsing content flag(s) . . .");
	end
end

--[[ =========================================================================
	function UpdateButtonToolTip() : update a specific picker's tooltip text based on selected ruleset
=========================================================================== ]]
function UpdateButtonToolTip(parameterId)
    local sRuleset = GameConfiguration.GetValue("RULESET");
	if (parameterId == "CityStates") then return C6GUE.CityStatesTooltip[sRuleset];
	elseif (parameterId == "LeaderPool1" or parameterId == "LeaderPool2") then return C6GUE.LeadersTooltip[sRuleset];
	elseif (parameterId == "GoodyHutConfig" and Modding.IsModEnabled("a4b1fac6-8c9e-4873-a1c1-7ddf08dbbf11")) then return C6GUE.GoodyHutsTooltip[sRuleset];
	elseif (parameterId == "NaturalWonders" and Modding.IsModEnabled("d0afae5b-02f8-4d01-bd54-c2bbc3d89858")) then return C6GUE.NaturalWondersTooltip[sRuleset];
	else
		if (parameterId == "NaturalWonders") then return C6GUE.NaturalWondersTooltip[sRuleset];
		else return;
		end
	end
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
