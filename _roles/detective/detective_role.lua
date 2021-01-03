dofile(minetest.get_modpath("murder") .. "/_roles/detective/detective_items.lua")



murder.register_role("Detective", {
    default = true,
    name = "Detective",
    hotbar_description = "Kill the murderer, if you kill another detective you'll die",
    items = {"murder:gun"}, 
    sound = "detective-role",
    on_kill = function(self, arena, pl_name, killed_pl_name)
        local killed_role = arena.roles[killed_pl_name]

        -- If the player killed another detective.
        if killed_role.name == self.name then
            local player_inv = minetest.get_player_by_name(pl_name):get_inventory()

            murder.print_msg(pl_name, murder.T("You killed another detective (@1)!", killed_pl_name))
            murder.eliminate_role(pl_name)
            minetest.after(0, function() player_inv:remove_item("main", "murder:gun") end)
        elseif killed_role.name == "Murderer" then     
            if murder.count_players_in_game(arena) == 1 then return end

            arena_lib.send_message_players_in_arena(
                arena,
                murder_settings.prefix .. 
                murder.T(
                    "@1 (@2) killed @3 (@4)!", 
                    pl_name, murder.T(self.name), killed_pl_name, murder.T(killed_role.name)
                )
            )
        end
    end,
    on_death = function(self, arena, pl_name, reason)
        if reason and reason.type == "punch" then
            local killer_name = reason.object:get_player_name()
            local killer_role = arena.roles[killer_name]
            local pl_pos = minetest.get_player_by_name(pl_name):get_pos()

            -- Adding a 4s lasting waypoint to the death place if the player's
            -- been killed by another role.
            if killer_role.name ~= self.name then
                for other_pl_name, _ in pairs(arena.players) do
                    local death_waypoint = {
                        hud_elem_type = "image_waypoint",
                        world_pos = {x = pl_pos.x, y = pl_pos.y + 1, z = pl_pos.z},
                        text      = "HUD_murder_player_killed.png",
                        scale     = {x = 5, y = 5},
                        size = {x = 200, y = 200},
                    }
                    
                    murder.add_temp_hud(other_pl_name, death_waypoint, 4)
                end
            end
        end
    end,
    can_shoot = true
})