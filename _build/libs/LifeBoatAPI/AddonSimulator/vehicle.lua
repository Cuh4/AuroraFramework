-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


---@section ---@section ___REMOVE_THIS__ADDON_SIMULATOR_VEHICLE_LUA

--- Spawns a vehicle that is in an addon
--- @param matrix SWMatrix The matrix the vehicle should be spawned at
--- @param addon_index number The index of the addon as it is found in the missions folder. There is no set order and it may not be the same next execution.
--- @param component_id number NOT THE COMPONENT_INDEX. The component_id can be found using getLocationComponentData
--- @return number vehicle_id, boolean is_success
function server.spawnAddonVehicle(matrix, addon_index, component_id)
    return 1, true
end

--- Spawns a vehicle from your vehicle save folder. NOTE: will spawn an "empty" vehicle if a vehicle file cannot be found. It is impossible to distinguish from an actual vehicle server-wise. BUG REPORT
--- @param matrix SWMatrix The matrix the vehicle should be spawned at
--- @param save_name string The name of the save file to spawn
--- @return number vehicle_id, boolean is_success
function server.spawnVehicle(matrix, save_name)
    return 1, true
end

--- Despawns a vehicle from the world
--- @param vehicle_id number The unique id of the vehicle
--- @param is_instant boolean If the vehicle should be despawned instantly (true) or when no one is near (false)
--- @return boolean is_success
function server.despawnVehicle(vehicle_id, is_instant)
    return true
end

--- Returns the position of the vehicle as a matrix
--- @param vehicle_id number The unique id of the vehicle
--- @param voxel_x number 0,0,0 is the center of the vehicle (viewable with the move tool). Each "block" or 0.25m is a different voxel. 0,0.25,0 is one block above the start point.
--- @param voxel_y number 
--- @param voxel_z number 
--- @return SWMatrix matrix, boolean is_success
function server.getVehiclePos(vehicle_id, voxel_x, voxel_y, voxel_z)
    return LifeBoatAPI.Matrix:newMatrix(), true
end

--- Teleports a vehicle from it's current locaiton to the new matrix
--- @param vehicle_id number The unique id of the vehicle
--- @param matrix SWMatrix The matrix to be applied to the vehicle
function server.setVehiclePos(vehicle_id, matrix) end

--- Teleports a vehicle from it's current locaiton to the new matrix. The vehicle is displaced by other vehicles at the arrival point
--- @param vehicle_id number The unique id of the vehicle
--- @param matrix SWMatrix The matrix to be applied to the vehicle
function server.setVehiclePosSafe(vehicle_id, matrix) end

--- Reloads the vehicle as if spawning from a workbench - refreshing damage and inventories etc.
--- @param vehicle_id number The unique id of the vehicle
function server.resetVehicleState(vehicle_id) end

--- Returns the name of the vehicle
--- @param vehicle_id number The unique id of the vehicle
--- @return string name, boolean is_success
function server.getVehicleName(vehicle_id)
    return "test_vehicle", true
end

--- Returns info on a vehicle
--- @param vehicle_id number The unique if of the vehicle
--- @return SWVehicleData vehicle_data, boolean is_success
function server.getVehicleData(vehicle_id)
    return {
        tags_full = "", -- string The tags as a string (ex. "tag1,tag2,tag3")
        tags = {""}, -- table<number, string> The tags of the vehicle
        filename = "", -- string The file name of the vehicle
        transform = LifeBoatAPI.Matrix:newMatrix(), -- SWMatrix The position of the vehicle
        simulating = true, -- boolean Whether the vehicle is simulating (loaded) or not
        mass = 10, -- number The mass of the vehicle
        voxels = 10, -- number The voxel count of the vehicle
        editable = true, -- boolean Is the vehicle editable at workbenches
        invulnerable = false, -- boolean Is the vehicle invulnerable
    }, true
end

--- Removes all vehicles from the world
function server.cleanVehicles() end

--- Cleans up fallout zones
function server.clearRadiation() end

--- Allows direct inputs to a chair from addon Lua
--- @param vehicle_id number The unique id of the vehicle
--- @param seat_name string The name of the seat as it apears on the vehicle. Editable using the select tool in the workbench
--- @param axis_ws number The W/S axis as it appears on the chair
--- @param axis_da number The D/A axis as it appears on the chair
--- @param axis_ud number The Up/Down axis as it appears on the chair
--- @param axis_rl number The Right/Left axis as it appears on the chair
--- @param button_1 boolean The chair button 1 state
--- @param button_2 boolean The chair button 2 state
--- @param button_3 boolean The chair button 3 state
--- @param button_4 boolean The chair button 4 state
--- @param button_5 boolean The chair button 5 state
--- @param button_6 boolean The chair button 6 state
function server.setVehicleSeat(vehicle_id, seat_name, axis_ws, axis_da, axis_ud, axis_rl, button_1, button_2, button_3, button_4, button_5, button_6) end

--- Presses a button on a vehicle. Warning, can cause massive lag. LAG BUG REPORT Also note: Static vehicles can output values even when not powered BUG REPORT
--- @param vehicle_id number The unique id of the vehicle
--- @param button_name string The name of the button as it appears on the vehicle. Editable using the select tool in the workbench
function server.pressVehicleButton(vehicle_id, button_name) end

--- Returns the state of a vehicle button
--- @param vehicle_id number The unique id of the vehicle
--- @param button_name string The name of the button as it appears on the vehicle. Editable using the select tool in the workbench
--- @return SWVehicleButtonData data, boolean is_success
function server.getVehicleButton(vehicle_id, button_name)
    return { on = true }, true
end

--- Gets a vehicle's sign voxel location
--- @param vehicle_id number The unique ID of the vehicle to get the sign on
--- @param sign_name number The name of the sign to get
--- @return SWVehicleSignData data, boolean is_success
function server.getVehicleSign(vehicle_id, sign_name)
    return { pos = {x=0, y=0, z=0} }, true
end

--- Sets a keypad's value
--- @param vehicle_id number The unique id of the vehicle
--- @param keypad_name string The name of the keypad as it appears on the vehicle. Editable using the select tool in the workbench
--- @param value number The value you want to set the keypad to
function server.setVehicleKeypad(vehicle_id, keypad_name, value) end

--- Returns the value of the specified dial
--- @param vehicle_id number The unique id of the vehicle
--- @param dial_name string The name of the dial as it appears on the vehicle. Editable using the select tool in the workbench
--- @return SWVehicleDialData value, boolean is_success
function server.getVehicleDial(vehicle_id, dial_name)
    return {value=1, value2=2}, true
end

--- Fills a fluid tank with the specified liquid
--- @param vehicle_id number The unique id of the vehicle
--- @param tank_name string The name of the tank as it appears on the vehicle. Editable using the select tool in the workbench
--- @param amount number The amount you want to fill the tank in litres
--- @param FLUID_TYPE SWTankFluidTypeEnum number for fuel type
function server.setVehicleTank(vehicle_id, tank_name, amount, FLUID_TYPE) end

--- Returns the amount of liters in the tank
--- @param vehicle_id number The unique id of the vehicle
--- @param tank_name string The name of the fuel tank as it appears on the vehicle. Editable using the select tool in the workbench
--- @return SWVehicleTankData data, boolean is_success
function server.getVehicleTank(vehicle_id, tank_name)
    return {
        value = 500, -- number current level
        capacity = 700, -- number total capacity
        fluid_type = 0, -- number 
    }, true
end

--- Sets the number of coal objects inside a hopper
--- @param vehicle_id number The vehicle ID to set the hopper on
--- @param hopper_name string The name of the hopper to set
--- @param amount number The amount to set the hopper to
function server.setVehicleHopper(vehicle_id, hopper_name, amount) end

--- Returns the coal count for the specified hopper
--- @param vehicle_id number The vehicle ID to get the hopper from
--- @param hopper_name string The name of the hopper to get
--- @return SWVehicleHopperData data, boolean is_success
function server.getVehicleHopper(vehicle_id, hopper_name)
    return {
        value = 100, -- number current level
        capacity = 100, -- number total capacity
    }, true
end

--- Sets the charge level of the battery
--- @param vehicle_id number The unique id of the vehicle
--- @param battery_name string The name of the battery as it appears on the vehicle. Editable using the select tool in the workbench
--- @param amount number The amount you want to fill the battery to
function server.setVehicleBattery(vehicle_id, battery_name, amount) end

--- Returns the charge level of the battery
--- @param vehicle_id number The unique id of the vehicle
--- @param battery_name string The name of the battery as it appears on the vehicle. Editable using the select tool in the workbench
--- @return SWVehicleBatteryData data, boolean is_success
function server.getVehicleBattery(vehicle_id, battery_name)
    return {charge = 100}, true
end

--- Sets the charge level of the weapon
--- @param vehicle_id number The unique id of the vehicle
--- @param weapon_name string The name of the weapon as it appears on the vehicle. Editable using the select tool in the workbench
--- @param amount number The amount you want to fill the ammo to
function server.setVehicleWeapon(vehicle_id, weapon_name, amount) end

--- Returns the charge level of the weapon
--- @param vehicle_id number The unique id of the vehicle
--- @param weapon_name string The name of the weapon as it appears on the vehicle. Editable using the select tool in the workbench
--- @return SWVehicleWeaponData data, boolean is_success
function server.getVehicleWeapon(vehicle_id, weapon_name)
    return {
        ammo = 100,
        capacity = 300
    }, true
end

--- Returns the amount of surfaces that are on fire
--- @param vehicle_id number The unique id of the vehicle
--- @return number surface_count, boolean is_success
function server.getVehicleFireCount(vehicle_id)
    return 1, true
end

--- Only works on vehicles where "show on map" is off. Shows the text when looked directly at. Blocks with unique tooltips such as buttons will override this tooltip
--- @param vehicle_id number The unique id of the vehicle
--- @param text string The text that will appear in the tooltip
--- @return boolean is_success
function server.setVehicleTooltip(vehicle_id, text)
    return true
end

--- Applies impact damage to a vehicle at the specified voxel location
--- @param vehicle_id number The ID of the vehicle to apply damage to
--- @param amount number The amount of damage to apply (0-100)
--- @param voxel_x number The voxel's X position to apply damage to
--- @param voxel_y number The voxel's Y position to apply damage to
--- @param voxel_z number The voxel's Z position to apply damage to
--- @return boolean is_success
function server.addDamage(vehicle_id, amount, voxel_x, voxel_y, voxel_z)
    return true
end

--- Returns whether the specified vehicle has finished loading and is simulating. 
--- @param vehicle_id number The unique id of the vehicle
--- @return boolean is_simulating, boolean is_success
function server.getVehicleSimulating(vehicle_id)
    return true, true
end

--- Returns whether the specified vehicle is loading, simulating or unloading
--- @param vehicle_id number The unique id of the vehicle
--- @return string is_local, boolean is_success
function server.getVehicleLocal(vehicle_id)
    return "local", true
end

--- Will set the vehicle's transponder state. If a transponder does not exist on the vehicle, an invisible one will be created.
--- @param vehicle_id number The unique id of the vehicle
--- @param is_active boolean Turns the transponder on/off
--- @return boolean is_success
function server.setVehicleTransponder(vehicle_id, is_active)
    return true
end

--- Allows a vehicle to be edited. NOTE: the vehicle will only be editable when next to a workbench. You can see it on the map but cannot teleport or remove it. BUG REPORT
--- @param vehicle_id number The unique id of the vehicle
--- @param is_editable boolean Sets whether or not the vehicle is able to be edited
--- @return boolean is_success
function server.setVehicleEditable(vehicle_id, is_editable)
    return true
end

--- Sets a vehicle to invulnerable
--- @param vehicle_id number The unique id of the vehicle
--- @param is_invulnerable boolean Sets whether or not the vehicle is immune to damage
--- @return boolean is_success
function server.setVehicleInvulnerable(vehicle_id, is_invulnerable)
    return true
end

--- Sets a vehicle to show on the map
--- @param vehicle_id number The ID of the vehicle to show/hide on map
--- @param is_show_on_map boolean Whether to show/hide the vehicle on the map
--- @return boolean is_success
function server.setVehicleShowOnMap(vehicle_id, is_show_on_map)
    return true
end

---@endsection