-- THIS RANDOMLY DECIDES WHO IS THE MURDERER AND WHO IS THE COP --

function murder.manage_roles(arena)
  local players_count = 0
  -- Counts how many players there are in the arena
  for _ in pairs(arena.players) do
    players_count = players_count + 1
  end

  -- Chooses a random number between 1 and players_count 
  -- os.clock is used as seed, because its value constantly changes
  local random_murderer = PcgRandom(os.clock()):next(1, players_count)
  local random_cop = random_murderer
  local randomizer = 2

  -- This randomly generates the random cop until it is different from the murderer
  while random_cop == random_murderer do 
    random_cop = PcgRandom(os.clock() * randomizer):next(1, players_count)
    randomizer = randomizer + 1
  end
  players_count = 0

  for pl_name, _ in pairs(arena.players) do
    players_count = players_count + 1
    local player_inv = minetest.get_player_by_name(pl_name):get_inventory()

    -- If this player is the murderer update his inventory
    if players_count == random_murderer then
      arena.murderer = pl_name
      minetest.chat_send_player(pl_name, murder.T("You are the murderer!"))
      player_inv:add_item("main", "murder:knife")
      player_inv:add_item("main", "murder:finder_chip")
    
    -- If this player is the cop update his inventory
    elseif players_count == random_cop then
      arena.cop = pl_name
      minetest.chat_send_player(pl_name, murder.T("You are the cop!"))
      player_inv:add_item("main", "murder:gun")
      player_inv:add_item("main", "murder:radar_on")
      player_inv:add_item("main", "murder:sprint_serum")

    else
      minetest.chat_send_player(pl_name, murder.T("You are a victim!"))
      player_inv:add_item("main", "murder:radar_on")
      player_inv:add_item("main", "murder:sprint_serum")
    end
  end
end