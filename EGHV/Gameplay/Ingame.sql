/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    Begin EGHV ingame configuration
########################################################################### */

-- new Types
REPLACE INTO Types
    (Type, Kind)
VALUES
    -- enhanced healing unit ability
    ('ABILITY_IMPROVED_HEALING', 'KIND_ABILITY'),
    -- enhanced movement unit ability
    ('ABILITY_IMPROVED_MOVEMENT', 'KIND_ABILITY'),
    -- enhanced sight unit ability
    ('ABILITY_IMPROVED_SIGHT', 'KIND_ABILITY'),
    -- enhanced combat strength unit ability
    ('ABILITY_IMPROVED_STRENGTH', 'KIND_ABILITY'),
    -- internal placeholder for the Villager Totem building prior to player unlock
    ('BUILDING_INTERNAL_TRIBAL_TOTEM', 'KIND_BUILDING'),
    -- level 0 Villager Totem building (initial unlock; +2 amenities)
    ('BUILDING_TRIBAL_TOTEM_LVL0', 'KIND_BUILDING'),
    -- level 1 Villager Totem building (+2 gold, +1 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL1', 'KIND_BUILDING'),
    -- level 2 Villager Totem building (+4 gold, +2 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL2', 'KIND_BUILDING'),
    -- level 3 Villager Totem building (+6 gold, +3 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL3', 'KIND_BUILDING'),
    -- level 4 Villager Totem building (+8 gold, +4 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL4', 'KIND_BUILDING'),
    -- level 5 Villager Totem building (+10 gold, +5 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL5', 'KIND_BUILDING'),
    -- additional unit abilities
    ('GOODYHUT_ABILITIES', 'KIND_GOODY_HUT'),
    -- free Envoys
    ('GOODYHUT_ENVOYS', 'KIND_GOODY_HUT'),
    -- fallback rewards *** these help prevent infinite loops and crashes related to EGHV; they should not be enabled or normally accessible ***
    ('GOODYHUT_FALLBACK', 'KIND_GOODY_HUT'),
    -- Hostile Villagers "rewards"
    ('GOODYHUT_HOSTILES', 'KIND_GOODY_HUT'),
    -- unit experience and promotions
    ('GOODYHUT_PROMOTIONS', 'KIND_GOODY_HUT'),
    -- Villager Secrets reward
    ('GOODYHUT_SECRETS', 'KIND_GOODY_HUT');

-- new Buildings
REPLACE INTO Buildings
    (BuildingType, Name, Description, PrereqDistrict, PrereqTech, PurchaseYield, Cost, Entertainment, Maintenance, InternalOnly, AdvisorType)
VALUES
    -- internal placeholder for the Villager Totem building prior to player unlock
    ('BUILDING_INTERNAL_TRIBAL_TOTEM', 'LOC_BUILDING_INTERNAL_TRIBAL_TOTEM_NAME', NULL, NULL, NULL, 'YIELD_GOLD', 1000, 0, 0, 1, NULL),
    -- level 0 Villager Totem building (initial unlock; +2 amenities)
    ('BUILDING_TRIBAL_TOTEM_LVL0', 'LOC_BUILDING_TRIBAL_TOTEM_NAME', 'LOC_BUILDING_TRIBAL_TOTEM_DESC', 'DISTRICT_CITY_CENTER', NULL, 'YIELD_GOLD', 75, 1, 1, 0, 'ADVISOR_GENERIC'),
    -- level 1 Villager Totem building (+2 gold, +1 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL1', 'LOC_BUILDING_TRIBAL_TOTEM_NAME', 'LOC_BUILDING_TRIBAL_TOTEM_DESC', 'DISTRICT_CITY_CENTER', NULL, 'YIELD_GOLD', 80, 1, 1, 0, 'ADVISOR_GENERIC'),
    -- level 2 Villager Totem building (+4 gold, +2 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL2', 'LOC_BUILDING_TRIBAL_TOTEM_NAME', 'LOC_BUILDING_TRIBAL_TOTEM_DESC', 'DISTRICT_CITY_CENTER', NULL, 'YIELD_GOLD', 85, 1, 1, 0, 'ADVISOR_GENERIC'),
    -- level 3 Villager Totem building (+6 gold, +3 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL3', 'LOC_BUILDING_TRIBAL_TOTEM_NAME', 'LOC_BUILDING_TRIBAL_TOTEM_DESC', 'DISTRICT_CITY_CENTER', NULL, 'YIELD_GOLD', 90, 1, 1, 0, 'ADVISOR_GENERIC'),
    -- level 4 Villager Totem building (+8 gold, +4 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL4', 'LOC_BUILDING_TRIBAL_TOTEM_NAME', 'LOC_BUILDING_TRIBAL_TOTEM_DESC', 'DISTRICT_CITY_CENTER', NULL, 'YIELD_GOLD', 95, 1, 1, 0, 'ADVISOR_GENERIC'),
    -- level 5 Villager Totem building (+10 gold, +5 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL5', 'LOC_BUILDING_TRIBAL_TOTEM_NAME', 'LOC_BUILDING_TRIBAL_TOTEM_DESC', 'DISTRICT_CITY_CENTER', NULL, 'YIELD_GOLD', 100, 1, 1, 0, 'ADVISOR_GENERIC');

-- new BuildingConditions
REPLACE INTO BuildingConditions
    (BuildingType, UnlocksFromEffect)
VALUES
    -- level 0 Villager Totem building (initial unlock; +2 amenities)
    ('BUILDING_TRIBAL_TOTEM_LVL0', 1),
    -- level 1 Villager Totem building (+2 gold, +1 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL1', 1),
    -- level 2 Villager Totem building (+4 gold, +2 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL2', 1),
    -- level 3 Villager Totem building (+6 gold, +3 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL3', 1),
    -- level 4 Villager Totem building (+8 gold, +4 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL4', 1),
    -- level 5 Villager Totem building (+10 gold, +5 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL5', 1);

-- new BuildingReplaces
REPLACE INTO BuildingReplaces
    (CivUniqueBuildingType, ReplacesBuildingType)
VALUES
    -- level 0 Villager Totem building (initial unlock; +2 amenities)
    ('BUILDING_TRIBAL_TOTEM_LVL0', 'BUILDING_INTERNAL_TRIBAL_TOTEM'),
    -- level 1 Villager Totem building (+2 gold, +1 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL1', 'BUILDING_TRIBAL_TOTEM_LVL0'),
    -- level 2 Villager Totem building (+4 gold, +2 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL2', 'BUILDING_TRIBAL_TOTEM_LVL1'),
    -- level 3 Villager Totem building (+6 gold, +3 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL3', 'BUILDING_TRIBAL_TOTEM_LVL2'),
    -- level 4 Villager Totem building (+8 gold, +4 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL4', 'BUILDING_TRIBAL_TOTEM_LVL3'),
    -- level 5 Villager Totem building (+10 gold, +5 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL5', 'BUILDING_TRIBAL_TOTEM_LVL4');

-- new Building_YieldChanges
REPLACE INTO Building_YieldChanges
    (BuildingType, YieldType, YieldChange)
VALUES
    -- level 1 Villager Totem building (+2 gold, +1 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL1', 'YIELD_CULTURE', 1),
    ('BUILDING_TRIBAL_TOTEM_LVL1', 'YIELD_FAITH', 1),
    ('BUILDING_TRIBAL_TOTEM_LVL1', 'YIELD_FOOD', 1),
    ('BUILDING_TRIBAL_TOTEM_LVL1', 'YIELD_GOLD', 2),
    ('BUILDING_TRIBAL_TOTEM_LVL1', 'YIELD_PRODUCTION', 1),
    ('BUILDING_TRIBAL_TOTEM_LVL1', 'YIELD_SCIENCE', 1),
    -- level 2 Villager Totem building (+4 gold, +2 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL2', 'YIELD_CULTURE', 2),
    ('BUILDING_TRIBAL_TOTEM_LVL2', 'YIELD_FAITH', 2),
    ('BUILDING_TRIBAL_TOTEM_LVL2', 'YIELD_FOOD', 2),
    ('BUILDING_TRIBAL_TOTEM_LVL2', 'YIELD_GOLD', 4),
    ('BUILDING_TRIBAL_TOTEM_LVL2', 'YIELD_PRODUCTION', 2),
    ('BUILDING_TRIBAL_TOTEM_LVL2', 'YIELD_SCIENCE', 2),
    -- level 3 Villager Totem building (+6 gold, +3 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL3', 'YIELD_CULTURE', 3),
    ('BUILDING_TRIBAL_TOTEM_LVL3', 'YIELD_FAITH', 3),
    ('BUILDING_TRIBAL_TOTEM_LVL3', 'YIELD_FOOD', 3),
    ('BUILDING_TRIBAL_TOTEM_LVL3', 'YIELD_GOLD', 6),
    ('BUILDING_TRIBAL_TOTEM_LVL3', 'YIELD_PRODUCTION', 3),
    ('BUILDING_TRIBAL_TOTEM_LVL3', 'YIELD_SCIENCE', 3),
    -- level 4 Villager Totem building (+8 gold, +4 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL4', 'YIELD_CULTURE', 4),
    ('BUILDING_TRIBAL_TOTEM_LVL4', 'YIELD_FAITH', 4),
    ('BUILDING_TRIBAL_TOTEM_LVL4', 'YIELD_FOOD', 4),
    ('BUILDING_TRIBAL_TOTEM_LVL4', 'YIELD_GOLD', 8),
    ('BUILDING_TRIBAL_TOTEM_LVL4', 'YIELD_PRODUCTION', 4),
    ('BUILDING_TRIBAL_TOTEM_LVL4', 'YIELD_SCIENCE', 4),
    -- level 5 Villager Totem building (+10 gold, +5 all other yields)
    ('BUILDING_TRIBAL_TOTEM_LVL5', 'YIELD_CULTURE', 5),
    ('BUILDING_TRIBAL_TOTEM_LVL5', 'YIELD_FAITH', 5),
    ('BUILDING_TRIBAL_TOTEM_LVL5', 'YIELD_FOOD', 5),
    ('BUILDING_TRIBAL_TOTEM_LVL5', 'YIELD_GOLD', 10),
    ('BUILDING_TRIBAL_TOTEM_LVL5', 'YIELD_PRODUCTION', 5),
    ('BUILDING_TRIBAL_TOTEM_LVL5', 'YIELD_SCIENCE', 5);

-- new UnitAbilities
REPLACE INTO UnitAbilities
    (UnitAbilityType, Name, Description, Inactive, ShowFloatTextWhenEarned)
VALUES
    -- enhanced healing
    ('ABILITY_IMPROVED_HEALING', 'LOC_ABILITY_IMPROVED_HEALING_NAME', 'LOC_ABILITY_IMPROVED_HEALING_DESC', 1, 1),
    -- enhanced movement
    ('ABILITY_IMPROVED_MOVEMENT', 'LOC_ABILITY_IMPROVED_MOVEMENT_NAME', 'LOC_ABILITY_IMPROVED_MOVEMENT_DESC', 1, 1),
    -- enhanced sight
    ('ABILITY_IMPROVED_SIGHT', 'LOC_ABILITY_IMPROVED_SIGHT_NAME', 'LOC_ABILITY_IMPROVED_SIGHT_DESC', 1, 1),
    -- enhanced combat strength
    ('ABILITY_IMPROVED_STRENGTH', 'LOC_ABILITY_IMPROVED_STRENGTH_NAME', 'LOC_ABILITY_IMPROVED_STRENGTH_DESC', 1, 1);

-- new TypeTags
REPLACE INTO TypeTags
    (Type, Tag)
VALUES
    -- enhanced healing
    ('ABILITY_IMPROVED_HEALING', 'CLASS_RECON'),
    ('ABILITY_IMPROVED_HEALING', 'CLASS_MELEE'),
    ('ABILITY_IMPROVED_HEALING', 'CLASS_RANGED'),
    ('ABILITY_IMPROVED_HEALING', 'CLASS_SIEGE'),
    ('ABILITY_IMPROVED_HEALING', 'CLASS_HEAVY_CAVALRY'),
    ('ABILITY_IMPROVED_HEALING', 'CLASS_LIGHT_CAVALRY'),
    ('ABILITY_IMPROVED_HEALING', 'CLASS_ANTI_CAVALRY'),
    ('ABILITY_IMPROVED_HEALING', 'CLASS_RANGED_CAVALRY'),
    ('ABILITY_IMPROVED_HEALING', 'CLASS_HEAVY_CHARIOT'),
    ('ABILITY_IMPROVED_HEALING', 'CLASS_LIGHT_CHARIOT'),
    ('ABILITY_IMPROVED_HEALING', 'CLASS_WARRIOR_MONK'),
    -- enhanced movement
    ('ABILITY_IMPROVED_MOVEMENT', 'CLASS_ALL_UNITS'),
    -- enhanced sight
    ('ABILITY_IMPROVED_SIGHT', 'CLASS_ALL_UNITS'),
    -- enhanced combat strength
    ('ABILITY_IMPROVED_STRENGTH', 'CLASS_RECON'),
    ('ABILITY_IMPROVED_STRENGTH', 'CLASS_MELEE'),
    ('ABILITY_IMPROVED_STRENGTH', 'CLASS_RANGED'),
    ('ABILITY_IMPROVED_STRENGTH', 'CLASS_SIEGE'),
    ('ABILITY_IMPROVED_STRENGTH', 'CLASS_HEAVY_CAVALRY'),
    ('ABILITY_IMPROVED_STRENGTH', 'CLASS_LIGHT_CAVALRY'),
    ('ABILITY_IMPROVED_STRENGTH', 'CLASS_ANTI_CAVALRY'),
    ('ABILITY_IMPROVED_STRENGTH', 'CLASS_RANGED_CAVALRY'),
    ('ABILITY_IMPROVED_STRENGTH', 'CLASS_HEAVY_CHARIOT'),
    ('ABILITY_IMPROVED_STRENGTH', 'CLASS_LIGHT_CHARIOT'),
    ('ABILITY_IMPROVED_STRENGTH', 'CLASS_WARRIOR_MONK');

-- new UnitAbilityModifiers
REPLACE INTO UnitAbilityModifiers
    (UnitAbilityType, ModifierId)
VALUES
    -- enhanced healing
    ('ABILITY_IMPROVED_HEALING', 'GOODY_ABILITIES_IMPROVED_HEALING'),
    -- enhanced movement
    ('ABILITY_IMPROVED_MOVEMENT', 'GOODY_ABILITIES_IMPROVED_MOVEMENT'),
    -- enhanced sight
    ('ABILITY_IMPROVED_SIGHT', 'GOODY_ABILITIES_IMPROVED_SIGHT'),
    -- enhanced combat strength
    ('ABILITY_IMPROVED_STRENGTH', 'GOODY_ABILITIES_IMPROVED_STRENGTH');

-- new ModifierStrings
REPLACE INTO ModifierStrings
    (ModifierId, Context, Text)
VALUES
    -- enhanced healing
    ('GOODY_ABILITIES_IMPROVED_HEALING', 'Preview', '{LOC_ABILITY_IMPROVED_HEALING_DESC} {LOC_WONDER_DESCRIPTOR_PREVIEW_TEXT}'),
    -- enhanced movement
    ('GOODY_ABILITIES_IMPROVED_MOVEMENT', 'Preview', '{LOC_ABILITY_IMPROVED_MOVEMENT_DESC} {LOC_WONDER_DESCRIPTOR_PREVIEW_TEXT}'),
    -- enhanced sight
    ('GOODY_ABILITIES_IMPROVED_SIGHT', 'Preview', '{LOC_ABILITY_IMPROVED_SIGHT_DESC} {LOC_WONDER_DESCRIPTOR_PREVIEW_TEXT}'),
    -- enhanced combat strength
    ('GOODY_ABILITIES_IMPROVED_STRENGTH', 'Preview', '{LOC_ABILITY_IMPROVED_STRENGTH_DESC} {LOC_WONDER_DESCRIPTOR_PREVIEW_TEXT}');

-- new GoodyHuts; Weight values provided here may be subject to change
REPLACE INTO GoodyHuts
    (GoodyHutType, Weight)
VALUES
    -- additional unit abilities
    ('GOODYHUT_ABILITIES', 100),
    -- free Envoys
    ('GOODYHUT_ENVOYS', 100),
    -- fallback rewards *** these help prevent infinite loops and crashes related to EGHV; they should not be enabled or normally accessible ***
    ('GOODYHUT_FALLBACK', 0),
    -- Hostile Villagers "rewards"
    ('GOODYHUT_HOSTILES', 100),
    -- unit experience and promotions
    ('GOODYHUT_PROMOTIONS', 100),
    -- Villager Secrets reward
    ('GOODYHUT_SECRETS', 100);

-- modify the cap on experience gained from killing barbarians; default : Value = 1
UPDATE GlobalParameters SET Value = 3 WHERE Name = 'EXPERIENCE_BARB_SOFT_CAP';

-- modify the maximum level attainable by killing barbarians (units begin at Level 1); default : Value = 2
UPDATE GlobalParameters SET Value = 5 WHERE Name = 'EXPERIENCE_MAX_BARB_LEVEL';

-- modify the amount of experience gained from clearing a goody hut; default : Value = 10 (Pre XP2) | 8 (XP2 and beyond) [maybe now a hard 5 by default? fuck it]
UPDATE GlobalParameters SET Value = 3 WHERE Name = 'EXPERIENCE_ACTIVATE_GOODY_HUT';

-- adjust the frequency of, minimum distance between, and gold earned for clearing Goody Huts; defaults : TilesPerGoody = 128, GoodyRange = 3, DispersalGold = ?
UPDATE Improvements SET TilesPerGoody = 128, GoodyRange = 3, DispersalGold = 0 WHERE ImprovementType = 'IMPROVEMENT_GOODY_HUT';

-- adjust existing Culture-type "one Civic boost" reward
UPDATE GoodyHutSubTypes SET Weight = 40, Turn = 0, Description = 'LOC_GOODYHUT_CULTURE_ONE_CIVIC_BOOST_DESCRIPTION' WHERE SubTypeGoodyHut = 'GOODYHUT_ONE_CIVIC_BOOST';
-- adjust existing Culture-type "two Civic boosts" reward
UPDATE GoodyHutSubTypes SET Weight = 30, Turn = 0, Description = 'LOC_GOODYHUT_CULTURE_TWO_CIVIC_BOOSTS_DESCRIPTION' WHERE SubTypeGoodyHut = 'GOODYHUT_TWO_CIVIC_BOOSTS';

-- adjust existing Faith-type "small Faith cache" reward
UPDATE GoodyHutSubTypes SET Weight = 40, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_SMALL_FAITH';               -- defaults : Weight = 55, Turn = 20
UPDATE ModifierArguments SET Value = 20 WHERE ModifierId = 'GOODY_FAITH_SMALL_MODIFIER' AND Name = 'Amount';    -- defaults : Value = 20
-- adjust existing Faith-type "medium Faith cache" reward
UPDATE GoodyHutSubTypes SET Weight = 30, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_MEDIUM_FAITH';              -- defaults : Weight = 30, Turn = 40
UPDATE ModifierArguments SET Value = 60 WHERE ModifierId = 'GOODY_FAITH_MEDIUM_MODIFIER' AND Name = 'Amount';   -- defaults : Value = 60
-- adjust existing Faith-type "large Faith cache" reward
UPDATE GoodyHutSubTypes SET Weight = 20, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_LARGE_FAITH';               -- defaults : Weight = 15, Turn = 60
UPDATE ModifierArguments SET Value = 100 WHERE ModifierId = 'GOODY_FAITH_LARGE_MODIFIER' AND Name = 'Amount';   -- defaults : Value = 100

-- make "one relic" a Faith-type reward (was Culture-type); adjust its weight value and other properties
UPDATE GoodyHutSubTypes SET GoodyHut = 'GOODYHUT_FAITH', Weight = 10, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_ONE_RELIC';              -- defaults : Weight = 15

-- adjust existing Gold-type "small Gold cache" reward
UPDATE GoodyHutSubTypes SET Weight = 40, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_SMALL_GOLD';                -- defaults : Weight = 55
UPDATE ModifierArguments SET Value = 40 WHERE ModifierId = 'GOODY_GOLD_SMALL_MODIFIER' AND Name = 'Amount';     -- defaults : Value = 40
-- adjust existing Gold-type "medium Gold cache" reward
UPDATE GoodyHutSubTypes SET Weight = 30, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_MEDIUM_GOLD';               -- defaults : Weight = 30, Turn = 20
UPDATE ModifierArguments SET Value = 80 WHERE ModifierId = 'GOODY_GOLD_MEDIUM_MODIFIER' AND Name = 'Amount';    -- defaults : Value = 75
-- adjust existing Gold-type "large Gold cache" reward
UPDATE GoodyHutSubTypes SET Weight = 20, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_LARGE_GOLD';                -- defaults : Weight = 15, Turn = 40
UPDATE ModifierArguments SET Value = 120 WHERE ModifierId = 'GOODY_GOLD_LARGE_MODIFIER' AND Name = 'Amount';    -- defaults : Value = 120

-- disable existing Military-type "grant experience" reward
UPDATE GoodyHutSubTypes SET Weight = 0, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_GRANT_EXPERIENCE';
-- disable existing Military-type "heal unit" reward
UPDATE GoodyHutSubTypes SET Weight = 0, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_HEAL';
-- enable "upgrade unit" reward and make it a custom Promotions-type reward
UPDATE GoodyHutSubTypes SET GoodyHut = 'GOODYHUT_PROMOTIONS', Weight = 10, Turn = 0, UpgradeUnit = 0, ModifierID = 'GOODY_EGHV_DUMMY_REWARD' WHERE SubTypeGoodyHut = 'GOODYHUT_GRANT_UPGRADE';
-- adjust existing Military-type "grant scout" reward; this reward now grants an Era-appropriate recon unit
UPDATE GoodyHutSubTypes SET Weight = 34, Turn = 0, ModifierID = 'GOODY_EGHV_DUMMY_REWARD' WHERE SubTypeGoodyHut = 'GOODYHUT_GRANT_SCOUT';

-- existing Science-type rewards
UPDATE GoodyHutSubTypes SET Weight = 40, Turn = 0, Description = 'LOC_GOODYHUT_SCIENCE_ONE_TECH_BOOST_DESCRIPTION' WHERE SubTypeGoodyHut = 'GOODYHUT_ONE_TECH_BOOST';
UPDATE GoodyHutSubTypes SET Weight = 30, Turn = 0, Description = 'LOC_GOODYHUT_SCIENCE_TWO_TECH_BOOSTS_DESCRIPTION' WHERE SubTypeGoodyHut = 'GOODYHUT_TWO_TECH_BOOSTS';
UPDATE GoodyHutSubTypes SET Weight = 20, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_ONE_TECH';

-- existing Survivor-type rewards
UPDATE GoodyHutSubTypes SET Weight = 40, Turn = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_ADD_POP';
UPDATE GoodyHutSubTypes SET Weight = 30, Turn = 0, Description = 'LOC_GOODYHUT_SURVIVORS_GRANT_BUILDER_DESCRIPTION', ModifierID = 'GOODY_EGHV_DUMMY_REWARD' WHERE SubTypeGoodyHut = 'GOODYHUT_GRANT_BUILDER';
UPDATE GoodyHutSubTypes SET Weight = 20, Turn = 0, Trader = 0, Description = 'LOC_GOODYHUT_SURVIVORS_GRANT_TRADER_DESCRIPTION', ModifierID = 'GOODY_EGHV_DUMMY_REWARD' WHERE SubTypeGoodyHut = 'GOODYHUT_GRANT_TRADER';
UPDATE GoodyHutSubTypes SET Weight = 10, Turn = 0, Description = 'LOC_GOODYHUT_SURVIVORS_GRANT_SETTLER_DESCRIPTION', ModifierID = 'GOODY_EGHV_DUMMY_REWARD' WHERE SubTypeGoodyHut = 'GOODYHUT_GRANT_SETTLER';

-- new GoodyHutSubTypes
REPLACE INTO GoodyHutSubTypes
    (GoodyHut, SubTypeGoodyHut, Description, Weight, Turn, MinOneCity, RequiresUnit, ModifierID)
VALUES
    -- Culture
    ('GOODYHUT_CULTURE', 'GOODYHUT_ONE_CIVIC', 'LOC_GOODYHUT_CULTURE_ONE_CIVIC_DESCRIPTION', 20, 0, 1, 1, 'GOODY_CULTURE_GRANT_ONE_CIVIC'),
    ('GOODYHUT_CULTURE', 'GOODYHUT_TWO_CIVICS', 'LOC_GOODYHUT_CULTURE_TWO_CIVICS_DESCRIPTION', 10, 0, 1, 1, 'GOODY_CULTURE_GRANT_TWO_CIVICS'),
    -- Gold
    ('GOODYHUT_GOLD', 'GOODYHUT_ADD_TRADE_ROUTE', 'LOC_GOODYHUT_ADD_TRADE_ROUTE_DESCRIPTION', 10, 0, 1, 1, 'GOODY_GOLD_ADD_TRADE_ROUTE'),
    -- Military
    ('GOODYHUT_MILITARY', 'GOODYHUT_GRANT_WARRIOR', 'LOC_GOODYHUT_MILITARY_GRANT_MELEE_UNIT_DESCRIPTION', 12, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    ('GOODYHUT_MILITARY', 'GOODYHUT_GRANT_SLINGER', 'LOC_GOODYHUT_MILITARY_GRANT_RANGED_UNIT_DESCRIPTION', 12, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    ('GOODYHUT_MILITARY', 'GOODYHUT_GRANT_SPEARMAN', 'LOC_GOODYHUT_MILITARY_GRANT_ANTI_CAVALRY_UNIT_DESCRIPTION', 12, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    ('GOODYHUT_MILITARY', 'GOODYHUT_GRANT_HEAVY_CHARIOT', 'LOC_GOODYHUT_MILITARY_GRANT_HEAVY_CAVALRY_UNIT_DESCRIPTION', 9, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    ('GOODYHUT_MILITARY', 'GOODYHUT_GRANT_HORSEMAN', 'LOC_GOODYHUT_MILITARY_GRANT_LIGHT_CAVALRY_UNIT_DESCRIPTION', 9, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    ('GOODYHUT_MILITARY', 'GOODYHUT_GRANT_BATTERING_RAM', 'LOC_GOODYHUT_MILITARY_GRANT_BATTERING_RAM_DESCRIPTION', 5, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    ('GOODYHUT_MILITARY', 'GOODYHUT_GRANT_CATAPULT', 'LOC_GOODYHUT_MILITARY_GRANT_CATAPULT_DESCRIPTION', 5, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    ('GOODYHUT_MILITARY', 'GOODYHUT_GRANT_MILITARY_ENGINEER', 'LOC_GOODYHUT_MILITARY_GRANT_MILITARY_ENGINEER_DESCRIPTION', 2, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    -- Science
    ('GOODYHUT_SCIENCE', 'GOODYHUT_TWO_TECHS', 'LOC_GOODYHUT_SCIENCE_TWO_TECHS_DESCRIPTION', 10, 0, 1, 1, 'GOODY_SCIENCE_GRANT_TWO_TECHS'),
    -- Abilities
    ('GOODYHUT_ABILITIES', 'GOODYHUT_IMPROVED_SIGHT', 'LOC_GOODYHUT_IMPROVED_SIGHT_DESCRIPTION', 40, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    ('GOODYHUT_ABILITIES', 'GOODYHUT_IMPROVED_HEALING', 'LOC_GOODYHUT_IMPROVED_HEALING_DESCRIPTION', 30, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    ('GOODYHUT_ABILITIES', 'GOODYHUT_IMPROVED_MOVEMENT', 'LOC_GOODYHUT_IMPROVED_MOVEMENT_DESCRIPTION', 20, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    ('GOODYHUT_ABILITIES', 'GOODYHUT_IMPROVED_STRENGTH', 'LOC_GOODYHUT_IMPROVED_STRENGTH_DESCRIPTION', 10, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    -- Envoys
    ('GOODYHUT_ENVOYS', 'GOODYHUT_ONE_ENVOY', 'LOC_GOODYHUT_ENVOYS_GRANT_ONE_DESCRIPTION', 40, 0, 1, 1, 'GOODY_ENVOYS_GRANT_ONE'),
    ('GOODYHUT_ENVOYS', 'GOODYHUT_TWO_ENVOYS', 'LOC_GOODYHUT_ENVOYS_GRANT_TWO_DESCRIPTION', 30, 0, 1, 1, 'GOODY_ENVOYS_GRANT_TWO'),
    ('GOODYHUT_ENVOYS', 'GOODYHUT_THREE_ENVOYS', 'LOC_GOODYHUT_ENVOYS_GRANT_THREE_DESCRIPTION', 20, 0, 1, 1, 'GOODY_ENVOYS_GRANT_THREE'),
    ('GOODYHUT_ENVOYS', 'GOODYHUT_FOUR_ENVOYS', 'LOC_GOODYHUT_ENVOYS_GRANT_FOUR_DESCRIPTION', 10, 0, 1, 1, 'GOODY_ENVOYS_GRANT_FOUR'),
    -- fallback rewards *** these help prevent infinite loops and crashes related to EGHV; they should not be enabled or normally accessible ***
    ('GOODYHUT_FALLBACK', 'GOODYHUT_CULTURE_FALLBACK', 'LOC_GOODYHUT_CULTURE_FALLBACK_DESCRIPTION', 0, 0, 1, 1, 'GOODY_FALLBACK_CULTURE'),
    ('GOODYHUT_FALLBACK', 'GOODYHUT_FAITH_FALLBACK', 'LOC_GOODYHUT_FAITH_FALLBACK_DESCRIPTION', 0, 0, 1, 1, 'GOODY_FALLBACK_FAITH'),
    ('GOODYHUT_FALLBACK', 'GOODYHUT_FOOD_FALLBACK', 'LOC_GOODYHUT_FOOD_FALLBACK_DESCRIPTION', 0, 0, 1, 1, 'GOODY_FALLBACK_FOOD'),
    ('GOODYHUT_FALLBACK', 'GOODYHUT_GOLD_FALLBACK', 'LOC_GOODYHUT_GOLD_FALLBACK_DESCRIPTION', 0, 0, 1, 1, 'GOODY_FALLBACK_GOLD'),
    ('GOODYHUT_FALLBACK', 'GOODYHUT_PRODUCTION_FALLBACK', 'LOC_GOODYHUT_PRODUCTION_FALLBACK_DESCRIPTION', 0, 0, 1, 1, 'GOODY_FALLBACK_PRODUCTION'),
    ('GOODYHUT_FALLBACK', 'GOODYHUT_SCIENCE_FALLBACK', 'LOC_GOODYHUT_SCIENCE_FALLBACK_DESCRIPTION', 0, 0, 1, 1, 'GOODY_FALLBACK_SCIENCE'),
    -- Hostiles
    ('GOODYHUT_HOSTILES', 'GOODYHUT_LOW_HOSTILITY_VILLAGERS', 'LOC_GOODYHUT_HOSTILE_VILLAGERS_DESCRIPTION', 40, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    ('GOODYHUT_HOSTILES', 'GOODYHUT_MID_HOSTILITY_VILLAGERS', 'LOC_GOODYHUT_HOSTILE_VILLAGERS_DESCRIPTION', 30, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HIGH_HOSTILITY_VILLAGERS', 'LOC_GOODYHUT_HOSTILE_VILLAGERS_DESCRIPTION', 20, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    ('GOODYHUT_HOSTILES', 'GOODYHUT_MAX_HOSTILITY_VILLAGERS', 'LOC_GOODYHUT_HOSTILE_VILLAGERS_DESCRIPTION', 10, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    -- Promotions
    ('GOODYHUT_PROMOTIONS', 'GOODYHUT_SMALL_EXPERIENCE', 'LOC_GOODYHUT_SMALL_EXPERIENCE_DESCRIPTION', 40, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    ('GOODYHUT_PROMOTIONS', 'GOODYHUT_MEDIUM_EXPERIENCE', 'LOC_GOODYHUT_MEDIUM_EXPERIENCE_DESCRIPTION', 30, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    ('GOODYHUT_PROMOTIONS', 'GOODYHUT_LARGE_EXPERIENCE', 'LOC_GOODYHUT_LARGE_EXPERIENCE_DESCRIPTION', 20, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    ('GOODYHUT_PROMOTIONS', 'GOODYHUT_HUGE_EXPERIENCE', 'LOC_GOODYHUT_HUGE_EXPERIENCE_DESCRIPTION', 0, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD'),
    -- Secrets
    ('GOODYHUT_SECRETS', 'GOODYHUT_UNLOCK_VILLAGER_SECRETS', 'LOC_GOODYHUT_VILLAGER_SECRETS_DESCRIPTION', 100, 0, 1, 1, 'GOODY_EGHV_DUMMY_REWARD');

-- new Modifiers
REPLACE INTO Modifiers
    (ModifierId, ModifierType, RunOnce, Permanent, SubjectRequirementSetId)
VALUES
    -- dummy modifier - for use by rewards implemented via lua
    ('GOODY_EGHV_DUMMY_REWARD', 'MODIFIER_PLAYER_ADJUST_YIELD_CHANGE', 1, 1, NULL),
    -- Culture
    ('GOODY_CULTURE_GRANT_ONE_CIVIC', 'MODIFIER_PLAYER_GRANT_RANDOM_CIVIC', 1, 1, NULL),
    ('GOODY_CULTURE_GRANT_TWO_CIVICS', 'MODIFIER_PLAYER_GRANT_RANDOM_CIVIC', 1, 1, NULL),
    -- Gold
    ('GOODY_GOLD_ADD_TRADE_ROUTE', 'MODIFIER_PLAYER_ADJUST_TRADE_ROUTE_CAPACITY', 1, 1, NULL),
    -- Military
    ('GOODY_MILITARY_GRANT_SCOUT', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_BY_CLASS_IN_NEAREST_CITY', 1, 1, NULL),
    ('GOODY_MILITARY_GRANT_WARRIOR', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_BY_CLASS_IN_NEAREST_CITY', 1, 1, NULL),
    ('GOODY_MILITARY_GRANT_SLINGER', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_BY_CLASS_IN_NEAREST_CITY', 1, 1, NULL),
    -- (Anti) Cavalry
    ('GOODY_MILITARY_GRANT_SPEARMAN', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_BY_CLASS_IN_NEAREST_CITY', 1, 1, NULL),
    ('GOODY_MILITARY_GRANT_HEAVY_CHARIOT', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_BY_CLASS_IN_NEAREST_CITY', 1, 1, NULL),
    ('GOODY_MILITARY_GRANT_HORSEMAN', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_BY_CLASS_IN_NEAREST_CITY', 1, 1, NULL),
    -- Science
    ('GOODY_SCIENCE_GRANT_TWO_TECHS', 'MODIFIER_PLAYER_GRANT_RANDOM_TECHNOLOGY', 1, 1, NULL),
    -- Abilities
    ('GOODY_ABILITIES_IMPROVED_SIGHT', 'MODIFIER_PLAYER_UNIT_ADJUST_SIGHT', 0, 0, NULL),
    ('GOODY_ABILITIES_IMPROVED_HEALING', 'MODIFIER_PLAYER_UNIT_ADJUST_HEAL_PER_TURN', 0, 0, NULL),
    ('GOODY_ABILITIES_IMPROVED_MOVEMENT', 'MODIFIER_PLAYER_UNIT_ADJUST_MOVEMENT', 0, 0, NULL),
    ('GOODY_ABILITIES_IMPROVED_STRENGTH', 'MODIFIER_UNIT_ADJUST_COMBAT_STRENGTH', 0, 0, NULL),
    -- Envoys
    ('GOODY_ENVOYS_GRANT_ONE', 'MODIFIER_PLAYER_GRANT_INFLUENCE_TOKEN', 1, 1, NULL),
    ('GOODY_ENVOYS_GRANT_TWO', 'MODIFIER_PLAYER_GRANT_INFLUENCE_TOKEN', 1, 1, NULL),
    ('GOODY_ENVOYS_GRANT_THREE', 'MODIFIER_PLAYER_GRANT_INFLUENCE_TOKEN', 1, 1, NULL),
    ('GOODY_ENVOYS_GRANT_FOUR', 'MODIFIER_PLAYER_GRANT_INFLUENCE_TOKEN', 1, 1, NULL),
    -- fallback rewards *** these help prevent infinite loops and crashes related to EGHV; they should not be enabled or normally accessible ***
    ('GOODY_FALLBACK_CULTURE', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_CHANGE', 1, 1, NULL),
    ('GOODY_FALLBACK_FAITH', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_CHANGE', 1, 1, NULL),
    ('GOODY_FALLBACK_FOOD', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_CHANGE', 1, 1, NULL),
    ('GOODY_FALLBACK_GOLD', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_CHANGE', 1, 1, NULL),
    ('GOODY_FALLBACK_PRODUCTION', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_CHANGE', 1, 1, NULL),
    ('GOODY_FALLBACK_SCIENCE', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_CHANGE', 1, 1, NULL),
    -- Hostile Villagers
    ('GOODY_SPAWN_HOSTILES', 'MODIFIER_PLAYER_UNIT_ADJUST_GRANT_EXPERIENCE', 1, 1, NULL),
    -- Promotions
    ('GOODY_EXPERIENCE_SMALL_MODIFIER', 'MODIFIER_PLAYER_UNIT_ADJUST_GRANT_EXPERIENCE', 1, 1, NULL),
    ('GOODY_EXPERIENCE_MEDIUM_MODIFIER', 'MODIFIER_PLAYER_UNIT_ADJUST_GRANT_EXPERIENCE', 1, 1, NULL),
    ('GOODY_EXPERIENCE_LARGE_MODIFIER', 'MODIFIER_PLAYER_UNIT_ADJUST_GRANT_EXPERIENCE', 1, 1, NULL),
    ('GOODY_EXPERIENCE_HUGE_MODIFIER', 'MODIFIER_PLAYER_UNIT_ADJUST_GRANT_EXPERIENCE', 1, 1, NULL),
    -- Secrets
    ('GOODY_VILLAGER_SECRETS', 'MODIFIER_PLAYER_UNIT_ADJUST_GRANT_EXPERIENCE', 1, 1, NULL),
    ('VILLAGER_SECRETS_UNLOCK_TRIBAL_TOTEM_LVL0', 'MODIFIER_PLAYER_ADJUST_VALID_BUILDING', 0, 0, NULL),
    ('VILLAGER_SECRETS_UNLOCK_TRIBAL_TOTEM_LVL1', 'MODIFIER_PLAYER_ADJUST_VALID_BUILDING', 0, 0, NULL),
    ('VILLAGER_SECRETS_UNLOCK_TRIBAL_TOTEM_LVL2', 'MODIFIER_PLAYER_ADJUST_VALID_BUILDING', 0, 0, NULL),
    ('VILLAGER_SECRETS_UNLOCK_TRIBAL_TOTEM_LVL3', 'MODIFIER_PLAYER_ADJUST_VALID_BUILDING', 0, 0, NULL),
    ('VILLAGER_SECRETS_UNLOCK_TRIBAL_TOTEM_LVL4', 'MODIFIER_PLAYER_ADJUST_VALID_BUILDING', 0, 0, NULL),
    ('VILLAGER_SECRETS_UNLOCK_TRIBAL_TOTEM_LVL5', 'MODIFIER_PLAYER_ADJUST_VALID_BUILDING', 0, 0, NULL),
    -- Support
    ('GOODY_MILITARY_GRANT_BATTERING_RAM', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_BY_CLASS_IN_NEAREST_CITY', 1, 1, NULL),
    ('GOODY_MILITARY_GRANT_CATAPULT', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_BY_CLASS_IN_NEAREST_CITY', 1, 1, NULL),
    ('GOODY_MILITARY_GRANT_MILITARY_ENGINEER', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_IN_NEAREST_CITY', 1, 1, NULL);

-- new ModifierArguments
REPLACE INTO ModifierArguments
    (ModifierId, Name, Value, Extra)
VALUES
    -- dummy modifier - for use by rewards implemented via lua
    ('GOODY_EGHV_DUMMY_REWARD', 'Amount', 0, NULL),
    ('GOODY_EGHV_DUMMY_REWARD', 'YieldType', 'YIELD_FOOD', NULL),
    ('GOODY_EGHV_DUMMY_REWARD', 'Scale', 'false', NULL),
    -- Culture : one free civic
    ('GOODY_CULTURE_GRANT_ONE_CIVIC', 'Amount', 1, -1),
    -- Culture : two free civics
    ('GOODY_CULTURE_GRANT_TWO_CIVICS', 'Amount', 2, -1),
    -- Gold : add trade route
    ('GOODY_GOLD_ADD_TRADE_ROUTE', 'Amount', 1, NULL),
    -- Military : grant recon unit
    ('GOODY_MILITARY_GRANT_SCOUT', 'UnitPromotionClassType', 'PROMOTION_CLASS_RECON', NULL),
    -- Military : grant melee unit
    ('GOODY_MILITARY_GRANT_WARRIOR', 'UnitPromotionClassType', 'PROMOTION_CLASS_MELEE', NULL),
    -- Military : grant ranged unit
    ('GOODY_MILITARY_GRANT_SLINGER', 'UnitPromotionClassType', 'PROMOTION_CLASS_RANGED', NULL),
    -- (Anti) Cavalry (Military) : grant anti-cavalry unit
    ('GOODY_MILITARY_GRANT_SPEARMAN', 'UnitPromotionClassType', 'PROMOTION_CLASS_ANTI_CAVALRY', NULL),
    -- (Anti) Cavalry (Military) : grant heavy cavalry unit
    ('GOODY_MILITARY_GRANT_HEAVY_CHARIOT', 'UnitPromotionClassType', 'PROMOTION_CLASS_HEAVY_CAVALRY', NULL),
    -- (Anti) Cavalry (Military) : grant light cavalry unit
    ('GOODY_MILITARY_GRANT_HORSEMAN', 'UnitPromotionClassType', 'PROMOTION_CLASS_LIGHT_CAVALRY', NULL),
    -- Science : two free techs
    ('GOODY_SCIENCE_GRANT_TWO_TECHS', 'Amount', 2, -1),
    -- Abilities : enhanced sight
    ('GOODY_ABILITIES_IMPROVED_SIGHT', 'Amount', 1, NULL),
    -- Abilities : enhanced healing
    ('GOODY_ABILITIES_IMPROVED_HEALING', 'Amount', 20, NULL),
    ('GOODY_ABILITIES_IMPROVED_HEALING', 'Type', 'ALL', NULL),
    -- Abilities : enhanced movement
    ('GOODY_ABILITIES_IMPROVED_MOVEMENT', 'Amount', 1, NULL),
    -- Abilities : enhanced combat strength
    ('GOODY_ABILITIES_IMPROVED_STRENGTH', 'Amount', 10, NULL),
    -- Envoys : +1 free
    ('GOODY_ENVOYS_GRANT_ONE', 'Amount', 1, NULL),
    -- Envoys : +2 free
    ('GOODY_ENVOYS_GRANT_TWO', 'Amount', 2, NULL),
    -- Envoys : +3 free
    ('GOODY_ENVOYS_GRANT_THREE', 'Amount', 3, NULL),
    -- Envoys : +4 free
    ('GOODY_ENVOYS_GRANT_FOUR', 'Amount', 4, NULL),
    -- culture fallback *** this helps prevent infinite loops and crashes related to EGHV; it should not be enabled or normally accessible ***
    ('GOODY_FALLBACK_CULTURE', 'YieldType', 'YIELD_CULTURE', NULL),
    ('GOODY_FALLBACK_CULTURE', 'Amount', 1, NULL),
    -- faith fallback *** this helps prevent infinite loops and crashes related to EGHV; it should not be enabled or normally accessible ***
    ('GOODY_FALLBACK_FAITH', 'YieldType', 'YIELD_FAITH', NULL),
    ('GOODY_FALLBACK_FAITH', 'Amount', 1, NULL),
    -- food fallback *** this helps prevent infinite loops and crashes related to EGHV; it should not be enabled or normally accessible ***
    ('GOODY_FALLBACK_FOOD', 'YieldType', 'YIELD_FOOD', NULL),
    ('GOODY_FALLBACK_FOOD', 'Amount', 1, NULL),
    -- gold fallback *** this helps prevent infinite loops and crashes related to EGHV; it should not be enabled or normally accessible ***
    ('GOODY_FALLBACK_GOLD', 'YieldType', 'YIELD_GOLD', NULL),
    ('GOODY_FALLBACK_GOLD', 'Amount', 2, NULL),
    -- production fallback *** this helps prevent infinite loops and crashes related to EGHV; it should not be enabled or normally accessible ***
    ('GOODY_FALLBACK_PRODUCTION', 'YieldType', 'YIELD_PRODUCTION', NULL),
    ('GOODY_FALLBACK_PRODUCTION', 'Amount', 1, NULL),
    -- science fallback *** this helps prevent infinite loops and crashes related to EGHV; it should not be enabled or normally accessible ***
    ('GOODY_FALLBACK_SCIENCE', 'YieldType', 'YIELD_SCIENCE', NULL),
    ('GOODY_FALLBACK_SCIENCE', 'Amount', 1, NULL),
    -- Hostile Villagers : unit XP modifier (the actual heavy-lifting here is done via lua)
    ('GOODY_SPAWN_HOSTILES', 'Amount', 3, NULL),
    -- Promotions : small lump XP sum
    ('GOODY_EXPERIENCE_SMALL_MODIFIER', 'Amount', 5, NULL),
    -- Promotions : medium lump XP sum
    ('GOODY_EXPERIENCE_MEDIUM_MODIFIER', 'Amount', 10, NULL),
    -- Promotions : large lump XP sum
    ('GOODY_EXPERIENCE_LARGE_MODIFIER', 'Amount', 15, NULL),
    -- Promotions : huge lump XP sum
    ('GOODY_EXPERIENCE_HUGE_MODIFIER', 'Amount', 25, NULL),
    -- Villager Secrets : unit XP modifier (the actual heavy-lifting here is done via lua)
    ('GOODY_VILLAGER_SECRETS', 'Amount', 3, NULL),
    -- level 0 Villager Totem building (initial unlock; +2 amenities)
    ('VILLAGER_SECRETS_UNLOCK_TRIBAL_TOTEM_LVL0', 'BuildingType', 'BUILDING_TRIBAL_TOTEM_LVL0', NULL),
    ('VILLAGER_SECRETS_UNLOCK_TRIBAL_TOTEM_LVL0', 'BuildingTypeToReplace', 'BUILDING_INTERNAL_TRIBAL_TOTEM', NULL),
    -- level 1 Villager Totem building (+2 gold, +1 all other yields)
    ('VILLAGER_SECRETS_UNLOCK_TRIBAL_TOTEM_LVL1', 'BuildingType', 'BUILDING_TRIBAL_TOTEM_LVL1', NULL),
    ('VILLAGER_SECRETS_UNLOCK_TRIBAL_TOTEM_LVL1', 'BuildingTypeToReplace', 'BUILDING_TRIBAL_TOTEM_LVL0', NULL),
    -- level 2 Villager Totem building (+4 gold, +2 all other yields)
    ('VILLAGER_SECRETS_UNLOCK_TRIBAL_TOTEM_LVL2', 'BuildingType', 'BUILDING_TRIBAL_TOTEM_LVL2', NULL),
    ('VILLAGER_SECRETS_UNLOCK_TRIBAL_TOTEM_LVL2', 'BuildingTypeToReplace', 'BUILDING_TRIBAL_TOTEM_LVL1', NULL),
    -- level 3 Villager Totem building (+6 gold, +3 all other yields)
    ('VILLAGER_SECRETS_UNLOCK_TRIBAL_TOTEM_LVL3', 'BuildingType', 'BUILDING_TRIBAL_TOTEM_LVL3', NULL),
    ('VILLAGER_SECRETS_UNLOCK_TRIBAL_TOTEM_LVL3', 'BuildingTypeToReplace', 'BUILDING_TRIBAL_TOTEM_LVL2', NULL),
    -- level 4 Villager Totem building (+8 gold, +4 all other yields)
    ('VILLAGER_SECRETS_UNLOCK_TRIBAL_TOTEM_LVL4', 'BuildingType', 'BUILDING_TRIBAL_TOTEM_LVL4', NULL),
    ('VILLAGER_SECRETS_UNLOCK_TRIBAL_TOTEM_LVL4', 'BuildingTypeToReplace', 'BUILDING_TRIBAL_TOTEM_LVL3', NULL),
    -- level 5 Villager Totem building (+10 gold, +5 all other yields)
    ('VILLAGER_SECRETS_UNLOCK_TRIBAL_TOTEM_LVL5', 'BuildingType', 'BUILDING_TRIBAL_TOTEM_LVL5', NULL),
    ('VILLAGER_SECRETS_UNLOCK_TRIBAL_TOTEM_LVL5', 'BuildingTypeToReplace', 'BUILDING_TRIBAL_TOTEM_LVL4', NULL),
    -- Support (Military) : grant support unit
    ('GOODY_MILITARY_GRANT_BATTERING_RAM', 'UnitPromotionClassType', 'PROMOTION_CLASS_SUPPORT', NULL),
    -- Support (Military) : grant siege unit
    ('GOODY_MILITARY_GRANT_CATAPULT', 'UnitPromotionClassType', 'PROMOTION_CLASS_SIEGE', NULL),
    -- Support (Military) : grant military engineer
    ('GOODY_MILITARY_GRANT_MILITARY_ENGINEER', 'UnitType', 'UNIT_MILITARY_ENGINEER', NULL),
    ('GOODY_MILITARY_GRANT_MILITARY_ENGINEER', 'Amount', 1, NULL);

/* ###########################################################################
    End EGHV ingame configuration
########################################################################### */
