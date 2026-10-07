local Audio = require("scripts.audio")
local Cannons = require("scripts.cannons")
local Locations = require("scripts.locations")

-- A cannon reaches orbit when a rocket silo sends it there. Pods headed to a space
-- platform or a landing pad deliver it as an item instead.
local Launch = {}

function Launch.deploy(force, location, count)
    local total = Cannons.add(force, location, count)
    Audio.voice_force(force, "ion-cannon-charging")
    if total == count then
        force.print({ "ion-cannon.first-launch" })
        force.print({ "ion-cannon.first-help" })
    else
        force.print({ "ion-cannon.another-launch", location.label, total })
    end
end

-- A plain "launch to orbit" without any landing pad reports a station destination
-- with no station attached; its pod is destroyed after the ascent like an orbit one.
local function delivers(destination)
    local types = defines.cargo_destination
    return destination ~= nil and (destination.type == types.space_platform
        or (destination.type == types.station and destination.station ~= nil)
        or (destination.type == types.surface and destination.surface ~= nil))
end

function Launch.on_cargo_pod_finished_ascending(event)
    local pod = event.cargo_pod
    if not (event.launched_by_rocket and pod and pod.valid) then
        return
    end
    if delivers(pod.cargo_pod_destination) then
        return
    end

    local inventory = pod.get_inventory(defines.inventory.cargo_unit)
    local count = inventory and inventory.get_item_count("orbital-ion-cannon") or 0
    if count == 0 then
        return
    end
    inventory.remove({ name = "orbital-ion-cannon", count = count })

    local origin = pod.cargo_pod_origin
    local surface = origin and origin.valid and origin.surface or pod.surface
    local location = Locations.of(surface)
    if location then
        Launch.deploy(pod.force, location, count)
    end
end

return Launch
