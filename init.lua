murder = {}
murder.T = minetest.get_translator("murder")
dofile(minetest.get_modpath("murder") .. "/SETTINGS.lua")



minetest.register_on_joinplayer(function (player)
  -- Showing the wielded item if armor_3d is installed.
  player:get_meta():set_int("show_wielded_item", 0)
  murder.restore_skin(player:get_player_name())
end)



arena_lib.register_minigame("murder", {
  name = "Murder",
  icon = "murder_icon.png",
  prefix = murder_settings.prefix,
  temp_properties = {
    roles = {},  -- pl_name : string = role : {}
    match_id = 0,
    emergency_data = {}
  },
  player_properties = {
    emergency_hud = -1,
    emergency_sound = -1
  },
  load_time = 0,
  show_nametags = false,
  show_minimap = false,
  celebration_time = murder_settings.celebration_time,
  disabled_damage_types = {"punch", "fall"},
  time_mode = "decremental"
})



dofile(minetest.get_modpath("murder") .. "/src/deps/visible_wielditem.lua")
dofile(minetest.get_modpath("murder") .. "/src/utils.lua")
dofile(minetest.get_modpath("murder") .. "/src/_debug/logs.lua")
dofile(minetest.get_modpath("murder") .. "/src/_arena_lib/arena_callbacks.lua")
dofile(minetest.get_modpath("murder") .. "/src/_arena_lib/arena_utils.lua")
dofile(minetest.get_modpath("murder") .. "/src/_roles/roles_registration.lua")
dofile(minetest.get_modpath("murder") .. "/src/_roles/detective/detective_role.lua")
dofile(minetest.get_modpath("murder") .. "/src/_roles/murderer/murderer_role.lua")
dofile(minetest.get_modpath("murder") .. "/src/commands.lua")
dofile(minetest.get_modpath("murder") .. "/src/hud.lua")
dofile(minetest.get_modpath("murder") .. "/src/sounds.lua")
