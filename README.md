# Enhanced Goodies and Hostile Villagers for Civilization VI
![Advanced Setup Modifications](/IMAGES/Advanced_Setup_Modifications.png)

The above image, and all other image(s) herein, reflect an Advanced Setup with Gathering Storm rules; actual configuration options will vary with different rules and/or available additional content.

# Overview
A mod that provides a fairly comprehensive extension to and overhaul of the Tribal Village (Goody Hut) rewards system. Many new Frontend options relating to Goody Huts are available, including:
- A picker for choosing which Goody Hut reward(s), if any, have a chance of appearing ingame.
- A slider for decreasing or increasing the relative amount of Goody Huts that will appear.
- A dropdown menu for selecting an amount of possible bonus reward(s) in addition to the usual reward from a Goody Hut.
- A checkbox flag for equalizing the chances of receiving all enabled reward(s).

In addition, the number of available Goody Hut rewards has greatly increased: 
Ruleset | Available Rewards (Types) | Rewards (Types) w/o EGHV
------- | ------- | -------
Standard | 47 (13) | 18 (6)
Rise and Fall | 51 (14) | 18 (6)
Gathering Storm | 60 (17) | 23 (8)

Many of these rewards are implemented entirely via Lua scripting, because the built-in system is sorely lacking in many ways.

Finally, Hostile Villagers as (and now, potentially following) a reward make their return.

New Frontend and Ingame text fully localized in the following language(s):
- English (en_US)
- Spanish (es_ES)
- French (fr_FR)

# Features
## Goody Huts
![Goody Hut Picker](/IMAGES/Goody_Hut_Picker.png)

Existing built-in rewards have been enabled, disabled, and/or moved to other types, and have had their chances of occurring balanced against new rewards as follows:
- The "one free relic" reward is now a Faith-type reward.
- The defined-but-disabled "one free settler" reward has been enabled. 
- The "heal unit" reward has been disabled because it is lame; it has been superceded by a new reward in the Abilities type.
- The "unit experience" reward has been disabled; it is superceded by the rewards in the new Promotions type.
- The defined-but-disabled "upgrade unit" reward has been enabled entirely via Lua, because the built-in mechanism is broken; this is now a Support-type reward.
- If Gathering Storm is present, all of the new rewards it provides have been disabled and superceded as follows:
  - The "free envoy" reward is superceded by the rewards in the new Envoys type; these rewards are now available for all rulesets.
  - The "free governor title" reward is superceded by the rewards in the new Governors type; these rewards are now available for Rise and Fall and later ruleset(s).
  - The "free diplomatic favor" reward is superceded by new rewards in the Diplomacy type.
  - The "free strategic resources" reward is superceded by the rewards in the new Resources type.

New rewards have been added in both new and existing categories. The following rewards are available for all rulesets:

Goody Hut (Weight) | Common (40) | Uncommon (30) | Rare (20) | Legendary (10)
--------- | ------ | ------ | ------ | ------
Abilities * | +1 sight | +20 healing per turn | +1 movement | +10 combat strength
(Anti) Cavalry * | 1 anti-cavalry unit (50) | 1 heavy cavalry unit (25) | 1 light cavalry unit (25)
Culture | 1 civics boost | 2 civics boosts | 1 civic * | 2 civics *
Envoys * | 1 envoy | 2 envoys | 3 envoys | 4 envoys
Faith | +20 faith | +60 faith | +100 faith | 1 relic
Gold | +40 gold | +80 gold | +120 gold | 1 additional trade route *
Hostiles * | low hostility | medium hostility | high hostility | maximum hostility
Military | 1 recon unit (55) | 1 melee unit (25) * | 1 ranged unit (20) *
Promotions * | 10 experience | 20 experience | 30 experience | 50 experience
Secrets * | villager secrets (100)
Science | 1 tech boost | 2 tech boosts | 1 tech | 2 techs *
Support * | 1 support unit (25) | 1 siege unit (25) | 1 military engineer (25) | upgrade unit (25)
Survivors | 1 new population | 1 builder | 1 trader | 1 settler

The following rewards are available for Rise and Fall and later ruleset(s):

Goody Hut (Weight) | Common (40) | Uncommon (30) | Rare (20) | Legendary (10)
--------- | ------ | ------ | ------ | ------
Governors * | 1 governor title | 2 governor titles | 3 governor titles | 4 governor titles

The following rewards are available for Gathering Storm and later ruleset(s):

Goody Hut (Weight) | Common (40) | Uncommon (30) | Rare (20) | Legendary (10)
--------- | ------ | ------ | ------ | ------
Diplomacy * | 10 diplomatic favor | 20 diplomatic favor | 30 diplomatic favor | 50 diplomatic favor
Meteor | meteor-strike site (100)
Resources * | 10 strategic resources | 20 strategic resources | 30 strategic resources | 50 strategic resources

- [ * ] Provided by EGHV

Minimum-turn requirements are set to 0 for all __DEFINED__ and __ENABLED__ rewards, meaning that all such rewards will be available from turn 1 on.

Units provided by any Military type reward - including any (Anti) Cavalry or Support type reward, and the Military Engineer reward - will be Era-specific and will spawn in a plot near the Goody Hut that provided the reward. Units provided by any other reward will be the unit indicated by the reward and will spawn in the nearest city center.

Most other new and existing rewards above are self-explanatory. The various Hostile Villagers and Villager Secrets rewards are described in detail further below. Refer to the #Known Shortcomings, Limitations, and Bugs section below for additional caveats.

## Goody Hut Reward Picker
![Goody Hut Picker](/IMAGES/Picker_Detail.gif)

Provides a new picker window for selecting the specific Goody Hut reward(s) that can appear, available in the game's Advanced Setup. Available selections in the picker will vary by the selected ruleset and/or compatible enabled content, and can be sorted by Name (the specific reward) or by Type (the parent category of the reward). Disabling all available reward(s) will cause the "No Goody Huts" game option to be implicitly enabled.

The tooltip for the Goody Hut picker reflects the source(s) of its content based on the selected ruleset and/or any currently available known content; it will dynamically update to reflect any changes to known content after launch. Its button text reflects the total amount of available items(s) when all items in the picker are selected.
- This functionality extends to the built-in City-States, Leaders, and Natural Wonders pickers.

## Goody Hut Distribution Slider
![Goody Hut Frequency](/IMAGES/Goody_Hut_Distribution.png)

Provides a slider for decreasing or increasing the relative amount of Goody Huts that will appear on the selected map; this slider defaults to 100%, and adjusts in steps of 25% in a range of 25% - 500%, inclusive. This slider also appears in the picker window.

## Bonus Rewards
![Bonus Rewards](/IMAGES/Bonus_Rewards.png)

Provides a dropdown menu for selecting the total number of potential reward(s) to receive from each Goody Hut. At the default setting of 1, nothing changes. With any of the "up to X" settings, X total rewards will be received from each Goody Hut, with any additional rewards beyond the first randomly selected from the pool of enabled rewards using a custom method. In certain circumstances, fewer than X rewards will be received; these include:
- When any Hostile Villagers reward is selected as a reward, whether it's the first or a bonus reward. When this happens, it will be the last reward granted by this Goody Hut; if it is the first reward, it will be the only reward.

Any received bonus reward will generate an ingame panel notification with details about the received reward. These notifications use one of the built-in "user-defined" types, so the icon used is subject to frequent change, as the game itself cannot seem to consistently use the same icon.

Bonus Rewards, if enabled, can only be received from a Goody Hut. There are two main consequences of this:
1. The meteor strike reward will not provide any bonus rewards. For now, we're going to assume that the meteor is not the wreckage of advanced replicator technology from beyond the stars.
2. Civilization traits and other abilities that provide a reward when another condition is met will also not provide any bonus rewards. Nice try, Gilgamesh.

## Equalized Reward Chances
![Equalize Rewards](/IMAGES/Equalize_Tribal_Village_Rewards.png)

Provides a checkbox option which, when enabled, assigns every enabled reward in a category an equal share of that category's Weight. This results in most enabled rewards having a roughly equal chance of being selected. Final actual chances will vary with the number of enabled rewards and/or the selected ruleset; with Standard rules and all available rewards enabled, these chances are as follows:
- ~ 7.69% villager secrets type reward (1 reward in type)
- ~ 2.56% specific (anti) cavalry type or military type reward (3 rewards in each parent type: ~ 7.69% for each parent type)
- ~ 1.92% any other specific reward (4 rewards in each parent type: ~ 7.69% for each parent type)

With Rise and Fall rules and all available rewards enabled, the above chances adjust to 7.14%, 2.38%, and 1.79%, respectively.

With Gathering Storm rules and all available rewards enabled, the above chances adjust to 5.89%, 1.96%, and 1.47%, respectively. Additionally, the following chances exist:
- ~ 5.89% meteor strike type reward (1 reward in type)

Fewer enabled rewards in a category will result in a greater chance of each enabled reward being chosen if its parent category is chosen. Fewer enabled categories will result in a greater chance of each enabled category being chosen. Ultimately, while the actual values may vary somewhat, they will be fairly close together as demonstrated above.

## Hostile Villagers
### Hostiles After Reward
![Hostiles After Reward](/IMAGES/Hostiles_After_Reward.png)

Whenever a reward is earned from a Goody Hut, there is a chance that some of the villagers will be displeased that their tribe treated with outsiders. This does not apply to the meteor strike reward, or to any rewards earned via trait or ability as outlined above; it only applies to rewards received from an actual Goody Hut. This chance fluctuates based on several factors:

- The selected difficulty level (Base chance increases with higher settings).
- The method used to pop the hut (Increased chance with a reward received via border expansion or by a unit susceptible to instant removal like capture, condemnation, plunder, or return to another tile; decreased chance with most non-recon military units).
  - Yes, decreased chance with most military units. The villagers may be primitive, but they're smart enough to not really want to dick around with units geared for warfare.
- The rarity tier of any received reward(s) (Chance increases with more valuable rewards. If bonus rewards are enabled, the cumulative value of all received rewards will be used; this can either have very little effect or it can seriously wreck your day, depending on how many rewards were received and how rare each was).
- The current game era (Increased chance with each successive era).

On the default difficulty setting, in the Ancient era, with one reward, there should be a 5-16% chance of encountering hostile villagers, depending on the received reward and the method in which it was received. This chance scales with each successive era, so that in the Future era, it will be 45-144%. On the lowest difficulty setting, the chance should start at 2-7% in the Ancient era, and scale from there. On the highest difficulty setting, the chancce should start at 9-28%, and scale from there. If bonus rewards are enabled, these chances increase slightly based upon the rarity of each reward received beyond the first. Thus, on higher difficulties, late enough in the game and with sufficient quantity and/or quality of rewards, encountering hostile villagers is no longer a chance, but instead becomes a guarantee.

If the villagers are hostile, they will retaliate by organizing into one barbarian melee unit in a nearby tile. If they are very hostile, more than one unit will appear, and some will be ranged. If they are downright pissed off, they will organize into a new barbarian camp near the site of their former village, and they will spawn a handful of units. If Horses are located near the site of the former village, there is a chance that any unit(s) that appear may instead be mounted; this chance increases with each additional nearby source of Horses. Villager hostility level greatly fluctuates based on the same factors as the chance to be hostile above, and like above, eventually multiple units, and even a camp, will move from being a chance to a guarantee.

### Hostiles As Reward
![Hostiles As Reward](/IMAGES/Hostile_Villagers.gif)

What's that? "Not masochistic enough!" you say? Then how about a new reward type that's nothing but hostile villagers "rewards?" They won't even lure you in with the carrot before reaching for the stick, they just go straight for the stick, and the stick is pointy. When enabled, these rewards can be selected by the rewards system like any other reward, and have pre-determined villager hostility values, as shown in the table above. Hostility increases as rarity does; in fact, one of these rewards is selected internally after calculating villager hostility to place any hostiles that appear after any other reward.

Any hostile villagers that appear as or after a reward will generate an ingame panel notification with details.

To compensate for the increased numbers of barbarian units that are likely to be present now, the experience and level caps from fighting such units have been increased. You still aren't going to get a fully-promoted unit from fighting barbarians, but at least you'll be able to get more than a single promotion.

### Hostiles Configuration
Hostile Villagers as a reward are configurable via the picker. For Hostile Villagers after a reward, there is a new dropdown option in Advanced Setup to select the chances of an appearance following any other Goody Hut reward. Available choices are:
- Never (hostile villagers will NOT appear)
- Maybe ( * this is the default option; a chance for hostile villagers to appear, as described above)
- Always (hostile villagers will ALWAYS appear; their hostility level will be as described above)
- Always + Increased Hostility (hostile villagers will ALWAYS appear, and their hostility level will be hyper-elevated)

Setting this option to 'Never', while also disabling all 'Hostile Villagers' reward type(s) via the picker, will remove any chance of encountering hostile villagers entirely, whether as or after a reward.

## Villager Secrets
![Villager Secrets](/IMAGES/Villager_Secrets.png)

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

Provides a checkbox option that, when enabled, will produce __EXTREMELY__ verbose logging output for debugging purposes. This is disabled by default, and should remain disabled unless absolutely necessary.
- Again, logging output will be __EXTREMELY__ verbose when this option is enabled; unless this verbosity is required, it is recommended that this option remain disabled.

# Known Shortcomings, Limitations, and Bugs
Receiving the "2 free civics" reward prior to unlocking the Code of Laws civic results in only receiving 1 free civic, which will be Code of Laws. As this is only really a problem during the extremely-early game (turns 1-20) prior to manual unlocking of Code of Laws, and the potential fix is cumbersome and ultimately unrewarding to implement, it is likely to remain unchanged.

The Villager Secrets reward can only be awarded to a Player a certain number of times before becoming useless. When this reward is received, and this limit has been reached for the Player, then unless this reward is the only enabled reward, a new reward will be randomly seleted instead. If this reward IS the only enabled reward, then instead nothing will happen.

Unit Ability rewards apply to any valid unit(s) in formation with the popping unit, as well as the popping unit. These rewards apply to each valid unit up to one time for the lifetime of that unit. For example, a Builder, Missionary, or Great Person can and will receive increased movement once, but not additional combat strength. Currently, the end result of this is that nothing will happen when an Ability reward is received and all valid unit(s) have already received the ability.

Unit Promotion rewards apply to any valid unit(s) in formation with the popping unit, as well as the popping unit. These rewards can be applied an unlimited number of times to any specific unit; however, built-in limitations prevent a specific unit from earning more experience than is needed for its next promotion, so any experience earned beyond this amount by any unit will be lost.

The Upgrade Unit reward applies to any valid unit(s) in formation with the popping unit, as well as the popping unit. Upgraded unit(s) retain any promotions and/or abilities attached to the old unit(s); however, they lose any remaining movement for the current turn, as well as any experience accrued towards their next promotion. Currently, specific units' actual experience totals cannot directly be determined; therefore, to balance any potential lost experience, any upgraded unit will be granted enough experience for its next promotion. Since this reward ultimately yields at least one new unit and one new promotion, it is a double-dose; it is an Upgrayedd.
- Kids, ask your parents.

Great effort has been made to ensure unit rewards only fire when a valid unit has been identified, but issues may still arise when certain rewards are granted via border expansion. Please open a new pull request to address any such issues.

Errors relating to the Wondrous Goody Huts community project may appear in the Database.log and Lua.log files when it is not present, or when it is present and disabled. Any such errors can be safely ignored.

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
## General
If your mod alters any _existing_ Goody Hut (sub)types, unless it is also using a ludicrously high load order to apply these changes, they will likely be overwritten by EGHV due to its ridiculously high load order. Conflicts __WILL__ arise _regardless of relative load order_ if these alterations deviate substantially from those of EGHV.

## Configuration Database
EGHV adds the following custom tables to the game's Configuration SQLite database:
- ContentFlags
- TribalVillages

If your mod uses any similarly-named tables, conflicts __WILL__ arise.

## Gameplay Database
EGHV adds new item(s) to and/or modifies existing item(s) in the following tables in the game's Gameplay SQLite database:
- Types
- TypeTags
- Building
- BuildingConditions
- BuildingModifiers **
- BuildingReplaces
- Building_YieldChanges
- GlobalParameters
- GoodyHuts
- GoodyHutSubTypes
- GoodyHutSubTypes_XP2 **
- Improvements
- Modifiers
- ModifierArguments
- ModifierStrings
- UnitAbilities
- UnitAbilityModifiers

[ ** ] Requires Gathering Storm

If your mod operates on any similarly-named item(s) in any of the above named table(s), these change(s) will likely be overwritten by EGHV. Conflicts __WILL__ arise _regardless of relative load order_ if these changes deviate substantially from those of EGHV.

## Gameplay Scripts
EGHV employs the following new custom gameplay scripts:
- EnhancedGoodies.lua
- IngameGUE.lua

If your mod employs any gameplay scripts with similar names, conflicts __WILL__ arise.

## Frontend
EGHV replaces the following existing Frontend context file(s):
- AdvancedSetup.lua and AdvancedSetup.xml
- GameSetupLogic.lua
- HostGame.lua and HostGame.xml
- Mods.lua

EGHV adds the following new Frontend context file(s):
- GoodyHutPicker.lua and GoodyHutPicker.xml

If your mod replaces any of the above existing files, or adds any similarly-named new ones, compatibility issues __WILL__ arise.

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
