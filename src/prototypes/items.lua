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
    -- A selection tool selecting nothing: click or drag anywhere, also in map and
    -- remote view, and the centre of the selection is the target.
    {
        type = "selection-tool",
        name = "ion-cannon-targeter",
        icon = "__OrbitalIonCannon-SE__/graphics/crosshairs64.png",
        icon_size = 64,
        flags = { "not-stackable" },
        subgroup = "capsule",
        order = "z[ion-cannon-targeter]",
        stack_size = 1,
        select = {
            border_color = { 1, 0.2, 0.2 },
            mode = { "nothing" },
            cursor_box_type = "not-allowed",
        },
        alt_select = {
            border_color = { 1, 0.2, 0.2 },
            mode = { "nothing" },
            cursor_box_type = "not-allowed",
        },
    },
})
