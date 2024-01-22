[h1]Enhanced Goodies and Hostile Villagers (EGHV) for Civilization VI[/h1]

A mod which enables additional Frontend and Ingame settings related to Tribal Village (Goody Hut) rewards.

EGHV performs a fairly comprehensive overhaul of and extension to the Goody Hut reward system. Many new Frontend options relating to Goody Huts are available within the game's single-player Advanced Setup and multi-player Host Game, including:

[list]
[*]A custom picker for selecting exactly which rewards, if any, will have a chance of being provided by a Goody Hut ingame. As with the built-in pickers for City-States and Natural Wonders, undesired rewards can be excluded.
[*]A new slider control for decreasing or increasing the amount of Goody Huts that will be placed ingame, relative to the baseline amount for the selected map and size. This control is also present within the Goody Hut picker.
[*]New options that control the total amount of rewards provided by a Goody Hut, the amount of new units or citizens certain rewards will provide, whether the new buildings provided by certain rewards are available to be constructed at game start, the relative chances of receiving all active rewards, whether a single Goody Hut can provide the same reward more than once, and more.
[/list]

The total amount of available Goody Hut rewards has greatly increased for each official ruleset.

Ingame, the built-in system for choosing and applying rewards has been replaced by a custom Lua Reward Generator. Each activated Goody Hut -- or in the case of Sumeria, dispersed Barbarian Outpost -- will prompt Reward Generator to select one or more applicable rewards from the pool of active rewards; if a selected reward is invalid for any reason, Reward Generator will try again until it finds one that is valid. This resolves several problems with the built-in system.

Minimum turn requirements have been removed from all rewards. Instead, many existing and new rewards now have a minimum Civic and/or Technology prerequisite which must be met. Some rewards can only be granted once per player per game Era.

Rewards themselves are implemented via a combination of the built-in Modifiers system and the Lua scripting system, which allows all rewards to function as intended.

Every reward generates popup World View text indicating what was provided. In addition, each activated Goody Hut will generate a notification with a summary of all rewards provided by that Goody Hut. Some rewards may generate additional notifications. Popup text and notifications are only provided for human players.

Finally, Hostile Villagers as (and now, potentially following) a reward make their return.

Some limitations apply; please refer to the project's [url=https://github.com/zzragnar0kzz/C6EGHV#readme]README file[/url] for these and more comprehensive details. This file is also included with EGHV, and can be found where it is installed.

New Frontend and Ingame text fully localized in the following languages:
[list]
[*]English (en_US)
[*]Spanish (es_ES)
[*]French (fr_FR)
[/list]

EGHV [b]REQUIRES[/b] Enhanced Community FrontEnd, and will be blocked from loading if that mod is not present or is not enabled.

Prefer a manual installation? Wish to contribute? [url=https://github.com/zzragnar0kzz/C6EGHV]Visit EGHV on Github.[/url]

[h1]Special Thanks[/h1]
EGHV would not exist without the efforts of the following individuals (in alphabetical order): Charsi, Gedemon, LeeS, Sailor Cat, Tiramisu
