/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV frontend configuration
########################################################################### */

-- Reposition the No Barbarians parameter, and give it a description
UPDATE Parameters SET Description = 'LOC_GAME_NO_BARBARIANS_DESCRIPTION', SortIndex = 2020 WHERE ParameterId = 'NoBarbarians';

-- Reposition the No Tribal Villages parameter, and give it a description
UPDATE Parameters SET Description = 'LOC_GAME_NO_GOODY_HUTS_DESCRIPTION', SortIndex = 2030 WHERE ParameterId = 'NoGoodyHuts';

-- Add advanced options to (1) equalize reward(s), and (2) disable hostile villagers _after_ a reward, and (3) disable hostile villagers _as_ the "reward"
INSERT INTO Parameters (Key1, Key2, ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, GroupId, SortIndex)
VALUES
    -- equalize goody hut reward weights
    ('Ruleset', 'RULESET_STANDARD', 'EqualizeGoodyHuts', 'LOC_GAME_EQUALIZE_GOODY_HUTS_NAME', 'LOC_GAME_EQUALIZE_GOODY_HUTS_DESCRIPTION', 'bool', 0, 'Game', 'GAME_EQUALIZE_GOODY_HUTS', 'AdvancedOptions', 2035),
    ('Ruleset', 'RULESET_EXPANSION_1', 'EqualizeGoodyHuts', 'LOC_GAME_EQUALIZE_GOODY_HUTS_NAME', 'LOC_GAME_EQUALIZE_GOODY_HUTS_DESCRIPTION', 'bool', 0, 'Game', 'GAME_EQUALIZE_GOODY_HUTS', 'AdvancedOptions', 2035),
    ('Ruleset', 'RULESET_EXPANSION_2', 'EqualizeGoodyHuts', 'LOC_GAME_EQUALIZE_GOODY_HUTS_NAME', 'LOC_GAME_EQUALIZE_GOODY_HUTS_DESCRIPTION', 'bool', 0, 'Game', 'GAME_EQUALIZE_GOODY_HUTS', 'AdvancedOptions', 2035),
    -- no hostile villagers following other rewards
    ('Ruleset', 'RULESET_STANDARD', 'NoHostilesAfterReward', 'LOC_GAME_NO_HOSTILES_AFTER_REWARD_NAME', 'LOC_GAME_NO_HOSTILES_AFTER_REWARD_DESCRIPTION', 'bool', 0, 'Game', 'GAME_NO_HOSTILES_AFTER_REWARD', 'AdvancedOptions', 2033),
    ('Ruleset', 'RULESET_EXPANSION_1', 'NoHostilesAfterReward', 'LOC_GAME_NO_HOSTILES_AFTER_REWARD_NAME', 'LOC_GAME_NO_HOSTILES_AFTER_REWARD_DESCRIPTION', 'bool', 0, 'Game', 'GAME_NO_HOSTILES_AFTER_REWARD', 'AdvancedOptions', 2033),
    ('Ruleset', 'RULESET_EXPANSION_2', 'NoHostilesAfterReward', 'LOC_GAME_NO_HOSTILES_AFTER_REWARD_NAME', 'LOC_GAME_NO_HOSTILES_AFTER_REWARD_DESCRIPTION', 'bool', 0, 'Game', 'GAME_NO_HOSTILES_AFTER_REWARD', 'AdvancedOptions', 2033);
    -- no hostile villagers AS reward * DEPRECATED * this functionality is now provided by the Goody Huts picker *
    -- ('Ruleset', 'RULESET_STANDARD', 'NoHostilesAsReward', 'LOC_GAME_NO_HOSTILES_AS_REWARD_NAME', 'LOC_GAME_NO_HOSTILES_AS_REWARD_DESCRIPTION', 'bool', 0, 'Game', 'GAME_NO_HOSTILES_AS_REWARD', 'AdvancedOptions', 2034),
    -- ('Ruleset', 'RULESET_EXPANSION_1', 'NoHostilesAsReward', 'LOC_GAME_NO_HOSTILES_AS_REWARD_NAME', 'LOC_GAME_NO_HOSTILES_AS_REWARD_DESCRIPTION', 'bool', 0, 'Game', 'GAME_NO_HOSTILES_AS_REWARD', 'AdvancedOptions', 2034),
    -- ('Ruleset', 'RULESET_EXPANSION_2', 'NoHostilesAsReward', 'LOC_GAME_NO_HOSTILES_AS_REWARD_NAME', 'LOC_GAME_NO_HOSTILES_AS_REWARD_DESCRIPTION', 'bool', 0, 'Game', 'GAME_NO_HOSTILES_AS_REWARD', 'AdvancedOptions', 2034);

-- Goody Hut frequency dropdown items
-- REPLACE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
-- VALUES
--     ('GoodyHutDistribution', 25, 'LOC_GOODYHUT_DISTRIBUTION_025_NAME', 'LOC_GOODYHUT_DISTRIBUTION_025_DESCRIPTION', 10),
--     ('GoodyHutDistribution', 50, 'LOC_GOODYHUT_DISTRIBUTION_050_NAME', 'LOC_GOODYHUT_DISTRIBUTION_050_DESCRIPTION', 20),
--     ('GoodyHutDistribution', 75, 'LOC_GOODYHUT_DISTRIBUTION_075_NAME', 'LOC_GOODYHUT_DISTRIBUTION_075_DESCRIPTION', 30),
--     ('GoodyHutDistribution', 100, 'LOC_GOODYHUT_DISTRIBUTION_100_NAME', 'LOC_GOODYHUT_DISTRIBUTION_100_DESCRIPTION', 40),
--     ('GoodyHutDistribution', 125, 'LOC_GOODYHUT_DISTRIBUTION_125_NAME', 'LOC_GOODYHUT_DISTRIBUTION_125_DESCRIPTION', 50),
--     ('GoodyHutDistribution', 150, 'LOC_GOODYHUT_DISTRIBUTION_150_NAME', 'LOC_GOODYHUT_DISTRIBUTION_150_DESCRIPTION', 60),
--     ('GoodyHutDistribution', 175, 'LOC_GOODYHUT_DISTRIBUTION_175_NAME', 'LOC_GOODYHUT_DISTRIBUTION_175_DESCRIPTION', 70),
--     ('GoodyHutDistribution', 200, 'LOC_GOODYHUT_DISTRIBUTION_200_NAME', 'LOC_GOODYHUT_DISTRIBUTION_200_DESCRIPTION', 80),
--     ('GoodyHutDistribution', 225, 'LOC_GOODYHUT_DISTRIBUTION_225_NAME', 'LOC_GOODYHUT_DISTRIBUTION_225_DESCRIPTION', 90),
--     ('GoodyHutDistribution', 250, 'LOC_GOODYHUT_DISTRIBUTION_250_NAME', 'LOC_GOODYHUT_DISTRIBUTION_250_DESCRIPTION', 100),
--     ('GoodyHutDistribution', 275, 'LOC_GOODYHUT_DISTRIBUTION_275_NAME', 'LOC_GOODYHUT_DISTRIBUTION_275_DESCRIPTION', 110),
--     ('GoodyHutDistribution', 300, 'LOC_GOODYHUT_DISTRIBUTION_300_NAME', 'LOC_GOODYHUT_DISTRIBUTION_300_DESCRIPTION', 120),
--     ('GoodyHutDistribution', 325, 'LOC_GOODYHUT_DISTRIBUTION_325_NAME', 'LOC_GOODYHUT_DISTRIBUTION_325_DESCRIPTION', 130),
--     ('GoodyHutDistribution', 350, 'LOC_GOODYHUT_DISTRIBUTION_350_NAME', 'LOC_GOODYHUT_DISTRIBUTION_350_DESCRIPTION', 140),
--     ('GoodyHutDistribution', 375, 'LOC_GOODYHUT_DISTRIBUTION_375_NAME', 'LOC_GOODYHUT_DISTRIBUTION_375_DESCRIPTION', 150),
--     ('GoodyHutDistribution', 400, 'LOC_GOODYHUT_DISTRIBUTION_400_NAME', 'LOC_GOODYHUT_DISTRIBUTION_400_DESCRIPTION', 160),
--     ('GoodyHutDistribution', 425, 'LOC_GOODYHUT_DISTRIBUTION_425_NAME', 'LOC_GOODYHUT_DISTRIBUTION_425_DESCRIPTION', 170),
--     ('GoodyHutDistribution', 450, 'LOC_GOODYHUT_DISTRIBUTION_450_NAME', 'LOC_GOODYHUT_DISTRIBUTION_450_DESCRIPTION', 180),
--     ('GoodyHutDistribution', 475, 'LOC_GOODYHUT_DISTRIBUTION_475_NAME', 'LOC_GOODYHUT_DISTRIBUTION_475_DESCRIPTION', 190),
--     ('GoodyHutDistribution', 500, 'LOC_GOODYHUT_DISTRIBUTION_500_NAME', 'LOC_GOODYHUT_DISTRIBUTION_500_DESCRIPTION', 200);

-- Goody Hut frequency dropdown
-- INSERT INTO Parameters (ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, GroupId, SortIndex)
-- VALUES
--     ('GoodyHutDistribution', 'LOC_GOODYHUT_DISTRIBUTION_NAME', 'LOC_GOODYHUT_DISTRIBUTION_DESCRIPTION', 'GoodyHutDistribution', 100, 'Game', 'GOODYHUT_FREQUENCY', 'GameOptions', 2031);

-- Goody Hut frequency slider
INSERT INTO Parameters (ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, Hash, GroupId, SortIndex)
VALUES
    ('GoodyHutFrequency', 'LOC_GOODYHUT_DISTRIBUTION_NAME', 'LOC_GOODYHUT_DISTRIBUTION_DESCRIPTION', 'GoodyHutFrequencyRange', 100, 'Game', 'GOODYHUT_FREQUENCY', 0, 'AdvancedOptions', 2031);

-- Goody Hut picker
INSERT INTO Parameters (Key1, Key2, ParameterId, Name, Description, Domain, Hash, Array, ConfigurationGroup, ConfigurationId, GroupId, UxHint, SortIndex)
VALUES
    ('Ruleset', 'RULESET_STANDARD', 'GoodyHutConfig', 'LOC_GOODY_HUT_CONFIG_NAME', 'LOC_GOODY_HUT_CONFIG_DESCRIPTION', 'StandardGoodyHuts', 0, 1, 'Game', 'EXCLUDE_GOODY_HUTS', 'AdvancedOptions', 'InvertSelection', 2032),
    ('Ruleset', 'RULESET_EXPANSION_1', 'GoodyHutConfig', 'LOC_GOODY_HUT_CONFIG_NAME', 'LOC_GOODY_HUT_CONFIG_DESCRIPTION', 'Expansion1GoodyHuts', 0, 1, 'Game', 'EXCLUDE_GOODY_HUTS', 'AdvancedOptions', 'InvertSelection', 2032),
    ('Ruleset', 'RULESET_EXPANSION_2', 'GoodyHutConfig', 'LOC_GOODY_HUT_CONFIG_NAME', 'LOC_GOODY_HUT_CONFIG_DESCRIPTION', 'Expansion2GoodyHuts', 0, 1, 'Game', 'EXCLUDE_GOODY_HUTS', 'AdvancedOptions', 'InvertSelection', 2032);

-- Disable certain options if this is for the world builder
INSERT INTO ParameterDependencies (ParameterId, ConfigurationGroup, ConfigurationId, Operator, ConfigurationValue)
VALUES
    ('GoodyHutConfig', 'Game', 'WORLD_BUILDER', 'NotEquals', 1),
    ('NoHostilesAfterReward', 'Game', 'WORLD_BUILDER', 'NotEquals', 1),
    ('NoHostilesAsReward', 'Game', 'WORLD_BUILDER', 'NotEquals', 1);

-- 
-- REPLACE INTO DomainRangeQueries (QueryId) VALUES ('GoodyHutFrequencyRange');
REPLACE INTO DomainRanges (Domain, MinimumValue, MaximumValue) VALUES ('GoodyHutFrequencyRange', 25, 500);

-- prep the Goody Hut picker
REPLACE INTO DomainValueQueries (QueryId) VALUES ('GoodyHutConfig');

-- queries for the Goody Hut picker and frequency slider
REPLACE INTO Queries (QueryId, SQL)
VALUES
    -- ('GoodyHutFrequencyRange', 'SELECT ''GoodyHutFrequencyRange'' AS Domain, 25 AS MinimumValue, 500 AS MaximumValue LIMIT 1'),
    ('GoodyHutConfig', 'SELECT Domain, Name, Description, SubTypeGoodyHut AS Value, Icon, SortIndex FROM TribalVillages');

/* ###########################################################################
    end EGHV frontend configuration
########################################################################### */
