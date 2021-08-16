/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV exclude Goody Hut configuration
    this will be loaded if :
        (1) ANY Goody Hut(s) are excluded with the picker, and
        (2) the selected ruleset is Expansion 1 or beyond
########################################################################### */

-- refresh the overall weights of EGHV type(s) to account for any exclusions
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_GOVERNORS') WHERE GoodyHutType = 'GOODYHUT_GOVERNORS';

/* ###########################################################################
    end EGHV exclude Goody Hut configuration
########################################################################### */
