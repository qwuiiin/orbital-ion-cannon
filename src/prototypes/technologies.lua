local science = {
    { "automation-science-pack", 2 },
    { "logistic-science-pack", 2 },
    { "chemical-science-pack", 2 },
    { "military-science-pack", 2 },
    { "production-science-pack", 2 },
    { "utility-science-pack", 2 },
    { "space-science-pack", 1 },
}

data:extend({
    {
        type = "technology",
        name = "orbital-ion-cannon",
        icon = "__OrbitalIonCannon-SE__/graphics/icon64.png",
        icon_size = 64,
        prerequisites = { "rocket-silo", "laser-weapons-damage-6" },
        effects = {
            { type = "unlock-recipe", recipe = "orbital-ion-cannon" },
        },
        unit = { count = 2500, ingredients = science, time = 60 },
        order = "k-a",
    },
    {
        type = "technology",
        name = "auto-targeting",
        icon = "__OrbitalIonCannon-SE__/graphics/AutoTargetingTech.png",
        icon_size = 64,
        prerequisites = { "orbital-ion-cannon" },
        effects = {},
        unit = { count = 2000, ingredients = table.deepcopy(science), time = 60 },
        order = "k-b",
    },
})
