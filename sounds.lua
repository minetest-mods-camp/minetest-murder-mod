local saved_sounds = {} -- pl_name = {name = id}


function murder.stop_sounds(pl_name)
  local player = minetest.get_player_by_name(pl_name)
    
  if not player or not saved_sounds[pl_name] then return end

  for name, sound in pairs(saved_sounds[pl_name]) do
    minetest.sound_stop(sound)
  end

  saved_sounds[pl_name] = nil
end



function murder.add_temp_sound(pl_name, name, def, time)
  local player = minetest.get_player_by_name(pl_name)
  
  sound = minetest.sound_play(name, def)
  saved_sounds[pl_name] = saved_sounds[pl_name] or {}
  saved_sounds[pl_name][sound] = sound

  minetest.after(time, function()
    if saved_sounds[pl_name] and saved_sounds[pl_name][sound] then
      minetest.sound_stop(sound)
      saved_sounds[pl_name][sound] = nil
    end
  end)

  return sound
end