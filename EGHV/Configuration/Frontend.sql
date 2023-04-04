/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2023 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV frontend configuration
########################################################################### */

-- reposition the No Barbarians parameter, and give it a description
UPDATE Parameters SET Description = 'LOC_GAME_NO_BARBARIANS_DESCRIPTION', SortIndex = 2020 WHERE ParameterId = 'NoBarbarians';

-- reposition the No Tribal Villages parameter, and give it a description
UPDATE Parameters SET Description = 'LOC_GAME_NO_GOODY_HUTS_DESCRIPTION', SortIndex = 2030 WHERE ParameterId = 'NoGoodyHuts';

-- equalize reward weights, and hostile villagers after reward dropdown
REPLACE INTO Parameters (ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, GroupId, SortIndex)
VALUES
    ('TotalRewards', 'LOC_GAME_TOTAL_REWARDS_NAME', 'LOC_GAME_TOTAL_REWARDS_DESC', 'TotalRewards', 1, 'Game', 'GAME_TOTAL_REWARDS', 'AdvancedOptions', 2034),
    ('HostilesChance', 'LOC_GAME_HOSTILES_CHANCE_NAME', 'LOC_GAME_HOSTILES_CHANCE_DESC', 'HostilesChance', 2, 'Game', 'GAME_HOSTILES_CHANCE', 'AdvancedOptions', 2035),
    ('EqualizeGoodyHuts', 'LOC_GAME_EQUALIZE_GOODY_HUTS_NAME', 'LOC_GAME_EQUALIZE_GOODY_HUTS_DESC', 'bool', 0, 'Game', 'GAME_EQUALIZE_GOODY_HUTS', 'AdvancedOptions', 2036),
    ('EGHV_Debug', 'LOC_GAME_EGHV_DEBUG_NAME', 'LOC_GAME_EGHV_DEBUG_DESC', 'bool', 0, 'Game', 'GAME_EGHV_DEBUG', 'AdvancedOptions', 2049);

-- domain values for specified parameter(s)
REPLACE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
VALUES
    ('TotalRewards', 1, 'LOC_TOTAL_REWARDS_1_NAME', 'LOC_TOTAL_REWARDS_1_DESC', 10),
    ('TotalRewards', 2, 'LOC_TOTAL_REWARDS_2_NAME', 'LOC_TOTAL_REWARDS_2_DESC', 20),
    ('TotalRewards', 3, 'LOC_TOTAL_REWARDS_3_NAME', 'LOC_TOTAL_REWARDS_3_DESC', 30),
    ('TotalRewards', 4, 'LOC_TOTAL_REWARDS_4_NAME', 'LOC_TOTAL_REWARDS_4_DESC', 40),
    ('TotalRewards', 5, 'LOC_TOTAL_REWARDS_5_NAME', 'LOC_TOTAL_REWARDS_5_DESC', 50),
    ('HostilesChance', 1, 'LOC_HOSTILES_CHANCE_NEVER_NAME', 'LOC_HOSTILES_CHANCE_NEVER_DESC', 10),
    ('HostilesChance', 2, 'LOC_HOSTILES_CHANCE_MAYBE_NAME', 'LOC_HOSTILES_CHANCE_MAYBE_DESC', 20),
    ('HostilesChance', 3, 'LOC_HOSTILES_CHANCE_ALWAYS_NAME', 'LOC_HOSTILES_CHANCE_ALWAYS_DESC', 30),
    ('HostilesChance', 4, 'LOC_HOSTILES_CHANCE_HYPER_NAME', 'LOC_HOSTILES_CHANCE_HYPER_DESC', 40);

-- 2021/05/24 : these options have been superceded, and are * DEPRECATED *; keeping them here as a learning experience
-- add advanced options to (1) equalize reward(s), and (2) disable hostile villagers _after_ a reward, and (3) disable hostile villagers _as_ the "reward"
-- REPLACE INTO Parameters (Key1, Key2, ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, GroupId, SortIndex)
-- VALUES
    -- equalize goody hut reward weights
    -- ('Ruleset', 'RULESET_STANDARD', 'EqualizeGoodyHuts', 'LOC_GAME_EQUALIZE_GOODY_HUTS_NAME', 'LOC_GAME_EQUALIZE_GOODY_HUTS_DESCRIPTION', 'bool', 0, 'Game', 'GAME_EQUALIZE_GOODY_HUTS', 'AdvancedOptions', 2035),
    -- ('Ruleset', 'RULESET_EXPANSION_1', 'EqualizeGoodyHuts', 'LOC_GAME_EQUALIZE_GOODY_HUTS_NAME', 'LOC_GAME_EQUALIZE_GOODY_HUTS_DESCRIPTION', 'bool', 0, 'Game', 'GAME_EQUALIZE_GOODY_HUTS', 'AdvancedOptions', 2035),
    -- ('Ruleset', 'RULESET_EXPANSION_2', 'EqualizeGoodyHuts', 'LOC_GAME_EQUALIZE_GOODY_HUTS_NAME', 'LOC_GAME_EQUALIZE_GOODY_HUTS_DESCRIPTION', 'bool', 0, 'Game', 'GAME_EQUALIZE_GOODY_HUTS', 'AdvancedOptions', 2035);
    -- no hostile villagers following other rewards
    -- ('Ruleset', 'RULESET_STANDARD', 'NoHostilesAfterReward', 'LOC_GAME_NO_HOSTILES_AFTER_REWARD_NAME', 'LOC_GAME_NO_HOSTILES_AFTER_REWARD_DESCRIPTION', 'bool', 0, 'Game', 'GAME_NO_HOSTILES_AFTER_REWARD', 'AdvancedOptions', 2033),
    -- ('Ruleset', 'RULESET_EXPANSION_1', 'NoHostilesAfterReward', 'LOC_GAME_NO_HOSTILES_AFTER_REWARD_NAME', 'LOC_GAME_NO_HOSTILES_AFTER_REWARD_DESCRIPTION', 'bool', 0, 'Game', 'GAME_NO_HOSTILES_AFTER_REWARD', 'AdvancedOptions', 2033),
    -- ('Ruleset', 'RULESET_EXPANSION_2', 'NoHostilesAfterReward', 'LOC_GAME_NO_HOSTILES_AFTER_REWARD_NAME', 'LOC_GAME_NO_HOSTILES_AFTER_REWARD_DESCRIPTION', 'bool', 0, 'Game', 'GAME_NO_HOSTILES_AFTER_REWARD', 'AdvancedOptions', 2033);
    -- no hostile villagers AS reward * DEPRECATED * this functionality is now provided by the Goody Huts picker *
    -- ('Ruleset', 'RULESET_STANDARD', 'NoHostilesAsReward', 'LOC_GAME_NO_HOSTILES_AS_REWARD_NAME', 'LOC_GAME_NO_HOSTILES_AS_REWARD_DESCRIPTION', 'bool', 0, 'Game', 'GAME_NO_HOSTILES_AS_REWARD', 'AdvancedOptions', 2034),
    -- ('Ruleset', 'RULESET_EXPANSION_1', 'NoHostilesAsReward', 'LOC_GAME_NO_HOSTILES_AS_REWARD_NAME', 'LOC_GAME_NO_HOSTILES_AS_REWARD_DESCRIPTION', 'bool', 0, 'Game', 'GAME_NO_HOSTILES_AS_REWARD', 'AdvancedOptions', 2034),
    -- ('Ruleset', 'RULESET_EXPANSION_2', 'NoHostilesAsReward', 'LOC_GAME_NO_HOSTILES_AS_REWARD_NAME', 'LOC_GAME_NO_HOSTILES_AS_REWARD_DESCRIPTION', 'bool', 0, 'Game', 'GAME_NO_HOSTILES_AS_REWARD', 'AdvancedOptions', 2034);

-- Goody Hut frequency slider
REPLACE INTO Parameters (ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, Hash, GroupId, SortIndex)
VALUES
    ('GoodyHutFrequency', 'LOC_GOODYHUT_DISTRIBUTION_NAME', 'LOC_GOODYHUT_DISTRIBUTION_DESCRIPTION', 'GoodyHutFrequencyRange', 100, 'Game', 'GOODYHUT_FREQUENCY', 0, 'AdvancedOptions', 2031);

-- Goody Hut picker
REPLACE INTO Parameters (Key1, Key2, ParameterId, Name, Description, Domain, Hash, Array, ConfigurationGroup, ConfigurationId, GroupId, UxHint, SortIndex)
VALUES
    ('Ruleset', 'RULESET_STANDARD', 'GoodyHutConfig', 'LOC_GOODY_HUT_CONFIG_NAME', 'LOC_GOODY_HUT_CONFIG_DESCRIPTION', 'StandardGoodyHuts', 0, 1, 'Game', 'EXCLUDE_GOODY_HUTS', 'AdvancedOptions', 'InvertSelection', 2032),
    ('Ruleset', 'RULESET_EXPANSION_1', 'GoodyHutConfig', 'LOC_GOODY_HUT_CONFIG_NAME', 'LOC_GOODY_HUT_CONFIG_DESCRIPTION', 'Expansion1GoodyHuts', 0, 1, 'Game', 'EXCLUDE_GOODY_HUTS', 'AdvancedOptions', 'InvertSelection', 2032),
    ('Ruleset', 'RULESET_EXPANSION_2', 'GoodyHutConfig', 'LOC_GOODY_HUT_CONFIG_NAME', 'LOC_GOODY_HUT_CONFIG_DESCRIPTION', 'Expansion2GoodyHuts', 0, 1, 'Game', 'EXCLUDE_GOODY_HUTS', 'AdvancedOptions', 'InvertSelection', 2032);

-- disable certain options if this is for the world builder
REPLACE INTO ParameterDependencies (ParameterId, ConfigurationGroup, ConfigurationId, Operator, ConfigurationValue)
VALUES
    ('GoodyHutConfig', 'Game', 'WORLD_BUILDER', 'NotEquals', 1);
    -- ('NoHostilesAfterReward', 'Game', 'WORLD_BUILDER', 'NotEquals', 1),
    -- ('NoHostilesAsReward', 'Game', 'WORLD_BUILDER', 'NotEquals', 1);

-- Goody Hut frequency slider range values
REPLACE INTO DomainRanges (Domain, MinimumValue, MaximumValue) VALUES ('GoodyHutFrequencyRange', 25, 500);

-- prep the Goody Hut picker
REPLACE INTO DomainValueQueries (QueryId) VALUES ('GoodyHutConfig');

-- queries for the Goody Hut picker
REPLACE INTO Queries (QueryId, SQL) VALUES ('GoodyHutConfig', 'SELECT Domain, Name, Description, SubTypeGoodyHut AS Value, Icon, SortIndex FROM TribalVillages');

/* ###########################################################################
    end EGHV frontend configuration
########################################################################### */
