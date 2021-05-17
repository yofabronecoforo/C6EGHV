/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV frontend schema
########################################################################### */

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
