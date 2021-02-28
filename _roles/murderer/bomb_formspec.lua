minetest.register_on_player_receive_fields(function(player, formname, fields)
    if not formname:find("murder:formspec_bomb/") or not fields.btn_stop then return end

    local code = formname:gsub("murder:formspec_bomb/", "")

    if fields.field_code_input ~= code then return end

    local pl_name = player:get_player_name()
    local arena = arena_lib.get_arena_by_player(pl_name)

    arena.emergency_data.murderer.bomb_detonated = false
    murder.remove_bomb(arena)
    
    minetest.close_formspec(pl_name, formname)
end)