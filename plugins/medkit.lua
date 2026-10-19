-- medkit: a small heal carried from spawn, used with !medkit.
--
-- Ported to Lua for Shoot and Destroy from medkit.py (PySnip
-- feature_server/scripts), by Booboorocks998, maintained by mat^2.
-- Original licence: GPL-3.0.
--
-- config.toml (all optional):
--   [plugins.medkit]
--   medkits = 1
--   heal_amount = 40

local plugin = {}
local left = {}
local MAX = config.medkits or 1
local HEAL = config.heal_amount or 40

function plugin.on_spawn(p)
    left[p.id] = MAX
end

function plugin.on_leave(p)
    left[p.id] = nil
end

function plugin.on_chat(p, text)
    if text:sub(1, 7) ~= "!medkit" then
        return
    end
    local n = left[p.id] or 0
    if n <= 0 then
        p:message("You have no medkits left.")
        return false
    end
    if p.hp >= 100 then
        p:message("You are already at full health.")
        return false
    end
    p:set_hp(math.min(100, p.hp + HEAL))
    left[p.id] = n - 1
    p:message("Medkit used (" .. (n - 1) .. " left).")
    game.log("medkit " .. p.name .. " hp=" .. p.hp .. " left=" .. (n - 1))
    return false
end

return plugin
