/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    Begin EGHV ingame configuration override; for debugging and testing
########################################################################### */

/* ###########################################################################
    GoodyHuts weights
    first line : globally reset all GoodyHuts weights
    second line : set weight of specific GoodyHutType; valid options (* requires Gathering Storm ruleset) :
        GOODYHUT_CULTURE
        GOODYHUT_FAITH
        GOODYHUT_GOLD
        GOODYHUT_MILITARY
        GOODYHUT_SCIENCE
        GOODYHUT_SURVIVORS
        * GOODYHUT_DIPLOMACY
        GOODYHUT_HOSTILES
########################################################################### */

-- UPDATE GoodyHuts SET Weight = 0;
-- UPDATE GoodyHuts SET Weight = 127 WHERE GoodyHutType = 'GOODYHUT_HOSTILES';

/* ###########################################################################
    GoodyHutSubTypes weights
    first line : globally reset all GoodyHutSubTypes weights
    second line : set weight of specific SubTypeGoodyHut; valid options (* requires Gathering Storm ruleset) :
        GOODYHUT_ONE_CIVIC_BOOST                GOODYHUT_SMALL_FAITH                    GOODYHUT_SMALL_GOLD
        GOODYHUT_TWO_CIVIC_BOOSTS               GOODYHUT_MEDIUM_FAITH                   GOODYHUT_MEDIUM_GOLD
        GOODYHUT_ONE_CIVIC                      GOODYHUT_LARGE_FAITH                    GOODYHUT_LARGE_GOLD
        GOODYHUT_TWO_CIVICS                     GOODYHUT_ONE_RELIC                      GOODYHUT_ADD_TRADE_ROUTE
        GOODYHUT_SMALL_CHANGE_CULTURE           GOODYHUT_SMALL_CHANGE_FAITH             GOODYHUT_SMALL_CHANGE_GOLD
        GOODYHUT_SMALL_MODIFIER_CULTURE         GOODYHUT_SMALL_MODIFIER_FAITH           GOODYHUT_SMALL_MODIFIER_GOLD

        GOODYHUT_GRANT_EXPERIENCE               GOODYHUT_ONE_TECH_BOOST                 GOODYHUT_ADD_POP
        GOODYHUT_GRANT_SCOUT                    GOODYHUT_TWO_TECH_BOOSTS                GOODYHUT_GRANT_BUILDER
        GOODYHUT_GRANT_WARRIOR                  GOODYHUT_ONE_TECH                       GOODYHUT_GRANT_TRADER
        GOODYHUT_GRANT_SLINGER                  GOODYHUT_TWO_TECHS                      GOODYHUT_GRANT_SETTLER
        GOODYHUT_GRANT_SPEARMAN                 GOODYHUT_SMALL_CHANGE_SCIENCE           GOODYHUT_SMALL_CHANGE_FOOD
        GOODYHUT_GRANT_MILITARY_ENGINEER        GOODYHUT_SMALL_MODIFIER_SCIENCE         GOODYHUT_SMALL_MODIFIER_FOOD
        GOODYHUT_GRANT_MEDIC
        GOODYHUT_GRANT_HORSEMAN                 * GOODYHUT_FAVOR                        * GOODYHUT_TWO_ENVOYS
        GOODYHUT_GRANT_HEAVY_CHARIOT            * GOODYHUT_ENVOY                        * GOODYHUT_TWO_GOVERNOR_TITLES
        GOODYHUT_SMALL_CHANGE_PRODUCTION        * GOODYHUT_GOVERNOR_TITLE               * GOODYHUT_SMALL_BOOST_FAVOR
        GOODYHUT_SMALL_MODIFIER_PRODUCTION
        * GOODYHUT_RESOURCES                    GOODYHUT_SPAWN_HOSTILE_VILLAGERS
########################################################################### */

-- UPDATE GoodyHutSubTypes SET Weight = 0;
-- UPDATE GoodyHutSubTypes SET Weight = 127 WHERE SubTypeGoodyHut = 'GOODYHUT_SPAWN_HOSTILE_VILLAGERS';

/* ###########################################################################
    End EGHV ingame configuration override
########################################################################### */
