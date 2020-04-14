
function arena_lib.on_start(arena)
    match_duration = 180
    arena.timer = match_duration
    timer(arena)  
        
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
