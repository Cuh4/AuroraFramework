-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


---@section---@section ___REMOVE_THIS__ADDON_SIMULATOR_OBJECTS_LUA

--- @return table<number, SWPlayer> players
function server.getPlayers()
    return {
        {
            id = 1, -- number The peer ID of the player (as seen in the server player list)
            name = "test_player", -- string The name of the player
            admin = true, -- boolean Whether the player is an admin
            auth = true, -- boolean Whether the player has auth
            steam_id = 123123, -- number The player's Steam ID (convert to string as soon as possible to prevent loss of data)
        }
    }
end

--- Returns the display name of the player
--- @param peer_id number The peer id of the player
--- @return string name, boolean is_success
function server.getPlayerName(peer_id)
    return "test_player", true
end

--- Returns the position of the requested player as a matrix
--- @param peer_id number The peer id of the player
--- @return SWMatrix matrix, boolean is_success
function server.getPlayerPos(peer_id)
    return LifeBoatAPI.Matrix:newMatrix(), true
end

--- Moves the player from their current location to the matrix provided
--- @param peer_id number The peer id of the player
--- @param matrix SWMatrix The matrix that should be applied to the player
--- @return boolean is_success
function server.setPlayerPos(peer_id, matrix)
    return true
end

--- This can only be called after a user has been in the server for a few seconds. Returns the direction the player is looking in. A player sitting in a seat will have their look direction reported relative to the seat. If the seat is upside down, looking "up" is down relative to the world. math.atan(x,z) will return the heading the player is facing.
--- @param peer_id number The peer id of the player
--- @return number x, number y, number z, boolean is_success
function server.getPlayerLookDirection(peer_id)
    return 0, 0, 1, true
end

--- Returns the id of the player's character
--- @param peer_id number The peer id of the player
--- @return number object_id, boolean is_success
function server.getPlayerCharacterID(peer_id)
    return 1, true
end

--- Spawns an object at the specified matrix
--- @param matrix SWMatrix The matrix that the object should be spawned at
--- @param  object_type SWObjectTypeEnum number, object type
--- @return number object_id, boolean is_success
function server.spawnObject(matrix, object_type)
    return 1, true
end

--- Spawns a fire at the given matrix. Can spawn explosions
--- @param matrix SWMatrix The matrix the fire will be spawned at
--- @param size number The size of the fire (0-10)
--- @param magnitude number -1 explodes instantly. Nearer to 0 means the explosion takes longer to happen. Must be below 0 for explosions to work.
--- @param is_lit boolean Lights the fire. If the magnitude is >1, this will need to be true for the fire to first warm up before exploding.
--- @param is_explosive boolean If the fire is explosive
--- @param parent_vehicle_id number Can be 0 or nil. When given a vehicle id, the fire will follow the given vehicle.
--- @param explosion_magnitude number The size of the explosion (0-5)
--- @return number object_id, boolean is_success
function server.spawnFire(matrix, size, magnitude, is_lit, is_explosive, parent_vehicle_id, explosion_magnitude)
    return 1, true
end

--- Spawns an NPC.
--- @param matrix SWMatrix The matrix the character will be spawned at
--- @param outfit_id SWOutfitTypeEnum If is_interactable is false, outfit_id is the name that shows up when looking at the NPC . This is the only place to give the character a name.
--- @return number object_id, boolean is_success
function server.spawnCharacter(matrix, outfit_id)
    return 1, true
end

--- Spawns an animal (penguin, shark, etc.)
--- @param matrix SWMatrix The matrix the animal will be spawned at
--- @param animal_type SWAnimalTypeEnum number
--- @param size_multiplier number The scale multiplier of the animal
--- @return number object_id, boolean is_success
function server.spawnAnimal(matrix, animal_type, size_multiplier)
    return 1, true
end

--- Despawns objects. Can be used on characters and animals.
--- @param object_id number The unique id of the object/character/animal to be despawned
--- @param is_instant boolean If the object should be despawned instantly (true) or when no one is near (false)
--- @return boolean is_success
function server.despawnObject(object_id, is_instant)
    return true
end

--- Get the positon of an object/character/animal
--- @param object_id number The unique id of the object/character/animal
--- @return SWMatrix matrix, boolean is_success
function server.getObjectPos(object_id)
    return LifeBoatAPI.Matrix:newMatrix(), true
end

--- Sets the position of an object/character/animalGet the simulating state of a specified object
--- @param object_id number The unique id of the object/character/animal
--- @return boolean is_simulating, boolean is_success
function server.getObjectSimulating(object_id)
    return true, true
end

--- Sets the position of an object/character/animal
--- @param object_id number The unique id of the object/character/animal
--- @param matrix SWMatrix The matrix to be applied to the object/character/animal
--- @return boolean is_success
function server.setObjectPos(object_id, matrix) 
    return true
end


--- Sets the parameters for a fire
--- @param object_id number The unique id of the fire
--- @param is_lit boolean If the fire is ignited
--- @param is_explosive boolean If the fire is explosive
function server.setFireData(object_id, is_lit, is_explosive) end

--- Returns the is_lit parameter of a fire
--- @param object_id number The unique id of the fire
--- @return boolean is_lit, boolean is_success
function server.getFireData(object_id)
    return true, true
end

--- Kills the given character
--- @param object_id number The unique object_id of the character you want to kill
function server.killCharacter(object_id) end

--- Revives the given character
--- @param object_id number The unique object_id of the character you want to revive
function server.reviveCharacter(object_id) end

--- Makes the provided character sit in the first seat found that has a matching name to that which is provided. Can seat player characters
--- @param object_id number The unique object_id of the character you want to seat
--- @param vehicle_id number The vehicle that the seat is a part of
--- @param seat_name string The name of the seat as it appears on the vehicle. Editable using the select tool in the workbench.
function server.setCharacterSeated(object_id, vehicle_id, seat_name) end

--- Returns the various parameters of the provided character
--- @param object_id number The unique object_id of the character you want to get data on
--- @return SWCharacterData character_data
function server.getCharacterData(object_id)
    return {
        hp = 50, -- number The character's health points
        incapacitated = false, -- boolean Whether the character is incapacitated
        dead = true, -- boolean Whether the character is dead
        interactible = true, -- boolean Whether the character is interactible
        ai = false, -- boolean Whether the character is AI or not
    }
end

--- Get the current vehicle_id for a specified character object
--- @param object_id number The unique id of the character
--- @return number vehicle_id, boolean is_success
function server.getCharacterVehicle(object_id)
    return 1, true
end

--- Sets the various parameters of a character
--- @param object_id number The unique id of the character/object/animal to be affected
--- @param hp number Value from 0 to 100. Has no effect on objects. Value will still be saved regardless. While is_interactable is false, hp can be any value.
--- @param is_interactable boolean If this is false you cannot pickup or ask the character to follow. Their name will be outfit_id which can't be set here (must be set at spawnCharacter)
--- @param is_ai boolean lets the character do seat controls
function server.setCharacterData(object_id, hp, is_interactable, is_ai) end

--- Set the equipment a character has
--- @param object_id number The unique id of the character
--- @param slot SWSlotNumberEnum number
--- @param EQUIPMENT_ID SWEquipmentTypeEnum number 
--- @param is_active boolean Activates equipment such as strobe lights and fire exstinguishers.
--- @param integer_value number|nil Depending on the item, sets the integer value (charges, ammo, channel, etc.)
--- @param float_value number|nil Depending on the item, sets the float value (ammo, battery, etc.)
--- @return boolean is_success
function server.setCharacterItem(object_id, slot, EQUIPMENT_ID, is_active, integer_value, float_value)
    return true
end

--- Returns the id of the equipment that the character has in the provided slot
--- @param object_id number The unique id of the character to check
--- @param SLOT_NUMBER SWSlotNumberEnum number
--- @return number equipment_id, boolean is_success
function server.getCharacterItem(object_id, SLOT_NUMBER)
    return 1, true
end

---@endsection