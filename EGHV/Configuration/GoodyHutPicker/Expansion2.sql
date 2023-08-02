/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2023 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV frontend configuration
########################################################################### */

-- configure the Expansion2GoodyHuts transition table
REPLACE INTO EGHV_Expansion2GoodyHuts SELECT 'Expansion2GoodyHuts' AS Domain, SubTypeGoodyHut, Name, GoodyHut, Description, Weight, Icon, SortIndex FROM EGHV_StandardGoodyHuts;
REPLACE INTO EGHV_Expansion2GoodyHuts SELECT 'Expansion2GoodyHuts' AS Domain, SubTypeGoodyHut, Name, GoodyHut, Description, Weight, Icon, SortIndex FROM EGHV_Expansion1GoodyHuts;

-- add new reward types for this ruleset to the transition table
REPLACE INTO EGHV_Expansion2GoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon, SortIndex)
VALUES
    -- Secrets : favor villager totem
    ('GOODYHUT_SECRETS', 'LOC_EGHV_GOODYHUT_VILLAGER_SECRETS_FAVOR_NAME', 'GOODYHUT_VILLAGER_SECRETS_FAVOR', 'LOC_EGHV_GOODYHUT_VILLAGER_SECRETS_FAVOR_DESC', 'ICON_EGHV_TOTEM_FAVOR', 500),
    -- EGHV : diplomacy type
    ('GOODYHUT_DIPLOMACY', 'LOC_EGHV_GOODYHUT_SMALL_FAVOR_NAME', 'GOODYHUT_SMALL_FAVOR', 'LOC_EGHV_GOODYHUT_SMALL_FAVOR_DESC', 'ICON_EGHV_SMALL_FAVOR', 100),
    ('GOODYHUT_DIPLOMACY', 'LOC_EGHV_GOODYHUT_MEDIUM_FAVOR_NAME', 'GOODYHUT_MEDIUM_FAVOR', 'LOC_EGHV_GOODYHUT_MEDIUM_FAVOR_DESC', 'ICON_EGHV_MEDIUM_FAVOR', 200),
    ('GOODYHUT_DIPLOMACY', 'LOC_EGHV_GOODYHUT_LARGE_FAVOR_NAME', 'GOODYHUT_LARGE_FAVOR', 'LOC_EGHV_GOODYHUT_LARGE_FAVOR_DESC', 'ICON_EGHV_LARGE_FAVOR', 300),
    ('GOODYHUT_DIPLOMACY', 'LOC_EGHV_GOODYHUT_HUGE_FAVOR_NAME', 'GOODYHUT_HUGE_FAVOR', 'LOC_EGHV_GOODYHUT_HUGE_FAVOR_DESC', 'ICON_EGHV_HUGE_FAVOR', 400),
    -- EGHV : resources type
    ('GOODYHUT_RESOURCES', 'LOC_EGHV_GOODYHUT_SMALL_RESOURCES_NAME', 'GOODYHUT_SMALL_RESOURCES', 'LOC_EGHV_GOODYHUT_SMALL_RESOURCES_DESC', 'ICON_EGHV_SMALL_RESOURCES', 100),
    ('GOODYHUT_RESOURCES', 'LOC_EGHV_GOODYHUT_MEDIUM_RESOURCES_NAME', 'GOODYHUT_MEDIUM_RESOURCES', 'LOC_EGHV_GOODYHUT_MEDIUM_RESOURCES_DESC', 'ICON_EGHV_MEDIUM_RESOURCES', 200),
    ('GOODYHUT_RESOURCES', 'LOC_EGHV_GOODYHUT_LARGE_RESOURCES_NAME', 'GOODYHUT_LARGE_RESOURCES', 'LOC_EGHV_GOODYHUT_LARGE_RESOURCES_DESC', 'ICON_EGHV_LARGE_RESOURCES', 300),
    ('GOODYHUT_RESOURCES', 'LOC_EGHV_GOODYHUT_HUGE_RESOURCES_NAME', 'GOODYHUT_HUGE_RESOURCES', 'LOC_EGHV_GOODYHUT_HUGE_RESOURCES_DESC', 'ICON_EGHV_HUGE_RESOURCES', 400),
    -- meteor type
    ('METEOR_GOODIES', 'LOC_EGHV_GOODYHUT_METEOR_GRANT_GOODIES_NAME', 'METEOR_GRANT_GOODIES', 'LOC_EGHV_GOODYHUT_METEOR_GRANT_GOODIES_DESC', 'ICON_EGHV_METEOR_STRIKE', 500);

-- configure the Goody Hut picker for Gathering Storm ruleset
REPLACE INTO TribalVillages SELECT * FROM EGHV_Expansion2GoodyHuts;

/* ###########################################################################
    end EGHV frontend configuration
########################################################################### */
