
function arena_lib.on_start(arena)
    match_duration = 180
    arena.timer = match_duration
    timer(arena)
    
    minetest.after(match_duration,
        function ()
            if arena_lib.get_arena_players_count(arena) > 1 then
                arena_lib.send_message_players_in_arena(arena, "The time is over, victims won!")
            end
            arena_lib.end_arena(arena)
        end)  
        
    manage_roles(arena)
    for pl in pairs(arena.players) do
        generate_HUD(arena, pl)
    end
end


function arena_lib.on_end(_, players)
    for pl, _ in pairs(players) do
        remove_HUD(pl)
    end
end
