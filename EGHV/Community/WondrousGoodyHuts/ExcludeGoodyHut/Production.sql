/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV exclude Goody Hut configuration
########################################################################### */

-- 
UPDATE GoodyHutSubTypes SET Weight = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_SAILOR_PRODUCTION';
UPDATE GoodyHuts Set Weight = (SELECT CASE WHEN (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SAILOR_WONDROUS') = 0 THEN 0 ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_SAILOR_WONDROUS') END) WHERE GoodyHutType = 'GOODYHUT_SAILOR_WONDROUS';

/* ###########################################################################
    end EGHV exclude Goody Hut configuration
########################################################################### */
