murder = {}
murder.mod_prefix = "murder:"
murder.T = minetest.get_translator("murder")

-- importing settings and items
dofile(minetest.get_modpath("murder") .. "/SETTINGS.lua")
dofile(minetest.get_modpath("murder") .. "/items.lua")



function murder.clear_inventory(player)

  player:get_inventory():remove_item("main", murder.gun) 
  player:get_inventory():remove_item("main", murder.murderer_weapon) 
  player:get_inventory():remove_item("main", murder.finder_chip) 
  player:get_inventory():remove_item("main", murder.sprint_serum) 
  player:get_inventory():remove_item("main", murder.radar_on) 
  player:get_inventory():remove_item("main", murder.radar_off) 
  player:get_inventory():remove_item("main", murder.sprint_serum) 
  
  player:get_inventory():remove_item("craft", murder.gun) 
  player:get_inventory():remove_item("craft", murder.murderer_weapon) 
  player:get_inventory():remove_item("craft", murder.finder_chip) 
  player:get_inventory():remove_item("craft", murder.sprint_serum) 
  player:get_inventory():remove_item("craft", murder.radar_on) 
  player:get_inventory():remove_item("craft", murder.radar_off) 
  player:get_inventory():remove_item("craft", murder.sprint_serum) 

end



minetest.register_on_joinplayer(function (player)

  murder.clear_inventory(player)
  -- enable wielding items if there is armor_3d installed
  player:get_meta():set_int("show_wielded_item", 0)

end)



-- registering the minigame in arena_lib's database
arena_lib.register_minigame("murder", {
  prefix = murder_settings.prefix,

  temp_properties = {
    murderer = "",
    cop = "",
    winner = "",
    thrown_knives = {}
  },
  
  properties = {
    match_duration = 0
  },

  player_properties = {
    original_speed = 1
  },

  hub_spawn_point = murder_settings.hub_spawn_point,
  load_time = 0,
  queue_waiting_time = murder_settings.queue_waiting_time,
  show_nametags = murder_settings.show_nametags,
  show_minimap = murder_settings.show_minimap,
  celebration_time = murder_settings.celebration_time,
  timer = 60,
  disabled_damage_types = {"punch"}
})


-- registering murder_admin privilege
minetest.register_privilege("murder_admin", {  
  description = murder.T("With this you can use /murderadmin")
})



-- importing files
dofile(minetest.get_modpath("murder") .. "/chatcmdbuilder.lua")
dofile(minetest.get_modpath("murder") .. "/commands.lua")
dofile(minetest.get_modpath("murder") .. "/hud.lua")
dofile(minetest.get_modpath("murder") .. "/arena_manager.lua")