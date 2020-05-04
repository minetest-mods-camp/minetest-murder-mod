-- THIS REGISTER ALL THE ITEMS AND THEIR LOGIC --

local function register_items()
    
    -- The knife used by the murderer
    minetest.register_craftitem("murder:knife", {
        description = murder.T("With this you can kill other player, seems fun, doesn't it?"),
        inventory_image = "knife.png",
        damage_groups = {fleshy = 3},
        groups = {murder_weapon = 1},
        stack_max = 1,
        -- Prevents this item from being dropped
        on_drop = function() end,
        on_use =
            function(_, player, pointed_thing)
                -- If the knife is used on a player kill him
                if pointed_thing.type == "object" and pointed_thing.ref:is_player() then
                    local hit_pl = pointed_thing.ref

                    if hit_pl:get_hp() <= 0 then return end

                    hit_pl:set_hp(0)
                    minetest.chat_send_player(player:get_player_name(), murder.T("You murdered") .. " " .. hit_pl:get_player_name())
                    minetest.sound_play("murder_knife_hit", { max_hear_distance = 5 })
                end
            end
    })
 

    -- The following chip used by the murderer
    minetest.register_craftitem("murder:finder_chip", {
        description = murder.T("Left click to find the nearest player's last position!"),
        inventory_image = "finder_chip.png",
        stack_max = 1,
        -- Prevents this item from being dropped
        on_drop = function() end,
        on_use = 
            function(_, player, pointed_thing)
                local pl_name = player:get_player_name()

                if arena_lib.is_player_in_arena(pl_name) then
                    local nearest_player
                    local arena = arena_lib.get_arena_by_player(pl_name)

                    -- This saves the nearest player in nearest_player
                    for p_name, _ in pairs(arena.players) do
                        local player2 = minetest.get_player_by_name(p_name)

                        if nearest_player == nil and p_name ~= pl_name then nearest_player = player2 end 

                        if p_name ~= pl_name and vector.distance(player:get_pos(), player2:get_pos()) < vector.distance(player:get_pos(), nearest_player:get_pos()) then
                            nearest_player = player2
                        end
                    end

                    murder.set_waypoint(pl_name, nearest_player:get_pos())
                end

                -- Removes the chip from the inventory
                minetest.after(0, function() player:get_inventory():remove_item("main", "murder:finder_chip") end)
            end
    })


    -- The sprint serum used by the murderer
    minetest.register_craftitem("murder:sprint_serum", {
        description = murder.T("Boost your speed for 6s"),
        inventory_image = "sprint_serum.png",
        stack_max = 1,
        -- Prevents this item from being dropped
        on_drop = function(itemstack, dropper, pos) end,
        on_use = 
            function (_, player)
                local inv = player:get_inventory()

                -- It removes this item from the player inventory, then it sets and resets the player speed
                minetest.after(0, function() inv:remove_item("main", "murder:sprint_serum") end)
                player: set_physics_override({ speed = 2 })
                minetest.after(6, function() player: set_physics_override({ speed = 1 }) end)
                minetest.chat_send_player(player:get_player_name(), minetest.colorize("#df3e23", murder.T("You feel electrified!")))
            end      
    })


    -- The gun used by the cop
    minetest.register_craftitem("murder:gun", { 
        description = murder.T("Kill the murderer with this, but beware if you hit a victim you die!"),
        inventory_image = "gun.png",
        stack_max = 1,
        -- Prevents this item from being dropped
        on_drop = function() end,
        on_use = 
            function(itemstack, player)
                local pmeta = player:get_meta()
                
                if pmeta:get("murder:canShoot") == nil or pmeta:get_int("murder:canShoot") == 1 then
                    local pl_pos = player:get_pos()
                    local pos_head = {x = pl_pos.x, y = pl_pos.y+1.5, z = pl_pos.z}  
                    local shoot_range = 50
                    local shoot_dir = vector.multiply(player:get_look_dir(), shoot_range)
                    -- Casts a ray from the player head position 'till the same position * shoot_range
                    local ray = minetest.raycast(vector.add(pos_head, vector.divide(player:get_look_dir(), 4)), vector.add(pos_head, shoot_dir), true, false)
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
                            local pl_name = player:get_player_name()

                            if hit.ref:get_hp() <= 0 then break end
                            
                            hit.ref:set_hp(0, "shot")

                            -- Kills the cop if it shoots a victim
                            if arena_lib.is_player_in_arena(hit_name) and arena_lib.is_player_in_arena(pl_name) then
                                local arena = arena_lib.get_arena_by_player(hit_name)
                                if arena.murderer ~= hit_name then
                                    minetest.chat_send_player(pl_name, murder.T("You killed a victim!"))
                                    player:set_hp(0)
                                end
                            end

                            break
                        end
                    end

                    minetest.sound_play("murder_gun_shoot", { max_hear_distance = 10, gain = 0.5 })
                    pmeta:set_int("murder:canShoot", 0)
                    minetest.after(1, function() pmeta:set_int("murder:canShoot", 1) end)
                else 
                    minetest.sound_play("murder_empty_gun", { max_hear_distance = 5, gain = 0.5 })
                end
                return nil
            end
    })

    -- The radar used by the victim
    minetest.register_craftitem("murder:radar_on", { 
        description = murder.T("Left click to detect if the killer is within 15 blocks from you!"),
        inventory_image = "radar_on.png",
        stack_max = 1,
        on_use = 
            function(itemstack, player)
                local pl_name = player:get_player_name()

                if arena_lib.is_player_in_arena(pl_name) then
                    local arena = arena_lib.get_arena_by_player(pl_name)

                    for p_name, _ in pairs(arena.players) do
                        if vector.distance(player:get_pos(), minetest.get_player_by_name(p_name):get_pos()) <= 15 and arena.murderer == p_name then
                            minetest.chat_send_player(pl_name, murder.T("The killer is nearby!"))
                            break
                        else
                            minetest.chat_send_player(pl_name, murder.T("The killer is not nearby!"))
                            break
                        end
                    end
                end

                player:get_inventory():add_item("main", "murder:radar_off")
                minetest.after(10,
                    function() 
                        player:get_inventory():add_item("main", "murder:radar_on") 
                        player:get_inventory():remove_item("main", "murder:radar_off")
                    end)
                minetest.after(0, function() player:get_inventory():remove_item("main", "murder:radar_on") end)
            end,
        on_drop = function() end
    })

    minetest.register_craftitem("murder:radar_off", { 
        description = murder.T("Left click to detect if the killer is within 15 blocks from you!"),
        inventory_image = "radar_off.png",
        stack_max = 1,
        on_use = function(itemstack, player) minetest.chat_send_player(player:get_player_name(), murder.T("The radar is recharging!")) end,
        on_drop = function() end
    })
end

register_items()
