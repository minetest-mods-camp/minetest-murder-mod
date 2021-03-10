minetest.register_craftitem("murder:gun", {
    description = murder.T("Shoot and kill!"),
    inventory_image = "item_murder_gun.png",
    stack_max = 1,
    on_drop = function() return end,
    on_use =
        function(itemstack, player)
            local pl_name = player:get_player_name()
            if not murder.is_player_playing(pl_name) then return end
            local arena = arena_lib.get_arena_by_player(pl_name)
            local detective = arena.roles[pl_name]
            local reload_delay = 2

            if detective.can_shoot then
                local ray, pos_head, shoot_dir = murder.look_raycast(player, 100)
                local particle_shot = {
                    pos = pos_head,
                    velocity = vector.multiply(shoot_dir, 2),
                    size = 1,
                    texture = "particle_murder_shoot.png",
                    glow = 12,
                    playername = pl_name
                }

                minetest.add_particle(particle_shot)

                -- Shooting using the look_raycast() ray, if it hits a player he/she gets killed.
                for hit_object in ray do
                    if hit_object.type == "object" and hit_object.ref:is_player() then
                        hit_object = hit_object.ref
                        local hit_name = hit_object:get_player_name()

                        if hit_object:get_hp() <= 0 then break
                        elseif not murder.is_player_playing(hit_name) then break end

                        if hit_name ~= pl_name then
                            murder.log(arena, pl_name .. " is shooting " .. hit_name)
                            murder.kill_player(pl_name, hit_name)
                            minetest.sound_play("murder_gun_shoot", {to_player = hit_name})
                            break
                        end
                    end
                end

                minetest.sound_play("murder_gun_shoot", {to_player = pl_name})

                detective.can_shoot = false
                minetest.after(reload_delay, function() detective.can_shoot = true end)
            else
                minetest.sound_play("murder_empty_gun", {to_player = pl_name})
            end
            return nil
        end
})
