data:extend({
    {
        type = "sprite",
        name = "ion-cannon-button",
        filename = "__OrbitalIonCannon-SE__/graphics/Button.png",
        size = 64,
        position = { 0, 0 },
        flags = { "gui-icon" },
    },
    {
        type = "custom-input",
        name = "ion-cannon-hotkey",
        key_sequence = "I",
        consuming = "none",
    },
    { type = "custom-event", name = "on_ion_cannon_targeted" },
    { type = "custom-event", name = "on_ion_cannon_fired" },
})
