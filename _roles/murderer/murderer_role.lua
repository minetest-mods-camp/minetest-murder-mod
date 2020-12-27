murder.register_role("Murderer", {
    name = "Murderer",
    hotbar_description = "Kill everyone!",
    items = {"murder:knife", "murder:blinder", "murder:skin_shuffler", "murder:locator"},
    sound = "murderer-role",
    kill_delay = 15,
    can_kill = true,
    physics_override = {speed = 1.3},
    thrown_knife = nil,
    thrown_knives_count = 0,
    remove_knife = function(self)
        self.thrown_knife:remove()
        self.thrown_knife = nil
    end,
})



dofile(minetest.get_modpath("murder") .. "/_roles/murderer/murderer_items.lua")
dofile(minetest.get_modpath("murder") .. "/_roles/murderer/throwable_knife.lua")