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



    cmd:sub("setspawn :arena", function(name, arena)
        arena_lib.set_spawner(name, "murder", arena)
    end)



    -- this sets the arena's sign
    cmd:sub("setsign :arena", function(sender, arena)
        arena_lib.set_sign(sender, nil, nil, "murder", arena)
    end)



    -- this sets the match duration of the arena
    cmd:sub("matchduration :arenaName :duration:int", function(name, arena_name, duration)
        local id, arena = arena_lib.get_arena_by_name( "murder", arena_name)

        arena.match_duration = duration

        minetest.chat_send_player(name,
         murder_settings.prefix 
        .. minetest.colorize("#f9a31b", arena_name) .. ": " 
        .. murder.T("match duration set to @1", arena.match_duration))
    end)


    
    -- enter editor mode
    cmd:sub("edit :arena", function(sender, arena)
        arena_lib.enter_editor(sender, "murder", arena)
    end)



    -- enable and disable arenas
    cmd:sub("enable :arena", function(name, arena)
        arena_lib.enable_arena(name, "murder", arena)
    end)



    cmd:sub("disable :arena", function(name, arena)
        arena_lib.disable_arena(name, "murder", arena)
    end)


    -- Debug commands
    cmd:sub("play :sound :gaint:number", function(p_name, sound, gain)
        minetest.sound_play(sound, { pos = minetest.get_player_by_name(p_name):get_pos(), to_player = p_name, gain = gain})
    end)
    

end, {
  description = [[
    
    /murderadmin + 
        <obligatory parameter>  [optional parameter]

    Use this to configure your arena:
    - create <arena name> [min players] [max players]
    - edit <arena name> 
    - matchduration <arena> <duration in seconds>
    - enable <arena>

    Manual configuration:
    - setspawn <arena name>
    - setsign <arena name>
    
    Other commands:
    - list
    - info <arena name>
    - remove <arena name>
    - disable <arena>
    ]],
  privs = { murder_admin = true }
})
