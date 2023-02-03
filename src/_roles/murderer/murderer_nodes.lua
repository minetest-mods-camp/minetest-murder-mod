minetest.register_node("murder:bomb", {
    description = "Bomb",
    groups = {crumbly=1},
    tiles = {
        "node_murder_bomb_side.png",
        "node_murder_bomb_side.png",  
        "node_murder_bomb_side.png",
        "node_murder_bomb_side.png",
        "node_murder_bomb_side.png", 
        "node_murder_bomb_front.png" 
    },
    paramtype2 = "facedir",
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local pl_name = clicker:get_player_name()
        local arena = arena_lib.get_arena_by_player(pl_name)
        local node_id = tonumber(minetest.get_meta(pos):get_string("match_id"))
        local random_code = math.random(100000, 999999)
        local formspec =
            "formspec_version[3]" ..
            "size[11,11]" ..
            "image[0,0;11,11;HUD_murder_bomb_background.png]" ..
            "field[1.5,4.5;8,1.3;field_code_input;" .. murder.T("Insert the code to deactivate the bomb") .. ";]" ..
            "image[1.5,1.5;8,2;HUD_murder_bomb_display.png]" ..
            "hypertext[1.5,1.4;8,2;lbl_code;<global valign=middle> <center><style color=#cd6093 size=32>"..random_code.."</style></center>]" ..
            "image_button[4,7;3,3;HUD_murder_bomb_button.png;btn_stop;;false;false;HUD_murder_bomb_button_pressed.png]"
        
        if (not murder.is_player_playing(pl_name)) or node_id ~= arena.match_id then
            minetest.set_node(pos, {name = "air"})
            return
        end

        minetest.show_formspec(clicker:get_player_name(), "murder:formspec_bomb/"..random_code, formspec)
    end
})