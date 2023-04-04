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
	begin modified Mods.lua frontend script
=========================================================================== ]]
-- print("C6GUE: Loading modified Mods.lua . . .");
-------------------------------------------------
-- Mods Browser Screen
-------------------------------------------------
include( "InstanceManager" );
include( "SupportFunctions" );
include( "PopupDialog" );

-- C6GUE shared components
-- include("C6GUE_Common");
-- ExposedMembers.C6GUE = ExposedMembers.C6GUE or {};
-- C6GUE = ExposedMembers.C6GUE;
-- C6GUE.TestFunction();

LOC_MODS_SEARCH_NAME = Locale.Lookup("LOC_MODS_SEARCH_NAME");

g_ModListingsManager = InstanceManager:new("ModInstance", "ModInstanceRoot", Controls.ModListingsStack);
g_SubscriptionsListingsManager = InstanceManager:new("SubscriptionInstance", "SubscriptionInstanceRoot", Controls.SubscriptionListingsStack);
g_DependencyListingsManager = InstanceManager:new("ReferenceItemInstance", "Item", Controls.ModDependencyItemsStack);


g_SearchContext = "Mods";
g_SearchQuery = nil;
g_ModListings = nil;			-- An array of pairs containing the mod handle and its associated listing.
g_SelectedModHandle = nil;		-- The currently selected mod entry.
g_CurrentListingsSort = nil;	-- The current method of sorting the mod listings.
g_ModSubscriptions = nil;
g_SubscriptionsSortingMap = {};

local MIN_SCREEN_Y				:number = 768;

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function RefreshModGroups()
	local groups = Modding.GetModGroups();
	for i, v in ipairs(groups) do
		v.DisplayName = Locale.Lookup(v.Name);
	end
	table.sort(groups, function(a,b)
		if(a.SortIndex == b.SortIndex) then
			-- Sort by Name.
			return Locale.Compare(a.DisplayName, b.DisplayName) == -1;
		else
			return a.SortIndex < b.SortIndex;
		end
	end);	
	
	local g = Modding.GetCurrentModGroup();

	local comboBox = Controls.ModGroupPullDown;
	comboBox:ClearEntries();
	for i, v in ipairs(groups) do
		local controlTable = {};
		comboBox:BuildEntry( "InstanceOne", controlTable );
		controlTable.Button:LocalizeAndSetText(v.Name);
	
		controlTable.Button:RegisterCallback(Mouse.eLClick, function()
			Modding.SetCurrentModGroup(v.Handle);
			RefreshModGroups();
			RefreshListings();
		end);	

		if(v.Handle == g) then
			comboBox:GetButton():SetText(v.DisplayName);
			Controls.DeleteModGroup:SetDisabled(not v.CanDelete);
		end
	end

	comboBox:CalculateInternals();
end
---------------------------------------------------------------------------
---------------------------------------------------------------------------
function RefreshListings()
	local mods = Modding.GetInstalledMods();

	g_ModListings = {};
	g_ModListingsManager:ResetInstances();

	Controls.EnableAll:SetDisabled(true);
	Controls.DisableAll:SetDisabled(true);

	if(mods == nil or #mods == 0) then
		Controls.ModListings:SetHide(true);
		Controls.NoModsInstalled:SetHide(false);
	else
		Controls.ModListings:SetHide(false);
		Controls.NoModsInstalled:SetHide(true);

		PreprocessListings(mods);

		mods = FilterListings(mods);

		SortListings(mods);

		local hasEnabledMods = false;
		local hasDisabledMods = false;

		for i,v in ipairs(mods) do		
			local instance = g_ModListingsManager:GetInstance();

			table.insert(g_ModListings, {v.Handle, instance});

			local handle = v.Handle;

			instance.ModInstanceButton:RegisterCallback(Mouse.eLClick, function()
				SelectMod(handle);
			end);

			local name = TruncateStringByLength(v.DisplayName, 96);
			
			if(v.Allowance == false) then
				name = name .. " [COLOR_RED](" .. Locale.Lookup("LOC_MODS_DETAILS_OWNERSHIP_NO") .. ")[ENDCOLOR]";
			end

			if(Modding.ShouldShowCompatibilityWarnings()) then
				if(not Modding.IsModCompatible(v.Handle) and not Modding.GetIgnoreCompatibilityWarnings(v.Handle)) then
					name = name .. " [COLOR_RED](" .. Locale.Lookup("LOC_MODS_DETAILS_COMPATIBLE_NOT") .. ")[ENDCOLOR]";
				end
			end

			instance.ModTitle:LocalizeAndSetText(name);

			local tooltip;
			if(#v.Teaser) then
				tooltip = Locale.Lookup(v.Teaser);
			end
			instance.ModInstanceRoot:SetToolTipString(tooltip);

			local enabled = v.Enabled;
			if(enabled) then
				hasEnabledMods = true;
				instance.ModEnabled:LocalizeAndSetText("LOC_MODS_ENABLED");
			else
				hasDisabledMods = true;
				instance.ModEnabled:SetText("[COLOR_RED]" .. Locale.Lookup("LOC_MODS_DISABLED") .. "[ENDCOLOR]");
			end

			local bOfficial = v.Official;
			local bIsMap = v.Source == "Map";
			instance.MapIcon:SetHide(not bIsMap);
			instance.OfficialIcon:SetHide(bIsMap or not bOfficial);
			instance.CommunityIcon:SetHide(bIsMap or bOfficial);
		end

		if(hasEnabledMods) then
			Controls.DisableAll:SetDisabled(false);
		end

		if(hasDisabledMods) then
			Controls.EnableAll:SetDisabled(false);
		end

		Controls.ModListingsStack:CalculateSize();
		Controls.ModListingsStack:ReprocessAnchoring();
		Controls.ModListings:CalculateInternalSize();
	end

	-- Update the selection state of each listing.
	RefreshListingsSelectionState();
	RefreshModDetails();
	-- C6GUE: check to see if a tooltip content refresh is necessary
	if C6GUE.RefreshContent then
		print("C6GUE: A queried content refresh is pending; skipping check.");
	else
		C6GUE.RefreshContent = CheckContentChanges(mods);
	end
end

---------------------------------------------------------------------------
-- Pre-process listings by translating strings or stripping tags.
---------------------------------------------------------------------------
function PreprocessListings(mods)
	for i,v in ipairs(mods) do
		v.DisplayName = Locale.Lookup(v.Name);
		v.StrippedDisplayName = Locale.StripTags(v.DisplayName);
	end
end

---------------------------------------------------------------------------
-- Filter the listings, returns filtered list.
---------------------------------------------------------------------------
function FilterListings(mods)

	local isFinalRelease = UI.IsFinalRelease();
	local showOfficialContent = Controls.ShowOfficialContent:IsChecked();
	local showCommunityContent = Controls.ShowCommunityContent:IsChecked();

	local original = mods;
	mods = {};
	for i,v in ipairs(original) do	
		-- Hide mods marked as always hidden or DLC which is not owned.
		local category = Modding.GetModProperty(v.Handle, "ShowInBrowser");
		if(category ~= "AlwaysHidden" and not (isFinalRelease and v.Allowance == false)) then
			-- Filter by selected options (currently only official and community content).
			if(v.Official and showOfficialContent) then
				table.insert(mods, v);
			elseif(not v.Official and showCommunityContent) then
				table.insert(mods, v);
			end
		end
	end

	-- Index remaining mods and filter by search query.
	if(Search.HasContext(g_SearchContext)) then
		Search.ClearData(g_SearchContext);
		for i, v in ipairs(mods) do
			Search.AddData(g_SearchContext, v.Handle, v.DisplayName, Locale.Lookup(v.Teaser or ""));
		end
		Search.Optimize(g_SearchContext);

		if(g_SearchQuery) then
			if (g_SearchQuery ~= nil and #g_SearchQuery > 0 and g_SearchQuery ~= LOC_MODS_SEARCH_NAME) then
				local include_map = {};
				local search_results = Search.Search(g_SearchContext, g_SearchQuery);
				if (search_results and #search_results > 0) then
					for i, v in ipairs(search_results) do
						include_map[tonumber(v[1])] = v[2];
					end
				end

				local original = mods;
				mods = {};
				for i,v in ipairs(original) do
					if(include_map[v.Handle]) then
						v.DisplayName = include_map[v.Handle];
						v.StrippedDisplayName = Locale.StripTags(v.DisplayName);
						table.insert(mods, v);
					end
				end
			end
		end
	end
	
	return mods;
end

---------------------------------------------------------------------------
-- Sort the listings in-place.
---------------------------------------------------------------------------
function SortListings(mods)
	if(g_CurrentListingsSort) then
		g_CurrentListingsSort(mods);
	end
end

-- Update the state of each instanced listing to reflect whether it is selected.
function RefreshListingsSelectionState()
	for i,v in ipairs(g_ModListings) do
		if(v[1] == g_SelectedModHandle) then
			v[2].ModInstanceButton:SetSelected(true);
		else
			v[2].ModInstanceButton:SetSelected(false);
		end
	end
end

function RefreshModDetails()
	if(g_SelectedModHandle == nil) then
		-- Hide details and offer up a guidance string.
		Controls.NoModSelected:SetHide(false);
		Controls.ModDetailsContainer:SetHide(true);

	else
		Controls.NoModSelected:SetHide(true);
		Controls.ModDetailsContainer:SetHide(false);

		local modHandle = g_SelectedModHandle;
		local info = Modding.GetModInfo(modHandle);

		local bIsMap = info.Source == "Map";

		if(bIsMap) then
			Controls.ModContent:LocalizeAndSetText("LOC_MODS_WORLDBUILDER_CONTENT");
		elseif(info.Official) then
			Controls.ModContent:LocalizeAndSetText("LOC_MODS_FIRAXIAN_CONTENT");
		else
			Controls.ModContent:LocalizeAndSetText("LOC_MODS_USER_CONTENT");
		end

		local compatible = Modding.IsModCompatible(modHandle);
		Controls.ModCompatibilityWarning:SetHide(compatible);
		Controls.WhitelistMod:SetHide(compatible);

		if(not compatible) then
			Controls.WhitelistMod:SetCheck(Modding.GetIgnoreCompatibilityWarnings(modHandle));
			Controls.WhitelistMod:RegisterCallback(Mouse.eLClick, function()
				Modding.SetIgnoreCompatibilityWarnings(modHandle, Controls.WhitelistMod:IsChecked());
				RefreshListings();
			end);
		end

		-- Official/Community Icons
		local bIsOfficial = info.Official;
		Controls.MapIcon:SetHide(not bIsMap);
		Controls.OfficialIcon:SetHide(bIsMap or not bIsOfficial);
		Controls.CommunityIcon:SetHide(bIsMap or bIsOfficial);

		local enableButton = Controls.EnableButton;
		local disableButton = Controls.DisableButton;
		if(info.Official and info.Allowance == false) then
			enableButton:SetHide(true);
			disableButton:SetHide(true);
		else
			local enabled = info.Enabled;
			if(enabled) then
				enableButton:SetHide(true);
				disableButton:SetHide(false);
				
				local err, xtra, sources = Modding.CanDisableMod(modHandle);
				if(err == "OK") then
					disableButton:SetDisabled(false);
					disableButton:SetToolTipString(nil);

					disableButton:RegisterCallback(Mouse.eLClick, function()
						Modding.DisableMod(modHandle);
						RefreshListings();
					end);
				else
					disableButton:SetDisabled(true);
							
					-- Generate tip w/ list of mods to enable.
					local error_suffix;

					local tip = {};
					local items = xtra or {};
					
					if(err == "OwnershipRequired") then
						error_suffix = "(" .. Locale.Lookup("LOC_MODS_DETAILS_OWNERSHIP_NO") .. ")";
					end

					if(err == "MissingDependencies") then
						tip[1] = Locale.Lookup("LOC_MODS_DISABLE_ERROR_DEPENDS");
						items = sources or {}; -- show sources of errors rather than targets of error.
					else
						tip[1] = Locale.Lookup("LOC_MODS_DISABLE_ERROR") .. err;
					end

					local unique_items = {};
					for k,ref in ipairs(items) do
						if(unique_items[ref.Id] == nil) then
							unique_items[ref.Id] = true;

							local name = ref.Id;
							if(ref.Name) then
								name = Locale.LookupBundle(ref.Name);
								if(name == nil) then
									name = Locale.Lookup(ref.Name);
								end
							end

							local item = "[ICON_BULLET] " .. name;
							if(error_suffix) then
								item = item .. " " .. error_suffix;
							end

							table.insert(tip, item);
						end
						
					end

					disableButton:SetToolTipString(table.concat(tip, "[NEWLINE]"));
				end
			else
				enableButton:SetHide(false);
				disableButton:SetHide(true);
				local err, xtra = Modding.CanEnableMod(modHandle);
				if(err == "MissingDependencies") then
					-- Don't replace xtra since we want the old list to enumerate missing mods.
					err, _ = Modding.CanEnableMod(modHandle, true);
				end

				if(err == "OK") then
					enableButton:SetDisabled(false);

					if(xtra and #xtra > 0) then
						-- Generate tip w/ list of mods to enable.
						local tip = {Locale.Lookup("LOC_MODS_ENABLE_INCLUDE")};


						local unique_items = {};
						for k,ref in ipairs(xtra) do
							if(unique_items[ref.Id] == nil) then
								unique_items[ref.Id] = true;

								local name = ref.Id;
								if(ref.Name) then
									name = Locale.LookupBundle(ref.Name);
									if(name == nil) then
										name = Locale.Lookup(ref.Name);
									end
								end

								local item = "[ICON_BULLET] " .. name;
								table.insert(tip, item);
							end	
						end

						enableButton:SetToolTipString(table.concat(tip, "[NEWLINE]"));
					else	
						enableButton:SetToolTipString(nil);
					end

					local OnEnable = function()
						Modding.EnableMod(modHandle, true);
						RefreshListings();
					end

					if(	Modding.ShouldShowCompatibilityWarnings() and 
						not Modding.IsModCompatible(modHandle) and 
						not Modding.GetIgnoreCompatibilityWarnings(modHandle)) then

						enableButton:RegisterCallback(Mouse.eLClick, function()
							m_kPopupDialog:AddText(Locale.Lookup("LOC_MODS_ENABLE_WARNING_NOT_COMPATIBLE"));
							m_kPopupDialog:AddTitle(Locale.ToUpper(Locale.Lookup("LOC_MODS_TITLE")));
							m_kPopupDialog:AddButton(Locale.Lookup("LOC_YES_BUTTON"), OnEnable, nil, nil, "PopupButtonInstanceGreen"); 
							m_kPopupDialog:AddButton(Locale.Lookup("LOC_NO_BUTTON"), nil);
							m_kPopupDialog:Open();
						end);

					else
						enableButton:RegisterCallback(Mouse.eLClick, OnEnable);
					end
				else
					enableButton:SetDisabled(true);
					
					if(err == "ContainsDuplicates") then
						enableButton:SetToolTipString(Locale.Lookup("LOC_MODS_ERROR_MOD_VERSION_ALREADY_ENABLED"));
					else
						-- Generate tip w/ list of mods to enable.
						local error_suffix;

						if(err == "OwnershipRequired") then
							error_suffix = "(" .. Locale.Lookup("LOC_MODS_DETAILS_OWNERSHIP_NO") .. ")";
						end

						local tip = {Locale.Lookup("LOC_MODS_ENABLE_ERROR")};

						local unique_items = {};
						for k,ref in ipairs(xtra) do
							if(unique_items[ref.Id] == nil) then
								unique_items[ref.Id] = true;

								local name = ref.Id;
								if(ref.Name) then
									name = Locale.LookupBundle(ref.Name);
									if(name == nil) then
										name = Locale.Lookup(ref.Name);
									end
								end

								local item = "[ICON_BULLET] " .. name;
								if(error_suffix) then
									item = item .. " " .. error_suffix;
								end
								table.insert(tip, item);
							end	
						end

						enableButton:SetToolTipString(table.concat(tip, "[NEWLINE]"));
					end		
					
				end
			end
		end

		Controls.ModTitle:LocalizeAndSetText(info.Name, 64);
		Controls.ModIdVersion:SetText(info.Id);
		if(bIsMap) then
			Controls.ModFileName:SetText(info.SourceFileName);
			Controls.ModFileName:SetHide(false);
		else
			Controls.ModFileName:SetHide(true);
		end

		local desc = Modding.GetModProperty(g_SelectedModHandle, "Description") or info.Teaser;
		if(desc) then
			desc = Modding.GetModText(g_SelectedModHandle, desc) or desc
			Controls.ModDescription:LocalizeAndSetText(desc);
			Controls.ModDescription:SetHide(false);
		else
			Controls.ModDescription:SetHide(true);
		end

		local authors = Modding.GetModProperty(g_SelectedModHandle, "Authors");
		if(authors) then
			authors = Modding.GetModText(g_SelectedModHandle, authors) or authors
			Controls.ModAuthorsValue:LocalizeAndSetText(authors);

			local width, height = Controls.ModAuthorsValue:GetSizeVal();
			Controls.ModAuthorsCaption:SetSizeY(height);
			Controls.ModAuthorsCaption:SetHide(false);
			Controls.ModAuthorsValue:SetHide(false);
		else
			Controls.ModAuthorsCaption:SetHide(true);
			Controls.ModAuthorsValue:SetHide(true);
		end

		local specialThanks = Modding.GetModProperty(g_SelectedModHandle, "SpecialThanks");
		if(specialThanks) then
			specialThanks = Modding.GetModText(g_SelectedModHandle, specialThanks) or specialThanks
			Controls.ModSpecialThanksValue:LocalizeAndSetText(specialThanks);
		
			local width, height = Controls.ModSpecialThanksValue:GetSizeVal();
			Controls.ModSpecialThanksCaption:SetSizeY(height);
			Controls.ModSpecialThanksValue:SetHide(false);
			Controls.ModSpecialThanksCaption:SetHide(false);
		
		else
			Controls.ModSpecialThanksCaption:SetHide(true);
			Controls.ModSpecialThanksValue:SetHide(true);
		end

		local created = info.Created;
		if(created) then
			Controls.ModCreatedValue:LocalizeAndSetText("{1_Created : date long}", created);
			Controls.ModCreatedCaption:SetHide(false);		
			Controls.ModCreatedValue:SetHide(false);
		else
			Controls.ModCreatedCaption:SetHide(true);
			Controls.ModCreatedValue:SetHide(true);
		end

		if(info.Official and info.Allowance ~= nil) then
			
			Controls.ModOwnershipCaption:SetHide(false);
			Controls.ModOwnershipValue:SetHide(false);
			if(info.Allowance) then
				Controls.ModOwnershipValue:SetText("[COLOR_GREEN]" .. Locale.Lookup("LOC_MODS_YES") .. "[ENDCOLOR]");
			else
				Controls.ModOwnershipValue:SetText("[COLOR_RED]" .. Locale.Lookup("LOC_MODS_NO") .. "[ENDCOLOR]");
			end
		else
			Controls.ModOwnershipCaption:SetHide(true);
			Controls.ModOwnershipValue:SetHide(true);
		end

		local affectsSavedGames = Modding.GetModProperty(g_SelectedModHandle, "AffectsSavedGames");
		if(affectsSavedGames and tonumber(affectsSavedGames) == 0) then
			Controls.ModAffectsSavedGamesValue:LocalizeAndSetText("LOC_MODS_NO");
		else
			Controls.ModAffectsSavedGamesValue:LocalizeAndSetText("LOC_MODS_YES");
		end

		local supportsSinglePlayer = Modding.GetModProperty(g_SelectedModHandle, "SupportsSinglePlayer");
		if(supportsSinglePlayer and tonumber(supportsSinglePlayer) == 0) then
			Controls.ModSupportsSinglePlayerValue:LocalizeAndSetText("[COLOR_RED]" .. Locale.Lookup("LOC_MODS_NO") .. "[ENDCOLOR]");
		else
			Controls.ModSupportsSinglePlayerValue:LocalizeAndSetText("LOC_MODS_YES");
		end

		local supportsMultiplayer = Modding.GetModProperty(g_SelectedModHandle, "SupportsMultiplayer");
		if(supportsMultiplayer and tonumber(supportsMultiplayer) == 0) then
			Controls.ModSupportsMultiplayerValue:LocalizeAndSetText("[COLOR_RED]" .. Locale.Lookup("LOC_MODS_NO") .. "[ENDCOLOR]");
		else
			Controls.ModSupportsMultiplayerValue:LocalizeAndSetText("LOC_MODS_YES");
		end

		local dependencies, references, blocks = Modding.GetModAssociations(g_SelectedModHandle);

		g_DependencyListingsManager:ResetInstances();
		if(dependencies) then
			local dependencyStrings = {}
			for i,v in ipairs(dependencies) do
				
				local name = v.Name;
				if(name) then
					local text = Locale.LookupBundle(name);
					if(text == nil) then
						text = Locale.Lookup(name);
					end

					dependencyStrings[i] = text or name;
				end				
			end
			table.sort(dependencyStrings, function(a,b) return Locale.Compare(a,b) == -1 end);

			for i,v in ipairs(dependencyStrings) do
				local instance = g_DependencyListingsManager:GetInstance();
				instance.Item:SetText( "[ICON_BULLET] " .. v);		
			end
		end
		Controls.ModDependenciesStack:SetHide(dependencies == nil or #dependencies == 0);

		
		Controls.ModDependencyItemsStack:CalculateSize();
		Controls.ModDependencyItemsStack:ReprocessAnchoring();
		Controls.ModDependenciesStack:CalculateSize();
		Controls.ModDependenciesStack:ReprocessAnchoring();	
		Controls.ModPropertiesValuesStack:CalculateSize();
		Controls.ModPropertiesValuesStack:ReprocessAnchoring();
		Controls.ModPropertiesCaptionStack:CalculateSize();
		Controls.ModPropertiesCaptionStack:ReprocessAnchoring();
		Controls.ModPropertiesStack:CalculateSize();
		Controls.ModPropertiesStack:ReprocessAnchoring();
		Controls.ModDetailsStack:CalculateSize();
		Controls.ModDetailsStack:ReprocessAnchoring();
		Controls.ModDetailsScrollPanel:CalculateInternalSize();
	end
end

-- Select a specific entry in the listings.
function SelectMod(handle)
	g_SelectedModHandle = handle;
	RefreshListingsSelectionState();
	RefreshModDetails();
end

function CreateModGroup()
	Controls.ModGroupEditBox:SetText("");
	Controls.CreateModGroupButton:SetDisabled(true);

	Controls.NameModGroupPopup:SetHide(false);
	Controls.NameModGroupPopupAlpha:SetToBeginning();
	Controls.NameModGroupPopupAlpha:Play();
	Controls.NameModGroupPopupSlide:SetToBeginning();
	Controls.NameModGroupPopupSlide:Play();

	Controls.ModGroupEditBox:TakeFocus();
end

function DeleteModGroup()
	local currentGroup = Modding.GetCurrentModGroup();
	local groups = Modding.GetModGroups();
	for i, v in ipairs(groups) do
		v.DisplayName = Locale.Lookup(v.Name);
	end

	table.sort(groups, function(a,b)
		if(a.SortIndex == b.SortIndex) then
			-- Sort by Name.
			return Locale.Compare(a.DisplayName, b.DisplayName) == -1;
		else
			return a.SortIndex < b.SortIndex;
		end
	end);	

	for i, v in ipairs(groups) do
		if(v.Handle ~= currentGroup) then
			Modding.SetCurrentModGroup(v.Handle);
			Modding.DeleteModGroup(currentGroup);
			break;
		end
	end

	RefreshModGroups();
	RefreshListings();
end

function EnableAllMods()
	local mods = Modding.GetInstalledMods();
	PreprocessListings(mods);
	mods = FilterListings(mods);

	local modHandles = {};
	for i,v in ipairs(mods) do
		local err, _ =  Modding.CanEnableMod(v.Handle, true);
		if (err == "OK") then
			table.insert(modHandles, v.Handle);
		end
	end

	if(	Modding.ShouldShowCompatibilityWarnings()) then
		local whitelistMods = false;
		local incompatibleMods = {};
		for i,v in ipairs(modHandles) do
			if(	not Modding.IsModCompatible(v) and 
				not Modding.GetIgnoreCompatibilityWarnings(v)) then
				table.insert(incompatibleMods, v);
			end
		end

		function OnYes()
			if(whitelistMods) then
				for i,v in ipairs(incompatibleMods) do
					Modding.SetIgnoreCompatibilityWarnings(v, true);
				end
			end

			Modding.EnableMod(modHandles);
			RefreshListings();
		end

		if(#incompatibleMods > 0) then
			m_kPopupDialog:AddText(Locale.Lookup("LOC_MODS_ENABLE_WARNING_NOT_COMPATIBLE_MANY"));
			m_kPopupDialog:AddTitle(Locale.ToUpper(Locale.Lookup("LOC_MODS_TITLE")));
			m_kPopupDialog:AddButton(Locale.Lookup("LOC_YES_BUTTON"), OnYes, nil, nil, "PopupButtonInstanceGreen"); 
			m_kPopupDialog:AddButton(Locale.Lookup("LOC_NO_BUTTON"), nil);
			m_kPopupDialog:AddCheckBox(Locale.Lookup("LOC_MODS_WARNING_WHITELIST_MANY"), false, function(checked) whitelistMods = checked; end);
			m_kPopupDialog:Open();
		else
			OnYes();
		end
	else	
		Modding.EnableMod(modHandles);
		RefreshListings();
	end
end

function DisableAllMods()
	local mods = Modding.GetInstalledMods();
	PreprocessListings(mods);
	mods = FilterListings(mods);

	local modHandles = {};
	for i,v in ipairs(mods) do
		modHandles[i] = v.Handle;
	end
	Modding.DisableMod(modHandles);
	RefreshListings();
end

----------------------------------------------------------------        
-- Subscriptions Tab
----------------------------------------------------------------        
function RefreshSubscriptions()
	local subs = Modding.GetSubscriptions();

	g_Subscriptions = {};
	g_SubscriptionsSortingMap = {};
	g_SubscriptionsListingsManager:ResetInstances();

	Controls.NoSubscriptions:SetHide(#subs > 0);

	for i,v in ipairs(subs) do
		local instance = g_SubscriptionsListingsManager:GetInstance();
		table.insert(g_Subscriptions, {
			SubscriptionId = v,
			Instance = instance,
			NeedsRefresh = true
		});
	end
	UpdateSubscriptions()

	Controls.SubscriptionListingsStack:CalculateSize();
	Controls.SubscriptionListingsStack:ReprocessAnchoring();
	Controls.SubscriptionListings:CalculateInternalSize();
end
----------------------------------------------------------------  
function RefreshSubscriptionItem(item)

	local needsRefresh = false;
	local instance = item.Instance;
	local subscriptionId = item.SubscriptionId;

	local details = Modding.GetSubscriptionDetails(subscriptionId);

	local name = details.Name;
	if(name == nil) then
		name = Locale.Lookup("LOC_MODS_SUBSCRIPTION_NAME_PENDING");
		needsRefresh = true;
	end

	instance.SubscriptionTitle:SetText(name);
	g_SubscriptionsSortingMap[tostring(instance.SubscriptionInstanceRoot)] = name;

	if(details.LastUpdated) then
		instance.LastUpdated:SetText(Locale.Lookup("LOC_MODS_LAST_UPDATED", details.LastUpdated));
	end
	
	instance.UnsubscribeButton:SetHide(true);

	local status = details.Status;
	instance.SubscriptionDownloadProgress:SetHide(status ~= "Downloading");
	if(status == "Downloading") then
		local downloaded, total = Modding.GetSubscriptionDownloadStatus(subscriptionId);

		if(total > 0) then
			local w = instance.SubscriptionInstanceRoot:GetSizeX();
			local pct = downloaded/total;

			instance.SubscriptionDownloadProgress:SetSizeX(math.floor(w * pct));
			instance.SubscriptionDownloadProgress:SetHide(false);
		else
			instance.SubscriptionDownloadProgress:SetHide(true);
		end

		instance.SubscriptionStatus:LocalizeAndSetText("LOC_MODS_SUBSCRIPTION_DOWNLOADING", downloaded, total);
	else
		local statusStrings = {
			["Installed"] = "LOC_MODS_SUBSCRIPTION_DOWNLOAD_INSTALLED",
			["DownloadPending"] = "LOC_MODS_SUBSCRIPTION_DOWNLOAD_PENDING",
			["Subscribed"] = "LOC_MODS_SUBSCRIPTION_SUBSCRIBED"
		};
		instance.SubscriptionStatus:LocalizeAndSetText(statusStrings[status]);
	end

	if(Steam and Steam.IsOverlayEnabled and Steam.IsOverlayEnabled()) then
		instance.SubscriptionViewButton:SetHide(false);
		instance.SubscriptionViewButton:RegisterCallback(Mouse.eLClick, function()
			local url = "http://steamcommunity.com/sharedfiles/filedetails/?id=" .. subscriptionId;
			Steam.ActivateGameOverlayToUrl(url);
		end);
	else
		instance.SubscriptionViewButton:SetHide(true);
	end

	-- If we're downloading or about to download, keep refreshing the details.
	if(status == "Downloading" or status == "DownloadingPending") then
		needsRefresh = true;
		instance.SubscriptionUpdateButton:SetHide(true);
	else
		local needsUpdate = details.NeedsUpdate;
		if(needsUpdate) then
			instance.SubscriptionUpdateButton:SetHide(false);
			instance.SubscriptionUpdateButton:RegisterCallback(Mouse.eLClick, function()
				Modding.UpdateSubscription(subscriptionId);
				RefreshSubscriptions();
			end);
		else
			instance.SubscriptionUpdateButton:SetHide(true);
			instance.UnsubscribeButton:SetHide(false);
			instance.UnsubscribeButton:RegisterCallback(Mouse.eLClick, function()
				Modding.Unsubscribe(subscriptionId);
				instance.SubscriptionInstanceRoot:SetHide(true);
			end);
		end
	end


	instance.SubscriptionInstanceRoot:SetHide(false);
	item.NeedsRefresh = needsRefresh;
end
----------------------------------------------------------------  
function SortSubscriptionListings(a,b)
	-- ForgUI requires a strict weak ordering sort.
	local ap = g_SubscriptionsSortingMap[tostring(a)];
	local bp = g_SubscriptionsSortingMap[tostring(b)];

	if(ap == nil and bp ~= nil) then
		return true;
	elseif(ap == nil and bp == nil) then
		return tostring(a) < tostring(b);
	elseif(ap ~= nil and bp == nil) then
		return false;
	else
		return Locale.Compare(ap, bp) == -1;
	end
end
----------------------------------------------------------------  
function UpdateSubscriptions()
	local updated = false;
	if(g_Subscriptions) then
		for i, v in ipairs(g_Subscriptions) do
			if(v.NeedsRefresh) then
				RefreshSubscriptionItem(v);
				updated = true;
			end
		end
	end

	if(updated) then
		Controls.SubscriptionListingsStack:SortChildren(SortSubscriptionListings);
	end
end


----------------------------------------------------------------        
-- Input Handler
----------------------------------------------------------------        
function InputHandler( uiMsg, wParam, lParam )
	if uiMsg == KeyEvents.KeyUp then
		if wParam == Keys.VK_ESCAPE then
			if(Controls.NameModGroupPopup ~= nil and Controls.NameModGroupPopup:IsVisible()) then
				Controls.NameModGroupPopup:SetHide(true);
			else
				HandleExitRequest();
			end
			return true;
		end
	end
	return false;
end
ContextPtr:SetInputHandler( InputHandler );

----------------------------------------------------------------  
function OnInstalledModsTabClick(bForce)
	if(Controls.InstalledTabPanel:IsHidden() or bForce) then
		Controls.SubscriptionsTabPanel:SetHide(true);
		Controls.InstalledTabPanel:SetHide(false);

		-- Clear search queries.
		g_SearchQuery = nil;
		g_SelectedModHandle = nil;

		Controls.SearchEditBox:SetText(LOC_MODS_SEARCH_NAME);
		RefreshModGroups();
		RefreshListings();
	end
end
----------------------------------------------------------------  
function OnSubscriptionsTabClick()
	if(Controls.SubscriptionsTabPanel:IsHidden() or bForce) then
		Controls.InstalledTabPanel:SetHide(true);
		Controls.SubscriptionsTabPanel:SetHide(false);

		RefreshSubscriptions();
	end
end
----------------------------------------------------------------  
function OnOpenWorkshop()
	if (Steam ~= nil) then
		Steam.ActivateGameOverlayToWorkshop();
	end
end

----------------------------------------------------------------    
function OnShow()
	OnInstalledModsTabClick(true);
	if(GameConfiguration.IsAnyMultiplayer()) then
		Controls.BrowseWorkshop:SetHide(true);
	else
		Controls.BrowseWorkshop:SetHide(false);
	end
end	
----------------------------------------------------------------    
function HandleExitRequest()
	GameConfiguration.UpdateEnabledMods();
	UIManager:DequeuePopup( ContextPtr );
	if C6GUE.RefreshContent then
		print("C6GUE: Possible change in installed and/or enabled content detected; refreshing known content . . .");
		local bIsEGHV = Modding.IsModEnabled("a4b1fac6-8c9e-4873-a1c1-7ddf08dbbf11");			-- 2021/05/24: not sure why this doesn't want to take the value from C6GUE
		local bIsENWS = Modding.IsModEnabled("d0afae5b-02f8-4d01-bd54-c2bbc3d89858");			-- 2021/05/24: not sure why this doesn't want to take the value from C6GUE
		print("C6GUE: EGHV: " .. tostring(bIsEGHV) .. " | ENWS: " .. tostring(bIsENWS));
		if not bIsEGHV and not bIsENWS then
			print(" * STUB * C6GUE: No component(s) enabled; picker tooltip(s) should be reset to defaults here . . .");
			-- ResetActiveContentTooltips();
		else
        	RefreshActiveContentTooltips();
		end
		C6GUE.RefreshContent = false;
	end
end
----------------------------------------------------------------  
function PostInit()
	if(not ContextPtr:IsHidden()) then
		OnShow();
	end
end

function OnUpdate(delta)
	-- Overkill..
	UpdateSubscriptions();
end
----------------------------------------------------------------  
-- ===========================================================================
--	Handle Window Sizing
-- ===========================================================================
function Resize()
	local screenX, screenY:number = UIManager:GetScreenSizeVal();
	local hideLogo = true;
	if(screenY >= MIN_SCREEN_Y + (Controls.LogoContainer:GetSizeY()+ Controls.LogoContainer:GetOffsetY() * 2)) then
		hideLogo = false;
		Controls.MainWindow:SetSizeY(screenY- (Controls.LogoContainer:GetSizeY() + Controls.LogoContainer:GetOffsetY()));
	else
		Controls.MainWindow:SetSizeY(screenY);
	end
	Controls.LogoContainer:SetHide(hideLogo);
end

function OnSearchBarGainFocus()
	Controls.SearchEditBox:ClearString();
end

----------------------------------------------------------------
function OnUpdateUI( type:number, tag:string, iData1:number, iData2:number, strData1:string )   
  if type == SystemUpdateUI.ScreenResize then
    Resize();
  end
end

----------------------------------------------------------------
function OnSearchCharCallback()
	local str = Controls.SearchEditBox:GetText();
	if (str ~= nil and #str > 0 and str ~= LOC_MODS_SEARCH_NAME) then
		g_SearchQuery = str;
		RefreshListings();
	elseif(str == nil or #str == 0) then
		g_SearchQuery = nil;
		RefreshListings();
	end
end


---------------------------------------------------------------------------
-- Sort By Pulldown setup
-- Must exist below callback function names
---------------------------------------------------------------------------
function SortListingsByName(mods)
	-- Keep XP1 and XP2 at the top of the list, regardless of sort.
	local sortOverrides = {
		["4873eb62-8ccc-4574-b784-dda455e74e68"] = -2,
		["1B28771A-C749-434B-9053-D1380C553DE9"] = -1
	};

	table.sort(mods, function(a,b) 
		local aSort = sortOverrides[a.Id] or 0;
		local bSort = sortOverrides[b.Id] or 0;

		if(aSort ~= bSort) then
			return aSort < bSort;
		else
			return Locale.Compare(a.StrippedDisplayName, b.StrippedDisplayName) == -1;
		end
	end);
end
---------------------------------------------------------------------------
function SortListingsByEnabled(mods)
	-- Keep XP1 and XP2 at the top of the list, regardless of sort.
	local sortOverrides = {
		["4873eb62-8ccc-4574-b784-dda455e74e68"] = -2,
		["1B28771A-C749-434B-9053-D1380C553DE9"] = -1
	};

	table.sort(mods, function(a,b) 
		local aSort = sortOverrides[a.Id] or 0;
		local bSort = sortOverrides[b.Id] or 0;

		if(aSort ~= bSort) then
			return aSort < bSort;
		elseif(a.Enabled ~= b.Enabled) then
			return a.Enabled;
		else
			-- Sort by Name.
			return Locale.Compare(a.StrippedDisplayName, b.StrippedDisplayName) == -1;
		end
	end);
end
---------------------------------------------------------------------------
local g_SortListingsOptions = {
	{"LOC_MODS_SORTBY_NAME", SortListingsByName},
	{"LOC_MODS_SORTBY_ENABLED", SortListingsByEnabled},
};
---------------------------------------------------------------------------
function InitializeSortListingsPulldown()
	local sortByPulldown = Controls.SortListingsPullDown;
	sortByPulldown:ClearEntries();
	for i, v in ipairs(g_SortListingsOptions) do
		local controlTable = {};
		sortByPulldown:BuildEntry( "InstanceOne", controlTable );
		controlTable.Button:LocalizeAndSetText(v[1]);
	
		controlTable.Button:RegisterCallback(Mouse.eLClick, function()
			sortByPulldown:GetButton():LocalizeAndSetText( v[1] );
			g_CurrentListingsSort = v[2];
			RefreshListings();
		end);
	
	end
	sortByPulldown:CalculateInternals();

	sortByPulldown:GetButton():LocalizeAndSetText(g_SortListingsOptions[1][1]);
	g_CurrentListingsSort = g_SortListingsOptions[1][2];
end

function Initialize()
	m_kPopupDialog = PopupDialog:new( "Mods" );

	Controls.EnableAll:RegisterCallback(Mouse.eLClick, EnableAllMods);
	Controls.DisableAll:RegisterCallback(Mouse.eLClick, DisableAllMods);
	Controls.CreateModGroup:RegisterCallback(Mouse.eLClick, CreateModGroup);
	Controls.DeleteModGroup:RegisterCallback(Mouse.eLClick, DeleteModGroup);
	
	if(not Search.CreateContext(g_SearchContext, "[COLOR_LIGHTBLUE]", "[ENDCOLOR]", "...")) then
		print("Failed to create mods browser search context!");
	end
	Controls.SearchEditBox:RegisterStringChangedCallback(OnSearchCharCallback);
	Controls.SearchEditBox:RegisterHasFocusCallback(OnSearchBarGainFocus);

	local refreshListings = function() RefreshListings(); end;
	Controls.ShowOfficialContent:RegisterCallback(Mouse.eLClick, refreshListings);
	Controls.ShowCommunityContent:RegisterCallback(Mouse.eLClick, refreshListings);

	Controls.CancelBindingButton:RegisterCallback(Mouse.eLClick, function()
		Controls.NameModGroupPopup:SetHide(true);
	end);

	Controls.CreateModGroupButton:RegisterCallback(Mouse.eLClick, function()
		Controls.NameModGroupPopup:SetHide(true);
		local groupName = Controls.ModGroupEditBox:GetText();
		local currentGroup = Modding.GetCurrentModGroup();
		Modding.CreateModGroup(groupName, currentGroup);
		RefreshModGroups();
		RefreshListings();
	end);

	Controls.ModGroupEditBox:RegisterStringChangedCallback(function()
		local str = Controls.ModGroupEditBox:GetText();
		Controls.CreateModGroupButton:SetDisabled(str == nil or #str == 0);
	end);

	Controls.ModGroupEditBox:RegisterCommitCallback(function()
		local str = Controls.ModGroupEditBox:GetText();
		if(str and #str > 0) then
			Controls.NameModGroupPopup:SetHide(true);
			local currentGroup = Modding.GetCurrentModGroup();
			Modding.CreateModGroup(str, currentGroup);
			RefreshModGroups();
			RefreshListings();
		end
	end);

	if(Steam ~= nil and Steam.GetAppID() ~= 0) then
		Controls.SubscriptionsTab:RegisterCallback(Mouse.eLClick, function() OnSubscriptionsTabClick() end);
		Controls.SubscriptionsTab:RegisterCallback( Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
		Controls.SubscriptionsTab:SetHide(false);
	else
		Controls.SubscriptionsTab:SetHide(true);
	end

	local pFriends = Network.GetFriends();
	if(pFriends ~= nil and pFriends:IsOverlayEnabled()) then
		Controls.BrowseWorkshop:RegisterCallback( Mouse.eLClick, OnOpenWorkshop );
		Controls.BrowseWorkshop:RegisterCallback( Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
	else
		Controls.BrowseWorkshop:SetDisabled(true);
	end
	Controls.ShowOfficialContent:SetCheck(true);
	Controls.ShowCommunityContent:SetCheck(true);

	InitializeSortListingsPulldown();
	Resize();
	Controls.InstalledTab:RegisterCallback(Mouse.eLClick, function() OnInstalledModsTabClick() end);
	Controls.InstalledTab:RegisterCallback( Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
	Controls.CloseButton:RegisterCallback( Mouse.eLClick, HandleExitRequest );
	Controls.CloseButton:RegisterCallback( Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);

	Events.SystemUpdateUI.Add( OnUpdateUI );

	ContextPtr:SetShowHandler( OnShow );
	ContextPtr:SetUpdate(OnUpdate);
	ContextPtr:SetPostInit(PostInit);	
end

Initialize();

--[[ =========================================================================
	end modified GameSetupLogic.lua frontend script
=========================================================================== ]]
