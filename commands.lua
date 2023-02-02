-- Registering the murder_admin privilege.
minetest.register_privilege("murder_admin", {
    description = murder.T("It allows you to use /murder")
})



ChatCmdBuilder.new("murder", function(cmd)

    cmd:sub("tutorial", function(name)
        minetest.chat_send_player(name, "See the TUTORIAL.txt file in the mod folder.")
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
    - disable <arena name>
    - logs <arena name>
    ]],
  privs = { murder_admin = true }
})
