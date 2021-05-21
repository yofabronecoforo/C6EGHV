/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV frontend configuration
########################################################################### */

-- configure the Expansion1GoodyHuts transition table
INSERT INTO EGHV_Expansion1GoodyHuts SELECT 'Expansion1GoodyHuts' AS Domain, SubTypeGoodyHut, Name, GoodyHut, Description, Weight, Icon, SortIndex FROM EGHV_StandardGoodyHuts;

-- configure the Goody Hut picker for Rise and Fall ruleset
INSERT INTO TribalVillages SELECT * FROM EGHV_Expansion1GoodyHuts;
    
/* ###########################################################################
    end EGHV frontend configuration
########################################################################### */
