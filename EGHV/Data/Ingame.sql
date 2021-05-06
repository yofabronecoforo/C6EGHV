/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    Begin EGHV ingame configuration
########################################################################### */

-- Add the Hostiles-type "reward" to gameplay table Types
REPLACE INTO Types (Type, Kind) VALUES ('GOODYHUT_HOSTILES', 'KIND_GOODY_HUT');

-- Add the Hostiles-type "reward" to gameplay table GoodyHuts; the Weight value provided here will likely be overwritten below
REPLACE INTO GoodyHuts (GoodyHutType, Weight) VALUES ('GOODYHUT_HOSTILES', 100);

-- Modify the cap on experience gained from killing barbarians; default : Value = 1
UPDATE GlobalParameters SET Value = 2 WHERE Name = 'EXPERIENCE_BARB_SOFT_CAP';

-- Modify the maximum level attainable by killing barbarians (units begin at Level 1); default : Value = 2
UPDATE GlobalParameters SET Value = 4 WHERE Name = 'EXPERIENCE_MAX_BARB_LEVEL';

-- Modify the amount of experience gained from clearing a goody hut; default : Value = 10 (Pre XP2) | 8 (XP2 and beyond) [maybe now a hard 5 by default? fuck it]
UPDATE GlobalParameters SET Value = 6 WHERE Name = 'EXPERIENCE_ACTIVATE_GOODY_HUT';

-- Adjust the frequency of, minimum distance between, and gold earned for clearing Goody Huts; defaults : TilesPerGoody = 128, GoodyRange = 3, DispersalGold = ?
UPDATE Improvements SET TilesPerGoody = 64, GoodyRange = 2, DispersalGold = 0 WHERE ImprovementType = 'IMPROVEMENT_GOODY_HUT';

-- Adjust the weight value and other properties assigned to individual existing Culture-type rewards
UPDATE GoodyHutSubTypes SET Weight = 60, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_ONE_CIVIC_BOOST';       -- defaults : Weight = 55
UPDATE GoodyHutSubTypes SET Weight = 50, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_TWO_CIVIC_BOOSTS';      -- defaults : Weight = 30, Turn = 30

-- Adjust the weight value and other properties assigned to individual existing Faith-type rewards
UPDATE GoodyHutSubTypes SET Weight = 60, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_SMALL_FAITH';               -- defaults : Weight = 55, Turn = 20
UPDATE ModifierArguments SET Value = 20 WHERE ModifierId = 'GOODY_FAITH_SMALL_MODIFIER' AND Name = 'Amount';    -- defaults : Value = 20
UPDATE GoodyHutSubTypes SET Weight = 50, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_MEDIUM_FAITH';              -- defaults : Weight = 30, Turn = 40
UPDATE ModifierArguments SET Value = 60 WHERE ModifierId = 'GOODY_FAITH_MEDIUM_MODIFIER' AND Name = 'Amount';   -- defaults : Value = 60
UPDATE GoodyHutSubTypes SET Weight = 40, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_LARGE_FAITH';               -- defaults : Weight = 15, Turn = 60
UPDATE ModifierArguments SET Value = 100 WHERE ModifierId = 'GOODY_FAITH_LARGE_MODIFIER' AND Name = 'Amount';   -- defaults : Value = 100

-- Make "one relic" a Faith-type reward (was Culture-type); adjust its weight value and other properties
UPDATE GoodyHutSubTypes SET GoodyHut = 'GOODYHUT_FAITH', Weight = 30, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_ONE_RELIC';              -- defaults : Weight = 15

-- Adjust the weight value and other properties assigned to individual existing Gold-type rewards
UPDATE GoodyHutSubTypes SET Weight = 60, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_SMALL_GOLD';                -- defaults : Weight = 55
UPDATE ModifierArguments SET Value = 40 WHERE ModifierId = 'GOODY_GOLD_SMALL_MODIFIER' AND Name = 'Amount';     -- defaults : Value = 40
UPDATE GoodyHutSubTypes SET Weight = 50, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_MEDIUM_GOLD';               -- defaults : Weight = 30, Turn = 20
UPDATE ModifierArguments SET Value = 80 WHERE ModifierId = 'GOODY_GOLD_MEDIUM_MODIFIER' AND Name = 'Amount';    -- defaults : Value = 75
UPDATE GoodyHutSubTypes SET Weight = 40, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_LARGE_GOLD';                -- defaults : Weight = 15, Turn = 40
UPDATE ModifierArguments SET Value = 120 WHERE ModifierId = 'GOODY_GOLD_LARGE_MODIFIER' AND Name = 'Amount';    -- defaults : Value = 120

-- Adjust the weight value and other properties assigned to individual existing Military-type rewards
UPDATE GoodyHutSubTypes SET Weight = 0, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_HEAL';                                           -- defaults : Weight = 30
UPDATE GoodyHutSubTypes SET Weight = 0, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_GRANT_UPGRADE';                                  -- defaults : Weight = 0
UPDATE GoodyHutSubTypes SET Weight = 120, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_GRANT_EXPERIENCE';                              -- defaults : Weight = 30
UPDATE GoodyHutSubTypes SET Weight = 50, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_GRANT_SCOUT';                                   -- defaults : Weight = 40

-- Adjust the weight value and other properties assigned to individual existing Science-type rewards
UPDATE GoodyHutSubTypes SET Weight = 60, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_ONE_TECH_BOOST';        -- defaults : Weight = 55
UPDATE GoodyHutSubTypes SET Weight = 50, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_TWO_TECH_BOOSTS';       -- defaults : Weight = 30, Turn = 30
UPDATE GoodyHutSubTypes SET Weight = 40, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_ONE_TECH';              -- defaults : Weight = 15, Turn = 50

-- Adjust the weight value and other properties assigned to individual existing Survivor-type rewards
UPDATE GoodyHutSubTypes SET Weight = 60, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_ADD_POP';           -- defaults : Weight = 40
UPDATE GoodyHutSubTypes SET Weight = 50, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_GRANT_BUILDER';     -- defaults : Weight = 35
UPDATE GoodyHutSubTypes SET Weight = 40, Turn = 0, Trader = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_GRANT_TRADER';      -- defaults : Weight = 25, Turn = 15
UPDATE GoodyHutSubTypes SET Weight = 30, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_GRANT_SETTLER';      -- defaults : Weight = 0

-- New Goody Hut rewards : GoodyHutSubTypes
REPLACE INTO GoodyHutSubTypes (GoodyHut, SubTypeGoodyHut, Description, Weight, Turn, MinOneCity, RequiresUnit, ModifierID)
VALUES
    -- Culture
    ('GOODYHUT_CULTURE', 'GOODYHUT_ONE_CIVIC', 'LOC_GOODYHUT_CULTURE_ONE_CIVIC_DESCRIPTION', 40, 0, 1, 1, 'GOODY_CULTURE_GRANT_ONE_CIVIC'),
    ('GOODYHUT_CULTURE', 'GOODYHUT_TWO_CIVICS', 'LOC_GOODYHUT_CULTURE_TWO_CIVICS_DESCRIPTION', 30, 0, 1, 1, 'GOODY_CULTURE_GRANT_TWO_CIVICS'),
    ('GOODYHUT_CULTURE', 'GOODYHUT_SMALL_CHANGE_CULTURE', 'LOC_GOODYHUT_CULTURE_SMALL_CHANGE_DESCRIPTION', 20, 0, 1, 1, 'GOODY_CULTURE_SMALL_CHANGE'),
    ('GOODYHUT_CULTURE', 'GOODYHUT_SMALL_MODIFIER_CULTURE', 'LOC_GOODYHUT_CULTURE_SMALL_MODIFIER_DESCRIPTION', 10, 0, 1, 1, 'GOODY_CULTURE_CITIES_SMALL_MODIFIER'),
    -- Faith
    ('GOODYHUT_FAITH', 'GOODYHUT_SMALL_CHANGE_FAITH', 'LOC_GOODYHUT_FAITH_SMALL_CHANGE_DESCRIPTION', 20, 0, 1, 1, 'GOODY_FAITH_SMALL_CHANGE'),
    ('GOODYHUT_FAITH', 'GOODYHUT_SMALL_MODIFIER_FAITH', 'LOC_GOODYHUT_FAITH_SMALL_MODIFIER_DESCRIPTION', 10, 0, 1, 1, 'GOODY_FAITH_CITIES_SMALL_MODIFIER'),
    -- Gold
    ('GOODYHUT_GOLD', 'GOODYHUT_ADD_TRADE_ROUTE', 'LOC_GOODYHUT_ADD_TRADE_ROUTE_DESCRIPTION', 30, 0, 1, 1, 'GOODY_GOLD_ADD_TRADE_ROUTE'),
    ('GOODYHUT_GOLD', 'GOODYHUT_SMALL_CHANGE_GOLD', 'LOC_GOODYHUT_GOLD_SMALL_CHANGE_DESCRIPTION', 20, 0, 1, 1, 'GOODY_GOLD_SMALL_CHANGE'),
    ('GOODYHUT_GOLD', 'GOODYHUT_SMALL_MODIFIER_GOLD', 'LOC_GOODYHUT_GOLD_SMALL_MODIFIER_DESCRIPTION', 10, 0, 1, 1, 'GOODY_GOLD_CITIES_SMALL_MODIFIER'),
    -- Military
    ('GOODYHUT_MILITARY', 'GOODYHUT_GRANT_WARRIOR', 'LOC_GOODYHUT_MILITARY_GRANT_MELEE_UNIT_DESCRIPTION', 50, 0, 1, 1, 'GOODY_MILITARY_GRANT_WARRIOR'),
    ('GOODYHUT_MILITARY', 'GOODYHUT_GRANT_SLINGER', 'LOC_GOODYHUT_MILITARY_GRANT_RANGED_UNIT_DESCRIPTION', 40, 0, 1, 1, 'GOODY_MILITARY_GRANT_SLINGER'),
    ('GOODYHUT_MILITARY', 'GOODYHUT_GRANT_SPEARMAN', 'LOC_GOODYHUT_MILITARY_GRANT_ANTI_CAVALRY_UNIT_DESCRIPTION', 40, 0, 1, 1, 'GOODY_MILITARY_GRANT_SPEARMAN'),
    ('GOODYHUT_MILITARY', 'GOODYHUT_GRANT_HORSEMAN', 'LOC_GOODYHUT_MILITARY_GRANT_LIGHT_CAVALRY_UNIT_DESCRIPTION', 30, 0, 1, 1, 'GOODY_MILITARY_GRANT_HORSEMAN'),
    ('GOODYHUT_MILITARY', 'GOODYHUT_GRANT_HEAVY_CHARIOT', 'LOC_GOODYHUT_MILITARY_GRANT_HEAVY_CAVALRY_UNIT_DESCRIPTION', 30, 0, 1, 1, 'GOODY_MILITARY_GRANT_HEAVY_CHARIOT'),
    ('GOODYHUT_MILITARY', 'GOODYHUT_GRANT_MILITARY_ENGINEER', 'LOC_GOODYHUT_MILITARY_GRANT_MILITARY_ENGINEER_DESCRIPTION', 20, 0, 1, 1, 'GOODY_MILITARY_GRANT_MILITARY_ENGINEER'),
    ('GOODYHUT_MILITARY', 'GOODYHUT_GRANT_MEDIC', 'LOC_GOODYHUT_MILITARY_GRANT_MEDIC_DESCRIPTION', 20, 0, 1, 1, 'GOODY_MILITARY_GRANT_MEDIC'),
    ('GOODYHUT_MILITARY', 'GOODYHUT_SMALL_CHANGE_PRODUCTION', 'LOC_GOODYHUT_PRODUCTION_SMALL_CHANGE_DESCRIPTION', 10, 0, 1, 1, 'GOODY_PRODUCTION_SMALL_CHANGE'),
    ('GOODYHUT_MILITARY', 'GOODYHUT_SMALL_MODIFIER_PRODUCTION', 'LOC_GOODYHUT_PRODUCTION_SMALL_MODIFIER_DESCRIPTION', 10, 0, 1, 1, 'GOODY_PRODUCTION_CITIES_SMALL_MODIFIER'),
    -- Science
    ('GOODYHUT_SCIENCE', 'GOODYHUT_TWO_TECHS', 'LOC_GOODYHUT_SCIENCE_TWO_TECHS_DESCRIPTION', 30, 0, 1, 1, 'GOODY_SCIENCE_GRANT_TWO_TECHS'),
    ('GOODYHUT_SCIENCE', 'GOODYHUT_SMALL_CHANGE_SCIENCE', 'LOC_GOODYHUT_SCIENCE_SMALL_CHANGE_DESCRIPTION', 20, 0, 1, 1, 'GOODY_SCIENCE_SMALL_CHANGE'),
    ('GOODYHUT_SCIENCE', 'GOODYHUT_SMALL_MODIFIER_SCIENCE', 'LOC_GOODYHUT_SCIENCE_SMALL_MODIFIER_DESCRIPTION', 10, 0, 1, 1, 'GOODY_SCIENCE_CITIES_SMALL_MODIFIER'),
    -- Survivors
    ('GOODYHUT_SURVIVORS', 'GOODYHUT_SMALL_CHANGE_FOOD', 'LOC_GOODYHUT_FOOD_SMALL_CHANGE_DESCRIPTION', 20, 0, 1, 1, 'GOODY_FOOD_SMALL_CHANGE'),
    ('GOODYHUT_SURVIVORS', 'GOODYHUT_SMALL_MODIFIER_FOOD', 'LOC_GOODYHUT_FOOD_SMALL_MODIFIER_DESCRIPTION', 10, 0, 1, 1, 'GOODY_FOOD_CITIES_SMALL_MODIFIER'),
    -- Hostiles
    ('GOODYHUT_HOSTILES', 'GOODYHUT_SPAWN_HOSTILE_VILLAGERS', 'LOC_GOODYHUT_SPAWN_HOSTILE_VILLAGERS_DESCRIPTION', 100, 0, 1, 1, 'GOODY_SPAWN_HOSTILES');

-- New Goody Hut rewards : Modifiers
REPLACE INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent)
VALUES
    -- Culture
    ('GOODY_CULTURE_GRANT_ONE_CIVIC', 'MODIFIER_PLAYER_GRANT_RANDOM_CIVIC', 1, 1),
    ('GOODY_CULTURE_GRANT_TWO_CIVICS', 'MODIFIER_PLAYER_GRANT_RANDOM_CIVIC', 1, 1),
    ('GOODY_CULTURE_SMALL_CHANGE', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_CHANGE', 1, 1),
    ('GOODY_CULTURE_CITIES_SMALL_MODIFIER', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER', 1, 1),
    -- Faith
    ('GOODY_FAITH_SMALL_CHANGE', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_CHANGE', 1, 1),
    ('GOODY_FAITH_CITIES_SMALL_MODIFIER', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER', 1, 1),
    -- Gold
    ('GOODY_GOLD_ADD_TRADE_ROUTE', 'MODIFIER_PLAYER_ADJUST_TRADE_ROUTE_CAPACITY', 1, 1),
    ('GOODY_GOLD_SMALL_CHANGE', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_CHANGE', 1, 1),
    ('GOODY_GOLD_CITIES_SMALL_MODIFIER', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER', 1, 1),
    -- Military
    ('GOODY_MILITARY_GRANT_SCOUT', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_IN_NEAREST_CITY', 1, 1),
    ('GOODY_MILITARY_GRANT_WARRIOR', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_IN_NEAREST_CITY', 1, 1),
    ('GOODY_MILITARY_GRANT_SLINGER', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_IN_NEAREST_CITY', 1, 1),
    ('GOODY_MILITARY_GRANT_HORSEMAN', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_IN_NEAREST_CITY', 1, 1),
    ('GOODY_MILITARY_GRANT_MILITARY_ENGINEER', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_IN_NEAREST_CITY', 1, 1),
    ('GOODY_MILITARY_GRANT_MEDIC', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_IN_NEAREST_CITY', 1, 1),
    ('GOODY_MILITARY_GRANT_SPEARMAN', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_IN_NEAREST_CITY', 1, 1),
    ('GOODY_MILITARY_GRANT_HEAVY_CHARIOT', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_IN_NEAREST_CITY', 1, 1),
    ('GOODY_PRODUCTION_SMALL_CHANGE', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_CHANGE', 1, 1),
    ('GOODY_PRODUCTION_CITIES_SMALL_MODIFIER', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER', 1, 1),
    -- Science
    ('GOODY_SCIENCE_GRANT_TWO_TECHS', 'MODIFIER_PLAYER_GRANT_RANDOM_TECHNOLOGY', 1, 1),
    ('GOODY_SCIENCE_SMALL_CHANGE', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_CHANGE', 1, 1),
    ('GOODY_SCIENCE_CITIES_SMALL_MODIFIER', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER', 1, 1),
    -- Survivors
    ('GOODY_FOOD_SMALL_CHANGE', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_CHANGE', 1, 1),
    ('GOODY_FOOD_CITIES_SMALL_MODIFIER', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER', 1, 1),
    -- Hostiles
    ('GOODY_SPAWN_HOSTILES', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_CHANGE', 1, 1);

-- New Goody Hut rewards : ModifierArguments
REPLACE INTO ModifierArguments (ModifierId, Name, Value, Extra)
VALUES
    -- Culture : one free civic
    ('GOODY_CULTURE_GRANT_ONE_CIVIC', 'Amount', 1, -1),
    -- Culture : two free civics
    ('GOODY_CULTURE_GRANT_TWO_CIVICS', 'Amount', 2, -1),
    -- Culture : small boost per turn in all cities
    ('GOODY_CULTURE_SMALL_CHANGE', 'Amount', 2, NULL),
    ('GOODY_CULTURE_SMALL_CHANGE', 'YieldType', 'YIELD_CULTURE', NULL),
    ('GOODY_CULTURE_SMALL_CHANGE', 'Scale', 'false', NULL),
    -- Culture : small modifier per turn in all cities
    ('GOODY_CULTURE_CITIES_SMALL_MODIFIER', 'Amount', 10, NULL),
    ('GOODY_CULTURE_CITIES_SMALL_MODIFIER', 'YieldType', 'YIELD_CULTURE', NULL),
    ('GOODY_CULTURE_CITIES_SMALL_MODIFIER', 'Scale', 'false', NULL),
    -- Faith : small boost per turn in all cities
    ('GOODY_FAITH_SMALL_CHANGE', 'Amount', 2, NULL),
    ('GOODY_FAITH_SMALL_CHANGE', 'YieldType', 'YIELD_FAITH', NULL),
    ('GOODY_FAITH_SMALL_CHANGE', 'Scale', 'false', NULL),
    -- Faith : small modifier per turn in all cities
    ('GOODY_FAITH_CITIES_SMALL_MODIFIER', 'Amount', 10, NULL),
    ('GOODY_FAITH_CITIES_SMALL_MODIFIER', 'YieldType', 'YIELD_FAITH', NULL),
    ('GOODY_FAITH_CITIES_SMALL_MODIFIER', 'Scale', 'false', NULL),
    -- Gold : add trade route
    ('GOODY_GOLD_ADD_TRADE_ROUTE', 'Amount', 1, NULL),
    -- Gold : small boost per turn in all cities
    ('GOODY_GOLD_SMALL_CHANGE', 'Amount', 4, NULL),
    ('GOODY_GOLD_SMALL_CHANGE', 'YieldType', 'YIELD_GOLD', NULL),
    ('GOODY_GOLD_SMALL_CHANGE', 'Scale', 'false', NULL),
    -- Gold : small modifier per turn in all cities
    ('GOODY_GOLD_CITIES_SMALL_MODIFIER', 'Amount', 10, NULL),
    ('GOODY_GOLD_CITIES_SMALL_MODIFIER', 'YieldType', 'YIELD_GOLD', NULL),
    ('GOODY_GOLD_CITIES_SMALL_MODIFIER', 'Scale', 'false', NULL),
    -- Military : grant scout
    ('GOODY_MILITARY_GRANT_SCOUT', 'UnitType', 'UNIT_SCOUT', NULL),
    ('GOODY_MILITARY_GRANT_SCOUT', 'Amount', 1, NULL),
    -- Military : grant warrior
    ('GOODY_MILITARY_GRANT_WARRIOR', 'UnitType', 'UNIT_WARRIOR', NULL),
    ('GOODY_MILITARY_GRANT_WARRIOR', 'Amount', 1, NULL),
    -- Military : grant slinger
    ('GOODY_MILITARY_GRANT_SLINGER', 'UnitType', 'UNIT_SLINGER', NULL),
    ('GOODY_MILITARY_GRANT_SLINGER', 'Amount', 1, NULL),
    -- Military : grant horseman
    ('GOODY_MILITARY_GRANT_HORSEMAN', 'UnitType', 'UNIT_HORSEMAN', NULL),
    ('GOODY_MILITARY_GRANT_HORSEMAN', 'Amount', 1, NULL),
    -- Military : grant military engineer
    ('GOODY_MILITARY_GRANT_MILITARY_ENGINEER', 'UnitType', 'UNIT_MILITARY_ENGINEER', NULL),
    ('GOODY_MILITARY_GRANT_MILITARY_ENGINEER', 'Amount', 1, NULL),
    -- Military : grant medic
    ('GOODY_MILITARY_GRANT_MEDIC', 'UnitType', 'UNIT_MEDIC', NULL),
    ('GOODY_MILITARY_GRANT_MEDIC', 'Amount', 1, NULL),
    -- Military : grant spearman
    ('GOODY_MILITARY_GRANT_SPEARMAN', 'UnitType', 'UNIT_SPEARMAN', NULL),
    ('GOODY_MILITARY_GRANT_SPEARMAN', 'Amount', 1, NULL),
    -- Military : grant heavy chariot
    ('GOODY_MILITARY_GRANT_HEAVY_CHARIOT', 'UnitType', 'UNIT_HEAVY_CHARIOT', NULL),
    ('GOODY_MILITARY_GRANT_HEAVY_CHARIOT', 'Amount', 1, NULL),
    -- Military : small boost to all production per turn in all cities
    ('GOODY_PRODUCTION_SMALL_CHANGE', 'Amount', 2, NULL),
    ('GOODY_PRODUCTION_SMALL_CHANGE', 'YieldType', 'YIELD_PRODUCTION', NULL),
    ('GOODY_PRODUCTION_SMALL_CHANGE', 'Scale', 'false', NULL),
    -- Military : small modifier to all production per turn in all cities
    ('GOODY_PRODUCTION_CITIES_SMALL_MODIFIER', 'Amount', 10, NULL),
    ('GOODY_PRODUCTION_CITIES_SMALL_MODIFIER', 'YieldType', 'YIELD_PRODUCTION', NULL),
    ('GOODY_PRODUCTION_CITIES_SMALL_MODIFIER', 'Scale', 'false', NULL),
    -- Science : two free techs
    ('GOODY_SCIENCE_GRANT_TWO_TECHS', 'Amount', 2, -1),
    -- Science : small boost per turn in all cities
    ('GOODY_SCIENCE_SMALL_CHANGE', 'Amount', 2, NULL),
    ('GOODY_SCIENCE_SMALL_CHANGE', 'YieldType', 'YIELD_SCIENCE', NULL),
    ('GOODY_SCIENCE_SMALL_CHANGE', 'Scale', 'false', NULL),
    -- Science : small modifier per turn in all cities
    ('GOODY_SCIENCE_CITIES_SMALL_MODIFIER', 'Amount', 10, NULL),
    ('GOODY_SCIENCE_CITIES_SMALL_MODIFIER', 'YieldType', 'YIELD_SCIENCE', NULL),
    ('GOODY_SCIENCE_CITIES_SMALL_MODIFIER', 'Scale', 'false', NULL),
    -- Survivors : small boost to food per turn in all cities
    ('GOODY_FOOD_SMALL_CHANGE', 'Amount', 2, NULL),
    ('GOODY_FOOD_SMALL_CHANGE', 'YieldType', 'YIELD_FOOD', NULL),
    ('GOODY_FOOD_SMALL_CHANGE', 'Scale', 'false', NULL),
    -- Survivors : small modifier to food per turn in all cities
    ('GOODY_FOOD_CITIES_SMALL_MODIFIER', 'Amount', 10, NULL),
    ('GOODY_FOOD_CITIES_SMALL_MODIFIER', 'YieldType', 'YIELD_FOOD', NULL),
    ('GOODY_FOOD_CITIES_SMALL_MODIFIER', 'Scale', 'false', NULL),
    -- Hostiles : spawn hostile villagers (this is a dummy modifier; it shouldn't actually do anything)
    ('GOODY_SPAWN_HOSTILES', 'Amount', 0, NULL),
    ('GOODY_SPAWN_HOSTILES', 'YieldType', 'YIELD_FOOD', NULL),
    ('GOODY_SPAWN_HOSTILES', 'Scale', 'false', NULL);

-- Normalize Goody Hut type and subtype weights here
-- Start by getting the overall weight of type GOODYHUT_MILITARY
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_MILITARY') WHERE GoodyHutType = 'GOODYHUT_MILITARY';

-- 2021/05/04 With EGHV, GOODYHUT_MILITARY has either 2x or (2x - 1) as many subtypes as any other type, and its default weight should be 2x that of any other type
-- There's likely a smarter way to do this, but for now, we're just going to increase other subtype weights by a factor of 2
UPDATE GoodyHutSubTypes SET Weight = Weight * 2 WHERE GoodyHut = 'GOODYHUT_CULTURE';
UPDATE GoodyHutSubTypes SET Weight = Weight * 2 WHERE GoodyHut = 'GOODYHUT_GOLD';
UPDATE GoodyHutSubTypes SET Weight = Weight * 2 WHERE GoodyHut = 'GOODYHUT_FAITH';
UPDATE GoodyHutSubTypes SET Weight = Weight * 2 WHERE GoodyHut = 'GOODYHUT_SCIENCE';
UPDATE GoodyHutSubTypes SET Weight = Weight * 2 WHERE GoodyHut = 'GOODYHUT_SURVIVORS';

-- Next, reset the remaining type weights based on the updated sums of the subtypes of each type
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_CULTURE') WHERE GoodyHutType = 'GOODYHUT_CULTURE';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_GOLD') WHERE GoodyHutType = 'GOODYHUT_GOLD';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_FAITH') WHERE GoodyHutType = 'GOODYHUT_FAITH';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SCIENCE') WHERE GoodyHutType = 'GOODYHUT_SCIENCE';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SURVIVORS') WHERE GoodyHutType = 'GOODYHUT_SURVIVORS';

-- Finally, set the hostile villagers "reward" type weight equal to that of GOODYHUT_MILITARY, and its subtype weight equal to same
UPDATE GoodyHuts SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_MILITARY') WHERE GoodyHutType = 'GOODYHUT_HOSTILES';
UPDATE GoodyHutSubTypes SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_HOSTILES') WHERE SubTypeGoodyHut = 'GOODYHUT_SPAWN_HOSTILE_VILLAGERS';

/* ###########################################################################
    End EGHV ingame configuration
########################################################################### */
