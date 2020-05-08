
-- Update the timer
local function timer(arena)
    minetest.after(1,
        function() 
            -- Update the HUD
            arena.timer = arena.timer - 1 
            arena.timer = math.abs(arena.timer)
            arena.timer = math.floor(arena.timer)
            for p_name, _ in pairs(arena.players) do
                murder.update_HUD(p_name, "timer_ID", arena.timer)
            end
            
            if arena.timer > 0 then timer(arena) 
            else
                if arena.winner == "" then arena.winner = murder.T("The victims' team") end
                arena_lib.load_celebration("murder", arena, arena.winner)
            end
        end)
end



arena_lib.on_start("murder", function(arena)
    arena_lib.send_message_players_in_arena(arena, minetest.colorize("#f9a31b", murder.T("The match will start in 10 seconds!")))
    minetest.after(10, function()
        murder.match_duration = 180 - 10
        arena.timer = murder.match_duration
        timer(arena)  
            
        murder.manage_roles(arena)
        for pl in pairs(arena.players) do
            murder.generate_HUD(arena, pl)
        end
    end)
end)



arena_lib.on_end("murder", function(_, players)
    for pl, _ in pairs(players) do
        murder.remove_HUD(pl)
    end
end)



arena_lib.on_celebration("murder", function(arena, players)
    arena.winner = "@ended"
end)
