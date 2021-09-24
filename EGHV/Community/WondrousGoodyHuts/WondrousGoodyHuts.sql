/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin WondrousGoodyHuts compatibility
	WondrousGoodyHuts is property of Sailor Cat. All rights reserved.
########################################################################### */

/* ###########################################################################
    add an entry for this mod to table ContentFlags
		Id and Name are user-selectable strings; they are only used internally by EGHV
		GUID is the mod's id from its .modinfo file
		Tooltip is the tag for the localized text to appear in select tooltips when this mod is enabled
		numeric values for the following column(s) indicate specifc content provided by the mod:
			CityStates, GoodyHuts, Leaders, NaturalWonders
		numeric values for the following column(s) indicate that content provided by this mod is valid in specific ruleset(s):
			Base, XP1, XP2
		provided numeric values will be converted internally to boolean values
			values > 0 will be treated as 'true'; other values will be treated as 'false'
	this facilitates picker and tooltip configuration
########################################################################### */

-- REPLACE INTO ContentFlags (Id, Name, GUID, CityStates, GoodyHuts, Leaders, NaturalWonders, Base, XP1, XP2, Tooltip)
-- SELECT 'WGH', 'WondrousGoodyHuts', '2d90451f-08c9-47de-bce8-e9b7fdecbe92', 0, 1, 0, 0, 1, 1, 1, 'LOC_WGH_TT';

/* ###########################################################################
    Goody Hut picker configuration : StandardGoodyHuts
	these queries will FAIL when WondrousGoodyHuts is not enabled
		this behavior is expected, and related errors in the log(s) can be safely ignored
########################################################################### */

-- random resource
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon, SortIndex)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_RANDOMRESOURCE_NAME', 'GOODYHUT_SAILOR_RANDOMRESOURCE', 'LOC_GOODYHUT_SAILOR_RANDOMRESOURCE_DESC', 'ICON_DISTRICT_WONDER', 500
-- WHERE EXISTS (SELECT * FROM SailorGoodyOptions);
WHERE EXISTS (SELECT * FROM sqlite_master WHERE type = 'table' AND name = 'SailorGoodyOptions');

-- random unit
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon, SortIndex)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_RANDOMUNIT_NAME', 'GOODYHUT_SAILOR_RANDOMUNIT', 'LOC_GOODYHUT_SAILOR_RANDOMUNIT_DESC', 'ICON_DISTRICT_WONDER', 500
-- WHERE EXISTS (SELECT * FROM SailorGoodyOptions);
WHERE EXISTS (SELECT * FROM sqlite_master WHERE type = 'table' AND name = 'SailorGoodyOptions');

-- random improvement
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon, SortIndex)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_RANDOMIMPROVEMENT_NAME', 'GOODYHUT_SAILOR_RANDOMIMPROVEMENT', 'LOC_GOODYHUT_SAILOR_RANDOMIMPROVEMENT_DESC', 'ICON_DISTRICT_WONDER', 500
-- WHERE EXISTS (SELECT * FROM SailorGoodyOptions);
WHERE EXISTS (SELECT * FROM sqlite_master WHERE type = 'table' AND name = 'SailorGoodyOptions');

-- sight bomb
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon, SortIndex)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_SIGHTBOMB_NAME', 'GOODYHUT_SAILOR_SIGHTBOMB', 'LOC_GOODYHUT_SAILOR_SIGHTBOMB_DESC', 'ICON_DISTRICT_WONDER', 500
-- WHERE EXISTS (SELECT * FROM SailorGoodyOptions);
WHERE EXISTS (SELECT * FROM sqlite_master WHERE type = 'table' AND name = 'SailorGoodyOptions');

-- random policy
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon, SortIndex)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_RANDOMPOLICY_NAME', 'GOODYHUT_SAILOR_RANDOMPOLICY', 'LOC_GOODYHUT_SAILOR_RANDOMPOLICY_DESC', 'ICON_DISTRICT_WONDER', 500
-- WHERE EXISTS (SELECT * FROM SailorGoodyOptions);
WHERE EXISTS (SELECT * FROM sqlite_master WHERE type = 'table' AND name = 'SailorGoodyOptions');

-- formation
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon, SortIndex)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_FORMATION_NAME', 'GOODYHUT_SAILOR_FORMATION', 'LOC_GOODYHUT_SAILOR_FORMATION_DESC', 'ICON_DISTRICT_WONDER', 500
-- WHERE EXISTS (SELECT * FROM SailorGoodyOptions);
WHERE EXISTS (SELECT * FROM sqlite_master WHERE type = 'table' AND name = 'SailorGoodyOptions');

-- wonder
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon, SortIndex)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_WONDER_NAME', 'GOODYHUT_SAILOR_WONDER', 'LOC_GOODYHUT_SAILOR_WONDER_DESC', 'ICON_DISTRICT_WONDER', 500
-- WHERE EXISTS (SELECT * FROM SailorGoodyOptions);
WHERE EXISTS (SELECT * FROM sqlite_master WHERE type = 'table' AND name = 'SailorGoodyOptions');

-- city-state
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon, SortIndex)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_CITYSTATE_NAME', 'GOODYHUT_SAILOR_CITYSTATE', 'LOC_GOODYHUT_SAILOR_CITYSTATE_DESC', 'ICON_DISTRICT_WONDER', 500
-- WHERE EXISTS (SELECT * FROM SailorGoodyOptions);
WHERE EXISTS (SELECT * FROM sqlite_master WHERE type = 'table' AND name = 'SailorGoodyOptions');

-- spy
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon, SortIndex)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_SPY_NAME', 'GOODYHUT_SAILOR_SPY', 'LOC_GOODYHUT_SAILOR_SPY_DESC', 'ICON_DISTRICT_WONDER', 500
-- WHERE EXISTS (SELECT * FROM SailorGoodyOptions);
WHERE EXISTS (SELECT * FROM sqlite_master WHERE type = 'table' AND name = 'SailorGoodyOptions');

-- production
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon, SortIndex)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_PRODUCTION_NAME', 'GOODYHUT_SAILOR_PRODUCTION', 'LOC_GOODYHUT_SAILOR_PRODUCTION_DESC', 'ICON_DISTRICT_WONDER', 500
-- WHERE EXISTS (SELECT * FROM SailorGoodyOptions);
WHERE EXISTS (SELECT * FROM sqlite_master WHERE type = 'table' AND name = 'SailorGoodyOptions');

-- teleport
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon, SortIndex)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_TELEPORT_NAME', 'GOODYHUT_SAILOR_TELEPORT', 'LOC_GOODYHUT_SAILOR_TELEPORT_DESC', 'ICON_DISTRICT_WONDER', 500
-- WHERE EXISTS (SELECT * FROM SailorGoodyOptions);
WHERE EXISTS (SELECT * FROM sqlite_master WHERE type = 'table' AND name = 'SailorGoodyOptions');

/* ###########################################################################
    end WondrousGoodyHuts compatibility
########################################################################### */
