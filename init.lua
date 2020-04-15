dofile(minetest.get_modpath("murder") .. "/items.lua")
dofile(minetest.get_modpath("murder") .. "/arena_lib/api.lua")
dofile(minetest.get_modpath("murder") .. "/chatcmdbuilder.lua")
dofile(minetest.get_modpath("murder") .. "/commands.lua")
dofile(minetest.get_modpath("murder") .. "/hud.lua")
dofile(minetest.get_modpath("murder") .. "/roles_manager.lua")
dofile(minetest.get_modpath("murder") .. "/kill_manager.lua")
dofile(minetest.get_modpath("murder") .. "/arena_manager.lua")

-- Delete player's inventory when he joins
minetest.register_on_joinplayer(function (player) player:get_inventory():set_list("main", {}) end)

arena_lib.settings({
  prefix = "Murder > "
})


minetest.register_privilege("murder_admin", {
    
  description = "With this you can use /murderadmin"
  
})

register_items()