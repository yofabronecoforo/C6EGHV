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
	'CityStates' BOOLEAN NOT NULL CHECK (CityStates IN (0,1)) DEFAULT 0,
	'GoodyHuts' BOOLEAN NOT NULL CHECK (GoodyHuts IN (0,1)) DEFAULT 0,
    'Leaders' BOOLEAN NOT NULL CHECK (Leaders IN (0,1)) DEFAULT 0,
	'NaturalWonders' BOOLEAN NOT NULL CHECK (NaturalWonders IN (0,1)) DEFAULT 0,
    'Base' BOOLEAN NOT NULL CHECK (Base IN (0,1)) DEFAULT 0,
	'XP1' BOOLEAN NOT NULL CHECK (XP1 IN (0,1)) DEFAULT 0,
	'XP2' BOOLEAN NOT NULL CHECK (XP2 IN (0,1)) DEFAULT 0,
	'Tooltip' TEXT NOT NULL,
	PRIMARY KEY('Name')
);

/* ###########################################################################
    end C6GUE frontend configuration schema
########################################################################### */
