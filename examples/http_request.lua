------------------------------------------------------------------------------------------------------------------------
    -- Aurora Framework | A reliable addon creation framework designed to make addon creation easier.
	-- 		Created by @cuh6_ on Discord
	--		My Discord: https://discord.gg/CymKaDE2pj
------------------------------------------------------------------------------------------------------------------------

----------------------------------------
-- [Example] HTTP
-- This example shows how you can send a HTTP request.
----------------------------------------

-- Let's pretend a HTTP server is running on port 6500, and whenever a request is sent to "/message", it returns a JSON object containing a message and an indentifier.

local hasHandled = {}

AuroraFramework.services.timerService.loop.create(5, function() -- calls this function every 5 seconds
    -- Create the target url
    local url = AuroraFramework.services.HTTPService.URLArgs("/message", -- becomes "/message?name=source&value=game"
        {
            name = "source",
            value = "game"
        }
    )

    -- Send a request
    ---@param response string
    local request = AuroraFramework.services.HTTPService.request(6500, url, function(response) -- the response is anything that the request returns
        -- Check if the request was successful
        if not AuroraFramework.services.HTTPService.ok(response) then
            return
        end

        -- Decode response
        local decodedResponse = AuroraFramework.services.HTTPService.JSON.decode(response)

        local identifier = decodedResponse.identifier
        local message = decodedResponse.message

        -- Check if we have sent this message already
        if hasHandled[identifier] then
            return
        end

        -- Send the message
        hasHandled[identifier] = true
        AuroraFramework.services.chatService.sendMessage("Message", message)
    end)

    -- Connect a random function to the request response event
    ---@param response string
    request.events.reply:connect(function(response)
        AuroraFramework.services.chatService.sendMessage("Server", "woah")
    end)
end)