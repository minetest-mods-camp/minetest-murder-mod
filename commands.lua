-- THIS REGISTERS ALL IN-CHAT COMMANDS --

ChatCmdBuilder.new("murderadmin", function(cmd)

    -- create arena
    cmd:sub("tutorial", function(name)
        minetest.chat_send_player(name, [[

        1) Creating the arena using:

        /murderadmin create <arena name> [min players] [max players]
        where min players is equal to the minimun amount of players 
        to make the arena start, and max players to the maximum 
        amount of players that an arena can have.


        2) Editing the arena using:

        /murderadmin edit <arena name>
        in this menu you can add spawn points and set up the sign to
        enter the arena: the spawn points are where the players will
        spawn when they enter the arena, while the sign is just the 
        way to enter it (by clicking it).


        3) Setting the match duration in the editor menu by 
        clicking on the clock in the settings.


        4) Enabling the arena using:

        /murderadmin enable <arena name>


        Once you've done this you can click the sign and start 
        playing :)
        Use /help murderadmin to see all the commands.
        ]])
    end)



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
    cmd:sub("play :sound :gain:number", function(p_name, sound, gain)
        minetest.sound_play(sound, { pos = minetest.get_player_by_name(p_name):get_pos(), to_player = p_name, gain = gain})
    end)
    

end, {
  description = [[

    Use this to configure your arena:
    - tutorial
    - create <arena name> [min players] [max players]
    - edit <arena name> 
    - enable <arena name>
    
    Other commands:
    - list
    - info <arena name>
    - remove <arena name>
    - removechest <arena name>
    - disable <arena>
    ]],
  privs = { murder_admin = true }
})
