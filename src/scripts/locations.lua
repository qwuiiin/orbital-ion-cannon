-- Cannons orbit a location, not a surface: a Space Exploration planet or moon
-- (its orbit counts as the same place), a Space Age planet, or a plain surface.
local Locations = {}

local function se_active()
    return remote.interfaces["space-exploration"] ~= nil
end

local function se_zone(surface)
    return remote.call("space-exploration", "get_zone_from_surface_index", { surface_index = surface.index })
end

local function se_solid(zone)
    return zone.type == "planet" or zone.type == "moon"
end

--- @return {key: string, label: LocalisedString, targetable: boolean}?
function Locations.of(surface)
    if not (surface and surface.valid) then
        return nil
    end

    if se_active() then
        local zone = se_zone(surface)
        if zone then
            if zone.type == "orbit" and zone.parent_index then
                local parent = remote.call("space-exploration", "get_zone_from_zone_index", { zone_index = zone.parent_index })
                if parent and se_solid(parent) then
                    return { key = "se:" .. parent.index, label = parent.name, targetable = false }
                end
            end
            if zone.type == "spaceship" then
                return nil
            end
            return { key = "se:" .. zone.index, label = zone.name, targetable = se_solid(zone) }
        end
    end

    if surface.platform then
        local location = surface.platform.space_location
        if location and game.planets[location.name] then
            return { key = "planet:" .. location.name, label = location.localised_name, targetable = false }
        end
        return nil
    end

    if surface.planet then
        return { key = "planet:" .. surface.planet.name, label = surface.planet.prototype.localised_name, targetable = true }
    end

    return { key = "surface:" .. surface.name, label = surface.localised_name or surface.name, targetable = true }
end

return Locations
