/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV exclude Goody Hut configuration
    this will be loaded if :
        (1) ANY Goody Hut(s) are excluded with the picker, and
        (2) the selected ruleset is Expansion 2
########################################################################### */

-- refresh the overall weights of Expansion 2 type(s) to account for any exclusions
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_DIPLOMACY') WHERE GoodyHutType = 'GOODYHUT_DIPLOMACY';

-- refresh the overall weights of the meteor strike type to account for any exclusions
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'METEOR_GOODIES') WHERE GoodyHutType = 'METEOR_GOODIES';

-- refresh the overall weights of EGHV type(s) to account for any exclusions
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_RESOURCES') WHERE GoodyHutType = 'GOODYHUT_RESOURCES';

/* ###########################################################################
    end EGHV exclude Goody Hut configuration
########################################################################### */
