------------------------------------------------------------------------------------------------------------------------
    -- Aurora Framework | A reliable addon creation framework designed to make addon creation easier.
	-- 		Created by @cuh6_ on Discord
	--		My Discord: https://discord.gg/CymKaDE2pj
------------------------------------------------------------------------------------------------------------------------

----------------------------------------
-- [Example] Groups
-- This example moves non-primary vehicles apart of a spawned group around every 0.1 seconds.
----------------------------------------

---@param group af_services_group_group
AuroraFramework.services.groupService.events.onSpawn:connect(function(group)
    -- This function will be called every x seconds
    local function move()
        -- Move all non-primary vehicles in a random direction
        for _, vehicle in pairs(group.properties.vehicles) do
            -- This is a primary vehicle, so ignore
            if vehicle.properties.isPrimaryVehicle then
                goto continue
            end

            -- This is a non-primary vehicle, so move the vehicle in a random direction
            local currentPos = vehicle:getPosition()
            local newPos = AuroraFramework.libraries.matrix.randomOffset(
                currentPos, -- position to offset
                10, -- offset amount
                false -- prevent changing the y (altitude)
            )

            vehicle:move(newPos)

            -- Continue to next vehicle
            ::continue::
        end
    end

    -- Call "move" every x seconds
    AuroraFramework.libraries.timer.loop.create(0.1, move)
end)