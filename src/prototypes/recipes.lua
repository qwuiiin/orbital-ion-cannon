local function item(name, amount)
    return { type = "item", name = name, amount = amount }
end

data:extend({
    {
        type = "recipe",
        name = "orbital-ion-cannon",
        enabled = false,
        energy_required = 60,
        ingredients = {
            item("low-density-structure", 100),
            item("solar-panel", 100),
            item("accumulator", 200),
            item("radar", 10),
            item("processing-unit", 200),
            item("electric-engine-unit", 25),
            item("laser-turret", 50),
            item("rocket-fuel", 50),
        },
        results = { item("orbital-ion-cannon", 1) },
    },
})
