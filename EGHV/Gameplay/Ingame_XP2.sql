/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    Begin EGHV ingame configuration for Gathering Storm
########################################################################### */

-- Adjust the weight value and other properties assigned to individual existing Diplomacy-type rewards
UPDATE GoodyHutSubTypes SET Weight = 60, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_FAVOR';                -- defaults : Weight = 45, Turn = 30
UPDATE GoodyHutSubTypes SET Weight = 50, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_ENVOY';                 -- defaults : Weight = 40
UPDATE GoodyHutSubTypes SET Weight = 40, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_GOVERNOR_TITLE';        -- defaults : Weight = 15, Turn = 30

-- Adjust the weight value and other properties assigned to individual existing Military-type rewards
UPDATE GoodyHutSubTypes SET Weight = 60, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_GRANT_EXPERIENCE';      -- defaults : Weight = 20
UPDATE GoodyHutSubTypes SET Weight = 60, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_RESOURCES';             -- defaults : Weight = 20

-- New Goody Hut rewards : GoodyHutSubTypes
REPLACE INTO GoodyHutSubTypes (GoodyHut, SubTypeGoodyHut, Description, Weight, Turn, MinOneCity, RequiresUnit, ModifierID)
VALUES
    -- Diplomacy
    ('GOODYHUT_DIPLOMACY', 'GOODYHUT_TWO_ENVOYS', 'LOC_GOODYHUT_DIPLOMACY_ENVOYS_DESCRIPTION', 30, 0, 1, 1, 'GOODY_DIPLOMACY_GRANT_TWO_ENVOYS'),
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

-- Normalize Goody Hut type and subtype weights here
-- Start by resetting the overall weight of type GOODYHUT_MILITARY
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_MILITARY') WHERE GoodyHutType = 'GOODYHUT_MILITARY';

-- 2021/05/04 With EGHV, GOODYHUT_MILITARY has either 2x or (2x - 1) as many subtypes as any other type, and its default weight should be 2x that of any other type
-- There's likely a smarter way to do this, but for now, since other subtype(s) should have already been adjusted, here we're just going to increase GOODYHUT_DIPLOMACY subtype weights by a factor of 2
UPDATE GoodyHutSubTypes SET Weight = Weight * 2 WHERE GoodyHut = 'GOODYHUT_DIPLOMACY';

-- Next, reset the remaining type weights based on the updated sums of the subtypes of each type
-- UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_CULTURE') WHERE GoodyHutType = 'GOODYHUT_CULTURE';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_DIPLOMACY') WHERE GoodyHutType = 'GOODYHUT_DIPLOMACY';
-- UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_GOLD') WHERE GoodyHutType = 'GOODYHUT_GOLD';
-- UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_FAITH') WHERE GoodyHutType = 'GOODYHUT_FAITH';
-- UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SCIENCE') WHERE GoodyHutType = 'GOODYHUT_SCIENCE';
-- UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SURVIVORS') WHERE GoodyHutType = 'GOODYHUT_SURVIVORS';

-- Set the meteor-strike reward's type weight equal to that of GOODYHUT_MILITARY, and its subtype weight equal to same
UPDATE GoodyHuts SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_MILITARY') WHERE GoodyHutType = 'METEOR_GOODIES';
UPDATE GoodyHutSubTypes SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'METEOR_GOODIES') WHERE SubTypeGoodyHut = 'METEOR_GRANT_GOODIES';

-- Finally, reset the hostile villagers "reward" type and subtype in the same way as above
UPDATE GoodyHuts SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_MILITARY') WHERE GoodyHutType = 'GOODYHUT_HOSTILES';
UPDATE GoodyHutSubTypes SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_HOSTILES') WHERE SubTypeGoodyHut = 'GOODYHUT_SPAWN_HOSTILE_VILLAGERS';

-- Add rows to table GoodyHutSubTypes_XP2 for new rewards which are similar to any built-in XP2 rewards
REPLACE INTO GoodyHutSubTypes_XP2 (SubTypeGoodyHut, CityState)
VALUES
    ('GOODYHUT_TWO_ENVOYS', 1);

/* ###########################################################################
    End EGHV ingame configuration for Gathering Storm
########################################################################### */
