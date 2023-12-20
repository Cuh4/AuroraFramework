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

-- Note that HTTP requests can only be sent to localhost. This is a Stormworks limitation. If you want to send requests to places other than localhost (eg: google.com), you'll
-- need a HTTP server that redirects your request to wherever you want it to go, basically a proxy.

-- Only GET requests can be made. This is, of course, yet another Stormworks limitation.

local hasHandled = {}

AuroraFramework.services.timerService.loop.create(5, function() -- calls this function every 5 seconds
    -- Create the target url
    local url = AuroraFramework.services.HTTPService.URLArgs("/message", -- becomes "/message?source=game"
        {
            name = "source",
            value = "game"
        }
    )

    -- Send a request
    ---@param response string
    ---@param success boolean
    local request = AuroraFramework.services.HTTPService.request(6500, url, function(response, success) -- the response is anything that the request returns
        -- Check if the request was successful
        if not success then -- alternatively, you can do "if not AuroraFramework.services.HTTPService.ok(response) then". but this is unneeded because this is actually what happens behind the scenes
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