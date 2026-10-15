# Plugin API

This is the contract between a plugin and the Shoot and Destroy server.

## The file

- A plugin is one file, `Resources/plugins/<name>.lua`. The name may use
  only `a-z`, `0-9`, `_` and `-`.
- The file runs once each time a map starts. It must return a table; the
  functions in that table named `on_*` are its events.
- Each plugin has its own Lua state, so plugins never share variables.
- The sandbox gives `base`, `table`, `string` and `math`. There is no `io`,
  `os`, `require` or `load`.
- A call that runs too long (an endless loop) is stopped. That counts as an
  error, and an error turns off that plugin alone (`EVT plugin action=error`).
- `config` is the plugin's `[plugins.<name>]` table from `config.toml`, or
  empty when there is none.

A game mode is a plugin whose table has `mode = true`, played with
`--gamemode <name>`. It may also set these fields:

- `wire = "ctf" | "arena"`: how clients draw the mode;
- `rules = "ctf"`: play over capture the flag's rules (intels, tents, the
  bots' CTF roles).

## Events

Every plugin is asked, in the order of `load`. A mode is asked last.

- Returning `false` refuses the action. The later plugins are not asked,
  and an `EVT plugin_refused` line is logged.
- Returning a value replaces the original for the later plugins and for
  the server. The arrows below show which events take a value.

The arguments `p`, `attacker`, `victim` and `killer` are player tables
(see Players below).

| Event | When | Return |
| --- | --- | --- |
| `on_init()` | the map has started | |
| `on_tick()` | 10 times a second | |
| `on_player_tick(p)` | once a second for each player in the game | |
| `on_join(p, team)` | p joins a team; team is 1, 2, or 0 for spectators | a team number, or false to keep p a spectator |
| `on_team(p, team)` | p asks to change team | false refuses |
| `on_leave(p)` | p disconnects | |
| `on_spawn(p)` | p spawned | |
| `on_spawn_point(p)` | where should p spawn? | x, y, z, or nothing for the usual spot |
| `allows_respawn(p)` | may dead p respawn now? | false keeps p waiting |
| `on_hit(attacker, victim, kind)` | a bullet or a spade hits a player; kind: 0 torso, 1 head, 2 arms, 3 legs, 4 melee | false: no damage |
| `on_damage(attacker, victim, amount, reason)` | any damage: guns, grenades, falls | a new amount, or false |
| `on_kill(killer, victim, reason)` | a death; killer may be nil; reason: 0 body, 1 head, 2 melee, 3 grenade, 4 fall, 5 team change, 6 weapon change | |
| `on_build(p, x, y, z)` | p places a block (also once per cell of a block line) | false refuses |
| `on_destroy(p, x, y, z, kind)` | a block is broken; kind is "spade", "dig" (three blocks), "gun" or "grenade" | false refuses |
| `on_chat(p, text, team_only)` | a chat line, not a /command | new text, or false to drop it |
| `on_tool(p, tool)` | p changes tool: 0 spade, 1 block, 2 gun, 3 grenade | false refuses |
| `on_weapon(p, weapon)` | p changes weapon: 0 rifle, 1 SMG, 2 shotgun | false refuses |
| `on_grenade(p)` | p throws a grenade | false refuses |
| `on_explode(p, x, y, z)` | p's grenade explodes | |
| `on_reload(p)` | p reloads | |
| `on_intel(p, action)` | action is "pickup", "capture" or "drop" | |

## Players

A player table is a snapshot taken when it was handed out. To read a player
again later, call `game.player(id)`.

**Fields:**
- `id`, `name`, `team` (1, 2, 0), `alive`, `hp`, `kills`, `deaths`, `bot`;
- `tool`, `weapon`, `blocks`, `grenades`, `intel` (carries one);
- `x`, `y`, `z` (see Coordinates below);
- `ox`, `oy`, `oz`: where the player looks, as a unit vector.

**Methods:**

| Method | Does |
| --- | --- |
| `p:message(text)` | a line only p reads |
| `p:set_hp(n)` | set health (0 or less kills) |
| `p:damage(n, by)` | hurt p through the normal path (hit marks, kill credit to `by`) |
| `p:kill()` | kill p |
| `p:teleport(x, y, z)` | move p, its own client included |
| `p:restock()` | full health, blocks, grenades and ammo |
| `p:fog(r, g, b)` | p's sky colour only (0..255) |
| `p:has_role(role)` | logged in as `role` or higher: "trusted", "guard", "mod", "admin", "manager" |

## game

| Function | Does |
| --- | --- |
| `game.players()` | every player, a list |
| `game.player(id)` | a player, or nil |
| `game.find(name)` | the player with that name, or the only one whose name starts with it |
| `game.notice(text[, team])` | a line every player (or one team) reads |
| `game.fog(r, g, b)`, `game.get_fog()` | everyone's sky colour |
| `game.score(team)`, `game.set_score(team, n)`, `game.score_limit()` | the scores |
| `game.win(team)` | that team wins; the next map starts |
| `game.time()` | the game clock in seconds |
| `game.later(seconds, fn)` | call fn later; at most 64 pending per plugin |
| `game.log(text)` | an `EVT plugin action=log` line |
| `game.map_size()` | x, y, z |
| `game.cell(x, y, z)` | true when the block is solid |
| `game.ground(x, y)` | the column's top block (its smallest z) |
| `game.spawn(team)` | the middle of a team's spawn area: x, y |
| `game.objective(x, y, radius)` | modes only: bots go there and hold it; with no arguments they hunt again |
| `game.set_intel_spot(team, x, y)`, `game.set_tent_spot(team, x, y)` | modes with `rules = "ctf"`: where a team's intel and tent stand |

## Coordinates

These are map coordinates.

- `z` grows downwards. `z = 0` is the top of the world, and the water is
  the bottom layer (`z = 63` on a 64-high map).
- A player's `x`, `y`, `z` is the hip. The floor under a standing player
  is about `z + 2.4`; the server spawns players at `floor_z - 2.4`.
