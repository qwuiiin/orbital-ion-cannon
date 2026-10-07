-- Cannons in orbit, per force. A cannon is { location = key, ready_at = tick, announced = bool };
-- its number is its position in the force's list.
local Cannons = {}

local function cooldown_ticks()
    return settings.global["ion-cannon-cooldown-seconds"].value * 60
end

function Cannons.init()
    storage.forces = storage.forces or {}
    storage.labels = storage.labels or {}
end

function Cannons.list(force)
    local data = storage.forces[force.index]
    if not data then
        data = { cannons = {} }
        storage.forces[force.index] = data
    end
    return data.cannons
end

function Cannons.count(force)
    local data = storage.forces[force.index]
    return data and #data.cannons or 0
end

function Cannons.label(key)
    return storage.labels[key] or key
end

--- @param location {key: string, label: LocalisedString}
function Cannons.add(force, location, count)
    storage.labels[location.key] = location.label
    local cannons = Cannons.list(force)
    local ready_at = game.tick + cooldown_ticks()
    for _ = 1, count or 1 do
        table.insert(cannons, { location = location.key, ready_at = ready_at, announced = false })
    end
    return #cannons
end

function Cannons.remove_last(force)
    return table.remove(Cannons.list(force)) ~= nil
end

function Cannons.is_ready(cannon)
    return cannon.ready_at <= game.tick
end

--- Puts the first ready cannon at `key` on cooldown.
--- @return integer? number of the cannon that fired
function Cannons.take(force, key)
    for number, cannon in ipairs(Cannons.list(force)) do
        if cannon.location == key and Cannons.is_ready(cannon) then
            cannon.ready_at = game.tick + cooldown_ticks()
            cannon.announced = false
            return number
        end
    end
end

function Cannons.ready_count(force, key)
    local ready = 0
    for _, cannon in pairs(Cannons.list(force)) do
        if cannon.location == key and Cannons.is_ready(cannon) then
            ready = ready + 1
        end
    end
    return ready
end

--- @return {key: string, label: LocalisedString, total: integer, ready: integer, next_ready: integer?}[]
function Cannons.summary(force)
    local by_key, order = {}, {}
    for _, cannon in pairs(Cannons.list(force)) do
        local entry = by_key[cannon.location]
        if not entry then
            entry = { key = cannon.location, label = Cannons.label(cannon.location), total = 0, ready = 0 }
            by_key[cannon.location] = entry
            table.insert(order, entry)
        end
        entry.total = entry.total + 1
        if Cannons.is_ready(cannon) then
            entry.ready = entry.ready + 1
        else
            local seconds = math.ceil((cannon.ready_at - game.tick) / 60)
            entry.next_ready = math.min(entry.next_ready or seconds, seconds)
        end
    end
    return order
end

--- Marks cannons that just became ready.
--- @return LuaForce[] forces with at least one newly ready cannon
function Cannons.collect_newly_ready()
    local forces = {}
    for force_index, data in pairs(storage.forces) do
        for _, cannon in pairs(data.cannons) do
            if not cannon.announced and Cannons.is_ready(cannon) then
                cannon.announced = true
                local force = game.forces[force_index]
                if force then
                    forces[force_index] = force
                end
            end
        end
    end
    return forces
end

function Cannons.on_forces_merged(event)
    local source = storage.forces[event.source_index]
    if source then
        local destination = Cannons.list(event.destination)
        for _, cannon in pairs(source.cannons) do
            table.insert(destination, cannon)
        end
        storage.forces[event.source_index] = nil
    end
end

return Cannons
