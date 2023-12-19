------------------------------------------------------------------------------------------------------------------------
    -- Aurora Framework | A reliable addon creation framework designed to make addon creation easier.
	-- 		Created by @cuh6_ on Discord
	--		My Discord: https://discord.gg/CymKaDE2pj
------------------------------------------------------------------------------------------------------------------------

----------------------------------------
-- [Example] Player
-- This example shows how you utilize the player service.
----------------------------------------

-- Set dedicated server property
AuroraFramework.services.playerService.setDedicatedServer(false) -- False by default, cannot be undone. If set to true, the framework will effectively make it so the host player (player with peer ID 0) gets removed internally. In dedicated servers, the host player is the server itself.

-- Do everything once the framework is ready. We need this because all the services are initialized when the addon and framework is ready which is always after the base-level addon code is ran
AuroraFramework.ready:connect(function()
    -- Get players. Note that you can only fetch players when the framework is ready
    local host = AuroraFramework.services.playerService.getPlayerByPeerID(0) -- Host player (the one who created the server, or in dedicated servers, the server/first player to join)

    local handsomeMan = AuroraFramework.services.playerService.getPlayerByName("Cuh4") -- caps sensitive search, must be exact
    local handsomeMan2 = AuroraFramework.services.playerService.getPlayerByNameSearch("CUH4") -- non-caps sensitive search, can be partial, returns player with closest name to the provided name
    local handsomeMan3 = AuroraFramework.services.playerService.getPlayerBySteamID(handsomeMan2.properties.steam_id) -- Get a player by their Steam ID. This returns handsomeMan2 because we're using his Steam ID
    local handsomeMan4 = AuroraFramework.services.playerService.getPlayerByObjectID(handsomeMan3:getCharacter()) -- Get a player by their character ID

    local allPlayers = AuroraFramework.services.playerService.getAllPlayers() -- Returns a table of all recognized players

    -- Send a notification to all recognized players
    -- Note that this won't do anything, because players in the server aren't loaded by the framework until the next tick
    for _, player in pairs(allPlayers) do
        AuroraFramework.services.notificationService.info(
            "Game",
            "Sup, "..player.properties.name..".",
            player
        )
    end
end)

-- Guess the number game
local randomNumbersForPlayer = {} -- indexed by peer ID

---@param player af_services_player_player
AuroraFramework.services.playerService.events.onJoin:connect(function(player)
    -- Give a random number for the player
    local randomNumber = math.random(1, 10)
    randomNumbersForPlayer[player.properties.peer_id] = randomNumber

    -- Announce the game
    AuroraFramework.services.chatService.sendMessage(
        "Game",
        "Guess the number between 1-10!",
        player
    )
end)

---@param message af_services_chat_message
AuroraFramework.services.chatService.events.onMessageSent:connect(function(message)
    -- Get the random number given for the player when they joined
    local randomNumber = randomNumbersForPlayer[message.properties.author.properties.peer_id]

    -- Player doesn't have a number (they have completed the game)
    if not randomNumber then
        return
    end

    -- Check if they guessed it correctly
    if tonumber(message) == randomNumber then
        -- They guessed correctly, so say good job
        AuroraFramework.services.chatService.sendMessage(
            "Game",
            "Good job! You guessed correctly!",
            message.properties.author
        )
    else
        -- They did not guess correctly, so mercilessly ban them
        AuroraFramework.services.chatService.sendMessage(
            "Game",
            "No",
            message.properties.author
        )

        message.properties.author:ban()
    end
end)

-- When a player dies, mock them
---@param player af_services_player_player
AuroraFramework.services.playerService.events.onDie:connect(function(player)
    AuroraFramework.services.chatService.sendMessage(
        "Death",
        ("loool! %s died! what a nerd!"):format(player.properties.name)
    )
end)

-- When a player respawns, give them a SMG
---@param player af_services_player_player
AuroraFramework.services.playerService.events.onRespawn:connect(function(player)
    -- Give SMG
    player:setItem(
        1, -- slot 1
        37, -- smg
        false, -- inactive. if we was to set this to true, the smg would start shooting even if the player didn't have it equipped
        100000, -- 100,000 bullets
        nil -- unneeded, but this can be a number. needed for items like fire extinguishers, flashlights, etc
    )

    -- Get the player to 1 HP
    player:damage(99) -- 100 (max health) - 99 = 1 HP
end)