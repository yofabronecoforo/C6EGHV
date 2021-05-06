/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV frontend configuration
########################################################################### */

-- Reposition the No Barbarians parameter
UPDATE Parameters SET Description = 'LOC_GAME_NO_BARBARIANS_DESCRIPTION', SortIndex = 2020 WHERE ParameterId = 'NoBarbarians';

-- Reposition the No Tribal Villages parameter
UPDATE Parameters SET SortIndex = 2030 WHERE ParameterId = 'NoGoodyHuts';

-- Add advanced options to (1) disable hostile villagers _after_ a reward, and (2) disable hostile villagers _as_ the "reward"
INSERT INTO Parameters (Key1, Key2, ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, GroupId, SortIndex)
VALUES
    ('Ruleset', 'RULESET_STANDARD', 'NoHostilesAfterReward', 'LOC_GAME_NO_HOSTILES_AFTER_REWARD_NAME', 'LOC_GAME_NO_HOSTILES_AFTER_REWARD_DESCRIPTION', 'bool', 0, 'Game', 'GAME_NO_HOSTILES_AFTER_REWARD', 'AdvancedOptions', 2031),
    ('Ruleset', 'RULESET_EXPANSION_1', 'NoHostilesAfterReward', 'LOC_GAME_NO_HOSTILES_AFTER_REWARD_NAME', 'LOC_GAME_NO_HOSTILES_AFTER_REWARD_DESCRIPTION', 'bool', 0, 'Game', 'GAME_NO_HOSTILES_AFTER_REWARD', 'AdvancedOptions', 2031),
    ('Ruleset', 'RULESET_EXPANSION_2', 'NoHostilesAfterReward', 'LOC_GAME_NO_HOSTILES_AFTER_REWARD_NAME', 'LOC_GAME_NO_HOSTILES_AFTER_REWARD_DESCRIPTION', 'bool', 0, 'Game', 'GAME_NO_HOSTILES_AFTER_REWARD', 'AdvancedOptions', 2031),
    ('Ruleset', 'RULESET_STANDARD', 'NoHostilesAsReward', 'LOC_GAME_NO_HOSTILES_AS_REWARD_NAME', 'LOC_GAME_NO_HOSTILES_AS_REWARD_DESCRIPTION', 'bool', 0, 'Game', 'GAME_NO_HOSTILES_AS_REWARD', 'AdvancedOptions', 2032),
    ('Ruleset', 'RULESET_EXPANSION_1', 'NoHostilesAsReward', 'LOC_GAME_NO_HOSTILES_AS_REWARD_NAME', 'LOC_GAME_NO_HOSTILES_AS_REWARD_DESCRIPTION', 'bool', 0, 'Game', 'GAME_NO_HOSTILES_AS_REWARD', 'AdvancedOptions', 2032),
    ('Ruleset', 'RULESET_EXPANSION_2', 'NoHostilesAsReward', 'LOC_GAME_NO_HOSTILES_AS_REWARD_NAME', 'LOC_GAME_NO_HOSTILES_AS_REWARD_DESCRIPTION', 'bool', 0, 'Game', 'GAME_NO_HOSTILES_AS_REWARD', 'AdvancedOptions', 2032);

-- Disable certain options if this is for the world builder
INSERT INTO ParameterDependencies (ParameterId, ConfigurationGroup, ConfigurationId, Operator, ConfigurationValue)
VALUES
    ('NoHostilesAfterReward', 'Game', 'WORLD_BUILDER', 'NotEquals', 1),
    ('NoHostilesAsReward', 'Game', 'WORLD_BUILDER', 'NotEquals', 1);

/* ###########################################################################
    end EGHV frontend configuration
########################################################################### */
