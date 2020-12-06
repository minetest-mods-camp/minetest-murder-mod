-- The throwable knife entity declaration.
local throwable_knife = {
    initial_properties = {
        hp_max = 999,
        physical = true,
        collide_with_objects = false,
        collisionbox = {-0.15, -0.15, -0.15, 0.15, 0.15, 0.15},
        visual = "wielditem",
        visual_size = {x = 0.4, y = 0.4},
        textures = {"murder:knife"},
        spritediv = {x = 1, y = 1},
        initial_sprite_basepos = {x = 0, y = 0},
        speed = 32,
        gravity = 11,
    },
    pl_name = "",
    dropped = false,
    hit_box_range = 1
}


-- staticdata = player's username
function throwable_knife:on_activate(staticdata, dtime_s)
    local obj = self.object

    if staticdata then
        self.pl_name = staticdata
        local player = minetest.get_player_by_name(self.pl_name)
        if not player then 
            obj:remove() 
            return
        end
        local yaw = player:get_look_horizontal()
        local pitch = player:get_look_vertical()
        local dir = player:get_look_dir()
        local arena = arena_lib.get_arena_by_player(self.pl_name)
        local knife_props = self.initial_properties
        local murderer_props = arena.roles[self.pl_name].properties
        local knife_id = murderer_props.thrown_knives_count + 1
        local match_id = arena.match_id 
        murderer_props.thrown_knives_count = knife_id

        obj:set_rotation({x = -pitch, y = yaw+55, z = 0})
        obj:set_velocity({
            x=(dir.x * knife_props.speed),
            y=(dir.y * knife_props.speed),
            z=(dir.z * knife_props.speed),
        })
        obj:set_acceleration({x = dir.x * -3, y = -knife_props.gravity, z = dir.z * -3})

        minetest.after(15, function()
            local player = minetest.get_player_by_name(self.pl_name)
            local arena = arena_lib.get_arena_by_player(self.pl_name)
            if not murder.is_player_playing(self.pl_name) then return end
            if match_id ~= arena.match_id then return end
            if not murderer_props.thrown_knife then return end
            if knife_id ~= murderer_props.thrown_knives_count then return end
            local pl_inv = player:get_inventory()

            murderer_props.remove_knife(arena, self.pl_name)
            pl_inv:add_item("main", ItemStack("murder:knife"))
        end)
    else
        obj:remove()
    end
end


function throwable_knife:drop()
    local obj = self.object
    local obj_pos = obj:get_pos()

    self.dropped = true
    obj:set_velocity({x=0, y=0, z=0})
    obj:set_acceleration({x=0, y=0, z=0})

    minetest.after(0, function()
        obj:set_pos(obj_pos)
    end)

    minetest.sound_play("knife_hit_block", { max_hear_distance = 10, pos = obj_pos })
end



function throwable_knife:on_rightclick(clicker)
    local pl_name = clicker:get_player_name()
    local arena = arena_lib.get_arena_by_player(pl_name)

    if murder.is_player_playing(pl_name) and pl_name == self.pl_name and self.dropped then
        local murderer_props = arena.roles[pl_name].properties

        minetest.get_player_by_name(pl_name):get_inventory():add_item("main", "murder:knife")
        murderer_props.remove_knife(arena, pl_name)
    end
end



function throwable_knife:on_step(dtime, moveresult)
    local player = minetest.get_player_by_name(self.pl_name)
    if not player or not murder.is_player_playing(self.pl_name) then
        self.object:remove()
        return
    end
    local arena = arena_lib.get_arena_by_player(self.pl_name)
    local nearest_player, distance = murder.get_nearest_player(arena, self.object:get_pos(), self.pl_name)

    if distance and distance <= self.hit_box_range then 
        local hit_pl_name = nearest_player:get_player_name()
        local hit_pl_pos = nearest_player:get_pos()

        murder.kill_player(self.pl_name, hit_pl_name) 
        minetest.sound_play("murder_knife_hit", {pos = hit_pl_pos, to_player = hit_pl_name})
        minetest.sound_play("murder_knife_hit", {max_hear_distance = 10, pos = hit_pl_pos})
    end

    if moveresult.collides == true then
      for _, collision in pairs(moveresult.collisions) do
        if collision.type == "node" then
          -- If it hit a block and it hasn't dropped yet
          if self.dropped == false then
              self:drop()
              return
          end
        end
      end
    end

end



minetest.register_entity("murder:throwable_knife", throwable_knife)
