/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2023 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV equalize Goody Hut configuration
    this will be loaded if :
        (1) Advanced Setup option 'Equalize Goody Huts' is enabled
    weights for enabled reward (sub)types will be equalized below
########################################################################### */

-- give all enabled reward types an identical weight value
UPDATE GoodyHuts_EGHV SET Weight = 100 WHERE Weight > 0;

-- give all enabled rewards an identical weight value
UPDATE GoodyHutSubTypes_EGHV SET Weight = 100 WHERE Weight > 0;

/* ###########################################################################
    end EGHV equalize Goody Hut configuration
########################################################################### */
