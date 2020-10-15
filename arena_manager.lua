-- Assigning each player a role
local function manage_roles(arena)

  local players_count = arena.players_amount

  -- Chooses a random number between 1 and players_count
  -- os.clock is used as seed, because its value constantly changes
  local random_murderer = math.random(1, players_count)
  local random_cop = math.random(1, players_count)

  -- This randomly generates the cop until it is different from the murderer
  while random_cop == random_murderer and players_count > 1 do
    random_cop = math.random(1, players_count)
  end

  players_count = 0
  for p_name, _ in pairs(arena.players) do
    players_count = players_count + 1
    local player = minetest.get_player_by_name(p_name)
    local player_inv = player:get_inventory()


    -- If this player is the murderer
    if players_count == random_murderer then
      arena.murderer = p_name
      arena_lib.HUD_send_msg("hotbar", p_name, murder.T("You are the murderer, kill everyone!"))

      player_inv:add_item("main", murder.murderer_weapon)
      player_inv:add_item("main", murder.finder_chip)

      player:set_physics_override({speed=1.1})
      minetest.sound_play("murderer-role", { pos = player:get_pos(), to_player = p_name })

    -- If this player is the cop
    elseif players_count == random_cop then
      arena.cop = p_name

      arena_lib.HUD_send_msg("hotbar", p_name, murder.T("You are the cop, kill the murderer but BEWARE if you kill a victim you'll die!"))
      player_inv:add_item("main", murder.gun)
      player_inv:add_item("main", murder.radar_on)
      player_inv:add_item("main", murder.sprint_serum)

      minetest.sound_play("cop-role", { pos = player:get_pos(), to_player = p_name })


    else
      arena_lib.HUD_send_msg("hotbar", p_name, murder.T("You are a victim, survive until the end!"))
      player_inv:add_item("main", murder.radar_on)
      player_inv:add_item("main", murder.sprint_serum)

      minetest.sound_play("victim-role", { pos = player:get_pos(), to_player = p_name })
    end
  end

end



arena_lib.on_time_tick("murder", function(arena)

  -- Updates the HUD
  for p_name, _ in pairs(arena.players) do
    murder.update_HUD(p_name, "timer_ID", arena.current_time)
  end

end)



arena_lib.on_timeout("murder", function(arena)
  if arena.winner == "" then
    arena.winner = murder.T("The victims' team")
  end
  minetest.after(0.1, function() arena_lib.load_celebration("murder", arena, arena.winner) end)
end)



arena_lib.on_start("murder", function(arena)

  arena_lib.send_message_players_in_arena(arena, minetest.colorize("#f9a31b", murder.T("The match will start in @1 seconds!", murder_settings.loading_time)))
  arena_lib.HUD_send_msg_all("broadcast", arena, murder.T("To know what an item does you can read its description in the inventory"), 10)

  -- disable wielding items if there is armor_3d installed

  for p_name in pairs(arena.players) do
    minetest.get_player_by_name(p_name):get_meta():set_int("show_wielded_item", 2)
  end

  minetest.after(murder_settings.loading_time,
    function()
      arena.current_time = arena.initial_time
      manage_roles(arena)
      for p_name in pairs(arena.players) do
        local player = minetest.get_player_by_name(p_name)

        murder.generate_HUD(arena, p_name)
        arena.players[p_name].original_speed = player:get_physics_override().speed

        if p_name == arena.murderer then player:set_physics_override({speed=1.1})
        else player:set_physics_override({speed=1}) end
      end

    end)

end)



local function victims_wins(arena)

  if minetest.get_player_by_name(arena.murderer) ~= nil then
    arena_lib.send_message_players_in_arena(
      arena,
      minetest.colorize("#f9a31b", arena.murderer) .. " "
      .. murder.T("the murderer has been killed by") .. " "
      .. minetest.colorize("#f9a31b", arena.cop)
    )
  else
    arena_lib.send_message_players_in_arena(
      arena,
      minetest.colorize("#f9a31b", arena.murderer) .. " "
      .. murder.T("the murderer quit the server")
    )
  end

  arena.current_time = 2
  arena.winner = murder.T("The victims' team")

end



local function murderer_wins(arena)

  arena.winner = minetest.colorize("#f9a31b", arena.murderer) .. " " .. murder.T("the murderer")
  arena.current_time = 2

end



local function cop_dies(arena, p_name)

  arena.current_time = math.ceil(arena.current_time / 2)

  if minetest.get_player_by_name(arena.cop) == nil then
    arena_lib.send_message_players_in_arena(arena, minetest.colorize("#f9a31b", murder.T("The cop quit the server, time has been halved!")))

  else
    arena_lib.send_message_players_in_arena(arena, minetest.colorize("#f9a31b", murder.T("The cop has been eliminated, time has been halved!")))
    murder.clear_inventory(minetest.get_player_by_name(p_name))
    murder.remove_HUD(p_name)
    arena_lib.remove_player_from_arena(p_name, 1)
    minetest.chat_send_player(p_name, murder.T("You died!"))
    arena_lib.HUD_hide("hotbar", p_name)
  end

end



local function victim_dies(arena, p_name)

  if minetest.get_player_by_name(p_name) ~= nil then
    murder.clear_inventory(minetest.get_player_by_name(p_name))
    arena_lib.remove_player_from_arena(p_name, 1)
    minetest.chat_send_player(p_name, murder.T("You died!"))
    murder.remove_HUD(p_name)
    arena_lib.HUD_hide("hotbar", p_name)
  end

end



local function on_player_dies(arena, p_name, disconnected)

  -- When a player disconnects he/she gets kicked before this function,
  -- if it is the case 'disconnected' will be set to 1 to fix this.
  if disconnected == true then
    disconnected = 1
  else
    disconnected = 0
  end

  -- If someone kills the murderer the match finishes and victims win
  if arena.murderer == p_name then
    victims_wins(arena, p_name)

  -- If the cop dies and he/she is not the last victim
  elseif arena.cop == p_name and arena.players_amount+disconnected > 2 then
    cop_dies(arena, p_name)

  -- If the murderer kills everyone
  -- (the reason why it checks if there are only 2 players left instead of 1 is because when a player gets killed
  -- he doesn't automatically get kicked out from the arena)
  elseif arena.players_amount+disconnected == 2 then
    murderer_wins(arena)

  -- When a victim dies
  else
    victim_dies(arena, p_name)
  end

end



arena_lib.on_death("murder", function(arena, p_name)

  minetest.after(0.1, function() on_player_dies(arena, p_name, false) end)

end)



arena_lib.on_end("murder", function(arena, players)

  for p_name, _ in pairs(players) do
    murder.remove_HUD(p_name)
    arena_lib.HUD_hide("hotbar", p_name)
    minetest.get_player_by_name(p_name):get_meta():set_int("show_wielded_item", 0)
  end

end)



arena_lib.on_celebration("murder", function(arena)

  remove_knives(arena)
  for p_name, _ in pairs(arena.players) do
    local player = minetest.get_player_by_name(p_name)

    minetest.get_player_by_name(p_name):get_meta():set_int("show_wielded_item", 0)
    player:set_physics_override({speed=arena.players[p_name].original_speed})
  end

end)


-- Blocks /quit
arena_lib.on_prequit("murder", function(arena, p_name)

  minetest.chat_send_player(p_name, murder.T("You cannot quit!"))
  return false

end)



arena_lib.on_quit("murder", function(arena, p_name)

  minetest.get_player_by_name(p_name):get_meta():set_int("show_wielded_item", 0)
  murder.remove_HUD(p_name)
  arena_lib.HUD_hide("hotbar", p_name)

end)



-- When a player quits the game call on_player_dies
arena_lib.on_disconnect("murder", function(arena, p_name)

  if arena.murderer == p_name then
    remove_knives(arena)
  end
  if arena.in_celebration == false then
    minetest.after(0.1, function() on_player_dies(arena, p_name, true) end)
  end

end)
