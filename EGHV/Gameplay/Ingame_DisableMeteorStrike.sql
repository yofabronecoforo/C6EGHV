/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2023 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    Begin EGHV ingame disable meteor strike configuration
########################################################################### */

-- disable the METEOR_GOODIES type
UPDATE GoodyHuts SET Weight = 0 WHERE GoodyHutType = 'METEOR_GOODIES';

-- disable the METEOR_GRANT_GOODIES subtype
UPDATE GoodyHutSubTypes SET Weight = 0 WHERE SubTypeGoodyHut = 'METEOR_GRANT_GOODIES';

/* ###########################################################################
    End EGHV ingame disable meteor strike configuration
########################################################################### */
