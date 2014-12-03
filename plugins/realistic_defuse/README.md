Realistic Defuse v1.4
============

__Esto es una copia del [link original](https://forums.alliedmods.net/showthread.php?t=101106)__

## Description:

This plugin give more realistic when the player (CT) defuse the bomb.

## Features:

>-You can block defusing without defuse kit (controled by cvar).
>-You can set that defuse kit can be used only for some times (controled by cvar).
>-Players can buy a New Defuse that can be used all the time except if you die (controled by cvar)
>-Plugin Have Multilingual System.
>-And more things.

## Commands:

__say /defuse:__ Show a menu asking you if want to buy a New Defuse, with the price too.

## Cvars:

* rd_enable (Default: 1)
  * 0: Plugin get paused.
  * 1: Plugin is working.
  * If you change this cvar in the middle of the game you have to change the map to apply the changes.
* defuse_remove (Default: 1)
  * 0: Don't remove defuse kit from player when he defused the bomb.
  * 1: Remove defuse kit from player when he defused the bomb (see next cvar).
* defuse_remove_immunity (Default: 0)
  * 0: Admins aren't inmune when defuse_remove cvar is enable.
  * 1: Admins are inmune when defuse_remove cvar is enable (so defuse not removed).
* defuse_times (Default: 1)
  * How much defuses can be made after remove defuse kit from the player. defuse_remove have to be actived. 0 And 1 is the same.
* defuse_block (Default: 1)
  * 0: Player can defuse without defuse kit.
  * 1: Player can't defuse without defuse kit.
* defuse_block_immunity (Default: 0)
  * 0: Admins aren't inmune when defuse_block cvar is enable.
  * 1: Admins are inmune when defuse_block cvar is enable (so admins can defuse without defusekit).
* defuse_reward (Default: 1)
  * 0: When the player defuse the bomb without defusekit, not get a reward.
  * 1: When the player defuse the bomb without defusekit, get a defuse (only if defuse_block is disabled).
* defuse_plugintag (Default: "[Realistic Defusing]")
  * Change the Plugin Tag of the chat messages.
* new_defuse (Default: "1")
  * 0: New Defuse is desactived.
  * 1: New Defuse is actived.
* new_defuse_buyzone (Default: "1")
  * 0: Player can buy the New Defuse everywhere.
  * 1: Player can buy the New Defuse only in the buyzone.
* new_defuse_sound (Default: "1")
  * 0: Don't play a sound.
  * 1|2|3: Play different sounds when you buy the New Defuse.
  * If the cvar have a value > than 0 and when you try to buy the New Defuse but don't have enough money you hear another sound (that can't be changed).
* new_defuse_cost (Default: "1000")
  * Cost of the New Defuse.
* new_defuse_color (Default: "255 0 0")
  * Color of the New Defuse to difference with the normal defuse.
  
## Recommended Plugins:

* [Icons Color Changer](http://forums.alliedmods.net/showthread.php?p=816874)
* [Planting Normalizer](http://forums.alliedmods.net/showthread.php?p=790266)
* [Time To Defuse](http://forums.alliedmods.net/showthread.php?p=523845)
* [Drop Defuser Kit](http://forums.alliedmods.net/showthread.php?p=57960)
* [Defuse Mistake 1.4](http://forums.alliedmods.net/showthread.php?p=601970)

## Credits:

* [Exolent](http://forums.alliedmods.net/member.php?u=25165) and [ConnorMcLeod](http://forums.alliedmods.net/member.php?u=18946) ([Exolent](http://forums.alliedmods.net/showthread.php?t=101026))
* [larito](http://forums.alliedmods.net/member.php?u=44270) and [joaquimandrade](http://forums.alliedmods.net/member.php?u=45372) ([Exolent](http://forums.alliedmods.net/showthread.php?t=100909))
* [ConnorMcLeod](http://forums.alliedmods.net/member.php?u=18946) - Blocking C4 defuse & Same color of defuse at StatusIcon event.

## Changelog:

* Version 1.0
  * First Release.
* Version 1.1
  * Cleaned code (click me).
  * Added print_center when you try to defuse without defuse kit (depends of defuse_block).
  * Added messages in the first spawn.
  * Added new cvar rd_enable to Enable/Disable (Unpause/Pause) the plugin.
* Version 1.2
  * Minor cleaned code.
  * Fixed the bug with defuse_times cvar.
* Version 1.3
  * Minor cleaned code.
  * Added new feature that take out the BuyZone icon when the menu is displayed(click me)
  * Added new cvar new_defuse_sound to play sounds when you buy the New Defuse and when you don't have enough money to buy it.
* Version 1.4
  * Now it suposed that you can change defuse_time in the middle of the game without changing the map.
  * Added new cvars: defuse_remove_immunity, defuse_block_immunity, defuse_reward.
  * Also added some recommended plugins to the thread.
  
## Multilingual:

[Multilingual Thread](http://forums.alliedmods.net/showthread.php?t=101107)