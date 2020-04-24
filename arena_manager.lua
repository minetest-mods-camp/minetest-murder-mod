
arena_lib.on_start("murder", function(arena)
    match_duration = 180
    arena.timer = match_duration
    timer(arena)  
        
    manage_roles(arena)
    for pl in pairs(arena.players) do
        generate_HUD(arena, pl)
    end
end)



arena_lib.on_end("murder", function(_, players)
    for pl, _ in pairs(players) do
        remove_HUD(pl)
    end
end)


-- Update the timer
function timer(arena)
    minetest.after(1,
        function() 
            arena.timer = arena.timer - 1 
            for p_name, _ in pairs(arena.players) do
                update_HUD(p_name, "timer_ID", arena.timer)
            end
            if arena.timer > 0 then timer(arena) 
            else
                if  arena.murderer ~= "" then
                    arena_lib.send_message_players_in_arena(arena, "The time is over, victims won!")
                end
                arena_lib.end_arena(arena_lib.mods["murder"], "murder", arena)
            end
        end)
end
