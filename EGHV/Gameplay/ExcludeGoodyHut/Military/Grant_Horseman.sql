/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2023 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV exclude Goody Hut configuration
########################################################################### */

-- exclude the grant light cavalry unit subtype
UPDATE GoodyHutSubTypes SET Weight = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_GRANT_HORSEMAN';

/* ###########################################################################
    end EGHV exclude Goody Hut configuration
########################################################################### */
