-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@section ___REMOVE_THIS__ADDON_SIMULATOR_GAME_LUA

--- @param transform_matrix SWMatrix
--- @param magnitude number magnitude 0->1
--- @return boolean is_success 
function server.spawnTsunami(transform_matrix, magnitude)
    return true
end

--- @param transform_matrix SWMatrix
--- @param magnitude number magnitude 0->1
--- @return boolean is_success 
function server.spawnWhirlpool(transform_matrix, magnitude)
    return true
end

--- Cancels the current gerstner wave even (tsunami or whirlpool)
function server.cancelGerstner() end

--- @param transform_matrix SWMatrix
--- @param magnitude number magnitude 0->1
--- @return boolean is_success 
function server.spawnTornado(transform_matrix, magnitude)
    return true
end

--- @param transform_matrix SWMatrix
--- @param magnitude number magnitude 0->1
--- @return boolean is_success 
function server.spawnMeteor(transform_matrix, magnitude)
    return true
end

--- @param transform_matrix SWMatrix
--- @param magnitude number magnitude 0->1
--- @return boolean is_success 
function server.spawnVolcano(transform_matrix, magnitude)
    return true
end

--- @return table<number, SWVolcano> volcanos 
function server.getVolcanos()
    return {
        {
            x = 0,
            y = 0,
            z = 0,
            tile_x = 0,
            tile_y = 0,
        }
    }
end

--- Requires Weapons DLC
--- @param transform_matrix SWMatrix
--- @param magnitude number 0->1
function server.spawnExplosion(transform_matrix, magnitude) end

--- Used to set game settings
--- @param GameSettingString SWGameSettingEnum
--- @param value boolean The game setting state. True or False
function server.setGameSetting(GameSettingString, value) end

--- Returns a table of the game settings indexed by the GAME_SETTING string, this can be accessed inline eg. server.getGameSettings().third_person
--- @return SWGameSettings game_settings
function server.getGameSettings() end

--- Used to set the money and research points for the player
--- @param money number How much money the player will have
--- @param research_points number How many research points the player will have
function server.setCurrency(money, research_points) end

--- Returns how much money the player has
--- @return number money
function server.getCurrency()
    return 1
end

--- Returns how many research points the player has
--- @return number research_points
function server.getResearchPoints()
    return 1
end

--- Returns how many days the player has survived
--- @return number days_survived
function server.getDateValue()
    return 1
end

--- Gets the current game date
--- @return number d, number m, number y
function server.getDate()
    return 1, 1, 1
end

--- Returns the current game time
--- @return SWTime clock
function server.getTime()
    return {
        hour            = 12,
        minute          = 0,
        daylight_factor = 0.5,
        percent         = 0.5
    }
end

--- Returns the time the save has been running for in milliseconds
--- @param transform_matrix SWMatrix
--- @return SWWeather weather
function server.getWeather(transform_matrix)
    return {
        fog  = 0.5,
        rain = 0.5,
        snow = 0.5,
        wind = 0.5,
        temp = 0.5
    }
end

--- Returns the world position of a random ocean tile within the selected search range
--- @param matrix SWMatrix The matrix to start the search at
--- @param min_search_range number The mininum search range relative to the provided matrix. In meters
--- @param max_search_range number The maximum search range relative to the provided matrix. In meters
--- @return SWMatrix matrix, boolean is_success
function server.getOceanTransform(matrix, min_search_range, max_search_range)
    return matrix, true
end

--- Returns the world position of a random tile of type tile_name closest to the supplied location
--- @param transform_matrix SWMatrix The matrix to find the tile near
--- @param tile_name string The name of the tile to find
--- @param search_radius number|nil The radius in which to find the tile. Max is 50000
--- @return SWMatrix transform_matrix, boolean is_success
function server.getTileTransform(transform_matrix, tile_name, search_radius)
    return transform_matrix, true
end

--- Returns the data for the tile at the specified location
--- @param transform SWMatrix The matrix to get the tile data for
--- @return SWTileData tile_data, boolean is_success
function server.getTile(transform)
    return {
        name = "test",
        sea_floor = 0,
        cost = 10000,    
        purchased = true
    }, true
end

--- Returns the data for the tile selected at the start of the game
--- @return SWStartTile tile_data, boolean is_success
function server.getStartTile()
    return {
        name = "test",
        x = 0,
        y = 0,
        z = 0
    }, true
end

--- Returns whether the tile at the given world coordinates is player owned
--- @param matrix SWMatrix The matrix the tile can be found at. Doesn't have to be exact, just has to be within the tile.
--- @return boolean is_purchased
function server.getTilePurchased(matrix)
    return true
end

--- Returns whether the object transform is within a custom zone of the selected size
--- @param matrix_object SWMatrix The matrix of the object
--- @param matrix_zone SWMatrix The matrix of the zone to search within
--- @param zone_size_x number The size of the zone. Refer to World Space 
--- @param zone_size_y number The size of the zone. Refer to World Space 
--- @param zone_size_z number The size of the zone. Refer to World Space 
--- @return boolean is_in_area
function server.isInTransformArea(matrix_object, matrix_zone, zone_size_x, zone_size_y, zone_size_z)
    return LifeBoatAPI.Colliders.isPointInZone(matrix_object, matrix_zone, zone_size_x, zone_size_y, zone_size_z)
end

--- Returns a table of waypoints that form a path from start to end, tags should be seperated by commas with no spaces.
--- @param matrix_start SWMatrix The starting point of the path. Refer to World Space
--- @param matrix_end SWMatrix The ending point of the path. Refer to World Space
--- @param required_tags string The tags a graph node must have to be used.
--- @param avoided_tags string The tags it will avoid if a graph node has it. (To omit provide a empty string "")
--- @return table<number, SWPathFindPoint> position_list
function server.pathfind(matrix_start, matrix_end, required_tags, avoided_tags)
    return {{x=0,y=0}, {x=100, y=100}, {x=1000, y=1000}}
end

--- Returns a table of waypoints tagged with ocean_path, that form a path from start to end. This functions the same as passing "ocean_path" as a required tag to server.pathfind().
--- @param matrix_start SWMatrix The starting point of the path. World Space 
--- @param matrix_end SWMatrix The ending point of the path. World Space
--- @return table<number, SWPathFindPoint> position_list
function server.pathfindOcean(matrix_start, matrix_end)
    return {{x=0,y=0}, {x=100, y=100}, {x=1000, y=1000}}
end


---@endsection