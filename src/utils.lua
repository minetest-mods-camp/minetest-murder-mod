function murder.print_msg(pl_name, msg)
    minetest.chat_send_player(pl_name, murder_settings.prefix .. msg)
end



function murder.print_error(pl_name, msg)
    minetest.chat_send_player(pl_name, minetest.colorize("#e6482e", murder_settings.prefix .. msg))
    minetest.sound_play("murder-error", {to_player = pl_name})
end



function murder.look_raycast(object, range)
    local pos = {}
    local looking_dir = 0
    local shoot_dir = 0

    -- Assigning the correct values to pos and looking_dir, based on
    -- if the object is a player or not.
    if object:is_player() then
        local pl_pos = object:get_pos()
        local head_pos = {x = pl_pos.x, y = pl_pos.y+1.5, z = pl_pos.z}
        pos = head_pos
        looking_dir = object:get_look_dir()
    else
        pos = object:get_pos()
        looking_dir = vector.normalize(object:get_velocity())
    end
    
    shoot_dir = vector.multiply(looking_dir, range)

    -- Casts a ray from pos to the object looking direction * range.
    local ray = minetest.raycast(
        vector.add(pos, vector.divide(looking_dir, 4)), 
        vector.add(pos, shoot_dir), 
        true, 
        false
    )

    return ray, pos, shoot_dir
end