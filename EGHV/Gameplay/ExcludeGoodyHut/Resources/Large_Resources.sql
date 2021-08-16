/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV exclude Goody Hut configuration
########################################################################### */

-- exclude the grant large strategic resources subtype
UPDATE GoodyHutSubTypes SET Weight = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_LARGE_RESOURCES';

/* ###########################################################################
    end EGHV exclude Goody Hut configuration
########################################################################### */