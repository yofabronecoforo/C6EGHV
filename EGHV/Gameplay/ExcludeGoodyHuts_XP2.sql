/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2023 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV exclude Goody Hut configuration
    this will be loaded for Expansion 2 Ruleset if ANY Goody Hut(s) are excluded with the picker
    when the sum of the Weights of all Goody Hut subtypes of a parent Goody Hut type equals 0, 
        meaning that all such subtypes have been excluded,
        then the Weight of that parent type will also be set to 0, which should disable it
    otherwise, the Weight of the parent type will remain unchanged
########################################################################### */

-- diplomacy type (EGHV)
UPDATE GoodyHuts SET Weight = CASE
    WHEN (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_DIPLOMACY') = 0 THEN 0
    ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_DIPLOMACY')
    END
WHERE GoodyHutType = 'GOODYHUT_DIPLOMACY';

-- meteor type
UPDATE GoodyHuts SET Weight = CASE
    WHEN (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'METEOR_GOODIES') = 0 THEN 0
    ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'METEOR_GOODIES')
    END
WHERE GoodyHutType = 'METEOR_GOODIES';

-- resources type (EGHV)
UPDATE GoodyHuts SET Weight = CASE
    WHEN (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_RESOURCES') = 0 THEN 0
    ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_RESOURCES')
    END
WHERE GoodyHutType = 'GOODYHUT_RESOURCES';

/* ###########################################################################
    end EGHV exclude Goody Hut configuration
########################################################################### */
