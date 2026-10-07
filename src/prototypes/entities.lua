local radius = settings.startup["ion-cannon-radius"].value
local laser_damage = settings.startup["ion-cannon-laser-damage"].value
local explosion_damage = settings.startup["ion-cannon-explosion-damage"].value
local flames = settings.startup["ion-cannon-flames"].value

local empty = {
    filename = "__core__/graphics/empty.png",
    priority = "low",
    width = 1,
    height = 1,
    frame_count = 1,
}

local function area(area_radius, effects)
    return {
        type = "area",
        radius = area_radius,
        action_delivery = { type = "instant", target_effects = effects },
    }
end

local function damage(share)
    return {
        { type = "damage", damage = { amount = laser_damage * share, type = "laser" } },
        { type = "damage", damage = { amount = explosion_damage * share, type = "explosion" } },
    }
end

local visuals = {
    type = "direct",
    action_delivery = {
        type = "instant",
        target_effects = {
            { type = "create-entity", entity_name = "ion-cannon-blast" },
            { type = "create-entity", entity_name = "ion-cannon-beam" },
            { type = "create-entity", entity_name = "ion-cannon-shockwave" },
            { type = "create-entity", entity_name = "ion-cannon-scorchmark", check_buildability = true },
            { type = "show-explosion-on-chart", scale = radius / 20 },
        },
    },
}

-- With flames off the full damage spreads over the whole radius instead of
-- concentrating in the inner 80 %, and only trees catch fire.
local strike_action
if flames then
    strike_action = {
        visuals,
        area(radius * 0.8, damage(1)),
        area(radius * 0.8, {
            { type = "create-fire", entity_name = "fire-flame" },
            { type = "create-fire", entity_name = "fire-flame-on-tree" },
        }),
        area(radius, {
            { type = "create-sticker", sticker = "fire-sticker" },
            { type = "create-fire", entity_name = "fire-flame" },
            { type = "create-fire", entity_name = "fire-flame-on-tree" },
        }),
    }
else
    strike_action = {
        visuals,
        area(radius, damage(0.5)),
        area(radius, { { type = "create-fire", entity_name = "fire-flame-on-tree" } }),
        area(radius, damage(0.5)),
    }
end

local blast = table.deepcopy(data.raw.explosion["massive-explosion"])
blast.name = "ion-cannon-blast"
blast.localised_name = { "entity-name.ion-cannon-blast" }
blast.sound = { filename = "__OrbitalIonCannon-SE__/sound/OrbitalIonCannon.ogg", volume = 1.0, audible_distance_modifier = 3 }
blast.light = { intensity = 2, size = radius * 3 }

local scorchmark = table.deepcopy(data.raw.corpse["big-scorchmark-tintable"])
scorchmark.name = "ion-cannon-scorchmark"
scorchmark.localised_name = { "entity-name.ion-cannon-scorchmark" }
scorchmark.order = "a-d-z"
-- the base sheet covers ~15 tiles; stretch it over the blast diameter
local scorch_scale = radius * 2 / 15
for _, layer in pairs({ "ground_patch", "ground_patch_higher" }) do
    if scorchmark[layer] and scorchmark[layer].sheet then
        scorchmark[layer].sheet.scale = (scorchmark[layer].sheet.scale or 1) * scorch_scale
    end
end

data:extend({
    blast,
    scorchmark,
    {
        type = "artillery-flare",
        name = "ion-cannon-flare",
        icon = "__OrbitalIonCannon-SE__/graphics/crosshairs64.png",
        icon_size = 64,
        flags = { "placeable-off-grid", "not-on-map" },
        hidden = true,
        map_color = { 1, 0.1, 0.1 },
        life_time = 2,
        shots_per_flare = 0, -- never attract artillery
        pictures = { empty },
    },
    {
        type = "simple-entity",
        name = "ion-cannon-target",
        icon = "__OrbitalIonCannon-SE__/graphics/crosshairs64.png",
        icon_size = 64,
        flags = { "placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable" },
        hidden = true,
        max_health = 1,
        collision_mask = { layers = {} },
        render_layer = "air-object",
        animations = {
            {
                filename = "__OrbitalIonCannon-SE__/graphics/crosshairs_anim.png",
                priority = "low",
                width = 64,
                height = 64,
                frame_count = 32,
                line_length = 8,
                animation_speed = 0.35,
                shift = { 0, -1 },
            },
        },
    },
    {
        type = "projectile",
        name = "ion-cannon-strike",
        flags = { "not-on-map" },
        hidden = true,
        acceleration = 0,
        action = strike_action,
        animation = empty,
    },
    {
        type = "smoke-with-trigger",
        name = "ion-cannon-beam",
        flags = { "not-on-map" },
        hidden = true,
        show_when_smoke_off = true,
        animation = {
            filename = "__OrbitalIonCannon-SE__/graphics/IonBeam.png",
            priority = "low",
            width = 110,
            height = 1871,
            frame_count = 1,
            line_length = 1,
            shift = { -0.1, -27.5 },
        },
        slow_down_factor = 0,
        affected_by_wind = false,
        cyclic = false,
        duration = 60 * 2,
        fade_away_duration = 60,
        spread_duration = 10,
    },
    {
        type = "smoke-with-trigger",
        name = "ion-cannon-shockwave",
        flags = { "not-on-map" },
        hidden = true,
        show_when_smoke_off = true,
        animation = {
            filename = "__OrbitalIonCannon-SE__/graphics/explosion.png",
            priority = "low",
            width = 192,
            height = 192,
            frame_count = 25,
            line_length = 5,
            animation_speed = 0.2,
            scale = radius / 3,
        },
        slow_down_factor = 0,
        affected_by_wind = false,
        cyclic = false,
        duration = 60 * 5,
        spread_duration = 10,
    },
})
