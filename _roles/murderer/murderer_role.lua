murder.register_role("Murderer", {
    name = "Murderer",
    hotbar_description = "Kill everyone!",
    items = {"murder:knife", "murder:blinder", "murder:skin_shuffler", "murder:finder_chip"},
    sound = "murderer-role",
    properties = {
        kill_delay = 8,
        can_kill = true,
        thrown_knife = nil,
        thrown_knives_count = 0,
        remove_knife = function(arena, pl_name)
            local pl_role = arena.roles[pl_name]

            arena.roles[pl_name].properties.thrown_knife:remove()
            arena.roles[pl_name].properties.thrown_knife = nil
        end
    },
    physics_override = {speed = 1.3}
})



dofile(minetest.get_modpath("murder") .. "/_roles/murderer/murderer_items.lua")
dofile(minetest.get_modpath("murder") .. "/_roles/murderer/throwable_knife.lua")