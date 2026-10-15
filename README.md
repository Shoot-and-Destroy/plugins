# Shoot and Destroy plugins

Lua plugins for Shoot and Destroy servers. A plugin changes how the whole
server plays: a game mode, a mechanic (airstrikes, rampages, spawn
protection), an admin or a building tool. Several plugins run together,
each able to refuse or change what happens, the way pyspades / PySnip
scripts did. Most plugins here are those scripts ported to Lua, and each
names its original author (see [CREDITS.md](CREDITS.md)).

## Installing a plugin

1. Copy `plugins/<name>.lua` into your server's `Resources/plugins/`.
2. List it in `Resources/config.toml`:

   ```toml
   [plugins]
   load = ["spawn_protect", "rampage"]

   [plugins.rampage]      # the plugin's own settings (see the top of its file)
   kills = 3
   ```

3. Restart the server, or change the map: plugins load again with every map.

A plugin that is a game mode (`tdm`, `koth`, `push`) is played with
`--gamemode <name>` instead of being listed.

## Plugins

| Plugin | What it does | Kind |
| --- | --- | --- |
| [tdm](plugins/tdm.lua) | team deathmatch: every kill scores | mode |
| [koth](plugins/koth.lua) | king of the hill | mode |
| [push](plugins/push.lua) | capture the flag across the whole map | mode |
| [welcome](plugins/welcome.lua) | greets named players | extension |
| [spawn_protect](plugins/spawn_protect.lua) | no damage for a few seconds after spawning | extension |
| [rampage](plugins/rampage.lua) | 3 quick kills: restock, red sky, announced | extension |

More arrive in batches. The scripts that will not be ported, and why, are in
[docs/not-ported.md](docs/not-ported.md).

## Writing a plugin

Start from [examples/hello.lua](examples/hello.lua). It is short and
commented. [examples/broken_example.lua](examples/broken_example.lua) shows
what happens when a plugin fails: the server logs the error and turns off
only that plugin. Every event and function is listed in
[docs/api.md](docs/api.md).

To see what a plugin did, run the server with `SP_EVENTLOG=1`. Each
`game.log` call is written as an `EVT ... plugin action=log` line. To try
plugins without editing the config, set `SP_PLUGINS=a,b`.

## Licence

GPL-3.0, like the scripts these come from. Each ported plugin keeps its
original author and licence in its header.
