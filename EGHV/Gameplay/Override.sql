/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2021 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV ingame configuration override; for debugging and testing
########################################################################### */

/* ###########################################################################
    GoodyHuts weights
    first line : globally reset all GoodyHuts weights
    additional line(s) : set weight of specific GoodyHutType from the following valid options (* requires Rise and Fall ruleset; ** requires Gathering Storm ruleset)
        GOODYHUT_CULTURE            GOODYHUT_FAITH          GOODYHUT_GOLD               GOODYHUT_MILITARY           GOODYHUT_SCIENCE            GOODYHUT_SURVIVORS

        GOODYHUT_ABILITIES          GOODYHUT_ENVOYS         GOODYHUT_HOSTILES           GOODYHUT_PROMOTIONS         GOODYHUT_SECRETS            GOODYHUT_UNITS

        * GOODYHUT_GOVERNORS

        ** GOODYHUT_DIPLOMACY       ** GOODYHUT_RESOURCES
########################################################################### */

-- UPDATE GoodyHuts SET Weight = 0;
-- UPDATE GoodyHuts SET Weight = 100 WHERE GoodyHutType = 'GOODYHUT_SECRETS';

/* ###########################################################################
    GoodyHutSubTypes weights
    first line : globally reset all GoodyHutSubTypes weights
    additional line(s) : set weight of specific SubTypeGoodyHut from the following valid options (* requires Rise and Fall ruleset; ** requires Gathering Storm ruleset)
        GOODYHUT_ONE_CIVIC_BOOST                GOODYHUT_TWO_CIVIC_BOOSTS               GOODYHUT_ONE_CIVIC                  GOODYHUT_TWO_CIVICS

        GOODYHUT_SMALL_FAITH                    GOODYHUT_MEDIUM_FAITH                   GOODYHUT_LARGE_FAITH                GOODYHUT_ONE_RELIC

        GOODYHUT_SMALL_GOLD                     GOODYHUT_MEDIUM_GOLD                    GOODYHUT_LARGE_GOLD                 GOODYHUT_ADD_TRADE_ROUTE

        GOODYHUT_GRANT_SCOUT                    GOODYHUT_GRANT_WARRIOR                  GOODYHUT_GRANT_SLINGER              GOODYHUT_GRANT_SPEARMAN

        GOODYHUT_ONE_TECH_BOOST                 GOODYHUT_TWO_TECH_BOOSTS                GOODYHUT_ONE_TECH                   GOODYHUT_TWO_TECHS

        GOODYHUT_ADD_POP                        GOODYHUT_GRANT_BUILDER                  GOODYHUT_GRANT_TRADER               GOODYHUT_GRANT_SETTLER

        GOODYHUT_IMPROVED_SIGHT                 GOODYHUT_IMPROVED_HEALING               GOODYHUT_IMPROVED_MOVEMENT          GOODYHUT_IMPROVED_STRENGTH

        GOODYHUT_ONE_ENVOY                      GOODYHUT_TWO_ENVOYS                     GOODYHUT_THREE_ENVOYS               GOODYHUT_FOUR_ENVOYS

        GOODYHUT_LOW_HOSTILITY_VILLAGERS        GOODYHUT_MID_HOSTILITY_VILLAGERS        GOODYHUT_HIGH_HOSTILITY_VILLAGERS   GOODYHUT_MAX_HOSTILITY_VILLAGERS

        GOODYHUT_SMALL_EXPERIENCE               GOODYHUT_MEDIUM_EXPERIENCE              GOODYHUT_LARGE_EXPERIENCE           GOODYHUT_HUGE_EXPERIENCE

        GOODYHUT_GRANT_HEAVY_CHARIOT            GOODYHUT_GRANT_HORSEMAN                 GOODYHUT_GRANT_MEDIC                GOODYHUT_GRANT_MILITARY_ENGINEER

        GOODYHUT_UNLOCK_VILLAGER_SECRETS

        * GOODYHUT_ONE_TITLE                    * GOODYHUT_TWO_TITLES                   * GOODYHUT_THREE_TITLES             * GOODYHUT_FOUR_TITLES

        ** GOODYHUT_SMALL_FAVOR                 ** GOODYHUT_MEDIUM_FAVOR                ** GOODYHUT_LARGE_FAVOR             ** GOODYHUT_HUGE_FAVOR
        
        ** GOODYHUT_SMALL_RESOURCES             ** GOODYHUT_MEDIUM_RESOURCES            ** GOODYHUT_LARGE_RESOURCES         ** GOODYHUT_HUGE_RESOURCES

    built-in subtypes that are disabled by default in EGHV; these are provided here for troubleshooting and debugging
        GOODYHUT_ENVOY
        GOODYHUT_FAVOR
        GOODYHUT_GOVERNOR_TITLE
        GOODYHUT_GRANT_EXPERIENCE
        GOODYHUT_RESOURCES

    deprecated subtypes; these are provided here for troubleshooting and debugging
        GOODYHUT_SMALL_CHANGE_CULTURE           GOODYHUT_SMALL_MODIFIER_CULTURE
        GOODYHUT_SMALL_CHANGE_FAITH             GOODYHUT_SMALL_MODIFIER_FAITH
        GOODYHUT_SMALL_CHANGE_GOLD              GOODYHUT_SMALL_MODIFIER_GOLD
        GOODYHUT_SMALL_CHANGE_PRODUCTION        GOODYHUT_SMALL_MODIFIER_PRODUCTION
        GOODYHUT_SMALL_CHANGE_SCIENCE           GOODYHUT_SMALL_MODIFIER_SCIENCE
        GOODYHUT_SMALL_CHANGE_FOOD              GOODYHUT_SMALL_MODIFIER_FOOD
########################################################################### */

-- UPDATE GoodyHutSubTypes SET Weight = 0;
-- UPDATE GoodyHutSubTypes SET Weight = 100 WHERE SubTypeGoodyHut = 'GOODYHUT_UNLOCK_VILLAGER_SECRETS';

/* ###########################################################################
    end EGHV ingame configuration override
########################################################################### */
