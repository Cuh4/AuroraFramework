-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@section ___REMOVE_THIS__ADDON_SIMULATOR_ADDON_LUA

--- Get the internal index of an active addon (useful if you want to spawn objects from another script). Omitting the name argument will return this addon's index
--- @param name string|nil The name of the addon as it appears in xml file. Not the filename
--- @return number addon_index, boolean is_success
function server.getAddonIndex(name)
    return 0, true
end

--- Get the internal index of a location in the specified addon by its name (this index is local to the addon)
--- @param addon_index number The index of the addon as it is found in the missions folder. There is no set order and it may not be the same next execution.
--- @param name string The name of the location as it appears in the addon
--- @return number location_index
function server.getLocationIndex(addon_index, name)
    return 0
end

--- The name of the location as it appears in the addon
--- @param name string 
--- @return boolean is_success
function server.spawnThisAddonLocation(name)
    return true
end

--- Spawn a mission location at the given matrix
--- @param matrix SWMatrix Matrix the mission location should spawn at. 0,0,0 matrix will spawn at a random location of the tile's type.
--- @param addon_index number The index of the addon as it is found in the missions folder. There is no set order and it may not be the same next execution.
--- @param location_index number The index of the location as it appears in the addon.
--- @return SWMatrix matrix, boolean is_success
function server.spawnAddonLocation(matrix, addon_index, location_index)
    return matrix, true
end

--- Get the filepath of a addon
--- @param addon_name string The name of the addon as it appears in the save file
--- @param is_rom boolean Only true for missions that are made by the developers (or at least put in the file path "Stormworks\rom\data\missions")
--- @return string path, boolean is_success
function server.getAddonPath(addon_name, is_rom)
    return "", false
end

--- Returns a list of all env mod zones
--- @param tag string|nil Returns a list of all env mod zones that match the tag(s). Example: server.getZones("type=car,arctic")  Returns all zones that have exactly type=car AND arctic in it's tags
--- @return table<number, SWZone> ZONE_LIST
function server.getZones(tag)
    return {}
end

--- Returns whether the matrix is within an env mod zone that matches the display name
--- @param matrix SWMatrix The matrix to check
--- @param zone_display_name string The environment mod zone to test the matrix against
--- @return boolean is_in_zone, boolean is_success
function server.isInZone(matrix, zone_display_name)
    return true, true
end

--- Returns the amount of addons that are enabled on this save
--- @return number count
function server.getAddonCount()
    return 1
end

--- Returns data about the addon
--- @param addon_index number The index of the addon as it is found in the missions folder. There is no set order and it may not be the same next execution. INDEX STARTS AT 0
--- @return SWAddonData addon_data
function server.getAddonData(addon_index)
    return {
        name = "",           
        path_id = "",        
        file_store = "",     
        location_count = 0,  
    }
end

--- @param matrix SWMatrix The matrix the mission object should be spawned at
--- @param addon_index number The index of the addon as it is found in the missions folder. There is no set order and it may not be the same next execution.
--- @param location_index number The unique index of the location that the component is in
--- @param component_index number The index of the component that can be read from the COMPONENT_DATA table using server.getLocationComponentData()
--- @return SWAddonComponentSpawned component, boolean is_success
function server.spawnAddonComponent(matrix, addon_index, location_index, component_index)
    return {
        tags_full = "",             
        tags = {"tag1=true"},       
        display_name = "test_name", 
        type = 1,                   
        transform = matrix,         
        id = 1,                     
    }, true
end

--- Returns data on a specific location in the addon
--- @param addon_index number The index of the addon as it is found in the missions folder. There is no set order and it may not be the same next execution. INDEX STARTS AT 0
--- @param location_index number The index of the location as it is found in the missions folder. There is no set order and it may not be the same next execution. INDEX STARTS AT 0
--- @return SWLocationData location_data, boolean is_success
function server.getLocationData(addon_index, location_index)
    return {
        name = "test_name",
        tile = "test tile name",
        env_spawn_count = 0,
        env_mod = false,
        component_count = 0,
    }, true
end

--- Returns data on a specific mission component. returned data includes component_id which can be used with server.spawnVehicle()
--- @param addon_index number The index of the addon as it is found in the missions folder. There is no set order and it may not be the same next execution. INDEX STARTS AT 0
--- @param location_index number The index of the location in the addon
--- @param component_index number The index of the component in the addon
--- @return SWAddonComponentData component_data, boolean is_success
function server.getLocationComponentData(addon_index, location_index, component_index)
    return {
        name = "test_name",
        tile = "test tile name",
        env_spawn_count = 0,
        env_mod = false,
        component_count = 0,
    }, true
end

---@endsection