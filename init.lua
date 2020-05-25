minetest.register_on_joinplayer(function (player)
  player:set_hp(20) 
  player:get_inventory():set_list("main", {}) 
  player:get_inventory():set_list("craft", {})
end)


murder = {}
murder.T = minetest.get_translator("murder")


-- registering the minigame in arena_lib's database
arena_lib.register_minigame("murder", {
  prefix = "Murder > ",
  temp_properties = {
    murderer = "",
    cop = "",
    winner = ""
  },
  properties = {
    match_duration = 0
  },
  hub_spawn_point = {x=0, y=10, z=0},
  load_time = 2,
  queue_waiting_time = 10
})
arena_lib.update_properties("murder")


-- registering murder_admin privilege
minetest.register_privilege("murder_admin", {  
  description = murder.T("With this you can use /murderadmin")
})


-- importing files
dofile(minetest.get_modpath("murder") .. "/items.lua")
dofile(minetest.get_modpath("murder") .. "/chatcmdbuilder.lua")
dofile(minetest.get_modpath("murder") .. "/commands.lua")
dofile(minetest.get_modpath("murder") .. "/hud.lua")
dofile(minetest.get_modpath("murder") .. "/roles_manager.lua")
dofile(minetest.get_modpath("murder") .. "/kill_manager.lua")
dofile(minetest.get_modpath("murder") .. "/arena_manager.lua")
