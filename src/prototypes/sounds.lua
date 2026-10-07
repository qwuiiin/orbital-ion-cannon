local voices = { "CommandAndConquer", "TiberianSunEVA", "TiberianSunCABAL" }
local lines = {
    ["ion-cannon-ready"] = "IonCannonReady",
    ["ion-cannon-charging"] = "IonCannonCharging",
    ["select-target"] = "SelectTarget",
    ["unable-to-comply"] = "UnableToComply",
}

for _, voice in pairs(voices) do
    for name, file in pairs(lines) do
        data:extend({
            {
                type = "sound",
                name = name .. "-" .. voice,
                filename = "__OrbitalIonCannon-SE__/sound/" .. voice .. "/" .. file .. ".ogg",
                volume = 0.75,
            },
        })
    end
end

data:extend({
    {
        type = "sound",
        name = "ion-cannon-klaxon",
        filename = "__OrbitalIonCannon-SE__/sound/Klaxon.ogg",
        volume = 0.75,
    },
})
