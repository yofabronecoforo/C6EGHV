/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2024 yofabronecoforo (zzragnar0kzz)
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV frontend configuration
########################################################################### */

-- reposition the No Barbarians parameter, and give it a description
UPDATE Parameters SET Description = 'LOC_GAME_NO_BARBARIANS_DESCRIPTION', SortIndex = 2020 WHERE ParameterId = 'NoBarbarians';

-- reposition the No Tribal Villages parameter, and give it a description
UPDATE Parameters SET Description = 'LOC_GAME_NO_GOODY_HUTS_DESCRIPTION', SortIndex = 2021 WHERE ParameterId = 'NoGoodyHuts';

-- disable meteor strike
REPLACE INTO Parameters (Key1, Key2, ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, GroupId, SortIndex)
VALUES
    ('Ruleset', 'RULESET_EXPANSION_2', 'DisableMeteorStrike', 'LOC_GAME_DISABLE_METEOR_STRIKE_NAME', 'LOC_GAME_DISABLE_METEOR_STRIKE_DESC', 'bool', 0, 'Game', 'GAME_DISABLE_METEOR_STRIKE', 'AdvancedOptions', 2024);

-- equalize reward weights, and hostile villagers after reward dropdown
REPLACE INTO Parameters (ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, GroupId, SortIndex)
VALUES
    ('EqualizeGoodyHuts', 'LOC_GAME_EQUALIZE_GOODY_HUTS_NAME', 'LOC_GAME_EQUALIZE_GOODY_HUTS_DESC', 'bool', 0, 'Game', 'GAME_EQUALIZE_GOODY_HUTS', 'AdvancedOptions', 2023),
    ('TotalRewards', 'LOC_GAME_TOTAL_REWARDS_NAME', 'LOC_GAME_TOTAL_REWARDS_DESC', 'TotalRewards', 1, 'Game', 'GAME_TOTAL_REWARDS', 'AdvancedOptions', 2033),
    ('NoDuplicateRewards', 'LOC_GAME_NO_DUPLICATE_REWARDS_NAME', 'LOC_GAME_NO_DUPLICATE_REWARDS_DESC', 'bool', 1, 'Game', 'GAME_NO_DUPLICATE_REWARDS', 'AdvancedOptions', 2022),
    ('HostilesChance', 'LOC_GAME_HOSTILES_CHANCE_NAME', 'LOC_GAME_HOSTILES_CHANCE_DESC', 'HostilesChance', 2, 'Game', 'GAME_HOSTILES_CHANCE', 'AdvancedOptions', 2037),
    ('HostilesMinTurn', 'LOC_GAME_HOSTILES_MIN_TURN_NAME', 'LOC_GAME_HOSTILES_MIN_TURN_DESC', 'HostilesMinTurn', 2, 'Game', 'GAME_HOSTILES_MIN_TURN', 'AdvancedOptions', 2038),
    ('UnlockVillagerSecrets', 'LOC_GAME_UNLOCK_VILLAGER_SECRETS_NAME', 'LOC_GAME_UNLOCK_VILLAGER_SECRETS_DESC', 'UnlockVillagerSecrets', 1, 'Game', 'GAME_UNLOCK_VILLAGER_SECRETS', 'AdvancedOptions', 2036),
    ('BonusUnitOrPop', 'LOC_GAME_BONUS_UNIT_OR_POP_NAME', 'LOC_GAME_BONUS_UNIT_OR_POP_DESC', 'BonusUnitOrPop', 1, 'Game', 'GAME_BONUS_UNIT_OR_POP', 'AdvancedOptions', 2035);
    
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
    ('HostilesChance', 4, 'LOC_HOSTILES_CHANCE_HYPER_NAME', 'LOC_HOSTILES_CHANCE_HYPER_DESC', 40),
    ('HostilesMinTurn', 2, 'LOC_HOSTILES_MIN_TURN_2_NAME', 'LOC_HOSTILES_MIN_TURN_2_DESC', 10),
    ('HostilesMinTurn', 5, 'LOC_HOSTILES_MIN_TURN_5_NAME', 'LOC_HOSTILES_MIN_TURN_5_DESC', 20),
    ('HostilesMinTurn', 10, 'LOC_HOSTILES_MIN_TURN_10_NAME', 'LOC_HOSTILES_MIN_TURN_10_DESC', 30),
    ('UnlockVillagerSecrets', 1, 'LOC_UNLOCK_VILLAGER_SECRETS_NO_NAME', 'LOC_UNLOCK_VILLAGER_SECRETS_NO_DESC', 10),
    ('UnlockVillagerSecrets', 2, 'LOC_UNLOCK_VILLAGER_SECRETS_YES_HUMAN_NAME', 'LOC_UNLOCK_VILLAGER_SECRETS_YES_HUMAN_DESC', 20),
    ('UnlockVillagerSecrets', 3, 'LOC_UNLOCK_VILLAGER_SECRETS_YES_AI_NAME', 'LOC_UNLOCK_VILLAGER_SECRETS_YES_AI_DESC', 30),
    ('UnlockVillagerSecrets', 4, 'LOC_UNLOCK_VILLAGER_SECRETS_YES_ALL_NAME', 'LOC_UNLOCK_VILLAGER_SECRETS_YES_ALL_DESC', 40),
    ('BonusUnitOrPop', 1, 'LOC_UNIT_OR_POP_ONE_ALWAYS_NAME', 'LOC_UNIT_OR_POP_ONE_ALWAYS_DESC', 10),
    ('BonusUnitOrPop', 20, 'LOC_UNIT_OR_POP_TWO_5_NAME', 'LOC_UNIT_OR_POP_TWO_5_DESC', 20),
    ('BonusUnitOrPop', 10, 'LOC_UNIT_OR_POP_TWO_10_NAME', 'LOC_UNIT_OR_POP_TWO_10_DESC', 30),
    ('BonusUnitOrPop', 6, 'LOC_UNIT_OR_POP_TWO_17_NAME', 'LOC_UNIT_OR_POP_TWO_17_DESC', 40),
    ('BonusUnitOrPop', 4, 'LOC_UNIT_OR_POP_TWO_25_NAME', 'LOC_UNIT_OR_POP_TWO_25_DESC', 50),
    ('BonusUnitOrPop', 2, 'LOC_UNIT_OR_POP_TWO_50_NAME', 'LOC_UNIT_OR_POP_TWO_50_DESC', 60),
    ('BonusUnitOrPop', 7, 'LOC_UNIT_OR_POP_TWO_ALWAYS_NAME', 'LOC_UNIT_OR_POP_TWO_ALWAYS_DESC', 70);
    
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
    ('Ruleset', 'RULESET_STANDARD', 'GoodyHuts', 'LOC_GOODY_HUT_CONFIG_NAME', 'LOC_GOODY_HUT_CONFIG_DESCRIPTION', 'StandardGoodyHuts', 0, 1, 'Game', 'EXCLUDE_GOODY_HUTS', 'AdvancedOptions', 'InvertSelection', 2032),
    ('Ruleset', 'RULESET_EXPANSION_1', 'GoodyHuts', 'LOC_GOODY_HUT_CONFIG_NAME', 'LOC_GOODY_HUT_CONFIG_DESCRIPTION', 'Expansion1GoodyHuts', 0, 1, 'Game', 'EXCLUDE_GOODY_HUTS', 'AdvancedOptions', 'InvertSelection', 2032),
    ('Ruleset', 'RULESET_EXPANSION_2', 'GoodyHuts', 'LOC_GOODY_HUT_CONFIG_NAME', 'LOC_GOODY_HUT_CONFIG_DESCRIPTION', 'Expansion2GoodyHuts', 0, 1, 'Game', 'EXCLUDE_GOODY_HUTS', 'AdvancedOptions', 'InvertSelection', 2032);

-- parameters defined here are only visible when the specified conditions are met
REPLACE INTO ParameterDependencies (ParameterId, ConfigurationGroup, ConfigurationId, Operator, ConfigurationValue)
VALUES
    ('BonusUnitOrPop', 'Game', 'GAME_NO_GOODY_HUTS', 'Equals', 0),
    ('BonusUnitOrPop', 'Game', 'GOODYHUT_FREQUENCY', 'NotEquals', 0),
    ('EqualizeGoodyHuts', 'Game', 'GAME_NO_GOODY_HUTS', 'Equals', 0),
    ('EqualizeGoodyHuts', 'Game', 'GOODYHUT_FREQUENCY', 'NotEquals', 0),
    ('GoodyHutFrequency', 'Game', 'GAME_NO_GOODY_HUTS', 'Equals', 0),
    ('GoodyHuts', 'Game', 'GAME_NO_GOODY_HUTS', 'Equals', 0),
    ('GoodyHuts', 'Game', 'GOODYHUT_FREQUENCY', 'NotEquals', 0),
    ('GoodyHuts', 'Game', 'WORLD_BUILDER', 'NotEquals', 1),
    ('HostilesChance', 'Game', 'GAME_NO_BARBARIANS', 'Equals', 0),
    ('HostilesChance', 'Game', 'GAME_NO_GOODY_HUTS', 'Equals', 0),
    ('HostilesChance', 'Game', 'GOODYHUT_FREQUENCY', 'NotEquals', 0),
    ('HostilesMinTurn', 'Game', 'GAME_NO_BARBARIANS', 'Equals', 0),
    ('HostilesMinTurn', 'Game', 'GAME_NO_GOODY_HUTS', 'Equals', 0),
    ('HostilesMinTurn', 'Game', 'GOODYHUT_FREQUENCY', 'NotEquals', 0),
    ('NoDuplicateRewards', 'Game', 'GAME_NO_GOODY_HUTS', 'Equals', 0),
    ('NoDuplicateRewards', 'Game', 'GOODYHUT_FREQUENCY', 'NotEquals', 0),
    ('TotalRewards', 'Game', 'GAME_NO_GOODY_HUTS', 'Equals', 0),
    ('TotalRewards', 'Game', 'GOODYHUT_FREQUENCY', 'NotEquals', 0),
    ('UnlockVillagerSecrets', 'Game', 'GAME_NO_GOODY_HUTS', 'Equals', 0),
    ('UnlockVillagerSecrets', 'Game', 'GOODYHUT_FREQUENCY', 'NotEquals', 0);

-- Goody Hut frequency slider range values
REPLACE INTO DomainRanges (Domain, MinimumValue, MaximumValue) VALUES ('GoodyHutFrequencyRange', 0, 500);

-- prep the Goody Hut picker
REPLACE INTO DomainValueQueries (QueryId) VALUES ('GoodyHuts');

-- queries for the Goody Hut picker
REPLACE INTO Queries (QueryId, SQL) VALUES ('GoodyHuts', 'SELECT Domain, Name, Description, SubTypeGoodyHut AS Value, Icon, SortIndex FROM TribalVillages');

/* ###########################################################################
    end EGHV frontend configuration
########################################################################### */
