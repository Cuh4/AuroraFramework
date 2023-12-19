------------------------------------------------------------------------------------------------------------------------
    -- Aurora Framework | A reliable addon creation framework designed to make addon creation easier.
	-- 		Created by @cuh6_ on Discord
	--		My Discord: https://discord.gg/CymKaDE2pj
------------------------------------------------------------------------------------------------------------------------

----------------------------------------
-- [Example] UI
-- This example shows how you can create UI. This example will only touch on screen UI components (screen popup) and map UI components (map object). The other UI components work very similarly, so don't worry much.
----------------------------------------

--[[
    Note:
        UI persists even after addon reloads. The framework takes care of UI IDs and persistence for you.
        If you create a UI once on world creation, it will stay even after numerous save loads and addon reloads unless you remove it.

        ---

        UIs that are only shown to a player are automatically removed when they leave.

        ---

        We must use the ready event when creating UI to allow the UIService to setup things before we do anything.
        If we don't use the ready event, we run the risk of UI being overwritten and causing issues.

        If you insist on not using the ready event, you must do:
        AuroraFramework.services.UIService.getScreenUI(name) or AuroraFramework.services.UIService.createScreenUI(name, ...)

        Instead of:
        AuroraFramework.services.UIService.createScreenUI(name, ...)
]]

-- But even then, you may run into some issues.
AuroraFramework.ready:connect(function()
    -- Create UI that'll be shown for everyone
    local UI = AuroraFramework.services.UIService.createScreenUI( -- if a screen popup with the same name already exists (framework stores UI in g_savedata, so UI persists!), it gets overwritten but uses the same id
        "WelcomeUI", -- the name of this ui
        "Welcome to my server!", -- the text that should be shown
        0, -- the x position on the screen (-1 to 1. -1 = far left, 1 = far right)
        0.8, -- the y position on the screen (-1 to 1. -1 = bottom, 1 = top),
        nil -- the player to show the UI to, if nil, it becomes shown to everyone
    )

    -- Text seems a bit lacking, so we can change it like so:
    UI.properties.text = "Welcome to my awesome server!"
    UI:refresh()

    -- We can also change the visibility of the UI.
    UI.properties.visible = false
    UI:refresh()
end)

-- Now, let's create a custom player marker on the map.
server.setGameSetting("map_show_players", false)

---@param player af_services_player_player
AuroraFramework.services.playerService.events.onJoin:connect(function(player)
    -- Create a map object for the player who just joined
    local uiName = AuroraFramework.services.UIService.name("PlayerMapIcon", player) -- if the player's peer id is 5, then this would become: "PlayerMapIcon5". this is here to prevent multiple UIs having the same name and therefore overwriting each other

    local mapObject = AuroraFramework.services.UIService.getMapObject(uiName) or AuroraFramework.services.UIService.createMapObject(
        uiName, -- name of the ui
        "[Player] "..player.properties.peer_id, -- title of the ui
        "Steam ID: "..player.properties.steam_id, -- subtitle of the ui
        matrix.translation(0, 0, 0), -- position of the ui, or position offset if the ui is attached to an object/vehicle
        1, -- the marker type of the ui (1 = survivor)
        nil, -- the player to show the map object to, or nil for everyone (nil by default)
        50, -- radius of the map object
        255, -- color rgba (red)
        255, -- color rgba (green)
        255, -- color rgba (blue)
        255 -- color rgba (alpha, aka opacity)
    )

    -- Attach it to the player's character
    local characterID = player:getCharacter()
    mapObject:attach(2, characterID) -- position type, object/vehicle id. position type can be 0 for fixed, 1 for vehicles, and 2 for objects
end)

---@param player af_services_player_player
AuroraFramework.services.playerService.events.onLeave:connect(function(player)
    -- Get the player's map marker UI
    local mapObject = AuroraFramework.services.UIService.getMapObject(
        AuroraFramework.services.UIService.name("PlayerMapIcon", player)
    )

    -- Make sure it exists. Who knows, maybe something went wrong and the map object doesn't exist for some reason
    if not mapObject then
        return
    end

    -- And now, we shall remove it
    mapObject:remove()
end)