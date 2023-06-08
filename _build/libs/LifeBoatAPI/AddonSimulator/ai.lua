-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


---@section ___REMOVE_THIS__ADDON_SIMULATOR_AI_LUA

--- Sets the AI state of a character
--- @param object_id number The unique id of the character
--- @param AI_STATE number 0 = none, 1 = path to destination, see in-game
function server.setAIState(object_id, AI_STATE) end

--- Sets the target destination for the AI
--- @param object_id number The unique id of the character
--- @param matrix_destination SWMatrix The matrix that the AI will try to reach
function server.setAITarget(object_id, matrix_destination) end

--- Gets the target destination for an AI
--- @param object_id number The unique ID of the character object ID
--- @return SWTargetData data
function server.getAITarget(object_id)
    return {
        character = 0,
        vehicle = 0,
        x = 0,
        y = 0,
        z = 0,
    }
end

--- Sets the target charcter for an AI. Different AIs use this data for their unique tasks
--- @param object_id number The unique id of the character
--- @param target_object_id number
function server.setAITargetCharacter(object_id, target_object_id) end

--- Sets the target vehicle for an AI. Different AIs use this data for their unique tasks
--- @param object_id number The unique id of the character
--- @param target_vehicle_id number
function server.setAITargetVehicle(object_id, target_vehicle_id) end

---@endsection