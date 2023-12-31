function murder.remove_bomb(arena)
    if arena.emergency_data and arena.emergency_data.bomb_pos then 
        minetest.set_node(arena.emergency_data.bomb_pos, {name = "air"})
    end

    -- Removing the waypoint and stopping the sound for each player.
    for pl_name, _ in pairs(arena.players_and_spectators) do
        murder.remove_hud(pl_name, "waypoint-emergency")
        murder.stop_sound(pl_name, "murder-emergency")
    end
end



function murder.place_bomb(arena, pl_name)
    local murderer = arena.roles[pl_name]
    local detonation_time = murderer.bomb_detonation_time
    local waypoint_emergency = {
        hud_elem_type = "image_waypoint",
        world_pos = murderer.bomb_pos,
        text      = "HUD_murder_emergency.png",
        scale     = {x = 5, y = 5},
        size = {x = 200, y = 200},
    }

    minetest.set_node(murderer.bomb_pos, {name = "murder:bomb"})
    minetest.get_meta(murderer.bomb_pos):set_string("match_id", tostring(arena.match_id))
    murderer.bomb_detonated = true
    arena.emergency_data.bomb_pos = murderer.bomb_pos
    arena.emergency_data.murderer = murderer
    local original_match_id = arena.match_id

    -- Adding a waypoint and playing music to each player and spectator.
    for pl_name, _ in pairs(arena.players_and_spectators) do
        murder.add_hud(pl_name, "waypoint-emergency", waypoint_emergency)
        murder.add_sound(pl_name, "murder-emergency", {to_player = pl_name, loop = true})
    end

    -- Bomb explosion.
    minetest.after(detonation_time, function()
        if arena.in_game and original_match_id == arena.match_id and murderer.bomb_detonated then
            for pl_name, _ in pairs(arena.players_and_spectators) do
                minetest.sound_play("murder-explosion", {to_player = pl_name})
            end
        
            murder.remove_bomb(arena)
            murder.player_wins(pl_name)
        end
    end)
end