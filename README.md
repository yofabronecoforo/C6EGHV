# Enhanced Goodies and Hostile Villagers for Civilization VI

A mod which provides several new Goody Hut rewards, and the return of hostile villagers.

# Features
### Goody Huts
Most types now have six possible rewards. To accommodate this, existing rewards have been enabled, disabled, and/or moved to other types, and have had their chances of occurring balanced against new rewards as follows:

Rarity | Tier 6 | Tier 5 | Tier 4 | Tier 3 | Tier 2 | Tier 1
------ | ------ | ------ | ------ | ------ | ------ | ------
Frequency | 50.8% | 25.4% | 12.7% | 6.3% | 3.2% | 1.6%

Most types retain at least their original common and uncommon rewards, which are now their Tier 6 and Tier 5 rewards. Most types also retain their original rare rewards, which are now their Tier 4 rewards. The "one free relic" reward is now a Faith-type reward, and is Tier 3. The defined-but-disabled "one free settler" reward has been enabled, and is the Tier 3 Survivors-type reward. New rewards have been added where necessary to fill out all types; for most types, the available rewards are now as follows:

Goody Hut | Tier 6 | Tier 5 | Tier 4 | Tier 3 | Tier 2 | Tier 1
--------- | ------ | ------ | ------ | ------ | ------ | ------
Culture | 1 civics boost | 2 civics boosts | 1 free civic | 2 free civics | +X culture per turn in all cities | +X% culture per turn in all cities
Diplomacy * | 20 favor | 1 free envoy | 1 free governor title | 2 free envoys | 2 free governor titles | +X favor per turn
Faith | 20 faith | 60 faith | 100 faith | 1 free relic | +X faith per turn in all cities | +X% faith per turn in all cities
Gold | 40 gold | 80 gold | 120 gold | +1 trade route | +X gold per turn in all cities | +X% gold per turn in all cities
Science | 1 tech boost | 2 tech boosts | 1 free tech | 2 free techs | +X science per turn in all cities | +X% science per turn in all cities
Survivors | +1 population in nearest city | 1 free builder | 1 free trader | 1 free settler | +X food per turn in all cities | +X% food per turn in all cities

[ * ] Requires the Gathering Storm expansion

Military-type rewards are slightly different. The "one free recon unit" has been replaced with several rewards that each provide a different class of unit; provided units will not scale with era or available tech, but can also be earned without having researched the prerequisite tech. The "free healing" reward has been disabled because it is lame. All enabled rewards of this type are split into six tiers as above, but due to the amount of available rewards, several tiers have more than one possible reward, with overall chances per tier as follows:

Goody Hut | Tier 6 (38.1%) | Tier 5 (38.1%) | Tier 4 (12.7%) | Tier 3 (6.3%) | Tier 2 (3.2%) | Tier 1 (1.6%)
--------- | ------ | ------ | ------ | ------ | ------ | ------
Military | grant experience -OR- grant resources * -OR - 1 free scout | 1 free warrior -OR- slinger -OR- spearman | 1 free medic -OR- military engineer | 1 free horseman -OR- heavy chariot | +X production per turn in all cities | +X% production per turn in all cities

[ * ] Requires the Gathering Storm expansion. When present each Tier 6 reward has an equal chance of occurring; when not present, grant experience will be twice as likely as one free scout.

Minimum-turn requirements have been set to 0 for all __defined__ rewards, meaning that all such rewards will be available from turn 1 on.

* There is a known issue where receiving the "2 free civics" reward prior to unlocking the Code of Laws civic results in only receiving 1 free civic, which will be Code of Laws. As this is only really a problem during turns 1-20, I am currently inclined to leave it alone.

In addition to all of the above, greater numbers of Goody Huts should appear on the map.

### Hostile Villagers
Whenever a reward is earned from a Goody Hut, there is a chance that some of the villagers will be displeased that their tribe treated with outsiders. This chance fluctuates based on several factors:

* the selected difficulty level (base chance increases with higher settings)
* the type of unit that popped the hut (increased chance when this is not a civilian or recon-class unit)
* the rarity tier of the reward (chance increases with more valuable rewards)
* the current game era (increased chance with each successive era)

On the default difficulty setting, in the Ancient era, a recon or civilian unit popping a hut has a 5-10% chance of encountering hostile villagers. This chance increases to 7-12% for other units. These scale with each successive era, so that in the Future era, they will be 45-90% and 63-108%, respectively. On the lowest difficulty setting, these chances should start at 2-7% and 3-8% in the Ancient era, and scale from there. On the highest difficulty setting, they should start at 9-14% and 13-18%, and scale from there. Thus, late enough in the game, and with rare enough rewards, encountering hostile villagers is no longer a chance, but instead becomes a guarantee.

If the villagers are hostile, they will retaliate by organizing into one barbarian melee unit. If they are very hostile, more than one unit will appear. If they are downright pissed off, they will organize into a new barbarian camp near the site of their former village, and they will spawn a handful of units. Their hostility level greatly fluctuates based on the same factors as the chance to be hostile above, and like above, eventually multiple units, and even a camp, will move from being a chance to a guarantee.

What's that? "Not masochistic enough!" you say? Then how about a new reward type that's nothing but hostile villagers? They won't even lure you in with the carrot before reaching for the stick, they just go straight for the stick, and the stick is pointy. This Hostiles-type reward is weighted similarly to other existing types; this means that there should be either a 1/7 or 1/8 chance of being the selected type, depending on whether or not the Gathering Storm expansion is present.

Finally, to compensate for the increased numbers of barbarian units that are likely to be present now, the experience and level caps from fighting such units have been increased. You still aren't going to get a fully-promoted unit from fighting barbarians, but at least you'll be able to get more than a single promotion.

### Advanced Setup
Options have been added to Advanced Setup which, when enabled, will prevent hostile villagers from appearing after, or as, a reward. Enabling both of these options will remove any chance of encountering hostile villagers entirely. Enabling 'No Barbarians' will override these new options and will also remove any chance of encountering hostile villagers; the tooltip for this option has been updated to reflect this.

* Currently, when 'No Hostile Villagers As Reward' is enabled, no reward will be granted if that is the randomly-chosen type. Further, hostiles may appear anyway as a result of the initial hostility check, which is normally bypassed with this type since the 'reward' is guaranteed hostile villagers; this does not apply if 'No Hostile Villagers After Reward' is also enabled.

# Compatibility
### Rulesets
Works with the following rulesets:

* Standard *
* Rise and Fall
* Gathering Storm

[ * ] Works with Standard ruleset, but due to missing events and/or methods, the game era is less dynamic, and will instead change on predefined turns.

### Game Modes
Works with the following game modes:

* Apocalypse
* Barbarian Clans
* Dramatic Ages
* Heroes & Legends
* Monopolies and Corporations
* Secret Societies

Has not been tested with the following game modes:

* Tech and Civic Shuffle
* Zombie Defense

### Mods
Should work with other mods that add new Goody Hut (sub)types; any reward(s) unrecognized by EGHV will be assigned a rarity value of 6 for purposes of determining hostile spawn chance and/or villager hostility level. See the Conflicts section below for exceptions.

# Conflicts
If your mod alters any _existing_ Goody Hut (sub)types, unless it is also using a ludicrously high load order to apply those changes, they will likely be overwritten by EGHV due to its ridiculously high load order. Conflicts __will__ arise _regardless of relative load order_ if these alterations deviate substantially from those of EGHV.

EGHV adds new item(s) to the following table(s) in the Gameplay SQLite database:

* Types
* GoodyHuts
* GoodyHutSubTypes
* GoodyHutSubTypes_XP2 *
* Modifiers
* ModifierArguments

[ * ] Requires the Gathering Storm expansion

If your mod adds any similarly-named item(s) to any of the above table(s), then like above, these additions will likely be overwritten by EGHV. Conflicts __will__ arise _regardless of relative load order_ if these additions deviate substantially from those of EGHV.

EGHV employs a gameplay script named HostileVillagers.lua. If your mod employs a gameplay script with that name, conflicts __will__ arise.

# Special Thanks
This mod would not exist in its current form without any of the following:

* The [Civilization Fanatics](https://www.civfanatics.com/) community, particularly the [Civ6 - Creation & Customization](https://forums.civfanatics.com/forums/civ6-creation-customization.541/) forums
* The [Civilization VI Workshop](https://steamcommunity.com/app/289070/workshop/) on Steam

Specifically, the following contributions were essential to the Hostile Villagers feature of this mod:

* [Getting an extra bonus from goody huts](https://forums.civfanatics.com/threads/getting-an-extra-bonus-from-goody-huts.616695/#post-14780879) by LeeS
* [Barbarians Evolved](https://steamcommunity.com/sharedfiles/filedetails/?id=2164194796) by Charsi
* [Add a Feature to a Plot During Game time with Lua](https://forums.civfanatics.com/threads/add-a-feature-to-a-plot-during-game-time-with-lua.645149/#post-15435909) by LeeS
* [OnGoodyHutReward event, what are the parameters?](https://forums.civfanatics.com/threads/ongoodyhutreward-event-what-are-the-parameters.642591/#post-15398744) by LeeS
* [How do you catch an era change event in Lua?](https://forums.civfanatics.com/threads/how-do-you-catch-an-era-change-event-in-lua.614454/#post-15144387) by Tiramisu

Extra special thanks to these contributors, and to the greater community, without whom the common knowledge required for the remaining features of this mod would not be as common.
