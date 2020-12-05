murder.register_role("Cop", {
    default = true,
    name = "Cop",
    hotbar_description = "Kill the murderer, but beware if you kill a victim you'll die!",
    items = {"murder:gun"}, 
    sound = "cop-role",
    on_kill = function(arena, pl_name, killed_pl_name)
        local killed_role = arena.roles[killed_pl_name]

        if killed_role.name == "Cop" then
            murder.print_msg(pl_name, murder.T("You killed another cop (@1)!", killed_pl_name))
            murder.eliminate_role(pl_name)
        end
    end,
    properties = {
        can_shoot = true
    }
})



dofile(minetest.get_modpath("murder") .. "/_roles/cop/cop_items.lua")
