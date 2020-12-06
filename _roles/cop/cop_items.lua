minetest.register_craftitem("murder:gun", {
    description = murder.T("Shoot and kill!"),
    inventory_image = "gun.png",
    stack_max = 1,
    on_drop = function() return end,
    on_use =
        function(itemstack, player)
            local pl_name = player:get_player_name()
            if not murder.is_player_playing(pl_name) then return end
            local arena = arena_lib.get_arena_by_player(pl_name)
            local cop_props = arena.roles[pl_name].properties
            local reload_delay = 2

            if cop_props.can_shoot then
                local ray, pos_head, shoot_dir = murder.look_raycast(player, 30)
                local particle_shot = {
                    pos = pos_head,
                    velocity = vector.multiply(shoot_dir, 2),
                    size = 1,
                    texture = "shoot_particle.png",
                    glow = 12,
                    playername = pl_name
                }

                minetest.add_particle(particle_shot)

                for hit_object in ray do
                    if hit_object.type == "object" and hit_object.ref:is_player() then
                        hit_object = hit_object.ref
                        local hit_name = hit_object:get_player_name()

                        if hit_object:get_hp() <= 0 then break
                        elseif not murder.is_player_playing(hit_name) then break end

                        if hit_name ~= pl_name then 
                            murder.kill_player(pl_name, hit_name) 
                            break
                        end
                    end
                end

                minetest.sound_play("murder_gun_shoot", {gain = 1, pos = player:get_pos(), to_player = pl_name})
                
                cop_props.can_shoot = false
                minetest.after(reload_delay, function() cop_props.can_shoot = true end)
            else
                minetest.sound_play("murder_empty_gun", {gain = 1 , pos = player:get_pos(), to_player = pl_name})
            end
            return nil
        end
})