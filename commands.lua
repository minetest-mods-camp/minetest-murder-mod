-- THIS REGISTERS ALL IN-CHAT COMMANDS --

ChatCmdBuilder.new("murderadmin", function(cmd)

    -- create arena
    cmd:sub("create :arena", function(name, arena_name)
        arena_lib.create_arena(name, "murder", arena_name)
    end)

    cmd:sub("create :arena :minplayers:int :maxplayers:int", function(name, arena_name, min_players, max_players)
        arena_lib.create_arena(name, "murder", arena_name, min_players, max_players)
    end)

    -- remove arena
    cmd:sub("remove :arena", function(name, arena_name)
        arena_lib.remove_arena(name, "murder", arena_name)
    end)

    -- list of the arenas
    cmd:sub("list", function(name)
        arena_lib.print_arenas(name, "murder")
    end)

    -- info on a specific arena
    cmd:sub("info :arena", function(name, arena_name)
        arena_lib.print_arena_info(name, "murder", arena_name)
      end)

    -- this sets the spawns using the player position
    cmd:sub("setspawn :arena", function(name, arena)
        arena_lib.set_spawner(name, "murder", arena)
      end)

    cmd:sub("setspawn :arena :spawnID:int", function(name, arena, spawn_ID)
        arena_lib.set_spawner(name, "murder", arena, spawn_ID)
    end)

    -- this sets the sign used to enter the arena
    cmd:sub("signtool :arena", function(name, arena)
        arena_lib.give_sign_tool(name, "murder", arena)
    end)

    -- this sets the match duration of the arena
    cmd:sub("matchduration :arenaName :duration:int", function(name, arena_name, duration)
        local id, arena = arena_lib.get_arena_by_name( "murder", arena_name)
        arena.match_duration = duration
        minetest.chat_send_player(name, arena_name .. " match duration set to " .. arena.match_duration)
    end)

    -- enable and disable arenas
    cmd:sub("enable :arena", function(name, arena)
        arena_lib.enable_arena(name, "murder", arena)
    end)

    cmd:sub("disable :arena", function(name, arena)
        arena_lib.disable_arena(name, "murder", arena)
    end)

end, {
  description = [[
    
    <obligatory parameter>  [optional parameter]

    - create <arena name> [min players] [max players]
    - setspawn <arena name> [spawnID]
    - signtool <arena name>
    - matchduration <arena> <duration>
    - enable <arena name>
    - disable <arenaID>
    - remove <arena name>
    - list
    - info <arena name>
    - matchduration <arena> <duration>
    ]],
  privs = { murder_admin = true }
})
