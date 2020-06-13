-- Assigning each player a role
local function manage_roles(arena)

  local players_count = 0

  -- Counts how many players there are in the arena
  for _ in pairs(arena.players) do
    players_count = players_count + 1
  end

  -- Chooses a random number between 1 and players_count 
  -- os.clock is used as seed, because its value constantly changes
  local random_murderer = PseudoRandom(os.clock()):next(1, players_count)
  local random_cop = random_murderer
  local randomizer = 2

  -- This randomly generates the random cop until it is different from the murderer
  while random_cop == random_murderer do 
    random_cop = PseudoRandom(os.clock() * randomizer):next(1, players_count)
    randomizer = randomizer + 1
  end

  players_count = 0

  for p_name, _ in pairs(arena.players) do
    players_count = players_count + 1
    local player_inv = minetest.get_player_by_name(p_name):get_inventory()

    -- If this player is the murderer update his inventory
    if players_count == random_murderer then
      arena.murderer = p_name
      arena_lib.HUD_send_msg("hotbar", p_name, murder.T("You are the murderer, kill everyone!"))

      player_inv:add_item("main", murder.murderer_weapon)
      player_inv:add_item("main", murder.finder_chip)
    
    -- If this player is the cop update his inventory
    elseif players_count == random_cop then
      arena.cop = p_name
      arena_lib.HUD_send_msg("hotbar", p_name, murder.T("You are the cop, kill the murderer but BEWARE if you kill a victim you'll die!"))
      player_inv:add_item("main", murder.gun)
      player_inv:add_item("main", murder.radar_on)
      player_inv:add_item("main", murder.sprint_serum)

    else
      arena_lib.HUD_send_msg("hotbar", p_name, murder.T("You are a victim, survive until the end!"))
      player_inv:add_item("main", murder.radar_on)
      player_inv:add_item("main", murder.sprint_serum)
    end
  end

end
  


-- Update the timer
local function timer(arena)

  minetest.after(1,
    function() 
      if arena.timer > 0 then timer(arena) 
        arena.timer = arena.timer - 1 
        arena.timer = math.floor(math.abs(arena.timer))

        -- Update the HUD
        for p_name, _ in pairs(arena.players) do
          murder.update_HUD(p_name, "timer_ID", arena.timer)
        end
      else
        if arena.winner == "" then arena.winner = murder.T("The victims' team") end
        minetest.after(0.1, function() arena_lib.load_celebration("murder", arena, arena.winner) end)
      end
    end)

end



arena_lib.on_start("murder", function(arena)

  arena_lib.send_message_players_in_arena(arena, minetest.colorize("#f9a31b", murder.T("The match will start in 10 seconds!")))
  minetest.after(10,
    function()
      arena.timer = arena.match_duration
      timer(arena)  
          
      manage_roles(arena)
      for p_name in pairs(arena.players) do
        murder.generate_HUD(arena, p_name)
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
  
  arena.timer = 0
  arena.winner = murder.T("The victims' team")

end



local function murderer_wins(arena)

  arena.winner = minetest.colorize("#f9a31b", arena.murderer) .. " " .. murder.T("the murderer")
  arena.timer = 0

end



local function cop_dies(arena, p_name)

  arena.timer = arena.timer / 2 

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
  -- if it is the case disconnected will be set to 1 to fix this. 
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
  elseif arena.players_amount+disconnected  == 2 then
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
  end

end)



arena_lib.on_celebration("murder", function(arena, players)
    
  arena.winner = "@ended"
    
end)



-- Blocks /quit
arena_lib.on_prequit("murder", function(arena, p_name) return false end)



-- When a player quits the game call on_player_dies 
arena_lib.on_disconnect("murder", 
  function(arena, p_name)

    if arena.in_celebration == false then
      minetest.after(0.1, function() on_player_dies(arena, p_name, true) end)
    end

  end)