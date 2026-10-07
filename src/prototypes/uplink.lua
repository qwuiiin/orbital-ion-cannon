-- Orbital uplink: a powered dish that lifts the targeting device's range limit on its
-- whole planet (orbit included). It is a radar underneath, so it scans like one.
local TINT = { r = 1, g = 0.45, b = 0.35, a = 1 }

local uplink = table.deepcopy(data.raw.radar["radar"])
uplink.name = "ion-cannon-uplink"
uplink.icons = { { icon = data.raw.item["radar"].icon, icon_size = data.raw.item["radar"].icon_size, tint = TINT } }
uplink.icon = nil
uplink.minable = { mining_time = 0.5, result = "ion-cannon-uplink" }
uplink.fast_replaceable_group = nil
uplink.next_upgrade = nil
uplink.max_health = 1000
uplink.energy_usage = "2MW"
for _, layer in pairs(uplink.pictures.layers) do
    if not layer.draw_as_shadow then
        layer.tint = TINT
    end
end

data:extend({
    uplink,
    {
        type = "item",
        name = "ion-cannon-uplink",
        icons = uplink.icons,
        subgroup = "defensive-structure",
        order = "e[orbital-ion-cannon]-b[uplink]",
        place_result = "ion-cannon-uplink",
        stack_size = 10,
    },
    {
        type = "recipe",
        name = "ion-cannon-uplink",
        enabled = false,
        energy_required = 30,
        ingredients = {
            { type = "item", name = "radar", amount = 5 },
            { type = "item", name = "processing-unit", amount = 50 },
            { type = "item", name = "low-density-structure", amount = 20 },
            { type = "item", name = "accumulator", amount = 10 },
        },
        results = { { type = "item", name = "ion-cannon-uplink", amount = 1 } },
    },
    {
        type = "technology",
        name = "ion-cannon-uplink",
        icons = {
            { icon = "__base__/graphics/technology/radar.png", icon_size = 256, tint = TINT },
        },
        prerequisites = { "orbital-ion-cannon" },
        effects = { { type = "unlock-recipe", recipe = "ion-cannon-uplink" } },
        unit = {
            count = 1000,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack", 1 },
                { "chemical-science-pack", 1 },
                { "military-science-pack", 1 },
                { "production-science-pack", 1 },
                { "utility-science-pack", 1 },
                { "space-science-pack", 1 },
            },
            time = 60,
        },
        order = "k-c",
    },
})
