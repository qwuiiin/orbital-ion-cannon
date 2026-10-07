local Audio = {}

--- Plays an announcer line in the voice the player picked.
function Audio.voice(player, line)
    local settings = player.mod_settings
    if settings["ion-cannon-play-voices"].value then
        player.play_sound({ path = line .. "-" .. settings["ion-cannon-voice-style"].value })
    end
end

function Audio.voice_force(force, line)
    for _, player in pairs(force.connected_players) do
        Audio.voice(player, line)
    end
end

--- "Ion cannon ready", at most once per the player's announcement interval.
function Audio.announce_ready(force)
    storage.voice_tick = storage.voice_tick or {}
    for _, player in pairs(force.connected_players) do
        local next_tick = storage.voice_tick[player.index] or 0
        if next_tick <= game.tick then
            storage.voice_tick[player.index] = game.tick + player.mod_settings["ion-cannon-ready-ticks"].value
            Audio.voice(player, "ion-cannon-ready")
        end
    end
end

--- Klaxon for everyone looking at the targeted surface, once per second at most.
function Audio.klaxon(surface)
    if (storage.klaxon_tick or 0) > game.tick then
        return
    end
    storage.klaxon_tick = game.tick + 60
    for _, player in pairs(game.connected_players) do
        if player.surface == surface and player.mod_settings["ion-cannon-play-klaxon"].value then
            player.play_sound({ path = "ion-cannon-klaxon" })
        end
    end
end

return Audio
