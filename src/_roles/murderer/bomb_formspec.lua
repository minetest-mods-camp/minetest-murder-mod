minetest.register_on_player_receive_fields(function(player, formname, fields)
    if not formname:find("murder:formspec_bomb/") or (not fields.btn_stop and not fields.key_enter) then
        return 
    end

    local code = formname:gsub("murder:formspec_bomb/", "")
    local pl_name = player:get_player_name()
    local arena = arena_lib.get_arena_by_player(pl_name)

    if not arena or not arena.in_game then 
        minetest.close_formspec(pl_name, formname)
        return 
    end

    if fields.field_code_input ~= code then
        murder.print_error(pl_name, murder.T("Wrong code"))
        return
    end

    arena.emergency_data.murderer.bomb_detonated = false
    murder.remove_bomb(arena)
    
    minetest.close_formspec(pl_name, formname)
end)