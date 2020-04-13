function arena_lib.on_start(arena)
    minetest.after(10,
    function ()
        if arena_lib.get_arena_players_count(arena) > 1 then
            arena_lib.send_message_players_in_arena(arena, "The time is over, victims won!")
        end
        arena_lib.end_arena(arena)
    end)  
    manage_roles(arena)
end