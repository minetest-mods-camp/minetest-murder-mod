local function on_load() end



arena_lib.on_enable("murder", function(arena, pl_name)
    local skins_count = #murder_settings.skins
    
    if arena.max_players > skins_count then
        murder.print_error(pl_name, murder.T("The maximum players amount can't exceed the skins amount (@1)!", skins_count))
        return false
    end

    return true
end)



arena_lib.on_start("murder", function(arena)
    arena.match_id = math.random(1, 9999999999)
    murder.log(arena, "\n--- MATCH STARTED ---\n")

    arena_lib.send_message_in_arena(
        arena, 
        "players",
        minetest.colorize("#f9a31b",
            murder_settings.prefix ..
            murder.T(
                "The match will start in @1 seconds!", 
                murder_settings.loading_time
            )
        )
    )
    arena_lib.HUD_send_msg_all(
        "broadcast", 
        arena, 
        murder.T("Read your items description to learn their utility"), 
        murder_settings.loading_time
    )
    
    murder.assign_skins(arena)
    minetest.after(murder_settings.loading_time, function() on_load(arena) end)
end)



arena_lib.on_join("murder", function(pl_name, arena, as_spectator)
    minetest.get_player_by_name(pl_name):get_meta():set_int("show_wielded_item", 2)
end)



arena_lib.on_celebration("murder", function(arena, winner_name)
    murder.log(arena, "- celebration started -")

    for pl_name, _ in pairs(arena.players) do
        arena.roles[pl_name]:on_end(arena, pl_name)
    end
    for pl_name, _ in pairs(arena.spectators) do
        minetest.get_player_by_name(pl_name):get_meta():set_int("show_wielded_item", 0)
    end
end)



arena_lib.on_death("murder", function(arena, pl_name, reason)
    arena.roles[pl_name]:on_death(arena, pl_name, reason)
end)



arena_lib.on_timeout("murder", function(arena)
    murder.team_wins(arena, murder.get_default_role())
end)



-- Blocking /quit.
arena_lib.on_prequit("murder", function(arena, pl_name)
    murder.print_error(pl_name, murder.T("You cannot quit!"))
    return false
end)



arena_lib.on_quit("murder", function(arena, pl_name, is_spectator)
    minetest.get_player_by_name(pl_name):get_meta():set_int("show_wielded_item", 0)
end)



arena_lib.on_disconnect("murder", function(arena, pl_name, is_spectator)
    minetest.get_player_by_name(pl_name):get_meta():set_int("show_wielded_item", 0)
    if is_spectator then return end
    arena.roles[pl_name]:on_eliminated(arena, pl_name)
end)



arena_lib.on_time_tick("murder", function(arena)
    for pl_name, _ in pairs(arena.players) do
        murder.update_HUD(pl_name, "timer_ID", arena.current_time)
        murder.update_HUD(pl_name, "pl_counter", arena.players_amount)
    end
end)
    


function on_load(arena)
    -- Reinitializing the timer to recover the time lost in the custom loading. 
    arena.current_time = arena.initial_time
    murder.assign_roles(arena)
    
    for pl_name in pairs(arena.players) do
        arena.roles[pl_name]:on_start(arena, pl_name)
    end
end
