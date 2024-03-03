------------------------------------------------------------------------------------------------------------------------
    -- Aurora Framework | A reliable addon creation framework designed to make addon creation easier.
	-- 		Created by @cuh6_ on Discord
	--		My Discord: https://discord.gg/CymKaDE2pj
------------------------------------------------------------------------------------------------------------------------

----------------------------------------
-- [Example] HTTP
-- This example shows how you can send a HTTP request.
----------------------------------------

-- Let's pretend that the URL "/foo" returns a string of "Hello, World!"
AuroraFramework.services.timerService.loop.create(5, function() -- calls this function every 5 seconds
    -- Create the target url
    local url = AuroraFramework.services.HTTPService.URLArgs("/foo", -- becomes "/foo?source=game"
        {
            name = "source",
            value = "game"
        }
    )

    -- Send a request
    ---@param response string
    ---@param success boolean
    local request, awaitingReply = AuroraFramework.services.HTTPService.request(6500, url, function(response, success) -- the response is anything that the request returns
        -- Check if the request was successful
        if not success then -- alternatively, you can do "if not AuroraFramework.services.HTTPService.ok(response) then". but this is unneeded because this is actually what happens behind the scenes
            return
        end

        -- Send response
        AuroraFramework.services.chatService.sendMessage("Message", response)
    end)

    -- Connect a random function to the request response event
    ---@param response string
    ---@param successful boolean
    awaitingReply.events.reply:connect(function(response, successful)
        AuroraFramework.services.chatService.sendMessage("Server", "woah")
    end)
end)