local saved_huds = {} -- pl_name = {hud name = id}

function murder.generate_HUD(arena, pl_name)
  local player = minetest.get_player_by_name(pl_name)
  local pl_role = arena.roles[pl_name]

  local background
  local timer
  local role = murder.T(pl_role.name)
  local vignette

  -- Sets the role background image.
  background = player:hud_add({
    hud_elem_type = "image",
    position  = {x = 1, y = 0},
    offset = {x = -179, y = 32},
    text      = pl_role.HUD_timer or "HUD_murder_timer.png",
    alignment = { x = 1.0},
    scale     = { x = 1.15, y = 1.15},
    number    = 0xFFFFFF,
    z_index = 100
  })

  -- Sets the timer text.
  timer = player:hud_add({
    hud_elem_type = "text",
    position  = {x = 1, y = 0},
    offset = {x = -51, y = 32},
    text      = arena.initial_time,
    alignment = { x = 1.0},
    scale     = { x = 2, y = 2},
    number    = 0xFFFFFF,
    z_index = 100,
  })

  -- Sets the role text.
  role = player:hud_add({
    hud_elem_type = "text",
    position  = {x = 1, y = 0},
    offset = {x = -136, y = 32},
    text      = role,
    alignment = { x = 0},
    scale     = { x = 100, y = 10},
    number    = 0xFFFFFF,
    z_index = 100
  })

  vignette = player:hud_add({
    hud_elem_type = "image",
    position = {x = 0.5, y = 0.5},
    scale = {
      x = -100,
      y = -100
    },
    text = pl_role.vignette or "HUD_murder_vignette.png",
    z_index = 99
  })

  -- Save the huds IDs for each player. 
  saved_huds[pl_name] = {
    role_ID = role,
    backgound_ID = background,
    timer_ID = timer,
    vignette_ID = vignette
  }
end



function murder.update_HUD(pl_name, field, new_value)
  if saved_huds[pl_name] and saved_huds[pl_name][field] then
    local player = minetest.get_player_by_name(pl_name)
    player:hud_change(saved_huds[pl_name][field], "text", new_value)
  end
end



function murder.remove_HUD(pl_name)
  minetest.after(1, function()
    local player = minetest.get_player_by_name(pl_name)
    
    if not player or not saved_huds[pl_name] then return end

    for name, id in pairs(saved_huds[pl_name]) do
      player:hud_remove(id)
    end

    saved_huds[pl_name] = {}
  end)
end



function murder.add_temp_hud(pl_name, hud, time)
  local player = minetest.get_player_by_name(pl_name)
  
  hud = player:hud_add(hud)
  saved_huds[pl_name] = saved_huds[pl_name] or {}
  saved_huds[pl_name][tostring(hud)] = hud

  minetest.after(time, function()
    -- Removing the hud if the player still has it.
    if saved_huds[pl_name] and saved_huds[pl_name][tostring(hud)] then
      player:hud_remove(hud)
      saved_huds[pl_name][tostring(hud)] = nil
    end
  end)

  return hud
end