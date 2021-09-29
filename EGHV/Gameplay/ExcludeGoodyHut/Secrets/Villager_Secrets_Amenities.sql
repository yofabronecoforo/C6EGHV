/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV exclude Goody Hut configuration
########################################################################### */

-- exclude the unlock villager secrets subtype
UPDATE GoodyHutSubTypes SET Weight = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_VILLAGER_SECRETS_AMENITIES';
UPDATE GoodyHuts Set Weight = (SELECT CASE WHEN (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SECRETS') = 0 THEN 0 ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_SECRETS') END) WHERE GoodyHutType = 'GOODYHUT_SECRETS';

/* ###########################################################################
    end EGHV exclude Goody Hut configuration
########################################################################### */
