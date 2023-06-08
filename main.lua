local old = debug.log
debug.log = function(msg)
    old(msg)
    AuroraFramework.services.chatService.sendMessage("debug", msg)
end

printTbl = function(tbl, indent)
    if not indent then
        indent = 0
    end

    for i, v in pairs(tbl) do
        formatting = string.rep("  ", indent)..i..": "

        if type(v) == "table" then
            debug.log(formatting)
            printTbl(v, indent + 1)
        else
            debug.log(formatting..tostring(v))
        end
    end
end

---@param player af_services_player_player
AuroraFramework.services.playerService.events.onJoin:connect(function(player)
    
end)

---@param vehicle af_services_vehicle_vehicle
AuroraFramework.services.vehicleService.events.onSpawn:connect(function(vehicle)
    
end)

AuroraFramework.services.commandService.create(function(command, args, player)
    
end, "test", {"t"})

AuroraFramework.game.callbacks.onCustomCommand.main:connect(function()
    for i, v in pairs(AuroraFramework.services.chatService.getAllMessagesSentByAPlayer(AuroraFramework.services.playerService.getPlayerByPeerID(0))) do
        v:edit("im a nerd")
    end

    for i, v in pairs(AuroraFramework.services.vehicleService.getAllVehiclesSpawnedByAPlayer(AuroraFramework.services.playerService.getPlayerByPeerID(0))) do
        v:setTooltip("hey")

        local pos = v:getPosition()
        pos = AuroraFramework.libraries.matrix.randomOffset(pos, 10)
        v:teleport(pos)

        AuroraFramework.libraries.timer.delay.create(1, function()
            v:explode(1)
        end)
    end
end)

AuroraFramework.services.chatService.events.onMessageSent:connect(function(message) ---@param message af_services_chat_message
    
end)