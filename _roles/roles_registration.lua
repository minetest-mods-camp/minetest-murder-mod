--[[
    Explanations:
    When the code refers to the player'S role it means the role table 
    associated to him/her in the arena.roles[pl_name] arena property.

    The definition table to put in register_role() is the following:
    {
        name : string =
            the role name.

        hotbar_description : string =
            a short description explaining its purpose, it will be
            showed in the hotbar.

        items : { “name” or {name : string, count : number}, ...} =
            the items that he/she will receive when the match starts.

        default_role : bool = 
            if true each player that hasn't got a non-default role
            yet will become this role.

        sound : string =
            the sound that will be reproduced to the player when this role
            will be assigned to him/her.

        on_start : function(arena, pl_name) = 
            this gets called when this role gets assigned to pl_name
            (pl_name always refers to the player this role is assigned to).

        on_end : function(arena, pl_name) =
            this gets called when this match finishes (on_celebration).

        on_eliminated : function(arena, pl_name) =
            this gets called when the player gets eliminated by 
            murder.eliminate(pl_name) or when disconnecting.
        
        on_death : function(arena, pl_name, reason) =
            this gets called when the player dies.

        on_kill : function(arena, pl_name, killed_pl_name) =
            this gets called one step after the player kills someone.

        properties : {} = 
            custom properties.
    }
]]





local function get_valid_role() end
local function set_callbacks() end
local function set_physics() end
murder.roles = {}  -- index = role


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

    role.on_start = function(arena, pl_name)
        murder.log(arena, pl_name.." called on start")
        local player = minetest.get_player_by_name(pl_name)
        arena.roles[pl_name].in_game = true

        murder.generate_HUD(arena, pl_name)
        -- Disable wielding items if there is 3d_armor installed.
        player:get_meta():set_int("show_wielded_item", 2)
        
        on_start(arena, pl_name)
    end

    role.on_kill = function(arena, pl_name, killed_pl_name)
        murder.log(arena, pl_name .. " called on kill")
        on_kill(arena, pl_name, killed_pl_name)
    end

    role.on_death = function(arena, pl_name, reason)
        murder.log(arena, pl_name.." called on death ")

        -- If the player was killed using murder.kill_player().
        if reason and reason.type == "punch" then
            local killer_name = reason.object:get_player_name()
            local killer_role = arena.roles[killer_name]

            murder.print_msg(pl_name, murder.T("@1 (@2) killed you!", killer_name, murder.T(killer_role.name)))
            minetest.after(0, function() killer_role.on_kill(arena, killer_name, pl_name) end)
        end

        on_death(arena, pl_name, reason)
        murder.eliminate_role(pl_name)
    end

    role.on_eliminated = function(arena, pl_name)
        murder.log(arena, pl_name.." called on eliminated ")

        arena.roles[pl_name].in_game = false
        murder.prekick_operations(pl_name)
        arena_lib.remove_player_from_arena(pl_name, 1)

        local last_role = murder.get_last_role_in_game(arena)
        local remaining_players = murder.count_players_in_game(arena)

        if last_role then murder.log(arena, "Last role is " .. last_role.name .. " with count " .. remaining_players) 
        else murder.log(arena, "Two or more different roles are in game, count players alive: " .. remaining_players) end

        -- If the remaining players have all the same role the team wins.
        if last_role and remaining_players > 1 then
            murder.log(arena, "Team " .. last_role.name .. " wins")
            murder.team_wins(arena, last_role)
        elseif last_role then
            local last_pl_name 
            
            -- Searching the last player in game knowing his/her role.
            for pl_name, role in pairs(arena.roles) do
                if role.in_game and role.name == last_role.name then
                    last_pl_name = pl_name 
                    break
                end
            end

            murder.player_wins(last_pl_name)
            murder.log(arena, "Player " .. last_pl_name .. " wins")
        end

        on_eliminated(arena, pl_name)
    end

    role.on_end = function(arena, pl_name)
        murder.log(arena, pl_name .. " called on end")
        murder.prekick_operations(pl_name)
        on_end(arena, pl_name)
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