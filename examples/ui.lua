------------------------------------------------------------------------------------------------------------------------
    -- Aurora Framework | A reliable addon creation framework designed to make addon creation easier.
	-- 		Created by @cuh6_ on Discord
	--		My Discord: https://discord.gg/CymKaDE2pj
------------------------------------------------------------------------------------------------------------------------

----------------------------------------
-- [Example] UI
-- This example shows how you can create UI. This example will only touch on screen UI components (screen popup) and map UI components (map object). The other UI components work very similarly, so don't worry much.
----------------------------------------

-- Create UI that'll be shown for everyone
local UI = AuroraFramework.services.UIService.createScreenUI(
    server.getMapID(), -- the ID of this ui
    "Welcome to my server!", -- the text that should be shown
    0, -- the x position on the screen (-1 to 1. -1 = far left, 1 = far right)
    0.8 -- the y position on the screen (-1 to 1. -1 = bottom, 1 = top)
)

-- Text seems a bit lacking, so we can change it like so:
UI.properties.text = "Welcome to my awesome server!"
UI:refresh()

-- We can also change the visibility of the UI.
UI.properties.visible = false
UI:refresh()

-- Now, let's create a custom player marker on the map.
server.setGameSetting("map_show_players", false)

---@param player af_services_player_player
AuroraFramework.services.playerService.events.onJoin:connect(function(player)
    -- Create a map object for the player who just joined
    local mapObject = AuroraFramework.services.UIService.createMapObject(
        player.properties.peer_id + 1000, -- id of the ui
        "[Player] "..player.properties.peer_id, -- title of the ui
        "Steam ID: "..player.properties.steam_id, -- subtitle of the ui
        matrix.translation(0, 0, 0), -- position of the ui, or position offset if the ui is attached to an object/vehicle
        1, -- the marker type of the ui (1 = survivor)
        nil, --- the player to show the map object to, or nil for everyone (nil by default)
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
    local mapObject = AuroraFramework.services.UIService.getMapObject(player.properties.peer_id + 1000)

    -- Make sure it exists. Who knows, maybe something went wrong and the map object doesn't exist for some reason
    if not mapObject then
        return
    end

    -- And now, we shall remove it
    mapObject:remove()
end)