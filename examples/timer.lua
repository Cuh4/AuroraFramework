------------------------------------------------------------------------------------------------------------------------
    -- Aurora Framework | A reliable addon creation framework designed to make addon creation easier.
	-- 		Created by @cuh6_ on Discord
	--		My Discord: https://discord.gg/CymKaDE2pj
------------------------------------------------------------------------------------------------------------------------

----------------------------------------
-- [Example] Timer
-- This example shows how you can delay or loop function calls.
----------------------------------------

-- Create a delay that, after 5 seconds, sends a message in chat
---@param delay af_services_timer_delay
AuroraFramework.services.timerService.delay.create(5, function(delay)
    AuroraFramework.services.chatService:sendMessage("Hello, all!")

    delay:setDuration(6) -- Update the delay duration to 6. This is useless though, since the delay gets removed immediately after this function has finished executing
end)

-- Create a loop that, every x seconds, spawns a meteor that targets wherever the host player was standing
---@param loop af_services_timer_loop
AuroraFramework.services.timerService.loop.create(5, function(loop)
    local host = AuroraFramework.services.playerService.getPlayerByPeerID(0)

    if not host then -- host can be nil if there are no players in the server when the addon is being ran in a dedicated server and the player service "isDedicatedServer" property is true, OR the same property is true in a non-dedicated server
        return
    end

    server.spawnMeteor(host:getPosition(), 1) -- Spawn a meteor at the host's position

    loop:setDuration(math.random(5, 15)) -- Update the loop duration to a random value, makes things a bit more unpredictable
end)

-- Create a useless delay
local function uselessCallback()
    -- Ban all players in the server
    for _, player in pairs(AuroraFramework.services.playerService.getAllPlayers()) do
        player:ban()
    end
end

local delay = AuroraFramework.services.timerService.delay.create(1, uselessCallback) -- Create the delay
delay:remove() -- Remove the delay, and as a result, no players get banned! :D