/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV frontend schema
########################################################################### */

-- Define table for flagging the presence of available additional content
CREATE TABLE IF NOT EXISTS 'ContentFlags' (
    'Name' TEXT NOT NULL,
	'Id' TEXT NOT NULL,
	'CityStates' INTEGER NOT NULL DEFAULT 0,
	'GoodyHuts' INTEGER NOT NULL DEFAULT 0,
    'Leaders' INTEGER NOT NULL DEFAULT 0,
	'NaturalWonders' INTEGER NOT NULL DEFAULT 0,
    'SQL' TEXT NOT NULL,
	'Tooltip' TEXT NOT NULL,
	PRIMARY KEY('Name')
);

-- Define official content flags here; doing so greatly simplifies lua implementation
INSERT INTO ContentFlags (Name, Id, CityStates, GoodyHuts, Leaders, NaturalWonders, SQL, Tooltip) VALUES 
	('DLC_Aztec', 'DLC01', 0, 0, 1, 0, 'SELECT * FROM Players WHERE CivilizationType = ''CIVILIZATION_AZTEC''', 'LOC_DLC_AZTEC_TT'),
	('DLC_Poland', 'DLC02', 0, 0, 1, 0, 'SELECT * FROM Players WHERE CivilizationType = ''CIVILIZATION_POLAND''', 'LOC_DLC_POLAND_TT'),
	('DLC_Vikings', 'DLC03', 1, 0, 1, 1, 'SELECT * FROM Players WHERE CivilizationType = ''CIVILIZATION_NORWAY''', 'LOC_DLC_VIKINGS_TT'),
	('DLC_Australia', 'DLC04', 0, 0, 1, 1, 'SELECT * FROM Players WHERE CivilizationType = ''CIVILIZATION_AUSTRALIA''', 'LOC_DLC_AUSTRALIA_TT'),
	('DLC_Persia', 'DLC05', 0, 0, 1, 0, 'SELECT * FROM Players WHERE CivilizationType = ''CIVILIZATION_PERSIA''', 'LOC_DLC_PERSIA_TT'),
	('DLC_Nubia', 'DLC06', 0, 0, 1, 0, 'SELECT * FROM Players WHERE CivilizationType = ''CIVILIZATION_NUBIA''', 'LOC_DLC_NUBIA_TT'),
	('DLC_Khmer', 'DLC07', 0, 0, 1, 1, 'SELECT * FROM Players WHERE CivilizationType = ''CIVILIZATION_KHMER''', 'LOC_DLC_KHMER_TT'),
	('DLC_Maya', 'DLC08', 1, 0, 1, 1, 'SELECT * FROM Players WHERE CivilizationType = ''CIVILIZATION_MAYA''', 'LOC_DLC_MAYA_TT'),
	('DLC_Ethiopia', 'DLC09', 0, 0, 1, 0, 'SELECT * FROM Players WHERE CivilizationType = ''CIVILIZATION_ETHIOPIA''', 'LOC_DLC_ETHIOPIA_TT'),
	('DLC_Byzantium', 'DLC10', 0, 0, 1, 0, 'SELECT * FROM Players WHERE CivilizationType = ''CIVILIZATION_BYZANTIUM''', 'LOC_DLC_BYZANTIUM_TT'),
	('DLC_Babylon', 'DLC11', 1, 0, 1, 0, 'SELECT * FROM Players WHERE CivilizationType = ''CIVILIZATION_BABYLON_STK''', 'LOC_DLC_BABYLON_STK_TT'),
	('DLC_Vietnam', 'DLC12', 0, 0, 1, 0, 'SELECT * FROM Players WHERE CivilizationType = ''CIVILIZATION_VIETNAM''', 'LOC_DLC_VIETNAM_TT'),
	('DLC_Portugal', 'DLC13', 0, 0, 1, 0, 'SELECT * FROM Players WHERE CivilizationType = ''CIVILIZATION_PORTUGAL''', 'LOC_DLC_PORTUGAL_TT'),
    ('Expansion1', 'XP1', 0, 0, 1, 1, 'SELECT * FROM GameCores WHERE GameCore = ''Expansion1''', 'LOC_XP1_TT'),
	('Expansion2', 'XP2', 1, 1, 1, 1, 'SELECT * FROM GameCores WHERE GameCore = ''Expansion2''', 'LOC_XP2_TT');

-- Define transition table for Standard Goody Huts
CREATE TABLE IF NOT EXISTS 'EGHV_StandardGoodyHuts' (
    'Domain' TEXT DEFAULT 'StandardGoodyHuts',
	'SubTypeGoodyHut' TEXT NOT NULL,
    'Name' TEXT NOT NULL,
	'GoodyHut' TEXT NOT NULL,
	'Description' TEXT,
	'Weight' INTEGER,
    'Icon' TEXT,
	'SortIndex' INTEGER,
	PRIMARY KEY ('Domain','SubTypeGoodyHut')
);

-- Define transition table for Expansion 1 Goody Huts
CREATE TABLE IF NOT EXISTS 'EGHV_Expansion1GoodyHuts' (
    'Domain' TEXT DEFAULT 'Expansion1GoodyHuts',
	'SubTypeGoodyHut' TEXT NOT NULL,
    'Name' TEXT NOT NULL,
	'GoodyHut' TEXT NOT NULL,
	'Description' TEXT,
	'Weight' INTEGER,
    'Icon' TEXT,
	'SortIndex' INTEGER,
	PRIMARY KEY ('Domain','SubTypeGoodyHut')
);

-- Define transition table for Expansion 2 Goody Huts
CREATE TABLE IF NOT EXISTS 'EGHV_Expansion2GoodyHuts' (
    'Domain' TEXT DEFAULT 'Expansion2GoodyHuts',
	'SubTypeGoodyHut' TEXT NOT NULL,
    'Name' TEXT NOT NULL,
	'GoodyHut' TEXT NOT NULL,
	'Description' TEXT,
	'Weight' INTEGER,
    'Icon' TEXT,
	'SortIndex' INTEGER,
	PRIMARY KEY ('Domain','SubTypeGoodyHut')
);

-- Define table for the Goody Huts picker
CREATE TABLE IF NOT EXISTS 'TribalVillages' (
    'Domain' TEXT NOT NULL,
	'SubTypeGoodyHut' TEXT NOT NULL,
    'Name' TEXT NOT NULL,
	'GoodyHut' TEXT NOT NULL,
	'Description' TEXT,
	'Weight' INTEGER,
    'Icon' TEXT,
	'SortIndex' INTEGER,
	PRIMARY KEY ('Domain','SubTypeGoodyHut')
);

/* ###########################################################################
    end EGHV frontend schema
########################################################################### */
