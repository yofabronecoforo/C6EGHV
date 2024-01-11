--[[ =========================================================================
	EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (C) 2020-2023 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin GoodyHutPicker.lua frontend script
=========================================================================== ]]

include("InstanceManager");
include("PlayerSetupLogic");
include("Civ6Common");

print("Loading GoodyHutPicker.lua . . .")

-- ===========================================================================
-- Members
-- ===========================================================================
local m_pItemIM:table = InstanceManager:new("ItemInstance",	"Button", Controls.ItemsPanel);

local m_kParameter:table = nil			-- Reference to the parameter being used. 
local m_kSelectedValues:table = nil		-- Table of string->boolean that represents checked off items.
local m_kItemList:table = nil;			-- Table of controls for select all/none

local m_bInvertSelection:boolean = false;

local m_kGoodyHutDataCache:table = {};

-- local m_kGoodyHutFrequencyParam:table = nil;

local m_RulesetType:string = "";

local m_numSelected:number = 0;

-- Track the number of goody huts to spawn when opening the picker
-- Used to revert to that number in case the user modifies the parameter then backs out of the picker
local m_OriginalGoodyHutFrequency:number = 0;

-- ===========================================================================
function Close()	
	-- Clear any temporary global variables.
	m_kParameter = nil;
	m_kSelectedValues = nil;

	ContextPtr:SetHide(true);
end

-- ===========================================================================
function IsItemSelected(item: table) 
	return m_kSelectedValues[item.Value] == true;
end

-- ===========================================================================
function OnBackButton()
	Close();
	LuaEvents.GoodyHutPicker_SetParameterValue("GoodyHutFrequencyNumber", m_OriginalGoodyHutFrequency);
end

-- ===========================================================================
function OnConfirmChanges()
	-- Generate sorted list from selected values.
	local values = {}
	for k,v in pairs(m_kSelectedValues) do
		if(v) then
			table.insert(values, k);
		end
	end

	LuaEvents.GoodyHutPicker_SetParameterValues(m_kParameter.ParameterId, values);
	Close();
end

-- ===========================================================================
function OnItemSelect(item :table, checkBox :table)
	local value = item.Value;
	local selected = not m_kSelectedValues[value];

	m_kSelectedValues[item.Value] = selected;
	if m_bInvertSelection then
		checkBox:SetCheck(not selected);
	else
		checkBox:SetCheck(selected);
	end
end

-- ===========================================================================
function OnItemFocus(item :table)
	if(item) then
		Controls.FocusedItemName:SetText(item.Name);
		Controls.FocusedItemDescription:LocalizeAndSetText(item.RawDescription);

		if((item.Icon and Controls.FocusedItemIcon:SetIcon(item.Icon)) or Controls.FocusedItemIcon:SetIcon("ICON_" .. item.Value)) then
			Controls.FocusedItemIcon:SetHide(false);
		else
			Controls.FocusedItemIcon:SetHide(true);
		end
	end
end

-- ===========================================================================
function GetGoodyHutData( goodyhutSubType:string )
	-- Refresh the cache if needed
	if m_kGoodyHutDataCache[goodyhutSubType] == nil then

		m_kGoodyHutDataCache[goodyhutSubType] = {};

		local query:string = "SELECT GoodyHut, SortIndex FROM TribalVillages WHERE SubTypeGoodyHut = ? LIMIT 1";
		local kResults:table = DB.ConfigurationQuery(query, goodyhutSubType);
		if(kResults) then
			for i,v in ipairs(kResults) do
				for name, value in pairs(v) do
					m_kGoodyHutDataCache[goodyhutSubType][name] = value;
				end
			end
		end
	end

	return m_kGoodyHutDataCache[goodyhutSubType];
end

-- ===========================================================================
function SetAllItems(bState: boolean)
	for _, node in ipairs(m_kItemList) do
		local item:table = node["item"];
		local checkBox:table = node["checkbox"];

		checkBox:SetCheck(bState);
		if m_bInvertSelection then
			m_kSelectedValues[item.Value] = not bState;
		else
			m_kSelectedValues[item.Value] = bState;
		end
	end
end

-- ===========================================================================
function OnSelectAll()
	SetAllItems(true);
end

-- ===========================================================================
function OnSelectNone()
	SetAllItems(false);
end

-- ===========================================================================
function ParameterInitialize(parameter : table)
	m_kParameter = parameter;
	m_kSelectedValues = {};

	-- m_kGoodyHutFrequencyParam = pGameParameters.Parameters["GoodyHutFrequency"];
	m_OriginalGoodyHutFrequency = GameConfiguration.GetValue("GOODYHUT_FREQUENCY");

	if (parameter.UxHint ~= nil and parameter.UxHint == "InvertSelection") then
		m_bInvertSelection = true;
	else
		m_bInvertSelection = false;
	end

	if(parameter.Value) then
		for i,v in ipairs(parameter.Value) do
			m_kSelectedValues[v.Value] = true;
		end
	end

	Controls.TopDescription:SetText(parameter.Description);
	Controls.WindowTitle:SetText(parameter.Name);
	m_pItemIM:ResetInstances();

	m_kItemList = {};
	for i, v in ipairs(parameter.Values) do
		InitializeItem(v);
	end

	-- 
	RefreshList();

	-- 
	InitGoodyHutFrequencySlider();
	InitSortByFilter();

	OnItemFocus(parameter.Values[1]);
end

-- ===========================================================================
function RefreshList( sortByFunc )

	m_numSelected = 0;
	m_kItemList = {};

	-- Always Sort list by name first; this should ensure consistent appearance of items in the picker
	if sortByFunc ~= nil and sortByFunc ~= SortByName then 
		table.sort(m_kParameter.Values, SortByName);
	end

	-- Sort list
	table.sort(m_kParameter.Values, sortByFunc ~= nil and sortByFunc or SortByName);

	-- Update UI
	m_pItemIM:ResetInstances();
	for i, v in ipairs(m_kParameter.Values) do
		InitializeItem(v);
	end
end

-- ===========================================================================
function SortByName(kItemA:table, kItemB:table)
	return Locale.Compare(kItemA.Name, kItemB.Name) == -1;
end

-- ===========================================================================
function SortByType(kItemA:table, kItemB:table)
	local kItemDataA:table = GetGoodyHutData(kItemA.Value);
	local kItemDataB:table = GetGoodyHutData(kItemB.Value);

	if kItemDataA.GoodyHut ~= nil and kItemDataB.GoodyHut ~= nil then
		return Locale.Compare(kItemDataA.GoodyHut, kItemDataB.GoodyHut) == -1;
	else
		return false;
	end
end

-- ===========================================================================
function SortByRarity(kItemA:table, kItemB:table)
	local kItemDataA:table = GetGoodyHutData(kItemA.Value);
	local kItemDataB:table = GetGoodyHutData(kItemB.Value);

	if kItemDataA.SortIndex ~= nil and kItemDataB.SortIndex ~= nil then
		-- return (kItemDataA.SortIndex >= kItemDataB.SortIndex) == -1;
		-- return Locale.Compare(tostring(kItemDataA.SortIndex), tostring(kItemDataB.SortIndex)) == -1;
		-- return kItemDataA.SortIndex ~= kItemDataB.SortIndex;
		return Locale.Compare(kItemDataA.SortIndex, kItemDataB.SortIndex) == -1;
	else
		return false;
	end
end

-- ===========================================================================
function InitGoodyHutFrequencySlider()
	-- local kValues:table = m_kGoodyHutFrequencyParam.Values;
	local sDomain = "GoodyHutFrequencyRange";
	local sQuery = "SELECT * FROM DomainRanges WHERE Domain = ?";
	local tResult = DB.ConfigurationQuery(sQuery, sDomain);
	local minimumValue = 25;
	local maximumValue = 500;
	-- local defaultValue = 100;
	local currentValue = GameConfiguration.GetValue("GOODYHUT_FREQUENCY");

	if (tResult and #tResult > 0) then
		for i, v in ipairs(tResult) do
			minimumValue = v.MinimumValue;
			maximumValue = v.MaximumValue;
		end
	end

	Controls.GoodyHutFrequencyNumber:SetText(currentValue);
	Controls.GoodyHutFrequencySlider:SetNumSteps(maximumValue / minimumValue);
	Controls.GoodyHutFrequencySlider:SetStep(currentValue / minimumValue);

	Controls.GoodyHutFrequencySlider:RegisterSliderCallback(function()
		local stepNum:number = Controls.GoodyHutFrequencySlider:GetStep();
		local value:number = minimumValue * stepNum;
			
		-- This method can get called pretty frequently, try and throttle it.
		if(currentValue ~= value) then
			GameConfiguration.SetValue("GOODYHUT_FREQUENCY", value);
			Controls.GoodyHutFrequencyNumber:SetText(value);
			Network.BroadcastGameConfig();
			-- RefreshCountWarning();
		end
	end);

end

-- ===========================================================================
function InitSortByFilter()

	local uiButton:object = Controls.SortByPulldown:GetButton();
	uiButton:SetText(Locale.Lookup("LOC_GOODY_HUT_PICKER_SORT_NAME"));

	Controls.SortByPulldown:ClearEntries();

	local pNameEntryInst:object = {};
	Controls.SortByPulldown:BuildEntry( "InstanceOne", pNameEntryInst );
	pNameEntryInst.Button:SetText(Locale.Lookup("LOC_GOODY_HUT_PICKER_SORT_NAME"));
	pNameEntryInst.Button:RegisterCallback( Mouse.eLClick, 
		function() 
			Controls.SortByPulldown:GetButton():SetText(Locale.Lookup("LOC_GOODY_HUT_PICKER_SORT_NAME"));
			RefreshList(SortByName);
		end );

	local pTypeEntryInst:object = {};
	Controls.SortByPulldown:BuildEntry( "InstanceOne", pTypeEntryInst );
	pTypeEntryInst.Button:SetText(Locale.Lookup("LOC_GOODY_HUT_PICKER_SORT_TYPE"));
	pTypeEntryInst.Button:RegisterCallback( Mouse.eLClick, 
		function() 
			Controls.SortByPulldown:GetButton():SetText(Locale.Lookup("LOC_GOODY_HUT_PICKER_SORT_TYPE"));
			RefreshList(SortByType);
		end );

	local pRarityEntryInst:object = {};
	Controls.SortByPulldown:BuildEntry( "InstanceOne", pRarityEntryInst );
	pRarityEntryInst.Button:SetText(Locale.Lookup("LOC_GOODY_HUT_PICKER_SORT_RARITY"));
	pRarityEntryInst.Button:RegisterCallback( Mouse.eLClick, 
		function() 
			Controls.SortByPulldown:GetButton():SetText(Locale.Lookup("LOC_GOODY_HUT_PICKER_SORT_RARITY"));
			RefreshList(SortByRarity);
		end );

	Controls.SortByPulldown:CalculateInternals();
end

-- ===========================================================================
function InitializeItem(item:table)
	local c: table = m_pItemIM:GetInstance();
	c.Name:SetText(item.Name);
	if not item.Icon or not c.Icon:SetIcon(item.Icon) then
		c.Icon:SetIcon("ICON_" .. item.Value);
	end
	c.Button:RegisterCallback( Mouse.eMouseEnter, function() OnItemFocus(item); end );
	c.Button:RegisterCallback( Mouse.eLClick, function() OnItemSelect(item, c.Selected); end );
	c.Selected:RegisterCallback( Mouse.eLClick, function() OnItemSelect(item, c.Selected); end );
	if m_bInvertSelection then
		c.Selected:SetCheck(not IsItemSelected(item));
	else
		c.Selected:SetCheck(IsItemSelected(item));
	end

	local listItem:table = {};
	listItem["item"] = item;
	listItem["checkbox"] = c.Selected;
	table.insert(m_kItemList, listItem);
end

-- ===========================================================================
function OnShutdown()
	Close();
	m_pItemIM:DestroyInstances();
	LuaEvents.GoodyHutPicker_Initialize.Remove( ParameterInitialize );
end

-- ===========================================================================
function OnInputHandler( pInputStruct:table )
	local uiMsg = pInputStruct:GetMessageType();
	if uiMsg == KeyEvents.KeyUp then
		local key:number = pInputStruct:GetKey();
		if key == Keys.VK_ESCAPE then
			Close();
		end
	end
	return true;
end

-- ===========================================================================
function Initialize()
	ContextPtr:SetShutdown( OnShutdown );
	ContextPtr:SetInputHandler( OnInputHandler, true );

	local OnMouseEnter = function() UI.PlaySound("Main_Menu_Mouse_Over"); end;

	Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnBackButton );
	Controls.CloseButton:RegisterCallback( Mouse.eMouseEnter, OnMouseEnter);
	Controls.ConfirmButton:RegisterCallback( Mouse.eLClick, OnConfirmChanges );
	Controls.ConfirmButton:RegisterCallback( Mouse.eMouseEnter, OnMouseEnter);
	Controls.SelectAllButton:RegisterCallback( Mouse.eLClick, OnSelectAll);
	Controls.SelectAllButton:RegisterCallback( Mouse.eMouseEnter, OnMouseEnter);
	Controls.SelectNoneButton:RegisterCallback( Mouse.eLClick, OnSelectNone);
	Controls.SelectNoneButton:RegisterCallback( Mouse.eMouseEnter, OnMouseEnter);

	LuaEvents.GoodyHutPicker_Initialize.Add( ParameterInitialize );
end
Initialize();

--[[ =========================================================================
	end GoodyHutPicker.lua frontend script
=========================================================================== ]]
