------------------------------------------------------------------------------------------------------------------------
    -- Aurora Framework | A reliable addon creation framework designed to make addon creation easier.
	-- 		Created by @cuh6_ on Discord
	--		My Discord: https://discord.gg/CymKaDE2pj
------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--// Lua LSP Diagnostics \\--
--------------------------------------------------------------------------------
---@diagnostic disable assign-type-mismatch

--------------------------------------------------------------------------------
--// Framework \\--
--------------------------------------------------------------------------------
AuroraFramework = {
	---@type table<string, af_callbacks_callback>
	callbacks = {},

	attributes = {},
	internal = {},
	libraries = {},
	services = {}
}

g_savedata = {
	AuroraFramework = {
		---@type table<integer, af_savedata_vehicle>
		vehicles = {},

		---@type table<integer, af_savedata_group>
		groups = {},

		UI = {
			---@type table<string, af_savedata_map_label>
			mapLabels = {},

			---@type table<string, af_savedata_map_line>
			mapLines = {},

			---@type table<string, af_savedata_map_object>
			mapObjects = {},

			---@type table<string, af_savedata_screen_ui>
			screen = {}
		},

		---@type table<integer, boolean>
		recognizedPeerIDs = {}
	}
}

--------------------------------------------------------------------------------
--// Attributes \\--
--------------------------------------------------------------------------------
---------------- DLCs
AuroraFramework.attributes.WeaponsEnabled = server.dlcWeapons()
AuroraFramework.attributes.AridEnabled = server.dlcArid()
AuroraFramework.attributes.SpaceEnabled = server.dlcSpace()

---------------- Misc
AuroraFramework.attributes.AddonIndex = (server.getAddonIndex())

--------------------------------------------------------------------------------
--// Libraries \\--
--------------------------------------------------------------------------------
---------------- Class
AuroraFramework.libraries.class = {}

-- Create a class
---@param name string
---@param methods table|nil
---@param properties table|nil
---@param events table|nil
---@param parentTo table|nil
---@param parentToIndex any
---@return af_libs_class_class
AuroraFramework.libraries.class.create = function(name, methods, properties, events, parentTo, parentToIndex)
	-- assign properties and events to the class
	local class = {
		__name__ = name,
		properties = properties or {},
		events = events or {}
	}

	-- assign methods to the class
	class = AuroraFramework.libraries.miscellaneous.combineTables(
		class,
		methods
	)

	-- parent the class to a table if needed
	if parentTo then
		if parentToIndex then
			-- use custom index
			parentTo[parentToIndex] = class
		else
			-- use lua-determined integer index
			table.insert(parentTo, class)
		end
	end

	-- return
	return class
end

-- Returns whether or not a class is of a specific type (equivalent to "class.__name__ == classType")
---@param class af_libs_class_class
---@param classType string
AuroraFramework.libraries.class.is = function(class, classType)
	return class.__name__ == classType
end

---------------- Matrix
AuroraFramework.libraries.matrix = {}

-- Offsets the position by x, y, and z
---@param position SWMatrix
---@param x number|nil 0 if nil
---@param y number|nil 0 if nil
---@param z number|nil 0 if nil
AuroraFramework.libraries.matrix.offset = function(position, x, y, z)
	local new = matrix.translation(0, 0, 0)

	for index, value in pairs(position) do
		new[index] = value
	end

	local toOffset = {x or 0, y or 0, z or 0}

	for i = 1, 3 do
		new[12 + i] = new[12 + i] + toOffset[i]
	end

	return new
end

-- Offsets the position by a random x, y, z, between -max, and max
---@param position SWMatrix
---@param max number
---@param shouldOffsetY boolean|nil
AuroraFramework.libraries.matrix.randomOffset = function(position, max, shouldOffsetY)
	return AuroraFramework.libraries.matrix.offset(
		position,
		math.random(-max, max),
		AuroraFramework.libraries.miscellaneous.switchbox(math.random(-max, max), 0, shouldOffsetY),
		math.random(-max, max)
	)
end

---------------- Miscellaneous
AuroraFramework.libraries.miscellaneous = {}

-- Recursively convert a table to string
---@param tbl table
---@param indent number|nil
AuroraFramework.libraries.miscellaneous.tableToString = function(tbl, indent)
	-- default indent
    if not indent then
        indent = 0
    end

    -- create a table for later
    local toConcatenate = {}

    -- convert the table to a string
    for index, value in pairs(tbl) do
        -- get value type
        local valueType = type(value)

        -- format the index for later
        local formattedIndex = ("%s:"):format(index)

        -- format the value
        local toAdd = formattedIndex

        if valueType == "table" then
			-- format table
			local nextIndent = indent + 2
            local formattedValue = AuroraFramework.libraries.miscellaneous.tableToString(value, nextIndent)

			-- check if empty table
			if formattedValue == "" then
				formattedValue = "{}"
			else
				formattedValue = "\n"..formattedValue
			end

			-- add to string
            toAdd = toAdd..(" %s"):format(formattedValue)
        elseif valueType == "number" or valueType == "boolean" then
            toAdd = toAdd..(" %s"):format(tostring(value))
        else
            toAdd = toAdd..(" \"%s\""):format(tostring(value):gsub("\n", "\\n"))
        end

        -- add to table
        table.insert(toConcatenate, ("  "):rep(indent)..toAdd)
    end

    -- return the table as a formatted string
    return table.concat(toConcatenate, "\n")
end

-- Returns whether or not if a number is between two numbers
---@param number number
---@param thresholdMin number
---@param thresholdMax number
AuroraFramework.libraries.miscellaneous.threshold = function(number, thresholdMin, thresholdMax)
	return number >= thresholdMin and number <= thresholdMax
end

-- Combine tables together
---@param ... table
---@return table
AuroraFramework.libraries.miscellaneous.combineTables = function(...)
	-- create vars
	local tables = {...}

	-- length check
	if #tables <= 1 then
		return tables[1] or {} -- there might be one table or zero tables, hence the "or"
	end

	-- get the main table. all other tables will be added to this table
	local main = tables[1]

	-- combine tables
	for _, tbl in pairs(tables) do
		for index, value in pairs(tbl) do
			main[index] = value
		end
	end

	-- return
	return main
end

-- Create a PID object (from https://steamcommunity.com/sharedfiles/filedetails/?id=1800568163)
---@param proportional number
---@param integral number
---@param derivative number
---@return af_libs_miscellaneous_pid
AuroraFramework.libraries.miscellaneous.pid = function(proportional, integral, derivative)
    ---@type af_libs_miscellaneous_pid
	local pid = AuroraFramework.libraries.class.create(
		"PID",

		{
			---@param self af_libs_miscellaneous_pid
			---@param setPoint number
			---@param processVariable number
			run = function(self, setPoint, processVariable)
				local E = setPoint - processVariable
				local D = E - self.properties._E
				local absolute = math.abs(D - self.properties._D)

				self.properties._E = E
				self.properties._D = D
				self.properties._I = absolute < E and self.properties._I + E * self.properties.integral or self.properties._I * 0.5

				return E * self.properties.proportional + (absolute < E and self.properties._I or 0) + D * self.properties.derivative
			end
		},

		{
			proportional = proportional,
			integral = integral,
			derivative = derivative,

			_E = 0,
			_D = 0,
			_I = 0,
		}
	)

	return pid
end

-- Create a profiler
---@return af_libs_miscellaneous_profiler
AuroraFramework.libraries.miscellaneous.profiler = function()
    ---@type af_libs_miscellaneous_profiler
	local profiler = AuroraFramework.libraries.class.create(
		"profiler",

		{
			---@param self af_libs_miscellaneous_profiler
			start = function(self)
				self.startTime = server.getTimeMillisec()
			end,

			---@param self af_libs_miscellaneous_profiler
			stop = function(self)
				self.stopTime = server.getTimeMillisec()
				self.difference = self.stopTime - self.startTime

				return self.difference
			end,
		},

		{
			startTime = 0,
			stopTime = 0,
			difference = 0
		}
	)

	return profiler
end

-- Clamp a number between min and max
---@param num number
---@param min number
---@param max number
AuroraFramework.libraries.miscellaneous.clamp = function(num, min, max)
	if num < min then
		return min
	elseif num > max then
		return max
	end

	return num
end

-- Remove a value from a table
---@param tbl table
---@param valueToRemove any
---@param useTableRemove boolean If true, the value will be removed using table.remove instead of index = nil
AuroraFramework.libraries.miscellaneous.removeValueFromTable = function(tbl, valueToRemove, useTableRemove)
	for index, value in pairs(tbl) do
		-- not the value to remove, so go to next value
		if value ~= valueToRemove then
			goto continue
		end

		-- remove the value
		if useTableRemove then
			table.remove(tbl, index)
		else
			tbl[index] = nil
		end

	    ::continue::
	end

	return tbl
end

-- Get the index of a value in a table
---@param tbl table
---@param value any
---@return any
AuroraFramework.libraries.miscellaneous.getIndexOfValueInTable = function(tbl, value)
	for i, v in pairs(tbl) do
		if v == value then
			return i
		end
	end
end

-- Get a peer ID from a player, or -1 if player is nil
---@param player af_services_player_player|nil
AuroraFramework.libraries.miscellaneous.getPeerID = function(player)
	local id = -1

	if player then
		id = player.properties.peer_id
	end

	return id
end

-- Returns the value count of a table
---@param tbl table
---@return integer
AuroraFramework.libraries.miscellaneous.getTableLength = function(tbl)
	local count = 0

	for _ in pairs(tbl) do
		count = count + 1
	end

	return count
end

-- Rounds a number
---@param input number
---@param numDecimalPlaces integer
AuroraFramework.libraries.miscellaneous.round = function(input, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(input * mult + 0.5) / mult
end

-- Converts a string to a bool ("true"/"TruE" = true, anything else = false)
---@param input string
AuroraFramework.libraries.miscellaneous.stringToBool = function(input)
    return input:lower() == "true"
end

-- Returns a random value in a table
---@param tbl table
---@return any
AuroraFramework.libraries.miscellaneous.getRandomTableValue = function(tbl)
    return tbl[math.random(1, #tbl)]
end

-- Returns the average of a table
---@param tbl table
AuroraFramework.libraries.miscellaneous.average = function(tbl)
    local sum = 0

	for _, v in pairs(tbl) do
		if type(v) == "number" then
			sum = sum + v
		end
	end

	return sum / AuroraFramework.libraries.miscellaneous.getTableLength(tbl)
end

-- Returns the "name" version of the provided string, eg: "bob" -> "Bob"
---@param input string
AuroraFramework.libraries.miscellaneous.name = function(input)
	return input:sub(1, 1):upper()..input:sub(2)
end

-- Returns on or off depending on whether or not switch is true
---@generic onValue
---@generic offValue
---
---@param on onValue
---@param off offValue
---@param switch any Preferably a boolean, but non-nil can act as a true value here
---@return onValue|offValue
AuroraFramework.libraries.miscellaneous.switchbox = function(on, off, switch)
	return switch and on or off
end

-- Returns whether or not a value is in a table
---@param value any
---@param tbl table
---@return boolean
AuroraFramework.libraries.miscellaneous.isValueInTable = function(value, tbl)
	for _, v in pairs(tbl) do
		if v == value then
			return true
		end
	end

	return false
end

-- Converts all values in a table to strings
---@param tbl table
AuroraFramework.libraries.miscellaneous.tostringValuesInTable = function(tbl)
	for index, value in pairs(tbl) do
		tbl[index] = tostring(value)
	end

	return tbl
end

-- Converts all string values in a table to lowercase
---@param tbl table
AuroraFramework.libraries.miscellaneous.lowerStringValuesInTable = function(tbl)
	for index, value in pairs(tbl) do
		if type(value) == "string" then
			tbl[index] = value:lower()
		end
	end

	return tbl
end

-- Converts all string values in a table to uppercase
---@param tbl table
AuroraFramework.libraries.miscellaneous.upperStringValuesInTable = function(tbl)
	for index, value in pairs(tbl) do
		if type(value) == "string" then
			tbl[index] = value:upper()
		end
	end

	return tbl
end

---------------- Events
AuroraFramework.libraries.events = {
	---@type table<string, af_libs_event_event>
	createdEvents = {}
}

-- Create an event
---@param name string
AuroraFramework.libraries.events.create = function(name)
	---@type af_libs_event_event
	local event = AuroraFramework.libraries.class.create(
		"event",

		{
			---@param self af_libs_event_event
			fire = function(self, ...)
				for _, connection in pairs(self.properties.connections) do
					connection(...)
				end
			end,

			---@param self af_libs_event_event
			clear = function(self)
				self.properties.connections = {}
			end,

			---@param self af_libs_event_event
			remove = function(self)
				return AuroraFramework.libraries.events.remove(self.properties.name)
			end,

			---@param self af_libs_event_event
			---@param toConnect function
			connect = function(self, toConnect)
				table.insert(self.properties.connections, toConnect)
			end
		},

		{
			name = name,
			connections = {}
		},

		nil,

		AuroraFramework.libraries.events.createdEvents,
		name
	)

	return event
end

-- Get an event
---@param name string
AuroraFramework.libraries.events.get = function(name)
	return AuroraFramework.libraries.events.createdEvents[name]
end

-- Remove an event
---@param name string
AuroraFramework.libraries.events.remove = function(name)
	AuroraFramework.libraries.events.createdEvents[name] = nil
end

--------------------------------------------------------------------------------
--// Services \\--
--------------------------------------------------------------------------------
---------------- Zone Service
AuroraFramework.services.zoneService = {
	initialize = function()
		-- Handle all zone types
		---@param loop af_services_timer_loop
		AuroraFramework.services.timerService.loop.create(AuroraFramework.services.zoneService.updateRate, function(loop)
			-- Update refresh rate
			loop:setDuration(AuroraFramework.services.zoneService.updateRate)

			-- Vehicle zones
			for _, vehicle in pairs(AuroraFramework.services.vehicleService.getAllVehicles()) do
				-- Get position
				local vehiclePos = vehicle:getPosition()

				-- Go through all zones, and check if the vehicle is in any of them
				for _, zone in pairs(AuroraFramework.services.zoneService.zones.vehicleZones) do
					-- Check distance
					local zonePos = zone.properties.position
					local distance = matrix.distance(vehiclePos, zonePos)

					if distance <= zone.properties.size then
						-- Within zone range, so enter
						zone:enter(vehicle)
					else
						-- Not within zone range, so exit
						zone:exit(vehicle)
					end
				end
			end

			-- Player zones
			for _, player in pairs(AuroraFramework.services.playerService.getAllPlayers()) do
				-- Get position
				local playerPos = player:getPosition()

				-- Go through all zones, and check if the player is in any of them
				for _, zone in pairs(AuroraFramework.services.zoneService.zones.playerZones) do
					-- Check distance
					local zonePos = zone.properties.position
					local distance = matrix.distance(playerPos, zonePos)

					if distance <= zone.properties.size then
						-- Within zone range, so enter
						zone:enter(player)
					else
						-- Not within zone range, so exit
						zone:exit(player)
					end
				end
			end
		end)

		-- Handle vehicle zones
		---@param vehicle af_services_vehicle_vehicle
		AuroraFramework.services.vehicleService.events.onDespawn:connect(function(vehicle)
			for _, zone in pairs(AuroraFramework.services.zoneService.zones.vehicleZones) do
				-- remove vehicle from zone
				zone:exit(vehicle)
			end
		end)

		-- Handle player zones
		---@param player af_services_player_player
		AuroraFramework.services.playerService.events.onLeave:connect(function(player)
			for _, zone in pairs(AuroraFramework.services.zoneService.zones.playerZones) do
				-- remove player from zone
				zone:exit(player)
			end
		end)
	end,

	updateRate = 0.02, -- in seconds

	zones = {
		---@type table<string, af_services_zone_player_zone>
		playerZones = {},

		---@type table<string, af_services_zone_vehicle_zone>
		vehicleZones = {}
	}
}

-- Set update rate. Recommended to be under 0.1. If your addon is causing performance issues with lots of vehicles spawned and players in the server, try turning this up
---@param rateInSeconds number
AuroraFramework.services.zoneService.setUpdateRate = function(rateInSeconds)
	AuroraFramework.services.zoneService.updateRate = rateInSeconds
end

-- Create a player zone
---@param name string
---@param position SWMatrix
---@param size number In meters
AuroraFramework.services.zoneService.createPlayerZone = function(name, position, size)
	-- Create zone
	---@type af_services_zone_player_zone
	local zone = AuroraFramework.libraries.class.create(
		"playerZone",

		{
			---@param self af_services_zone_player_zone
			remove = function(self)
				return AuroraFramework.services.zoneService.removePlayerZone(self.properties.name)
			end,

			---@param self af_services_zone_player_zone
			---@param newPos SWMatrix
			move = function(self, newPos)
				self.properties.position = newPos
			end,
		
			---@param self af_services_zone_player_zone
			---@param newSize number
			changeSize = function(self, newSize)
				self.properties.size = newSize
			end,

			---@param self af_services_zone_player_zone
			---@param player af_services_player_player
			inZone = function(self, player)
				return self.properties.playersInZone[player.properties.peer_id] ~= nil
			end,

			---@param self af_services_zone_player_zone
			---@param player af_services_player_player
			enter = function(self, player)
				if self:inZone(player) then
					return
				end

				self.properties.playersInZone[player.properties.peer_id] = player
				self.events.onEnter:fire(player)
			end,

			-- Exit zone (internal method, do not use)
			---@param self af_services_zone_player_zone
			---@param player af_services_player_player
			exit = function(self, player)
				if not self:inZone(player) then
					return
				end

				self.properties.playersInZone[player.properties.peer_id] = nil
				self.events.onExit:fire(player)
			end
		},

		{
			name = name,
			position = position,
			size = size,
			playersInZone = {}
		},

		{
			onEnter = AuroraFramework.libraries.events.create("auroraframework_playerzone_onenter_"..tostring(name)),
			onExit = AuroraFramework.libraries.events.create("auroraframework_playerzone_onexit_"..tostring(name))
		},

		AuroraFramework.services.zoneService.zones.playerZones,
		name
	)

	-- Return
	return zone
end

-- Remove a player zone
---@param name string
AuroraFramework.services.zoneService.removePlayerZone = function(name)
	AuroraFramework.services.zoneService.zones.playerZones[name] = nil
end

-- Create a vehicle zone
---@param name string
---@param position SWMatrix
---@param size number In meters
AuroraFramework.services.zoneService.createVehicleZone = function(name, position, size)
	-- Create zone
	---@type af_services_zone_vehicle_zone
	local zone = AuroraFramework.libraries.class.create(
		"vehicleZone",

		{
			---@param self af_services_zone_vehicle_zone
			remove = function(self)
				return AuroraFramework.services.zoneService.removeVehicleZone(self.properties.name)
			end,

			---@param self af_services_zone_vehicle_zone
			---@param newPos SWMatrix
			move = function(self, newPos)
				self.properties.position = newPos
			end,
		
			---@param self af_services_zone_vehicle_zone
			---@param newSize number
			changeSize = function(self, newSize)
				self.properties.size = newSize
			end,

			---@param self af_services_zone_vehicle_zone
			---@param vehicle af_services_vehicle_vehicle
			inZone = function(self, vehicle)
				return self.properties.vehiclesInZone[vehicle.properties.vehicle_id] ~= nil
			end,

			---@param self af_services_zone_vehicle_zone
			---@param vehicle af_services_vehicle_vehicle
			enter = function(self, vehicle)
				if self:inZone(vehicle) then
					return
				end

				self.properties.vehiclesInZone[vehicle.properties.vehicle_id] = vehicle
				self.events.onEnter:fire(vehicle)
			end,

			-- Exit zone (internal method, do not use)
			---@param self af_services_zone_vehicle_zone
			---@param vehicle af_services_vehicle_vehicle
			exit = function(self, vehicle)
				if not self:inZone(vehicle) then
					return
				end

				self.properties.vehiclesInZone[vehicle.properties.vehicle_id] = nil
				self.events.onExit:fire(vehicle)
			end
		},

		{
			name = name,
			position = position,
			size = size,
			vehiclesInZone = {}
		},

		{
			onEnter = AuroraFramework.libraries.events.create("auroraframework_vehiclezone_onenter_"..tostring(name)),
			onExit = AuroraFramework.libraries.events.create("auroraframework_vehiclezone_onexit_"..tostring(name))
		},

		AuroraFramework.services.zoneService.zones.vehicleZones,
		name
	)

	-- Return
	return zone
end

-- Remove a vehicle zone
---@param name string
AuroraFramework.services.zoneService.removeVehicleZone = function(name)
	AuroraFramework.services.zoneService.zones.vehicleZones[name] = nil
end

---------------- Debugger Service
AuroraFramework.services.debuggerService = {
	initialize = function()
		-- create artificial ontick event
		AuroraFramework.internal.artificialOnTick = AuroraFramework.libraries.events.create("auroraframework_artificialOnTick")

		-- configurables
		local artificialOnTickRequestURL = "auroraframework_debugger_ontick"
		local threshold = 2500 -- ms

		-- detect whether or not the addon has broken by finding out the time difference between onTick and an artificial ontick
		local onTickPreviousTime = server.getTimeMillisec()
		local artificialOnTickTime = server.getTimeMillisec()
		local hasBroken = false

		-- ontick side
		AuroraFramework.callbacks.onTick.internal:connect(function()
			-- set time
			onTickPreviousTime = server.getTimeMillisec()
		end)

		-- artificial ontick side
		local function heartbeat(hasBroken)
			AuroraFramework.internal.artificialOnTick:fire()

			if hasBroken then
				return
			end

			server.httpGet(0, artificialOnTickRequestURL)
		end

		---@param port integer
		---@param url string
		---@param reply string
		AuroraFramework.callbacks.httpReply.internal:connect(function(port, url, reply)
			-- not us or the addon has stopped, so stop here
			if port ~= 0 and url ~= artificialOnTickRequestURL then
				return
			end

			-- set time
			artificialOnTickTime = server.getTimeMillisec()

			-- go again
			heartbeat()

			-- stop here if the addon has broken already
			if hasBroken then
				return
			end

			-- calculate difference
			local difference = artificialOnTickTime - onTickPreviousTime

			-- if difference is within threshold, stop here
			if difference <= threshold then
				return
			end
			
			-- addon has likely stopped, so trigger event
			hasBroken = true
			AuroraFramework.services.debuggerService.events.onAddonStop:fire()
		end)

		-- start artificial ontick
		heartbeat()
	end,

	events = {
		onAddonStop = AuroraFramework.libraries.events.create("auroraFramework_onAddonStop"),
	},

	internal = {},

	---@type table<string, af_services_debugger_logger>
	loggers = {}
}

-- Find a variable in _ENV. Had to create this so I could modify a function passed through to a function
---@param variable any
---@return table|nil varTbl The table the variable was found in
---@return string|nil tblIndex The index of the table in which the variable is found
---@return string path The path to the variable (eg: _ENV.some.table.the_variable)
AuroraFramework.services.debuggerService.internal.findENVVariable = function(variable)
	-- recursive search sub-function. scans through a table to find the value then modifies it
	local variableTable
	local variableIndex
	local variablePath

	---@param tbl table
	---@param path string
	local function recursiveSearch(tbl, path)
		for index, value in pairs(tbl) do
			-- stop search if we've found it
			if result then
				return
			end

			-- set path
			local currentPath = path.."."..tostring(index)

			-- get value type
			local valueType = type(value)

			-- check the value type
			if valueType ~= "table" then
				-- value is a function, so check if its the variable we're looking for. if not, go to next value
				if value ~= variable then
					goto continue
				end

				-- found it!
				variableTable = tbl
				variableIndex = index
				variablePath = currentPath

				return
			else
				-- value is at able, so let's search it too
				recursiveSearch(value, currentPath)
			end

			::continue::
		end
	end

	-- start the search process
	recursiveSearch(_ENV, "_ENV")
	return variableTable, variableIndex, variablePath
end

-- Attaches debug code to multiple functions. Effectively tracks function usage and notifies you when a function is called by sending a message through the provided logger
---@param tbl table
---@param logger af_services_debugger_logger
---@param customHandler function|nil Function that is called when the modified functions are called
AuroraFramework.services.debuggerService.attachMultiple = function(tbl, logger, customHandler)
	-- iterate through table
	for index, value in pairs(tbl) do
		if type(value) == "table" then
			-- value is a table, so attach to all functions inside of it
			AuroraFramework.services.debuggerService.attachMultiple(value, logger, customHandler)
		elseif type(value) == "function" then
			-- value is a function, so attach to it
			AuroraFramework.services.debuggerService.attach(value, logger, customHandler)
		end
	end
end

-- Attaches debug code to a function. Effectively tracks function usage and notifies you when a function is called by sending a message through the provided logger
---@param func function The function must be a global function and not a local one
---@param logger af_services_debugger_logger
---@param customHandler function|nil Function that is called when the modified function is called
AuroraFramework.services.debuggerService.attach = function(func, logger, customHandler)
	-- find name if not provided
	local funcTable, funcIndex, funcPathString = AuroraFramework.services.debuggerService.internal.findENVVariable(func)

	-- if we couldnt find the function, then stop here
	if not funcTable then
		return
	end

	-- create class
	---@type af_services_debugger_attached_function
	local attachedFunction = AuroraFramework.libraries.class.create(
		"debuggerAttachedFunction",

		{},

		{
			name = funcPathString,
			targetFunction = nil,

			functionUsageCount = 0,
			recentExecutionTime = 0,
			averageExecutionTime = 0,
			__averageTrack = {},

			profiler = AuroraFramework.libraries.miscellaneous.profiler(),
			logger = logger
		},

		{
			functionCall = AuroraFramework.libraries.events.create("debug_attached_function_"..funcPathString)
		}
	)

	-- add custom handler
	if customHandler then
		attachedFunction.events.functionCall:connect(customHandler)
	end

	-- overwrite function
	funcTable[funcIndex] = function(...)
		-- calculate execution time
		attachedFunction.properties.profiler:start()

		-- call old function
		local returned = func(...)

		-- track stuffs
		local executionTime = attachedFunction.properties.profiler:stop()
		
		attachedFunction.properties.functionUsageCount = attachedFunction.properties.functionUsageCount + 1 -- increment usage count
		attachedFunction.properties.recentExecutionTime = executionTime -- save recent execution time

		table.insert(attachedFunction.properties.__averageTrack, executionTime) -- insert execution time into average tracking table to calculate average execution time

		-- calculate average execution time, and save it
		local averageExecutionTime = AuroraFramework.libraries.miscellaneous.average(attachedFunction.properties.__averageTrack)
		attachedFunction.properties.averageExecutionTime = averageExecutionTime

		-- clear average table if its too long
		if #attachedFunction.properties.__averageTrack > 10 then
			attachedFunction.properties.__averageTrack = {}
		end

		-- send debug message
		attachedFunction.properties.logger:send(("%s() was called. | Usage Count: %s | Took: %s ms, AVG: %s ms | Returned: %s"):format(attachedFunction.properties.name, attachedFunction.properties.functionUsageCount, executionTime, averageExecutionTime, tostring(returned)))

		-- fire event
		attachedFunction.events.functionCall:fire(attachedFunction, returned, ...)

		-- return actual function result
		return returned
	end

	attachedFunction.properties.targetFunction = funcTable[funcIndex]

	-- return
	return attachedFunction
end

-- Create a logger
---@param name string
---@param shouldSendInChat boolean|nil When a message is sent through the logger, it will send it in chat if this is true, or via debug.log if this is false
AuroraFramework.services.debuggerService.createLogger = function(name, shouldSendInChat)
	-- create the logger
	---@type af_services_debugger_logger
	local logger = AuroraFramework.libraries.class.create(
		"debuggerLogger",

		{
			---@param self af_services_debugger_logger
			remove = function(self)
				AuroraFramework.services.debuggerService.removeLogger(self.properties.name)
			end,

			---@param self af_services_debugger_logger
			---@param message any
			send = function(self, message)
				-- don't send anything if not permitted to
				if self.properties.suppressed then
					return
				end

				-- convert message to string
				if type(message) == "table" then
					message = "\n"..AuroraFramework.libraries.miscellaneous.tableToString(message)
				else
					message = tostring(message)
				end

				-- send the messages
				if self.properties.sendToChat then
					AuroraFramework.services.chatService.sendMessage(
						self.properties.formattedName,
						message
					)
				else
					debug.log(
						("%s %s"):format(self.properties.formattedName, message:gsub("\n", ("\n%s "):format(self.properties.formattedName)))
					)
				end
			end,

			---@param self af_services_debugger_logger
			---@param shouldSuppress boolean
			setSuppressed = function(self, shouldSuppress)
				self.properties.suppressed = shouldSuppress
			end
		},

		{
			name = name,
			sendToChat = shouldSendInChat or false,
			formattedName = ("[DebuggerService - Logger | %s - Addon #%s]"):format(name, AuroraFramework.attributes.AddonIndex)
		},

		nil,

		AuroraFramework.services.debuggerService.loggers,
		name
	)

	-- return
	return logger
end

-- Get a logger by name
---@param name string
AuroraFramework.services.debuggerService.getLogger = function(name)
	return AuroraFramework.services.debuggerService.loggers[name]
end

-- Remove a logger
---@param name string
AuroraFramework.services.debuggerService.removeLogger = function(name)
	AuroraFramework.services.debuggerService.loggers[name] = nil
end

---------------- Timer Service
AuroraFramework.services.timerService = {
	initialize = function()
		-- Handle loops and delays
		AuroraFramework.callbacks.onTick.internal:connect(function()
			local current = server.getTimeMillisec()
	
			-- Handle loops
			for _, loop in pairs(AuroraFramework.services.timerService.loop.ongoing) do
				if current > loop.properties.creationTime + (loop.properties.duration * 1000) then
					loop.events.completion:fire(loop)
					loop.properties.creationTime = current
				end
			end
	
			-- Handle delays
			for _, delay in pairs(AuroraFramework.services.timerService.delay.ongoing) do
				if current > delay.properties.creationTime + (delay.properties.duration * 1000) then
					delay.events.completion:fire(delay)
					delay:remove()
				end
			end
		end)
	end,

	timerID = 0,

	loop = {
		---@type table<integer, af_services_timer_loop>
		ongoing = {}
	},

	delay = {
		---@type table<integer, af_services_timer_delay>
		ongoing = {}
	}
}

-- Create a loop. Duration is in seconds
---@param duration integer In seconds
---@param callback fun(loop: af_services_timer_loop)
AuroraFramework.services.timerService.loop.create = function(duration, callback)
	-- unique id
	AuroraFramework.services.timerService.timerID = AuroraFramework.services.timerService.timerID + 1

	-- store loop
	---@type af_services_timer_loop
	local loop = AuroraFramework.libraries.class.create(
		"timerLoop",

		{
			---@param self af_services_timer_loop
			remove = function(self)
				AuroraFramework.services.timerService.loop.remove(self.properties.id)
			end,

			---@param self af_services_timer_loop
			---@param new number
			setDuration = function(self, new)
				self.duration = new
			end
		},

		{
			duration = duration,
			creationTime = server.getTimeMillisec(),
			id = AuroraFramework.services.timerService.timerID
		},

		{
			completion = AuroraFramework.libraries.events.create(AuroraFramework.services.timerService.timerID.."_af_loop")
		},

		AuroraFramework.services.timerService.loop.ongoing,
		AuroraFramework.services.timerService.timerID
	)

	-- attach callback
	loop.events.completion:connect(callback)

	-- return
	return loop
end

-- Remove a loop
---@param id integer
AuroraFramework.services.timerService.loop.remove = function(id)
	AuroraFramework.services.timerService.loop.ongoing[id] = nil
end

-- Create a delay. Duration is in seconds
---@param duration integer In seconds
---@param callback fun(delay: af_services_timer_delay)
AuroraFramework.services.timerService.delay.create = function(duration, callback)
	-- unique id
	AuroraFramework.services.timerService.timerID = AuroraFramework.services.timerService.timerID + 1

	-- store delay
	---@type af_services_timer_delay
	local delay = AuroraFramework.libraries.class.create(
		"timerDelay",

		{
			---@param self af_services_timer_delay
			remove = function(self)
				AuroraFramework.services.timerService.delay.remove(self.properties.id)
			end,

			---@param self af_services_timer_delay
			---@param new number
			setDuration = function(self, new)
				self.duration = new
			end
		},

		{
			duration = duration,
			creationTime = server.getTimeMillisec(),
			id = AuroraFramework.services.timerService.timerID
		},

		{
			completion = AuroraFramework.libraries.events.create(AuroraFramework.services.timerService.timerID.."_af_loop")
		},

		AuroraFramework.services.timerService.delay.ongoing,
		AuroraFramework.services.timerService.timerID
	)

	-- attach callback
	delay.events.completion:connect(callback)

	-- return
	return delay
end

-- Remove a delay
---@param id integer
AuroraFramework.services.timerService.delay.remove = function(id)
	AuroraFramework.services.timerService.delay.ongoing[id] = nil
end

---------------- Addon Communication
AuroraFramework.services.communicationService = {
	initialize = function()
		-- listen for messages
		---@param peer_id integer
		---@param indicator string
		---@param channelName string
		---@param addonIndex string
		---@param ... string
		AuroraFramework.callbacks.onCustomCommand.internal:connect(function(_, peer_id, _, _, indicator, channelName, addonIndex, ...)
			-- remove question mark from communication indicator
			indicator = indicator:sub(2)

			-- check if the message was sent by an addon
			if peer_id ~= -1 then
				return
			end

			-- check if the indicator is valid. if its not, then a different addon communication system is likely being used by the
			-- source addon, and therefore we should ignore it to prevent any errors (like json decoding invalid data)
			if AuroraFramework.services.communicationService.internal.communicationIndicatorName ~= indicator then
				return
			end

			-- find channel
			local channel = AuroraFramework.services.communicationService.getChannel(channelName)

			if not channel then
				return
			end

			-- convert addon index to number
			addonIndex = tonumber(addonIndex)

			-- fire event
			local data = table.concat({...}, " ") -- data may include spaces, so it ends up being split across arguments. here we just join them back together into one string
			local decoded = AuroraFramework.services.communicationService.internal.decode(data)
	
			channel.events.message:fire(decoded, addonIndex)
		end)
	end,

	---@type table<string, af_libs_communication_channel>
	channels = {},

	internal = {
		communicationIndicatorName = "auroraframework_addoncommunication"
	}
}

-- Encode data (Data --> JSON)
---@param data any
---@return string
AuroraFramework.services.communicationService.internal.encode = function(data)
	return AuroraFramework.services.HTTPService.JSON.encode(data)
end

-- Decode data (JSON --> Data)
---@param data string
---@return any
AuroraFramework.services.communicationService.internal.decode = function(data)
	return AuroraFramework.services.HTTPService.JSON.decode(data)
end

-- Create a channel, which then you can send messages or listen for messages
---@param name string
---@return af_services_communication_channel
AuroraFramework.services.communicationService.createChannel = function(name)
	-- correct parameters
	name = name:gsub(" ", "")

	-- create channel
	---@type af_services_communication_channel
	local channel = AuroraFramework.libraries.class.create(
		"communicationChannel",

		{
			---@param self af_services_communication_channel
			---@param data any
			send = function(self, data)
				AuroraFramework.services.communicationService.send(self, data)
			end,

			---@param self af_services_communication_channel
			---@param callback fun(data: any, addonIndex: integer)
			listen = function(self, callback)
				AuroraFramework.services.communicationService.listen(self, callback)
			end,

			---@param self af_services_communication_channel
			remove = function(self)
				AuroraFramework.services.communicationService.removeChannel(self.properties.name)
			end
		},

		{
			name = name
		},

		{
			message = AuroraFramework.libraries.events.create("auroraFramework_communicationService_onMessage_"..name)
		},

		AuroraFramework.services.communicationService.channels,
		name
	)

	return channel
end

-- Get a channel by its name
---@param name string
---@return af_services_communication_channel
AuroraFramework.services.communicationService.getChannel = function(name)
	return AuroraFramework.services.communicationService.channels[name]
end

-- Remove a channel
---@param name string
AuroraFramework.services.communicationService.removeChannel = function(name)
	AuroraFramework.services.communicationService.channels[name] = nil
end

-- Send a message to other addons on a specific channel
---@param channel af_services_communication_channel
---@param data any
AuroraFramework.services.communicationService.send = function(channel, data)
	-- encode data (probably hurts performance especially with larger tables)
	local encodedData = AuroraFramework.services.communicationService.internal.encode(data)

	-- send over to addons that are listening on this channel
	local command = "?"..table.concat({
		AuroraFramework.services.communicationService.internal.communicationIndicatorName,
		channel.properties.name,
		AuroraFramework.attributes.AddonIndex,
		encodedData
	}, " ")

	server.command(command) -- can't use this framework's command service here
end

-- Listen for messages from other addons on a specific channel
---@param channel af_services_communication_channel
---@param acceptMessagesFromThisAddon boolean
---@param callback fun(data: any, addonIndex: integer)
AuroraFramework.services.communicationService.listen = function(channel, acceptMessagesFromThisAddon, callback)
	-- attach function to channel's reply event
	---@param data any
	---@param addonIndex integer
	channel.events.message:connect(function(data, addonIndex)
		if addonIndex == AuroraFramework.attributes.AddonIndex and not acceptMessagesFromThisAddon then
			return
		end

		return callback(data, addonIndex)
	end)
end

---------------- TPS
AuroraFramework.services.TPSService = {
	initialize = function()
		local previous = server.getTimeMillisec()

		AuroraFramework.callbacks.onTick.internal:connect(function()
			-- calculate tps
			local now = server.getTimeMillisec()
			local tps = 1000 / (now - previous)

			-- update tps
			AuroraFramework.services.TPSService.tpsData.tps = tps

			-- calculate average tps
			local averageTPSTable = AuroraFramework.services.TPSService.internal.averageTPSTable

			if #averageTPSTable > 10 then
				-- calculate average tps
				AuroraFramework.services.TPSService.tpsData.average = AuroraFramework.libraries.miscellaneous.average(averageTPSTable)
				AuroraFramework.services.TPSService.internal.averageTPSTable = {}
			else
				-- add tps to average tps table otherwise
				table.insert(averageTPSTable, tps)
			end

			-- prepare for next tick
			previous = now
		end)
	end,

	tpsData = {
		tps = 62, -- The current server TPS
		average = 62 -- The average server TPS, calculated over 10 ticks
	},

	internal = {
		averageTPSTable = {}
	}
}

-- Returns a table containing the server TPS, and the average server TPS
AuroraFramework.services.TPSService.getTPSData = function()
	return AuroraFramework.services.TPSService.tpsData
end

---------------- Groups
AuroraFramework.services.groupService = {
	initialize = function()
		-- Load groups from savedata
		for _, group in pairs(g_savedata.AuroraFramework.groups) do
			AuroraFramework.services.groupService.internal.giveGroupData(
				group.group_id,
				group.peer_id,
				group.x,
				group.y,
				group.z,
				group.group_cost,
				group.vehicle_ids
			)
		end

		-- Give group data whenever a group is spawned
		AuroraFramework.callbacks.onGroupSpawn.internal:connect(function(...)
			-- give group data
			local data = AuroraFramework.services.groupService.internal.giveGroupData(...)

			if not data then
				return
			end

			-- fire onspawn event
			AuroraFramework.services.groupService.events.onSpawn:fire(data)
		end)

		-- Remove vehicle from group when it despawns
		---@param vehicle af_services_vehicle_vehicle
		AuroraFramework.services.vehicleService.events.onDespawn:connect(function(vehicle)
			-- get group
			local group = vehicle:getGroup()

			if not group then
				return
			end

			-- remove vehicle from group
			group.properties.vehicles[vehicle.properties.vehicle_id] = nil
		end)

		-- Remove group when all vehicles in a group despawn
		---@param vehicle af_services_vehicle_vehicle
		AuroraFramework.services.vehicleService.events.onDespawn:connect(function(vehicle)
			local group = vehicle:getGroup()

			if not group then
				return
			end

			-- wait a tick to make sure the vehicle is removed from the group
			AuroraFramework.services.timerService.delay.create(0, function()
				-- check group length
				if AuroraFramework.libraries.miscellaneous.getTableLength(group.properties.vehicles) >= 1 then
					return
				end

				-- no more vehicles remain in the group, so despawn it
				group:despawn()
			end)
		end)
	end,

	---@type table<integer, af_services_group_group>
	groups = {},

	events = {
		onSpawn = AuroraFramework.libraries.events.create("auroraFramework_onGroupSpawn"),
		onDespawn = AuroraFramework.libraries.events.create("auroraFramework_onGroupDespawn")
	},

	internal = {}
}

-- Give group data to a group
---@param group_id integer
---@param peer_id integer
---@param x number
---@param y number
---@param z number
---@param group_cost number
---@param vehicle_ids vehicle_ids|nil
AuroraFramework.services.groupService.internal.giveGroupData = function(group_id, peer_id, x, y, z, group_cost, vehicle_ids)
	-- ignore if already exists
	if AuroraFramework.services.groupService.getGroup(group_id) then
		return
	end

	-- set vehicle ids if not provided
	vehicle_ids = vehicle_ids or server.getVehicleGroup(group_id)

	-- save the group to g_savedata for when the addon is reloaded or a save is loaded
	local data = {
		group_id = group_id,
		peer_id = peer_id,
		x = x,
		y = y,
		z = z,
		group_cost = group_cost,
		vehicle_ids = vehicle_ids
	}

	g_savedata.AuroraFramework.groups[group_id] = data

	-- get player
	local player = AuroraFramework.services.playerService.getPlayerByPeerID(peer_id) -- doesnt matter if this is nil, because of the addonSpawned property

	-- create group
	---@type af_services_group_group
	local group = AuroraFramework.libraries.class.create(
		"group",

		{
			---@param self af_services_group_group
			---@param position SWMatrix
			teleport = function(self, position)
				server.setGroupPos(self.properties.group_id, position)
			end,

			---@param self af_services_group_group
			---@param position SWMatrix
			move = function(self, position)
				server.moveGroup(self.properties.group_id, position)
			end,

			---@param self af_services_group_group
			despawn = function(self)
				return AuroraFramework.services.groupService.despawnGroup(self.properties.group_id)
			end,

			---@param self af_services_group_group
			getPosition = function(self)
				return self.properties.primaryVehicle:getPosition()
			end,

			---@param self af_services_group_group
			---@param vehicle_id integer
			getVehicle = function(self, vehicle_id)
				return self.properties.vehicles[vehicle_id]
			end
		},

		{
			vehicles = {},
			owner = player,
			addonSpawned = peer_id == -1,
			cost = group_cost,
			group_id = group_id,
			spawnPos = matrix.translation(x, y, z),
			primaryVehicle = nil
		},

		nil
	)

	-- set up vehicles belonging to the group
	local vehicles = {}

	for _, vehicle_id in pairs(vehicle_ids) do
		-- get vehicle
		local vehicle = AuroraFramework.services.vehicleService.getVehicleByVehicleID(vehicle_id)

		if not vehicle then
			goto continue
		end

		-- set group attribute
		vehicle.properties.group_id = group.properties.group_id

		-- insert into vehicles table
		vehicles[vehicle_id] = vehicle

		::continue::
	end

	group.properties.vehicles = vehicles
	group.properties.primaryVehicle = AuroraFramework.services.groupService.internal.calculatePrimaryVehicle(group)
	group.properties.primaryVehicle.properties.isPrimaryVehicle = true

	-- parent group to groups in groupservice, then return group
	AuroraFramework.services.groupService.groups[group_id] = group
	return group
end

-- Calculate primary vehicle
---@param group af_services_group_group
---@return af_services_vehicle_vehicle
AuroraFramework.services.groupService.internal.calculatePrimaryVehicle = function(group)
	-- set variables
	local lowest = math.huge
	local primaryVehicle = nil

	-- find primary vehicle
	for _, vehicle in pairs(group.properties.vehicles) do
		-- the primary vehicle is the vehicle that spawns first
		-- as we know, the vehicle id of a vehicle is 1 higher than the previously spawned vehicle
		-- therefore the primary vehicle (first vehicle spawned) in this group is the vehicle with the lowest vehicle id in the group

		if vehicle.properties.vehicle_id <= lowest then
			primaryVehicle = vehicle
			lowest = vehicle.properties.vehicle_id
		end
	end

	-- return it
	return primaryVehicle
end

-- Remove group data
---@param group_id integer
AuroraFramework.services.groupService.internal.removeGroupData = function(group_id)
	-- remove the group from savedata
	g_savedata.AuroraFramework.groups[group_id] = nil

	-- remove the group from the framework
	AuroraFramework.services.groupService.groups[group_id] = nil
end

-- Spawn a group (server.spawnAddonVehicle behind the hood)
---@param position SWMatrix
---@param playlist_id integer
---@param addonIndex integer|nil
---@return af_services_group_group
AuroraFramework.services.groupService.spawnGroup = function(position, playlist_id, addonIndex)
	-- spawn the group
	local vehicle_id, successful, vehicle_ids = server.spawnAddonVehicle(position, addonIndex or AuroraFramework.attributes.AddonIndex, playlist_id)

	if not successful then
		return
	end

	-- get group id
	local data = server.getVehicleData(vehicle_id)

	if not data then
		return
	end

	local group_id = data.group_id

	-- setup vehicle data beforehand
	for _, vehicle_id in pairs(vehicle_ids) do
		AuroraFramework.services.vehicleService.internal.giveVehicleData(
			vehicle_id,
			-1,
			x, y, z,
			0,
			group_id
		)
	end

	-- setup group data
	local x, y, z = matrix.position(position)

	local group = AuroraFramework.services.groupService.internal.giveGroupData(
		group_id,
		-1,
		x, y, z,
		0,
		vehicle_ids
	)

	-- onGroupSpawn gets called, but since the group already exists, it ignores the group entirely, resulting in groupservice's onSpawn event not being fired. therefore, we must fire it ourselves
	AuroraFramework.services.groupService.events.onSpawn:fire(group)

	-- return the group
	return group
end

-- Get a group
---@param group_id integer
---@return af_services_group_group
AuroraFramework.services.groupService.getGroup = function(group_id)
	return AuroraFramework.services.groupService.groups[group_id]
end

-- Get all groups
AuroraFramework.services.groupService.getAllGroups = function()
	return AuroraFramework.services.groupService.groups
end

-- Get the amount of spawned and recognised groups
---@return integer
AuroraFramework.services.groupService.getGlobalGroupCount = function()
	return AuroraFramework.libraries.miscellaneous.getTableLength(AuroraFramework.services.groupService.groups)
end

-- Get a list of groups spawned by a player
---@param player af_services_player_player
---@return table<integer, af_services_group_group>
AuroraFramework.services.groupService.getAllGroupsSpawnedByAPlayer = function(player)
	local list = {}

	for _, group in pairs(AuroraFramework.services.groupService.groups) do
		if group.properties.addonSpawned then
			goto continue
		end

		if AuroraFramework.services.playerService.isSamePlayer(player, group.properties.owner) then
			table.insert(list, group)
		end

	    ::continue::
	end

	return list
end

-- Get the amount of vehicles spawned by a player
---@param player af_services_player_player
---@return integer
AuroraFramework.services.groupService.getGroupCountOfPlayer = function(player)
	return #AuroraFramework.services.groupService.getAllGroupsSpawnedByAPlayer(player)
end

-- Returns whether or not two groups are the same
---@param group1 af_services_group_group
---@param group2 af_services_group_group
---@return boolean
AuroraFramework.services.groupService.isSameGroup = function(group1, group2)
	return group1.properties.group_id == group2.properties.group_id
end

-- Despawn a group
---@param group_id integer
AuroraFramework.services.groupService.despawnGroup = function(group_id)
	-- get group
	local group = AuroraFramework.services.groupService.getGroup(group_id)

	if group then
		-- despawn all vehicles in the group to trigger events
		for _, vehicle in pairs(group.properties.vehicles) do
			vehicle:despawn()
		end

		-- fire events
		AuroraFramework.services.groupService.events.onDespawn:fire(group)
	end

	-- actually despawn the group
	server.despawnVehicleGroup(group_id, true)

	-- remove data
	AuroraFramework.services.groupService.internal.removeGroupData(group_id)
end

---------------- Vehicles
AuroraFramework.services.vehicleService = {
	initialize = function()
		-- Load vehicles from savedata
		for _, vehicle in pairs(g_savedata.AuroraFramework.vehicles) do
			AuroraFramework.services.vehicleService.internal.giveVehicleData(
				vehicle.vehicle_id,
				vehicle.peer_id,
				vehicle.x,
				vehicle.y,
				vehicle.z,
				vehicle.group_cost,
				vehicle.group_id
			)
		end

		-- Give vehicle data whenever a vehicle is spawned
		AuroraFramework.callbacks.onVehicleSpawn.internal:connect(function(...)
			-- give vehicle data
			local vehicle = AuroraFramework.services.vehicleService.internal.giveVehicleData(...)

			if not vehicle then
				return
			end

			-- fire events
			AuroraFramework.services.vehicleService.events.onSpawn:fire(vehicle)
		end)

		-- Update vehicle data on load
		AuroraFramework.callbacks.onVehicleLoad.internal:connect(function(vehicle_id)
			-- set vehicle loaded
			local vehicle = AuroraFramework.services.vehicleService.getVehicleByVehicleID(vehicle_id)

			if not vehicle then
				return
			end

			vehicle.properties.loaded = true

			-- fire events
			AuroraFramework.services.vehicleService.events.onLoad:fire(vehicle)
		end)

		-- Remove vehicle data whenever a vehicle is despawned
		AuroraFramework.callbacks.onVehicleDespawn.internal:connect(function(vehicle_id)
			AuroraFramework.services.timerService.delay.create(0, function() -- because of how stupid stormworks is, sometimes onvehicledespawn is called before onvehiclespawn if a vehicle is despawned right away, hence the delay
				-- fire events
				local vehicle = AuroraFramework.services.vehicleService.getVehicleByVehicleID(vehicle_id)

				if vehicle then
					AuroraFramework.services.vehicleService.events.onDespawn:fire(vehicle)
				end

				-- remove data
				AuroraFramework.services.vehicleService.internal.removeVehicleData(vehicle_id)
			end)
		end)
	end,

	---@type table<integer, af_services_vehicle_vehicle>
	vehicles = {},

	events = {
		onSpawn = AuroraFramework.libraries.events.create("auroraFramework_onVehicleSpawn"),
		onLoad = AuroraFramework.libraries.events.create("auroraFramework_onVehicleLoad"),
		onDespawn = AuroraFramework.libraries.events.create("auroraFramework_onVehicleDespawn")
	},

	internal = {}
}

-- Give vehicle data to a vehicle
---@param vehicle_id integer
---@param peer_id integer
---@param x number
---@param y number
---@param z number
---@param group_cost number
---@param group_id integer
---@return af_services_vehicle_vehicle
AuroraFramework.services.vehicleService.internal.giveVehicleData = function(vehicle_id, peer_id, x, y, z, group_cost, group_id)
	-- ignore if data already exists
	if AuroraFramework.services.vehicleService.getVehicleByVehicleID(vehicle_id) then
		return
	end

	-- save the vehicle to g_savedata for when the addon is reloaded or a save is loaded
	local data = {
		vehicle_id = vehicle_id,
		peer_id = peer_id,
		x = x,
		y = y,
		z = z,
		group_cost = group_cost,
		group_id = group_id
	}

	g_savedata.AuroraFramework.vehicles[vehicle_id] = data

	-- get player
	local player = AuroraFramework.services.playerService.getPlayerByPeerID(peer_id) -- doesnt matter if this is nil, because of the addonSpawned property

	-- create vehicle
	---@type af_services_vehicle_vehicle
	local vehicle = AuroraFramework.libraries.class.create(
		"vehicle",

		{
			---@param self af_services_vehicle_vehicle
			getGroup = function(self)
				return AuroraFramework.services.groupService.getGroup(self.properties.group_id)
			end,

			---@param self af_services_vehicle_vehicle
			despawn = function(self)
				AuroraFramework.services.vehicleService.despawnVehicle(self.properties.vehicle_id)
			end,

			---@param self af_services_vehicle_vehicle
			---@param magnitude number|nil
			---@param despawn boolean|nil
			explode = function(self, magnitude, despawn)
				if AuroraFramework.attributes.WeaponsEnabled then
					server.spawnExplosion(self:getPosition(), magnitude or 0.1)
				end

				if not despawn then
					return
				end

				self:despawn()
			end,

			---@param self af_services_vehicle_vehicle
    		---@param position SWMatrix
			move = function(self, position)
				server.moveVehicle(self.properties.vehicle_id, position)
			end,

			---@param self af_services_vehicle_vehicle
    		---@param position SWMatrix
			teleport = function(self, position)
				server.setVehiclePos(self.properties.vehicle_id, position)
			end,

			---@param self af_services_vehicle_vehicle
			repair = function(self)
				server.resetVehicleState(self.properties.vehicle_id)
			end,

			---@param self af_services_vehicle_vehicle
			---@param voxelX number|nil
			---@param voxelY number|nil
			---@param voxelZ number|nil
			getPosition = function(self, voxelX, voxelY, voxelZ)
				return (server.getVehiclePos(self.properties.vehicle_id, voxelX, voxelY, voxelZ)) -- in brackets to only get pos, not success
			end,

			---@param self af_services_vehicle_vehicle
			getVehicleData = function(self)
				return (server.getVehicleData(self.properties.vehicle_id))
			end,

			---@param self af_services_vehicle_vehicle
			getVehicleComponents = function(self)
				if not self.properties.loaded then
					return
				end

				return (server.getVehicleComponents(self.properties.vehicle_id))
			end,

			---@param self af_services_vehicle_vehicle
			---@param isInvulnerable boolean
			setInvulnerable = function(self, isInvulnerable)
				server.setVehicleInvulnerable(self.properties.vehicle_id, isInvulnerable)
			end,

			---@param self af_services_vehicle_vehicle
			---@param isEditable boolean
			setEditable = function(self, isEditable)
				server.setVehicleEditable(self.properties.vehicle_id, isEditable)
			end,

			---@param self af_services_vehicle_vehicle
			---@param isVisible boolean
			setMapVisibility = function(self, isVisible)
				server.setVehicleShowOnMap(self.properties.vehicle_id, isVisible)
			end,

			---@param self af_services_vehicle_vehicle
			---@param text string
			setTooltip = function(self, text)
				server.setVehicleTooltip(self.properties.vehicle_id, text)
			end
		},

		{
			owner = player,
			addonSpawned = peer_id == -1,
			vehicle_id = vehicle_id,
			spawnPos = matrix.translation(x, y, z),
			cost = group_cost,
			loaded = false,
			group_id = nil, -- gets set up by ongroupspawn in groupservice
			isPrimaryVehicle = false
		},

		nil,

		AuroraFramework.services.vehicleService.vehicles,
		vehicle_id
	)

	return vehicle
end

-- Remove vehicle data from a vehicle
---@param vehicle_id integer
AuroraFramework.services.vehicleService.internal.removeVehicleData = function(vehicle_id)
	-- remove vehicle from savedata
	g_savedata.AuroraFramework.vehicles[vehicle_id] = nil

	-- remove vehicle from framework
	AuroraFramework.services.vehicleService.vehicles[vehicle_id] = nil
end

-- Returns all recognised vehicles
---@return table<integer, af_services_vehicle_vehicle>
AuroraFramework.services.vehicleService.getAllVehicles = function()
	return AuroraFramework.services.vehicleService.vehicles
end

-- Get a vehicle by its ID
---@param vehicle_id integer
---@return af_services_vehicle_vehicle
AuroraFramework.services.vehicleService.getVehicleByVehicleID = function(vehicle_id)
	return AuroraFramework.services.vehicleService.vehicles[vehicle_id]
end

-- Get the amount of spawned and recognised vehicles
---@return integer
AuroraFramework.services.vehicleService.getGlobalVehicleCount = function()
	return AuroraFramework.libraries.miscellaneous.getTableLength(AuroraFramework.services.vehicleService.vehicles)
end

-- Get a list of vehicles spawned by a player
---@param player af_services_player_player
---@return table<integer, af_services_vehicle_vehicle>
AuroraFramework.services.vehicleService.getAllVehiclesSpawnedByAPlayer = function(player)
	local list = {}

	for _, vehicle in pairs(AuroraFramework.services.vehicleService.vehicles) do
		if vehicle.properties.addonSpawned then
			goto continue
		end

		if AuroraFramework.services.playerService.isSamePlayer(player, vehicle.properties.owner) then
			table.insert(list, vehicle)
		end

	    ::continue::
	end

	return list
end

-- Get the amount of vehicles spawned by a player
---@param player af_services_player_player
---@return integer
AuroraFramework.services.vehicleService.getVehicleCountOfPlayer = function(player)
	return #AuroraFramework.services.vehicleService.getAllVehiclesSpawnedByAPlayer(player)
end

-- Returns whether or not two vehicles are the same
---@param vehicle1 af_services_vehicle_vehicle
---@param vehicle2 af_services_vehicle_vehicle
---@return boolean
AuroraFramework.services.vehicleService.isSameVehicle = function(vehicle1, vehicle2)
	return vehicle1.properties.vehicle_id == vehicle2.properties.vehicle_id
end

-- Despawn a vehicle
---@param vehicle_id integer
AuroraFramework.services.vehicleService.despawnVehicle = function(vehicle_id)
	server.despawnVehicle(vehicle_id, true)
end

---------------- Notifications
AuroraFramework.services.notificationService = {
	notificationTypes = {
		newMission = 0,
		newMissionCritical = 1,
		failedMission = 2,
		failedMissionCritical = 3,
		completeMission = 4,
		networkConnect = 5,
		networkDisconnect = 6,
		networkInfo = 7,
		chatMessage = 8,
		star = 9,
		networkDisconnectCritical = 10,
		scienceFlask = 11
	}
}

-- Send a success notification
---@param title string "[Success] - title"
---@param message string
---@param player af_services_player_player|nil If nil, everyone will see the notification
AuroraFramework.services.notificationService.success = function(title, message, player)
	AuroraFramework.services.notificationService.custom(
		"[Success] "..title,
		message,
		AuroraFramework.services.notificationService.notificationTypes.completeMission,
		player
	)
end

-- Send a warning notification
---@param title string "[Warning] - title"
---@param message string
---@param player af_services_player_player|nil If nil, everyone will see the notification
AuroraFramework.services.notificationService.warning = function(title, message, player)
	AuroraFramework.services.notificationService.custom(
		"[Warning] "..title,
		message,
		AuroraFramework.services.notificationService.notificationTypes.newMissionCritical,
		player
	)
end

-- Send a failure notification
---@param title string "[Failure] - title"
---@param message string
---@param player af_services_player_player|nil If nil, everyone will see the notification
AuroraFramework.services.notificationService.failure = function(title, message, player)
	AuroraFramework.services.notificationService.custom(
		"[Failure] "..title,
		message,
		AuroraFramework.services.notificationService.notificationTypes.failedMissionCritical,
		player
	)
end

-- Send an info notification
---@param title string "[Info] - title"
---@param message string
---@param player af_services_player_player|nil If nil, everyone will see the notification
AuroraFramework.services.notificationService.info = function(title, message, player)
	AuroraFramework.services.notificationService.custom(
		"[Info] "..title,
		message,
		AuroraFramework.services.notificationService.notificationTypes.networkInfo,
		player
	)
end

-- Send a custom notification
---@param title string
---@param message string
---@param player af_services_player_player|nil If nil, everyone will see the notification
---@param notificationType SWNotifiationTypeEnum
AuroraFramework.services.notificationService.custom = function(title, message, notificationType, player)
	server.notify(
		AuroraFramework.libraries.miscellaneous.getPeerID(player),
		title,
		message,
		notificationType
	)
end

---------------- Players
AuroraFramework.services.playerService = {
	initialize = function()
		-- Load players that are currently in the server without calling events
		for _, player in pairs(server.getPlayers()) do
			-- check if the player is connecting and hasnt loaded (the infamous "unnamed client")
			if player.steam_id == 0 then
				return
			end

			-- give the player data
			local isRecognized = g_savedata.AuroraFramework.recognizedPeerIDs[player.id] -- givePlayerData autoamtically adds the player's peer id to the recognizedPeerIDs table, hence why we check it before giving the player data instead of after

			local playerData = AuroraFramework.services.playerService.internal.givePlayerData(
				player.steam_id,
				player.name,
				player.id,
				player.admin,
				player.auth
			)

			-- if the player's peer id isnt stored in g_savedata, that means they connected to the server for the first time, but the addon wasnt working when they joined. therefore, call the onJoin event
			if playerData and not isRecognized then
				AuroraFramework.services.playerService.events.onJoin:fire(playerData)
			end

			::continue::
		end

		-- Purge player persistence data
		g_savedata.AuroraFramework.recognizedPeerIDs = {}

		-- Give player data whenever a player joins
		AuroraFramework.callbacks.onPlayerJoin.internal:connect(function(...)
			-- give data and fire join event
			local player = AuroraFramework.services.playerService.internal.givePlayerData(...)

			if not player then -- errored somewhere or something
				return
			end

			AuroraFramework.services.playerService.events.onJoin:fire(player)
		end)

		-- Remove player data whenever a player leaves
		AuroraFramework.callbacks.onPlayerLeave.internal:connect(function(_, _, peer_id)
			-- fire leave event
			local player = AuroraFramework.services.playerService.getPlayerByPeerID(peer_id)

			if not player then
				return
			end

			AuroraFramework.services.playerService.events.onLeave:fire(player)

			-- remove player data
			AuroraFramework.services.playerService.internal.removePlayerData(peer_id)
		end)

		-- Die event
		AuroraFramework.callbacks.onPlayerDie.internal:connect(function(_, _, peer_id)
			local player = AuroraFramework.services.playerService.getPlayerByPeerID(peer_id)

			if not player then
				return
			end

			AuroraFramework.services.playerService.events.onDie:fire(player)
		end)

		-- Respawn event
		AuroraFramework.callbacks.onPlayerRespawn.internal:connect(function(peer_id)
			local player = AuroraFramework.services.playerService.getPlayerByPeerID(peer_id)

			if not player then
				return
			end

			AuroraFramework.services.playerService.events.onRespawn:fire(player)
		end)

		-- Update player properties
		AuroraFramework.callbacks.onTick.internal:connect(function()
			for _, player in pairs(server.getPlayers()) do
				-- player doesn't have data (usually means player is connecting, or the player is the server and dedicatedServer is set to true), so ignore
				if not AuroraFramework.services.playerService.getPlayerByPeerID(player.id) then -- don't update player data if there is none (usually means player is connecting, but hasnt connected fully)
					goto continue
				end

				-- update properties
				local data = AuroraFramework.services.playerService.players[player.id]
				data.properties.admin = player.admin
				data.properties.auth = player.auth

				::continue::
			end
		end)
	end,

	---@type table<integer, af_services_player_player>
	players = {},

	events = {
		onJoin = AuroraFramework.libraries.events.create("auroraFramework_onPlayerJoin"),
		onLeave = AuroraFramework.libraries.events.create("auroraFramework_onPlayerLeave"),
		onDie = AuroraFramework.libraries.events.create("auroraFramework_onPlayerDie"),
		onRespawn = AuroraFramework.libraries.events.create("auroraFramework_onPlayerRespawn")
	},

	internal = {},

	isDedicatedServer = false
}

-- Give player data to a player
---@param steam_id integer|string
---@param name string
---@param peer_id integer
---@param admin boolean
---@param auth boolean
AuroraFramework.services.playerService.internal.givePlayerData = function(steam_id, name, peer_id, admin, auth)
	-- check if the player already exists
	if AuroraFramework.services.playerService.getPlayerByPeerID(peer_id) then
		return
	end

	-- check if the player is the server itself in a dedicated server
	if tonumber(steam_id) == 0 and AuroraFramework.services.playerService.isDedicatedServer then
		return
	end

	-- check if the player is the host player
	local isHost = peer_id == 0

	-- store the player's peer id in g_savedata to prevent onJoin being called for this player after an addon reload
	g_savedata.AuroraFramework.recognizedPeerIDs[peer_id] = true

	-- create player class
	---@type af_services_player_player
	local player = AuroraFramework.libraries.class.create(
		"player",

		{
			---@param self af_services_player_player
			---@param audioMood SWAudioMoodEnum
			setAudioMood = function(self, audioMood)
				server.setAudioMood(self.properties.peer_id, audioMood)
			end,

			---@param self af_services_player_player
			---@param slot SWSlotNumberEnum
			---@param type SWEquipmentTypeEnum
			---@param active boolean|nil
			---@param int integer|nil
			---@param float number|nil
			setItem = function(self, slot, to, active, int, float)
				server.setCharacterItem(self:getCharacter(), slot, to, active or false, int or 0, float) ---@diagnostic disable-line
			end,

			---@param self af_services_player_player
    		---@param slot SWSlotNumberEnum
			removeItem = function(self, slot)
				server.setCharacterItem(self:getCharacter(), slot, 0, false)
			end,

			---@param self af_services_player_player
    		---@param slot SWSlotNumberEnum
			getItem = function(self, slot)
				return server.getCharacterItem(self:getCharacter(), slot) ---@diagnostic disable-line
			end,

			---@param self af_services_player_player
			kick = function(self)
				server.kickPlayer(self.properties.peer_id)
			end,

			---@param self af_services_player_player
			ban = function(self)
				server.banPlayer(self.properties.peer_id)
			end,

			---@param self af_services_player_player
			---@param position SWMatrix
			teleport = function(self, position)
				server.setPlayerPos(self.properties.peer_id, position)
			end,

			---@param self af_services_player_player
			getPosition = function(self)
				return (server.getPlayerPos(self.properties.peer_id)) -- in brackets to only get pos, not success
			end,

			---@param self af_services_player_player
			getCharacter = function(self)
				return (server.getPlayerCharacterID(self.properties.peer_id))
			end,

			---@param self af_services_player_player
			getCharacterData = function(self)
				-- get the player's character
				local character = self:getCharacter()

				if not character then
					return
				end

				-- get the player's character data and return it
				return server.getCharacterData(character)
			end,

			---@param self af_services_player_player
			---@param damageToDeal number
			damage = function(self, damageToDeal)
				-- get the player's character
				local character = self:getCharacter()

				if not character then
					return
				end

				-- get the player's character data
				local data = server.getCharacterData(character)

				if not data then
					return
				end

				-- deal damage
				return server.setCharacterData(character, data.hp - damageToDeal, data.interactible, data.ai)
			end,

			---@param self af_services_player_player
			kill = function(self)
				local character = self:getCharacter()

				if not character then
					return
				end

				server.killCharacter(character)
			end,

			---@param self af_services_player_player
			revive = function(self)
				local character = self:getCharacter()

				if not character then
					return
				end

				server.reviveCharacter(character)
			end,

			---@param self af_services_player_player
			---@param shouldGive boolean
			setAdmin = function(selfshouldGive, give)
				if shouldGive then
					server.addAdmin(self.properties.peer_id)
				else
					server.removeAdmin(self.properties.peer_id)
				end
			end,

			---@param self af_services_player_player
			---@param shouldGive boolean
			setAuth = function(self, shouldGive)
				if shouldGive then
					server.addAuth(self.properties.peer_id)
				else
					server.removeAuth(self.properties.peer_id)
				end
			end
		},

		{
			steam_id = tostring(steam_id),
			name = name,
			peer_id = peer_id,
			admin = admin,
			auth = auth,
			isHost = isHost
		},

		nil,

		AuroraFramework.services.playerService.players,
		peer_id
	)

	return player
end

-- Remove player data from a player
---@param peer_id integer
AuroraFramework.services.playerService.internal.removePlayerData = function(peer_id)
	AuroraFramework.services.playerService.players[peer_id] = nil
	g_savedata.AuroraFramework.recognizedPeerIDs[peer_id] = nil
end

-- Returns all recognised players
AuroraFramework.services.playerService.getAllPlayers = function()
	return AuroraFramework.services.playerService.players
end

-- Sets whether or not this addon is being used in a dedicated server. If set to true, the host (the server itself) will not be considered a player. This cannot be reversed
---@param isDedicatedServer boolean
AuroraFramework.services.playerService.setDedicatedServer = function(isDedicatedServer)
	AuroraFramework.services.playerService.isDedicatedServer = isDedicatedServer

	if isDedicatedServer then
		AuroraFramework.services.playerService.internal.removePlayerData(0)
	end
end

-- Returns whether or not two players are the same
---@param player1 af_services_player_player
---@param player2 af_services_player_player
AuroraFramework.services.playerService.isSamePlayer = function(player1, player2)
	return player1.properties.peer_id == player2.properties.peer_id
end

-- Get a player by their peer ID
---@param peer_id integer
AuroraFramework.services.playerService.getPlayerByPeerID = function(peer_id)
	return AuroraFramework.services.playerService.players[peer_id]
end

-- Get a player by their Steam ID
---@param steam_id string|integer
AuroraFramework.services.playerService.getPlayerBySteamID = function(steam_id)
	steam_id = tostring(steam_id)

	for _, player in pairs(AuroraFramework.services.playerService.players) do
		if player.properties.steam_id == steam_id then
			return player
		end
	end
end

-- Get a player by their character's object ID
---@param object_id integer
AuroraFramework.services.playerService.getPlayerByObjectID = function(object_id)
	for _, player in pairs(AuroraFramework.services.playerService.players) do
		if player:getCharacter() == object_id then
			return player
		end
	end
end

-- Get a player by name, partial or not
---@param name string
AuroraFramework.services.playerService.getPlayerByNameSearch = function(name)
	for _, player in pairs(AuroraFramework.services.playerService.players) do
		if player.properties.name:lower():find(name:lower()) then
			return player
		end
	end
end

-- Get a player by their exact name
---@param name string
AuroraFramework.services.playerService.getPlayerByName = function(name)
	for _, player in pairs(AuroraFramework.services.playerService.players) do
		if player.properties.name == name then
			return player
		end
	end
end

---------------- HTTP
AuroraFramework.services.HTTPService = {
	initialize = function()
		---@param port integer
		---@param url string
		---@param response string
		AuroraFramework.callbacks.httpReply.internal:connect(function(port, url, response)
			-- get the request
			local data = AuroraFramework.services.HTTPService.ongoingRequests[port.."|"..url]

			-- doesn't exist, so ignore
			if not data then
				return
			end

			-- handle the request
			data.events.reply:fire(tostring(response), AuroraFramework.services.HTTPService.ok(response)) -- reply callback
			data:cancel() -- remove the request
		end)
	end,

	---@type table<string, af_services_http_request>
	ongoingRequests = {},

	-- Encodes anything into a JSON string. Useful for encoding data ready to be passed through a HTTP request
	-- Source: https://gist.github.com/tylerneylon/59f4bcf316be525b30ab
	JSON = {},

	-- Encodes a string into a Base64 string. Useful for encoding JSON strings in a URL
	-- Source: https://gist.github.com/To0fan/ca3ebb9c029bb5df381e4afc4d27b4a6
	Base64 = {
		conversion = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	},

	internal = {}
}

-- Send a HTTP request
---@param port integer
---@param url string
---@param callback fun(response: string, successful: boolean)|nil
---@return af_services_http_request
AuroraFramework.services.HTTPService.request = function(port, url, callback)
	-- check if a request has already been made
	local ongoingRequest = AuroraFramework.services.HTTPService.ongoingRequests[port.."|"..url]

	if ongoingRequest then -- a request has already been made to the same port and url, so we simply stop here
		return
	end

	-- create a http request
	---@type af_services_http_request
	local httpRequest = AuroraFramework.libraries.class.create(
		"HTTPRequest",

		{
			---@param self af_services_http_request
			cancel = function(self)
				AuroraFramework.services.HTTPService.cancel(self.properties.port, self.properties.url)
			end
		},

		{
			port = port,
			url = url,
			event = AuroraFramework.libraries.events.create("auroraFramework_HTTPRequest_"..port.."|"..url)
		},

		{
			reply = AuroraFramework.libraries.events.create("auroraFramework_HTTPRequest_"..port.."|"..url)
		},

		AuroraFramework.services.HTTPService.ongoingRequests,
		port.."|"..url
	)

	-- connect callback to reply event
	if callback then
		httpRequest.events.reply:connect(callback) -- attach callback to reply event
	end

	-- send http request
	server.httpGet(port, url)

	-- return http request class
	return httpRequest
end

-- Convert a table of args into URL parameters
---@param url string
---@param ... af_services_http_urlarg
AuroraFramework.services.HTTPService.URLArgs = function(url, ...)
	-- convert provided parameters to a table
	local args = {}
	local packed = {...}

	-- go through each argument
	for index, URLArg in pairs(packed) do
		-- check if the argument is valid
		if URLArg.name == nil or URLArg.value == nil then
			goto continue
		end

		-- http encode the name and value
		URLArg.name = AuroraFramework.services.HTTPService.URLEncode(URLArg.name)
		URLArg.value = AuroraFramework.services.HTTPService.URLEncode(URLArg.value)

		-- format into url
		if index == 1 then
			-- first argument, so index with "?"
			table.insert(args, "?"..URLArg.name.."="..URLArg.value)
		else
			-- all other arguments, so index with "&"
			table.insert(args, "&"..URLArg.name.."="..URLArg.value)
		end

		::continue::
	end

	-- anddd return
	return url..table.concat(args)
end

-- URL encode a string
---@param input string
AuroraFramework.services.HTTPService.URLEncode = function(input)
	local inputType = type(input)

	if inputType == "boolean" then
		return tostring(input)
	end

	if inputType ~= "string" or tonumber(input) then -- dont url encode numbers/non-strings
		return input
	end

	input = string.gsub(input, "\n", "\r\n")
    input = string.gsub(input, "([^%w %-%_%.%~])",
        function(c)
			return string.format("%%%02X", string.byte(c))
		end)
	input = string.gsub(input, " ", "+")

	return input
end

-- URL decode a string
---@param input string
AuroraFramework.services.HTTPService.URLDecode = function(input)
	input = string.gsub(input, "+", " ")
	input = string.gsub(input, "%%(%x%x)",
		function (hex)
			return string.char(tonumber(hex, 16))
		end
	)

	input = string.gsub(input, "\r\n", "\n")

	return input
end

-- Returns whether or not a response is ok
---@param response string
AuroraFramework.services.HTTPService.ok = function(response)
	local notOk = {
        ["Connection closed unexpectedly"] = true,
        ["connect(): Connection refused"] = true,
        ["recv(): Connection reset by peer"] = true,
        ["timeout"] = true
    }

    return notOk[response] == nil
end

-- Cancel a request
---@param port integer
---@param url string
AuroraFramework.services.HTTPService.cancel = function(port, url)
	AuroraFramework.services.HTTPService.ongoingRequests[port.."|"..url] = nil
end

-- Convert a string to a Base64 String
---@param data string
---@return string
AuroraFramework.services.HTTPService.Base64.encode = function(data)
	return ((data:gsub('.', function(x)
		local r, b = '', x:byte()
		for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0') end
		return r;
	end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then return '' end
		local c = 0
		for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) end
		return AuroraFramework.services.HTTPService.Base64.conversion:sub(c + 1, c + 1)
	end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

-- Translate a Base64 String to its original form
---@param data string
---@return string
AuroraFramework.services.HTTPService.Base64.decode = function(data)
	data = string.gsub(data, '[^' .. AuroraFramework.services.HTTPService.Base64.conversion .. '=]', '')
	return (data:gsub('.', function(x)
		if (x == '=') then return '' end
		local r, f = '', (AuroraFramework.services.HTTPService.Base64.conversion:find(x) - 1)
		for i = 6, 1, -1 do r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0') end
		return r;
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if (#x ~= 8) then return '' end
		local c = 0
		for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0) end
		return string.char(c)
	end))
end

AuroraFramework.services.HTTPService.JSON.kind_of = function(obj)
	if type(obj) ~= "table" then return type(obj) end
	local i = 1
	for _ in pairs(obj) do
		if obj[i] ~= nil then
			i = i + 1
		else
			return 'table'
		end
	end
	if i == 1 then
		return 'table'
	else
		return 'array'
	end
end

AuroraFramework.services.HTTPService.JSON.escape_str = function(s)
	local in_char = { '\\', '"', '/', '\b', '\f', '\n', '\r', '\t' }
	local out_char = { '\\', '"', '/', 'b', 'f', 'n', 'r', 't' }
	for i, c in ipairs(in_char) do s = s:gsub(c, '\\' .. out_char[i]) end
	return s
end

AuroraFramework.services.HTTPService.JSON.skip_delim = function(str, pos, delim)
	pos = pos + #str:match('^%s*', pos)
	if str:sub(pos, pos) ~= delim then
		return pos, false
	end
	return pos + 1, true
end

AuroraFramework.services.HTTPService.JSON.parse_str_val = function(str, pos, val)
	val = val or ''
	if pos > #str then return end
	local c = str:sub(pos, pos)
	if c == '"' then return val, pos + 1 end
	if c ~= '\\' then return AuroraFramework.services.HTTPService.JSON.parse_str_val(str, pos + 1, val .. c) end
	-- We must have a \ character.
	local esc_map = { b = '\b', f = '\f', n = '\n', r = '\r', t = '\t' }
	local nextc = str:sub(pos + 1, pos + 1)
	if not nextc then return end
	return AuroraFramework.services.HTTPService.JSON.parse_str_val(str, pos + 2, val .. (esc_map[nextc] or nextc))
end

AuroraFramework.services.HTTPService.JSON.parse_num_val = function(str, pos)
	local num_str = str:match('^-?%d+%.?%d*[eE]?[+-]?%d*', pos)
	local val = tonumber(num_str)
	if not val then return end
	return val, pos + #num_str
end

-- Encode a Lua object into a JSON string
---@param obj any The data to encode
---@param as_key boolean|nil
---@return string
AuroraFramework.services.HTTPService.JSON.encode = function(obj, as_key)
	local s = {}           -- We'll build the string as an array of strings to be concatenated.
	local kind = AuroraFramework.services.HTTPService.JSON.kind_of(obj) -- This is 'array' if it's an array or type(obj) otherwise.

	if kind == 'array' then
		if as_key then
			return
		end

		s[#s + 1] = '['

		for i, val in ipairs(obj) do
			if i > 1 then s[#s + 1] = ',' end
			s[#s + 1] = AuroraFramework.services.HTTPService.JSON.encode(val)
		end

		s[#s + 1] = ']'
	elseif kind == 'table' then
		if as_key then
			return
		end

		s[#s + 1] = '{'

		for k, v in pairs(obj) do
			if #s > 1 then s[#s + 1] = ',' end
			s[#s + 1] = AuroraFramework.services.HTTPService.JSON.encode(k, true)
			s[#s + 1] = ':'
			s[#s + 1] = AuroraFramework.services.HTTPService.JSON.encode(v)
		end

		s[#s + 1] = '}'
	elseif kind == 'string' then
		return '"' .. AuroraFramework.services.HTTPService.JSON.escape_str(obj) .. '"'
	elseif kind == 'number' then
		if as_key then return '"' .. tostring(obj) .. '"' end
		return tostring(obj)
	elseif kind == 'boolean' then
		return tostring(obj)
	elseif kind == 'nil' then
		return 'null'
	else
		return
	end

	return table.concat(s)
end

-- Decode a JSON string into a Lua object
---@param str string
---@param pos number|nil
---@param end_delim string|nil
---@return any, number
AuroraFramework.services.HTTPService.JSON.decode = function(str, pos, end_delim)
	pos = pos or 1

	if pos > #str then
		return nil
	end

	local pos = pos + #str:match('^%s*', pos) -- Skip whitespace.
	local first = str:sub(pos, pos)

	if first == '{' then                   -- Parse an object.
		local obj, key, delim_found = {}, true, true
		pos = pos + 1

		while true do
			key, pos = AuroraFramework.services.HTTPService.JSON.decode(str, pos, '}')
			if key == nil then return obj, pos end
			if not delim_found then return nil end
			pos = AuroraFramework.services.HTTPService.JSON.skip_delim(str, pos, ':')
			obj[key], pos = AuroraFramework.services.HTTPService.JSON.decode(str, pos)
			pos, delim_found = AuroraFramework.services.HTTPService.JSON.skip_delim(str, pos, ',')
		end
	elseif first == '[' then -- Parse an array.
		local arr, val, delim_found = {}, true, true
		pos = pos + 1

		while true do
			val, pos = AuroraFramework.services.HTTPService.JSON.decode(str, pos, ']')
			if val == nil then return arr, pos end
			if not delim_found then return nil end
			arr[#arr + 1] = val
			pos, delim_found = AuroraFramework.services.HTTPService.JSON.skip_delim(str, pos, ',')
		end
	elseif first == '"' then                   -- Parse a string.
		return AuroraFramework.services.HTTPService.JSON.parse_str_val(str, pos + 1)
	elseif first == '-' or first:match('%d') then -- Parse a number.
		return AuroraFramework.services.HTTPService.JSON.parse_num_val(str, pos)
	elseif first == end_delim then             -- End of an object or array.
		return nil, pos + 1
	else                                       -- Parse true, false, or null.
		local literals = {
			['true'] = true,
			['false'] = false,
			['null'] = "nil"
		}

		for lit_str, lit_val in pairs(literals) do
			local lit_end = pos + #lit_str - 1
			if str:sub(pos, lit_end) == lit_str then
				if lit_str == "null" then
					return nil, lit_end + 1
				end

				return lit_val, lit_end + 1
			end
		end

		str:sub(pos, pos + 10)
		return nil
	end
end

---------------- Chat
AuroraFramework.services.chatService = {
	initialize = function()
		AuroraFramework.callbacks.onChatMessage.internal:connect(function(peer_id, _, content)
			AuroraFramework.services.timerService.delay.create(0.01, function() -- just so if the addon deletes the message, shit wont be fucked up (onchatmessage is fired before message is shown in chat)
				-- get player
				local player = AuroraFramework.services.playerService.getPlayerByPeerID(peer_id)

				if not player then
					return
				end

				-- construct message
				local message = AuroraFramework.services.chatService.internal.construct(player, content)

				-- enforce message limit
				if #AuroraFramework.services.chatService.messages > AuroraFramework.services.chatService.messageLimit then
					table.remove(AuroraFramework.services.chatService.messages, 1)
				end

				-- save the message
				table.insert(AuroraFramework.services.chatService.messages, message)

				-- fire event
				AuroraFramework.services.chatService.events.onMessageSent:fire(message)
			end)
		end)
	end,

	events = {
		onMessageSent = AuroraFramework.libraries.events.create("auroraFramework_onMessageSent"), -- message
		onMessageDeleted = AuroraFramework.libraries.events.create("auroraFramework_onMessageDeleted"), -- message, player|nil
		onMessageEdited = AuroraFramework.libraries.events.create("auroraFramework_onMessageEdited") -- message, player|nil
	},

	---@type table<integer, af_services_chat_message>
	messages = {},
	messageLimit = 129, -- max of 129, since thats all the chat window can contain

	internal = {
		message_id = 0
	}
}

-- Construct a message
---@param author af_services_player_player
---@param messageContent string
---@return af_services_chat_message
AuroraFramework.services.chatService.internal.construct = function(author, messageContent)
	AuroraFramework.services.chatService.internal.message_id = AuroraFramework.services.chatService.internal.message_id + 1

	---@type af_services_chat_message
	local message = AuroraFramework.libraries.class.create(
		"chatMessage",

		{
			---@param self af_services_chat_message
			---@param player af_services_player_player
			delete = function(self, player)
				return AuroraFramework.services.chatService.deleteMessage(self, player)
			end,

			---@param self af_services_chat_message
			---@param newContent string
			---@param player af_services_player_player
			edit = function(self, newContent, player)
				return AuroraFramework.services.chatService.editMessage(self, newContent, player)
			end
		},

		{
			author = author,
			content = messageContent,
			id = AuroraFramework.services.chatService.internal.message_id
		}
	)

	return message
end

-- Get all messages sent by a player
---@param player af_services_player_player
---@return table<integer, af_services_chat_message>
AuroraFramework.services.chatService.getAllMessagesSentByAPlayer = function(player)
	local list = {}

	for _, message in pairs(AuroraFramework.services.chatService.messages) do
		if AuroraFramework.services.playerService.isSamePlayer(message.properties.author, player) then
			table.insert(list, message)
		end
	end

	return list
end

-- Get the latest message
AuroraFramework.services.chatService.getLatestMessage = function()
	return AuroraFramework.services.chatService.messages[#AuroraFramework.services.chatService.messages]
end

-- Get the oldest message
AuroraFramework.services.chatService.getOldestMessage = function()
	return AuroraFramework.services.chatService.messages[1]
end

-- Edit a message
---@param message af_services_chat_message
---@param newContent string
---@param player af_services_player_player|nil If player, the message will be edited for the player, else, everyone
AuroraFramework.services.chatService.editMessage = function(message, newContent, player)
	-- edit message
	message.properties.content = newContent

	-- clear chat
	AuroraFramework.services.chatService.clear(player)

	-- resend messages
	for i, msg in pairs(AuroraFramework.services.chatService.messages) do
		-- save edited message
		if AuroraFramework.services.chatService.isSameMessage(msg, message) then
			AuroraFramework.services.chatService.messages[i] = message
		end

		-- resend
		AuroraFramework.services.chatService.sendMessage(msg.properties.author.properties.name, msg.properties.content, player)
	end

	-- fire event
	AuroraFramework.services.chatService.events.onMessageEdited:fire(message, player)
end

-- Delete a message
---@param message af_services_chat_message
---@param player af_services_player_player|nil If player, the message will be deleted for the player, else, everyone
AuroraFramework.services.chatService.deleteMessage = function(message, player)
	-- clear chat
	AuroraFramework.services.chatService.clear(player)

	-- resend messages
	for i, msg in pairs(AuroraFramework.services.chatService.messages) do
		-- delete message
		if AuroraFramework.services.chatService.isSameMessage(msg, message) then
			AuroraFramework.services.chatService.messages[i] = nil
			goto continue -- prevent sending the deleted message
		end

		-- resend
		AuroraFramework.services.chatService.sendMessage(msg.properties.author.properties.name, msg.properties.content, player)

		-- next message
	    ::continue::
	end

	-- fire event
	AuroraFramework.services.chatService.events.onMessageDeleted:fire(message, player)
end

-- Whether or not both messages are the same
---@param message1 af_services_chat_message
---@param message2 af_services_chat_message
---@return boolean
AuroraFramework.services.chatService.isSameMessage = function(message1, message2)
	return message1.properties.id == message2.properties.id
end

-- Send a message to everyone/a player
---@param author string
---@param message string
---@param player af_services_player_player|nil
AuroraFramework.services.chatService.sendMessage = function(author, message, player)
	server.announce(tostring(author), tostring(message), AuroraFramework.libraries.miscellaneous.getPeerID(player))
end

-- Clear chat for everyone/a player
---@param player af_services_player_player|nil
AuroraFramework.services.chatService.clear = function(player)
	for _ = 1, AuroraFramework.services.chatService.messageLimit do
		AuroraFramework.services.chatService.sendMessage(" ", " ", player)
	end
end

---------------- Commands
AuroraFramework.services.commandService = {
	initialize = function()
		-- handle commands
		AuroraFramework.callbacks.onCustomCommand.internal:connect(function(message, peer_id, admin, auth, command, ...)
			-- get variables n stuff
			local player = AuroraFramework.services.playerService.getPlayerByPeerID(peer_id)

			if not player then
				return
			end

			local args = {...}
			command = command:sub(2)

			-- go through all commands
			for _, cmd in pairs(AuroraFramework.services.commandService.commands) do
				-- check admin permissions
				if cmd.properties.requiresAdmin and not admin then
					goto continue
				end

				-- check auth permissions
				if cmd.properties.requiresAuth and not auth then
					goto continue
				end

				-- command name pattern matching
				if cmd.properties.capsSensitive then
					-- caps sensitive
					if cmd.properties.name ~= command and not AuroraFramework.libraries.miscellaneous.isValueInTable(command, cmd.properties.shorthands) then
						goto continue
					end
				else
					-- not caps sensitive
					if cmd.properties.name:lower() ~= command:lower() and not AuroraFramework.libraries.miscellaneous.isValueInTable(command:lower(), AuroraFramework.libraries.miscellaneous.lowerStringValuesInTable(cmd.properties.shorthands)) then
						goto continue
					end
				end

				-- command found, so fire events
				cmd.events.activation:fire(player, cmd, args)
				AuroraFramework.services.commandService.events.commandActivated:fire(player, cmd, args)

				-- continue
			    ::continue::
			end
		end)
	end,

	---@type table<string, af_services_command_command>
	commands = {},
	events = {
		commandActivated = AuroraFramework.libraries.events.create("auroraFramework_commandActivated") -- command, args, player
	},

	internal = {}
}

-- Create a command
---@param callback fun(command: af_services_command_command, args: table<integer, string>, player: af_services_player_player)
---@param name string
---@param shorthands table<integer, string>|nil
---@param capsSensitive boolean|nil
---@param description string|nil
---@param requiresAuth boolean|nil
---@param requiresAdmin boolean|nil
AuroraFramework.services.commandService.create = function(callback, name, shorthands, capsSensitive, description, requiresAuth, requiresAdmin)
	-- create the command
	---@type af_services_command_command
	local command = AuroraFramework.libraries.class.create(
		"command",

		{
			---@param self af_services_command_command
			remove = function(self)
				return AuroraFramework.services.commandService.remove(self.properties.name)
			end,

			---@param self af_services_command_command
			---@param message string
			---@param player af_services_player_player
			successNotification = function(self, message, player)
				AuroraFramework.services.notificationService.success(
					"Command",
					message,
					player
				)
			end,

			---@param self af_services_command_command
			---@param message string
			---@param player af_services_player_player
			warningNotification = function(self, message, player)
				AuroraFramework.services.notificationService.warning(
					"Command",
					message,
					player
				)
			end,

			---@param self af_services_command_command
			---@param message string
			---@param player af_services_player_player
			failureNotification = function(self, message, player)
				AuroraFramework.services.notificationService.failure(
					"Command",
					message,
					player
				)
			end,

			---@param self af_services_command_command
			---@param message string
			---@param player af_services_player_player
			infoNotification = function(self, message, player)
				AuroraFramework.services.notificationService.info(
					"Command",
					message,
					player
				)
			end
		},

		{
			name = name,
			requiresAdmin = requiresAdmin or false,
			requiresAuth = requiresAuth or false,
			description = description or "",
			shorthands = shorthands or {},
			capsSensitive = capsSensitive or false
		},

		{
			activation = AuroraFramework.libraries.events.create("commandService_command_"..name.."_activation"),
		},

		AuroraFramework.services.commandService.commands,
		name
	)

	-- attach callback
	command.events.activation:connect(callback)

	-- return
	return command
end

-- Remove a command
---@param name string
AuroraFramework.services.commandService.remove = function(name)
	AuroraFramework.services.commandService.commands[name] = nil
end

---------------- UI
AuroraFramework.services.UIService = {
	initialize = function()
		-- load map objects
		for _, mapObject in pairs(g_savedata.AuroraFramework.UI.mapObjects) do
			-- get the player, or nil if the ui is for everyone
			local player = AuroraFramework.services.playerService.getPlayerByPeerID(mapObject.peer_id)

			-- if the player the ui was made for isnt in the server, don't create it
			if not player and mapObject.peer_id ~= -1 then
				return
			end

			-- make the ui
			local ui = AuroraFramework.services.UIService.createMapObject(
				mapObject.name,
				mapObject.title,
				mapObject.subtitle,
				mapObject.pos,
				mapObject.markerType,
				player,
				mapObject.radius,
				mapObject.r,
				mapObject.g,
				mapObject.b,
				mapObject.a,
				mapObject.id
			)

			-- update properties
			ui.properties.visible = mapObject.visible
			ui:attach(mapObject.positionType, mapObject.attachID) -- automatically refreshes ui
		end

		-- load map lines
		for _, mapLine in pairs(g_savedata.AuroraFramework.UI.mapLines) do
			-- get the player, or nil if the ui is for everyone
			local player = AuroraFramework.services.playerService.getPlayerByPeerID(mapLine.peer_id)

			-- if the player the ui was made for isnt in the server, don't create it
			if not player and mapLine.peer_id ~= -1 then
				return
			end

			-- make the ui
			local ui = AuroraFramework.services.UIService.createMapLine(
				mapLine.name,
				mapLine.startPoint,
				mapLine.endPoint,
				mapLine.thickness,
				player,
				mapLine.r,
				mapLine.g,
				mapLine.b,
				mapLine.a,
				mapLine.id
			)

			-- update properties
			ui.properties.visible = mapLine.visible
			ui:refresh()
		end

		-- load screen ui
		for _, screenUI in pairs(g_savedata.AuroraFramework.UI.screen) do
			-- get the player, or nil if the ui is for everyone
			local player = AuroraFramework.services.playerService.getPlayerByPeerID(screenUI.peer_id)

			-- if the player the ui was made for isnt in the server, don't create it
			if not player and screenUI.peer_id ~= -1 then
				return
			end

			-- make the ui
			local ui = AuroraFramework.services.UIService.createScreenUI(
				screenUI.name,
				screenUI.text,
				screenUI.x,
				screenUI.y,
				player,
				screenUI.id
			)

			-- update properties
			ui.properties.visible = screenUI.visible
			ui:refresh()
		end

		-- load map labels
		for _, mapLabel in pairs(g_savedata.AuroraFramework.UI.mapLabels) do
			-- get the player, or nil if the ui is for everyone
			local player = AuroraFramework.services.playerService.getPlayerByPeerID(mapLabel.peer_id)

			-- if the player the ui was made for isnt in the server, don't create it
			if not player and mapLabel.peer_id ~= -1 then
				return
			end

			-- make the ui
			local ui = AuroraFramework.services.UIService.createMapLabel(
				mapLabel.name,
				mapLabel.text,
				mapLabel.pos,
				mapLabel.labelType,
				player,
				mapLabel.id
			)

			-- update properties
			ui.properties.visible = mapLabel.visible
			ui:refresh()
		end

		-- show ui on join
		AuroraFramework.services.playerService.events.onJoin:connect(function(player) ---@param player af_services_player_player
			-- show all ui
			for _, uiContainers in pairs(AuroraFramework.services.UIService.UI) do
				for _, ui in pairs(uiContainers) do
					if not ui.properties.player then -- since the player who joined has a new peer id, they will never be the target of an ui object, so no point in checking
						-- show to all
						ui:refresh()
					end
				end
			end
		end)

		-- remove ui on leave
		AuroraFramework.services.playerService.events.onLeave:connect(function(player) ---@param player af_services_player_player
			for _, uiContainers in pairs(AuroraFramework.services.UIService.UI) do
				for _, ui in pairs(uiContainers) do
					if ui.properties.player and AuroraFramework.services.playerService.isSamePlayer(ui.properties.player, player) then
						-- remove since this ui is only being shown for this player
						ui:remove()
					end
				end
			end
		end)
	end,

	UI = {
		---@type table<string, af_services_ui_screen>
		screen = {},

		---@type table<string, af_services_ui_map_label>
		mapLabels = {},

		---@type table<string, af_services_ui_map_object>
		mapObjects = {},

		---@type table<string, af_services_ui_map_line>
		mapLines = {}
	},

	internal = {}
}

-- Mix UI name with player peer ID to prevent UI duplicates
---@param name string
---@param player af_services_player_player|nil
AuroraFramework.services.UIService.name = function(name, player)
	if not player then
		return name
	end

	return name..player.properties.peer_id
end

-- Create a Screen UI object
---@param name string
---@param text string
---@param x number
---@param y number
---@param player af_services_player_player|nil
---@param custom_id integer|nil
---@return af_services_ui_screen
AuroraFramework.services.UIService.createScreenUI = function(name, text, x, y, player, custom_id)
	-- Get ID
	local id = custom_id or server.getMapID()

	-- If UI with the same name exists, use the ID from it and overwrite the UI entirely
	local alreadyExistingUI = AuroraFramework.services.UIService.getScreenUI(name)

	if alreadyExistingUI then
		id = alreadyExistingUI.properties.id
		alreadyExistingUI:remove()
	end

	-- Create UI
	---@type af_services_ui_screen
	local ui = AuroraFramework.libraries.class.create(
		"UIScreen",

		{
			---@param self af_services_ui_screen
			refresh = function(self)
				self:updateSaveData()

				local peerID = AuroraFramework.libraries.miscellaneous.getPeerID(self.properties.player)
				server.setPopupScreen(peerID, self.properties.id, "", self.properties.visible, self.properties.text, self.properties.x, self.properties.y)
			end,

			---@param self af_services_ui_screen
			remove = function(self)
				return AuroraFramework.services.UIService.removeScreenUI(self.properties.name)
			end,

			---@param self af_services_ui_screen
			updateSaveData = function(self)
				if not AuroraFramework.services.UIService.getScreenUI(self.properties.name) then
					g_savedata.AuroraFramework.UI.screen[self.properties.name] = nil
					return
				end

				g_savedata.AuroraFramework.UI.screen[self.properties.name] = {
					name = self.properties.name,
					id = self.properties.id,
					x = self.properties.x,
					y = self.properties.y,
					text = self.properties.text,
					visible = self.properties.visible,
					peer_id = AuroraFramework.libraries.miscellaneous.getPeerID(self.properties.player)
				}
			end
		},

		{
			x = x,
			y = y,
			text = text,
			visible = true,
			player = player,
			id = id,
			name = name
		},

		nil,

		AuroraFramework.services.UIService.UI.screen,
		name
	)

	ui:refresh() -- show
	return ui
end

-- Get a Screen UI object
---@param name string
---@return af_services_ui_screen
AuroraFramework.services.UIService.getScreenUI = function(name)
	return AuroraFramework.services.UIService.UI.screen[name]
end

-- Remove a Screen UI object
---@param name string
AuroraFramework.services.UIService.removeScreenUI = function(name)
	local data = AuroraFramework.services.UIService.UI.screen[name]

	if not data then
		return
	end

	data.properties.visible = false
	data:refresh() -- hide ui

	AuroraFramework.services.UIService.UI.screen[name] = nil
	data:updateSaveData()
end

-- Create a Map Label
---@param name string
---@param text string
---@param pos SWMatrix
---@param labelType SWLabelTypeEnum
---@param player af_services_player_player|nil
---@param custom_id integer|nil
---@return af_services_ui_map_label
AuroraFramework.services.UIService.createMapLabel = function(name, text, pos, labelType, player, custom_id)
	-- Get ID
	local id = custom_id or server.getMapID()

	-- If UI with the same name exists, use the ID from it and overwrite the UI entirely
	local alreadyExistingUI = AuroraFramework.services.UIService.getMapLabel(name)

	if alreadyExistingUI then
		id = alreadyExistingUI.properties.id
		alreadyExistingUI:remove()
	end

	-- Create UI
	---@type af_services_ui_map_label
	local ui = AuroraFramework.libraries.class.create(
		"UIMapLabel",

		{
			---@param self af_services_ui_map_label
			refresh = function(self)
				self:updateSaveData()

				local peerID = AuroraFramework.libraries.miscellaneous.getPeerID(self.properties.player)
				server.removeMapLabel(peerID, self.properties.id)

				if not self.properties.visible then -- if not visible, dont add the label back
					return
				end

				server.addMapLabel(peerID, self.properties.id, self.properties.labelType, self.properties.text, self.properties.pos[13], self.properties.pos[15])
			end,

			---@param self af_services_ui_map_label
			remove = function(self)
				return AuroraFramework.services.UIService.removeMapLabel(self.properties.name)
			end,

			---@param self af_services_ui_map_label
			updateSaveData = function(self)
				if not AuroraFramework.services.UIService.getMapLabel(self.properties.name) then
					g_savedata.AuroraFramework.UI.mapLabels[self.properties.name] = nil
					return
				end

				g_savedata.AuroraFramework.UI.mapLabels[self.properties.name] = {
					name = self.properties.name,
					id = self.properties.id,
					pos = self.properties.pos,
					text = self.properties.text,
					visible = self.properties.visible,
					labelType = self.properties.labelType,
					peer_id = AuroraFramework.libraries.miscellaneous.getPeerID(self.properties.player)
				}
			end
		},

		{
			name = name,
			pos = pos,
			text = text,
			visible = true,
			player = player,
			id = id,
			labelType = labelType
		},

		nil,

		AuroraFramework.services.UIService.UI.mapLabels,
		name
	)

	ui:refresh() -- show
	return ui
end

-- Get a Map Label
---@param name string
---@return af_services_ui_map_label
AuroraFramework.services.UIService.getMapLabel = function(name)
	return AuroraFramework.services.UIService.UI.mapLabels[name]
end

-- Remove a Map Label
---@param name string
AuroraFramework.services.UIService.removeMapLabel = function(name)
	local data = AuroraFramework.services.UIService.UI.mapLabels[name]

	if not data then
		return
	end

	data.properties.visible = false
	data:refresh() -- hide ui

	AuroraFramework.services.UIService.UI.mapLabels[name] = nil
	data:updateSaveData() -- remove from savedata
end

-- Create a Map Line
---@param name string
---@param startPoint SWMatrix
---@param endPoint SWMatrix
---@param thickness number
---@param player af_services_player_player|nil
---@param r integer|nil 0-255
---@param g integer|nil 0-255
---@param b integer|nil 0-255
---@param a integer|nil 0-255
---@param custom_id integer|nil
---@return af_services_ui_map_line
AuroraFramework.services.UIService.createMapLine = function(name, startPoint, endPoint, thickness, player, r, g, b, a, custom_id)
	-- Get ID
	local id = custom_id or server.getMapID()

	-- If UI with the same name exists, use the ID from it and overwrite the UI entirely
	local alreadyExistingUI = AuroraFramework.services.UIService.getMapLine(name)

	if alreadyExistingUI then
		id = alreadyExistingUI.properties.id
		alreadyExistingUI:remove()
	end
	
	-- Create UI
	---@type af_services_ui_map_line
	local ui = AuroraFramework.libraries.class.create(
		"UIMapLine",

		{
			---@param self af_services_ui_map_line
			refresh = function(self)
				self:updateSaveData()

				local peerID = AuroraFramework.libraries.miscellaneous.getPeerID(self.properties.player)
				server.removeMapLine(peerID, self.properties.id)

				if not self.properties.visible then -- if not visible, dont add the line back
					return
				end

				server.addMapLine(
					peerID,
					self.properties.id,
					self.properties.startPoint,
					self.properties.endPoint,
					self.properties.thickness,
					self.properties.r,
					self.properties.g,
					self.properties.b,
					self.properties.a
				)
			end,

			---@param self af_services_ui_map_line
			remove = function(self)
				return AuroraFramework.services.UIService.removeMapLine(self.properties.name)
			end,

			---@param self af_services_ui_map_line
			updateSaveData = function(self)
				if not AuroraFramework.services.UIService.getMapLine(self.properties.name) then
					g_savedata.AuroraFramework.UI.mapLines[self.properties.name] = nil
					return
				end

				g_savedata.AuroraFramework.UI.mapLines[self.properties.name] = {
					name = self.properties.name,
					startPoint = self.properties.startPoint,
					endPoint = self.properties.endPoint,
					visible = self.properties.visible,
					peer_id = AuroraFramework.libraries.miscellaneous.getPeerID(self.properties.player),
					id = self.properties.id,

					r = self.properties.r,
					g = self.properties.g,
					b = self.properties.b,
					a = self.properties.a,

					thickness = self.properties.thickness
				}
			end
		},

		{
			name = name,
			startPoint = startPoint,
			endPoint = endPoint,
			visible = true,
			player = player,
			id = id,

			r = r or 255,
			g = g or 255,
			b = b or 255,
			a = a or 255,

			thickness = thickness
		},

		nil,

		AuroraFramework.services.UIService.UI.mapLines,
		name
	)

	ui:refresh() -- show
	return ui
end

-- Get a Map Line
---@param name string
---@return af_services_ui_map_line
AuroraFramework.services.UIService.getMapLine = function(name)
	return AuroraFramework.services.UIService.UI.mapLines[name]
end

-- Remove a Map Line
---@param name string
AuroraFramework.services.UIService.removeMapLine = function(name)
	local data = AuroraFramework.services.UIService.UI.mapLines[name]

	if not data then
		return
	end

	data.properties.visible = false
	data:refresh() -- hide ui

	AuroraFramework.services.UIService.UI.mapLines[name] = nil
	data:updateSaveData()
end

-- Create a Map Object
---@param name string
---@param title string
---@param subtitle string
---@param pos SWMatrix
---@param markerType SWMarkerTypeEnum
---@param player af_services_player_player|nil
---@param radius number
---@param r integer|nil 0-255
---@param g integer|nil 0-255
---@param b integer|nil 0-255
---@param a integer|nil 0-255
---@param custom_id integer|nil
---@return af_services_ui_map_object
AuroraFramework.services.UIService.createMapObject = function(name, title, subtitle, pos, markerType, player, radius, r, g, b, a, custom_id)
	-- Get ID
	local id = custom_id or server.getMapID()

	-- If UI with the same name exists, use the ID from it and overwrite the UI entirely
	local alreadyExistingUI = AuroraFramework.services.UIService.getMapObject(name)

	if alreadyExistingUI then
		id = alreadyExistingUI.properties.id
		alreadyExistingUI:remove()
	end

	-- Create UI
	---@type af_services_ui_map_object
	local ui = AuroraFramework.libraries.class.create(
		"UIMapObject",

		{
			---@param self af_services_ui_map_object
			refresh = function(self)
				self:updateSaveData()

				local peerID = AuroraFramework.libraries.miscellaneous.getPeerID(self.properties.player)
				server.removeMapObject(peerID, self.properties.id)

				if not self.properties.visible then -- if not visible, dont add the object back
					return
				end

				server.addMapObject( -- what the FUCK
					peerID,
					self.properties.id,
					self.properties.positionType,
					self.properties.markerType,
					self.properties.pos[13],
					self.properties.pos[15],
					self.properties.pos[13],
					self.properties.pos[15],
					self.properties.attachID,
					self.properties.attachID,
					self.properties.title,
					self.properties.radius,
					self.properties.subtitle,
					self.properties.r,
					self.properties.g,
					self.properties.b,
					self.properties.a
				)
			end,

			---@param self af_services_ui_map_object
			remove = function(self)
				return AuroraFramework.services.UIService.removeMapObject(self.properties.name)
			end,

			---@param self af_services_ui_map_object
			---@param positionType SWPositionTypeEnum
			---@param objectOrVehicleID integer
			attach = function(self, positionType, objectOrVehicleID)
				self.properties.positionType = positionType
				self.properties.attachID = objectOrVehicleID
				self:refresh()
			end,

			---@param self af_services_ui_map_object
			updateSaveData = function(self)
				if not AuroraFramework.services.UIService.getMapObject(self.properties.name) then
					g_savedata.AuroraFramework.UI.mapObjects[self.properties.name] = nil
					return
				end

				g_savedata.AuroraFramework.UI.mapObjects[self.properties.name] = {
					name = self.properties.name,
					pos = self.properties.pos,
					title = self.properties.title,
					subtitle = self.properties.subtitle,
					visible = self.properties.visible,
					peer_id = AuroraFramework.libraries.miscellaneous.getPeerID(self.properties.player),
					id = self.properties.id,
					markerType = self.properties.markerType,
					positionType = self.properties.positionType,
					attachID = self.properties.attachID,
					r = self.properties.r,
					g = self.properties.g,
					b = self.properties.b,
					a = self.properties.a,
					radius = self.properties.radius
				}
			end
		},

		{
			pos = pos,
			title = title,
			subtitle = subtitle,
			visible = true,
			player = player,
			name = name,
			id = id,
			markerType = markerType,
			positionType = 0,
			attachID = 0,

			r = r or 255,
			g = g or 255,
			b = b or 255,
			a = a or 255,

			radius = radius
		},

		nil,

		AuroraFramework.services.UIService.UI.mapObjects,
		name
	)

	ui:refresh() -- show
	return ui
end

-- Get a Map Object
---@param name string
---@return af_services_ui_map_object
AuroraFramework.services.UIService.getMapObject = function(name)
	return AuroraFramework.services.UIService.UI.mapObjects[name]
end

-- Remove a Map Object
---@param name string
AuroraFramework.services.UIService.removeMapObject = function(name)
	local data = AuroraFramework.services.UIService.UI.mapObjects[name]

	if not data then
		return
	end

	data.properties.visible = false
	data:refresh() -- hide ui

	AuroraFramework.services.UIService.UI.mapObjects[name] = nil
	data:updateSaveData()
end

--------------------------------------------------------------------------------
--// Callbacks \\--
--------------------------------------------------------------------------------
AuroraFramework.callbacks.onTick = {
	internal = AuroraFramework.libraries.events.create("callback_onTick_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onTick_addon")
}

function onTick(...)
	AuroraFramework.callbacks.onTick.internal:fire(...)
	AuroraFramework.callbacks.onTick.main:fire(...)
end

----------------

AuroraFramework.callbacks.onCreate = {
	internal = AuroraFramework.libraries.events.create("callback_onCreate_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onCreate_addon")
}

function onCreate(...)
	AuroraFramework.callbacks.onCreate.internal:fire(...)
	AuroraFramework.callbacks.onCreate.main:fire(...)
end

----------------

AuroraFramework.callbacks.onDestroy = {
	internal = AuroraFramework.libraries.events.create("callback_onDestroy_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onDestroy_addon")
}

function onDestroy(...)
	AuroraFramework.callbacks.onDestroy.internal:fire(...)
	AuroraFramework.callbacks.onDestroy.main:fire(...)
end

----------------

AuroraFramework.callbacks.onCustomCommand = {
	internal = AuroraFramework.libraries.events.create("callback_onCustomCommand_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onCustomCommand_addon")
}

function onCustomCommand(...)
	AuroraFramework.callbacks.onCustomCommand.internal:fire(...)
	AuroraFramework.callbacks.onCustomCommand.main:fire(...)
end

----------------

AuroraFramework.callbacks.onChatMessage = {
	internal = AuroraFramework.libraries.events.create("callback_onChatMessage_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onChatMessage_addon")
}

function onChatMessage(...)
	AuroraFramework.callbacks.onChatMessage.internal:fire(...)
	AuroraFramework.callbacks.onChatMessage.main:fire(...)
end

----------------

AuroraFramework.callbacks.onPlayerJoin = {
	internal = AuroraFramework.libraries.events.create("callback_onPlayerJoin_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onPlayerJoin_addon")
}

function onPlayerJoin(...)
	AuroraFramework.callbacks.onPlayerJoin.internal:fire(...)
	AuroraFramework.callbacks.onPlayerJoin.main:fire(...)
end

----------------

AuroraFramework.callbacks.onPlayerSit = {
	internal = AuroraFramework.libraries.events.create("callback_onPlayerSit_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onPlayerSit_addon")
}

function onPlayerSit(...)
	AuroraFramework.callbacks.onPlayerSit.internal:fire(...)
	AuroraFramework.callbacks.onPlayerSit.main:fire(...)
end

----------------

AuroraFramework.callbacks.onPlayerUnsit = {
	internal = AuroraFramework.libraries.events.create("callback_onPlayerUnsit_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onPlayerUnsit_addon")
}

function onPlayerUnsit(...)
	AuroraFramework.callbacks.onPlayerUnsit.internal:fire(...)
	AuroraFramework.callbacks.onPlayerUnsit.main:fire(...)
end

----------------

AuroraFramework.callbacks.onCharacterSit = {
	internal = AuroraFramework.libraries.events.create("callback_onCharacterSit_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onCharacterSit_addon")
}

function onCharacterSit(...)
	AuroraFramework.callbacks.onCharacterSit.internal:fire(...)
	AuroraFramework.callbacks.onCharacterSit.main:fire(...)
end

----------------

AuroraFramework.callbacks.onCharacterUnsit = {
	internal = AuroraFramework.libraries.events.create("callback_onCharacterUnsit_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onCharacterUnsit_addon")
}

function onCharacterUnsit(...)
	AuroraFramework.callbacks.onCharacterUnsit.internal:fire(...)
	AuroraFramework.callbacks.onCharacterUnsit.main:fire(...)
end

----------------

AuroraFramework.callbacks.onCharacterPickup = {
	internal = AuroraFramework.libraries.events.create("callback_onCharacterPickup_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onCharacterPickup_addon")
}

function onCharacterPickup(...)
	AuroraFramework.callbacks.onCharacterPickup.internal:fire(...)
	AuroraFramework.callbacks.onCharacterPickup.main:fire(...)
end

----------------

AuroraFramework.callbacks.onEquipmentPickup = {
	internal = AuroraFramework.libraries.events.create("callback_onEquipmentPickup_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onEquipmentPickup_addon")
}

function onEquipmentPickup(...)
	AuroraFramework.callbacks.onEquipmentPickup.internal:fire(...)
	AuroraFramework.callbacks.onEquipmentPickup.main:fire(...)
end

----------------

AuroraFramework.callbacks.onEquipmentDrop = {
	internal = AuroraFramework.libraries.events.create("callback_onEquipmentDrop_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onEquipmentDrop_addon")
}

function onEquipmentDrop(...)
	AuroraFramework.callbacks.onEquipmentDrop.internal:fire(...)
	AuroraFramework.callbacks.onEquipmentDrop.main:fire(...)
end

----------------

AuroraFramework.callbacks.onCharacterPickup = {
	internal = AuroraFramework.libraries.events.create("callback_onCharacterPickup_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onCharacterPickup_addon")
}

function onCharacterPickup(...)
	AuroraFramework.callbacks.onCharacterPickup.internal:fire(...)
	AuroraFramework.callbacks.onCharacterPickup.main:fire(...)
end

----------------

AuroraFramework.callbacks.onPlayerRespawn = {
	internal = AuroraFramework.libraries.events.create("callback_onPlayerRespawn_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onPlayerRespawn_addon")
}

function onPlayerRespawn(...)
	AuroraFramework.callbacks.onPlayerRespawn.internal:fire(...)
	AuroraFramework.callbacks.onPlayerRespawn.main:fire(...)
end

----------------

AuroraFramework.callbacks.onPlayerLeave = {
	internal = AuroraFramework.libraries.events.create("callback_onPlayerLeave_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onPlayerLeave_addon")
}

function onPlayerLeave(...)
	AuroraFramework.callbacks.onPlayerLeave.internal:fire(...)
	AuroraFramework.callbacks.onPlayerLeave.main:fire(...)
end

----------------

AuroraFramework.callbacks.onToggleMap = {
	internal = AuroraFramework.libraries.events.create("callback_onToggleMap_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onToggleMap_addon")
}

function onToggleMap(...)
	AuroraFramework.callbacks.onToggleMap.internal:fire(...)
	AuroraFramework.callbacks.onToggleMap.main:fire(...)
end

----------------

AuroraFramework.callbacks.onPlayerDie = {
	internal = AuroraFramework.libraries.events.create("callback_onPlayerDie_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onPlayerDie_addon")
}

function onPlayerDie(...)
	AuroraFramework.callbacks.onPlayerDie.internal:fire(...)
	AuroraFramework.callbacks.onPlayerDie.main:fire(...)
end

----------------

AuroraFramework.callbacks.onVehicleSpawn = {
	internal = AuroraFramework.libraries.events.create("callback_onVehicleSpawn_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onVehicleSpawn_addon")
}

function onVehicleSpawn(...)
	AuroraFramework.callbacks.onVehicleSpawn.internal:fire(...)
	AuroraFramework.callbacks.onVehicleSpawn.main:fire(...)
end

----------------

AuroraFramework.callbacks.onGroupSpawn = {
	internal = AuroraFramework.libraries.events.create("callback_onGroupSpawn_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onGroupSpawn_addon")
}

function onGroupSpawn(...)
	AuroraFramework.callbacks.onGroupSpawn.internal:fire(...)
	AuroraFramework.callbacks.onGroupSpawn.main:fire(...)
end

----------------

AuroraFramework.callbacks.onVehicleDespawn = {
	internal = AuroraFramework.libraries.events.create("callback_onVehicleDespawn_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onVehicleDespawn_addon")
}

function onVehicleDespawn(...)
	AuroraFramework.callbacks.onVehicleDespawn.internal:fire(...)
	AuroraFramework.callbacks.onVehicleDespawn.main:fire(...)
end

----------------

AuroraFramework.callbacks.onVehicleLoad = {
	internal = AuroraFramework.libraries.events.create("callback_onVehicleLoad_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onVehicleLoad_addon")
}

function onVehicleLoad(...)
	AuroraFramework.callbacks.onVehicleLoad.internal:fire(...)
	AuroraFramework.callbacks.onVehicleLoad.main:fire(...)
end

----------------

AuroraFramework.callbacks.onVehicleUnload = {
	internal = AuroraFramework.libraries.events.create("callback_onVehicleUnload_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onVehicleUnload_addon")
}

function onVehicleUnload(...)
	AuroraFramework.callbacks.onVehicleUnload.internal:fire(...)
	AuroraFramework.callbacks.onVehicleUnload.main:fire(...)
end

----------------

AuroraFramework.callbacks.onVehicleTeleport = {
	internal = AuroraFramework.libraries.events.create("callback_onVehicleTeleport_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onVehicleTeleport_addon")
}

function onVehicleTeleport(...)
	AuroraFramework.callbacks.onVehicleTeleport.internal:fire(...)
	AuroraFramework.callbacks.onVehicleTeleport.main:fire(...)
end

----------------

AuroraFramework.callbacks.onObjectLoad = {
	internal = AuroraFramework.libraries.events.create("callback_onObjectLoad_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onObjectLoad_addon")
}

function onObjectLoad(...)
	AuroraFramework.callbacks.onObjectLoad.internal:fire(...)
	AuroraFramework.callbacks.onObjectLoad.main:fire(...)
end

----------------

AuroraFramework.callbacks.onObjectUnload = {
	internal = AuroraFramework.libraries.events.create("callback_onObjectUnload_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onObjectUnload_addon")
}

function onObjectUnload(...)
	AuroraFramework.callbacks.onObjectUnload.internal:fire(...)
	AuroraFramework.callbacks.onObjectUnload.main:fire(...)
end

----------------

AuroraFramework.callbacks.onButtonPress = {
	internal = AuroraFramework.libraries.events.create("callback_onButtonPress_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onButtonPress_addon")
}

function onButtonPress(...)
	AuroraFramework.callbacks.onButtonPress.internal:fire(...)
	AuroraFramework.callbacks.onButtonPress.main:fire(...)
end

----------------

AuroraFramework.callbacks.onCreatureSit = {
	internal = AuroraFramework.libraries.events.create("callback_onCreatureSit_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onCreatureSit_addon")
}

function onCreatureSit(...)
	AuroraFramework.callbacks.onCreatureSit.internal:fire(...)
	AuroraFramework.callbacks.onCreatureSit.main:fire(...)
end

----------------

AuroraFramework.callbacks.onCreatureUnsit = {
	internal = AuroraFramework.libraries.events.create("callback_onCreatureUnsit_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onCreatureUnsit_addon")
}

function onCreatureUnsit(...)
	AuroraFramework.callbacks.onCreatureUnsit.internal:fire(...)
	AuroraFramework.callbacks.onCreatureUnsit.main:fire(...)
end

----------------

AuroraFramework.callbacks.onCreaturePickup = {
	internal = AuroraFramework.libraries.events.create("callback_onCreaturePickup_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onCreaturePickup_addon")
}

function onCreaturePickup(...)
	AuroraFramework.callbacks.onCreaturePickup.internal:fire(...)
	AuroraFramework.callbacks.onCreaturePickup.main:fire(...)
end

----------------

AuroraFramework.callbacks.onSpawnAddonComponent = {
	internal = AuroraFramework.libraries.events.create("callback_onSpawnAddonComponent_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onSpawnAddonComponent_addon")
}

function onSpawnAddonComponent(...)
	AuroraFramework.callbacks.onSpawnAddonComponent.internal:fire(...)
	AuroraFramework.callbacks.onSpawnAddonComponent.main:fire(...)
end

----------------

AuroraFramework.callbacks.onVehicleDamaged = {
	internal = AuroraFramework.libraries.events.create("callback_onVehicleDamaged_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onVehicleDamaged_addon")
}

function onVehicleDamaged(...)
	AuroraFramework.callbacks.onVehicleDamaged.internal:fire(...)
	AuroraFramework.callbacks.onVehicleDamaged.main:fire(...)
end

----------------

AuroraFramework.callbacks.httpReply = {
	internal = AuroraFramework.libraries.events.create("callback_httpReply_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_httpReply_addon")
}

function httpReply(...)
	AuroraFramework.callbacks.httpReply.internal:fire(...)
	AuroraFramework.callbacks.httpReply.main:fire(...)
end

----------------

AuroraFramework.callbacks.onFireExtinguished = {
	internal = AuroraFramework.libraries.events.create("callback_onFireExtinguished_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onFireExtinguished_addon")
}

function onFireExtinguished(...)
	AuroraFramework.callbacks.onFireExtinguished.internal:fire(...)
	AuroraFramework.callbacks.onFireExtinguished.main:fire(...)
end

----------------

AuroraFramework.callbacks.onForestFireSpawned = {
	internal = AuroraFramework.libraries.events.create("callback_onForestFireSpawned_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onForestFireSpawned_addon")
}

function onForestFireSpawned(...)
	AuroraFramework.callbacks.onForestFireSpawned.internal:fire(...)
	AuroraFramework.callbacks.onForestFireSpawned.main:fire(...)
end

----------------

AuroraFramework.callbacks.onForestFireExtinguished = {
	internal = AuroraFramework.libraries.events.create("callback_onForestFireExtinguished_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onForestFireExtinguished_addon")
}

function onForestFireExtinguished(...)
	AuroraFramework.callbacks.onForestFireExtinguished.internal:fire(...)
	AuroraFramework.callbacks.onForestFireExtinguished.main:fire(...)
end

----------------

AuroraFramework.callbacks.onTornado = {
	internal = AuroraFramework.libraries.events.create("callback_onTornado_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onTornado_addon")
}

function onTornado(...)
	AuroraFramework.callbacks.onTornado.internal:fire(...)
	AuroraFramework.callbacks.onTornado.main:fire(...)
end

----------------

AuroraFramework.callbacks.onMeteor = {
	internal = AuroraFramework.libraries.events.create("callback_onMeteor_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onMeteor_addon")
}

function onMeteor(...)
	AuroraFramework.callbacks.onMeteor.internal:fire(...)
	AuroraFramework.callbacks.onMeteor.main:fire(...)
end

----------------

AuroraFramework.callbacks.onTsunami = {
	internal = AuroraFramework.libraries.events.create("callback_onTsunami_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onTsunami_addon")
}

function onTsunami(...)
	AuroraFramework.callbacks.onTsunami.internal:fire(...)
	AuroraFramework.callbacks.onTsunami.main:fire(...)
end

----------------

AuroraFramework.callbacks.onWhirlpool = {
	internal = AuroraFramework.libraries.events.create("callback_onWhirlpool_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onWhirlpool_addon")
}

function onWhirlpool(...)
	AuroraFramework.callbacks.onWhirlpool.internal:fire(...)
	AuroraFramework.callbacks.onWhirlpool.main:fire(...)
end

----------------

AuroraFramework.callbacks.onVolcano = {
	internal = AuroraFramework.libraries.events.create("callback_onVolcano_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onVolcano_addon")
}

function onVolcano(...)
	AuroraFramework.callbacks.onVolcano.internal:fire(...)
	AuroraFramework.callbacks.onVolcano.main:fire(...)
end

----------------

AuroraFramework.callbacks.onOilSpill = {
	internal = AuroraFramework.libraries.events.create("callback_onOilSpill_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onOilSpill_addon")
}

function onOilSpill(...)
	AuroraFramework.callbacks.onOilSpill.internal:fire(...)
	AuroraFramework.callbacks.onOilSpill.main:fire(...)
end

--------------------------------------------------------------------------------
--// Initialization \\--
--------------------------------------------------------------------------------
-- // Ready event
AuroraFramework.ready = AuroraFramework.libraries.events.create("auroraframework_ready") -- provides one param: "save_load"|"save_create"|"addon_reload"

---@param first_load boolean
AuroraFramework.callbacks.onCreate.internal:connect(function(save_create)
	AuroraFramework.services.timerService.delay.create(0, function() -- wait a tick, because stormworks g_savedata is weird
		if save_create then
			-- first load
			AuroraFramework.ready:fire("save_create")
			return
		end

		if server.getPlayers()[1].steam_id == 0 then
			-- loading from saved file
			AuroraFramework.ready:fire("save_load")
		else
			-- addon reload
			AuroraFramework.ready:fire("addon_reload")
		end
	end)
end)

-- // Initialize services
AuroraFramework.services.zoneService.initialize()
AuroraFramework.services.debuggerService.initialize()
AuroraFramework.services.timerService.initialize()
AuroraFramework.services.communicationService.initialize()
AuroraFramework.services.chatService.initialize()
AuroraFramework.services.HTTPService.initialize()
AuroraFramework.services.TPSService.initialize()
AuroraFramework.services.commandService.initialize()

---@param state "save_load"|"save_create"|"addon_reload"
AuroraFramework.ready:connect(function(state)
	AuroraFramework.services.playerService.initialize(state)
	AuroraFramework.services.UIService.initialize(state)
	AuroraFramework.services.vehicleService.initialize(state) -- important this is initialized before groupservice
	AuroraFramework.services.groupService.initialize(state)
end)