local function apply_role() end


function murder.player_wins(pl_name)
    local arena = arena_lib.get_arena_by_player(pl_name)
    local player_role_name = murder.T(arena.roles[pl_name].name)
    local winner = pl_name .. " (" .. player_role_name .. ")"
    local player = minetest.get_player_by_name(pl_name)

    arena_lib.load_celebration("murder", arena, winner)
end



function murder.team_wins(arena, role)
    local winner = murder.T("The @1 team", murder.T(role.name))
    arena_lib.load_celebration("murder", arena, winner)
end



function murder.is_player_playing(pl_name)
    local arena = arena_lib.get_arena_by_player(pl_name)
    return arena and arena.in_game
end



function murder.kick_player(pl_name)
    arena_lib.remove_player_from_arena(pl_name, 1)
    murder.remove_HUD(pl_name)
    arena_lib.HUD_hide("hotbar", pl_name)
end



function murder.eliminate_role(pl_name)
    local arena = arena_lib.get_arena_by_player(pl_name)

    murder.kick_player(pl_name)
    arena.roles[pl_name].in_game = false
    arena.roles[pl_name].on_eliminated(arena, pl_name)
end



function murder.get_last_role_in_game(arena)
    -- adding to roles_in_game the roles alive
    local roles_in_game = {}
    for pl_name, role in pairs(arena.roles) do
        if role.in_game then table.insert(roles_in_game, role) end
    end

    local last_role = roles_in_game[1]
    for pl_name, role in pairs(roles_in_game) do
        if last_role.name ~= role.name then return nil end
    end

    return last_role
end



function murder.assign_roles(arena)
    local temp_roles = table.copy(murder.roles)
    assert(#murder.roles > 0, "No roles configured!")
    assert(murder.get_default_role(), "Default role not configured!")

    for pl_name in pairs(arena.players) do
        local random_index
        local random_role
        local is_default_role

        -- Generates the random role until it's not the default one
        repeat
            random_index = math.random(1, #temp_roles)
            random_role = temp_roles[random_index]
            is_default_role = random_role.name == murder.get_default_role().name
        until not is_default_role or #temp_roles <= 1

        -- If the generated role it's not the default one then this assigns it to
        -- the player and removes it from the roles helper table.
        arena.roles[pl_name] = table.copy(random_role)
        if #temp_roles > 1 then
            table.remove(temp_roles, random_index)
        end

        apply_role(pl_name, random_role)
    end
end



function murder.assign_skins(arena)
    local skins = table.copy(murder_settings.skins)

    for pl_name, _ in pairs(arena.players) do
        local random_index = math.random(1, #skins)
        local player = minetest.get_player_by_name(pl_name)
        local pl_meta = player:get_meta()

        if pl_meta:get_string("murder:original_skin") == "" then
            local serialized_skin = minetest.serialize(player:get_properties().textures)
            pl_meta:set_string("murder:original_skin", serialized_skin)
        end

        player_api.set_textures(player, {skins[random_index]})
        table.remove(skins, random_index)
    end
end



function murder.restore_skin(pl_name)
    local player = minetest.get_player_by_name(pl_name)
    local pl_meta = player:get_meta()
    local original_skin = minetest.deserialize(pl_meta:get_string("murder:original_skin"))
    
    if original_skin then
        player_api.set_textures(player, original_skin)
    end
    pl_meta:set_string("murder:original_skin", "")
end



function murder.get_nearest_player(arena, original_pos, pl_name)
    local nearest_player
    local min_distance
    local players = table.copy(arena.players)

    if pl_name then players[pl_name] = nil end 

    for other_pl_name, _ in pairs(players) do
        local other_pl = minetest.get_player_by_name(other_pl_name)
        if not nearest_player then -- nearest_player and min_distance initialization.
            nearest_player = other_pl 
            local nearest_pl_center = vector.add({x=0, y=1, z=0}, nearest_player:get_pos())
            min_distance = vector.distance(original_pos, nearest_pl_center)
        end
        local other_pl_center = vector.add({x=0, y=1, z=0}, other_pl:get_pos())
        local distance = vector.distance(original_pos, other_pl_center)

        if distance < min_distance then
            nearest_player = other_pl 
            min_distance = distance
        end
    end

    return nearest_player, min_distance
end



function murder.kill_player(killer_name, victim_name)
    local arena = arena_lib.get_arena_by_player(killer_name)
    local killer = minetest.get_player_by_name(killer_name)
    local victim = minetest.get_player_by_name(victim_name)
    local reason = {type = "punch", object = killer}
    local particle_min_pos = vector.add({x=0, y=0.8, z=0}, victim:get_pos())
    local particle_max_pos = vector.add({x=0, y=0.6, z=0}, particle_min_pos)

    minetest.add_particlespawner({
        amount = 50,
        time = 0.25,
        minpos = particle_min_pos,
        maxpos = particle_max_pos,
        minvel = {x=-3, y=-3, z=-3},
        maxvel = {x=3, y=1, z=3},
        minacc = {x=-3, y=-3, z=-3},
        maxacc = {x=3, y=1, z=3},
        minexptime = 0.25,
        maxexptime = 0.25,
        minsize = 1,
        maxsize = 4,
        texture = "blood_particle.png",
    })

    arena.roles[victim_name].on_death(arena, victim_name, reason)
end



function murder.get_roles_alive(arena)
    local count = 0
    for pl_name, role in pairs(arena.roles) do
        if role.in_game then count = count + 1 end
    end
    return count
end



function apply_role(pl_name, role)
    local player = minetest.get_player_by_name(pl_name)
    local player_inv = player:get_inventory()

    arena_lib.HUD_send_msg("hotbar", pl_name, murder.T(role.hotbar_description))

    for i, item in pairs(role.items) do
        player_inv:add_item("main", ItemStack(item))
    end

    player:set_physics_override(role.physics_override)
    minetest.sound_play(role.sound, {pos = player:get_pos(), to_player = pl_name})   
end