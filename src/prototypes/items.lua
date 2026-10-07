data:extend({
    {
        type = "item",
        name = "orbital-ion-cannon",
        icon = "__OrbitalIonCannon-SE__/graphics/icon64.png",
        icon_size = 64,
        subgroup = "defensive-structure",
        order = "e[orbital-ion-cannon]",
        stack_size = 1,
        weight = 1000000, -- a whole rocket
        send_to_orbit_mode = "manual",
    },
    {
        type = "capsule",
        name = "ion-cannon-targeter",
        icon = "__OrbitalIonCannon-SE__/graphics/crosshairs64.png",
        icon_size = 64,
        capsule_action = {
            type = "artillery-remote",
            flare = "ion-cannon-flare",
        },
        subgroup = "capsule",
        order = "z[ion-cannon-targeter]",
        stack_size = 1,
    },
})
