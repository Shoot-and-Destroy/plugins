-- bot_escort: a game mode on the bots' API (docs/api.md, "Bots"): a VIP
-- escort. Copy it to <server>/Resources/plugins/bot_escort.lua and start the
-- server with --gamemode bot_escort and some bots (--bots 16).
--
-- Team 1's living bot with the lowest id is the VIP (on_bot_team_tick picks
-- it) and runs for team 2's spawn; the rest of team 1 keep up with it,
-- looking where it looks; team 2 hunts the VIP and, while it has none to
-- hunt, holds its spawn. A VIP that gets there (on_bot_arrived) scores for
-- team 1 and is killed, so the next run starts. Every decision is a goal
-- table; the server walks, fights and digs.
--
-- Licence: GPL-3.0.

local mode = {name = "bot_escort", wire = "ctf", mode = true}

local vip = nil       -- the VIP's player id
local stuck = 0       -- on_bot_stuck calls since the last report
local arrived = 0     -- VIP runs that got there
local ticks = 0       -- on_bot_team_tick calls (team 1's), for the report

function mode.on_bot_team_tick(team, bots)
    if team ~= 1 then
        return
    end
    local best = nil
    for _, b in ipairs(bots) do
        if b.alive and (best == nil or b.id < best.id) then
            best = b
        end
    end
    if best ~= nil and best.id ~= vip then
        vip = best.id
        game.log("vip=" .. best.id)
    end
    ticks = ticks + 1
    if ticks % 30 == 0 then
        game.log("report arrived=" .. arrived .. " stuck=" .. stuck)
        stuck = 0
    end
end

function mode.on_bot_think(bot)
    local v = vip and game.player(vip)
    local alive = v ~= nil and v.alive
    if bot.team == 1 then
        if bot.id == vip then
            local ex, ey = game.spawn(2)
            return {name = "vip-run", x = ex, y = ey, hold = 4, role = "rush", rush = true, intent = "take"}
        end
        if not alive then
            local sx, sy = game.spawn(1)
            return {name = "regroup", x = sx, y = sy, hold = 6}
        end
        return {name = "escort", x = v.x, y = v.y, hold = 4, intent = {"with", "push"},
                watch = {x = v.x + v.ox * 10, y = v.y + v.oy * 10}}
    end
    if bot.team == 2 then
        if alive then
            return {name = "hunt-vip", x = v.x, y = v.y, role = "rush", intent = "chase"}
        end
        local sx, sy = game.spawn(2)
        return {name = "hold-spawn", x = sx, y = sy, hold = 8, intent = "post"}
    end
    return nil
end

function mode.on_bot_arrived(bot, name)
    if name == "vip-run" and bot.id == vip then
        arrived = arrived + 1
        game.set_score(1, game.score(1) + 1)
        game.log("vip_arrived id=" .. bot.id .. " total=" .. arrived)
        bot:kill()
    end
end

function mode.on_bot_stuck(bot, why)
    stuck = stuck + 1
end

return mode
