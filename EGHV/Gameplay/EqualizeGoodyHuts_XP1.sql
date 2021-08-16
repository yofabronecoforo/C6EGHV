/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV equalize Goody Hut configuration
    this will be loaded if :
        (1) Advanced Setup option 'Equalize Goody Huts' is enabled, and
        (2) Expansion 1 ruleset is in-use
    subtype weights for enabled reward(s) within a type will we equalized below
########################################################################### */

-- resources EGHV type
UPDATE GoodyHutSubTypes 
SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_GOVERNORS') / (SELECT COUNT(*) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_GOVERNORS' AND NOT Weight = 0) 
WHERE GoodyHut = 'GOODYHUT_GOVERNORS' AND NOT Weight = 0;

/* ###########################################################################
    end EGHV equalize Goody Hut configuration
########################################################################### */
