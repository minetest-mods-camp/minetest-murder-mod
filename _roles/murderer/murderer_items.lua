minetest.register_craftitem("murder:knife", {
    description = murder.T(
        "With this you can kill other players, seems fun, doesn't it?\nRight click in the air to throw it, then right click it again to take it back\n(@1s cooldown)", 
        murder.get_role_by_name("Murderer").kill_delay
    ),
    inventory_image = "item_murder_knife.png",
    damage_groups = {fleshy = 3},
    stack_max = 1,
    on_drop = function() return end,
    on_use =
        function(_, player, pointed_thing)
            local pl_name = player:get_player_name()
            if not murder.is_player_playing(pl_name) then return end
            local arena = arena_lib.get_arena_by_player(pl_name)
            local murderer = arena.roles[pl_name]
            local kill_delay = murderer.kill_delay
            
            if not murderer.can_kill then
                murder.print_msg(pl_name, murder.T("You have to wait @1s to use again the knife!", kill_delay))
                return
            end

            -- If it's used on a player than kill him/her.
            if pointed_thing.type == "object" and pointed_thing.ref:is_player() then
                local hit_pl = pointed_thing.ref
                local hit_pl_name = hit_pl:get_player_name()
                local image_kills_disabled = {
                    hud_elem_type = "image",
                    position = {x=0.5, y=0.7},
                    scale = {x=5, y=5},
                    text = "HUD_kills_disabled.png",
                    z_index = -100
                }

                minetest.sound_play("murder_knife_hit", {max_hear_distance = 10, pos = player:get_pos()})
                minetest.sound_play("murder_knife_hit", {pos = hit_pl:get_pos(), to_player = hit_pl_name})

                murder.kill_player(pl_name, hit_pl_name) 
                murder.add_temp_hud(pl_name, image_kills_disabled, murderer.kill_delay)

                murderer.can_kill = false
                minetest.after(murderer.kill_delay, function() murderer.can_kill = true end)
            end
        end,
    on_secondary_use =
        function(_, player, pointed_thing)
            local pl_name = player:get_player_name()
            if not murder.is_player_playing(pl_name) then return end
            local arena = arena_lib.get_arena_by_player(pl_name)
            local murderer = arena.roles[pl_name]
            local throw_starting_pos = vector.add({x=0, y=1.5, z=0}, player:get_pos())

            if not murderer.can_kill then
                local kill_delay = murderer.kill_delay
                murder.print_msg(pl_name, murder.T("You have to wait @1s to use again the knife!", kill_delay))
                return
            end

            local knife = minetest.add_entity(throw_starting_pos, "murder:throwable_knife", pl_name)

            murderer.thrown_knife = knife
            minetest.after(0, function() player:get_inventory():remove_item("main", "murder:knife") end)

            minetest.sound_play("throw_knife", {max_hear_distance = 5, pos = player:get_pos()})
        end
})



minetest.register_craftitem("murder:locator", {
    description = murder.T("Left click to show the nearest player's last position!"),
    inventory_image = "item_locator.png",
    stack_max = 1,
    on_drop = function() return nil end,
    on_use =
        function(_, player, pointed_thing)
            local pl_name = player:get_player_name()
            if not murder.is_player_playing(pl_name) then return end
            local arena = arena_lib.get_arena_by_player(pl_name)
            local nearest_player = murder.get_nearest_player(arena, player:get_pos(), pl_name)
            local nearest_pl_pos = nearest_player:get_pos()
            local target_waypoint = {
                hud_elem_type = "image_waypoint",
                world_pos = {x = nearest_pl_pos.x, y = nearest_pl_pos.y + 1, z = nearest_pl_pos.z},
                text      = "item_locator.png",
                scale     = {x = 5, y = 5},
                number    = 0xdf3e23,
                size = {x = 200, y = 200},
            }

            murder.add_temp_hud(pl_name, target_waypoint, 10)
            minetest.after(0, function() player:get_inventory():remove_item("main", "murder:locator") end)
            
            minetest.sound_play("finder-chip", { pos = player:get_pos(), to_player = pl_name })
        end
})



minetest.register_craftitem("murder:blinder", {
    description = murder.T("Blinds everyone for @1s!", 3),
    inventory_image = "item_blinder.png",
    stack_max = 1,
    on_drop = function() return nil end,
    on_use =
        function(_, player, pointed_thing)
            local pl_name = player:get_player_name()
            if not murder.is_player_playing(pl_name) then return end
            local arena = arena_lib.get_arena_by_player(pl_name)
            local pl_inv = player:get_inventory()

            -- Blinding all players in arena but the murderer.
            for pl_to_blind_name, _ in pairs(arena.players) do
                local player_to_blind = minetest.get_player_by_name(pl_to_blind_name)

                if arena.roles[pl_to_blind_name].name == "Murderer" then goto continue end
                
                local black_screen = {
                    hud_elem_type = "image",
                    position = {x=0.5, y=0.5},
                    scale = {x=-100, y=-100},
                    text = "HUD_blind.png",
                    z_index = -100
                }
                local image_eye = {
                    hud_elem_type = "image",
                    position = {x=0.5, y=0.5},
                    scale = {x=4, y=4},
                    text = "HUD_eye.png",
                    z_index = -100
                }

                murder.add_temp_hud(pl_to_blind_name, black_screen, 3)
                murder.add_temp_hud(pl_to_blind_name, image_eye, 3)

                minetest.sound_play("blinder", { pos = player_to_blind:get_pos(), to_player = pl_to_blind_name})

                ::continue::
            end
            
            minetest.sound_play("murder_blinder", { pos = player:get_pos(), to_player = pl_name})
            minetest.after(0, function() pl_inv:remove_item("main", "murder:blinder") end)
        end
})



minetest.register_craftitem("murder:skin_shuffler", {
    description = murder.T("Shuffles all players skins!"),
    inventory_image = "item_skin_shuffler.png",
    stack_max = 1,
    on_drop = function() return nil end,
    on_use =
        function(_, player, pointed_thing)
            local pl_name = player:get_player_name()
            if not murder.is_player_playing(pl_name) then return end
            local arena = arena_lib.get_arena_by_player(pl_name)
            local pl_inv = player:get_inventory()

            murder.assign_skins(arena)
            minetest.after(0, function() pl_inv:remove_item("main", "murder:skin_shuffler") end)
            minetest.sound_play("skin-shuffler", {pos = player:get_pos(), to_player = pl_name})
        end
})
