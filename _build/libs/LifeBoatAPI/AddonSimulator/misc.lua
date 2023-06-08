-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


---@section ---@section ___REMOVE_THIS__ADDON_SIMULATOR_MISC_LUA

--- Adds a checkbox to the settings of the addon
--- @param text string The text to show on the checkbox
--- @param default_value boolean The default value of the checkbox
--- @return boolean value
function property.checkbox(text, default_value)
    return default_value
end

--- Adds a slider to the settings of the addon
--- @param text string The text to show on the checkbox
--- @param min number The min value of the slider
--- @param max number The max value of the slider
--- @param increment number The increment of the slider (step size)
--- @param default_value number The default value of the slider
--- @return number value
function property.slider(text, min, max, increment, default_value)
    return default_value
end

--- Limited to one request per 2 ticks (32 requests/s). Any additional requests will be queued
--- @param port number The port you are making the request on
--- @param request string The URL to make the request to.
function server.httpGet(port, request) end

--- Bans a player from your server. There is no way to unban players from that save, choose wisely! A new save will have to be created before a banned player can rejoin.
--- @param peer_id number The peer id of the affected player
function server.banPlayer(peer_id) end

--- Kicks a player from your server. They can rejoin
--- @param peer_id number The peer id of the affected player. Kicking -1 will kick the host, closing the server.
function server.kickPlayer(peer_id) end

--- Makes a player an admin. (Able to kick, ban, auth)
--- @param peer_id number The peer id of the affected player
function server.addAdmin(peer_id) end

--- Removes the admin permissions from a player
--- @param peer_id number The peer id of the affected player
function server.removeAdmin(peer_id) end

--- Gives a player the ability to spawn in vehicles and edit unlocked game settings
--- @param peer_id number The peer id of the affected player
function server.addAuth(peer_id) end

--- Remove the auth permissions from a player
--- @param peer_id number The peer id of the affected player
function server.removeAuth(peer_id) end

--- Send a save command for a dedicated server, with an optional save name parameter
--- @param save_name string Name to give the save
function server.save(save_name) end

--- For random seeding
--- @return number system_time milliseconds - may not be reliable sync between different machines
function server.getTimeMillisec()
    return os.clock()
end

--- Get whether the game considers the tutorial active (Default missions check this before they spawn)
--- @return boolean tutorial_completed
function server.getTutorial()
    return true
end

--- Sets whether the game considers the tutorial active (useful if you are making your own tutorial)
function server.setTutorial() end

--- Returns whether or not the user has been informed of the video tutorials that are on the main menu and pause screen.
--- @return boolean user_notified
function server.getVideoTutorial()
    return true
end

--- Returns true of the host player is a developer of the game.
--- @return boolean is_dev
function server.isDev()
    return false
end

--- Returns true if the server has the weapons DLC active.
--- @return boolean is_enabled
function server.dlcWeapons()
    return true
end

--- Log a message to the console output
--- @param message string The string to log
function debug.log(message)
    print(message)
end

---@endsection