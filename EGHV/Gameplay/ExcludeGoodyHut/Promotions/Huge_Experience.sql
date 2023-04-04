/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV exclude Goody Hut configuration
########################################################################### */

-- exclude the grant huge experience subtype
UPDATE GoodyHutSubTypes SET Weight = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_HUGE_EXPERIENCE';

/* ###########################################################################
    end EGHV exclude Goody Hut configuration
########################################################################### */