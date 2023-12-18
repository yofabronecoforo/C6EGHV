/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2023 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV gameplay schema
########################################################################### */

-- goody hut types for RewardGenerator
CREATE TABLE IF NOT EXISTS GoodyHuts_EGHV (
    'GoodyHutType' TEXT NOT NULL,
    'Weight' INTEGER NOT NULL,
    'Hash' INTEGER,
    PRIMARY KEY('GoodyHutType')
);

-- goody hut rewards for RewardGenerator
CREATE TABLE IF NOT EXISTS GoodyHutSubTypes_EGHV (
    'GoodyHut' TEXT NOT NULL,
    'SubTypeGoodyHut' TEXT NOT NULL UNIQUE,
    'Weight' INTEGER NOT NULL,
    'MinTurn' INTEGER NOT NULL DEFAULT 0,
    'Description' TEXT,
    'ModifierID' TEXT,
    'MinOneCity' BOOLEAN NOT NULL CHECK (MinOneCity IN (0,1)) DEFAULT 0,
    'RequiresUnit' BOOLEAN NOT NULL CHECK (RequiresUnit IN (0,1)) DEFAULT 0,
    -- 'Heal' INTEGER NOT NULL DEFAULT 0,
    'Relic' BOOLEAN NOT NULL CHECK (Relic IN (0,1)) DEFAULT 0,
    -- 'Trader' BOOLEAN NOT NULL CHECK (Trader IN (0,1)) DEFAULT 0,
    'PrereqCivic' TEXT,
    'PrereqTech1' TEXT,
    'PrereqTech2' TEXT,
    'OncePerEra' BOOLEAN NOT NULL CHECK (OncePerEra IN (0,1)) DEFAULT 0,
    'Unit' BOOLEAN NOT NULL CHECK (Unit IN (0,1)) DEFAULT 0,
    'UnitAbility' TEXT,
    'UnitClass' TEXT,
    'UnitType' TEXT,
    'UpgradeUnit' BOOLEAN NOT NULL CHECK (UpgradeUnit IN (0,1)) DEFAULT 0,
    'Experience' BOOLEAN NOT NULL CHECK (Experience IN (0,1)) DEFAULT 0,
    'ExperienceMultiplier' REAL,
    'Tier' INTEGER,
    'TierType' TEXT,
    'Hostile' BOOLEAN NOT NULL CHECK (Hostile IN (0,1)) DEFAULT 0,
    'Fallback' BOOLEAN NOT NULL CHECK (Fallback IN (0,1)) DEFAULT 0,
    'Hash' INTEGER,
    PRIMARY KEY('SubTypeGoodyHut')
);

-- per-Era Unit rewards
CREATE TABLE IF NOT EXISTS UnitRewards (
    'Era' INTEGER NOT NULL DEFAULT 0,
	'Recon' TEXT NOT NULL,
    'Melee' TEXT NOT NULL,
    'Ranged' TEXT NOT NULL,
    'AntiCavalry' TEXT NOT NULL,
    'HeavyCavalry' TEXT NOT NULL,
    'LightCavalry' TEXT NOT NULL,
    'Siege' TEXT NOT NULL,
    'Support' TEXT NOT NULL,
    'NavalMelee' TEXT NOT NULL,
    'NavalRanged' TEXT NOT NULL,
	PRIMARY KEY('Era')
);

-- Hostile Unit "rewards"
CREATE TABLE IF NOT EXISTS HostileUnits AS SELECT * FROM UnitRewards;

-- 
CREATE TABLE IF NOT EXISTS PromotionLevels (
    'XPFNL' INTEGER NOT NULL,
    'Level' INTEGER NOT NULL,
    'XPTNL' INTEGER NOT NULL,
    PRIMARY KEY('XPFNL')
);

-- units that increase the chance of encountering hostiles after reward
CREATE TABLE IF NOT EXISTS IncreasedHostilityTargets (
	'UnitType' TEXT NOT NULL,
	PRIMARY KEY('UnitType')
);

-- units that decrease the chance of encountering hostiles after reward
CREATE TABLE IF NOT EXISTS DecreasedHostilityTargets (
	'PromotionClass' TEXT NOT NULL,
	PRIMARY KEY('PromotionClass')
);

-- make a hash for each type inserted into GoodyHuts_EGHV
CREATE TRIGGER OnInsertIntoGoodyHuts_EGHV AFTER INSERT ON GoodyHuts_EGHV BEGIN
UPDATE GoodyHuts_EGHV SET Hash = Make_Hash(GoodyHutType) WHERE GoodyHutType = New.GoodyHutType;
END;

-- make a hash for each reward inserted into GoodyHutSubTypes_EGHV
CREATE TRIGGER OnInsertIntoGoodyHutSubTypes_EGHV AFTER INSERT ON GoodyHutSubTypes_EGHV BEGIN
UPDATE GoodyHutSubTypes_EGHV SET Hash = Make_Hash(SubTypeGoodyHut) WHERE SubTypeGoodyHut = New.SubTypeGoodyHut;
END;

/* ###########################################################################
    end EGHV gameplay schema
########################################################################### */
