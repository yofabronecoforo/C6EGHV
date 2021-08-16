/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    Begin EGHV ingame configuration for Gathering Storm
########################################################################### */

-- new Types
REPLACE INTO Types
    (Type, Kind)
VALUES
    -- governor titles
    ('GOODYHUT_GOVERNORS', 'KIND_GOODY_HUT');

-- new GoodyHuts
REPLACE INTO GoodyHuts
    (GoodyHutType, Weight)
VALUES
    -- governor titles
    ('GOODYHUT_GOVERNORS', 100);

-- new GoodyHutSubTypes
REPLACE INTO GoodyHutSubTypes
    (GoodyHut, SubTypeGoodyHut, Description, Weight, Turn, MinOneCity, RequiresUnit, ModifierID)
VALUES
    -- governors type
    ('GOODYHUT_GOVERNORS', 'GOODYHUT_ONE_GOVERNOR_TITLE', 'LOC_GOODYHUT_GOVERNORS_ONE_TITLE_DESCRIPTION', 40, 0, 1, 1, 'GOODY_TITLES_GRANT_ONE'),
    ('GOODYHUT_GOVERNORS', 'GOODYHUT_TWO_GOVERNOR_TITLES', 'LOC_GOODYHUT_GOVERNORS_TWO_TITLES_DESCRIPTION', 30, 0, 1, 1, 'GOODY_TITLES_GRANT_TWO'),
    ('GOODYHUT_GOVERNORS', 'GOODYHUT_THREE_GOVERNOR_TITLES', 'LOC_GOODYHUT_GOVERNORS_THREE_TITLES_DESCRIPTION', 20, 0, 1, 1, 'GOODY_TITLES_GRANT_THREE'),
    ('GOODYHUT_GOVERNORS', 'GOODYHUT_FOUR_GOVERNOR_TITLES', 'LOC_GOODYHUT_GOVERNORS_FOUR_TITLES_DESCRIPTION', 10, 0, 1, 1, 'GOODY_TITLES_GRANT_FOUR');

-- new Modifiers
REPLACE INTO Modifiers
    (ModifierId, ModifierType, RunOnce, Permanent, SubjectRequirementSetId)
VALUES
    -- titles
    ('GOODY_TITLES_GRANT_ONE', 'MODIFIER_PLAYER_ADJUST_GOVERNOR_POINTS', 1, 1, NULL),
    ('GOODY_TITLES_GRANT_TWO', 'MODIFIER_PLAYER_ADJUST_GOVERNOR_POINTS', 1, 1, NULL),
    ('GOODY_TITLES_GRANT_THREE', 'MODIFIER_PLAYER_ADJUST_GOVERNOR_POINTS', 1, 1, NULL),
    ('GOODY_TITLES_GRANT_FOUR', 'MODIFIER_PLAYER_ADJUST_GOVERNOR_POINTS', 1, 1, NULL);

-- new ModifierArguments
REPLACE INTO ModifierArguments
    (ModifierId, Name, Value, Extra)
VALUES
    -- titles : +1 free
    ('GOODY_TITLES_GRANT_ONE', 'Delta', 1, NULL),
    -- titles : +2 free
    ('GOODY_TITLES_GRANT_TWO', 'Delta', 2, NULL),
    -- titles : +3 free
    ('GOODY_TITLES_GRANT_THREE', 'Delta', 3, NULL),
    -- titles : +4 free
    ('GOODY_TITLES_GRANT_FOUR', 'Delta', 4, NULL);

/* ###########################################################################
    End EGHV ingame configuration
########################################################################### */
