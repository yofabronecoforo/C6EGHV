/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    Begin EGHV ingame configuration for Gathering Storm
########################################################################### */

-- 
-- UPDATE GoodyHuts SET Weight = 630 WHERE GoodyHutType = 'GOODYHUT_DIPLOMACY';
-- UPDATE GoodyHuts SET Weight = 630 WHERE GoodyHutType = 'GOODYHUT_MILITARY';

-- Adjust the weight value and other properties assigned to individual existing Diplomacy-type rewards
UPDATE GoodyHutSubTypes SET Weight = 320, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_FAVOR';                -- defaults : Weight = 45, Turn = 30
UPDATE GoodyHutSubTypes SET Weight = 160, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_ENVOY';                 -- defaults : Weight = 40
UPDATE GoodyHutSubTypes SET Weight = 80, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_GOVERNOR_TITLE';        -- defaults : Weight = 15, Turn = 30

-- Adjust the weight value and other properties assigned to individual existing Military-type rewards
UPDATE GoodyHutSubTypes SET Weight = 80, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_GRANT_EXPERIENCE';      -- defaults : Weight = 20
UPDATE GoodyHutSubTypes SET Weight = 80, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_RESOURCES';             -- defaults : Weight = 20

-- New Goody Hut rewards : GoodyHutSubTypes
REPLACE INTO GoodyHutSubTypes (GoodyHut, SubTypeGoodyHut, Description, Weight, Turn, MinOneCity, RequiresUnit, ModifierID)
VALUES
    -- Diplomacy
    ('GOODYHUT_DIPLOMACY', 'GOODYHUT_TWO_ENVOYS', 'LOC_GOODYHUT_DIPLOMACY_ENVOYS_DESCRIPTION', 40, 0, 1, 1, 'GOODY_DIPLOMACY_GRANT_TWO_ENVOYS'),
    ('GOODYHUT_DIPLOMACY', 'GOODYHUT_TWO_GOVERNOR_TITLES', 'LOC_GOODYHUT_DIPLOMACY_GOVERNOR_TITLES_DESCRIPTION', 20, 0, 1, 1, 'GOODY_DIPLOMACY_GRANT_TWO_GOVERNOR_TITLES'),
    ('GOODYHUT_DIPLOMACY', 'GOODYHUT_SMALL_BOOST_FAVOR', 'LOC_GOODYHUT_DIPLOMACY_SMALL_BOOST_FAVOR_DESCRIPTION', 10, 0, 1, 1, 'GOODY_DIPLOMACY_FAVOR_SMALL_BOOST');

-- New Goody Hut rewards : Modifiers
REPLACE INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent)
VALUES
    -- Diplomacy
    ('GOODY_DIPLOMACY_GRANT_TWO_ENVOYS', 'MODIFIER_PLAYER_GRANT_INFLUENCE_TOKEN', 1, 1),
    ('GOODY_DIPLOMACY_GRANT_TWO_GOVERNOR_TITLES', 'MODIFIER_PLAYER_ADJUST_GOVERNOR_POINTS', 1, 1),
    ('GOODY_DIPLOMACY_FAVOR_SMALL_BOOST', 'MODIFIER_PLAYER_ADJUST_EXTRA_FAVOR_PER_TURN', 1, 1);

-- New Goody Hut rewards : ModifierArguments
REPLACE INTO ModifierArguments (ModifierId, Name, Value, Extra)
VALUES
    -- Diplomacy : two envoys
    ('GOODY_DIPLOMACY_GRANT_TWO_ENVOYS', 'Amount', 2, NULL),
    -- Diplomacy : two governor titles
    ('GOODY_DIPLOMACY_GRANT_TWO_GOVERNOR_TITLES', 'Delta', 2, NULL),
    -- Diplomacy : 
    ('GOODY_DIPLOMACY_FAVOR_SMALL_BOOST', 'Amount', 3, NULL);

-- Adjust the overall weight(s) assigned to Goody Hut types based on the sum of the weights of the individual rewards of that type
-- Set the individual weights once above, and this will do the rest
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_DIPLOMACY') WHERE GoodyHutType = 'GOODYHUT_DIPLOMACY';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_MILITARY') WHERE GoodyHutType = 'GOODYHUT_MILITARY';

-- Add rows to table GoodyHutSubTypes_XP2 for new rewards which are similar to any built-in XP2 rewards
REPLACE INTO GoodyHutSubTypes_XP2 (SubTypeGoodyHut, CityState)
VALUES
    ('GOODYHUT_TWO_ENVOYS', 1);

/* ###########################################################################
    End EGHV ingame configuration for Gathering Storm
########################################################################### */
