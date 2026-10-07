local Locations = require("scripts.locations")

-- A powered orbital uplink anywhere at a location (its orbit included) lifts the
-- targeting device's range limit there.
local Uplink = {}

local ONLINE = {
    [defines.entity_status.working] = true,
    [defines.entity_status.low_power] = true,
}

function Uplink.covers(force, key)
    for _, surface in pairs(game.surfaces) do
        local location = Locations.of(surface)
        if location and location.key == key then
            for _, uplink in pairs(surface.find_entities_filtered({ name = "ion-cannon-uplink", force = force })) do
                if ONLINE[uplink.status] then
                    return true
                end
            end
        end
    end
    return false
end

return Uplink
