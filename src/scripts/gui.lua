local mod_gui = require("mod-gui")
local Cannons = require("scripts.cannons")
local Launch = require("scripts.launch")
local Locations = require("scripts.locations")
local Strike = require("scripts.strike")

local Gui = {}

local BUTTON = "ion_cannon_button"
local FRAME = "ion_cannon_frame"

function Gui.init()
    storage.gui_details = storage.gui_details or {}
end

local function cheats_allowed(player)
    return player.admin and settings.global["ion-cannon-cheat-menu"].value
end

function Gui.update_button(player)
    local flow = mod_gui.get_button_flow(player)
    local wanted = Cannons.count(player.force) > 0 or player.cheat_mode or cheats_allowed(player)
    if wanted and not flow[BUTTON] then
        flow.add({
            type = "sprite-button",
            name = BUTTON,
            sprite = "ion-cannon-button",
            style = mod_gui.button_style,
            tooltip = { "ion-cannon.button-tooltip" },
        })
    elseif not wanted and flow[BUTTON] then
        flow[BUTTON].destroy()
    end
end

local function add_status(parent, player)
    local force = player.force
    local summary = Cannons.summary(force)
    if #summary == 0 then
        parent.add({ type = "label", caption = { "ion-cannon.no-cannons" } })
        return
    end

    local status = parent.add({ type = "table", column_count = 4, draw_horizontal_line_after_headers = true })
    for _, header in pairs({ "location", "in-orbit", "ready", "next-ready" }) do
        status.add({ type = "label", caption = { "ion-cannon.column-" .. header }, style = "caption_label" })
    end
    for _, entry in pairs(summary) do
        status.add({ type = "label", caption = entry.label })
        status.add({ type = "label", caption = entry.total })
        status.add({ type = "label", caption = entry.ready })
        status.add({ type = "label", caption = entry.next_ready and { "ion-cannon.seconds", entry.next_ready } or "-" })
    end

    if storage.gui_details[player.index] then
        local details = parent.add({ type = "table", column_count = 3 })
        for number, cannon in ipairs(Cannons.list(force)) do
            details.add({ type = "label", caption = "#" .. number })
            details.add({ type = "label", caption = Cannons.label(cannon.location) })
            if Cannons.is_ready(cannon) then
                details.add({ type = "label", caption = { "ion-cannon.ready" } })
            else
                details.add({ type = "label", caption = { "ion-cannon.cooldown", math.ceil((cannon.ready_at - game.tick) / 60) } })
            end
        end
    end
end

local function add_admin(parent, player)
    parent.add({ type = "line" })
    parent.add({
        type = "checkbox",
        caption = { "mod-setting-name.ion-cannon-auto-targeting" },
        state = storage.auto_targeting,
        tags = { ion_cannon = "auto_targeting" },
    })

    if cheats_allowed(player) then
        local cheats = parent.add({ type = "flow", direction = "horizontal" })
        cheats.add({ type = "button", caption = { "ion-cannon.cheat-add-one" }, tags = { ion_cannon = "cheat_add", count = 1 } })
        cheats.add({ type = "button", caption = { "ion-cannon.cheat-add-five" }, tags = { ion_cannon = "cheat_add", count = 5 } })
        cheats.add({ type = "button", caption = { "ion-cannon.cheat-remove-one" }, tags = { ion_cannon = "cheat_remove" } })
    end

    parent.add({ type = "label", caption = { "ion-cannon.permissions" }, style = "caption_label" })
    local permissions = parent.add({ type = "table", column_count = 2 })
    for _, other in pairs(game.players) do
        permissions.add({ type = "label", caption = other.name })
        permissions.add({
            type = "checkbox",
            state = Strike.allowed(other),
            tags = { ion_cannon = "permission", player_index = other.index },
        })
    end
end

local function build(player)
    local frame = mod_gui.get_frame_flow(player).add({
        type = "frame",
        name = FRAME,
        direction = "vertical",
        caption = { "ion-cannon.title" },
        style = mod_gui.frame_style,
    })
    frame.add({ type = "flow", name = "status", direction = "vertical" })
    frame.add({
        type = "checkbox",
        caption = { "ion-cannon.show-details" },
        state = storage.gui_details[player.index] or false,
        tags = { ion_cannon = "details" },
    })
    if player.admin then
        add_admin(frame.add({ type = "flow", name = "admin", direction = "vertical" }), player)
    end
    add_status(frame.status, player)
end

function Gui.toggle(player)
    local frame = mod_gui.get_frame_flow(player)[FRAME]
    if frame then
        frame.destroy()
    else
        build(player)
    end
end

--- Rebuilds an open window from scratch (permissions, admin state).
function Gui.rebuild(player)
    local frame = mod_gui.get_frame_flow(player)[FRAME]
    if frame then
        frame.destroy()
        build(player)
    end
end

--- Refreshes the cooldown numbers of an open window.
function Gui.refresh(player)
    local frame = mod_gui.get_frame_flow(player)[FRAME]
    if frame then
        frame.status.clear()
        add_status(frame.status, player)
    end
end

function Gui.refresh_all()
    for _, player in pairs(game.connected_players) do
        Gui.update_button(player)
        Gui.refresh(player)
    end
end

function Gui.on_gui_click(event)
    local element = event.element
    if element.name == BUTTON then
        Gui.toggle(game.get_player(event.player_index))
        return
    end
    local action = element.tags and element.tags.ion_cannon
    if not action then
        return
    end

    local player = game.get_player(event.player_index)
    if not cheats_allowed(player) then
        return
    end
    if action == "cheat_add" then
        local location = Locations.of(player.surface)
        if location then
            Launch.deploy(player.force, location, element.tags.count)
        else
            player.print({ "ion-cannon.cannot-target-here" })
        end
    elseif action == "cheat_remove" then
        if Cannons.remove_last(player.force) then
            player.force.print({ "ion-cannon.removed" })
        else
            player.print({ "ion-cannon.no-cannons" })
        end
    end
    Gui.refresh_all()
end

function Gui.on_gui_checked_state_changed(event)
    local element = event.element
    local action = element.tags and element.tags.ion_cannon
    if not action then
        return
    end

    local player = game.get_player(event.player_index)
    if action == "details" then
        storage.gui_details[player.index] = element.state
        Gui.refresh(player)
    elseif player.admin and action == "auto_targeting" then
        storage.auto_targeting = element.state
        for _, other in pairs(game.connected_players) do
            Gui.rebuild(other)
        end
    elseif player.admin and action == "permission" then
        storage.blocked[element.tags.player_index] = not element.state or nil
        for _, other in pairs(game.connected_players) do
            Gui.rebuild(other)
        end
    end
end

return Gui
