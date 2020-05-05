-- THIS HANDLES IN-GAME KILLS -- 

arena_lib.on_death("murder", function(arena, p_name)
    
    minetest.after(1, function()
        -- If someone kills the murderer the match finishes and victims win
        if arena.murderer == p_name then
            arena_lib.send_message_players_in_arena(arena, murder.T("The murderer has been killed by") .. " " .. minetest.colorize("#f9a31b", arena.cop))
            arena.timer = 0
            arena.winner = murder.T("The victims' team")

        -- If the murderer kills everyone the match finishes and he wins 
        -- (the reason why it checks if there are only 2 players left instead of 1 is because when a player gets killed he doesn't automatically get kicked out from the arena)
        elseif arena_lib.get_arena_players_count(arena) == 2 then
            arena.winner = minetest.colorize("#f9a31b", arena.murderer) .. " " .. murder.T("the murderer")
            arena.timer = 0

        -- When somebody dies this sends a message to him
        else
            if p_name == arena.cop then arena.timer = arena.timer / 2 end
            minetest.get_player_by_name(p_name):get_inventory():set_list("main", {})
            minetest.get_player_by_name(p_name):get_inventory():set_list("craft", {})
            murder.remove_HUD(p_name)
            arena_lib.remove_player_from_arena(p_name, true)
            minetest.chat_send_player(p_name, murder.T("You've been killed!"))
        end
    end)
end)
