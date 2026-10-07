local Audio = require("scripts.audio")
local AutoTarget = require("scripts.autotarget")
local Cannons = require("scripts.cannons")
local Gui = require("scripts.gui")
local Launch = require("scripts.launch")
local Migration = require("scripts.migration")
local Strike = require("scripts.strike")

local function on_tick()
    Strike.on_tick()
    if not Strike.pending() then
        script.on_event(defines.events.on_tick, nil)
    end
end

-- on_tick only runs while a strike is heating up
local function watch_strikes()
    if Strike.pending() then
        script.on_event(defines.events.on_tick, on_tick)
    end
end

local function init()
    Cannons.init()
    Strike.init()
    AutoTarget.init()
    Gui.init()
    storage.version = Migration.VERSION
end

script.on_init(init)

script.on_configuration_changed(function()
    Migration.run()
    init()
    for _, player in pairs(game.players) do
        Gui.update_button(player)
    end
end)

script.on_load(watch_strikes)

script.on_nth_tick(60, function()
    for _, force in pairs(Cannons.collect_newly_ready()) do
        Audio.announce_ready(force)
    end
    Strike.expire_chart_tags()
    AutoTarget.process_queue()
    watch_strikes()
    Gui.refresh_all()
end)

script.on_event(defines.events.on_cargo_pod_finished_ascending, function(event)
    Launch.on_cargo_pod_finished_ascending(event)
    for _, player in pairs(game.connected_players) do
        Gui.update_button(player)
    end
end)

script.on_event({ defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area }, function(event)
    Strike.on_player_selected_area(event)
    watch_strikes()
end)

script.on_event(defines.events.on_player_cursor_stack_changed, Strike.on_player_cursor_stack_changed)

script.on_event(defines.events.on_sector_scanned, function(event)
    AutoTarget.on_sector_scanned(event)
    watch_strikes()
end)

script.on_event(defines.events.on_biter_base_built, AutoTarget.on_biter_base_built)

script.on_event(defines.events.on_forces_merged, Cannons.on_forces_merged)

script.on_event("ion-cannon-hotkey", function(event)
    Gui.toggle(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_gui_click, Gui.on_gui_click)
script.on_event(defines.events.on_gui_checked_state_changed, Gui.on_gui_checked_state_changed)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if event.setting == "ion-cannon-cheat-menu" or event.setting == "ion-cannon-auto-targeting" then
        for _, player in pairs(game.players) do
            Gui.update_button(player)
            Gui.rebuild(player)
        end
    end
end)

for _, event in pairs({ defines.events.on_player_created, defines.events.on_player_changed_force, defines.events.on_player_promoted, defines.events.on_player_demoted }) do
    script.on_event(event, function(e)
        local player = game.get_player(e.player_index)
        Gui.update_button(player)
        Gui.rebuild(player)
    end)
end

-- Same interface name and calls as the original Orbital Ion Cannon, so mods built
-- against it keep working.
remote.add_interface("orbital_ion_cannon", {
    on_ion_cannon_targeted = function()
        return prototypes.custom_event["on_ion_cannon_targeted"].event_id
    end,
    on_ion_cannon_fired = function()
        return prototypes.custom_event["on_ion_cannon_fired"].event_id
    end,
    --- @return integer|string|false cannon number, or false when no cannon could fire
    target_ion_cannon = function(force, position, surface, player)
        local result = Strike.target(game.forces[force.name or force], game.get_surface(surface.name or surface), position, player)
        watch_strikes()
        return result
    end,
    --- @return {location: string, total: integer, ready: integer, next_ready: integer?}[]
    get_status = function(force)
        local result = {}
        for _, entry in pairs(Cannons.summary(game.forces[force.name or force])) do
            table.insert(result, { location = entry.key, total = entry.total, ready = entry.ready, next_ready = entry.next_ready })
        end
        return result
    end,
})
