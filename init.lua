murder = {}
murder.T = minetest.get_translator("murder")


function murder.clear_inventory(player)
  player:get_inventory():remove_item("main", "murder:gun") 
  player:get_inventory():remove_item("main", "murder:knife") 
  player:get_inventory():remove_item("main", "murder:finder_chip") 
  player:get_inventory():remove_item("main", "murder:sprint_serum") 
  player:get_inventory():remove_item("main", "murder:radar_on") 
  player:get_inventory():remove_item("main", "murder:radar_off") 
  player:get_inventory():remove_item("main", "murder:sprint_serum") 
  
  player:get_inventory():remove_item("craft", "murder:gun") 
  player:get_inventory():remove_item("craft", "murder:knife") 
  player:get_inventory():remove_item("craft", "murder:finder_chip") 
  player:get_inventory():remove_item("craft", "murder:sprint_serum") 
  player:get_inventory():remove_item("craft", "murder:radar_on") 
  player:get_inventory():remove_item("craft", "murder:radar_off") 
  player:get_inventory():remove_item("craft", "murder:sprint_serum") 
end


minetest.register_on_joinplayer(function (player)
  player:set_hp(20) 
  murder.clear_inventory(player)
end)


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
