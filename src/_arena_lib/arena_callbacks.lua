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
    murder.generate_HUD(arena, pl_name)
    if as_spectator then
        murder.update_hud(pl_name, "role", murder.T("Spectator"))
    end
end)



arena_lib.on_celebration("murder", function(arena, winner_name)
    murder.log(arena, "- celebration started -")

    for pl_name, _ in pairs(arena.players_and_spectators) do
        if arena.roles[pl_name] then
            arena.roles[pl_name]:on_end(arena, pl_name)
        end
        murder.out_of_match_operations(pl_name)
        murder.remove_HUDs(pl_name)
    end
end)



arena_lib.on_end("murder", function(arena, players, winners, spectators, is_forced)
    murder.log(arena, "- match ended -")

    for pl_name, _ in pairs(players) do
        murder.out_of_match_operations(pl_name)
        murder.remove_HUDs(pl_name)
    end
    for pl_name, _ in pairs(spectators or {}) do
        murder.out_of_match_operations(pl_name)
        murder.remove_HUDs(pl_name)
    end
end)



arena_lib.on_death("murder", function(arena, pl_name, reason)
    arena.roles[pl_name]:on_death(arena, pl_name, reason)
end)



arena_lib.on_timeout("murder", function(arena)
    for pl_name, role in pairs(arena.roles) do
        if role.name == "Murderer" then
            murder.player_wins(pl_name)
            return
        end
    end
end)



arena_lib.on_quit("murder", function(arena, pl_name, is_spectator, reason)
    minetest.get_player_by_name(pl_name):get_meta():set_int("show_wielded_item", 0)

    if reason == 0 then
      if is_spectator or not arena.roles or not arena.roles[pl_name] then return end
      arena.roles[pl_name]:on_eliminated(arena, pl_name)
    else
      murder.out_of_match_operations(pl_name)
      murder.remove_HUDs(pl_name)
    end
end)



arena_lib.on_time_tick("murder", function(arena)
    for pl_name, _ in pairs(arena.players_and_spectators) do
        murder.update_hud(pl_name, "timer", arena.current_time)
        murder.update_hud(pl_name, "pl_counter", arena.players_amount)
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



minetest.register_on_chatcommand(function(name, command, params)
    if arena_lib.is_player_in_arena(name, "murder") and not minetest.get_player_privs(name)["kick"] then
        murder.print_error(name, murder.T("You can't use any command while playing!"))
        return true
    end
end)