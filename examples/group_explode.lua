------------------------------------------------------------------------------------------------------------------------
    -- Aurora Framework | A reliable addon creation framework designed to make addon creation easier.
	-- 		Created by @cuh6_ on Discord
	--		My Discord: https://discord.gg/CymKaDE2pj
------------------------------------------------------------------------------------------------------------------------

----------------------------------------
-- [Example] This example explodes non-primary vehicles (any vehicles that weren't the first to spawn in a group) in a group that just spawned.
----------------------------------------

---@param group af_services_group_group
AuroraFramework.services.groupService.events.onSpawn:connect(function(group)
    -- Loop through all vehicles in the group
    for _, vehicle in pairs(group.properties.vehicles) do
        -- This is a primary vehicle, so we ignore it
        if vehicle.properties.isPrimaryVehicle then
            goto continue
        end

        -- This is a non-primary vehicle, so let's explode it
        vehicle:explode(0.05, false) -- Magnitude of 0.05 / 1, despawn set to false so the vehicle doesn't despawn upon exploding

        -- Continue to next vehicle
        ::continue::
    end
end)