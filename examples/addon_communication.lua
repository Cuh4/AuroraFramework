------------------------------------------------------------------------------------------------------------------------
    -- Aurora Framework | A reliable addon creation framework designed to make addon creation easier.
	-- 		Created by @cuh6_ on Discord
	--		My Discord: https://discord.gg/CymKaDE2pj
------------------------------------------------------------------------------------------------------------------------

----------------------------------------
-- [Example] Addon Communication
-- This example shows how you can communicate between addons easily with this framework
----------------------------------------

-- Create a channel
-- The name of the channel cannot have spaces (spaces get stripped anyway), and for other addons to receive messages from this addon, they have to use the same channel name when creating a channel
local mainChannel = AuroraFramework.services.communicationService.createChannel("main")

-- Listen for messages on the channel
mainChannel:listen(true, function(data) -- first parameter dictates whether the addon should accept messages from this addon and other addons, or just other addons
    AuroraFramework.services.chatService.sendMessage("Server", "I received a message: "..data["message"]) -- this will print in chat: "I received a message: hello world"
end)

-- Send a message through the channel to other addons
mainChannel:send({ -- note that this can even be a string. it doesn't have to be a table
    message = "hello world",

    data = {
        "anything",
        "can go",
        "here",
        {
            "and it'll be sent over"
        }
    }
})