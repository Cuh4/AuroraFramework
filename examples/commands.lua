------------------------------------------------------------------------------------------------------------------------
    -- Aurora Framework | A reliable addon creation framework designed to make addon creation easier.
	-- 		Created by @cuh6_ on Discord
	--		My Discord: https://discord.gg/CymKaDE2pj
------------------------------------------------------------------------------------------------------------------------

----------------------------------------
-- [Example] Commands
-- This example creates a one-use command that kills the user. Only players with auth can use the command.
----------------------------------------

-- Create a command that kills any player who uses it, and prevents others from using it afterwards.
---@param player af_services_player_player
---@param command af_services_command_command
---@param args table<integer, string>
AuroraFramework.services.commandService.create(function(player, command, args)
    player:kill() -- Kills the player
    command:successNotification("You died! Congratulations!", player) -- Shows a success notification on the right of their screen temporarily

    command:remove() -- Prevent other players from using this command
end, "kill", {"s", "k", "suicide", "die"}, false, "Kills the player.", true, false)

-- The parameters passed through to the "create" function are, in order, the following:
-- name ("kill"),
-- shorthands ({"s", "k", "suicide", "die"}),
-- capsSensitive (false),
-- description ("Kills the player."),
-- requiresAuth (true),
-- requiresAdmin (false)