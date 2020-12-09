murder.register_role("Cop", {
    default = true,
    name = "Cop",
    hotbar_description = "Kill the murderer, but if you kill another cop you'll die!",
    items = {"murder:gun"}, 
    sound = "cop-role",
    on_kill = function(arena, pl_name, killed_pl_name)
        local killed_role = arena.roles[killed_pl_name]

        if killed_role.name == "Cop" then
            if not murder.is_player_playing(pl_name) then return end
            murder.print_msg(pl_name, murder.T("You killed another cop (@1)!", killed_pl_name))
            murder.eliminate_role(pl_name)
        end
    end,
    on_death = function(arena, pl_name, reason)
        if reason and reason.type == "punch" then
            local killer_name = reason.object:get_player_name()
            local killer_role = arena.roles[killer_name]
            local pl_pos = minetest.get_player_by_name(pl_name):get_pos()

            if killer_role.name ~= "Cop" then
                for other_pl_name, _ in pairs(arena.players) do
                    local death_waypoint = {
                        hud_elem_type = "image_waypoint",
                        world_pos = {x = pl_pos.x, y = pl_pos.y + 1, z = pl_pos.z},
                        text      = "murder_player_killed.png",
                        scale     = {x = 5, y = 5},
                        number    = 0xdf3e23,
                        size = {x = 200, y = 200},
                    }
                    murder.add_temp_hud(other_pl_name, death_waypoint, 4)
                end
            end
        end
    end,
    properties = {
        can_shoot = true
    }
})



dofile(minetest.get_modpath("murder") .. "/_roles/cop/cop_items.lua")
