/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2023 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV gameplay schema
########################################################################### */

-- 
ALTER TABLE GoodyHuts ADD Hash INTEGER;

-- add columns to the GoodyHutSubTypes table to specify the HostileModifier and Tier for each present subtype
ALTER TABLE GoodyHutSubTypes ADD HostileModifier INTEGER;
ALTER TABLE GoodyHutSubTypes ADD Tier TEXT;
ALTER TABLE GoodyHutSubTypes ADD Hash INTEGER;

-- 
CREATE TABLE IF NOT EXISTS 'DisabledGoodyHutSubTypes' (
	'GoodyHut' TEXT NOT NULL,
	'SubTypeGoodyHut' TEXT NOT NULL UNIQUE,
	'Description' TEXT,
	'Weight' INTEGER NOT NULL,
	'ModifierID' TEXT NOT NULL,
	'UpgradeUnit' BOOLEAN NOT NULL CHECK (UpgradeUnit IN (0,1)) DEFAULT 0,
	'Turn' INTEGER NOT NULL DEFAULT 0,
	'Experience' BOOLEAN NOT NULL CHECK (Experience IN (0,1)) DEFAULT 0,
	'Heal' INTEGER NOT NULL DEFAULT 0,
	'Relic' BOOLEAN NOT NULL CHECK (Relic IN (0,1)) DEFAULT 0,
	'Trader' BOOLEAN NOT NULL CHECK (Trader IN (0,1)) DEFAULT 0,
	'MinOneCity' BOOLEAN NOT NULL CHECK (MinOneCity IN (0,1)) DEFAULT 0,
	'RequiresUnit' BOOLEAN NOT NULL CHECK (RequiresUnit IN (0,1)) DEFAULT 0,
    'HostileModifier' INTEGER,
    'Tier' TEXT,
    'Hash' INTEGER,
    PRIMARY KEY('SubTypeGoodyHut')
);

-- this table references a Goody Hut Type to a calculated hash value returned by ingame Events
CREATE TABLE IF NOT EXISTS 'GoodyHutsByHash' (
	'GoodyHutType' TEXT NOT NULL,
	'Hash' INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY('Hash')
);

-- this table references a Goody Hut SubType to a calculated hash value returned by ingame Events
CREATE TABLE IF NOT EXISTS 'GoodyHutSubTypesByHash' (
	'SubTypeGoodyHut' TEXT NOT NULL,
	'Hash' INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY('Hash')
);

-- this table contains per-Era Unit rewards
CREATE TABLE IF NOT EXISTS 'UnitRewards' (
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

-- this table contains per-Era hostile Unit "rewards"
CREATE TABLE IF NOT EXISTS 'HostileUnits' (
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

-- trigger to automatically generate hash values for Goody Hut Types as they are added to the appropriate table
CREATE TRIGGER OnGoodyHutsByHashInsert AFTER INSERT ON GoodyHutsByHash BEGIN UPDATE GoodyHutsByHash SET Hash = Make_Hash(GoodyHutType) WHERE GoodyHutType = New.GoodyHutType; END;

-- trigger to automatically generate hash values for Goody Hut SubTypes as they are added to the appropriate table
CREATE TRIGGER OnGoodyHutSubTypesByHashInsert AFTER INSERT ON GoodyHutSubTypesByHash BEGIN UPDATE GoodyHutSubTypesByHash SET Hash = Make_Hash(SubTypeGoodyHut) WHERE SubTypeGoodyHut = New.SubTypeGoodyHut; END;

/* ###########################################################################
    end EGHV gameplay schema
########################################################################### */
