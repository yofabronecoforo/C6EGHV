/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV frontend configuration
########################################################################### */

-- configure the Expansion2GoodyHuts transition table
REPLACE INTO EGHV_Expansion2GoodyHuts SELECT 'Expansion2GoodyHuts' AS Domain, SubTypeGoodyHut, Name, GoodyHut, Description, Weight, Icon, SortIndex FROM EGHV_StandardGoodyHuts;
REPLACE INTO EGHV_Expansion2GoodyHuts SELECT 'Expansion2GoodyHuts' AS Domain, SubTypeGoodyHut, Name, GoodyHut, Description, Weight, Icon, SortIndex FROM EGHV_Expansion1GoodyHuts;

-- add new reward types for this ruleset to the transition table
REPLACE INTO EGHV_Expansion2GoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon)
VALUES
    -- EGHV : diplomacy type
    ('GOODYHUT_DIPLOMACY', 'LOC_EGHV_GOODYHUT_SMALL_FAVOR_NAME', 'GOODYHUT_SMALL_FAVOR', 'LOC_EGHV_GOODYHUT_SMALL_FAVOR_DESC', 'ICON_DISTRICT_CITY_CENTER'),
    ('GOODYHUT_DIPLOMACY', 'LOC_EGHV_GOODYHUT_MEDIUM_FAVOR_NAME', 'GOODYHUT_MEDIUM_FAVOR', 'LOC_EGHV_GOODYHUT_MEDIUM_FAVOR_DESC', 'ICON_DISTRICT_CITY_CENTER'),
    ('GOODYHUT_DIPLOMACY', 'LOC_EGHV_GOODYHUT_LARGE_FAVOR_NAME', 'GOODYHUT_LARGE_FAVOR', 'LOC_EGHV_GOODYHUT_LARGE_FAVOR_DESC', 'ICON_DISTRICT_CITY_CENTER'),
    ('GOODYHUT_DIPLOMACY', 'LOC_EGHV_GOODYHUT_HUGE_FAVOR_NAME', 'GOODYHUT_HUGE_FAVOR', 'LOC_EGHV_GOODYHUT_HUGE_FAVOR_DESC', 'ICON_DISTRICT_CITY_CENTER'),
    -- EGHV : resources type
    ('GOODYHUT_RESOURCES', 'LOC_EGHV_GOODYHUT_SMALL_RESOURCES_NAME', 'GOODYHUT_SMALL_RESOURCES', 'LOC_EGHV_GOODYHUT_SMALL_RESOURCES_DESC', 'ICON_RESOURCE_ALUMINUM'),
    ('GOODYHUT_RESOURCES', 'LOC_EGHV_GOODYHUT_MEDIUM_RESOURCES_NAME', 'GOODYHUT_MEDIUM_RESOURCES', 'LOC_EGHV_GOODYHUT_MEDIUM_RESOURCES_DESC', 'ICON_RESOURCE_ALUMINUM'),
    ('GOODYHUT_RESOURCES', 'LOC_EGHV_GOODYHUT_LARGE_RESOURCES_NAME', 'GOODYHUT_LARGE_RESOURCES', 'LOC_EGHV_GOODYHUT_LARGE_RESOURCES_DESC', 'ICON_RESOURCE_ALUMINUM'),
    ('GOODYHUT_RESOURCES', 'LOC_EGHV_GOODYHUT_HUGE_RESOURCES_NAME', 'GOODYHUT_HUGE_RESOURCES', 'LOC_EGHV_GOODYHUT_HUGE_RESOURCES_DESC', 'ICON_RESOURCE_ALUMINUM'),
    -- meteor type
    ('METEOR_GOODIES', 'LOC_EGHV_GOODYHUT_METEOR_GRANT_GOODIES_NAME', 'METEOR_GRANT_GOODIES', 'LOC_EGHV_GOODYHUT_METEOR_GRANT_GOODIES_DESC', 'ICON_DISTRICT_WONDER');

-- configure the Goody Hut picker for Gathering Storm ruleset
REPLACE INTO TribalVillages SELECT * FROM EGHV_Expansion2GoodyHuts;

/* ###########################################################################
    end EGHV frontend configuration
########################################################################### */
