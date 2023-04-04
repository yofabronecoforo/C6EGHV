/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV ingame Goody Hut frequency configuration
########################################################################### */

-- set Goody Hut distribution to 175% of normal; default : TilesPerGoody = 128
UPDATE Improvements	SET TilesPerGoody = 80 WHERE ImprovementType = 'IMPROVEMENT_GOODY_HUT';

/* ###########################################################################
    end EGHV ingame Goody Hut frequency configuration
########################################################################### */
