/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin user setup for EGHV compatibility
	if your mod
		(1) adds Goody Huts, and/or
		(2) adds any other picker content, and/or
		(3) should be reflected in the dynamic tooltip of any picker,
	then start here:
		1. Copy this file to the desired location within your mod. Rename it to
			whatever you wish. Add it to your mod's .modinfo file within <Files>
		2. Add the file to your mod's .modinfo file using an <UpdateDatabase> tag
			within <FrontEndActions>. Ensure that this action has a defined
			LoadOrder < 1010171, or EGHV may not accurately obtain necessary data
		3. Follow further directions below as required for your mod
########################################################################### */

/* ###########################################################################
    Configuration database schema : table definitions for C6GUE
	if any C6GUE components are present, these will be ignored
	if NO components of C6GUE are present, the tables defined below will be
		(1) created,
		(2) populated, and
		(3) otherwise unused
	This is to avoid unnecessary errors in Database.log
	These should generally be left alone
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

/* ###########################################################################
    Configuration database schema : table definitions for EGHV
	if EGHV is present, these will be ignored
	if EGHV is NOT present, the tables defined below will be
		(1) created,
		(2) populated, and
		(3) otherwise unused
	This is to avoid unnecessary errors in Database.log
	These should generally be left alone
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

/* ###########################################################################
    ContentFlags
	Uncomment the query below and modify as needed if you want your mod to be
		reflected in the dynamic tooltip of any picker(s)
	Numeric values here should be booleans, but SQLite is dumb, so use a value x
		where x > 0 for true; x <= 0 will be treated as false
	Don't forget to define the indicated tooltip tag(s) in the localization database
########################################################################### */

-- INSERT INTO ContentFlags (Name, Id, CityStates, GoodyHuts, Leaders, NaturalWonders, SQL, Tooltip)
-- VALUES 
-- 	('Dummy', 'DUMMY1', 0, 0, 0, 0, 'SELECT * FROM Parameters WHERE ParameterId = ''Ruleset''', 'LOC_DUMMY_TT');

INSERT INTO ContentFlags (Name, Id, CityStates, GoodyHuts, Leaders, NaturalWonders, SQL, Tooltip)
VALUES 
	('WondrousGoodyHuts', 'WGH', 0, 1, 0, 0, 'SELECT * FROM SailorGoodyOptions', '[NEWLINE]LOC_WGH_TT');

/* ###########################################################################
    Goody Hut picker configuration : StandardGoodyHuts
	Uncomment the query below and modify as needed if your mod adds Goody Huts
		that are available in Standard ruleset and beyond
	Ensure that the necessary localization tags are defined, and if EGHV is
		enabled, it will handle the rest
########################################################################### */

-- REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon)
-- VALUES
--     ('GOODYHUT_DUMMY', 'LOC_EGHV_GOODYHUT_DUMMY_CONFIG_NAME', 'GOODYHUT_DUMMY_REWARD', 'LOC_EGHV_GOODYHUT_DUMMY_CONFIG_DESCRIPTION', 'ICON_DISTRICT_HARBOR');

REPLACE INTO EGHV_StandardGoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon)
VALUES
	('GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_RANDOMRESOURCE', 'GOODYHUT_SAILOR_RANDOMRESOURCE', 'LOC_GOODYHUT_SAILOR_RANDOMRESOURCE', 'ICON_DISTRICT_WONDER'),
	('GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_RANDOMUNIT', 'GOODYHUT_SAILOR_RANDOMUNIT', 'LOC_GOODYHUT_SAILOR_RANDOMUNIT', 'ICON_DISTRICT_WONDER'),
	('GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_RANDOMIMPROVEMENT', 'GOODYHUT_SAILOR_RANDOMIMPROVEMENT', 'LOC_GOODYHUT_SAILOR_RANDOMIMPROVEMENT', 'ICON_DISTRICT_WONDER'),
	('GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_SIGHTBOMB', 'GOODYHUT_SAILOR_SIGHTBOMB', 'LOC_GOODYHUT_SAILOR_SIGHTBOMB', 'ICON_DISTRICT_WONDER'),
	('GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_RANDOMPOLICY', 'GOODYHUT_SAILOR_RANDOMPOLICY', 'LOC_GOODYHUT_SAILOR_RANDOMPOLICY', 'ICON_DISTRICT_WONDER'),
	('GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_FORMATION', 'GOODYHUT_SAILOR_FORMATION', 'LOC_GOODYHUT_SAILOR_FORMATION', 'ICON_DISTRICT_WONDER'),
	('GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_WONDER', 'GOODYHUT_SAILOR_WONDER', 'LOC_GOODYHUT_SAILOR_WONDER', 'ICON_DISTRICT_WONDER'),
	('GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_CITYSTATE', 'GOODYHUT_SAILOR_CITYSTATE', 'LOC_GOODYHUT_SAILOR_CITYSTATE', 'ICON_DISTRICT_WONDER'),
	('GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_SPY', 'GOODYHUT_SAILOR_SPY', 'LOC_GOODYHUT_SAILOR_SPY', 'ICON_DISTRICT_WONDER'),
	('GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_PRODUCTION', 'GOODYHUT_SAILOR_PRODUCTION', 'LOC_GOODYHUT_SAILOR_PRODUCTION', 'ICON_DISTRICT_WONDER'),
    ('GOODYHUT_SAILOR_WONDROUS', 'LOC_GOODYHUT_SAILOR_TELEPORT', 'GOODYHUT_SAILOR_TELEPORT', 'LOC_GOODYHUT_SAILOR_TELEPORT', 'ICON_DISTRICT_WONDER');

/* ###########################################################################
    Goody Hut picker configuration : Expansion1GoodyHuts
	Uncomment the query below and modify as needed if your mod adds Goody Huts
		that are available only in Expansion1 ruleset and beyond
	Ensure that the necessary localization tags are defined, and if EGHV is
		enabled, it will handle the rest
########################################################################### */

-- REPLACE INTO EGHV_Expansion1GoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon)
-- VALUES
--     ('GOODYHUT_DUMMY', 'LOC_EGHV_GOODYHUT_DUMMY_CONFIG_NAME', 'GOODYHUT_DUMMY_REWARD', 'LOC_EGHV_GOODYHUT_DUMMY_CONFIG_DESCRIPTION', 'ICON_DISTRICT_HARBOR');

/* ###########################################################################
    Goody Hut picker configuration : Expansion2GoodyHuts
	Uncomment the query below and modify as needed if your mod adds Goody Huts
		that are available only in Expansion2 ruleset and beyond
	Ensure that the necessary localization tags are defined, and if EGHV is
		enabled, it will handle the rest
########################################################################### */

-- REPLACE INTO EGHV_Expansion2GoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon)
-- VALUES
--     ('GOODYHUT_DUMMY', 'LOC_EGHV_GOODYHUT_DUMMY_CONFIG_NAME', 'GOODYHUT_DUMMY_REWARD', 'LOC_EGHV_GOODYHUT_DUMMY_CONFIG_DESCRIPTION', 'ICON_DISTRICT_HARBOR');

/* ###########################################################################
    end user setup for EGHV compatibility
########################################################################### */
