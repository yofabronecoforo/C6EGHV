/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV frontend configuration
########################################################################### */

-- configure the Expansion2GoodyHuts transition table
INSERT INTO EGHV_Expansion2GoodyHuts SELECT 'Expansion2GoodyHuts' AS Domain, SubTypeGoodyHut, Name, GoodyHut, Description, Weight, Icon, SortIndex FROM EGHV_StandardGoodyHuts;

-- add new reward types for this ruleset to the transition table
REPLACE INTO EGHV_Expansion2GoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon)
VALUES
    -- military type
    ('GOODYHUT_MILITARY', 'LOC_EGHV_GOODYHUT_MILITARY_RESOURCES_NAME', 'GOODYHUT_RESOURCES', 'LOC_EGHV_GOODYHUT_MILITARY_RESOURCES_DESC', 'ICON_DISTRICT_ENCAMPMENT'),
    -- meteor type
    ('METEOR_GOODIES', 'LOC_EGHV_GOODYHUT_METEOR_GRANT_GOODIES_NAME', 'METEOR_GRANT_GOODIES', 'LOC_EGHV_GOODYHUT_METEOR_GRANT_GOODIES_DESC', 'ICON_DISTRICT_WONDER'),
    -- diplomacy type
    ('GOODYHUT_DIPLOMACY', 'LOC_EGHV_GOODYHUT_DIPLOMACY_SMALL_BOOST_FAVOR_NAME', 'GOODYHUT_SMALL_BOOST_FAVOR', 'LOC_EGHV_GOODYHUT_DIPLOMACY_SMALL_BOOST_FAVOR_DESC', 'ICON_DISTRICT_CITY_CENTER'),
    ('GOODYHUT_DIPLOMACY', 'LOC_EGHV_GOODYHUT_DIPLOMACY_TWO_GOVERNOR_TITLES_NAME', 'GOODYHUT_TWO_GOVERNOR_TITLES', 'LOC_EGHV_GOODYHUT_DIPLOMACY_TWO_GOVERNOR_TITLES_DESC', 'ICON_DISTRICT_CITY_CENTER'),
    ('GOODYHUT_DIPLOMACY', 'LOC_EGHV_GOODYHUT_DIPLOMACY_TWO_ENVOYS_NAME', 'GOODYHUT_TWO_ENVOYS', 'LOC_EGHV_GOODYHUT_DIPLOMACY_TWO_ENVOYS_DESC', 'ICON_DISTRICT_CITY_CENTER'),
    ('GOODYHUT_DIPLOMACY', 'LOC_EGHV_GOODYHUT_DIPLOMACY_GOVERNOR_TITLE_NAME', 'GOODYHUT_GOVERNOR_TITLE', 'LOC_EGHV_GOODYHUT_DIPLOMACY_GOVERNOR_TITLE_DESC', 'ICON_DISTRICT_CITY_CENTER'),
    ('GOODYHUT_DIPLOMACY', 'LOC_EGHV_GOODYHUT_DIPLOMACY_ENVOY_NAME', 'GOODYHUT_ENVOY', 'LOC_EGHV_GOODYHUT_DIPLOMACY_ENVOY_DESC', 'ICON_DISTRICT_CITY_CENTER'),
    ('GOODYHUT_DIPLOMACY', 'LOC_EGHV_GOODYHUT_DIPLOMACY_FAVOR_NAME', 'GOODYHUT_FAVOR', 'LOC_EGHV_GOODYHUT_DIPLOMACY_FAVOR_DESC', 'ICON_DISTRICT_CITY_CENTER');

-- configure the Goody Hut picker for Gathering Storm ruleset
INSERT INTO TribalVillages SELECT * FROM EGHV_Expansion2GoodyHuts;

/* ###########################################################################
    end EGHV frontend configuration
########################################################################### */
