local Cannons = require("scripts.cannons")
local Locations = require("scripts.locations")

-- 4.0 is a rewrite with its own storage layout. Older saves are cleared, but cannons
-- kept in the original Orbital Ion Cannon table (`forces_ion_cannon_table`, one entry
-- per cannon under the force name) are carried over.
local Migration = {}

Migration.VERSION = 1

local function default_surface()
    return game.get_surface("nauvis") or game.surfaces[1]
end

--- Entries are lists like {cooldown_seconds, ready_flag}; some variants also carry a
--- surface name. Anything else still counts as one cannon on the home planet.
local function convert(force, entry)
    local surface
    if type(entry) == "table" then
        for _, value in pairs(entry) do
            if type(value) == "string" and game.get_surface(value) then
                surface = game.get_surface(value)
                break
            end
        end
    end
    local location = Locations.of(surface or default_surface())
    if not location then
        return
    end

    Cannons.add(force, location, 1)
    local cannon = Cannons.list(force)[Cannons.count(force)]
    if type(entry) == "table" and entry[2] == 1 then
        cannon.ready_at = game.tick
    elseif type(entry) == "table" and type(entry[1]) == "number" then
        cannon.ready_at = game.tick + math.max(0, entry[1]) * 60
    end
    cannon.announced = Cannons.is_ready(cannon)
end

function Migration.run()
    if storage.version == Migration.VERSION then
        return
    end

    local old = storage.forces_ion_cannon_table
    for key in pairs(storage) do
        storage[key] = nil
    end
    Cannons.init()

    local migrated = 0
    if type(old) == "table" then
        for force_name, entries in pairs(old) do
            local force = game.forces[force_name]
            if force and type(entries) == "table" then
                for _, entry in ipairs(entries) do
                    convert(force, entry)
                    migrated = migrated + 1
                end
            end
        end
    end
    if migrated > 0 then
        game.print({ "ion-cannon.migrated", migrated })
    end
end

return Migration
