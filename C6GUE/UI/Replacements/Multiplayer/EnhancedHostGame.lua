--[[ =========================================================================
	EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (C) 2020-2023 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin EnhancedHostGame.lua frontend script
=========================================================================== ]]
print("Loading EnhancedHostGame.lua . . .");

--[[ =========================================================================
	include necessary original or modified file(s) here
=========================================================================== ]]
print("Including common frontend component(s) . . .");
include("CommonFrontend");
print("Common frontend component(s) successfully included; proceeding . . .");
print("Including last imported HostGame.lua . . .");
include("HostGame");
print("HostGame.lua successfully included from UI/FrontEnd/Multiplayer or last imported source; proceeding . . .");
print("Including any imported HostGame_*.lua file(s) . . .");
include("HostGame_", true);
print("Imported HostGame_*.lua file(s) successfully included; proceeding . . .");
print("Including any imported GameSetupLogic_*.lua file(s) . . .");
include("GameSetupLogic_", true);
print("Imported GameSetupLogic_*.lua file(s) successfully included; proceeding . . .");

--[[ =========================================================================
	end EnhancedHostGame.lua frontend script
=========================================================================== ]]
