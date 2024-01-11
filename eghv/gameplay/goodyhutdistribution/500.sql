/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2023 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV ingame Goody Hut frequency configuration
########################################################################### */

-- set Goody Hut distribution to 500% of normal; default : TilesPerGoody = 128, GoodyRange = 3
UPDATE Improvements	SET TilesPerGoody = 8, GoodyRange = 1 WHERE ImprovementType = 'IMPROVEMENT_GOODY_HUT';

/* ###########################################################################
    end EGHV ingame Goody Hut frequency configuration
########################################################################### */
