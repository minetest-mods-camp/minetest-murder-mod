--[[
                            ! WARNING !
Don't change the variables' names if you don't know what you're doing

(murder_settings.variable_name = value)
]]



-- ARENA LIB'S SETTINGS --

-- The table that stores all the global variables, don't touch this.
murder_settings = {}

--  The time between the loading state and the start of the match.
murder_settings.loading_time = 10

-- The time between the end of the match and the respawn at the hub.
murder_settings.celebration_time = 3

-- What's going to appear in most of the lines printed by murder.
murder_settings.prefix = "Murder > "

-- Whether to show the players nametags while in game.
-- false = don't / true = do
murder_settings.show_nametags = false

-- Whether to allow players to use the builtin minimap function.
murder_settings.show_minimap = false
