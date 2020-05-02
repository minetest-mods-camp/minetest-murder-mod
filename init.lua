minetest.register_on_joinplayer(function (player) player:get_inventory():set_list("main", {}) end)

murder = {}

-- initializing arena_lib settings
arena_lib.initialize("murder")

arena_lib.settings("murder", {
  prefix = "Murder > ",
  temp_properties = {
    murderer = " ",
    cop = " "
  },
  hub_spawn_point = {x=0, y=10, z=0}
})

minetest.register_privilege("murder_admin", {  
  description = "With this you can use /murderadmin"
})

-- importing files
dofile(minetest.get_modpath("murder") .. "/items.lua")
dofile(minetest.get_modpath("murder") .. "/chatcmdbuilder.lua")
dofile(minetest.get_modpath("murder") .. "/commands.lua")
dofile(minetest.get_modpath("murder") .. "/hud.lua")
dofile(minetest.get_modpath("murder") .. "/roles_manager.lua")
dofile(minetest.get_modpath("murder") .. "/kill_manager.lua")
dofile(minetest.get_modpath("murder") .. "/arena_manager.lua")
