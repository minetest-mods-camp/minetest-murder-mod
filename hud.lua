local saved_huds = {} -- p_name = {hud_name, index}

function murder.generate_HUD(arena, p_name)

  local player = minetest.get_player_by_name(p_name)

  local backgound
  local timer 
  local role
  local waypoint 

  -- Assign role
  if p_name == arena.murderer then
    role = murder.T("Murderer")
  elseif p_name == arena.cop then
    role = murder.T("Cop")
  else
    role = murder.T("Victim")
  end  

  -- Sets the murderer background image
  background = player:hud_add({
    hud_elem_type = "image",
    position  = {x = 0.91, y = 0.03},
    text      = "HUD_timer.png",
    alignment = { x = 1.0},
    scale     = { x = 1, y = 1},
    number    = 0xFFFFFF,
  })

  -- Sets the timer text
  timer = player:hud_add({
    hud_elem_type = "text",
    position  = {x = 0.966, y = 0.03},
    text      = timer,
    alignment = { x = 1.0},
    scale     = { x = 2, y = 2},
    number    = 0xFFFFFF,
  })

  -- Sets the role text
  role = player:hud_add({
    hud_elem_type = "text",
    position  = {x = 0.929, y = 0.03},
    text      = role,
    alignment = { x = 0},
    scale     = { x = 100, y = 10},
    number    = 0xFFFFFF,
  })

  -- Save the huds IDs for each player 
  saved_huds[p_name] = {
    role_ID = role,
    backgound_ID = background,
    timer_ID = timer,
  }

end



function murder.update_HUD(p_name, field, new_value)

  local player = minetest.get_player_by_name(p_name)
  player:hud_change(saved_huds[p_name][field], "text", new_value)

end


-- TODO: Make this an image_waypoint when minetest 5.3 gets released
function murder.set_waypoint(p_name, target_pos)

  local player = minetest.get_player_by_name(p_name)

  -- Sets the waypoint used by the murderer
  waypoint = player:hud_add({
    hud_elem_type = "waypoint",
    world_pos  = {x = target_pos.x, y = target_pos.y + 1, z = target_pos.z},
    text      = " × " .. murder.T("LAST POSITION"),
    scale     = { x = 5, y = 5},
    number    = 0xdf3e23,
    size = { x=200, y=200 },
  })

  minetest.after(12, function() player:hud_remove(waypoint) end)

end


function murder.remove_HUD(p_name)

  local player = minetest.get_player_by_name(p_name)
  for name, id in pairs(saved_huds[p_name]) do
    player:hud_remove(id)
  end
end
