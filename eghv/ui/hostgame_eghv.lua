--[[ =========================================================================
	C6EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (c) 2020-2024 yofabronecoforo (zzragnar0kzz)
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin hostgame_eghv.lua configuration script
=========================================================================== ]]
print("[+]: Loading HostGame_EGHV.lua UI script . . .");

--[[ =========================================================================
	OVERRIDE: call ExcludeGoodyHuts() and pass arguments to pre-EGHV HostGame()
=========================================================================== ]]
Pre_EGHV_HostGame = HostGame;
function HostGame(serverType:number) 
    ExcludeGoodyHuts();
    Pre_EGHV_HostGame(serverType);
end

--[[ =========================================================================
	end hostgame_eghv.lua configuration script
=========================================================================== ]]
