--[[
    When the code refers to the player'S role it means the role table 
    associated to him/her in the arena.roles[pl_name] property.

    The definition table to put in register_role() is the following:
    {
        name : string =
            the role name, it is automatically translated in chat
            messages.

        hotbar_description : string =
            a short description explaining its purpose, it will be
            showed in the hotbar and automatically translated
            in chat messages.

        items : { "name" or {name : string, required_players_amount : number}, ...} =
            the items that the player will receive when the match starts.
            required_players_amount means the required amount of players in the match 
            to use that item; if it is specified, make sure to create a disabled version
            of that item using murder.generate_disabled_item(itemstack).

        default_role : bool = 
            if true each player that hasn't got a non-default role
            yet, will become this one.

        HUD_timer : string =
            a custom texture for the timer HUD.

        vignette : string =
            a custom vignette texture.

        sound : string =
            the sound that will be reproduced to the player when this role 
            gets assigned to him/her.

        on_start : function(self, arena, pl_name) = 
            this gets called when this role gets assigned to pl_name. self
            is the role table assigned to the player while pl_name is his/her
            name.

        on_end : function(self, arena, pl_name) =
            this gets called when the match finishes (on_celebration).

        on_eliminated : function(self, arena, pl_name) =
            this gets called when the player gets eliminated by 
            murder.eliminate(pl_name) or when disconnecting.
        
        on_death : function(self, arena, pl_name, reason) =
            this gets called when the player dies.

        on_kill : function(self, arena, pl_name, killed_pl_name) =
            this gets called when the player kills someone.

        ... other functions or custom properties, just make sure
        that their names don't conflict with the already existing
        ones.
    }
]]





local function get_valid_role() end
local function set_callbacks() end
local function set_physics() end
murder.roles = {}  -- index : number = role : {}



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



function murder.generate_disabled_item(itemstack)
    local item_name = itemstack:get_name()
    local definition = itemstack:get_definition()
    local needed_players

    minetest.register_craftitem(item_name .. "_disabled", {
        description = definition.description,
        groups = {murder=1},
        inventory_image = definition.inventory_image .. "^itemoverlay_not_enough_players.png",
        stack_max = 1,
        on_drop = function() return end,
        on_use = function(_, player)
            local pl_name = player:get_player_name()
            local arena = arena_lib.get_arena_by_player(pl_name)
            if not murder.is_player_playing(pl_name) then return end
            local role = arena.roles[pl_name]

            for i, item in pairs(role.items) do
                local item_name = item.name or item
                
                if item_name == definition.name then
                    needed_players = item.required_players_amount
                    break
                end
            end
            murder.print_error(pl_name, murder.T("There must be at least @1 players to use this", needed_players))
        end
    }) 
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

    role.on_start = function(self, arena, pl_name)
        murder.log(arena, pl_name .." is " .. self.name .. " and called on start")

        local player = minetest.get_player_by_name(pl_name)
        self.in_game = true

        murder.generate_HUD(arena, pl_name)
        -- Hiding the wielded item if 3d_armor is installed.
        player:get_meta():set_int("show_wielded_item", 2)
        
        on_start(self, arena, pl_name)
    end

    role.on_kill = function(self, arena, pl_name, killed_pl_name)
        murder.log(arena, pl_name .. " called on kill (killed: " .. killed_pl_name .. ")")
        on_kill(self, arena, pl_name, killed_pl_name)
    end

    role.on_death = function(self, arena, pl_name, reason)
        murder.log(arena, pl_name .. " called on death")

        murder.update_hud(pl_name, "role", murder.T("Spectator"))
        on_death(self, arena, pl_name, reason)
        murder.eliminate_role(pl_name)

        -- If the player was killed using murder.kill_player().
        if reason and reason.type == "punch" then
            local killer_name = reason.object:get_player_name()
            local killer_role = arena.roles[killer_name]

            murder.print_msg(pl_name, murder.T("@1 (@2) killed you!", killer_name, murder.T(killer_role.name)))
            killer_role:on_kill(arena, killer_name, pl_name)
        end
    end

    role.on_eliminated = function(self, arena, pl_name)
        murder.log(arena, pl_name.." called on eliminated ")
        
        self.in_game = false
        local last_role = murder.get_last_role_in_game(arena)
        local remaining_players = murder.count_players_in_game(arena)

        murder.out_of_match_operations(pl_name)

        if last_role then murder.log(arena, "Last role is " .. last_role.name .. " with count " .. remaining_players) 
        else murder.log(arena, "Two or more different roles are in game, count players alive: " .. remaining_players) end

        -- If the remaining players have all the same role, their team wins.
        if last_role and remaining_players > 1 then
            murder.team_wins(arena, last_role)
            murder.log(arena, "Team " .. last_role.name .. " wins")
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

        arena_lib.remove_player_from_arena(pl_name, 1)
        on_eliminated(self, arena, pl_name)
    end

    role.on_end = function(self, arena, pl_name)
        murder.log(arena, pl_name .. " called on end")
        if self.in_game then
            on_end(self, arena, pl_name)
        end
    end
end



function set_physics(role)
    local phys = role.physics_override or {}
    phys.speed = phys.speed or 1.2
    phys.gravity = phys.gravity or 1
    phys.acceleration = phys.acceleration or 1
    phys.jump = phys.jump or 1
    phys.sneak = phys.sneak or true
    phys.sneak_glitch = phys.sneak_glitch or false
    phys.new_move = phys.new_move or true

    role.physics_override = phys
end
