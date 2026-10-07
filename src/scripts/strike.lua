local Audio = require("scripts.audio")
local Cannons = require("scripts.cannons")
local Locations = require("scripts.locations")

-- A designated target waits for the cannon to heat up (~3.5 s per multiplier step),
-- then the strike projectile hits it.
local Strike = {}

local HEATUP_TICKS = 210

function Strike.init()
    storage.strikes = storage.strikes or {}
    storage.chart_tags = storage.chart_tags or {}
    storage.blocked = storage.blocked or {}
end

function Strike.heatup_ticks()
    return settings.global["ion-cannon-heatup-multiplier"].value * HEATUP_TICKS
end

function Strike.pending()
    return next(storage.strikes) ~= nil
end

function Strike.allowed(player)
    return not storage.blocked[player.index]
end

local function refuse(player, message)
    if player then
        player.print(message)
        Audio.voice(player, "unable-to-comply")
    end
    return false
end

local function chunk_of(position)
    return { x = math.floor(position.x / 32), y = math.floor(position.y / 32) }
end

local function alert(force, entity, message)
    for _, player in pairs(force.connected_players) do
        if player.mod_settings["ion-cannon-custom-alerts"].value then
            player.add_custom_alert(entity, { type = "item", name = "orbital-ion-cannon" }, message, true)
        end
    end
end

--- Designates a target for one of the force's ready cannons orbiting the surface's location.
--- @param player LuaPlayer? the targeting player; nil for auto-targeting and remote calls
--- @param alert_message LocalisedString? custom alert text instead of the default one
--- @return integer|string|false cannon number ("cheat" for a free cheat-mode shot) or false
function Strike.target(force, surface, position, player, alert_message)
    if player and not Strike.allowed(player) then
        return refuse(player, { "ion-cannon.permission-denied" })
    end

    local location = Locations.of(surface)
    if not (location and location.targetable) then
        return refuse(player, { "ion-cannon.cannot-target-here" })
    end
    if player and not force.is_chunk_charted(surface, chunk_of(position)) then
        return refuse(player, { "ion-cannon.not-charted" })
    end

    local number
    if player and player.cheat_mode then
        number = "cheat"
    else
        number = Cannons.take(force, location.key)
        if not number then
            return refuse(player, { "ion-cannon.none-ready", location.label })
        end
    end

    position = { x = position.x, y = position.y }
    local who = player and player.name or { "ion-cannon.auto" }
    local marker = surface.create_entity({ name = "ion-cannon-target", position = position, force = "neutral" })

    local tag = force.add_chart_tag(surface, {
        icon = { type = "item", name = "ion-cannon-targeter" },
        text = "Ion cannon #" .. number .. " (" .. (player and player.name or "auto") .. ")",
        position = position,
    })
    if tag then
        local duration = settings.global["ion-cannon-chart-tag-duration"].value
        table.insert(storage.chart_tags, { tag = tag, expires = game.tick + duration })
    end

    table.insert(storage.strikes, {
        tick = game.tick + Strike.heatup_ticks(),
        surface = surface,
        position = position,
        force = force,
        marker = marker,
        player_index = player and player.index,
    })

    Audio.klaxon(surface)
    if marker then
        alert(force, marker, alert_message or { "ion-cannon.target-location", number, math.floor(position.x), math.floor(position.y), who })
    end
    if player then
        player.print({ "ion-cannon.targeting", number })
    end

    script.raise_event("on_ion_cannon_targeted", {
        force = force,
        surface = surface,
        position = position,
        radius = settings.startup["ion-cannon-radius"].value,
        player_index = player and player.index,
    })
    return number
end

local function fire(strike)
    if strike.marker and strike.marker.valid then
        strike.marker.destroy()
    end
    local surface, force = strike.surface, strike.force
    if not (surface.valid and force.valid) then
        return
    end

    surface.create_entity({
        name = "ion-cannon-strike",
        position = strike.position,
        target = strike.position,
        force = force,
        speed = 1,
    })

    local radius = settings.startup["ion-cannon-radius"].value
    local x, y = strike.position.x, strike.position.y
    force.chart(surface, { { x - radius, y - radius }, { x + radius, y + radius } })

    script.raise_event("on_ion_cannon_fired", {
        force = force,
        surface = surface,
        position = strike.position,
        radius = radius,
        player_index = strike.player_index,
    })
end

function Strike.on_tick()
    local strikes = storage.strikes
    for i = #strikes, 1, -1 do
        if strikes[i].tick <= game.tick then
            local strike = table.remove(strikes, i)
            fire(strike)
        end
    end
end

function Strike.expire_chart_tags()
    local tags = storage.chart_tags
    for i = #tags, 1, -1 do
        if tags[i].expires <= game.tick then
            if tags[i].tag.valid then
                tags[i].tag.destroy()
            end
            table.remove(tags, i)
        end
    end
end

--- The targeting device is an artillery-remote capsule, so it works from map and remote view.
function Strike.on_player_used_capsule(event)
    if event.item.name ~= "ion-cannon-targeter" then
        return
    end
    local player = game.get_player(event.player_index)
    Strike.target(player.force, player.surface, event.position, player)
end

--- "Select target" when the device is picked up while a cannon is ready.
function Strike.on_player_cursor_stack_changed(event)
    local player = game.get_player(event.player_index)
    local stack = player.cursor_stack
    if not (stack and stack.valid_for_read and stack.name == "ion-cannon-targeter") then
        return
    end
    if not Strike.allowed(player) then
        player.clear_cursor()
        refuse(player, { "ion-cannon.permission-denied" })
        return
    end
    local location = Locations.of(player.surface)
    if player.cheat_mode or (location and Cannons.ready_count(player.force, location.key) > 0) then
        Audio.voice(player, "select-target")
    end
end

return Strike
