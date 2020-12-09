local logs = {} -- arena = logs


function murder.log(arena, msg)
    if type(arena) == "table" then arena = arena.name end
    logs[arena] = logs[arena] or ""
    logs[arena] = logs[arena] .. "\n" .. msg
end



function murder.print_logs(arena, pl_name)
    if type(arena) == "table" then arena = arena.name end
    logs[arena] = logs[arena] or ""
    minetest.chat_send_player(pl_name, logs[arena])
end