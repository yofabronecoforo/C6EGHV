/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV equalize Goody Hut configuration
    this will be loaded if :
        (1) Advanced Setup option 'Equalize Goody Huts' is enabled
########################################################################### */

-- Start with GOODYHUT_MILITARY types
UPDATE GoodyHutSubTypes SET Weight = 10 WHERE GoodyHut = 'GOODYHUT_MILITARY' AND NOT SubTypeGoodyHut = 'GOODYHUT_GRANT_UPGRADE' AND NOT SubTypeGoodyHut = 'GOODYHUT_HEAL';

-- Set other built-in types here
UPDATE GoodyHutSubTypes SET Weight = 20 WHERE GoodyHut = 'GOODYHUT_CULTURE';
UPDATE GoodyHutSubTypes SET Weight = 20 WHERE GoodyHut = 'GOODYHUT_FAITH';
UPDATE GoodyHutSubTypes SET Weight = 20 WHERE GoodyHut = 'GOODYHUT_GOLD';
UPDATE GoodyHutSubTypes SET Weight = 20 WHERE GoodyHut = 'GOODYHUT_SCIENCE';
UPDATE GoodyHutSubTypes SET Weight = 20 WHERE GoodyHut = 'GOODYHUT_SURVIVORS';

-- Next, reset built-in type weights based on the updated sums of the subtypes of each type
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_CULTURE') WHERE GoodyHutType = 'GOODYHUT_CULTURE';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_FAITH') WHERE GoodyHutType = 'GOODYHUT_FAITH';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_GOLD') WHERE GoodyHutType = 'GOODYHUT_GOLD';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_MILITARY') WHERE GoodyHutType = 'GOODYHUT_MILITARY';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SCIENCE') WHERE GoodyHutType = 'GOODYHUT_SCIENCE';
UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SURVIVORS') WHERE GoodyHutType = 'GOODYHUT_SURVIVORS';

-- Finally, set the hostile villagers "reward" type weight equal to that of GOODYHUT_MILITARY, and its subtype weight equal to same
UPDATE GoodyHuts SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_MILITARY') WHERE GoodyHutType = 'GOODYHUT_HOSTILES';
UPDATE GoodyHutSubTypes SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_HOSTILES') WHERE SubTypeGoodyHut = 'GOODYHUT_SPAWN_HOSTILE_VILLAGERS';

/* ###########################################################################
    end EGHV equalize Goody Hut configuration
########################################################################### */
