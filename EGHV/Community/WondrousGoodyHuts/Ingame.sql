/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2023 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin WondrousGoodyHuts ingame configuration
	WondrousGoodyHuts is property of Sailor Cat. All rights reserved.
########################################################################### */

-- UPDATE GoodyHutSubTypes SET Weight = 100 WHERE GoodyHut = 'GOODYHUT_SAILOR_WONDROUS';
REPLACE INTO GoodyHuts_EGHV
    (GoodyHutType, Weight)
VALUES
    -- WGH
    ('GOODYHUT_SAILOR_WONDROUS', 100);

REPLACE INTO GoodyHutSubTypes_EGHV
    (Weight, GoodyHut, MinTurn, SubTypeGoodyHut, MinOneCity, Description, RequiresUnit, Experience, ExperienceMultiplier, ModifierID, Unit, UnitAbility, UnitClass, UnitType, UpgradeUnit, Hostile, Fallback)
VALUES
    -- Abilities
    (100, 'GOODYHUT_SAILOR_WONDROUS', 0, 'GOODYHUT_SAILOR_RANDOMRESOURCE', 1, 'LOC_WGH_FLOAT_RESOURCE', 1, 0, NULL, 'SAILOR_GOODY_EMPTY', 0, NULL, NULL, NULL, 0, 0, 0),
    (100, 'GOODYHUT_SAILOR_WONDROUS', 0, 'GOODYHUT_SAILOR_RANDOMUNIT', 0, 'LOC_WGH_FLOAT_UNIT', 1, 0, NULL, 'SAILOR_GOODY_EMPTY', 0, NULL, NULL, NULL, 0, 0, 0),
    (100, 'GOODYHUT_SAILOR_WONDROUS', 0, 'GOODYHUT_SAILOR_RANDOMIMPROVEMENT', 1, 'LOC_WGH_FLOAT_IMPROVEMENT', 1, 0, NULL, 'SAILOR_GOODY_EMPTY', 0, NULL, NULL, NULL, 0, 0, 0),
    (100, 'GOODYHUT_SAILOR_WONDROUS', 0, 'GOODYHUT_SAILOR_SIGHTBOMB', 0, 'LOC_WGH_FLOAT_SIGHT', 1, 0, NULL, 'SAILOR_GOODY_EMPTY', 0, NULL, NULL, NULL, 0, 0, 0),
    (100, 'GOODYHUT_SAILOR_WONDROUS', 0, 'GOODYHUT_SAILOR_RANDOMPOLICY', 1, 'LOC_WGH_FLOAT_POLICY', 1, 0, NULL, 'SAILOR_GOODY_EMPTY', 0, NULL, NULL, NULL, 0, 0, 0),
    (100, 'GOODYHUT_SAILOR_WONDROUS', 0, 'GOODYHUT_SAILOR_FORMATION', 0, 'LOC_WGH_FLOAT_FORMATION', 1, 0, NULL, 'SAILOR_GOODY_EMPTY', 0, NULL, NULL, NULL, 0, 0, 0),
    (100, 'GOODYHUT_SAILOR_WONDROUS', 0, 'GOODYHUT_SAILOR_WONDER', 0, 'LOC_WGH_FLOAT_WONDER', 1, 0, NULL, 'SAILOR_GOODY_EMPTY', 0, NULL, NULL, NULL, 0, 0, 0),
    (100, 'GOODYHUT_SAILOR_WONDROUS', 0, 'GOODYHUT_SAILOR_CITYSTATE', 0, 'LOC_WGH_FLOAT_CITYSTATE', 1, 0, NULL, 'SAILOR_GOODY_EMPTY', 0, NULL, NULL, NULL, 0, 0, 0),
    (100, 'GOODYHUT_SAILOR_WONDROUS', 0, 'GOODYHUT_SAILOR_SPY', 1, 'LOC_WGH_FLOAT_SPY', 1, 0, NULL, 'SAILOR_GOODY_EMPTY', 0, NULL, NULL, NULL, 0, 0, 0),
    (100, 'GOODYHUT_SAILOR_WONDROUS', 0, 'GOODYHUT_SAILOR_PRODUCTION', 1, 'LOC_WGH_FLOAT_PRODUCTION', 1, 0, NULL, 'SAILOR_GOODY_EMPTY', 0, NULL, NULL, NULL, 0, 0, 0),
    (100, 'GOODYHUT_SAILOR_WONDROUS', 0, 'GOODYHUT_SAILOR_TELEPORT', 0, 'LOC_WGH_FLOAT_TELEPORT', 1, 0, NULL, 'SAILOR_GOODY_EMPTY', 0, NULL, NULL, NULL, 0, 0, 0);

/* ###########################################################################
    end WondrousGoodyHuts ingame configuration
########################################################################### */
