/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2023 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV exclude Goody Hut configuration
    this will be loaded for Expansion 1 and Expansion 2 Rulesets if ANY Goody Hut(s) are excluded with the picker
    when the sum of the Weights of all Goody Hut subtypes of a parent Goody Hut type equals 0, 
        meaning that all such subtypes have been excluded,
        then the Weight of that parent type will also be set to 0, which should disable it
    otherwise, the Weight of the parent type will remain unchanged
########################################################################### */

-- governors type (EGHV)
UPDATE GoodyHuts SET Weight = CASE
    WHEN (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_GOVERNORS') = 0 THEN 0
    ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_GOVERNORS')
    END
WHERE GoodyHutType = 'GOODYHUT_GOVERNORS';

/* ###########################################################################
    end EGHV exclude Goody Hut configuration
########################################################################### */
