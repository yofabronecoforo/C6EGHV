# Enhanced Goodies and Hostile Villagers for Civilization VI

A mod that provides a fairly comprehensive extension to the Tribal Village rewards system. Many new Frontend options relating to Goody Huts are available, including:
- A picker for choosing which Goody Hut reward(s), if any, have a chance of appearing ingame.
- A slider for decreasing or increasing the relative amount of Goody Huts that will appear.
- A dropdown menu for selecting an amount of possible bonus reward(s) in addition to the usual reward from a Goody Hut.
- A checkbox flag for equalizing the chances of receiving all enabled reward(s).

In addition, the number of available Goody Hut rewards has nearly tripled: There are now 47 with Standard rules and 51 with Rise and Fall rules (compared to 18 with either ruleset without EGHV), and 60 with Gathering Storm rules (compared to 23).

Finally, Hostile Villagers as (and now, potentially following) a reward make their return.

New Frontend and Ingame text fully localized in the following language(s):
- English (en_US)
- Spanish (es_ES)
- French (fr_FR)

# Features
## Reward Picker
Provides a new picker window for selecting the specific Goody Hut reward(s) that can appear, available in the game's Advanced Setup. Available selections in the picker will vary by the selected ruleset and/or compatible enabled content, and can be sorted by Name (the specific reward) or by Type (the parent category of the reward). Disabling all available reward(s) will cause the "No Goody Huts" game option to be implicitly enabled.

The tooltip for the Goody Hut picker reflects the source(s) of its content based on the selected ruleset and/or any currently available known content; it will dynamically update to reflect any changes to known content after launch. Its button text reflects the total amount of available items(s) when all items in the picker are selected.
- This functionality extends to the built-in City-States, Leaders, and Natural Wonders pickers.

## Goody Hut Distribution Slider
Provides a slider for decreasing or increasing the relative amount of Goody Huts that will appear on the selected map; this slider defaults to 100%, and adjusts in steps of 25% in a range of 25% - 500%, inclusive. This slider also appears in the picker window.

## Goody Huts
Existing built-in rewards have been enabled, disabled, and/or moved to other types, and have had their chances of occurring balanced against new rewards as follows:
- The "one free relic" reward is now a Faith-type reward.
- The defined-but-disabled "one free settler" reward has been enabled. 
- The "heal unit" reward has been disabled because it is lame.
- The "unit experience" reward has been disabled and replaced.
- The defined-but-disabled "upgrade unit" reward remains disabled; this is unlikely to change because it does not work correctly.
- If Gathering Storm is present, all of the new rewards it provides have been disabled and replaced.

New rewards have been added in both new and existing categories. The following rewards are available for all rulesets:

Goody Hut (Weight) | Common (40) | Uncommon (30) | Rare (20) | Legendary (10)
--------- | ------ | ------ | ------ | ------
Abilities * | +1 sight | +20 healing per turn | +1 movement | +10 combat strength
(Anti) Cavalry * | 1 free spearman (50) | 1 free heavy chariot (25) | 1 free horseman (25)
Culture | 1 civics boost | 2 civics boosts | 1 free civic * | 2 free civics *
Envoys * | 1 free envoy | 2 free envoys | 3 free envoys | 4 free envoys
Faith | 20 faith | 60 faith | 100 faith | 1 free relic
Gold | 40 gold | 80 gold | 120 gold | +1 trade route *
Hostiles * | low hostility | medium hostility | high hostility | maximum hostility
Military | 1 free recon unit (55) | 1 free melee unit (25) * | 1 free ranged unit (20) *
Promotions * | 10 experience | 20 experience | 30 experience | 50 experience
Secrets * | unlock villager secrets (100)
Science | 1 tech boost | 2 tech boosts | 1 free tech | 2 free techs *
Support * | 1 free battering ram | 1 free catapult | 1 free military engineer | 1 free medic
Survivors | +1 population | 1 free builder | 1 free trader | 1 free settler

The following rewards are available for Rise and Fall and later ruleset(s):

Goody Hut (Weight) | Common (40) | Uncommon (30) | Rare (20) | Legendary (10)
--------- | ------ | ------ | ------ | ------
Governors * | 1 free governor title | 2 free governor titles | 3 free governor titles | 4 free governor titles

The following rewards are available for Gathering Storm and later ruleset(s):

Goody Hut (Weight) | Common (40) | Uncommon (30) | Rare (20) | Legendary (10)
--------- | ------ | ------ | ------ | ------
Diplomacy * | 10 favor | 20 favor | 30 favor | 50 favor
Meteor | meteor-strike site (100)
Resources * | +10 strategic resources | +20 strategic resources | +30 strategic resources | +50 strategic resources

- [ * ] Provided by EGHV

Minimum-turn requirements have been set to 0 for all __defined__ rewards, meaning that all such rewards will be available from turn 1 on.
- There is a known issue where receiving the "2 free civics" reward prior to unlocking the Code of Laws civic results in only receiving 1 free civic, which will be Code of Laws. As this is only really a problem during turns 1-20, I am currently inclined to leave it alone.

The "grant catapult" reward currently does not work if the Player does not possess the prerequisite technology. This is weird, because none of the other specific individual unit rewards have a similar limitation.

The Villager Secrets reward can only be awarded to a Player a certain number of times before becoming useless. When this reward is received, and this limit has been reached for the Player, then unless this reward is the only enabled reward, a new reward will be randomly seleted instead. If it IS the only enabled reward, then instead nothing will happen. See below for further details.

The unit Ability rewards apply to any valid unit(s) in formation with the popping unit, as well as the popping unit. These rewards apply to each valid unit up to one time for the lifetime of that unit. For example, a Builder, Missionary, or Great Person can and will receive increased movement once, but not additional combat strength. Currently, the end result of this is that nothing will happen when an Ability reward is received and all valid unit(s) have already received the ability.

Units provided by Military type rewards will be Era-specific; units provided by (Anti) Cavalry and Support type rewards will not. 

Most of the other new and existing rewards above are self-explanatory. The various Hostile Villagers and Villager Secrets rewards will be described in detail further below.

## Bonus Rewards
Provides a dropdown menu for selecting the total number of potential reward(s) to receive from each Goody Hut. At the default setting of 1, nothing changes. With any of the "up to X" settings, X total rewards will be received from each Goody Hut, with any additional rewards beyond the first randomly selected from the pool of enabled rewards using a hokey custom method. In certain circumstances, fewer than X rewards will be received; these include:
- When any Hostile Villagers reward is selected as a reward, whether it's the first or a bonus reward. When this happens, it will be the last reward granted by this Goody Hut; if it is the first reward, it will be the only reward.

Any received bonus reward will generate an ingame panel notification with details about the received reward. These notifications use one of the built-in "user-defined" types, so the icon used is subject to frequent change, as the game itself cannot seem to consistently use the same icon.

Bonus Rewards, if enabled, can only be received from a Goody Hut. There are two main consequences of this:
1. The meteor strike reward will not provide any bonus rewards. For now, we're going to assume that the meteor is not the wreckage of advanced replicator technology from beyond the stars.
2. Civilization traits and other abilities that provide a reward when another condition is met will also not provide any bonus rewards. Nice try, Gilgamesh.

## Equalized Reward Chances
Provides a checkbox option which, when enabled, assigns every enabled reward in a category an equal share of that category's Weight. This results in most enabled rewards having a roughly equal chance of being selected. When all available rewards are enabled in Gathering Storm, these chances are roughly as follows:
- 5.89% meteor strike or villager secrets type
- 1.96% specific (anti) cavalry or military reward (5.89% for each parent type)
- 1.47% all other specific rewards (5.89% for each parent type)

These values will be different for different rulesets and/or amounts of enabled rewards, but will still ultimately be fairly close together.

## Hostile Villagers
Except for the meteor strike in Gathering Storm, whenever a reward is earned from a Goody Hut, there is a chance that some of the villagers will be displeased that their tribe treated with outsiders. This chance fluctuates based on several factors:

* The selected difficulty level (Base chance increases with higher settings)
* The type of unit that popped the hut (Increased chance with a reward received via border expansion or by a unit susceptible to instant removal like capture, condemnation, plunder, or return to another tile; decreased chance with most non-recon military units)
* The rarity tier of any received reward(s) (Chance increases with more valuable rewards. If bonus rewards are enabled, the cumulative value of all received rewards will be used; this can either have very little effect or it can seriously wreck your day, depending on how many rewards were received and how rare each was)
* The current game era (Increased chance with each successive era)

On the default difficulty setting, in the Ancient era, with one reward, there should be a 5-16% chance of encountering hostile villagers, depending on the received reward and the method in which it was received. This chance scales with each successive era, so that in the Future era, it will be 45-144%. On the lowest difficulty setting, the chance should start at 2-7% in the Ancient era, and scale from there. On the highest difficulty setting, the chancce should start at 9-28%, and scale from there. If bonus rewards are enabled, these chances increase slightly based upon the rarity of each reward received beyond the first. Thus, on higher difficulties, late enough in the game and with sufficient quantity and/or quality of rewards, encountering hostile villagers is no longer a chance, but instead becomes a guarantee.

If the villagers are hostile, they will retaliate by organizing into one barbarian melee unit in a nearby tile. If they are very hostile, more than one unit will appear, and some will be ranged. If they are downright pissed off, they will organize into a new barbarian camp near the site of their former village, and they will spawn a handful of units. If Horses are located near the site of the former village, there is a chance that any unit(s) that appear may instead be mounted; this chance increases with each additional nearby source of Horses. Villager hostility level greatly fluctuates based on the same factors as the chance to be hostile above, and like above, eventually multiple units, and even a camp, will move from being a chance to a guarantee.

What's that? "Not masochistic enough!" you say? Then how about a new reward type that's nothing but hostile villagers "rewards?" They won't even lure you in with the carrot before reaching for the stick, they just go straight for the stick, and the stick is pointy. When enabled, these rewards can be selected by the rewards system like any other reward, and have pre-determined villager hostility values, as shown in the table above. Hostility increases as rarity does; in fact, one of these rewards is selected internally after calculating villager hostility to place any hostiles that appear after any other reward.

Any hostile villagers that appear as or after a reward will generate an ingame panel notification with details.

To compensate for the increased numbers of barbarian units that are likely to be present now, the experience and level caps from fighting such units have been increased. You still aren't going to get a fully-promoted unit from fighting barbarians, but at least you'll be able to get more than a single promotion.

Hostile Villagers as a reward are configurable via the picker. For Hostile Villagers after a reward, there is a new dropdown option in Advanced Setup to select the chances of an appearance following any other Goody Hut reward. Available choices are:
- Never (hostile villagers will NOT appear)
- Maybe ( * this is the default option; a chance for hostile villagers to appear, as described above)
- Always (hostile villagers will ALWAYS appear; their hostility level will be as described above)
- Always + Increased Hostility (hostile villagers will ALWAYS appear, and their hostility level will be hyper-elevated)

Setting this option to 'Never', while also disabling all 'Hostile Villagers' reward type(s) via the picker, will remove any chance of encountering hostile villagers entirely, whether as or after a reward.

## Villager Secrets
This is a specialized reward which, when received, unlocks the ability for the receiving Player to build the Tribal Totem building. This building functions like a Monument, except it provides Amenities instead of Culture. This building can also be upgraded. The second time this reward is received by the same Player, an improved version of the building will be unlocked, which provides additional yields (the initial unlock is level 0):

Tribal Totem Yield Modifiers | Culture | Faith | Food | Gold | Production | Science | Favor **
------- | ------- | ------- | ------- | ------- | ------- | ------- | -------
Level 1 | +1 | +1 | +1 | +2 | +1 | +1 | +1

These yields are in addition to its Amenities output. The building can currently be upgraded in this way 5 times, with the additional yield modifiers stacking each time; thus, at level 5 it will look like this:

Tribal Totem Yield Modifiers | Culture | Faith | Food | Gold | Production | Science | Favor **
------- | ------- | ------- | ------- | ------- | ------- | ------- | -------
Level 5 | +5 | +5 | +5 | +10 | +5 | +5 | +5
- [ ** ] Requires Gathering Storm

This means that each Player can currently receive this reward a total of 6 times in a game before there are no further "secrets" to unlock and it becomes useless. When this happens, a new reward will be randomly selected to replace it, unless this is the only currently enabled reward, in which case nothing will happen.

If Hostile Villagers after a reward are enabled, this reward will provoke a slightly more aggressive response than usual.

## Additional Advanced Setup
Enabling 'No Barbarians' will override any hostiles-related options and/or selections above, and will also remove any chance of encountering hostile villagers, whether as or after a reward. The tooltip for this option has been updated to reflect this.

Enabling 'No Tribal Villages' will override any selections made with the Goody Hut picker. It will also override any other Goody-Hut-related values, including hostiles-related options and/or selections, but will not otherwise affect Barbarians. The tooltip for this option has been updated to reflect this.

The dev version provides a checkbox option that, when enabled, will produce _extremely_ verbose logging output for debugging purposes. This is disabled by default.

# Compatibility
## SP / MP
Compatible with Single- and Multi-Player game setups.

## Rulesets
Compatible with the following rulesets:

* Standard
* Rise and Fall
* Gathering Storm

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
- Any rewards which EGHV does NOT recognize will **NOT** appear in the Goody Hut picker; these must be configured and recognized to do so. If you would like any Goody Huts provided by a particular community project to be reflected within the picker when said project is enabled, please open an issue with the project details, and it will be considered.
- Note that the above means EGHV has no interaction with unrecognized Goody Hut rewards beyond potentially spawning hostile villagers after receiving such a reward.
- New Goody Hut rewards provided by recognized content will appear in the Goody Hut picker when enabled, and disabling any of these rewards via the picker will eliminate their chances of appearing ingame. Currently, in addition to official content and C6GUE components, the following community project(s) provide content recognized by EGHV:
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
* The [Civilization VI Modding Companion](https://docs.google.com/spreadsheets/d/1hQ8zlEHl1nfjCWvKqOlkDACezu5-igfQkVcOxeE_KG0/edit#gid=1678767919) by ChimpanG, et al
* The [Civilization 6 Modding Guide](https://forums.civfanatics.com/threads/lees-civilization-6-modding-guide.644687/) by LeeS
* [DB's Font Icons and Colors](https://steamcommunity.com/sharedfiles/filedetails/?id=1846090643) by DB

Specifically, the following were essential to the Hostile Villagers feature:

* [Getting an extra bonus from goody huts](https://forums.civfanatics.com/threads/getting-an-extra-bonus-from-goody-huts.616695/#post-14780879) by LeeS
* [Barbarians Evolved](https://steamcommunity.com/sharedfiles/filedetails/?id=2164194796) by Charsi
* [Add a Feature to a Plot During Game time with Lua](https://forums.civfanatics.com/threads/add-a-feature-to-a-plot-during-game-time-with-lua.645149/#post-15435909) by LeeS
* [OnGoodyHutReward event, what are the parameters?](https://forums.civfanatics.com/threads/ongoodyhutreward-event-what-are-the-parameters.642591/#post-15398744) by LeeS
* [How do you catch an era change event in Lua?](https://forums.civfanatics.com/threads/how-do-you-catch-an-era-change-event-in-lua.614454/#post-15144387) by Tiramisu

The following were essential in implementing the Goody Hut picker and frequency slider:

* [Configurable Goody Huts](https://steamcommunity.com/sharedfiles/filedetails/?id=2462745561) by Sailor Cat

The following were essential to the Unit Ability rewards, Villager Secrets reward, and Bonus Rewards features:

* [Questions regarding limitations of Mods](https://forums.civfanatics.com/threads/questions-regarding-limitations-of-mods.663297/) by dunkleosteus, et al
* [Wondrous Goody Huts](https://steamcommunity.com/sharedfiles/filedetails/?id=2384120911) by Sailor Cat
* [Test Dummy Techs](https://forums.civfanatics.com/threads/solved-need-help-creating-custom-trait.621558/#post-14849718) by LeeS

Extra special thanks to these contributors, and to the greater community, without whom the common knowledge required for the remaining features of this mod would not be as common.
