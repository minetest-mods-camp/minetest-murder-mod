-- THIS REGISTER ALL THE ITEMS AND THEIR LOGIC --
-- Generating the items' names
murder.murderer_weapon = murder.mod_prefix .. "knife"
murder.finder_chip =  murder.mod_prefix .. "finder_chip"
murder.sprint_serum =  murder.mod_prefix .. "sprint_serum"
murder.radar_on =  murder.mod_prefix .. "radar_on"
murder.radar_off =  murder.mod_prefix .. "radar_off"
murder.gun =  murder.mod_prefix .. "gun"
-- The throwable knife entity declaration
local throwable_knife = {
    initial_properties = {
        hp_max = 1000,
        physical = true,
        collide_with_objects = false,
        collisionbox = {-0.15, -0.15, -0.15, 0.15, 0.15, 0.15},
        visual = "wielditem",
        visual_size = {x = 0.4, y = 0.4},
        textures = {murder.murderer_weapon},
        spritediv = {x = 1, y = 1},
        initial_sprite_basepos = {x = 0, y = 0},
        speed = 32,
        gravity = 11,
    },
    p_name = "",
    knife_dropped = false
}




--------------------------
-- ! Other functions ! --
--------------------------

local function look_raycast(object, range)

    local pos = {}
    local looking_dir = 0
    local shoot_dir = 0

    if object:is_player() then
        local pl_pos = object:get_pos()
        pos = {x = pl_pos.x, y = pl_pos.y+1.5, z = pl_pos.z}
        looking_dir = object:get_look_dir()
        shoot_dir = vector.multiply(looking_dir, range)
    else
        pos = object:get_pos()
        looking_dir = vector.normalize(object:get_velocity())
        shoot_dir = vector.multiply(looking_dir, range)
    end
    -- Casts a ray from the player head position 'till the same position
    local ray = minetest.raycast(vector.add(pos, vector.divide(looking_dir, 4)), vector.add(pos, shoot_dir), true, false)

    return ray, pos, shoot_dir

end



-- The function that will be called when the murderer kills someone
local function murder_player(hit_pl, p_name)

    local player = minetest.get_player_by_name(p_name)

    if hit_pl:get_hp() <= 0 then return end

    hit_pl:set_hp(0)
    minetest.chat_send_player(p_name, murder.T("You murdered @1", hit_pl:get_player_name()))
    minetest.sound_play("murder_knife_hit", { max_hear_distance = 10, pos = player:get_pos(), gain = 1 })
    minetest.add_particlespawner({
            amount = 50,
            time = 0.25,
            minpos = {x=0, y=0.8, z=0},
            maxpos = {x=0, y=1.2, z=0},
            minvel = {x=-3, y=-3, z=-3},
            maxvel = {x=3, y=1, z=3},
            minacc = {x=-3, y=-3, z=-3},
            maxacc = {x=3, y=1, z=3},
            minexptime = 0.25,
            maxexptime = 0.25,
            minsize = 1,
            maxsize = 4,
            attached = hit_pl,
            texture = "blood_particle.png",
        }
    )

end



function murder.remove_knives(arena)

    if not arena.thrown_knives then return end
    for i = 1, #arena.thrown_knives do
        arena.thrown_knives[i]:remove()
    end

end



local function remove_knife(knife, arena)

    for i = 1, #arena.thrown_knives do
        if knife == arena.thrown_knives[i] then
            table.remove(arena.thrown_knives, i)
        end
    end
    knife:remove()

end



----------------------
-- ! Knife Entity ! --
----------------------

-- staticdata = player's username
function throwable_knife:on_activate(staticdata, dtime_s)

    if staticdata ~= "" then
        self.knife_dropped = false
        self.p_name = staticdata
        local player = minetest.get_player_by_name(self.p_name)
        local yaw = player:get_look_horizontal()
        local pitch = player:get_look_vertical()
        local dir = player:get_look_dir()
        local arena = arena_lib.get_arena_by_player(staticdata)

        self.object:set_rotation({x = -pitch, y = yaw+55, z = 0})

        self.object:set_velocity({
            x=(dir.x * self.initial_properties.speed),
            y=(dir.y * self.initial_properties.speed),
            z=(dir.z * self.initial_properties.speed),
        })
        self.object:set_acceleration({x=dir.x*-3, y=-self.initial_properties.gravity, z=dir.z*-3})
    end

    return

end


function throwable_knife:drop()

    local obj = self.object
    local obj_pos = obj:get_pos()

    self.knife_dropped = true
    obj:set_velocity({x=0, y=0, z=0})
    obj:set_acceleration({x=0, y=0, z=0})

    minetest.after(0.1, function()
        obj:set_pos(obj_pos)
    end)
    minetest.after(15, function()
        local player = minetest.get_player_by_name(self.p_name)
        local arena = arena_lib.get_arena_by_player(self.p_name)

        if not player or not arena or not arena.thrown_knives[1] then return end
        local pl_inv = player:get_inventory()

        murder.remove_knives(arena)
        pl_inv:add_item("main", ItemStack(murder.murderer_weapon))
    end)

    minetest.sound_play("knife_hit_block", { max_hear_distance = 10, gain = 1, pos = obj_pos })

end



function throwable_knife:on_rightclick(clicker)

    local p_name = clicker:get_player_name()

    if arena_lib.is_player_in_arena(p_name, "murder") and arena_lib.get_arena_by_player(p_name).murderer == p_name and self.knife_dropped then
        minetest.get_player_by_name(p_name):get_inventory():add_item("main", murder.murderer_weapon)
        remove_knife(self.object, arena_lib.get_arena_by_player(p_name))
    end

end



function throwable_knife:on_step(dtime, moveresult)

    local player = minetest.get_player_by_name(self.p_name)

    if player == nil then
        self.object:remove()
        return
    end

    local ray = look_raycast(self.object, 1)

    -- Kills a player with a raycast
    for hit in ray do
        if self.knife_dropped then return end

        if hit.type == "object" and hit.ref:is_player() and hit.ref:get_player_name() ~= self.p_name then
            local hit_name = hit.ref:get_player_name()

            if hit.ref:get_hp() <= 0 then return end

            murder_player(hit.ref, self.p_name)

        end
    end

    if moveresult.collides == true then
      for k, collision in pairs(moveresult.collisions) do
        if collision.type == "node" then
          -- If it hit a block and it hasn't dropped yet
          if self.knife_dropped == false then
              self:drop()
              return
          end
        end
      end
    end

end

minetest.register_entity("murder:throwable_knife", throwable_knife)



----------------------------
-- ! Items Registration ! --
----------------------------

local function register_items()

    -- The knife used by the murderer
    minetest.register_craftitem(murder.murderer_weapon, {
        description = murder.T("With this you can kill other players, seems fun, doesn't it?\nRight click in the air to throw it, then right click it again to take it back"),
        inventory_image = "knife.png",
        damage_groups = {fleshy = 3},
        stack_max = 1,
        on_drop = function() return nil end, -- Prevents this item from being dropped
        on_use =
            function(_, player, pointed_thing)

                local p_name = player:get_player_name()

                if not arena_lib.is_player_in_arena(p_name) then return end

                local arena = arena_lib.get_arena_by_player(p_name)

                if arena.in_game == false then return end

                -- If the knife is used on a player kill him
                if pointed_thing.type == "object" and pointed_thing.ref:is_player() then
                    local hit_pl = pointed_thing.ref
                    murder_player(hit_pl, p_name)
                end

            end,
        on_secondary_use =
            function(_, player, pointed_thing)
                local p_name = player:get_player_name()

                if not arena_lib.is_player_in_arena(p_name) then return end

                local arena = arena_lib.get_arena_by_player(p_name)

                if arena.in_game == false then return end

                -- Throw the knife and save it
                local entity = minetest.add_entity(vector.add({x=0, y=1.5, z=0}, player:get_pos()), "murder:throwable_knife", p_name)
                table.insert(arena.thrown_knives, entity)
                minetest.sound_play("throw_knife", { max_hear_distance = 5, gain = 1, pos = player:get_pos() })
                minetest.after(0, function() player:get_inventory():remove_item("main", murder.murderer_weapon) end)
            end
    })


    -- The following chip used by the murderer
    minetest.register_craftitem(murder.finder_chip, {
        description = murder.T("Left click to find the nearest player's last position!"),
        inventory_image = "finder_chip.png",
        stack_max = 1,
        -- Prevents this item from being dropped
        on_drop = function() return nil end,
        on_use =
            function(_, player, pointed_thing)

                local p_name = player:get_player_name()

                minetest.sound_play("finder-chip", { pos = player:get_pos(), gain = 1, to_player = p_name })

                if arena_lib.is_player_in_arena(p_name) then
                    local nearest_player
                    local arena = arena_lib.get_arena_by_player(p_name)

                    -- This saves the nearest player in nearest_player
                    for name, _ in pairs(arena.players) do
                        local player2 = minetest.get_player_by_name(name)

                        if nearest_player == nil and p_name ~= name then nearest_player = player2 end

                        if p_name ~= name and vector.distance(player:get_pos(), player2:get_pos()) < vector.distance(player:get_pos(), nearest_player:get_pos()) then
                            nearest_player = player2
                        end
                    end

                    murder.set_waypoint(p_name, nearest_player:get_pos())
                end

                -- Removes the chip from the inventory
                minetest.after(0, function() player:get_inventory():remove_item("main", murder.finder_chip) end)

            end
    })


    -- The sprint serum used by the murderer
    minetest.register_craftitem(murder.sprint_serum, {
        description = murder.T("Boost your speed for 3s"),
        inventory_image = "sprint_serum.png",
        stack_max = 1,
        -- Prevents this item from being dropped
        on_drop = function(itemstack, dropper, pos) end,
        on_use =
            function (_, player)

                local inv = player:get_inventory()
                local p_name = player:get_player_name()
                -- It removes this item from the player inventory, then it sets and resets the player speed
                minetest.after(0, function() inv:remove_item("main", murder.sprint_serum) end)
                player: set_physics_override({ speed = 2 })

                minetest.after(3, function() player:set_physics_override({ speed = 1 }) end)
                minetest.chat_send_player(p_name, minetest.colorize("#df3e23", murder.T("You feel electrified!")))
                minetest.sound_play("sprint-serum", { pos = player:get_pos(), to_player = p_name })

            end
    })


    -- The gun used by the cop
    minetest.register_craftitem(murder.gun, {
        description = murder.T("Kill the murderer with this, but beware if you hit a victim you die!"),
        inventory_image = "gun.png",
        stack_max = 1,
        -- Prevents this item from being dropped
        on_drop = function() end,
        on_use =
            function(itemstack, player)

                local pmeta = player:get_meta()
                local p_name = player:get_player_name()

                -- Check if the player is in the arena and is fighting, if not it exit
                if not arena_lib.is_player_in_arena(p_name) then return end

                local arena = arena_lib.get_arena_by_player(p_name)

                if arena.in_game == false then return end

                if pmeta:get_string("murder:canShoot") ~= "false" then
                    local ray, pos_head, shoot_dir = look_raycast(player, 30)
                    local particle_shot = {
                        pos = pos_head,
                        velocity = vector.multiply(shoot_dir, 2),
                        size = 1,
                        texture = "shoot_particle.png",
                        glow = 12
                    }

                    minetest.add_particle(particle_shot)

                    -- If the raycast hits a player it kills him
                    for hit in ray do
                        if hit.type == "object" and hit.ref:is_player() and hit.ref:get_player_name() ~= player:get_player_name() then
                            local hit_name = hit.ref:get_player_name()

                            if hit.ref:get_hp() <= 0 then break end

                            hit.ref:set_hp(0, "shot")

                            -- Kills the cop if it shoots a victim
                            if arena_lib.is_player_in_arena(hit_name) and arena_lib.is_player_in_arena(p_name) then
                                if arena.murderer ~= hit_name then
                                    minetest.chat_send_player(p_name, murder.T("You killed a victim!"))
                                    player:set_hp(0)
                                end
                            end

                            break
                        end
                    end

                    minetest.sound_play("murder_gun_shoot", { max_hear_distance = 20, gain = 1, pos = player:get_pos() })
                    pmeta:set_string("murder:canShoot", "false")
                    minetest.after(1, function() pmeta:set_string("murder:canShoot", "true") end)
                else
                    minetest.sound_play("murder_empty_gun", { max_hear_distance = 10, gain = 1 , pos = player:get_pos() })
                end
                return nil

            end
    })

    -- The radar used by the victim
    minetest.register_craftitem(murder.radar_on, {
        description = murder.T("Left click to detect if the killer is within 15 blocks from you!"),
        inventory_image = "radar_on.png",
        stack_max = 1,
        on_use =
            function(itemstack, player)

                local p_name = player:get_player_name()

                if arena_lib.is_player_in_arena(p_name) then
                    local arena = arena_lib.get_arena_by_player(p_name)
                    local found = false

                    for name, _ in pairs(arena.players) do
                        if vector.distance(player:get_pos(), minetest.get_player_by_name(name):get_pos()) <= 15 and arena.murderer == name then
                            minetest.chat_send_player(p_name, murder.T("The killer is nearby!"))
                            found = true
                            break
                        end
                    end
                    if found == false then minetest.chat_send_player(p_name, murder.T("The killer is not nearby!")) end
                    minetest.sound_play("victim-radar", { pos = player:get_pos(), gain = 1, to_player = p_name })
                end

                player:get_inventory():add_item("main", murder.radar_off)
                minetest.after(5,
                    function()
                        if arena_lib.is_player_in_arena(p_name) then player:get_inventory():add_item("main", murder.radar_on) end
                        player:get_inventory():remove_item("main", murder.radar_off)
                    end)
                minetest.after(0, function() player:get_inventory():remove_item("main", murder.radar_on) end)

            end,
        on_drop = function() return nil end
    })

    minetest.register_craftitem(murder.radar_off, {
        description = murder.T("Left click to detect if the killer is within 15 blocks from you!"),
        inventory_image = "radar_off.png",
        stack_max = 1,
        on_use = function(itemstack, player) minetest.chat_send_player(player:get_player_name(), murder.T("The radar is recharging!")) end,
        on_drop = function() return nil end,
    })
end



register_items()
