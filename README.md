# Simple Taunts

Based on KevinNovak's awesome [SimpleTauntMenu](https://github.com/KevinNovak/SimpleTauntMenu). Which was inspired by [Icedream](https://steamcommunity.com/id/icedream2k9)'s [Minimal PropHunt Taunt Menu](https://steamcommunity.com/sharedfiles/filedetails/?id=431297319).

## Description

Simple Taunts the bare minimum if you want to add a taunt system (or override the built-in one) for ANY gamemode (but it was made with prop_hunt in mind). It ships only the minimum needed to make taunts work. It does not ship any soundfiles itself, and it's server-side only.

Just press and hold your `+menu_context` button (which is the "C" key by default) to bring up the taunt menu and click a taunt to begin taunting.

To play a random taunt press `gm_showspare1` (Default is the "F3" key).

**Note**: Players must be alive and not a spectator in order to taunt.

## Installation

This addon runs on the server-side, and it does not need any client side addon to be installed. Adding sound files, and ensuring they are downloaded for the clients is up to the server administrator! This addon does not care if the sound files are coming from another addon or directly added files on the server.

## Configuration

This addon can be configured by placing a lua script in the server's shared autorun folder. The same script has to run on both client and server side so the state will be the same.

### Basic configuration

Call the following function to register a taunt in the menu:

```lua
RegisterTaunt(string categoryName, string tauntName, string soundFilePath)
```

So for example:

```lua
RegisterTaunt("Misc", "This is SPARTA!", "prophunt/props/9.wav")
```

### Advanced configuration

There are two hooks you can register to limit who can play what taunt.

`SimpleTaunts/CanTaunt` and `SimpleTaunts/CanUseTaunt`:

```lua
hook.Add("SimpleTaunts/CanTaunt", "", function (Player ply)
 ...
end)


hook.Add("SimpleTaunts/CanUseTaunt", "", function (Player ply, number categoryID, string categoryName, table soundData)
 ...
end)
```

`SimpleTaunts/CanTaunt` is a simple general hook, called every time before allowing a player to taunt, you can put your custom dynamic logic here to restrict players from taunting for whatever reason. This will not hide the taunt from the player.

`SimpleTaunts/CanUseTaunt` Can also be used to restrict a taunt, but this taunt is called when constructing the taunt menu, or deciding which taunts are used for random taunting. So this can be used to "hide" a specific taunt from a player. **For performance reasons, the result of this hooks are cached and only invalidated on certain game events. For example when the player spawns, or changes teams!**

A fourth parameter can be added to `RegisterTaunt`, this can be any arbitrary data, that is attached to that taunt. It can be accessed trough `soundData.meta`. It's purpose is to be used in hooks so the logic can be simple.

Here is a full example:

```lua
RegisterTaunt("My Taunts", "Some Taunt", "my_taunts/some.mp3", "user")
RegisterTaunt("My Taunts", "Admin Taunt", "my_taunts/admin.mp3", "admin")

hook.Add("SimpleTaunts/CanTaunt", "aliveOnly", function (ply)
 if not ply:Alive() then
        ply:ChatPrint("You can not taunt while you are dead.")
        return false
    end
end)


hook.Add("SimpleTaunts/CanUseTaunt", "team restriction", function (ply, categoryID, categoryName, soundData)
 if soundData.meta == "admin" then
    return ply:IsAdmin() -- allow admin taunts only for admins
 end
end)
```

You should also add these snippets to a shared lua file, because they are called both on the server and the client side. They are expected to return the same value in both realms.
