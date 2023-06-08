-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@sectiom Bitwise
LifeBoatAPI.Bitwise = {

    --- Compacts 24 booleans to a single number, that can be sent to SW keypads
    ---@param flags boolean[]
    ---@return number
    bitFlagsToNumber = function(flags)
        local result = 0;
        for i=1, 24 do
            result = result | (flags[i] and 1 or 0) << (i-1)
        end
        return result
    end;

    --- Unpacks a number into 24 boolean flags, for recieving compacted data from vehicle dials
    ---@param bytes number
    ---@return boolean[]
    numberToBitFlags = function(bytes)
        local flags = {}
        for i=1, 24 do
            local bitVal = bytes & (1 << (i-1))
            flags[i] = bitVal > 0 -- convert back to bool
        end
        return flags
    end;
}
---@endsection