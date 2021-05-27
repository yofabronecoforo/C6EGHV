# Enhanced Goodies and Hostile Villagers for Civilization VI

A mod that provides a picker for choosing which Goody Hut reward(s), if any, have a chance of appearing ingame. It also provides a slider for decreasing or increasing the relative amount of Goody Huts that will appear. In addition, it provides several other new Goody Hut customization options, and many new Goody Hut rewards. Finally, Hostile Villagers as (and now, potentially following) a reward make their return.

New Frontend and Ingame text fully localized in the following language(s):
- English (en_US)
- Spanish (es_ES)
- French (fr_FR)

# Features
## Goody Hut Picker and Distribution Slider
Provides a new picker window for selecting the specific Goody Hut reward(s) that can appear, available in the game's Advanced Setup. Available selections in the picker will vary by the selected ruleset and/or compatible enabled content, and can be sorted by Name (the specific reward) or by Type (the parent category of the reward). Disabling all available reward(s) will cause the "No Goody Huts" game option to be implicitly enabled.

The tooltip for the Goody Hut picker reflects the source(s) of its content based on the selected ruleset and/or any currently available known content; it will dynamically update to reflect any changes to known content after launch. Its button text reflects the total amount of available items(s) when all items in the picker are selected.
- This functionality extends to the built-in City-States, Leaders, and Natural Wonders pickers.

Provides a slider for decreasing or increasing the relative amount of Goody Huts that will appear on the selected map; this slider defaults to 100%, and adjusts in steps of 25% in a range of 25% - 500%, inclusive. This slider also appears in the picker window.

## Goody Huts
Most types now have six possible rewards. To accommodate this, existing rewards have been enabled, disabled, and/or moved to other types, and have had their chances of occurring balanced against new rewards. Currently, rarity tiers and the corresponding frequencies and weights for most types are as follows:

Rarity | Tier 6 | Tier 5 | Tier 4 | Tier 3 | Tier 2 | Tier 1
------ | ------ | ------ | ------ | ------ | ------ | ------
Frequency | 28.6% | 23.8% | 19.0% | 14.3% | 9.5% | 4.8%
Weight | 60 | 50 | 40 | 30 | 20 | 10

Most types retain at least their original common and uncommon rewards, which are now their Tier 6 and Tier 5 rewards. Most types also retain their original rare rewards, which are now their Tier 4 rewards.

The "one free relic" reward is now a Faith-type reward, and is Tier 3. The defined-but-disabled "one free settler" reward has been enabled, and is now the Tier 3 Survivors-type reward. 

The "heal unit" reward has been disabled because it is lame. The defined-but-disabled "upgrade unit" reward remains disabled; this is unlikely to change.

New rewards have been added where necessary to fill out all types to at least six possible rewards; for Military-type, the "grant scout" reward has been split into several rewards which each grant a different unit type, and other new rewards have been added to bring the total to twelve. Available rewards are now as follows:

Goody Hut | Tier 6 | Tier 5 | Tier 4 | Tier 3 | Tier 2 | Tier 1
--------- | ------ | ------ | ------ | ------ | ------ | ------
Culture | 1 civics boost | 2 civics boosts | 1 free civic | 2 free civics | +2 culture per turn in all cities | +10% culture per turn in all cities
Diplomacy * | 20 favor | 1 free envoy | 1 free governor title | 2 free envoys | 2 free governor titles | +3 favor per turn
Faith | 20 faith | 60 faith | 100 faith | 1 free relic | +2 faith per turn in all cities | +10% faith per turn in all cities
Gold | 40 gold | 80 gold | 120 gold | +1 trade route | +4 gold per turn in all cities | +10% gold per turn in all cities
Military | grant experience -OR- grant resources ** | 1 free scout -OR- 1 free warrior | 1 free slinger -OR- 1 free spearman | 1 free horseman -OR- 1 free heavy chariot | 1 free medic -OR- 1 free military engineer | +2 production per turn in all cities -OR- +10% production per turn in all cities
Science | 1 tech boost | 2 tech boosts | 1 free tech | 2 free techs | +2 science per turn in all cities | +10% science per turn in all cities
Survivors | +1 population in nearest city | 1 free builder | 1 free trader | 1 free settler | +2 food per turn in all cities | +10% food per turn in all cities

* [ * ] Requires the Gathering Storm expansion.
* [ ** ] Requires the Gathering Storm expansion. When present each Tier 6 reward has an equal chance of occurring; when not present, grant experience will be the only reward in this tier.

Minimum-turn requirements have been set to 0 for all __defined__ rewards, meaning that all such rewards will be available from turn 1 on.

* There is a known issue where receiving the "2 free civics" reward prior to unlocking the Code of Laws civic results in only receiving 1 free civic, which will be Code of Laws. As this is only really a problem during turns 1-20, I am currently inclined to leave it alone.

## Hostile Villagers
Whenever a reward is earned from a Goody Hut, there is a chance that some of the villagers will be displeased that their tribe treated with outsiders. This chance fluctuates based on several factors:

* the selected difficulty level (base chance increases with higher settings)
* the type of unit that popped the hut (increased chance when this is not a civilian or recon-class unit)
* the rarity tier of the reward (chance increases with more valuable rewards)
* the current game era (increased chance with each successive era)

On the default difficulty setting, in the Ancient era, a recon or civilian unit popping a hut has a 5-10% chance of encountering hostile villagers. This chance increases to 7-12% for other units. These scale with each successive era, so that in the Future era, they will be 45-90% and 63-108%, respectively. On the lowest difficulty setting, these chances should start at 2-7% and 3-8% in the Ancient era, and scale from there. On the highest difficulty setting, they should start at 9-14% and 13-18%, and scale from there. Thus, late enough in the game, and with rare enough rewards, encountering hostile villagers is no longer a chance, but instead becomes a guarantee.

If the villagers are hostile, they will retaliate by organizing into one barbarian melee unit. If they are very hostile, more than one unit will appear. If they are downright pissed off, they will organize into a new barbarian camp near the site of their former village, and they will spawn a handful of units. Their hostility level greatly fluctuates based on the same factors as the chance to be hostile above, and like above, eventually multiple units, and even a camp, will move from being a chance to a guarantee.

What's that? "Not masochistic enough!" you say? Then how about a new reward type that's nothing but hostile villagers? They won't even lure you in with the carrot before reaching for the stick, they just go straight for the stick, and the stick is pointy. This Hostiles-type reward is weighted similarly to other existing types; this means that there should be either a 1/7 or 1/8 chance of being the selected type, depending on whether or not the Gathering Storm expansion is present.

Finally, to compensate for the increased numbers of barbarian units that are likely to be present now, the experience and level caps from fighting such units have been increased. You still aren't going to get a fully-promoted unit from fighting barbarians, but at least you'll be able to get more than a single promotion.

## Advanced Setup
Provides an option in Advanced Setup to select whether Hostile Villagers may appear following any other Goody Hut reward. Available choices are:
- Never (hostile villagers will NOT appear)
- Maybe ( * this is the default option; a chance for hostile villagers to appear, as described above)
- Always (hostile villagers will ALWAYS appear; their hostility level will be as described above)
- Always + Increased Hostility (hostile villagers will ALWAYS appear, and their hostility level will be hyper-elevated)

Setting this option to 'Never', while also disabling the 'Hostile Villagers' reward type via the picker, will remove any chance of encountering hostile villagers entirely.

Provides an option in Advanced Setup to equalize the chances most known Goody Hut rewards have of appearing. When enabled, most known individual rewards will have an equal chance of appearing, and for the purposes of spawning Hostile Villagers, they will be assigned to rarity Tier 1.

Enabling 'No Barbarians' will override these new options, and will also remove any chance of encountering hostile villagers; the tooltip for this option has been updated to reflect this.

Enabling 'No Tribal Villages' will override any selections made with the Goody Hut picker. It will also override any other Goody-Hut-related values; the tooltip for this option has been updated to reflect this.

# Compatibility
## SP / MP
Compatible with Single- and Multi-Player game setups.

## Rulesets
Compatible with the following rulesets:

* Standard *
* Rise and Fall
* Gathering Storm

[ * ] Works with Standard ruleset, but due to missing events and/or methods, the game era is less dynamic, and will instead change on predefined turns.

## Game Modes
Compatible with the following game modes:

* Apocalypse
* Barbarian Clans
* Dramatic Ages
* Heroes & Legends
* Monopolies and Corporations
* Secret Societies

Has not been tested with the following game modes:

* Tech and Civic Shuffle
* Zombie Defense

## Mods
Should work with other mods that add new Goody Hut (sub)types, with the following caveats:
- Most rewards which EGHV does NOT recognize will be assigned a rarity value of 6 for purposes of determining hostile spawn chance and/or villager hostility level. Exceptions to this include most rewards which are the only subtype within their parent type; these require additional tuning.
- Any rewards which EGHV does NOT recognize will **NOT** appear in the Goody Hut picker; these must be configured and recognized to do so. If you would like any Goody Huts provided by a particular community project to be reflected within the picker when said project is enabled, please open an issue with the project details, and it will be considered.
- Note that taken together, the above means EGHV has no interaction with unrecognized Goody Hut rewards beyond potentially spawning hostile villagers after receiving such a reward.
- New Goody Hut rewards provided by recognized content will appear in the Goody Hut picker when enabled, and disabling any of these rewards via the picker will eliminate their chances of appearing ingame. Currently, the following community projects are recognized by EGHV:
  - Wondrous Goody Huts

See the Conflicts section below for exceptions.

# Installation
## Automatic
EGHV is [Steam Workshop item 2474051781](https://steamcommunity.com/sharedfiles/filedetails/?id=2474051781). Subscribe to automatically download and install the latest release, and to automatically receive any updates as they are published to the Workshop.

## Manual
Download the [latest release](https://github.com/zzragnar0kzz/C6EGHV/releases/latest) and extract it into the game's local mods folder. Alternately, clone the repository into the game's local mods folder using your preferred tools. The local mods folder varies:
- Windows : `$userprofile\Documents\My Games\Sid Meier's Civilization VI\Mods`
- Linux : 
- MacOS : 

To update to a newer release, clone or download the latest release as described above, overwriting any existing items in the destination folder.

# Conflicts
If your mod alters any _existing_ Goody Hut (sub)types, unless it is also using a ludicrously high load order to apply these changes, they will likely be overwritten by EGHV due to its ridiculously high load order. Conflicts __will__ arise _regardless of relative load order_ if these alterations deviate substantially from those of EGHV.

EGHV adds the following custom table(s) to the game's Configuration database:
- ContentFlags
- TribalVillages

If your mod uses any similarly-named tables, conflicts _may_ arise.

EGHV adds new item(s) to the following table(s) in the game's Gameplay database:
- Types
- GoodyHuts
- GoodyHutSubTypes
- GoodyHutSubTypes_XP2 *
- Modifiers
- ModifierArguments

[ * ] Requires the Gathering Storm expansion

If your mod adds any similarly-named item(s) to any of the above table(s), then like above, these additions will likely be overwritten by EGHV. Conflicts __will__ arise _regardless of relative load order_ if these additions deviate substantially from those of EGHV.

EGHV employs a gameplay script named HostileVillagers.lua. If your mod employs a gameplay script with that name, conflicts __will__ arise.

EGHV replaces the following existing Frontend context file(s):
- AdvancedSetup.lua and AdvancedSetup.xml
- GameSetupLogic.lua
- HostGame.lua and HostGame.xml
- Mods.lua

EGHV adds the following new Frontend context file(s):
- GoodyHutPicker.lua and GoodyHutPicker.xml

If your mod replaces any of the above existing files, or adds any similarly-named new ones, compatibility issues **will** arise.

# Special Thanks
This mod would not exist in its current form without any of the following:

* The [Civilization Fanatics](https://www.civfanatics.com/) community, particularly the [Civ6 - Creation & Customization](https://forums.civfanatics.com/forums/civ6-creation-customization.541/) forums
* The [Civilization VI Workshop](https://steamcommunity.com/app/289070/workshop/) on Steam

Specifically, the following were essential to the Hostile Villagers feature:

* [Getting an extra bonus from goody huts](https://forums.civfanatics.com/threads/getting-an-extra-bonus-from-goody-huts.616695/#post-14780879) by LeeS
* [Barbarians Evolved](https://steamcommunity.com/sharedfiles/filedetails/?id=2164194796) by Charsi
* [Add a Feature to a Plot During Game time with Lua](https://forums.civfanatics.com/threads/add-a-feature-to-a-plot-during-game-time-with-lua.645149/#post-15435909) by LeeS
* [OnGoodyHutReward event, what are the parameters?](https://forums.civfanatics.com/threads/ongoodyhutreward-event-what-are-the-parameters.642591/#post-15398744) by LeeS
* [How do you catch an era change event in Lua?](https://forums.civfanatics.com/threads/how-do-you-catch-an-era-change-event-in-lua.614454/#post-15144387) by Tiramisu

The following were essential in implementing the Goody Hut picker and frequency slider:

* [Configurable Goody Huts](https://steamcommunity.com/sharedfiles/filedetails/?id=2462745561) by Sailor Cat

Extra special thanks to these contributors, and to the greater community, without whom the common knowledge required for the remaining features of this mod would not be as common.
