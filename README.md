# *t5cine - A Black Ops Cinematic Mod* <!-- omit in toc -->
⚠️ Note: This mod isn't in alpha stage... it doesn't do anything yet,

**A GSC modification for t5 to create cinematics.**

- [Installation](#installation)
- [Command List](#command-list)
- [To-Do List](#to-do-list)
- [Credits](#credits)

## Installation

Simply download the mod through [this link](https://github.com/4GlVE/t5cine/releases/latest). Scroll down to `Assets` and download `mp_t5cine.zip`.

Once the mod downloaded, open the ZIP file and drag the `mp_t5cine` folder into your `BO1/mods` folder. If the `mods` folder doesn't exist, create it.

```text
C:/
└── .../
    └── BO1/
        └── mods/
            └── mp_t5cine
```

Once this is done open your game, then click on the "Mods" tab. "mp_t5cine" should appear in the list; click on it once and then click on "Launch" to restart your game with the mod on.

## Command List

> These commands are set using the onPlayerCommand function, therefore will not show in the console as a dvar.

### Bot Commands <!-- omit in toc -->
* `mvm_bot_spawn` - This command allows you to spawn a bot.
* `mvm_bot_setup` - If you want to change the position of your bot, then this is the command you need. The bot will also respawn to its new position if it gets killed.
* `mvm_bot_stare` - This command will make the bot look at the host.
 
### Misc Commands <!-- omit in toc -->
* `about` - Prints credits and information on the screen.
* `clone` - Spawns a clone of yourself
* `clearbodies` - Deletes all dead bodies
* `mvm_eb_close` - Toggles on/off close explosive bullets

## To-Do List
I know this mod is very bare bones and there is not much to it, but in time I will try to implement every part of Sass' mod into Black Ops.

You can only spawn one bot at a time, and I have not yet implemented a way to kill the bot via command.
* Add the ability to differentiate between bot names for ease of use with commands.
* Add the ability to spawn bots and choosing "class" and "team".
* Add "kill" command.
* Add "vision" command.
* Add "bot model" command.
* Add "hold gun" command.
* Add "score" command. // Similar to "mvm_score"
* Add "killstreak command. // Similar to "mvm_killstreak"

## Credits
**Sass:** *Wouldnt be doing this kind of stuff today if it wasn't for him. // Thank you for allowing me to use your code for my mod and everything else you've done for me! Seriously, all the kindness you've shown me the past years/recently is very appreciated.*
* [Github](https://github.com/sortileges/iw4cine)
* [Twitter](https://twitter.com/sasseries)

**Antiga:** *Helped me convert and make functions for t5. // Thank you for expanding my knowledge of coding and everything else you've done for me! You also smell.*
* [Github](https://github.com/mprust)
* [Twitter](https://twitter.com/mp_rust)
