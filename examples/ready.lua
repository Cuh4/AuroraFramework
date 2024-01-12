------------------------------------------------------------------------------------------------------------------------
    -- Aurora Framework | A reliable addon creation framework designed to make addon creation easier.
	-- 		Created by @cuh6_ on Discord
	--		My Discord: https://discord.gg/CymKaDE2pj
------------------------------------------------------------------------------------------------------------------------

----------------------------------------
-- [Example] Ready
-- Basic example showcasing the framework's "ready" event
----------------------------------------

-- Function that prints "Framework is ready! {your message}" to chat
---@param message string
local function quickPrint(message)
    AuroraFramework.services.chatService.sendMessage(
        "Server",
        ("Framework is ready! %s"):format(message)
    )
end

-- Connect a function to the framework ready event
---@param state af_ready_state
AuroraFramework.ready:connect(function(state)
    -- Utilize the framework here
    AuroraFramework.services.UIService.createScreenUI( -- Create or modify an existing UI with the name "Text1"
        "Text1", -- The internal name of the UI used for persistence
        "Hello! Ready State: "..state, -- The text that should be shown
        0, -- The X position on the screen (-1 to 1, 1 being right)
        0.8 -- The Y position on the screen (-1 to 1, 1 being top)
    )

    -- Print a message based on the ready state
    if state == "addon_reload" then
        quickPrint("The addon was reloaded.")
    elseif state == "save_create" then
        quickPrint("A new world has been created with this addon enabled.")
    elseif state == "save_load" then
        quickPrint("An existing save with this addon enabled has been loaded.")
    end
end)