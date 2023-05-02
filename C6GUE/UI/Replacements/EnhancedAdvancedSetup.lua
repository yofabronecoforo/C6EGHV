--[[ =========================================================================
	EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (C) 2020-2023 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin EnhancedAdvancedSetup.lua frontend script
=========================================================================== ]]
print("Loading EnhancedAdvancedSetup.lua . . .");

--[[ =========================================================================
	include necessary original or modified file(s) here
=========================================================================== ]]
print("Including common frontend component(s) . . .");
include("CommonFrontend");
print("Common frontend component(s) successfully included; proceeding . . .");
print("Including last imported AdvancedSetup.lua . . .");
include("AdvancedSetup");
if bYnAMP_IsEnabled then 
	print("YnAMP AdvancedSetup.lua and any imported AdvancedSetup_*.lua file(s) successfully included; proceeding . . .");
else 
	print("AdvancedSetup.lua successfully included from UI/FrontEnd/ or last imported source; proceeding . . .");
end
if not bYnAMP_IsEnabled then 
	print("Including any imported AdvancedSetup_*.lua file(s) . . .");
	include("AdvancedSetup_", true);
	print("Imported AdvancedSetup_*.lua file(s) successfully included; proceeding . . .");
end
print("Including any imported GameSetupLogic_*.lua file(s) . . .");
include("GameSetupLogic_", true);
print("Imported GameSetupLogic_*.lua file(s) successfully included; proceeding . . .");

--[[ =========================================================================
	end EnhancedAdvancedSetup.lua frontend script
=========================================================================== ]]
