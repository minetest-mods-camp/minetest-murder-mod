dofile(minetest.get_modpath("murder") .. "/items.lua")
dofile(minetest.get_modpath("murder") .. "/arena_lib/api.lua")
dofile(minetest.get_modpath("murder") .. "/chatcmdbuilder.lua")
dofile(minetest.get_modpath("murder") .. "/commands.lua")
dofile(minetest.get_modpath("murder") .. "/roles_manager.lua")
dofile(minetest.get_modpath("murder") .. "/kill_manager.lua")

arena_lib.settings({
  prefix = "Murder > "
})

minetest.register_privilege("murder_admin", {
    
  description = "With this you can use /murderadmin"
  
})

register_items()