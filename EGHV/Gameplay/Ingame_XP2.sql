/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2023 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    Begin EGHV ingame configuration for Gathering Storm
########################################################################### */

-- new Types
REPLACE INTO Types
    (Type, Kind)
VALUES
    -- Secrets : favor villager totem
    ('BUILDING_FAVOR_TOTEM_LOCKED', 'KIND_BUILDING'),
    ('BUILDING_FAVOR_TOTEM', 'KIND_BUILDING'),
    ('BUILDING_FAVOR_TOTEM_BIG', 'KIND_BUILDING'),
    -- strategic resources
    ('GOODYHUT_RESOURCES', 'KIND_GOODY_HUT');

-- new Buildings
REPLACE INTO Buildings
    (BuildingType, Name, Description, PrereqDistrict, PrereqTech, PurchaseYield, Cost, Entertainment, Maintenance, InternalOnly, AdvisorType)
VALUES
    -- Secrets : favor villager totem
    ('BUILDING_FAVOR_TOTEM_LOCKED', 'LOC_BUILDING_FAVOR_TOTEM_LOCKED_NAME', NULL, NULL, NULL, 'YIELD_GOLD', 1000, 0, 0, 1, NULL),
    ('BUILDING_FAVOR_TOTEM', 'LOC_BUILDING_FAVOR_TOTEM_NAME', 'LOC_BUILDING_FAVOR_TOTEM_DESC', 'DISTRICT_CITY_CENTER', NULL, 'YIELD_GOLD', 120, 0, 1, 0, 'ADVISOR_GENERIC'),
    ('BUILDING_FAVOR_TOTEM_BIG', 'LOC_BUILDING_FAVOR_TOTEM_NAME', 'LOC_BUILDING_FAVOR_TOTEM_DESC', 'DISTRICT_CITY_CENTER', NULL, 'YIELD_GOLD', 120, 0, 1, 0, 'ADVISOR_GENERIC');

-- new BuildingConditions
REPLACE INTO BuildingConditions
    (BuildingType, UnlocksFromEffect)
VALUES
    -- Secrets : favor villager totem
    ('BUILDING_FAVOR_TOTEM', 1),
    ('BUILDING_FAVOR_TOTEM_BIG', 1);

-- new BuildingReplaces
REPLACE INTO BuildingReplaces
    (CivUniqueBuildingType, ReplacesBuildingType)
VALUES
    -- Secrets : favor villager totem
    ('BUILDING_FAVOR_TOTEM', 'BUILDING_FAVOR_TOTEM_LOCKED'),
    ('BUILDING_FAVOR_TOTEM_BIG', 'BUILDING_FAVOR_TOTEM');

REPLACE INTO GoodyHuts_EGHV
    (GoodyHutType, Weight)
VALUES
    -- diplomatic favor
    ('GOODYHUT_DIPLOMACY', 100), 
    -- strategic resources
    ('GOODYHUT_RESOURCES', 100);
    -- alternate rewards
    -- ('GOODYHUT_ALTERNATE', 0);

-- New Goody Hut rewards : GoodyHutSubTypes
REPLACE INTO GoodyHutSubTypes_EGHV
    (Weight, GoodyHut, MinTurn, SubTypeGoodyHut, MinOneCity, Description, PrereqTech1, PrereqTech2, RequiresUnit, Experience, ExperienceMultiplier, ModifierID, Unit, UnitAbility, UnitClass, UnitType, Hostile, Fallback)
VALUES
    -- Secrets : favor villager totem
    (100, 'GOODYHUT_SECRETS', 0, 'GOODYHUT_VILLAGER_SECRETS_FAVOR', 1, 'LOC_GOODYHUT_VILLAGER_SECRETS_FAVOR_DESCRIPTION', NULL, NULL, 0, 0, NULL, 'VILLAGER_SECRETS_UNLOCK_FAVOR_TOTEM', 0, NULL, NULL, NULL, 0, 0),
    -- Diplomacy
    (55, 'GOODYHUT_DIPLOMACY', 0, 'GOODYHUT_SMALL_FAVOR', 0, 'LOC_GOODYHUT_SMALL_FAVOR_DESCRIPTION', NULL, NULL, 0, 0, NULL, 'GOODY_FAVOR_SMALL_MODIFIER', 0, NULL, NULL, NULL, 0, 1),
    (30, 'GOODYHUT_DIPLOMACY', 0, 'GOODYHUT_MEDIUM_FAVOR', 0, 'LOC_GOODYHUT_MEDIUM_FAVOR_DESCRIPTION', NULL, NULL, 0, 0, NULL, 'GOODY_FAVOR_MEDIUM_MODIFIER', 0, NULL, NULL, NULL, 0, 0),
    (10, 'GOODYHUT_DIPLOMACY', 0, 'GOODYHUT_LARGE_FAVOR', 0, 'LOC_GOODYHUT_LARGE_FAVOR_DESCRIPTION', NULL, NULL, 0, 0, NULL, 'GOODY_FAVOR_LARGE_MODIFIER', 0, NULL, NULL, NULL, 0, 0),
    (5, 'GOODYHUT_DIPLOMACY', 0, 'GOODYHUT_HUGE_FAVOR', 0, 'LOC_GOODYHUT_HUGE_FAVOR_DESCRIPTION', NULL, NULL, 0, 0, NULL, 'GOODY_FAVOR_HUGE_MODIFIER', 0, NULL, NULL, NULL, 0, 0),
    -- Resources
    (55, 'GOODYHUT_RESOURCES', 0, 'GOODYHUT_SMALL_RESOURCES', 0, 'LOC_GOODYHUT_SMALL_RESOURCES_DESCRIPTION', 'TECH_ANIMAL_HUSBANDRY', 'TECH_BRONZE_WORKING', 0, 0, NULL, 'GOODY_RESOURCES_SMALL_MODIFIER', 0, NULL, NULL, NULL, 0, 1),
    (30, 'GOODYHUT_RESOURCES', 0, 'GOODYHUT_MEDIUM_RESOURCES', 0, 'LOC_GOODYHUT_MEDIUM_RESOURCES_DESCRIPTION', 'TECH_ANIMAL_HUSBANDRY', 'TECH_BRONZE_WORKING', 0, 0, NULL, 'GOODY_RESOURCES_MEDIUM_MODIFIER', 0, NULL, NULL, NULL, 0, 0),
    (10, 'GOODYHUT_RESOURCES', 0, 'GOODYHUT_LARGE_RESOURCES', 0, 'LOC_GOODYHUT_LARGE_RESOURCES_DESCRIPTION', 'TECH_ANIMAL_HUSBANDRY', 'TECH_BRONZE_WORKING', 0, 0, NULL, 'GOODY_RESOURCES_LARGE_MODIFIER', 0, NULL, NULL, NULL, 0, 0),
    (5, 'GOODYHUT_RESOURCES', 0, 'GOODYHUT_HUGE_RESOURCES', 0, 'LOC_GOODYHUT_HUGE_RESOURCES_DESCRIPTION', 'TECH_ANIMAL_HUSBANDRY', 'TECH_BRONZE_WORKING', 0, 0, NULL, 'GOODY_RESOURCES_HUGE_MODIFIER', 0, NULL, NULL, NULL, 0, 0);
    -- grant Animal Husbandry tech when GOODYHUT_RESOURCES type is received before the tech is researched
    -- (0, 'GOODYHUT_ALTERNATE', 0, 'GOODYHUT_GRANT_ANIMAL_HUSBANDRY', 0, 'LOC_GOODYHUT_GRANT_ANIMAL_HUSBANDRY_DESCRIPTION', 0, 0, NULL, 'GOODY_ALTERNATE_GRANT_ANIMAL_HUSBANDRY', 0, NULL, NULL, NULL, 0, 0);

-- New Modifiers
REPLACE INTO Modifiers
    (ModifierId, ModifierType, RunOnce, Permanent, SubjectRequirementSetId)
VALUES
    -- Secrets : favor villager totem
    ('VILLAGER_SECRETS_UNLOCK_FAVOR_TOTEM', 'MODIFIER_PLAYER_ADJUST_VALID_BUILDING', 0, 0, NULL),
    -- ('BUILDING_FAVOR_TOTEM_FAVOR_MODIFIER', 'MODIFIER_PLAYER_ADJUST_BUILDING_FAVOR', 0, 0, NULL),
    ('BUILDING_FAVOR_TOTEM_FAVOR_MODIFIER', 'MODIFIER_PLAYER_ADJUST_EXTRA_FAVOR_PER_TURN', 0, 0, NULL),
    -- Diplomacy
    ('GOODY_FAVOR_SMALL_MODIFIER', 'MODIFIER_PLAYER_ADD_FAVOR', 1, 1, NULL),
    ('GOODY_FAVOR_MEDIUM_MODIFIER', 'MODIFIER_PLAYER_ADD_FAVOR', 1, 1, NULL),
    ('GOODY_FAVOR_LARGE_MODIFIER', 'MODIFIER_PLAYER_ADD_FAVOR', 1, 1, NULL),
    ('GOODY_FAVOR_HUGE_MODIFIER', 'MODIFIER_PLAYER_ADD_FAVOR', 1, 1, NULL),
    -- Resources
    ('GOODY_RESOURCES_SMALL_MODIFIER', 'MODIFIER_PLAYER_ADJUST_MOST_ADVANCED_STRATEGIC_RESOURCE_COUNT', 1, 1, NULL),
    ('GOODY_RESOURCES_MEDIUM_MODIFIER', 'MODIFIER_PLAYER_ADJUST_MOST_ADVANCED_STRATEGIC_RESOURCE_COUNT', 1, 1, NULL),
    ('GOODY_RESOURCES_LARGE_MODIFIER', 'MODIFIER_PLAYER_ADJUST_MOST_ADVANCED_STRATEGIC_RESOURCE_COUNT', 1, 1, NULL),
    ('GOODY_RESOURCES_HUGE_MODIFIER', 'MODIFIER_PLAYER_ADJUST_MOST_ADVANCED_STRATEGIC_RESOURCE_COUNT', 1, 1, NULL),
    -- grant Animal Husbandry tech when GOODYHUT_RESOURCES type is received before the tech is researched
    ('GOODY_ALTERNATE_GRANT_ANIMAL_HUSBANDRY', 'MODIFIER_PLAYER_GRANT_SPECIFIC_TECHNOLOGY', 0, 0, NULL);

-- New BuildingModifiers
REPLACE INTO BuildingModifiers
    (BuildingType, ModifierId)
VALUES
    ('BUILDING_FAVOR_TOTEM', 'BUILDING_FAVOR_TOTEM_FAVOR_MODIFIER');

-- new ModifierArguments : Resources rewards
REPLACE INTO ModifierArguments
    (ModifierId, Name, Value, Type)
VALUES
    -- Resources
    ('GOODY_RESOURCES_SMALL_MODIFIER', 'Amount', 10, 'ScaleByGameSpeed'),
    ('GOODY_RESOURCES_MEDIUM_MODIFIER', 'Amount', 20, 'ScaleByGameSpeed'),
    ('GOODY_RESOURCES_LARGE_MODIFIER', 'Amount', 30, 'ScaleByGameSpeed'),
    ('GOODY_RESOURCES_HUGE_MODIFIER', 'Amount', 50, 'ScaleByGameSpeed'),
    -- grant Animal Husbandry tech when GOODYHUT_RESOURCES type is received before the tech is researched
    ('GOODY_ALTERNATE_GRANT_ANIMAL_HUSBANDRY', 'TechType', 'TECH_ANIMAL_HUSBANDRY', 'ARGTYPE_IDENTITY');

-- new ModifierArguments : Tribal Totem and Diplomacy rewards
REPLACE INTO ModifierArguments
    (ModifierId, Name, Value, Extra)
VALUES
    -- Secrets : favor villager totem
    ('VILLAGER_SECRETS_UNLOCK_FAVOR_TOTEM', 'BuildingType', 'BUILDING_FAVOR_TOTEM', NULL),
    ('VILLAGER_SECRETS_UNLOCK_FAVOR_TOTEM', 'BuildingTypeToReplace', 'BUILDING_FAVOR_TOTEM_LOCKED', NULL),
    -- ('BUILDING_FAVOR_TOTEM_FAVOR_MODIFIER', 'BuildingType', 'BUILDING_FAVOR_TOTEM', NULL),
    -- ('BUILDING_FAVOR_TOTEM_FAVOR_MODIFIER', 'Favor', 4, NULL),
    ('BUILDING_FAVOR_TOTEM_FAVOR_MODIFIER', 'Amount', 4, NULL),
    -- Diplomacy
    ('GOODY_FAVOR_SMALL_MODIFIER', 'Amount', 10, NULL),
    ('GOODY_FAVOR_MEDIUM_MODIFIER', 'Amount', 20, NULL),
    ('GOODY_FAVOR_LARGE_MODIFIER', 'Amount', 30, NULL),
    ('GOODY_FAVOR_HUGE_MODIFIER', 'Amount', 50, NULL);

-- Add rows to table GoodyHutSubTypes_XP2 for new rewards which are similar to any built-in XP2 rewards
-- REPLACE INTO GoodyHutSubTypes_XP2 (SubTypeGoodyHut, CityState)
-- VALUES
--     ('GOODYHUT_ONE_ENVOY', 1),
--     ('GOODYHUT_TWO_ENVOYS', 1),
--     ('GOODYHUT_THREE_ENVOYS', 1),
--     ('GOODYHUT_FOUR_ENVOYS', 1);

-- adjust UnitRewards to reflect XP2 unit replacements
UPDATE UnitRewards SET Recon = 'UNIT_SKIRMISHER', LightCavalry = 'UNIT_COURSER' WHERE Era >= 2 AND Era <= 3;
UPDATE UnitRewards SET HeavyCavalry = 'UNIT_CUIRASSIER' WHERE Era = 4;

/* ###########################################################################
    End EGHV ingame configuration for Gathering Storm
########################################################################### */
