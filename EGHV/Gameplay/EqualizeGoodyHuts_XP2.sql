/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2023 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV equalize Goody Hut configuration
    this will be loaded if :
        (1) Advanced Setup option 'Equalize Goody Huts' is enabled, and
        (2) Expansion 2 ruleset is in-use
    subtype weights for enabled reward(s) within a type will we equalized below
########################################################################### */

-- * * * 2023/03/03 - DEPRECATED * * *

-- diplomacy built-in type
-- UPDATE GoodyHutSubTypes 
-- SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_DIPLOMACY') / (SELECT COUNT(*) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_DIPLOMACY' AND NOT Weight = 0) 
-- WHERE GoodyHut = 'GOODYHUT_DIPLOMACY' AND NOT Weight = 0;

-- meteor strike built-in type
-- UPDATE GoodyHutSubTypes 
-- SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'METEOR_GOODIES') / (SELECT COUNT(*) FROM GoodyHutSubTypes WHERE GoodyHut = 'METEOR_GOODIES' AND NOT Weight = 0) 
-- WHERE GoodyHut = 'METEOR_GOODIES' AND NOT Weight = 0;

-- resources EGHV type
-- UPDATE GoodyHutSubTypes 
-- SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_RESOURCES') / (SELECT COUNT(*) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_RESOURCES' AND NOT Weight = 0) 
-- WHERE GoodyHut = 'GOODYHUT_RESOURCES' AND NOT Weight = 0;

-- Equalize Expansion 2 subtypes here
-- UPDATE GoodyHutSubTypes SET Weight = 20 WHERE GoodyHut = 'GOODYHUT_DIPLOMACY';

-- Next, reset built-in type weights based on the updated sums of the subtypes of each type
-- UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_DIPLOMACY') WHERE GoodyHutType = 'GOODYHUT_DIPLOMACY';

-- Finally, reset the meteor strike "reward" type weight equal to that of GOODYHUT_MILITARY, and its subtype weight equal to same
-- UPDATE GoodyHuts SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_MILITARY') WHERE GoodyHutType = 'METEOR_GOODIES';
-- UPDATE GoodyHutSubTypes SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'METEOR_GOODIES') WHERE SubTypeGoodyHut = 'METEOR_GRANT_GOODIES';

/* ###########################################################################
    end EGHV equalize Goody Hut configuration
########################################################################### */
