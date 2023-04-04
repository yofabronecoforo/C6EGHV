/* ###########################################################################
    C6GUE : Gameplay and Usability Enhancements for Civilization VI
    Copyright (c) 2020-2023 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin C6GUE frontend configuration schema
########################################################################### */

-- Define table for flagging the presence of available additional content
CREATE TABLE IF NOT EXISTS 'ContentFlags' (
	'Id' TEXT NOT NULL,
    'Name' TEXT NOT NULL,
	'GUID' TEXT NOT NULL,
	'CityStates' INTEGER NOT NULL DEFAULT 0,
	'GoodyHuts' INTEGER NOT NULL DEFAULT 0,
    'Leaders' INTEGER NOT NULL DEFAULT 0,
	'NaturalWonders' INTEGER NOT NULL DEFAULT 0,
    'Base' INTEGER NOT NULL DEFAULT 0,
	'XP1' INTEGER NOT NULL DEFAULT 0,
	'XP2' INTEGER NOT NULL DEFAULT 0,
	'Tooltip' TEXT NOT NULL,
	PRIMARY KEY('Name')
);

/* ###########################################################################
    end C6GUE frontend configuration schema
########################################################################### */
