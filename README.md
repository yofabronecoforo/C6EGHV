# Enhanced Goodies and Hostile Villagers for Civilization VI
![Advanced Setup](/IMAGES/Advanced_Setup.png)

The above image, and all other image(s) reflecting game content herein, reflect an Advanced Setup with Gathering Storm rules; actual configuration options will vary with different rules and/or available additional content.

# Overview
A mod that provides a fairly comprehensive extension to and overhaul of the Tribal Village (Goody Hut) rewards system. Many new Frontend options relating to Goody Huts are available, including:
- A picker for choosing exactly which Goody Hut reward(s), if any, will have a chance of appearing ingame.
- A slider for decreasing or increasing the number of Goody Huts that will appear ingame, relative to the baseline amount for the selected map and/or size.
- A dropdown menu for selecting an amount of possible bonus reward(s), which may be provided in addition to the usual reward from a Goody Hut.
- A checkbox flag for equalizing the chances of receiving all enabled reward(s).

In addition, the number of available ingame Goody Hut rewards has greatly increased for each official ruleset:

Ruleset in use | Standard | Rise and Fall | Gathering Storm
------- | ------- | ------- | -------
Rewards (Types) built-in | 18 (6) | 18 (6) | 23 (8)
Rewards (Types) with EGHV | 52 (11) | 56 (12) | 66 (15)

Many of these rewards are implemented via a combination of the built-in Modifiers system and the Lua scripting system, as this allows these rewards to function as intended.

Finally, Hostile Villagers as (and now, potentially following) a reward make their return.

EGHV is compatible with mods that replace the AdvancedSetup, GameSetupLogic, and HostGame Frontend Lua context files. See "Conflicts-Frontend-Context" below for details and limitations.

# Localization
When obtained via any of the official channels referenced in the #Installation section below, releases contain new Frontend and Ingame text fully localized in the following language(s):
- English (en_US)
- Spanish (es_ES)
- French (fr_FR)

Please report any conspicuous absent text, grammatical errors, inaccurate translations, or instances of localization placeholders (i.e. LOC_SOME_TEXT_HERE), when using any of the above languages.

# Features
## Goody Huts
![Goody Hut Picker](/IMAGES/Goody_Hut_Picker.png)

EGHV modifies existing Goody Hut rewards, and provides several new rewards in several new categories.

Minimum-turn requirements have been set to 0 for all __DEFINED__ and __ENABLED__ rewards. This means that these rewards will be available from turn 1 on.

There is an issue with the 2 free civics reward where only 1 civic will be granted when no more than that are available to be researched, for example before Code of Laws has been unlocked.

### Standard
![Standard Rewards](/IMAGES/Standard.gif)

These rewards are available for all rulesets. Existing and new rewards have been rebalanced as follows:

Goody Hut Type (Weight) | Common (55) | Uncommon (30) | Rare (10) | Legendary (5)
------ | ------ | ------ | ------ | ------
Culture | 1 civic boost | 2 civic boosts | 1 civic [1] [2] | 2 civics [1] [3]
Faith | +20 faith | +60 faith | +100 faith | +1 relic [4]
Gold | +40 gold | +80 gold | +120 gold | +1 trade route [1]
Science | 1 tech boost | 2 tech boosts | 1 tech | 2 techs [1]
Survivors | +1 new population [5] | 1 Builder [6] | 1 Trader [7] | 1 Settler [6] [8]

1. This reward is provided by EGHV
2. Code of Laws will be the free Civic provided by this reward if no Civics have been unlocked
3. Code of Laws will be the __ONLY__ free Civic provided by this reward if no Civics have been unlocked, and the second free Civic will be lost. C'est la vie
4. The "one relic" Culture-type reward is now a Faith-type reward
5. The built-in "add population" Survivors-type reward modifier would only correctly fire once per Goody Hut; when this reward is received multiple times from the same Goody Hut, additional new population beyond the first will now bypass this modifier and be provided by Lua directly
6. The unit provided by this reward will now spawn in a plot near the Goody Hut that provided the reward
7. This reward is unmodified, and the provided Trader unit will spawn wherever it was originally supposed to; this prevents it from being rendered essentially unusable
8. The defined-but-disabled "one settler" Survivors-type reward is now enabled

### Military-Type
![Military Rewards](/IMAGES/Military-type.gif)

Built-in Military-type rewards have been entirely disabled and reworked. For all rulesets, a reward of this type now provides a new unit as follows:

Goody Hut Type (Weight) | Common (55) | Uncommon (30) | Rare (10) | Legendary (5)
------ | ------ | ------ | ------ | ------
Military | Recon | Melee OR Ranged OR Anti-Cavalry | Heavy Cavalry OR Light Cavalry | Support OR Siege OR a Military Engineer

Any unit provided by a Military-type reward will now spawn in a plot near the Goody Hut that provided the reward. Additionally, with the exception of the free Military Engineer, any unit provided by a Military-type reward will now be Era-appropriate.

### New Standard Types
![EGHV Rewards](/IMAGES/EGHV.gif)

These rewards are provided by EGHV for all rulesets:

Goody Hut Type (Weight) | Common (55) | Uncommon (30) | Rare (10) | Legendary (5)
------ | ------ | ------ | ------ | ------
Abilities [1] [3] | +1 sight | +20 healing per turn | +1 movement | +10 combat strength
Envoys [2] | 1 envoy | 2 envoys | 3 envoys | 4 envoys
Hostiles | low hostility | medium hostility | high hostility | maximum hostility
Promotions [1] [4] | 5 experience | 10 experience | 15 experience | upgrade and/or experience for next promotion [5]
Secrets [6] | villager secrets (100)

1. Rewards of this type apply to any valid unit(s) when obtained via exploration; they should be replaced by EGHV when obtained via border expansion
2. When the Gathering Storm expansion is present and in use, new rewards provided by this EGHV type supercede the "free envoy" Diplomacy-type reward, which is disabled
3. Unit Ability rewards apply to any valid unit(s) in formation with the popping unit, as well as the popping unit. These rewards apply to each valid unit up to one time for the lifetime of that unit. For example, a Builder, Missionary, or Great Person can and will receive increased movement once, but not additional combat strength. Currently, the end result of this is that nothing will happen when an Ability reward is received and all valid unit(s) have already received the ability.
4. Unit Promotion rewards apply to any valid unit(s) in formation with the popping unit, as well as the popping unit. These rewards can be applied an unlimited number of times to any specific unit; however, built-in limitations prevent a specific unit from earning more experience than is needed for its next promotion, so any experience earned beyond this amount by any unit will be lost.
5. The Upgrade Unit reward provides one or more of the following to any valid unit(s) in formation with the popping unit, as well as the popping unit:
    1. Any unit with a valid promotion class, that has NOT yet earned any promotions, will receive a free upgrade IF it also has a valid upgrade path. Due to built-in limitations, this "upgrade" consists of destroying the existing unit and placing a new unit in the last plot the existing unit occupied. Since promotions and experience cannot currently be transferred easily and cleanly to a new unit, any unit with any promotions will be ignored. Upgraded unit(s) DO retain any abilities attached to the old unit(s); however, they lose any remaining movement for the current turn.
    2. Any unit with a valid promotion class, including any unit upgraded by (i) above, will receive enough experience for its next promotion.
    3. Units without a valid promotion class or upgrade path will be skipped by this reward; currently, this results in nothing happening.
6. Rewards of this type have a specialized nature and inherently equalized chances of being selected. They are explained in detail below.

### New Rise and Fall Types
![EGHV Rewards](/IMAGES/Expansion1.gif)

These rewards are provided by EGHV for Rise and Fall and later ruleset(s):

Goody Hut Type (Weight) | Common (55) | Uncommon (30) | Rare (10) | Legendary (5)
------ | ------ | ------ | ------ | ------
Governors [1] | 1 governor title | 2 governor titles | 3 governor titles | 4 governor titles

1. When the Gathering Storm expansion is present and in use, new rewards provided by this EGHV type supercede the "free governor title" Diplomacy-type reward, which is disabled

### New Gathering Storm Types
![EGHV Rewards](/IMAGES/Expansion2.gif)

These rewards are provided by EGHV for Gathering Storm and later ruleset(s):

Goody Hut Type (Weight) | Common (55) | Uncommon (30) | Rare (10) | Legendary (5)
------ | ------ | ------ | ------ | ------
Diplomacy [1] | +10 diplomatic favor | +20 diplomatic favor | +30 diplomatic favor | +50 diplomatic favor
Meteor | meteor-strike site (100)
Resources [2] [3] | +10 strategic resources | +20 strategic resources | +30 strategic resources | +50 strategic resources

1. New rewards provided by this EGHV type supercede the "free diplomatic favor" Diplomacy-type reward, which is disabled
2. New rewards provided by this EGHV type supercede the "free strategic resources" Military-type reward, which is disabled
3. Currently there is a bug causing rewards of this type to provide nothing when no types of strategic resources have been revealed

## Goody Hut Reward Picker
![Goody Hut Picker](/IMAGES/Picker_Detail.gif)

EGHV provides a new picker window for selecting the specific Goody Hut reward(s) that can appear ingame, available in the game's Advanced Setup. Available content in the picker will vary with the selected ruleset and/or compatible enabled content. Available content can be sorted by:
- Name (alphabetical by individual reward subtype)
- Type (alphabetical by individual reward subtype, then grouped by parent reward type)
- Rarity (alphabetical by individual reward subtype, then ascending by rarity tier)

Disabling all available reward(s) via the picker will cause the "No Goody Huts" game option to be implicitly enabled.

The tooltip for the Goody Hut picker reflects the source(s) of its content based on the selected ruleset and/or any currently available known content as calculated at game launch. Its button text reflects the total amount of available items(s) when all items in the picker are selected.
- This functionality extends to the built-in City-States, Leaders, and Natural Wonders pickers.

## Goody Hut Distribution Slider
![Goody Hut Frequency](/IMAGES/Goody_Hut_Distribution.png)

EGHV provides a slider for decreasing or increasing the relative amount of Goody Huts that will appear on the selected map; this slider defaults to 100%, and adjusts in steps of 25% in a range of 25% - 500%, inclusive. This slider also appears in the picker window.

## Reward Roller
When some rewards are received and have an invalid target, EGHV will use a custom method to randomly select a replacement reward from the pool of available rewards. This method is also used to provide a(ny) bonus reward(s) as outlined below.

## Bonus Rewards
![Bonus Rewards](/IMAGES/Bonus_Rewards.png)

EGHV provides a dropdown menu for selecting the total number of potential reward(s) to receive from each Goody Hut. At the default setting of 1, nothing changes. With any of the "up to X" settings, up to X total rewards will be received from each Goody Hut, with any additional rewards beyond the first randomly selected from the pool of enabled rewards using the custom Reward Roller method.

In certain circumstances, fewer than X rewards will be received; these include:
- When any Hostile Villagers reward is selected as a reward, whether it's the first or a bonus reward. When this happens, it will be the last reward granted by this Goody Hut; if it is the first reward, it will be the only reward.

Any received bonus reward will generate an ingame panel notification with details about the received reward. These notifications use one of the built-in "user-defined" types, so the icon used is subject to frequent change, as the game itself cannot seem to consistently use the same icon.

Bonus Rewards, if enabled, can only be received from a Goody Hut. There are two main consequences of this:
1. The meteor strike reward will not provide any bonus rewards. For now, we're going to assume that the meteor is not the wreckage of advanced replicator technology from beyond the stars.
2. Civilization traits and other abilities that provide a reward when another condition is met will also not provide any bonus rewards. Nice try, Gilgamesh.

## Equalized Reward Chances
![Equalize Rewards](/IMAGES/Equalize_Tribal_Village_Rewards.png)

EGHV provides a checkbox option which, when enabled, assigns every enabled reward in a category a Weight equal to that category's Weight. This results in most enabled rewards having a roughly equal chance of being selected.

## Hostile Villagers
### Hostiles After Reward
![Hostiles After Reward](/IMAGES/Hostiles_After_Reward.png)

Whenever a reward is earned from a Goody Hut, there is a chance that some of the villagers will be displeased that their tribe treated with outsiders. This does not apply to the meteor strike reward, or to any rewards earned via trait or ability as outlined above; it only applies to rewards received from an actual Goody Hut. This chance fluctuates based on several factors:

- The selected difficulty level (Base chance increases with higher settings).
- The method used to pop the hut (Increased chance with a reward received via border expansion or by a unit susceptible to instant removal like capture, condemnation, plunder, or return to another tile; decreased chance with most non-recon military units).
  - Yes, decreased chance with most military units. The villagers may be primitive, but they're smart enough to not really want to dick around with units geared for warfare.
- The rarity tier of any received reward(s) (Chance increases with more valuable rewards. If Bonus Rewards are enabled, the cumulative value of all received rewards will be used; this can either have very little effect or it can seriously wreck your day, depending on how many rewards were received and how rare each was).
- The current game era (Increased chance with each successive era).

On the default difficulty setting, in the Ancient era, with one reward, there should be a 5-16% chance of encountering hostile villagers, depending on the received reward and the method in which it was received. This chance scales with each successive era, so that in the Future era, it will be 45-144%. On the lowest difficulty setting, the chance should start at 2-7% in the Ancient era, and scale from there. On the highest difficulty setting, the chancce should start at 9-28%, and scale from there. If bonus rewards are enabled, these chances increase slightly based upon the rarity of each reward received beyond the first. Thus, on higher difficulties, late enough in the game and with sufficient quantity and/or quality of rewards, encountering hostile villagers is no longer a chance, but instead becomes a guarantee.

If the villagers are hostile, they will retaliate by organizing into one barbarian melee unit in a nearby tile. If they are very hostile, more than one unit will appear, and some will be ranged. If they are downright pissed off, they will organize into a new barbarian camp near the site of their former village, and they will spawn a handful of units. If Horses are located near the site of the former village, there is a chance that any unit(s) that appear may instead be mounted; this chance increases with each additional nearby source of Horses. Villager hostility level greatly fluctuates based on the same factors as the chance to be hostile above, and like above, eventually multiple units, and even a camp, will move from being a chance to a guarantee.

Hostile Villagers AFTER any other reward are configurable via a new dropdown option in Advanced Setup. Available settings are:
- Never (hostile villagers will NOT appear)
- Maybe ( * this is the default option; a chance for hostile villagers to appear, as described above)
- Always (hostile villagers will ALWAYS appear; their hostility level will be as described above)
- Always + Increased Hostility (hostile villagers will ALWAYS appear, and their hostility level will be hyper-elevated)

Setting this option to 'Never', while also disabling all 'Hostile Villagers' reward type(s) via the picker, will remove any chance of encountering hostile villagers entirely, whether as or after a reward.

### Hostiles As Reward
![Hostiles As Reward](/IMAGES/Hostile_Villagers.gif)

What's that? "Not masochistic enough!" you say? Then how about a new reward type that's nothing but hostile villagers "rewards?" They won't even lure you in with the carrot before reaching for the stick, they just go straight for the stick, and the stick is pointy. When enabled, these rewards can be selected by the rewards system like any other reward, and have pre-determined villager hostility values. Hostility increases as "reward" rarity does; in fact, one of these rewards is selected internally after calculating villager hostility to place any hostiles that appear after any other reward.

Hostile Villagers AS a "reward" are configurable via the picker like any other available reward.

### Hostiles Errata
Any hostile villagers that appear as or after a reward will generate an ingame panel notification with details.

To compensate for the increased numbers of barbarian units that are likely to be present now, the experience and level caps from fighting such units have been increased. You still aren't going to get a fully-promoted unit from fighting barbarians, but at least you'll be able to get more than a single promotion.

## Villager Secrets
![Villager Secrets](/IMAGES/Villager_Secrets.gif)

Villager Secrets are a group of specialized rewards which have an inherently equalized chance of being selected when enabled. When one is received, it unlocks the ability to build a Villager Totem building. Each reward unlocks a different Totem, and each of these new buildings provides a boost to a different yield:

Villager Totem | Yield Modifier
------- | -------
Amenities | +4
Culture | +4
Faith | +4
Diplomatic Favor [1] | +4
Food | +4
Gold | +8
Production | +4
Science | +4

1. Requires Gathering Storm

Once a particular Totem has been unlocked, if the reward that provides it is received again, instead a free Totem of that type will be placed in a City that does not already have one. If all cities have that Totem already, or if there are otherwise no cities in which to place it, instead nothing will happen.

With judicious use of the distribution slider and bonus reward features, and all available rewards enabled, it is likely that the number and types of unlocked Totem(s) will differ for a given Player from game to game. On the flip side, if the slider and/or bonuses are cranked to max, or the pool of available rewards is greatly narrowed - particularly to only Secrets-type rewards - via the picker, or some combination of these occurs, it is likely that all Players will shortly unlock the ability to build every Totem.

If Hostile Villagers After a Reward are enabled, rewards of this type will tend to provoke elevated hostility.

## Additional Advanced Setup
### No Barbarians
![No Barbarians](/IMAGES/No_Barbarians.png)

Enabling 'No Barbarians' will override any hostiles-related options and/or selections above, and will also remove any chance of encountering hostile villagers, whether as or after a reward. The tooltip for this option has been updated to reflect this.

### No Tribal Villages
![No Tribal Villages](/IMAGES/No_Tribal_Villages.png)

Enabling 'No Tribal Villages' will override any selections made with the Goody Hut picker. It will also override any other Goody-Hut-related values, including hostiles-related options and/or selections, but will not otherwise affect Barbarians. The tooltip for this option has been updated to reflect this.

### Debugging
![EGHV Debugging](/IMAGES/EGHV_Debugging.png)

Provides a checkbox option that, when enabled, will produce __EXTREMELY__ verbose logging output for debugging purposes. This is disabled by default, and should remain disabled unless absolutely necessary.
- Again, logging output will be __EXTREMELY__ verbose when this option is enabled; unless this verbosity is required, it is recommended that this option remain disabled.

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
### Incompatible Mods
The following community projects are known to alter one or more of the game files also modified by EGHV:
- (placeholder)

To prevent breakage, when any of the above mod(s) are enabled, EGHV will be disabled. Further, EGHV cannot be enabled while any of the above mod(s) are also enabled.

### Compatible Mods
Should work with other mods that add new Goody Hut (sub)types, with the following caveats:
- Any rewards which EGHV does NOT recognize will **NOT** appear in the Goody Hut picker; these must be configured and recognized to do so. If you would like any Goody Huts provided by a particular community project to be reflected within the picker when said project is enabled, please open an issue with the project details, and it will be considered.
  - Note that the above means EGHV has no interaction with unrecognized Goody Hut rewards beyond potentially spawning hostile villagers after receiving such a reward.

See the Conflicts section below for exceptions.

New Goody Hut rewards provided by recognized content will appear in the Goody Hut picker when such content is enabled. Such content can then be manipulated via the picker and any other configuration settings EGHV provides. All such content should function normally as the Primary reward, but may require additional configuration to be provided as a Bonus Reward.

EGHV is compatible with mods that replace the AdvancedSetup, GameSetupLogic, and HostGame Frontend Lua context files. See "Conflicts-Frontend-Context" below for details and limitations.

#### Wondrous Goody Huts
This community project is explicitly recognized by EGHV.
- There does not appear to be a way of initializing the selection status of individual items in the picker. All rewards provided by WGH will therefore initialize as selected, even those normally disabled by default; such rewards will be enabled by EGHV if left selected.
- Rewards provided by WGH are supported as the only or Primary reward with no further configuration required.
- Rewards provided by WGH are supported as a Bonus reward when WGH methods are available to EGHV via the global ExposedMembers table; this is currently accomplished by including a modified version of WGH's script when EGHV loads.

# Installation
## Automatic
[Subscribe to EGHV in the Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2474051781) to automatically download and install the latest published release, and to automatically receive any updates as they are published to the Workshop.

## Manual
Download the [latest release](https://github.com/zzragnar0kzz/C6EGHV/releases/latest) and extract it into the game's local mods folder. Alternately, clone the repository into the game's local mods folder using your preferred tools. The local mods folder varies:
- Windows : `$userprofile\Documents\My Games\Sid Meier's Civilization VI\Mods`
- Linux : 
- MacOS : 

To update to a newer release, clone or download the latest release as described above, overwriting any existing items in the destination folder.

# Conflicts
## General
If your mod alters any _existing_ Goody Hut (sub)types, unless it is also using a ludicrously high load order to apply these changes, they will likely be overwritten by EGHV due to its ridiculously high load order. Conflicts __WILL__ arise _regardless of relative load order_ if these alterations deviate substantially from those of EGHV.

## Frontend
### Database
EGHV adds the following custom tables to the game's Configuration SQLite database:
- ContentFlags
- TribalVillages

If your mod uses any similarly-named tables, conflicts __WILL__ arise.

### Context
EGHV replaces the following existing Frontend context file(s):
- MainMenu.xml

The only modifications to this file consist of changing the filenames used for the "AdvancedSetup" and "HostGame" Lua contexts. The EGHV replacements for these files are:
- EnhancedAdvancedSetup.lua and EnhancedAdvancedSetup.xml
- EnhancedHostGame.lua and EnhancedHostGame.xml

The above new XML files contain changes to incorporate EGHV's new Goody Hut picker as well as the replacement Natural Wonders picker from [ENWS](https://steamcommunity.com/sharedfiles/filedetails/?id=2273495829), and in the case of EnhancedAdvancedSetup, to allow for interoperability with [YnAMP](https://steamcommunity.com/sharedfiles/filedetails/?id=871861883) when it is also loaded. YnAMP-specific buttons in the Advanced Setup header will be hidden when it is not loaded. When ENWS is not loaded, errors will be generated in the log; these are due to the missing custom picker, and as the game should fall back to the default picker, they can be safely ignored.

The above new Lua files contain directives to include the currently active AdvancedSetup or HostGame scripts for SP and MP setups. These will either be the base versions found in the game's UI/FrontEnd folder, or the last imported version from another mod, such as YnAMP. Necessary changes to AdvancedSetup and HostGame are now contained in separate files:
- CommonFrontend.lua    contains new code used by both the AdvancedSetup and HostGame contexts
- AdvancedSetup_EGHV.lua    contains modifications to existing code in the AdvancedSetup context
- GameSetupLogic_EGHV.lua    contains modifications to existing code in the GameSetupLogic script, which is used by both the AdvancedSetup and HostGame contexts
- HostGame_EGHV.lua    contains modifications to existing code in the HostGame context

The above files are included by directive in the appropriate contexts. Additional directives will, as appropriate, include any other imported file whose name matches any of the following patterns:
- AdvancedSetup_
- GameSetupLogic_
- HostGame_

Doing this simulates the behavior of the Ingame "ReplaceUIScript" modinfo tag, which does nothing in the Frontend. This removes the need to overwrite the aforementioned original scripts with new versions containing any necessary changes, and allows for such changes to be placed in separate files that are loaded as needed after the existing scripts are loaded. When care is exercised, this allows multiple mods to make precision changes to these scripts and interoperate with one another. Crucially, since EGHV's load order generally makes it one of the last mods loaded, if not the last one loaded, it also allows for EGHV to function alongside other mods that __DO__ replace the original scripts, without resorting to a Frankenstein's monster of a single script containing changes from different mods. This functionality has been tested with YnAMP, but it *should* work with any mod that replaces the AdvancedSetup, GameSetupLogic, and/or HostGame script(s); however, there are limitations:
- EGHV cannot make the game retain multiple versions of a script with the same name, so only the last imported version of each of these files will be used. This means other mods that overwrite one or more of these scripts will likely continue to conflict with each other.
- Mods that make extensive changes to the AdvancedSetup and/or HostGame XML templates are not supported by EGHV. Notably, this applies to Sukitract's Civ Selection Screen.

To implement the new Goody Hut picker, EGHV adds the following new Frontend context file(s):
- GoodyHutPicker.lua and GoodyHutPicker.xml

If your mod replaces any of the files named above, or adds any similarly-named new ones, compatibility issues __WILL__ arise.

## Ingame
### Database
EGHV adds the following custom tables to the game's Gameplay SQLite database:
- GoodyHutsByHash
- GoodyHutSubTypesByHash
- HostileUnits
- UnitRewards

If your mod uses any similarly-named tables, conflicts __WILL__ arise.

EGHV modifies the structure of, adds new item(s) to, and/or modifies existing item(s) in the following tables in the game's Gameplay SQLite database:
- Types
- TypeTags
- Building
- BuildingConditions
- BuildingModifiers [1]
- BuildingReplaces
- Building_YieldChanges
- GlobalParameters
- GoodyHuts
- GoodyHutSubTypes
- GoodyHutSubTypes_XP2 [1]
- Improvements
- Modifiers
- ModifierArguments
- ModifierStrings
- UnitAbilities
- UnitAbilityModifiers

1. Requires Gathering Storm

If your mod operates on any similarly-named item(s) in any of the above named table(s), these change(s) will likely be overwritten by EGHV. Conflicts __WILL__ arise _regardless of relative load order_ if these changes deviate substantially from those of EGHV.

### Gameplay Scripts
EGHV employs the following new custom gameplay scripts:
- EGHV.lua
- EnhancedGoodies.lua
- HostileVillagers.lua
- BonusRewards.lua

If your mod employs any gameplay scripts with similar names, conflicts __WILL__ arise.

# Art
256x256 px source textures for EGHV content ganked from the pantry.

Additionally, one or more 256x256 px source textures ganked from the following:
- [Civilization Wiki](https://civilization.fandom.com/)

Additional texture sizes derived from the above sources.

Ingame assets for the various Villager Totem buildings are recycled from the built-in Monument building.

# Special Thanks
Extra special thanks to the following for their direct contributions and/or insight:
- SailorCat

EGHV generally relies on knowledge gleaned from the following:

* The [Civilization Fanatics](https://www.civfanatics.com/) community, particularly the [Civ6 - Creation & Customization](https://forums.civfanatics.com/forums/civ6-creation-customization.541/) forums
* The [Civilization VI Workshop](https://steamcommunity.com/app/289070/workshop/) on Steam
* The [Civilization VI Modding Companion](https://docs.google.com/spreadsheets/d/1hQ8zlEHl1nfjCWvKqOlkDACezu5-igfQkVcOxeE_KG0/edit#gid=1678767919) by ChimpanG, et al
* The [Civilization 6 Modding Guide](https://forums.civfanatics.com/threads/lees-civilization-6-modding-guide.644687/) by LeeS
* [DB's Font Icons and Colors](https://steamcommunity.com/sharedfiles/filedetails/?id=1846090643) by DB

The Hostile Villagers feature relies on knowledge gleaned from the following:

* [Getting an extra bonus from goody huts](https://forums.civfanatics.com/threads/getting-an-extra-bonus-from-goody-huts.616695/#post-14780879) by LeeS
* [Barbarians Evolved](https://steamcommunity.com/sharedfiles/filedetails/?id=2164194796) by Charsi
* [Add a Feature to a Plot During Game time with Lua](https://forums.civfanatics.com/threads/add-a-feature-to-a-plot-during-game-time-with-lua.645149/#post-15435909) by LeeS
* [OnGoodyHutReward event, what are the parameters?](https://forums.civfanatics.com/threads/ongoodyhutreward-event-what-are-the-parameters.642591/#post-15398744) by LeeS
* [How do you catch an era change event in Lua?](https://forums.civfanatics.com/threads/how-do-you-catch-an-era-change-event-in-lua.614454/#post-15144387) by Tiramisu

The Goody Hut picker and frequency slider features rely on knowledge gleaned from the following:

* [Configurable Goody Huts](https://steamcommunity.com/sharedfiles/filedetails/?id=2462745561) by Sailor Cat

The Unit Ability rewards, Villager Secrets reward, and Bonus Rewards features rely on knowledge gleaned from the following:

* [Questions regarding limitations of Mods](https://forums.civfanatics.com/threads/questions-regarding-limitations-of-mods.663297/) by dunkleosteus, et al
* [Wondrous Goody Huts](https://steamcommunity.com/sharedfiles/filedetails/?id=2384120911) by Sailor Cat
* [Test Dummy Techs](https://forums.civfanatics.com/threads/solved-need-help-creating-custom-trait.621558/#post-14849718) by LeeS

Extra special thanks to these contributors, and to the greater community, without whom the common knowledge required for the remaining features of this mod would not be as common.
