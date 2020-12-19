-- Registering the murder_admin privilege.
minetest.register_privilege("murder_admin", {  
    description = murder.T("It allows you to use /murder")
})



ChatCmdBuilder.new("murder", function(cmd)

    cmd:sub("tutorial", function(name)
        minetest.chat_send_player(name, "See the TUTORIAL.txt file in the mod folder.")
    end)



    cmd:sub("create :arena", function(name, arena_name)
        arena_lib.create_arena(name, "murder", arena_name)
    end)



    cmd:sub("create :arena :minplayers:int :maxplayers:int", function(name, arena_name, min_players, max_players)
        arena_lib.create_arena(name, "murder", arena_name, min_players, max_players)
    end)



    cmd:sub("remove :arena", function(name, arena_name)
        arena_lib.remove_arena(name, "murder", arena_name)
    end)

    
    
    -- list of the arenas
    cmd:sub("list", function(name)
        arena_lib.print_arenas(name, "murder")
    end)



    cmd:sub("info :arena", function(name, arena_name)
        arena_lib.print_arena_info(name, "murder", arena_name)
    end)



    -- This sets the spawns using the player position.
    cmd:sub("setspawn :arena", function(name, arena)
        arena_lib.set_spawner(name, "murder", arena)
    end)



    -- This sets the arena sign.
    cmd:sub("setsign :arena", function(sender, arena)
        arena_lib.set_sign(sender, nil, nil, "murder", arena)
    end)


    
    cmd:sub("edit :arena", function(sender, arena)
        arena_lib.enter_editor(sender, "murder", arena)
    end)



    cmd:sub("enable :arena", function(name, arena)
        arena_lib.enable_arena(name, "murder", arena)
    end)



    cmd:sub("disable :arena", function(name, arena)
        arena_lib.disable_arena(name, "murder", arena)
    end)



    -- Debug commands:
    cmd:sub("play :sound :gain:number", function(pl_name, sound, gain)
        minetest.sound_play(sound, { pos = minetest.get_player_by_name(pl_name):get_pos(), gain = gain})
    end)



    cmd:sub("logs :arena", function(pl_name, arena)
        murder.print_logs(arena, pl_name)
    end)

end, {
  description = [[
     
    ADMIN COMMANDS
    (Use /help murder to read it all)

    Use this to configure your arena:
    - tutorial
    - create <arena name> [min players] [max players]
    - edit <arena name> 
    - enable <arena name>
    
    Other commands:
    - list
    - info <arena name>
    - remove <arena name>
    - disable <arena>
    - logs <arena>
    ]],
  privs = { murder_admin = true }
})
