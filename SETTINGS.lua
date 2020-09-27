--[[
                            ! WARNING !
Don't change the variables' names if you don't know what you're doing

(murder_settings.variable_name = value)
]]



-- ARENA LIB'S SETTINGS --

-- The table that stores all the global variables, don't touch this.
murder_settings = {}

-- Where players will be teleported when a match ends.
murder_settings.hub_spawn_point = {x = 0, y = 10, z = 0}

--  The time between the loading state and the start of the match.
murder_settings.loading_time = 10

-- The time to wait before the loading phase starts. It gets triggered when the minimium amount of players has been reached to start the queue.
murder_settings.queue_waiting_time = 10

-- The time between the end of the match and the respawn at the hub.
murder_settings.celebration_time = 3

-- What's going to appear in most of the lines printed by murder.
murder_settings.prefix = "Murder > "

-- Whether to show the players nametags while in game.
-- false = don't / true = do
murder_settings.show_nametags = false

-- Whether to allow players to use the builtin minimap function.
murder_settings.show_minimap = false