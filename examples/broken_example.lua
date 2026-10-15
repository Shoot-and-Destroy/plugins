-- broken_example: a plugin with a mistake on purpose. At the third kill its
-- on_kill indexes nil; the server logs the error (EVT plugin action=error)
-- and turns this plugin off alone: the game and every other plugin go on.
-- Load it next to others to see that: load = ["hello", "broken_example"].
-- It declares mode = true, so it can also be tried as a game mode
-- (--gamemode broken_example): the match goes on without its events.

local plugin = {name = "broken_example", wire = "ctf", mode = true}
local kills = 0

function plugin.on_kill(killer, victim)
    kills = kills + 1
    if kills == 3 then
        local nothing = nil
        return nothing.field -- an error: indexing nil
    end
end

return plugin
