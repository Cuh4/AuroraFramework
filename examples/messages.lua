------------------------------------------------------------------------------------------------------------------------
    -- Aurora Framework | A reliable addon creation framework designed to make addon creation easier.
	-- 		Created by @cuh6_ on Discord
	--		My Discord: https://discord.gg/CymKaDE2pj
------------------------------------------------------------------------------------------------------------------------

----------------------------------------
-- [Example] Messages
-- This example shows how you can send, edit, and delete chat messages.
----------------------------------------

-- NOTE: Messages sent by addons or unrecognized players (eg: the server player in a dedicated server) are not tracked, so when a message sent by someone
--       is deleted or edited, the messages sent by addons or unrecognized players will be completely wiped and won't be resent. This is because
--       Stormworks doesn't natively support message editing/deleting, so the framework just sends enough blank messages to clear the chat, then resends
--       every tracked message.

-- Send a random message when a player joins
local randomJoinMessages = {
    "Welcome, %s!",
    "Hey there, %s!",
    "Welcome to the server, %s!"
}

---@param player af_services_player_player
AuroraFramework.services.playerService.events.onJoin:connect(function(player)
    -- Get a random message
    local message = AuroraFramework.libraries.miscellaneous.getRandomTableValue(randomJoinMessages)

    -- Send it only to the player
    AuroraFramework.services.chatService.sendMessage(
        "Server",
        message:format(player.properties.name),
        player -- only the player can see the message
    )
end)


-- 50% chance of editing messages sent by a player
---@param message af_services_chat_message
AuroraFramework.services.chatService.events.onMessageSent:connect(function(message)
    -- Get the player
    local player = message.properties.author

    -- 50% chance of editing
    local shouldEdit = math.random(1, 2) == 2

    -- Player is lucky, so stop here
    if not shouldEdit then
        return
    end

    -- Edit the message
    message:edit("No") -- edit the message for everyone
    -- message:edit("No", player) -- edit the message only for the player who sent the message

    -- Notify the player
    AuroraFramework.services.notificationService.info(
        "Uh oh!",
        "Your message has been edited.",
        player
    )
end)

-- Delete messages sent by a player if they request it
---@param player af_services_player_player
---@param command af_services_command_command
---@param args table<integer, string>
AuroraFramework.services.commandService.create(function(player, command, args)
    -- Get all messages sent by the player
    local messages = AuroraFramework.services.chatService.getAllMessagesSentByAPlayer(player)

    -- Go through each and every one of them and delete them
    for _, message in pairs(messages) do
        message:delete()
    end

    -- Notify the player
    AuroraFramework.services.notificationService.success(
        "Whew!",
        "All of your messages has been deleted.",
        player
    )
end, "delete", {"d", "del"}, false, "Deletes all of your messages.", false, false) -- see examples/commands.lua