/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2023 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV frontend configuration
########################################################################### */

-- configure the Expansion1GoodyHuts transition table
REPLACE INTO EGHV_Expansion1GoodyHuts SELECT 'Expansion1GoodyHuts' AS Domain, SubTypeGoodyHut, Name, GoodyHut, Description, Weight, Icon, SortIndex FROM EGHV_StandardGoodyHuts;

-- add new reward types for this ruleset to the transition table
REPLACE INTO EGHV_Expansion1GoodyHuts (GoodyHut, Name, SubTypeGoodyHut, Description, Icon, SortIndex)
VALUES
    -- EGHV : governors type
    ('GOODYHUT_GOVERNORS', 'LOC_EGHV_GOODYHUT_ONE_GOVERNOR_TITLE_NAME', 'GOODYHUT_ONE_GOVERNOR_TITLE', 'LOC_EGHV_GOODYHUT_ONE_GOVERNOR_TITLE_DESC', 'ICON_EGHV_GOODYHUT_ONE_GOVERNOR_TITLE', 100),
    ('GOODYHUT_GOVERNORS', 'LOC_EGHV_GOODYHUT_TWO_GOVERNOR_TITLES_NAME', 'GOODYHUT_TWO_GOVERNOR_TITLES', 'LOC_EGHV_GOODYHUT_TWO_GOVERNOR_TITLES_DESC', 'ICON_EGHV_GOODYHUT_TWO_GOVERNOR_TITLES', 200),
    ('GOODYHUT_GOVERNORS', 'LOC_EGHV_GOODYHUT_THREE_GOVERNOR_TITLES_NAME', 'GOODYHUT_THREE_GOVERNOR_TITLES', 'LOC_EGHV_GOODYHUT_THREE_GOVERNOR_TITLES_DESC', 'ICON_EGHV_GOODYHUT_THREE_GOVERNOR_TITLES', 300),
    ('GOODYHUT_GOVERNORS', 'LOC_EGHV_GOODYHUT_FOUR_GOVERNOR_TITLES_NAME', 'GOODYHUT_FOUR_GOVERNOR_TITLES', 'LOC_EGHV_GOODYHUT_FOUR_GOVERNOR_TITLES_DESC', 'ICON_EGHV_GOODYHUT_FOUR_GOVERNOR_TITLES', 400);

-- configure the Goody Hut picker for Rise and Fall ruleset
REPLACE INTO TribalVillages SELECT * FROM EGHV_Expansion1GoodyHuts;
    
/* ###########################################################################
    end EGHV frontend configuration
########################################################################### */
