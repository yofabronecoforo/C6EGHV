/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2023 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV exclude Goody Hut configuration
    this will be loaded for all Rulesets if ANY Goody Hut(s) are excluded with the picker
    when the sum of the Weights of all Goody Hut subtypes of a parent Goody Hut type equals 0, 
        meaning that all such subtypes have been excluded,
        then the Weight of that parent type will also be set to 0, which should disable it
    otherwise, the Weight of the parent type will remain unchanged
########################################################################### */

-- 
-- UPDATE GoodyHutSubTypes SET Weight = CASE
--     WHEN (SELECT GameConfiguration(EXCLUDE_GOODYHUT_ONE_GOODYHUT)) = 1 THEN 0
--     ELSE (SELECT Weight FROM GoodyHutSubTypes WHERE SubTypeGoodyHut = 'GOODYHUT_ONE_GOODYHUT')
-- WHERE SubTypeGoodyHut = 'GOODYHUT_ONE_GOODYHUT';

-- culture type
UPDATE GoodyHuts SET Weight = CASE
    WHEN (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_CULTURE') = 0 THEN 0
    ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_CULTURE')
    END
WHERE GoodyHutType = 'GOODYHUT_CULTURE';

-- faith type
UPDATE GoodyHuts SET Weight = CASE
    WHEN (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_FAITH') = 0 THEN 0
    ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_FAITH')
    END
WHERE GoodyHutType = 'GOODYHUT_FAITH';

-- gold type
UPDATE GoodyHuts SET Weight = CASE
    WHEN (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_GOLD') = 0 THEN 0
    ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_GOLD')
    END
WHERE GoodyHutType = 'GOODYHUT_GOLD';

-- military type
UPDATE GoodyHuts SET Weight = CASE
    WHEN (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_MILITARY') = 0 THEN 0
    ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_MILITARY')
    END
WHERE GoodyHutType = 'GOODYHUT_MILITARY';

-- science type
UPDATE GoodyHuts SET Weight = CASE
    WHEN (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SCIENCE') = 0 THEN 0
    ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_SCIENCE')
    END
WHERE GoodyHutType = 'GOODYHUT_SCIENCE';

-- survivors type
UPDATE GoodyHuts SET Weight = CASE
    WHEN (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SURVIVORS') = 0 THEN 0
    ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_SURVIVORS')
    END
WHERE GoodyHutType = 'GOODYHUT_SURVIVORS';

-- abilities type (EGHV)
UPDATE GoodyHuts SET Weight = CASE
    WHEN (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_ABILITIES') = 0 THEN 0
    ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_ABILITIES')
    END
WHERE GoodyHutType = 'GOODYHUT_ABILITIES';

-- envoys type (EGHV)
UPDATE GoodyHuts SET Weight = CASE
    WHEN (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_ENVOYS') = 0 THEN 0
    ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_ENVOYS')
    END
WHERE GoodyHutType = 'GOODYHUT_ENVOYS';

-- hostiles type (EGHV)
UPDATE GoodyHuts SET Weight = CASE
    WHEN (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_HOSTILES') = 0 THEN 0
    ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_HOSTILES')
    END
WHERE GoodyHutType = 'GOODYHUT_HOSTILES';

-- promotions type (EGHV)
UPDATE GoodyHuts SET Weight = CASE
    WHEN (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_PROMOTIONS') = 0 THEN 0
    ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_PROMOTIONS')
    END
WHERE GoodyHutType = 'GOODYHUT_PROMOTIONS';

-- secrets type (EGHV)
UPDATE GoodyHuts SET Weight = CASE
    WHEN (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SECRETS') = 0 THEN 0
    ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_SECRETS')
    END
WHERE GoodyHutType = 'GOODYHUT_SECRETS';

/* ###########################################################################
    end EGHV exclude Goody Hut configuration
########################################################################### */
