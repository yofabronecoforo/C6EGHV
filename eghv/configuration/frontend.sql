/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2023 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV frontend configuration
########################################################################### */

-- 
-- REPLACE INTO ContentFlags (Id, Name, GUID, CityStates, GoodyHuts, Leaders, NaturalWonders, Base, XP1, XP2, Tooltip)
-- VALUES 
--     ('DLC01', 'Aztec', '02A8BDDE-67EA-4D38-9540-26E685E3156E', 0, 0, 1, 0, 1, 1, 1, 'LOC_DLC_AZTEC_TT'),
--     ('DLC02', 'Poland', '3809975F-263F-40A2-A747-8BFB171D821A', 0, 0, 1, 0, 1, 1, 1, 'LOC_DLC_POLAND_TT'),
--     ('DLC03', 'Vikings', '2F6E858A-28EF-46B3-BEAC-B985E52E9BC1', 1, 0, 1, 1, 1, 1, 1, 'LOC_DLC_VIKINGS_TT'),
--     ('DLC04', 'Australia', 'E3F53C61-371C-440B-96CE-077D318B36C0', 0, 0, 1, 1, 1, 1, 1, 'LOC_DLC_AUSTRALIA_TT'),
--     ('DLC05', 'Persia', 'E2749E9A-8056-45CD-901B-C368C8E83DEB', 0, 0, 1, 0, 1, 1, 1, 'LOC_DLC_PERSIA_TT'),
--     ('DLC06', 'Nubia', '643EA320-8E1A-4CF1-A01C-00D88DDD131A', 0, 0, 1, 0, 1, 1, 1, 'LOC_DLC_NUBIA_TT'),
--     ('DLC07', 'Khmer', '1F367231-A040-4793-BDBB-088816853683', 0, 0, 1, 1, 1, 1, 1, 'LOC_DLC_KHMER_TT'),
--     ('DLC08', 'Maya', '9DE86512-DE1A-400D-8C0A-AB46EBBF76B9', 1, 0, 1, 1, 1, 1, 1, 'LOC_DLC_MAYA_TT'),
--     ('DLC09', 'Ethiopia', '1B394FE9-23DC-4868-8F0A-5220CB8FB427', 0, 0, 1, 0, 1, 1, 1, 'LOC_DLC_ETHIOPIA_TT'),
--     ('DLC10', 'Byzantium', 'A1100FC4-70F2-4129-AC27-2A65A685ED08', 0, 0, 1, 0, 1, 1, 1, 'LOC_DLC_BYZANTIUM_TT'),
--     ('DLC11', 'Babylon', '8424840C-92EF-4426-A9B4-B4E0CB818049', 1, 0, 1, 0, 1, 1, 1, 'LOC_DLC_BABYLON_STK_TT'),
--     ('DLC12', 'Vietnam', 'A3F42CD4-6C3E-4F5A-BC81-BE29E0C0B87C', 0, 0, 1, 0, 1, 1, 1, 'LOC_DLC_VIETNAM_TT'),
--     ('DLC13', 'Portugal', 'FFDF4E79-DEE2-47BB-919B-F5739106627A', 0, 0, 1, 0, 1, 1, 1, 'LOC_DLC_PORTUGAL_TT'),
--     ('XP1', 'Expansion1', '1B28771A-C749-434B-9053-D1380C553DE9', 0, 0, 1, 1, 0, 1, 1, 'LOC_XP1_TT'),
--     ('XP2', 'Expansion2', '4873eb62-8ccc-4574-b784-dda455e74e68', 1, 1, 1, 1, 0, 0, 1, 'LOC_XP2_TT'),
--     ('ENWS', 'ENWS', 'd0afae5b-02f8-4d01-bd54-c2bbc3d89858', 0, 0, 0, 0, 1, 1, 1, 'LOC_ENWS_TT'),
--     ('EGHV', 'EGHV', 'a4b1fac6-8c9e-4873-a1c1-7ddf08dbbf11', 0, 1, 0, 0, 1, 1, 1, 'LOC_EGHV_TT'),
--     ('WGH', 'WGH', '2d90451f-08c9-47de-bce8-e9b7fdecbe92', 0, 1, 0, 0, 1, 1, 1, 'LOC_WGH_TT');

-- reposition the No Barbarians parameter, and give it a description
UPDATE Parameters SET Description = 'LOC_GAME_NO_BARBARIANS_DESCRIPTION', SortIndex = 2020 WHERE ParameterId = 'NoBarbarians';

-- reposition the No Tribal Villages parameter, and give it a description
UPDATE Parameters SET Description = 'LOC_GAME_NO_GOODY_HUTS_DESCRIPTION', SortIndex = 2030 WHERE ParameterId = 'NoGoodyHuts';

-- 
REPLACE INTO Parameters (Key1, Key2, ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, GroupId, SortIndex)
VALUES
    ('Ruleset', 'RULESET_EXPANSION_2', 'DisableMeteorStrike', 'LOC_GAME_DISABLE_METEOR_STRIKE_NAME', 'LOC_GAME_DISABLE_METEOR_STRIKE_DESC', 'bool', 0, 'Game', 'GAME_DISABLE_METEOR_STRIKE', 'AdvancedOptions', 2042);

-- equalize reward weights, and hostile villagers after reward dropdown
REPLACE INTO Parameters (ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, GroupId, SortIndex)
VALUES
    ('EqualizeGoodyHuts', 'LOC_GAME_EQUALIZE_GOODY_HUTS_NAME', 'LOC_GAME_EQUALIZE_GOODY_HUTS_DESC', 'bool', 0, 'Game', 'GAME_EQUALIZE_GOODY_HUTS', 'AdvancedOptions', 2041),
    ('TotalRewards', 'LOC_GAME_TOTAL_REWARDS_NAME', 'LOC_GAME_TOTAL_REWARDS_DESC', 'TotalRewards', 1, 'Game', 'GAME_TOTAL_REWARDS', 'AdvancedOptions', 2033),
    ('NoDuplicateRewards', 'LOC_GAME_NO_DUPLICATE_REWARDS_NAME', 'LOC_GAME_NO_DUPLICATE_REWARDS_DESC', 'bool', 1, 'Game', 'GAME_NO_DUPLICATE_REWARDS', 'AdvancedOptions', 2034),
    ('HostilesChance', 'LOC_GAME_HOSTILES_CHANCE_NAME', 'LOC_GAME_HOSTILES_CHANCE_DESC', 'HostilesChance', 2, 'Game', 'GAME_HOSTILES_CHANCE', 'AdvancedOptions', 2037),
    ('HostilesMinTurn', 'LOC_GAME_HOSTILES_MIN_TURN_NAME', 'LOC_GAME_HOSTILES_MIN_TURN_DESC', 'HostilesMinTurn', 2, 'Game', 'GAME_HOSTILES_MIN_TURN', 'AdvancedOptions', 2038),
    ('UnlockVillagerSecrets', 'LOC_GAME_UNLOCK_VILLAGER_SECRETS_NAME', 'LOC_GAME_UNLOCK_VILLAGER_SECRETS_DESC', 'UnlockVillagerSecrets', 1, 'Game', 'GAME_UNLOCK_VILLAGER_SECRETS', 'AdvancedOptions', 2036),
    ('BonusUnitOrPop', 'LOC_GAME_BONUS_UNIT_OR_POP_NAME', 'LOC_GAME_BONUS_UNIT_OR_POP_DESC', 'BonusUnitOrPop', 1, 'Game', 'GAME_BONUS_UNIT_OR_POP', 'AdvancedOptions', 2035);
    -- ('EGHV_Logging', 'LOC_GAME_EGHV_LOGGING_NAME', 'LOC_GAME_EGHV_LOGGING_DESC', 'EGHV_Logging', 2, 'Game', 'GAME_EGHV_LOGGING', 'AdvancedOptions', 2049);
    -- ('EGHV_Debug', 'LOC_GAME_EGHV_DEBUG_NAME', 'LOC_GAME_EGHV_DEBUG_DESC', 'bool', 0, 'Game', 'GAME_EGHV_DEBUG', 'AdvancedOptions', 2049);

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
    -- ('EGHV_Logging', 1, 'LOC_EGHV_LOGGING_MINIMAL_NAME', 'LOC_EGHV_LOGGING_MINIMAL_DESC', 10),
    -- ('EGHV_Logging', 2, 'LOC_EGHV_LOGGING_NORMAL_NAME', 'LOC_EGHV_LOGGING_NORMAL_DESC', 20),
    -- ('EGHV_Logging', 3, 'LOC_EGHV_LOGGING_VERBOSE_NAME', 'LOC_EGHV_LOGGING_VERBOSE_DESC', 30);
    -- ('EGHV_Logging', 4, 'LOC_EGHV_LOGGING_EXTRA_VERBOSE_NAME', 'LOC_EGHV_LOGGING_EXTRA_VERBOSE_DESC', 40);

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