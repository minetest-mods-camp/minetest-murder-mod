-- THIS REGISTERS ALL IN-CHAT COMMANDS --

ChatCmdBuilder.new("murderadmin", function(cmd)

    -- create arena
    cmd:sub("create :arena", function(name, arena_name)
        arena_lib.create_arena(name, arena_name)
    end)

    cmd:sub("create :arena :minplayers:int :maxplayers:int", function(name, arena_name, min_players, max_players)
        arena_lib.create_arena(name, "murder", arena_name, min_players, max_players)
    end)

    -- remove arena
    cmd:sub("remove :arena", function(name, arena_name)
        arena_lib.remove_arena("murder", arena_name)
    end)

    -- list of the arenas
    cmd:sub("list", function(name)
        arena_lib.print_arenas(name, "murder")
    end)

    -- info on a specific arena
    cmd:sub("info :arena", function(name, arena_name)
        arena_lib.print_arena_info(name, "murder", arena_name)
      end)

    -- info on game stats
    cmd:sub("score :arena", function(name, arena_name)
        arena_lib.print_arena_stats(name, arena_name)
      end)

    -- this sets the spawns using the player position
    cmd:sub("setspawn :arena", function(name, arena)
        arena_lib.set_spawner(name, "murder", arena)
      end)

    cmd:sub("setspawn :arena :spawnID:int", function(name, arena, spawn_ID)
        arena_lib.set_spawner(name, "murder", arena, spawn_ID)
    end)


    -- this sets the sign used to enter the arena
    cmd:sub("setsign :arena", function(name, arena)
        arena_lib.set_sign(name, "murder", arena)
    end)

    -- enable and disable arenas
    cmd:sub("enable :arenaID:number", function(name, arenaID)
        arena_lib.enable_arena(name, "murder", arenaID)
    end)

    cmd:sub("disable :arenaID:number", function(name, arenaID)
        arena_lib.disable_arena(name, "murder", arenaID)
    end)

end, {
  description = "description",
  privs = { murder_admin = true }
})
