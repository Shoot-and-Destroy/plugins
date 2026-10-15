-- hello: a small plugin to start from. It shows the parts every plugin has:
-- its settings (`config`), its events, refusing an action, timers and the
-- player methods. Copy it to <server>/Resources/plugins/hello.lua and list
-- it in config.toml:
--
--   [plugins]
--   load = ["hello"]
--
--   [plugins.hello]
--   greeting = "Hello"
--
-- docs/api.md lists every event and every function.

-- A plugin returns a table; its functions named on_* are the events.
local plugin = {}

-- config is the plugin's own [plugins.<name>] table from config.toml.
local GREETING = config.greeting or "Hello"

-- Each plugin keeps its own state; it starts empty on every map.
local kills = {} -- by player id

-- A player joined a team (team: 1, 2, or 0 for the spectators). Returning
-- a team number sends it there instead; returning false keeps it out.
function plugin.on_join(p, team)
    p:message(GREETING .. ", " .. p.name .. "!")
end

function plugin.on_spawn(p)
    -- game.later runs a function a number of seconds from now
    game.later(1, function()
        local now = game.player(p.id) -- a fresh copy: tables are snapshots
        if now ~= nil and now.alive then
            now:message("You have " .. now.blocks .. " blocks and " .. now.grenades .. " grenades.")
        end
    end)
end

-- killer is nil when nobody killed (a fall); reason: 0 body, 1 head,
-- 2 melee, 3 grenade, 4 fall, 5 team change, 6 weapon change
function plugin.on_kill(killer, victim, reason)
    if killer == nil or killer.id == victim.id then
        return
    end
    kills[killer.id] = (kills[killer.id] or 0) + 1
    if kills[killer.id] % 5 == 0 then
        game.notice(killer.name .. " has " .. kills[killer.id] .. " kills")
        killer:restock()
    end
end

-- Returning false refuses the action: nobody may build in the top 2 layers.
function plugin.on_build(p, x, y, z)
    if z < 2 then
        p:message("Too high to build.")
        return false
    end
end

function plugin.on_leave(p)
    kills[p.id] = nil
end

-- game.log writes an EVT line to the server log: what the plugin did,
-- for whoever tests it
game.log("hello is loaded")

return plugin
