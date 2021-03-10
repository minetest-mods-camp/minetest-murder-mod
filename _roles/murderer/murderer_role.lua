murder.register_role("Murderer", {
    name = "Murderer",
    hotbar_description = "Kill everyone!",
    items = {
        "murder:knife",
        "murder:blinder",
        {name = "murder:bomb_placer", required_players_amount = 4},
        {name = "murder:locator", required_players_amount = 4},
        {name = "murder:skin_shuffler", required_players_amount = 5}
    },
    sound = "murderer-role",
    physics_override = {speed = 1.3},
    HUD_timer = "HUD_murder_murderer_timer.png",
    vignette = "HUD_murder_murderer_vignette.png",
    can_kill = true,
    kill_delay = 15,
    thrown_knife = nil,
    thrown_knives_count = 0,
    bomb_pos = nil,
    bomb_detonation_time = 30,
    bomb_detonated = false,
    remove_knife = function(self)
        self.thrown_knife:remove()
        self.thrown_knife = nil
    end,
    kill_player = function(self, pl_name, hit_pl_name)
        local player = minetest.get_player_by_name(pl_name)
        local image_kills_disabled = {
            hud_elem_type = "image",
            position = {x=0.5, y=0.7},
            scale = {x=5, y=5},
            text = "HUD_murder_kills_disabled.png",
            z_index = -100
        }

        if not self.can_kill then
            murder.print_error(pl_name, murder.T("You have to wait for @1s to use the knife again", self.kill_delay))
            return false
        end

        murder.kill_player(pl_name, hit_pl_name) 
        murder.add_temp_hud(pl_name, image_kills_disabled, self.kill_delay)

        minetest.sound_play("murder_knife_hit", {max_hear_distance = 10, pos = player:get_pos()})
        minetest.sound_play("murder_knife_hit", {to_player = hit_pl_name})

        self.can_kill = false
        minetest.after(self.kill_delay, function() self.can_kill = true end)

        return true
    end,
    throw_knife = function(self, pl_name)
        if not self.can_kill then
            murder.print_error(pl_name, murder.T("You have to wait @1s to use again the knife!", self.kill_delay))
            return false
        end

        local player = minetest.get_player_by_name(pl_name)
        local throw_starting_pos = vector.add({x=0, y=1.5, z=0}, player:get_pos())
        local knife = minetest.add_entity(throw_starting_pos, "murder:throwable_knife", pl_name)
        self.thrown_knife = knife

        minetest.after(0, function() player:get_inventory():remove_item("main", "murder:knife") end)

        minetest.sound_play("throw_knife", {max_hear_distance = 5, pos = player:get_pos()})

        return true
    end,
    on_end = function(self, arena, pl_name)
        murder.remove_bomb(arena)
    end
})



dofile(minetest.get_modpath("murder") .. "/_roles/murderer/bomb_utils.lua")
dofile(minetest.get_modpath("murder") .. "/_roles/murderer/bomb_formspec.lua")
dofile(minetest.get_modpath("murder") .. "/_roles/murderer/murderer_nodes.lua")
dofile(minetest.get_modpath("murder") .. "/_roles/murderer/murderer_items.lua")
dofile(minetest.get_modpath("murder") .. "/_roles/murderer/throwable_knife.lua")
