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
    -- strategic resources
    ('GOODYHUT_RESOURCES', 'KIND_GOODY_HUT');

REPLACE INTO GoodyHuts
    (GoodyHutType, Weight)
VALUES
    -- strategic resources
    ('GOODYHUT_RESOURCES', 100);

-- disable Diplomacy-type rewards supplied by Gathering Storm, as these rewards are provided by other types and/or earlier rulesets in EGHV
UPDATE GoodyHutSubTypes SET Weight = 0, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_FAVOR';                -- defaults : Weight = 45, Turn = 30
UPDATE GoodyHutSubTypes SET Weight = 0, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_ENVOY';                 -- defaults : Weight = 40
UPDATE GoodyHutSubTypes SET Weight = 0, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_GOVERNOR_TITLE';        -- defaults : Weight = 15, Turn = 30

-- disable Military-type rewards supplied by Gathering Storm, as these rewards are provided by other types and/or earlier rulesets in EGHV
UPDATE GoodyHutSubTypes SET Weight = 0, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_GRANT_EXPERIENCE';      -- defaults : Weight = 20
UPDATE GoodyHutSubTypes SET Weight = 0, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_RESOURCES';             -- defaults : Weight = 20

-- New Goody Hut rewards : GoodyHutSubTypes
REPLACE INTO GoodyHutSubTypes
    (GoodyHut, SubTypeGoodyHut, Description, Weight, Turn, MinOneCity, RequiresUnit, ModifierID)
VALUES
    -- Diplomacy
    ('GOODYHUT_DIPLOMACY', 'GOODYHUT_SMALL_FAVOR', 'LOC_GOODYHUT_SMALL_FAVOR_DESCRIPTION', 40, 0, 1, 1, 'GOODY_FAVOR_SMALL_MODIFIER'),
    ('GOODYHUT_DIPLOMACY', 'GOODYHUT_MEDIUM_FAVOR', 'LOC_GOODYHUT_MEDIUM_FAVOR_DESCRIPTION', 30, 0, 1, 1, 'GOODY_FAVOR_MEDIUM_MODIFIER'),
    ('GOODYHUT_DIPLOMACY', 'GOODYHUT_LARGE_FAVOR', 'LOC_GOODYHUT_LARGE_FAVOR_DESCRIPTION', 20, 0, 1, 1, 'GOODY_FAVOR_LARGE_MODIFIER'),
    ('GOODYHUT_DIPLOMACY', 'GOODYHUT_HUGE_FAVOR', 'LOC_GOODYHUT_HUGE_FAVOR_DESCRIPTION', 10, 0, 1, 1, 'GOODY_FAVOR_HUGE_MODIFIER'),
    -- Resources
    ('GOODYHUT_RESOURCES', 'GOODYHUT_SMALL_RESOURCES', 'LOC_GOODYHUT_RESOURCES_DESCRIPTION', 40, 0, 1, 1, 'GOODY_RESOURCES_SMALL_MODIFIER'),
    ('GOODYHUT_RESOURCES', 'GOODYHUT_MEDIUM_RESOURCES', 'LOC_GOODYHUT_RESOURCES_DESCRIPTION', 30, 0, 1, 1, 'GOODY_RESOURCES_MEDIUM_MODIFIER'),
    ('GOODYHUT_RESOURCES', 'GOODYHUT_LARGE_RESOURCES', 'LOC_GOODYHUT_RESOURCES_DESCRIPTION', 20, 0, 1, 1, 'GOODY_RESOURCES_LARGE_MODIFIER'),
    ('GOODYHUT_RESOURCES', 'GOODYHUT_HUGE_RESOURCES', 'LOC_GOODYHUT_RESOURCES_DESCRIPTION', 10, 0, 1, 1, 'GOODY_RESOURCES_HUGE_MODIFIER');

-- New Modifiers
REPLACE INTO Modifiers
    (ModifierId, ModifierType, RunOnce, Permanent, SubjectRequirementSetId)
VALUES
    -- Villager Totem building
    ('TRIBAL_TOTEM_AMENITIES_AT_FULL_LOYALTY', 'MODIFIER_SINGLE_CITY_ADJUST_ENTERTAINMENT', 0, 0, 'MONUMENT_FULL_LOYALTY_REQUIREMENTS'),
    ('TRIBAL_TOTEM_FAVOR_AT_LVL1', 'MODIFIER_PLAYER_ADJUST_BUILDING_FAVOR', 0, 0, NULL),
    ('TRIBAL_TOTEM_FAVOR_AT_LVL2', 'MODIFIER_PLAYER_ADJUST_BUILDING_FAVOR', 0, 0, NULL),
    ('TRIBAL_TOTEM_FAVOR_AT_LVL3', 'MODIFIER_PLAYER_ADJUST_BUILDING_FAVOR', 0, 0, NULL),
    ('TRIBAL_TOTEM_FAVOR_AT_LVL4', 'MODIFIER_PLAYER_ADJUST_BUILDING_FAVOR', 0, 0, NULL),
    ('TRIBAL_TOTEM_FAVOR_AT_LVL5', 'MODIFIER_PLAYER_ADJUST_BUILDING_FAVOR', 0, 0, NULL),
    -- Diplomacy
    ('GOODY_FAVOR_SMALL_MODIFIER', 'MODIFIER_PLAYER_ADD_FAVOR', 1, 1, NULL),
    ('GOODY_FAVOR_MEDIUM_MODIFIER', 'MODIFIER_PLAYER_ADD_FAVOR', 1, 1, NULL),
    ('GOODY_FAVOR_LARGE_MODIFIER', 'MODIFIER_PLAYER_ADD_FAVOR', 1, 1, NULL),
    ('GOODY_FAVOR_HUGE_MODIFIER', 'MODIFIER_PLAYER_ADD_FAVOR', 1, 1, NULL),
    -- Resources
    ('GOODY_RESOURCES_SMALL_MODIFIER', 'MODIFIER_PLAYER_ADJUST_MOST_ADVANCED_STRATEGIC_RESOURCE_COUNT', 1, 1, NULL),
    ('GOODY_RESOURCES_MEDIUM_MODIFIER', 'MODIFIER_PLAYER_ADJUST_MOST_ADVANCED_STRATEGIC_RESOURCE_COUNT', 1, 1, NULL),
    ('GOODY_RESOURCES_LARGE_MODIFIER', 'MODIFIER_PLAYER_ADJUST_MOST_ADVANCED_STRATEGIC_RESOURCE_COUNT', 1, 1, NULL),
    ('GOODY_RESOURCES_HUGE_MODIFIER', 'MODIFIER_PLAYER_ADJUST_MOST_ADVANCED_STRATEGIC_RESOURCE_COUNT', 1, 1, NULL);

-- New BuildingModifiers
REPLACE INTO BuildingModifiers
    (BuildingType, ModifierId)
VALUES
    -- Villager Totem building
    ('BUILDING_TRIBAL_TOTEM_LVL0', 'TRIBAL_TOTEM_AMENITIES_AT_FULL_LOYALTY'),
    ('BUILDING_TRIBAL_TOTEM_LVL1', 'TRIBAL_TOTEM_AMENITIES_AT_FULL_LOYALTY'),
    ('BUILDING_TRIBAL_TOTEM_LVL1', 'TRIBAL_TOTEM_FAVOR_AT_LVL1'),
    ('BUILDING_TRIBAL_TOTEM_LVL2', 'TRIBAL_TOTEM_AMENITIES_AT_FULL_LOYALTY'),
    ('BUILDING_TRIBAL_TOTEM_LVL2', 'TRIBAL_TOTEM_FAVOR_AT_LVL2'),
    ('BUILDING_TRIBAL_TOTEM_LVL3', 'TRIBAL_TOTEM_AMENITIES_AT_FULL_LOYALTY'),
    ('BUILDING_TRIBAL_TOTEM_LVL3', 'TRIBAL_TOTEM_FAVOR_AT_LVL3'),
    ('BUILDING_TRIBAL_TOTEM_LVL4', 'TRIBAL_TOTEM_AMENITIES_AT_FULL_LOYALTY'),
    ('BUILDING_TRIBAL_TOTEM_LVL4', 'TRIBAL_TOTEM_FAVOR_AT_LVL4'),
    ('BUILDING_TRIBAL_TOTEM_LVL5', 'TRIBAL_TOTEM_AMENITIES_AT_FULL_LOYALTY'),
    ('BUILDING_TRIBAL_TOTEM_LVL5', 'TRIBAL_TOTEM_FAVOR_AT_LVL5');

-- new ModifierArguments : Resources rewards
REPLACE INTO ModifierArguments
    (ModifierId, Name, Value, Type)
VALUES
    -- Resources
    ('GOODY_RESOURCES_SMALL_MODIFIER', 'Amount', 10, 'ScaleByGameSpeed'),
    ('GOODY_RESOURCES_MEDIUM_MODIFIER', 'Amount', 20, 'ScaleByGameSpeed'),
    ('GOODY_RESOURCES_LARGE_MODIFIER', 'Amount', 30, 'ScaleByGameSpeed'),
    ('GOODY_RESOURCES_HUGE_MODIFIER', 'Amount', 50, 'ScaleByGameSpeed');

-- new ModifierArguments : Tribal Totem and Diplomacy rewards
REPLACE INTO ModifierArguments
    (ModifierId, Name, Value, Extra)
VALUES
    -- Villager Totem building
    ('TRIBAL_TOTEM_AMENITIES_AT_FULL_LOYALTY', 'Amount', 1, NULL),
    ('TRIBAL_TOTEM_FAVOR_AT_LVL1', 'Amount', 1, NULL),
    ('TRIBAL_TOTEM_FAVOR_AT_LVL2', 'Amount', 2, NULL),
    ('TRIBAL_TOTEM_FAVOR_AT_LVL3', 'Amount', 3, NULL),
    ('TRIBAL_TOTEM_FAVOR_AT_LVL4', 'Amount', 4, NULL),
    ('TRIBAL_TOTEM_FAVOR_AT_LVL5', 'Amount', 5, NULL),
    -- Diplomacy
    ('GOODY_FAVOR_SMALL_MODIFIER', 'Amount', 10, NULL),
    ('GOODY_FAVOR_MEDIUM_MODIFIER', 'Amount', 20, NULL),
    ('GOODY_FAVOR_LARGE_MODIFIER', 'Amount', 30, NULL),
    ('GOODY_FAVOR_HUGE_MODIFIER', 'Amount', 50, NULL);

-- Normalize Goody Hut type and subtype weights here
-- Start by resetting the overall weight of type GOODYHUT_MILITARY
-- UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_MILITARY') WHERE GoodyHutType = 'GOODYHUT_MILITARY';

-- -- 2021/05/04 With EGHV, GOODYHUT_MILITARY has either 2x or (2x - 1) as many subtypes as any other type, and its default weight should be 2x that of any other type
-- -- There's likely a smarter way to do this, but for now, since other subtype(s) should have already been adjusted, here we're just going to increase GOODYHUT_DIPLOMACY subtype weights by a factor of 2
-- UPDATE GoodyHutSubTypes SET Weight = Weight * 2 WHERE GoodyHut = 'GOODYHUT_DIPLOMACY';

-- -- Next, reset the remaining type weights based on the updated sums of the subtypes of each type
-- -- UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_CULTURE') WHERE GoodyHutType = 'GOODYHUT_CULTURE';
-- UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_DIPLOMACY') WHERE GoodyHutType = 'GOODYHUT_DIPLOMACY';
-- -- UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_GOLD') WHERE GoodyHutType = 'GOODYHUT_GOLD';
-- -- UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_FAITH') WHERE GoodyHutType = 'GOODYHUT_FAITH';
-- -- UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SCIENCE') WHERE GoodyHutType = 'GOODYHUT_SCIENCE';
-- -- UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SURVIVORS') WHERE GoodyHutType = 'GOODYHUT_SURVIVORS';

-- -- Set the meteor-strike reward's type weight equal to that of GOODYHUT_MILITARY, and its subtype weight equal to same
-- UPDATE GoodyHuts SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_MILITARY') WHERE GoodyHutType = 'METEOR_GOODIES';
-- UPDATE GoodyHutSubTypes SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'METEOR_GOODIES') WHERE SubTypeGoodyHut = 'METEOR_GRANT_GOODIES';

-- -- Finally, reset the hostile villagers "reward" type and subtype in the same way as above
-- UPDATE GoodyHuts SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_MILITARY') WHERE GoodyHutType = 'GOODYHUT_HOSTILES';
-- UPDATE GoodyHutSubTypes SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_HOSTILES') WHERE SubTypeGoodyHut = 'GOODYHUT_SPAWN_HOSTILE_VILLAGERS';
-- UPDATE GoodyHutSubTypes SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_SECRETS') WHERE SubTypeGoodyHut = 'GOODYHUT_UNLOCK_VILLAGER_SECRETS';

-- Add rows to table GoodyHutSubTypes_XP2 for new rewards which are similar to any built-in XP2 rewards
REPLACE INTO GoodyHutSubTypes_XP2 (SubTypeGoodyHut, CityState)
VALUES
    ('GOODYHUT_ONE_ENVOY', 1),
    ('GOODYHUT_TWO_ENVOYS', 1),
    ('GOODYHUT_THREE_ENVOYS', 1),
    ('GOODYHUT_FOUR_ENVOYS', 1);

/* ###########################################################################
    End EGHV ingame configuration for Gathering Storm
########################################################################### */
