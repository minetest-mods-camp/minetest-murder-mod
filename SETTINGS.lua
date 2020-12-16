--[[
                            ! WARNING !
Don't change the variables names if you don't know what you're doing!

(murder_settings.variable_name = value)
]]


-- ARENA LIB'S SETTINGS --

-- The table that stores all the global variables, don't touch this.
murder_settings = {}

--  The time between the loading state and the start of the match.
murder_settings.loading_time = 10

-- The time between the end of the match and the respawn at the hub.
murder_settings.celebration_time = 5

-- What's going to appear in most of the lines printed by murder.
murder_settings.prefix = "Murder > "

-- The skins that can be applied to each player.
murder_settings.skins = {
    "skin_black_cyan.png",
    "skin_black_gray.png",
    "skin_black_green.png",
    "skin_black_pink.png",
    "skin_black_yellow.png",
    "skin_white_cyan.png",
    "skin_white_gray.png",
    "skin_white_green.png",
    "skin_white_pink.png",
    "skin_white_yellow.png"
}