local function get_valid_role() end
local function set_callbacks() end
local function set_physics() end
murder.roles = {}  -- id = role


function murder.register_role(name, def)
    def = get_valid_role(name, def)
    murder.roles[#murder.roles+1] = def
end



function murder.get_default_role()
    for i, role in pairs(murder.roles) do
        if role.default then return role end
    end
end



function murder.get_role_by_name(name)
    for i, role in pairs(murder.roles) do
        if role.name:lower() == name:lower() then return role end
    end
end



function get_valid_role(name, role)
    role.default = role.default or false
    set_physics(role)
    set_callbacks(role)

    assert(
        role.name or role.hotbar_description or role.items or
        v.sound, 
        "A role hasn't been configured correctly ("..name..")!"
    )
    assert(
        not murder.get_role_by_name(role.name), 
        "Two roles have the same name ("..name..")!"
    )
    assert(
        not (murder.get_default_role() and role.default), 
        "There is more than 1 default role!"
    )

    return role
end



function set_callbacks(role)
    local empty_func = function() end
    local on_death = role.on_death or empty_func
    local on_end = role.on_end or empty_func
    local on_eliminated = role.on_eliminated or empty_func
    local on_start = role.on_start or empty_func
    local on_kill = role.on_kill or empty_func

    role.on_death = function(arena, pl_name, reason)
        if reason and reason.type == "punch" then
            local killer_name = reason.object:get_player_name()
            local killer_role = arena.roles[killer_name]

            murder.print_msg(pl_name, murder.T("@1 (@2) killed you!", killer_name, murder.T(killer_role.name)))
            minetest.after(0, function() killer_role.on_kill(arena, killer_name, pl_name) end)
        end

        on_death(arena, pl_name, reason)
        murder.eliminate_role(pl_name)
    end

    role.on_end = function(arena, pl_name)
        local player = minetest.get_player_by_name(pl_name)
        murder.restore_skin(pl_name)

        player:get_inventory():set_list("main", {})
        player:get_inventory():set_list("craft", {})
        on_end(arena, pl_name)
    end

    role.on_eliminated = function(arena, pl_name)
        local last_role = murder.get_last_role_in_game(arena)
        local roles_alive = murder.get_roles_alive(arena)

        if last_role and roles_alive > 1 then
            murder.team_wins(arena, last_role)
        elseif last_role then
            local last_pl_name 
            
            for pl_name, _ in pairs(arena.players) do
                local pl_role = arena.roles[pl_name]

                if pl_role.in_game and pl_role.name == last_role.name then
                    last_pl_name = pl_name 
                    break
                end
            end
            murder.player_wins(last_pl_name)
        end

        murder.restore_skin(pl_name)
        on_eliminated(arena, pl_name, disconnected)
    end

    role.on_start = function(arena, pl_name)
        arena.roles[pl_name].in_game = true
        on_start(arena, pl_name)
    end

    role.on_kill = function(arena, pl_name, killed_pl_name)
        on_kill(arena, pl_name, killed_pl_name)
    end
end



function set_physics(role)
    local phys = role.physics_override or {}
    local speed = phys.speed or 1.2
    local gravity = phys.gravity or 1
    local acceleration = phys.acceleration or 1
    local jump = phys.jump or 1
    local sneak = phys.sneak or true
    local sneak_glitch = phys.sneak_glitch or false
    local new_move = phys.new_move or true

    phys = {
        speed = speed, 
        gravity = gravity, 
        acceleration = acceleration, 
        jump = jump,
        sneak = sneak,
        sneak_glitch = sneak_glitch,
        new_move = new_move
    }

    role.physics_override = phys
end