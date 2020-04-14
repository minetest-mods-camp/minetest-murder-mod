local saved_huds = {} -- p_name = {hud_name, index}

function generate_HUD(arena, p_name)

  local player = minetest.get_player_by_name(p_name)

  local backgound
  local timer = 0
  local role
  
  -- Assign role
  if p_name == arena.murderer then
    role = "Murderer"
  elseif p_name == arena.cop then
    role = "Cop"
  else
    role = "Victim"
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
    text      = timer .. "s",
    alignment = { x = 1.0},
    scale     = { x = 2, y = 2},
    number    = 0xFFFFFF,
  })

  -- Sets the role text
  role = player:hud_add({
    hud_elem_type = "text",
    position  = {x = 0.928, y = 0.03},
    text      = role,
    alignment = { x = 0},
    scale     = { x = 100, y = 10},
    number    = 0xFFFFFF,
  })


  -- Save the huds IDs for each player 
  saved_huds[p_name] = {
    role_ID = role,
    backgound_ID = background,
    timer_ID = timer
  }

end



function update_HUD(p_name, field, new_value)

  local player = minetest.get_player_by_name(p_name)
  player:hud_change(saved_huds[p_name][field], "text", new_value)

end



function remove_HUD(p_name)

  local player = minetest.get_player_by_name(p_name)
  for name, id in pairs(saved_huds[p_name]) do
    player:hud_remove(id)
  end
end


-- Update the timer's HUD
function timer(arena)
    minetest.after(1,
      function() 
        arena.timer = arena.timer - 1 
        for p_name, _ in pairs(arena.players) do
          update_HUD(p_name, "timer_ID", arena.timer .. "s")
        end
        if arena.timer > 0 then timer(arena) end
      end)
  end