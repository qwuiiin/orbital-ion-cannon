local function int(name, setting_type, order, default, minimum, maximum)
    return {
        type = "int-setting",
        name = name,
        setting_type = setting_type,
        order = order,
        default_value = default,
        minimum_value = minimum,
        maximum_value = maximum,
    }
end

local function bool(name, setting_type, order, default)
    return {
        type = "bool-setting",
        name = name,
        setting_type = setting_type,
        order = order,
        default_value = default,
    }
end

data:extend({
    -- Startup: baked into the blast prototypes
    int("ion-cannon-radius", "startup", "a", 25, 2, 500),
    int("ion-cannon-laser-damage", "startup", "b", 2500, 1),
    int("ion-cannon-explosion-damage", "startup", "c", 1000, 1),
    bool("ion-cannon-flames", "startup", "d", true),

    -- Map
    int("ion-cannon-cooldown-seconds", "runtime-global", "a", 300, 2),
    int("ion-cannon-heatup-multiplier", "runtime-global", "b", 2, 1, 50),
    bool("ion-cannon-auto-targeting", "runtime-global", "c", true),
    bool("ion-cannon-target-worms", "runtime-global", "d", true),
    bool("ion-cannon-auto-target-visible", "runtime-global", "e", true),
    int("ion-cannon-min-cannons-ready", "runtime-global", "f", 2, 0),
    int("ion-cannon-chart-tag-duration", "runtime-global", "g", 720, 120),
    bool("ion-cannon-cheat-menu", "runtime-global", "h", false),
    int("ion-cannon-targeter-range", "runtime-global", "i", 100, 10),

    -- Per player
    bool("ion-cannon-play-voices", "runtime-per-user", "a", true),
    {
        type = "string-setting",
        name = "ion-cannon-voice-style",
        setting_type = "runtime-per-user",
        order = "b",
        default_value = "CommandAndConquer",
        allowed_values = { "CommandAndConquer", "TiberianSunEVA", "TiberianSunCABAL" },
    },
    bool("ion-cannon-play-klaxon", "runtime-per-user", "c", true),
    int("ion-cannon-ready-ticks", "runtime-per-user", "d", 300, 1),
    bool("ion-cannon-custom-alerts", "runtime-per-user", "e", true),
})
