-- THIS HANDLES IN-GAME KILLS -- 

minetest.register_on_dieplayer(
function(player)
    local p_name = player:get_player_name()
    local arenaID = arena_lib.get_arenaID_by_player(p_name)
    local arena = arena_lib.arenas[arenaID]

    -- If the player is in an arena
    if arena_lib.is_player_in_arena(p_name) then

        -- If someone kills the murderer the match finishes and victims win
        if arena.murderer == p_name then
            for pl_name in pairs(arena.players) do
                minetest.chat_send_player(pl_name, "The murderer has been killed by " .. arena.cop .. ", victims won the game!")
            end
            arena_lib.end_arena(arena)
            
        -- If the murderer kills everyone the match finishes and he wins 
        -- (the reason why it checks if there are only 2 players left instead of 1 is because when a player gets killed he doesn't automatically get kicked out from the arena)
        elseif arena_lib.get_arena_players_count(arenaID) == 2 then
            for pl_name in pairs(arena.players) do
                minetest.chat_send_player(pl_name, arena.murderer .. " the murderer won!")
            end
            arena_lib.end_arena(arena)

        -- When somebody dies this sends a message to him
        else
            arena_lib.remove_player_from_arena(p_name)
            minetest.chat_send_player(p_name, "You've been killed!")
        end
    end
end)
