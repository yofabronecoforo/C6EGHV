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
	end advancedsetup_eghv.lua configuration script
=========================================================================== ]]
