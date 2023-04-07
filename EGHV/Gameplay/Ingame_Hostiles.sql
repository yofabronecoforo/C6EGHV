/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2023 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    Begin EGHV ingame configuration for hostile villagers
	these settings are used extensively by EGHV gameplay scripts
########################################################################### */

-- set HostileModifier for all reward SubTypes, based on Weight and/or Type
UPDATE GoodyHutSubTypes
SET HostileModifier = CASE
	WHEN GoodyHut = 'GOODYHUT_FALLBACK' THEN 1
	WHEN GoodyHut = 'METEOR_GOODIES' THEN -1
	WHEN Weight = 0 THEN 0
	WHEN Weight >= 100 THEN 5
	WHEN Weight >= 55 THEN 1
	WHEN Weight >= 30 THEN 2
	WHEN Weight >= 10 THEN 3
	WHEN Weight >= 5 THEN 4
	WHEN Weight >= 1 THEN 5
	ELSE -1
END;

-- set Tier for all reward SubTypes, based on HostileModifier
UPDATE GoodyHutSubTypes
SET Tier = CASE
	WHEN HostileModifier = 0 THEN '''DISABLED'''
	WHEN HostileModifier = 1 THEN 'Common'
	WHEN HostileModifier = 2 THEN 'Uncommon'
	WHEN HostileModifier = 3 THEN 'Rare'
	WHEN HostileModifier = 4 THEN 'Legendary'
	WHEN HostileModifier = 5 THEN 'Mythic'
	ELSE '''INVALID'''
END;

-- populate HostileUnits table by copying wholesale from UnitRewards table
REPLACE INTO HostileUnits SELECT * FROM UnitRewards;

-- adjust HostileUnits "rewards" for specific game Eras here
UPDATE HostileUnits SET HeavyCavalry = 'UNIT_BARBARIAN_HORSEMAN', LightCavalry = 'UNIT_BARBARIAN_HORSE_ARCHER' WHERE Era = 0;

-- populate GoodyHutsByHash with all available Types; Hash values for each Type will be automatically calculated as they are added
INSERT INTO GoodyHutsByHash (GoodyHutType) SELECT GoodyHutType FROM GoodyHuts;

-- update GoodyHuts with the Hash values calculated above; this is stupid, but to my knowledge, required to reference Type to Hash and vice versa
UPDATE GoodyHuts SET Hash = (SELECT Hash FROM GoodyHutsByHash WHERE GoodyHutsByHash.GoodyHutType = GoodyHuts.GoodyHutType);

-- populate GoodyHutSubTypesByHash with all available SubTypes; Hash values for each SubType will be automatically calculated as they are added
INSERT INTO GoodyHutSubTypesByHash (SubTypeGoodyHut) SELECT SubTypeGoodyHut FROM GoodyHutSubTypes;

-- update GoodyHutSubTypes with the Hash values calculated above; this is stupid, but to my knowledge, required to reference SubType to Hash and vice versa
UPDATE GoodyHutSubTypes SET Hash = (SELECT Hash FROM GoodyHutSubTypesByHash WHERE GoodyHutSubTypesByHash.SubTypeGoodyHut = GoodyHutSubTypes.SubTypeGoodyHut);

/* ###########################################################################
    End EGHV ingame configuration
########################################################################### */
