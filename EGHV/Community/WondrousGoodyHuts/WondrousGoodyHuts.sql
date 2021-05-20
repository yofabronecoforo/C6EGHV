/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin WondrousGoodyHuts compatibility
	WondrousGoodyHuts is the property of Sailor Cat. All rights reserved.
########################################################################### */

/* ###########################################################################
    ContentFlags
	these queries will be ignored when WondrousGoodyHuts is not enabled
########################################################################### */

-- add an entry for this mod to table ContentFlags; this facilitates picker and tooltip configuration
REPLACE INTO ContentFlags (Name, Id, CityStates, GoodyHuts, Leaders, NaturalWonders, SQL, Tooltip)
SELECT 'WondrousGoodyHuts', 'WGH', 0, 1, 0, 0, 'SELECT * FROM SailorGoodyOptions', '[NEWLINE]LOC_WGH_TT'
WHERE EXISTS (SELECT * FROM SailorGoodyOptions);

/* ###########################################################################
    Goody Hut picker configuration : StandardGoodyHuts
	these queries will be ignored when WondrousGoodyHuts is not enabled
########################################################################### */

-- random resource
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_RANDOMRESOURCE', 'GOODYHUT_SAILOR_RANDOMRESOURCE', 'LOC_GOODYHUT_SAILOR_RANDOMRESOURCE', 'ICON_DISTRICT_WONDER'
WHERE EXISTS (SELECT * FROM ContentFlags WHERE Id = 'WGH');

-- random unit
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_RANDOMUNIT', 'GOODYHUT_SAILOR_RANDOMUNIT', 'LOC_GOODYHUT_SAILOR_RANDOMUNIT', 'ICON_DISTRICT_WONDER'
WHERE EXISTS (SELECT * FROM ContentFlags WHERE Id = 'WGH');

-- random improvement
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_RANDOMIMPROVEMENT', 'GOODYHUT_SAILOR_RANDOMIMPROVEMENT', 'LOC_GOODYHUT_SAILOR_RANDOMIMPROVEMENT', 'ICON_DISTRICT_WONDER'
WHERE EXISTS (SELECT * FROM ContentFlags WHERE Id = 'WGH');

-- sight bomb
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_SIGHTBOMB', 'GOODYHUT_SAILOR_SIGHTBOMB', 'LOC_GOODYHUT_SAILOR_SIGHTBOMB', 'ICON_DISTRICT_WONDER'
WHERE EXISTS (SELECT * FROM ContentFlags WHERE Id = 'WGH');

-- random policy
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_RANDOMPOLICY', 'GOODYHUT_SAILOR_RANDOMPOLICY', 'LOC_GOODYHUT_SAILOR_RANDOMPOLICY', 'ICON_DISTRICT_WONDER'
WHERE EXISTS (SELECT * FROM ContentFlags WHERE Id = 'WGH');

-- formation
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_FORMATION', 'GOODYHUT_SAILOR_FORMATION', 'LOC_GOODYHUT_SAILOR_FORMATION', 'ICON_DISTRICT_WONDER'
WHERE EXISTS (SELECT * FROM ContentFlags WHERE Id = 'WGH');

-- wonder
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_WONDER', 'GOODYHUT_SAILOR_WONDER', 'LOC_GOODYHUT_SAILOR_WONDER', 'ICON_DISTRICT_WONDER'
WHERE EXISTS (SELECT * FROM ContentFlags WHERE Id = 'WGH');

-- city-state
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_CITYSTATE', 'GOODYHUT_SAILOR_CITYSTATE', 'LOC_GOODYHUT_SAILOR_CITYSTATE', 'ICON_DISTRICT_WONDER'
WHERE EXISTS (SELECT * FROM ContentFlags WHERE Id = 'WGH');

-- spy
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_SPY', 'GOODYHUT_SAILOR_SPY', 'LOC_GOODYHUT_SAILOR_SPY', 'ICON_DISTRICT_WONDER'
WHERE EXISTS (SELECT * FROM ContentFlags WHERE Id = 'WGH');

-- production
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_PRODUCTION', 'GOODYHUT_SAILOR_PRODUCTION', 'LOC_GOODYHUT_SAILOR_PRODUCTION', 'ICON_DISTRICT_WONDER'
WHERE EXISTS (SELECT * FROM ContentFlags WHERE Id = 'WGH');

-- teleport
REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon)
SELECT 'GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_TELEPORT', 'GOODYHUT_SAILOR_TELEPORT', 'LOC_GOODYHUT_SAILOR_TELEPORT', 'ICON_DISTRICT_WONDER'
WHERE EXISTS (SELECT * FROM ContentFlags WHERE Id = 'WGH');

/* ###########################################################################
    end WondrousGoodyHuts compatibility
########################################################################### */
