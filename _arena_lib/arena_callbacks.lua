local function on_load() end


arena_lib.on_enable("murder", function(arena, pl_name)
    local skins_count = #murder_settings.skins
    
    if arena.max_players > skins_count then
        murder.print_msg(pl_name, murder.T("The maximum players amount can't exceed the skins amount (@1)!", skins_count))
        return false
    end

    return true
end)



arena_lib.on_start("murder", function(arena)
    arena_lib.send_message_players_in_arena(
        arena, 
        minetest.colorize("#f9a31b", 
            murder.T("The match will start in @1 seconds!", murder_settings.loading_time)
        )
    )
    arena_lib.HUD_send_msg_all(
        "broadcast", 
        arena, 
        murder.T("Read your items description to learn their utility"), 
        murder_settings.loading_time
    ) 
  
    for pl_name in pairs(arena.players) do
      local player = minetest.get_player_by_name(pl_name)
  
      -- Disable wielding items if there is 3d_armor installed.
      player:get_meta():set_int("show_wielded_item", 2)
    end
    
    murder.assign_skins(arena)
    minetest.after(murder_settings.loading_time, function() on_load(arena) end)
end)



arena_lib.on_end("murder", function(arena, players)
    for pl_name, _ in pairs(players) do
      murder.remove_HUD(pl_name)
      arena_lib.HUD_hide("hotbar", pl_name)
      minetest.get_player_by_name(pl_name):get_meta():set_int("show_wielded_item", 0)
    end
end)



arena_lib.on_celebration("murder", function(arena)
    for pl_name, _ in pairs(arena.players) do
        arena.roles[pl_name].on_end(arena, pl_name)
    end
end)  



arena_lib.on_death("murder", function(arena, pl_name, reason)
    arena.roles[pl_name].on_death(arena, pl_name, reason)
end)



arena_lib.on_timeout("murder", function(arena)
    murder.team_wins(arena, murder.get_default_role())
end)



-- Blocks /quit
arena_lib.on_prequit("murder", function(arena, pl_name)
    murder.print_msg(pl_name, murder.T("You cannot quit!"))
    return false
end)



arena_lib.on_disconnect("murder", function(arena, pl_name)
    arena.roles[pl_name].in_game = false
    arena.roles[pl_name].on_eliminated(arena, pl_name)
end)



arena_lib.on_time_tick("murder", function(arena)
    for pl_name, _ in pairs(arena.players) do
      murder.update_HUD(pl_name, "timer_ID", arena.current_time)
    end
end)
    


function on_load(arena)
    arena.current_time = arena.initial_time
    murder.assign_roles(arena)
    
    for pl_name in pairs(arena.players) do
        murder.generate_HUD(arena, pl_name)
        arena.roles[pl_name].on_start(arena, pl_name)
    end
end
