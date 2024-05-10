--[[ =========================================================================
	C6EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (c) 2020-2024 yofabronecoforo (zzragnar0kzz)
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin advancedsetup_eghv.lua configuration script
=========================================================================== ]]
print("[+]: Loading AdvancedSetup_EGHV.lua UI script . . .");

--[[ =========================================================================
	OVERRIDE: call ExcludeGoodyHuts() and call pre-EGHV HostGame()
=========================================================================== ]]
Pre_EGHV_HostGame = HostGame;
function HostGame()
    ExcludeGoodyHuts();
    Pre_EGHV_HostGame();
end

--[[ =========================================================================
	OVERRIDE: call pre-EGHV OnShutdown() and remove LuaEvent listeners for the Goody Hut picker
=========================================================================== ]]
Pre_EGHV_OnShutdown = OnShutdown;
function OnShutdown()
    Pre_EGHV_OnShutdown();
	LuaEvents.GoodyHutPicker_SetParameterValues.Remove(OnSetParameterValues);
	-- LuaEvents.GoodyHutPicker_SetParameterValue.Remove(OnSetParameterValue);
end

--[[ =========================================================================
	reset context pointers with modified functions
=========================================================================== ]]
ContextPtr:SetShutdown( OnShutdown );

--[[ =========================================================================
	add new LuaEvent listeners for the Goody Hut picker
=========================================================================== ]]
LuaEvents.GoodyHutPicker_SetParameterValues.Add(OnSetParameterValues);
-- LuaEvents.GoodyHutPicker_SetParameterValue.Add(OnSetParameterValue);

--[[ =========================================================================
	end advancedsetup_eghv.lua configuration script
=========================================================================== ]]
