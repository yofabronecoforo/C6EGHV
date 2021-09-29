/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV equalize Goody Hut configuration
    this will be loaded if :
        (1) Advanced Setup option 'Equalize Goody Huts' is enabled
    subtype weights for enabled reward(s) within a type will be equalized below
########################################################################### */

-- culture built-in type
UPDATE GoodyHutSubTypes 
SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_CULTURE') / (SELECT COUNT(*) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_CULTURE' AND NOT Weight = 0) 
WHERE GoodyHut = 'GOODYHUT_CULTURE' AND NOT Weight = 0;
-- faith built-in type
UPDATE GoodyHutSubTypes 
SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_FAITH') / (SELECT COUNT(*) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_FAITH' AND NOT Weight = 0) 
WHERE GoodyHut = 'GOODYHUT_FAITH' AND NOT Weight = 0;
-- gold built-in type
UPDATE GoodyHutSubTypes 
SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_GOLD') / (SELECT COUNT(*) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_GOLD' AND NOT Weight = 0) 
WHERE GoodyHut = 'GOODYHUT_GOLD' AND NOT Weight = 0;
-- military built-in type
UPDATE GoodyHutSubTypes 
SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_MILITARY') / (SELECT COUNT(*) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_MILITARY' AND NOT Weight = 0) 
WHERE GoodyHut = 'GOODYHUT_MILITARY' AND NOT Weight = 0;
-- science built-in type
UPDATE GoodyHutSubTypes 
SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_SCIENCE') / (SELECT COUNT(*) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SCIENCE' AND NOT Weight = 0) 
WHERE GoodyHut = 'GOODYHUT_SCIENCE' AND NOT Weight = 0;
-- survivors built-in type
UPDATE GoodyHutSubTypes 
SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_SURVIVORS') / (SELECT COUNT(*) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SURVIVORS' AND NOT Weight = 0) 
WHERE GoodyHut = 'GOODYHUT_SURVIVORS' AND NOT Weight = 0;

-- abilities EGHV type
UPDATE GoodyHutSubTypes 
SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_ABILITIES') / (SELECT COUNT(*) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_ABILITIES' AND NOT Weight = 0) 
WHERE GoodyHut = 'GOODYHUT_ABILITIES' AND NOT Weight = 0;
-- cavalry EGHV type
-- UPDATE GoodyHutSubTypes 
-- SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_CAVALRY') / (SELECT COUNT(*) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_CAVALRY' AND NOT Weight = 0) 
-- WHERE GoodyHut = 'GOODYHUT_CAVALRY' AND NOT Weight = 0;
-- envoys EGHV type
UPDATE GoodyHutSubTypes 
SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_ENVOYS') / (SELECT COUNT(*) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_ENVOYS' AND NOT Weight = 0) 
WHERE GoodyHut = 'GOODYHUT_ENVOYS' AND NOT Weight = 0;
-- hostiles EGHV type
UPDATE GoodyHutSubTypes 
SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_HOSTILES') / (SELECT COUNT(*) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_HOSTILES' AND NOT Weight = 0) 
WHERE GoodyHut = 'GOODYHUT_HOSTILES' AND NOT Weight = 0;
-- promotions EGHV type
UPDATE GoodyHutSubTypes 
SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_PROMOTIONS') / (SELECT COUNT(*) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_PROMOTIONS' AND NOT Weight = 0) 
WHERE GoodyHut = 'GOODYHUT_PROMOTIONS' AND NOT Weight = 0;
-- secrets EGHV type
-- UPDATE GoodyHutSubTypes 
-- SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_SECRETS') / (SELECT COUNT(*) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SECRETS' AND NOT Weight = 0) 
-- WHERE GoodyHut = 'GOODYHUT_SECRETS' AND NOT Weight = 0;
-- units EGHV type
-- UPDATE GoodyHutSubTypes 
-- SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_SUPPORT') / (SELECT COUNT(*) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SUPPORT' AND NOT Weight = 0) 
-- WHERE GoodyHut = 'GOODYHUT_SUPPORT' AND NOT Weight = 0;

-- Start with GOODYHUT_MILITARY types
-- UPDATE GoodyHutSubTypes SET Weight = 10 WHERE GoodyHut = 'GOODYHUT_MILITARY' AND NOT SubTypeGoodyHut = 'GOODYHUT_GRANT_UPGRADE' AND NOT SubTypeGoodyHut = 'GOODYHUT_HEAL';

-- Set other built-in types here
-- UPDATE GoodyHutSubTypes SET Weight = 20 WHERE GoodyHut = 'GOODYHUT_CULTURE';
-- UPDATE GoodyHutSubTypes SET Weight = 20 WHERE GoodyHut = 'GOODYHUT_FAITH';
-- UPDATE GoodyHutSubTypes SET Weight = 20 WHERE GoodyHut = 'GOODYHUT_GOLD';
-- UPDATE GoodyHutSubTypes SET Weight = 20 WHERE GoodyHut = 'GOODYHUT_SCIENCE';
-- UPDATE GoodyHutSubTypes SET Weight = 20 WHERE GoodyHut = 'GOODYHUT_SURVIVORS';

-- Next, reset built-in type weights based on the updated sums of the subtypes of each type
-- UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_CULTURE') WHERE GoodyHutType = 'GOODYHUT_CULTURE';
-- UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_FAITH') WHERE GoodyHutType = 'GOODYHUT_FAITH';
-- UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_GOLD') WHERE GoodyHutType = 'GOODYHUT_GOLD';
-- UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_MILITARY') WHERE GoodyHutType = 'GOODYHUT_MILITARY';
-- UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SCIENCE') WHERE GoodyHutType = 'GOODYHUT_SCIENCE';
-- UPDATE GoodyHuts SET Weight = (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SURVIVORS') WHERE GoodyHutType = 'GOODYHUT_SURVIVORS';

-- Finally, set the hostile villagers "reward" type weight equal to that of GOODYHUT_MILITARY, and its subtype weight equal to same
-- UPDATE GoodyHuts SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_MILITARY') WHERE GoodyHutType = 'GOODYHUT_HOSTILES';
-- UPDATE GoodyHutSubTypes SET Weight = (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_HOSTILES') WHERE SubTypeGoodyHut = 'GOODYHUT_SPAWN_HOSTILE_VILLAGERS';

/* ###########################################################################
    end EGHV equalize Goody Hut configuration
########################################################################### */
