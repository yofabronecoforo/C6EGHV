/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV equalize Goody Hut configuration
    this will be loaded if :
        (1) Advanced Setup option 'Equalize Goody Huts' is enabled, and
        (2) Expansion 2 ruleset is in-use
########################################################################### */

-- Equalize Expansion 2 subtypes here
UPDATE GoodyHutSubTypes SET Weight = 20 WHERE GoodyHut = 'GOODYHUT_DIPLOMACY';

-- Next, reset built-in type weights based on the updated sums of the subtypes of each type
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_DIPLOMACY') WHERE GoodyHutType = 'GOODYHUT_DIPLOMACY';

-- Finally, reset the meteor strike "reward" type weight equal to that of GOODYHUT_MILITARY, and its subtype weight equal to same
UPDATE GoodyHuts SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_MILITARY') WHERE GoodyHutType = 'METEOR_GOODIES';
UPDATE GoodyHutSubTypes SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'METEOR_GOODIES') WHERE SubTypeGoodyHut = 'METEOR_GRANT_GOODIES';

/* ###########################################################################
    end EGHV equalize Goody Hut configuration
########################################################################### */
