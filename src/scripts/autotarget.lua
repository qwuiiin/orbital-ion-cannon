local Cannons = require("scripts.cannons")
local Locations = require("scripts.locations")
local Strike = require("scripts.strike")

-- Radars that finish scanning a sector designate an enemy nest in it; new nests
-- in always-visible radar coverage are queued and hit as soon as a cannon allows.
local AutoTarget = {}

function AutoTarget.init()
    storage.auto_queue = storage.auto_queue or {}
    storage.next_auto_tick = storage.next_auto_tick or {}
    if storage.auto_targeting == nil then
        storage.auto_targeting = true
    end
end

function AutoTarget.enabled()
    return storage.auto_targeting and settings.global["ion-cannon-auto-targeting"].value
end

local function researched(force)
    local tech = force.technologies["auto-targeting"]
    return tech and tech.researched
end

--- Fires at `entity` if the force has spare ready cannons there and is not still
--- waiting for its previous automatic shot to land.
local function try_fire(force, entity, message)
    if (storage.next_auto_tick[force.index] or 0) > game.tick then
        return false
    end
    local location = Locations.of(entity.surface)
    if not location then
        return false
    end
    if Cannons.ready_count(force, location.key) <= settings.global["ion-cannon-min-cannons-ready"].value then
        return false
    end
    local fired = Strike.target(force, entity.surface, entity.position, nil, message)
    if fired then
        storage.next_auto_tick[force.index] = game.tick + Strike.heatup_ticks()
    end
    return fired
end

local function find_nest(force, surface, area)
    local types = { "unit-spawner" }
    if settings.global["ion-cannon-target-worms"].value then
        table.insert(types, "turret")
    end
    -- spawners first, worms only when there is no spawner
    for _, entity_type in ipairs(types) do
        local candidates = {}
        for _, entity in pairs(surface.find_entities_filtered({ area = area, type = entity_type })) do
            if force.is_enemy(entity.force) then
                table.insert(candidates, entity)
            end
        end
        if #candidates > 0 then
            return candidates[math.random(#candidates)]
        end
    end
end

function AutoTarget.on_sector_scanned(event)
    if not AutoTarget.enabled() then
        return
    end
    local radar = event.radar
    local force = radar.force
    if not researched(force) then
        return
    end
    local nest = find_nest(force, radar.surface, event.area)
    if nest then
        try_fire(force, nest, { "ion-cannon.auto-target-designated", radar.backer_name or "", math.floor(nest.position.x), math.floor(nest.position.y) })
    end
end

-- every biter settling into a new base raises the event; one blast covers the whole base
local function already_queued(force, entity)
    local reach = settings.startup["ion-cannon-radius"].value / 2
    for _, entry in pairs(storage.auto_queue) do
        if entry.force == force and entry.entity.valid and entry.entity.surface == entity.surface then
            local dx = entry.entity.position.x - entity.position.x
            local dy = entry.entity.position.y - entity.position.y
            if dx * dx + dy * dy <= reach * reach then
                return true
            end
        end
    end
    return false
end

function AutoTarget.on_biter_base_built(event)
    if not (AutoTarget.enabled() and settings.global["ion-cannon-auto-target-visible"].value) then
        return
    end
    local base = event.entity
    if not (base and base.valid) then
        return
    end
    local chunk = { x = math.floor(base.position.x / 32), y = math.floor(base.position.y / 32) }
    for _, force in pairs(game.forces) do
        if researched(force) and force.is_enemy(base.force) and force.is_chunk_visible(base.surface, chunk)
            and not already_queued(force, base) then
            table.insert(storage.auto_queue, { entity = base, force = force })
        end
    end
end

function AutoTarget.process_queue()
    local queue = storage.auto_queue
    if #queue == 0 then
        return
    end
    local enabled = AutoTarget.enabled()
    for i = #queue, 1, -1 do
        local entry = queue[i]
        if not (enabled and entry.entity.valid and entry.force.valid) then
            table.remove(queue, i)
        elseif try_fire(entry.force, entry.entity, { "ion-cannon.auto-target-expansion", math.floor(entry.entity.position.x), math.floor(entry.entity.position.y) }) then
            table.remove(queue, i)
        end
    end
end

return AutoTarget
