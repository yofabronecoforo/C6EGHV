--[[ =========================================================================
	EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (C) 2020-2021 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin EGHV.lua gameplay script
=========================================================================== ]]

--[[ =========================================================================
	context sharing : initialize and/or fetch ExposedMembers here
	pre-init+ : these should be defined prior to any exposed globals
=========================================================================== ]]
-- fetch or initialize global exposed members
if not ExposedMembers.GUE then ExposedMembers.GUE = {}; end
GUE = ExposedMembers.GUE;
-- fetch any available Wondrous Goody Hut exposed members
WGH = ExposedMembers.WGH;

--[[ =========================================================================
	exposed globals : define any needed EGHV globally shared component(s) here
	pre-init : these should be defined prior to Initialize()
=========================================================================== ]]
-- make DebugPrint() more conveniently globally accessible, as otherwise this declaration must be made in a local scope within each function below
Dprint = GUE.DebugPrint;

--[[ =========================================================================
	function Initialize()
	final configuration prior to startup
=========================================================================== ]]

-- Initialize();

--[[ =========================================================================
	references
==============================================================================

	[1] web : https://forums.civfanatics.com/threads/getting-an-extra-bonus-from-goody-huts.616695/#post-14780879
	[2] web : https://steamcommunity.com/sharedfiles/filedetails/?id=2164194796
	[3] web : https://forums.civfanatics.com/threads/add-a-feature-to-a-plot-during-game-time-with-lua.645149/#post-15435909
	[4] web : https://forums.civfanatics.com/threads/ongoodyhutreward-event-what-are-the-parameters.642591/#post-15398744
	[5] web : https://forums.civfanatics.com/threads/how-do-you-catch-an-era-change-event-in-lua.614454/#post-15144387

=========================================================================== ]]

--[[ =========================================================================
	end EGHV.lua gameplay script
=========================================================================== ]]
