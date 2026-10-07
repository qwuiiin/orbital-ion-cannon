-- Overhauls (Space Exploration, Krastorio 2, ...) rename or remove science packs and
-- technologies; keep only what exists so the tech tree never fails to load.
for _, name in pairs({ "orbital-ion-cannon", "auto-targeting" }) do
    local tech = data.raw.technology[name]
    if tech then
        local prerequisites = {}
        for _, prerequisite in pairs(tech.prerequisites or {}) do
            if data.raw.technology[prerequisite] then
                table.insert(prerequisites, prerequisite)
            end
        end
        tech.prerequisites = prerequisites

        local ingredients = {}
        for _, ingredient in pairs(tech.unit.ingredients) do
            if data.raw.tool[ingredient[1]] then
                table.insert(ingredients, ingredient)
            end
        end
        tech.unit.ingredients = ingredients
    end
end
