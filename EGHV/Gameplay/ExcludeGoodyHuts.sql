/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV exclude Goody Hut configuration
    this will be loaded if :
        (1) ANY Goody Hut(s) are excluded with the picker
########################################################################### */

-- refresh the overall weights of Standard type(s) to account for any exclusions
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_CULTURE') WHERE GoodyHutType = 'GOODYHUT_CULTURE';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_FAITH') WHERE GoodyHutType = 'GOODYHUT_FAITH';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_GOLD') WHERE GoodyHutType = 'GOODYHUT_GOLD';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_MILITARY') WHERE GoodyHutType = 'GOODYHUT_MILITARY';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SCIENCE') WHERE GoodyHutType = 'GOODYHUT_SCIENCE';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SURVIVORS') WHERE GoodyHutType = 'GOODYHUT_SURVIVORS';

-- refresh the overall weights of EGHV type(s) to account for any exclusions
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_ABILITIES') WHERE GoodyHutType = 'GOODYHUT_ABILITIES';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_CAVALRY') WHERE GoodyHutType = 'GOODYHUT_CAVALRY';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_ENVOYS') WHERE GoodyHutType = 'GOODYHUT_ENVOYS';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_HOSTILES') WHERE GoodyHutType = 'GOODYHUT_HOSTILES';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_PROMOTIONS') WHERE GoodyHutType = 'GOODYHUT_PROMOTIONS';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SECRETS') WHERE GoodyHutType = 'GOODYHUT_SECRETS';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SUPPORT') WHERE GoodyHutType = 'GOODYHUT_SUPPORT';

/* ###########################################################################
    end EGHV exclude Goody Hut configuration
########################################################################### */
