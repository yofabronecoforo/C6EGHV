/* ###########################################################################
    EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
    Copyright (c) 2020-2023 zzragnar0kzz
    All rights reserved.
########################################################################### */

/* ###########################################################################
    begin EGHV exclude Goody Hut configuration
    each Goody Hut in the picker requires a file like this to facilitate exclusion
    if you want your content to be properly disabled via the picker, start here:
        1. Copy this file to the desired location within your mod. Rename it to
			whatever you wish. Add it to your mod's .modinfo file within <Files>
        2. Define new criteria within <ActionCriteria> in your mod's .modinfo file:
                <Criteria id="New_Criteria_ID">
    		        <ConfigurationValueMatches>
    			        <ConfigurationId>EXCLUDE_?</ConfigurationId>
    			        <Group>Game</Group>
        			    <Value>1</Value>
        		    </ConfigurationValueMatches>
    	        </Criteria>
            ? above corresponds to the SubTypeGoodyHut of this reward in table GoodyHutSubTypes
            (e.g. if this reward has a SubTypeGoodyHut of GOODYHUT_AWESOME_REWARD, then the criteria's
            ConfigurationId will be EXCLUDE_GOODYHUT_AWESOME_REWARD)
        3. Add this file to your mod's .modinfo file using a new <UpdateDatabase> action
			within <InGameActions>. Ensure that this action has a defined LoadOrder
            which will cause it to load after the content to be excluded has been added to the
            Gameplay database
        4. Uncomment and modify the queries below, or add your own, to disable the specified
            Goody Hut. Generally, this can be accomplished by setting its weight value to 0 in
            table GoodyHutSubTypes, followed by recalculating the total weight of all rewards
            with this reward's parent GoodyHutType in table GoodyHuts
########################################################################### */

UPDATE GoodyHutSubTypes SET Weight = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_SAILOR_RANDOMUNIT';
UPDATE GoodyHuts Set Weight = (SELECT CASE WHEN (SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SAILOR_WONDROUS') = 0 THEN 0 ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_SAILOR_WONDROUS') END) WHERE GoodyHutType = 'GOODYHUT_SAILOR_WONDROUS';

/* ###########################################################################
    end EGHV exclude Goody Hut configuration
########################################################################### */
