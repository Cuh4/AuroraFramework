------------------------------------------------------------------------------------------------------------------------
    -- Aurora Framework || A reliable addon creation framework designed for future cuhHub addons.
	-- 		Created by @cuh5_ on Discord
	--		cuhHub: https://discord.gg/zTQxaZjwDr
------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--// Framework \\--
--------------------------------------------------------------------------------
AuroraFramework = {
	game = {},
	libraries = {},
	services = {}
}

--------------------------------------------------------------------------------
--// Libraries \\--
--------------------------------------------------------------------------------
---------------- Matrix
AuroraFramework.libraries.matrix = {}

-- Offsets the position by x, y, and z
---@param position SWMatrix
---@param x number|nil 0 if nil
---@param y number|nil 0 if nil
---@param z number|nil 0 if nil
AuroraFramework.libraries.matrix.offset = function(position, x, y, z)
	local new = matrix.translation(0, 0, 0)

	for i, v in pairs(position) do
		new[i] = v
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
	return AuroraFramework.libraries.matrix.offset(position, math.random(-max, max), AuroraFramework.libraries.miscellaneous.switchbox(0, math.random(-max, max), shouldOffsetY), math.random(-max, max))
end

---------------- Miscellaneous
AuroraFramework.libraries.miscellaneous = {}

-- Create a PID object (from https://steamcommunity.com/sharedfiles/filedetails/?id=1800568163)
---@param proportional number
---@param integral number
---@param derivative number
---@return af_libs_miscellaneous_pid
AuroraFramework.libraries.miscellaneous.pid = function(proportional, integral, derivative)
    return {
		proportional = proportional,
		integral = integral,
		derivative = derivative,

		_E = 0,
		_D = 0,
		_I = 0,

		---@param self af_libs_miscellaneous_pid
		run = function(self, setPoint, processVariable)
			local E = setPoint - processVariable
			local D = E - self._E
			local absolute = math.abs(D - self._D)

			self._E = E
			self._D = D
			self._I = absolute < E and self._I + E * self.integral or self._I * 0.5

			return E * self.proportional + (absolute < E and self._I or 0) + D * self.derivative
		end
	}
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
---@param value any
AuroraFramework.libraries.miscellaneous.removeValueFromTable = function(tbl, value)
	for i, v in pairs(tbl) do
		if v == value then
			tbl[i] = nil
		end
	end

	return tbl
end

-- Get the index of a value in a table
---@param tbl table
---@param value any
---@return any|nil
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

-- Returns the average of a table full of numbers
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

-- Adds both set and get methods to the provided class. If the name is "foo", then two new methods will be created under the provided class named "getFoo" and "setFoo" (note the capitalization)
---@generic class
---@param class table|class
---@param name string
---@param location table|nil The location of the property with the same name as the one provided. If nil, the location will be set to the provided class
---@return class class The provided class
AuroraFramework.libraries.miscellaneous.getterSetter = function(class, name, location)
	if not location then
		location = class
	end

	name = AuroraFramework.libraries.miscellaneous.name(name)

	class["get"..name] = function(self)
		return self[name]
	end

	class["set"..name] = function(self, to)
		self[name] = to
		return self
	end

	return class
end

-- Returns the "name" version of the provided string, eg: "bob" -> "Bob"
---@param input string
AuroraFramework.libraries.miscellaneous.name = function(input)
	return input:sub(1, 1):upper()..input:sub(2)
end

-- Returns on or off depending on whether or not switch is true
---@param off any
---@param on any
---@param switch any
---@return any
AuroraFramework.libraries.miscellaneous.switchbox = function(off, on, switch)
	if switch then
		return on
	else
		return off
	end
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
	for i, v in pairs(tbl) do
		tbl[i] = tostring(v)
	end

	return tbl
end

-- Converts all string values in a table to lowercase
---@param tbl table
AuroraFramework.libraries.miscellaneous.lowerStringValuesInTable = function(tbl)
	for i, v in pairs(tbl) do
		if type(v) == "string" then
			tbl[i] = v:lower()
		end
	end

	return tbl
end

-- Converts all string values in a table to uppercase
---@param tbl table
AuroraFramework.libraries.miscellaneous.upperStringValuesInTable = function(tbl)
	for i, v in pairs(tbl) do
		if type(v) == "string" then
			tbl[i] = v:upper()
		end
	end

	return tbl
end

---------------- Storage
AuroraFramework.libraries.storage = {
	---@type table<string, af_libs_storage_storage>
	createdStorages = {}
}

-- Create a storage container
---@param name string
AuroraFramework.libraries.storage.create = function(name)
	AuroraFramework.libraries.storage.createdStorages[name] = {
		name = name,
		data = {},

		---@param self af_libs_storage_storage
		save = function(self, index, value)
			self = AuroraFramework.libraries.storage.get(self.name) -- prevent modifying a "cached" version of this storage instead of the actual storage

			self.data[index] = value
			return self
		end,

		---@param self af_libs_storage_storage
		get = function(self, index)
			self = AuroraFramework.libraries.storage.get(self.name)
			return self.data[index]
		end,

		---@param self af_libs_storage_storage
		destroy = function(self, index)
			self = AuroraFramework.libraries.storage.get(self.name)

			self.data[index] = nil
			return self
		end,

		---@param self af_libs_storage_storage
		remove = function(self)
			return AuroraFramework.libraries.storage.remove(self.name)
		end
	}

	return AuroraFramework.libraries.storage.createdStorages[name]
end

-- Get a storage container
---@param name string
AuroraFramework.libraries.storage.get = function(name)
	return AuroraFramework.libraries.storage.createdStorages[name]
end

-- Remove a storage container
---@param name string
AuroraFramework.libraries.storage.remove = function(name)
	AuroraFramework.libraries.storage.createdStorages[name] = nil
end

---------------- Events
AuroraFramework.libraries.events = {
	---@type table<string, af_libs_event_event>
	createdEvents = {}
}

-- Create an event
---@param name string
AuroraFramework.libraries.events.create = function(name)
	AuroraFramework.libraries.events.createdEvents[name] = {
		name = name,
		connections = {},

		---@param self af_libs_event_event
		fire = function(self, ...)
			for i, v in pairs(self.connections) do
				v(...)
			end

			return self
		end,

		---@param self af_libs_event_event
		clear = function(self)
			self.connections = {}
			return self
		end,

		---@param self af_libs_event_event
		remove = function(self)
			return AuroraFramework.libraries.events.remove(self.name)
		end,

		---@param self af_libs_event_event
		connect = function(self, toConnect)
			table.insert(self.connections, toConnect)
			return self
		end
	}

	local event = AuroraFramework.libraries.events.createdEvents[name]
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

---------------- Loops and Delays
local af_timerID = 0

AuroraFramework.libraries.timer = {
	loop = {
		---@type table<integer, af_libs_timer_loop>
		ongoing = {}
	},

	delay = {
		---@type table<integer, af_libs_timer_delay>
		ongoing = {}
	}
}

-- Create a loop. Duration is in seconds
---@param duration integer In seconds
---@param callback function
AuroraFramework.libraries.timer.loop.create = function(duration, callback)
	-- unique id
	af_timerID = af_timerID + 1

	-- store loop
	AuroraFramework.libraries.timer.loop.ongoing[af_timerID] = {
		duration = duration,
		creationTime = server.getTimeMillisec(),
		event = AuroraFramework.libraries.events.create(af_timerID.."_af_loop"),
		id = af_timerID,

		---@param self af_libs_timer_loop
		remove = function(self)
			AuroraFramework.libraries.timer.loop.remove(self.id)
		end,

		---@param self af_libs_timer_loop
		setDuration = function(self, new)
			self.duration = new
		end
	}

	-- attach callback
	local data = AuroraFramework.libraries.timer.loop.ongoing[af_timerID]
	data.event:connect(callback)

	-- return
	return data
end

-- Remove a loop
---@param id integer
AuroraFramework.libraries.timer.loop.remove = function(id)
	AuroraFramework.libraries.timer.loop.ongoing[id] = nil
end

-- Create a delay. Duration is in seconds
---@param duration integer In seconds
---@param callback function
AuroraFramework.libraries.timer.delay.create = function(duration, callback)
	-- unique id
	af_timerID = af_timerID + 1

	-- store delay
	AuroraFramework.libraries.timer.delay.ongoing[af_timerID] = {
		duration = duration,
		creationTime = server.getTimeMillisec(),
		event = AuroraFramework.libraries.events.create(af_timerID.."_af_loop"),
		id = af_timerID,

		---@param self af_libs_timer_delay
		remove = function(self)
			AuroraFramework.libraries.timer.delay.remove(self.id)
		end,

		---@param self af_libs_timer_delay
		setDuration = function(self, new)
			self.duration = new
		end
	}

	-- attach callback
	local data = AuroraFramework.libraries.timer.delay.ongoing[af_timerID]
	data.event:connect(callback)

	-- return
	return data
end

-- Remove a delay
---@param id integer
AuroraFramework.libraries.timer.delay.remove = function(id)
	AuroraFramework.libraries.timer.delay.ongoing[id] = nil
end

-- Handler
AuroraFramework.libraries.timer.handler = function()
	AuroraFramework.game.callbacks.onTick.internal:connect(function()
		local current = server.getTimeMillisec()

		-- Handle loops
		for i, v in pairs(AuroraFramework.libraries.timer.loop.ongoing) do
			if current > v.creationTime + (v.duration * 1000) then
				v.event:fire(v)
				v.creationTime = current
			end
		end

		-- Handle delays
		for i, v in pairs(AuroraFramework.libraries.timer.delay.ongoing) do
			if current > v.creationTime + (v.duration * 1000) then
				v.event:fire(v)
				v:remove()
			end
		end
	end)
end

--------------------------------------------------------------------------------
--// TPS \\--
--------------------------------------------------------------------------------
AuroraFramework.services.TPSService = {
	initialize = function() -- from: https://github.com/Dangleworks/Antilag/blob/master/script.lua
		local ticks = 0
		local ticksTime = 0

		-- update tps n stuff
		AuroraFramework.game.callbacks.onTick.internal:connect(function()
			ticks = ticks + 1

			if server.getTimeMillisec() - ticksTime >= 500 then
				-- update tps
				AuroraFramework.services.TPSService.tpsData.tps = ticks * 2

				-- calculate avg tps
				if #AuroraFramework.services.TPSService.internal.avgTicksTbl > 5 then
					-- calculate average tps
					AuroraFramework.services.TPSService.tpsData.avg = AuroraFramework.libraries.miscellaneous.average(AuroraFramework.services.TPSService.internal.avgTicksTbl)
					AuroraFramework.services.TPSService.internal.avgTicksTbl = {}
				else
					-- add tps to avg tps table
					table.insert(AuroraFramework.services.TPSService.internal.avgTicksTbl, AuroraFramework.services.TPSService.tpsData.tps)
				end

				-- ready for next tps update stuff
				ticks = 0
				ticksTime = server.getTimeMillisec()
			end
		end)
	end,

	tpsData = {
		tps = 64,
		avg = 64
	},

	internal = {
		avgTicksTbl = {}
	}
}

AuroraFramework.services.TPSService.getTPSData = function()
	return AuroraFramework.services.TPSService.tpsData
end

--------------------------------------------------------------------------------
--// Vehicles \\--
--------------------------------------------------------------------------------
AuroraFramework.services.vehicleService = {
	initialize = function()
		-- Give vehicle data whenever a vehicle is spawned
		AuroraFramework.game.callbacks.onVehicleSpawn.internal:connect(function(...)
			-- give vehicle data
			local vehicle = AuroraFramework.services.vehicleService.internal.giveVehicleData(...)

			if not vehicle then
				return
			end

			-- fire events
			AuroraFramework.services.vehicleService.events.onSpawn:fire(vehicle)
		end)

		-- Update vehicle data on load
		AuroraFramework.game.callbacks.onVehicleLoad.internal:connect(function(vehicle_id)
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
		AuroraFramework.game.callbacks.onVehicleDespawn.internal:connect(function(vehicle_id)
			AuroraFramework.libraries.timer.delay.create(0.05, function() -- because of how stupid stormworks is, sometimes onvehicledespawn is called before onvehiclespawn if a vehicle is despawned right away
				-- fire events
				local vehicle = AuroraFramework.services.vehicleService.getVehicleByVehicleID(vehicle_id)

				if not vehicle then
					return
				end

				-- fire events
				AuroraFramework.services.vehicleService.events.onDespawn:fire(vehicle)

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
AuroraFramework.services.vehicleService.internal.giveVehicleData = function(vehicle_id, peer_id, x, y, z, cost)
	if AuroraFramework.services.vehicleService.getVehicleByVehicleID(vehicle_id) then
		return
	end

	local player = AuroraFramework.services.playerService.getPlayerByPeerID(peer_id) -- doesnt matter if nil, because of the addonSpawned property

	AuroraFramework.services.vehicleService.vehicles[vehicle_id] = {
		properties = {
			owner = player,
			addonSpawned = peer_id == -1,
			name = (server.getVehicleName(vehicle_id)),
			vehicle_id = vehicle_id,
			spawnPos = matrix.translation(x, y, z),
			cost = cost,
			storage = AuroraFramework.libraries.storage.create("vehicle_"..vehicle_id.."_storage"),
			loaded = false
		},

		---@param self af_services_vehicle_vehicle
		despawn = function(self)
			server.despawnVehicle(self.properties.vehicle_id, true)
		end,

		---@param self af_services_vehicle_vehicle
		explode = function(self, magnitude)
			if server.dlcWeapons() then
				server.spawnExplosion(self:getPosition(), magnitude or 0.1)
			end

			self:despawn()
		end,

		---@param self af_services_vehicle_vehicle
		teleport = function(self, pos)
			server.setVehiclePos(self.properties.vehicle_id, pos)
		end,

		---@param self af_services_vehicle_vehicle
		repair = function(self)
			server.resetVehicleState(self.properties.vehicle_id)
		end,

		---@param self af_services_vehicle_vehicle
		getPosition = function(self, voxelX, voxelY, voxelZ)
			return (server.getVehiclePos(self.properties.vehicle_id, voxelX, voxelY, voxelZ)) -- in brackets to only get pos, not success
		end,

		---@param self af_services_vehicle_vehicle
		getLoadedVehicleData = function(self)
			if not self.properties.loaded then
				return
			end

			return (server.getVehicleData(self.properties.vehicle_id))
		end,

		---@param self af_services_vehicle_vehicle
		setInvulnerability = function(self, state)
			server.setVehicleInvulnerable(self.properties.vehicle_id, state)
		end,

		---@param self af_services_vehicle_vehicle
		setEditable = function(self, state)
			server.setVehicleEditable(self.properties.vehicle_id, state)
		end,

		---@param self af_services_vehicle_vehicle
		setTooltip = function(self, text)
			server.setVehicleTooltip(self.properties.vehicle_id, text)
		end
	}

	return AuroraFramework.services.vehicleService.vehicles[vehicle_id]
end

-- Remove vehicle data from a vehicle
---@param vehicle_id integer
AuroraFramework.services.vehicleService.internal.removeVehicleData = function(vehicle_id)
	AuroraFramework.services.vehicleService.vehicles[vehicle_id] = nil
end

-- Returns all recognised vehicles
---@return table<integer, af_services_vehicle_vehicle>
AuroraFramework.services.vehicleService.getAllVehicles = function()
	return AuroraFramework.services.vehicleService.vehicles
end

-- Spawn an addon vehicle
---@param componentID integer Found in the playlist.xml of your addon folder and in the addon editor
---@param position SWMatrix
---@return af_services_vehicle_vehicle
AuroraFramework.services.vehicleService.spawnAddonVehicle = function(componentID, position)
	local vehicleID = server.spawnAddonVehicle(position, (server.getAddonIndex()), componentID)
	return AuroraFramework.services.vehicleService.internal.giveVehicleData(vehicleID, -1, position[13], position[14], position[15], 0) ---@diagnostic disable-line return-type-mismatch
end

-- Get a vehicle by its ID
---@param vehicle_id integer
AuroraFramework.services.vehicleService.getVehicleByVehicleID = function(vehicle_id)
	return AuroraFramework.services.vehicleService.vehicles[vehicle_id]
end

-- Get a vehicle by its name
---@param input string
AuroraFramework.services.vehicleService.getVehicleByName = function(input)
	for i, v in pairs(AuroraFramework.services.vehicleService.getAllVehicles()) do
		if v.properties.name == input then
			return v
		end
	end
end

-- Search for a vehicle by name
---@param input string
AuroraFramework.services.vehicleService.getVehicleByNameSearch = function(input)
	for i, v in pairs(AuroraFramework.services.vehicleService.getAllVehicles()) do
		if v.properties.name:lower():find(input:lower()) then
			return v
		end
	end
end

-- Get the amount of spawned and recognised vehicles
AuroraFramework.services.vehicleService.getGlobalVehicleCount = function()
	return AuroraFramework.libraries.miscellaneous.getTableLength(AuroraFramework.services.vehicleService.vehicles)
end

-- Get a list of vehicles spawned by a player
---@param player af_services_player_player
---@return table<integer, af_services_vehicle_vehicle>
AuroraFramework.services.vehicleService.getAllVehiclesSpawnedByAPlayer = function(player)
	local list = {}

	for _, vehicle in pairs(AuroraFramework.services.vehicleService.vehicles) do
		if AuroraFramework.services.playerService.isSamePlayer(player, vehicle.properties.owner) then
			table.insert(list, vehicle)
		end
	end

	return list
end

-- Get the amount of vehicles spawned by a player
---@param player af_services_player_player
AuroraFramework.services.vehicleService.getVehicleCountOfPlayer = function(player)
	return #AuroraFramework.services.vehicleService.getAllVehiclesSpawnedByAPlayer(player)
end

-- Returns whether or not two vehicles are the same
---@param vehicle1 af_services_vehicle_vehicle
---@param vehicle2 af_services_vehicle_vehicle
AuroraFramework.services.vehicleService.isSameVehicle = function(vehicle1, vehicle2)
	return vehicle1.properties.vehicle_id == vehicle2.properties.vehicle_id
end

--------------------------------------------------------------------------------
--// Notification \\--
--------------------------------------------------------------------------------
AuroraFramework.services.notificationService = {}

-- Send a success notification
---@param title string "[Success] - title"
---@param message string "message"
---@param player af_services_player_player|nil If nil, everyone will see the notification
AuroraFramework.services.notificationService.success = function(title, message, player)
	server.notify(AuroraFramework.libraries.miscellaneous.getPeerID(player), "[Success] "..title, message, 4)
end

-- Send a warning notification
---@param title string "[Warning] - title"
---@param message string "message"
---@param player af_services_player_player|nil If nil, everyone will see the notification
AuroraFramework.services.notificationService.warning = function(title, message, player)
	server.notify(AuroraFramework.libraries.miscellaneous.getPeerID(player), "[Warning] "..title, message, 1)
end

-- Send a failure notification
---@param title string "[Failure] - title"
---@param message string "message"
---@param player af_services_player_player|nil If nil, everyone will see the notification
AuroraFramework.services.notificationService.failure = function(title, message, player)
	server.notify(AuroraFramework.libraries.miscellaneous.getPeerID(player), "[Failure] "..title, message, 3)
end

-- Send a custom notification
---@param title string "title"
---@param message string "message"
---@param player af_services_player_player|nil If nil, everyone will see the notification
---@param notificationType SWNotifiationTypeEnum
AuroraFramework.services.notificationService.custom = function(title, message, player, notificationType)
	server.notify(AuroraFramework.libraries.miscellaneous.getPeerID(player), title, message, notificationType)
end

--------------------------------------------------------------------------------
--// Players \\--
--------------------------------------------------------------------------------
AuroraFramework.services.playerService = {
	initialize = function()
		-- Give player data whenever a player joins
		AuroraFramework.game.callbacks.onPlayerJoin.internal:connect(function(...)
			-- give data and fire join event
			local player = AuroraFramework.services.playerService.internal.givePlayerData(...)

			if not player then -- errored somewhere or something
				return
			end

			AuroraFramework.services.playerService.events.onJoin:fire(player)
		end)

		-- Remove player data whenever a player leaves
		AuroraFramework.game.callbacks.onPlayerLeave.internal:connect(function(_, _, peer_id)
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
		AuroraFramework.game.callbacks.onPlayerDie.internal:connect(function(_, _, peer_id)
			local player = AuroraFramework.services.playerService.getPlayerByPeerID(peer_id)

			if not player then
				return
			end

			AuroraFramework.services.playerService.events.onDie:fire(player)
		end)

		-- Respawn event
		AuroraFramework.game.callbacks.onPlayerRespawn.internal:connect(function(peer_id)
			local player = AuroraFramework.services.playerService.getPlayerByPeerID(peer_id)

			if not player then
				return
			end

			AuroraFramework.services.playerService.events.onRespawn:fire(player)
		end)

		-- Character load event
		AuroraFramework.game.callbacks.onObjectLoad.internal:connect(function(object_id)
			local player = AuroraFramework.services.playerService.getPlayerByObjectID(object_id)

			if not player then
				return
			end

			player.properties.characterLoaded = true
			AuroraFramework.services.playerService.events.onCharacterLoad:fire(player)
		end)

		-- Update player properties
		AuroraFramework.libraries.timer.delay.create(0.01, function() -- wait a tick for addon to attach callbacks to player events
			-- Activate player join events
			for _, v in pairs(server.getPlayers()) do
				AuroraFramework.game.callbacks.onPlayerJoin.main:fire(v.steam_id, v.name, v.id, v.admin, v.auth)
				AuroraFramework.game.callbacks.onPlayerJoin.internal:fire(v.steam_id, v.name, v.id, v.admin, v.auth)
			end

			for _, v in pairs(AuroraFramework.services.playerService.getAllPlayers()) do
				v.properties.characterLoaded = true -- set character loaded to true on script reload n shit
				AuroraFramework.services.playerService.events.onCharacterLoad:fire(v)
			end

			-- Update player data
			AuroraFramework.libraries.timer.loop.create(0.01, function()
				for _, player in pairs(server.getPlayers()) do
					if not AuroraFramework.services.playerService.getPlayerByPeerID(player.id) then -- don't update player data if there is none (usually means player is connecting, but hasnt connected fully)
						goto continue
					end

					AuroraFramework.services.playerService.internal.givePlayerData(
						player.steam_id,
						player.name,
						player.id,
						player.admin,
						player.auth
					)

				    ::continue::
				end
			end)
		end)
	end,

	---@type table<integer, af_services_player_player>
	players = {},

	events = {
		onJoin = AuroraFramework.libraries.events.create("auroraFramework_onPlayerJoin"),
		onLeave = AuroraFramework.libraries.events.create("auroraFramework_onPlayerLeave"),
		onCharacterLoad = AuroraFramework.libraries.events.create("auroraFramework_onPlayerCharacterLoad"),
		onDie = AuroraFramework.libraries.events.create("auroraFramework_onPlayerDie"),
		onRespawn = AuroraFramework.libraries.events.create("auroraFramework_onPlayerRespawn")
	},

	internal = {},

	isDedicatedServer = false
}

-- Give player data to a player
AuroraFramework.services.playerService.internal.givePlayerData = function(steam_id, name, peer_id, admin, auth, characterLoaded)
	if steam_id == 0 and AuroraFramework.services.playerService.isDedicatedServer then
		return
	end

	AuroraFramework.services.playerService.players[peer_id] = {
		properties = {
			steam_id = tostring(steam_id),
			name = name,
			peer_id = peer_id,
			admin = admin,
			auth = auth,
			isHost = peer_id == 0,
			storage = AuroraFramework.libraries.storage.create("player_"..peer_id.."_storage"),
			characterLoaded = characterLoaded or false
		},

		setItem = function(self, slot, to, active, int, float)
			server.setCharacterItem(self:getCharacter(), slot, to, active, int, float)
		end,

		removeItem = function(self, slot)
			server.setCharacterItem(self:getCharacter(), slot, 0, false)
		end,

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
		teleport = function(self, pos)
			server.setPlayerPos(self.properties.peer_id, pos)
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
		damage = function(self, amount)
			local character = self:getCharacter()
			local data = server.getCharacterData(character)

			if not data then
				return
			end

			return server.setCharacterData(character, data.hp - amount, data.interactible, data.ai)
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
		setAdmin = function(self, give)
			if give then
				server.addAdmin(self.properties.peer_id)
			else
				server.removeAdmin(self.properties.peer_id)
			end
		end,

		---@param self af_services_player_player
		setAuth = function(self, give)
			if give then
				server.addAuth(self.properties.peer_id)
			else
				server.removeAuth(self.properties.peer_id)
			end
		end
	}

	return AuroraFramework.services.playerService.players[peer_id]
end

-- Remove player data from a player
AuroraFramework.services.playerService.internal.removePlayerData = function(peer_id)
	AuroraFramework.services.playerService.players[peer_id] = nil
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
		local host = AuroraFramework.services.playerService.getPlayerByPeerID(0)

		if not host then
			return
		end

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

--------------------------------------------------------------------------------
--// HTTP \\--
--------------------------------------------------------------------------------
AuroraFramework.services.HTTPService = {
	initialize = function()
		AuroraFramework.game.callbacks.httpReply.internal:connect(function(port, url, reply)
			local data = AuroraFramework.services.HTTPService.ongoingRequests[port.."|"..url]

			if data then
				data.properties.event:fire(tostring(reply)) -- reply callback
				data:cancel() -- remove the request
			end
		end)
	end,

	---@type table<string, af_services_http_request>
	ongoingRequests = {},

	internal = {}
}

-- Send a HTTP request
---@param port integer
---@param url string
---@param callback function|nil
---@return af_services_http_request
AuroraFramework.services.HTTPService.request = function(port, url, callback)
	local ongoingRequest = AuroraFramework.services.HTTPService.ongoingRequests[port.."|"..url]

	if ongoingRequest then -- a request has already been made to the same port and url, so we simply connect to the request's event
		if callback then
			ongoingRequest.properties.event:connect(callback)
		end

		return ongoingRequest
	end

	AuroraFramework.services.HTTPService.ongoingRequests[port.."|"..url] = {
		properties = {
			port = port,
			url = url,
			event = AuroraFramework.libraries.events.create("auroraFramework_HTTPRequest_"..port.."|"..url)
		},

		---@param self af_services_http_request
		cancel = function(self)
			AuroraFramework.services.HTTPService.cancel(self.properties.port, self.properties.url)
		end
	}

	local data = AuroraFramework.services.HTTPService.ongoingRequests[port.."|"..url]

	if callback then
		data.properties.event:connect(callback) -- attach callback to reply event
	end

	server.httpGet(port, url)

	return data
end

-- Convert a table of args into URL parameters
---@param url string
AuroraFramework.services.HTTPService.URLArgs = function(url, ...)
	-- convert args to stuffs tghfgdfd
	local args = {}
	local packed = {...}

	for i, v in pairs(packed) do
		if v.name == nil or v.value == nil then
			goto continue
		end

		if i == 1 then
			table.insert(args, "?"..AuroraFramework.services.HTTPService.URLEncode(v.name).."="..AuroraFramework.services.HTTPService.URLEncode(v.value))
		else
			table.insert(args, "&"..AuroraFramework.services.HTTPService.URLEncode(v.name).."="..AuroraFramework.services.HTTPService.URLEncode(v.value))
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
        ["timeout"] = true,
		["nil"] = true,
		[""] = true
    }

    return notOk[response] == nil
end

-- Cancel a request
---@param port integer
---@param url string
AuroraFramework.services.HTTPService.cancel = function(port, url)
	AuroraFramework.services.HTTPService.ongoingRequests[port.."|"..url] = nil
end

-- Source: https://gist.github.com/To0fan/ca3ebb9c029bb5df381e4afc4d27b4a6
-- Useful for encoding strings (eg: JSON strings) in a URL.
AuroraFramework.services.HTTPService.Base64= {
	conversion = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
}

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

-- Source: https://gist.github.com/tylerneylon/59f4bcf316be525b30ab
-- Encode Lua objects into strings, and decode strings into Lua objects. Handy for transferring/receiving data via HTTP URLs and responses.
AuroraFramework.services.HTTPService.JSON = {}

-- Internal
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

-- Internal
AuroraFramework.services.HTTPService.JSON.escape_str = function(s)
	local in_char = { '\\', '"', '/', '\b', '\f', '\n', '\r', '\t' }
	local out_char = { '\\', '"', '/', 'b', 'f', 'n', 'r', 't' }
	for i, c in ipairs(in_char) do s = s:gsub(c, '\\' .. out_char[i]) end
	return s
end

-- Internal
AuroraFramework.services.HTTPService.JSON.skip_delim = function(str, pos, delim)
	pos = pos + #str:match('^%s*', pos)
	if str:sub(pos, pos) ~= delim then
		return pos, false
	end
	return pos + 1, true
end

-- Internal
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

-- Internal
AuroraFramework.services.HTTPService.JSON.parse_num_val = function(str, pos)
	local num_str = str:match('^-?%d+%.?%d*[eE]?[+-]?%d*', pos)
	local val = tonumber(num_str)
	if not val then return end
	return val, pos + #num_str
end

-- Encode a Lua object into a JSON string
---@param obj any The thing to encode
---@param as_key boolean|nil
---@return string|nil
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
---@return any|nil, number|nil decodedResult nil = failed
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

--------------------------------------------------------------------------------
--// Messages \\--
--------------------------------------------------------------------------------
AuroraFramework.services.chatService = {
	initialize = function()
		AuroraFramework.game.callbacks.onChatMessage.internal:connect(function(peer_id, _, content)
			AuroraFramework.libraries.timer.delay.create(0.01, function() -- just so if the addon deletes the message, shit wont be fucked up (onchatmessage is fired before message is shown in chat)
				-- get player
				local player = AuroraFramework.services.playerService.getPlayerByPeerID(peer_id)

				if not player then
					return
				end

				-- construct message
				local message = AuroraFramework.services.chatService.internal.construct(player, content)

				-- enforce message limit
				if #AuroraFramework.services.chatService.messages >= 129 then
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
	messages = {}, -- max of 129, since thats all the chat window can contain

	internal = {
		message_id = 0
	}
}

-- Construct a message
---@param _player af_services_player_player
---@return af_services_chat_message
AuroraFramework.services.chatService.internal.construct = function(_player, messageContent)
	AuroraFramework.services.chatService.internal.message_id = AuroraFramework.services.chatService.internal.message_id + 1

	return {
		properties = {
			author = _player,
			content = messageContent,
			id = AuroraFramework.services.chatService.internal.message_id
		},

		---@param self af_services_chat_message
		---@param player af_services_player_player
		delete = function(self, player)
			return AuroraFramework.services.chatService.deleteMessage(self, player)
		end,

		---@param self af_services_chat_message
		---@param player af_services_player_player
		edit = function(self, newContent, player)
			return AuroraFramework.services.chatService.editMessage(self, newContent, player)
		end
	}
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

-- Get the newest message
AuroraFramework.services.chatService.getNewestMessage = function()
	return AuroraFramework.services.chatService.messages[#AuroraFramework.services.chatService.messages]
end

-- Get the oldest message
AuroraFramework.services.chatService.getOldestMessage = function()
	return AuroraFramework.services.chatService.messages[1]
end

-- Edit a message
---@param message af_services_chat_message
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
---@param author any
---@param message any
---@param player af_services_player_player|nil
AuroraFramework.services.chatService.sendMessage = function(author, message, player)
	local peer_id = -1

	if player then
		peer_id = player.properties.peer_id
	end

	server.announce(tostring(author), tostring(message), peer_id)
end

-- Clear chat for everyone/a player
---@param player af_services_player_player|nil
AuroraFramework.services.chatService.clear = function(player)
	for _ = 1, 11 do
		AuroraFramework.services.chatService.sendMessage(" ", " ", player)
	end
end

--------------------------------------------------------------------------------
--// Commands \\--
--------------------------------------------------------------------------------
AuroraFramework.services.commandService = {
	initialize = function()
		-- handle commands
		AuroraFramework.game.callbacks.onCustomCommand.internal:connect(function(message, peer_id, admin, auth, command, ...)
			-- get variables n stuff
			local player = AuroraFramework.services.playerService.getPlayerByPeerID(peer_id)

			if not player then
				return
			end

			local args = {...}

			command = command:sub(2, -1)
			local loweredCommand = command:lower()

			-- go through all commands
			for _, cmd in pairs(AuroraFramework.services.commandService.commands) do
				if cmd.properties.requiresAdmin and not admin then
					goto continue
				end

				if cmd.properties.requiresAuth and not auth then
					goto continue
				end

				if cmd.properties.capsSensitive then
					if cmd.properties.name == command or AuroraFramework.libraries.miscellaneous.isValueInTable(command, cmd.properties.shorthands) then
						cmd.events.onActivation:fire(cmd, args, player)
						AuroraFramework.services.commandService.events.commandActivated:fire(cmd, args, player)
						return -- no need to go through the rest of the commands
					end
				else
					if cmd.properties.name:lower() == loweredCommand or AuroraFramework.libraries.miscellaneous.isValueInTable(loweredCommand, AuroraFramework.libraries.miscellaneous.lowerStringValuesInTable(cmd.properties.shorthands)) then
						cmd.events.onActivation:fire(cmd, args, player)
						AuroraFramework.services.commandService.events.commandActivated:fire(cmd, args, player)
						return -- no need to go through the rest of the commands 2
					end
				end

			    ::continue::
			end
		end)
	end,

	---@type table<string, af_services_commands_command>
	commands = {},
	events = {
		commandActivated = AuroraFramework.libraries.events.create("auroraFramework_onCommandActivated") -- command, args, player
	},

	internal = {}
}

-- Create a command
---@param callback function first param = command, second param = args in table, third = player
---@param name string
---@param shorthands table<integer, string>|nil
---@param capsSensitive boolean|nil
---@param description string|nil
---@param requiresAuth boolean|nil
---@param requiresAdmin boolean|nil
AuroraFramework.services.commandService.create = function(callback, name, shorthands, capsSensitive, description, requiresAuth, requiresAdmin)
	-- create the command
	AuroraFramework.services.commandService.commands[name] = {
		properties = {
			name = name,
			requiresAdmin = requiresAdmin or false,
			requiresAuth = requiresAuth or false,
			description = description or "",
			shorthands = shorthands or {},
			capsSensitive = capsSensitive or false
		},

		events = {
			onActivation = AuroraFramework.libraries.events.create("commandService_command_"..name),
		},

		---@param self af_services_commands_command
		remove = function(self)
			return AuroraFramework.services.commandService.remove(self.properties.name)
		end
	}

	-- attach callback
	local data = AuroraFramework.services.commandService.commands[name]
	data.events.onActivation:connect(callback)

	-- return
	return data
end

-- Remove a command
---@param name string
AuroraFramework.services.commandService.remove = function(name)
	AuroraFramework.services.commandService.commands[name] = nil
end

--------------------------------------------------------------------------------
--// UI \\--
--------------------------------------------------------------------------------
AuroraFramework.services.UIService = {
	initialize = function()
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
	end,

	UI = {
		---@type table<integer, af_services_ui_screen>
		screen = {},

		---@type table<integer, af_services_ui_map_label>
		mapLabels = {},

		---@type table<integer, af_services_ui_map_object>
		mapObjects = {},

		---@type table<integer, af_services_ui_map_line>
		mapLines = {}
	},

	internal = {}
}

-- Create a Screen UI object
---@param id string|number
---@param text string
---@param x number
---@param y number
---@param player af_services_player_player|nil
---@return af_services_ui_screen
AuroraFramework.services.UIService.createScreenUI = function(id, text, x, y, player)
	AuroraFramework.services.UIService.UI.screen[id] = {
		properties = {
			x = x,
			y = y,
			text = text,
			visible = true,
			player = player,
			id = id,
			trueID = server.getMapID()
		},

		---@param self af_services_ui_screen
		refresh = function(self)
			local peerID = AuroraFramework.libraries.miscellaneous.getPeerID(self.properties.player)
			server.setPopupScreen(peerID, self.properties.trueID, "", self.properties.visible, self.properties.text, self.properties.x, self.properties.y)
		end,

		---@param self af_services_ui_screen
		remove = function(self)
			return AuroraFramework.services.UIService.removeScreenUI(self.properties.id)
		end,
	}

	local data = AuroraFramework.services.UIService.UI.screen[id]
	data:refresh() -- show

	return data
end

-- Get a Screen UI object
---@param id string|number
---@return af_services_ui_screen
AuroraFramework.services.UIService.getScreenUI = function(id)
	return AuroraFramework.services.UIService.UI.screen[id]
end

-- Remove a Screen UI object
---@param id string|number
AuroraFramework.services.UIService.removeScreenUI = function(id)
	local data = AuroraFramework.services.UIService.UI.screen[id]
	data.properties.visible = false
	data:refresh() -- hide ui

	AuroraFramework.services.UIService.UI.screen[id] = nil
end

-- Create a Map Label
---@param id string|number
---@param text string
---@param pos SWMatrix
---@param labelType SWLabelTypeEnum
---@param player af_services_player_player|nil
---@return af_services_ui_map_label
AuroraFramework.services.UIService.createMapLabel = function(id, text, pos, labelType, player)
	AuroraFramework.services.UIService.UI.mapLabels[id] = {
		properties = {
			pos = pos,
			text = text,
			visible = true,
			player = player,
			id = id,
			trueID = server.getMapID(),
			labelType = labelType
		},

		---@param self af_services_ui_map_label
		refresh = function(self)
			local peerID = AuroraFramework.libraries.miscellaneous.getPeerID(self.properties.player)
			server.removeMapLabel(peerID, self.properties.trueID)

			if not self.properties.visible then -- if not visible, dont add the label back
				return
			end

			server.addMapLabel(peerID, self.properties.trueID, self.properties.labelType, self.properties.text, self.properties.pos[13], self.properties.pos[15])
		end,

		---@param self af_services_ui_map_label
		remove = function(self)
			return AuroraFramework.services.UIService.removeMapLabel(self.properties.id)
		end,
	}

	local data = AuroraFramework.services.UIService.UI.mapLabels[id]
	data:refresh() -- show

	return data
end

-- Get a Map Label
---@param id string|number
---@return af_services_ui_map_label
AuroraFramework.services.UIService.getMapLabel = function(id)
	return AuroraFramework.services.UIService.UI.mapLabels[id]
end

-- Remove a Map Label
---@param id string|number
AuroraFramework.services.UIService.removeMapLabel = function(id)
	local data = AuroraFramework.services.UIService.UI.mapLabels[id]
	data.properties.visible = false
	data:refresh() -- hide ui

	AuroraFramework.services.UIService.UI.mapLabels[id] = nil
end

-- Create a Map Line
---@param id string|number
---@param startPoint SWMatrix
---@param endPoint SWMatrix
---@param thickness number
---@param player af_services_player_player|nil
---@param r integer|nil 0-255
---@param g integer|nil 0-255
---@param b integer|nil 0-255
---@param a integer|nil 0-255
---@return af_services_ui_map_line
AuroraFramework.services.UIService.createMapLine = function(id, startPoint, endPoint, thickness, r, g, b, a, player)
	AuroraFramework.services.UIService.UI.mapLines[id] = {
		properties = {
			startPoint = startPoint,
			endPoint = endPoint,
			visible = true,
			player = player,
			id = id,
			trueID = server.getMapID(),

			r = r or 255,
			g = g or 255,
			b = b or 255,
			a = a or 255,

			thickness = thickness
		},

		---@param self af_services_ui_map_line
		refresh = function(self)
			local peerID = AuroraFramework.libraries.miscellaneous.getPeerID(self.properties.player)
			server.removeMapLine(peerID, self.properties.trueID)

			if not self.properties.visible then -- if not visible, dont add the line back
				return
			end

			server.addMapLine(peerID, self.properties.trueID, self.properties.startPoint, self.properties.endPoint, self.properties.thickness, self.properties.r, self.properties.g, self.properties.b, self.properties.a)
		end,

		---@param self af_services_ui_map_line
		remove = function(self)
			return AuroraFramework.services.UIService.removeMapLine(self.properties.id)
		end,
	}

	local data = AuroraFramework.services.UIService.UI.mapLines[id]
	data:refresh() -- show

	return data
end

-- Get a Map Line
---@param id string|number
---@return af_services_ui_map_line
AuroraFramework.services.UIService.getMapLine = function(id)
	return AuroraFramework.services.UIService.UI.mapLines[id]
end

-- Remove a Map Line
---@param id string|number
AuroraFramework.services.UIService.removeMapLine = function(id)
	local data = AuroraFramework.services.UIService.UI.mapLines[id]
	data.properties.visible = false
	data:refresh() -- hide ui

	AuroraFramework.services.UIService.UI.mapLines[id] = nil
end

-- Create a Map Object
---@param id string|number
---@param title string
---@param subtitle string
---@param pos SWMatrix
---@param objectType SWMarkerTypeEnum
---@param player af_services_player_player|nil
---@param radius number
---@param r integer|nil 0-255
---@param g integer|nil 0-255
---@param b integer|nil 0-255
---@param a integer|nil 0-255
---@return af_services_ui_map_object
AuroraFramework.services.UIService.createMapObject = function(id, title, subtitle, pos, objectType, player, radius, r, g, b, a)
	AuroraFramework.services.UIService.UI.mapObjects[id] = {
		properties = {
			pos = pos,
			title = title,
			subtitle = subtitle,
			visible = true,
			player = player,
			id = id,
			trueID = server.getMapID(),
			objectType = objectType,
			positionType = 0,
			attachID = 0,

			r = r or 255,
			g = g or 255,
			b = b or 255,
			a = a or 255,

			radius = radius
		},

		---@param self af_services_ui_map_object
		refresh = function(self)
			local peerID = AuroraFramework.libraries.miscellaneous.getPeerID(self.properties.player)
			server.removeMapObject(peerID, self.properties.trueID)

			if not self.properties.visible then -- if not visible, dont add the object back
				return
			end

			server.addMapObject( -- what the FUCK
				peerID,
				self.properties.trueID,
				self.properties.positionType,
				self.properties.objectType,
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
			return AuroraFramework.services.UIService.removeMapObject(self.properties.id)
		end,

		---@param self af_services_ui_map_object
		attach = function(self, positionType, attach)
			self.properties.positionType = positionType
			self.properties.attachID = attach
			self:refresh()
		end
	}

	local data = AuroraFramework.services.UIService.UI.mapObjects[id]
	data:refresh() -- show

	return data
end

-- Get a Map Object
---@param id string|number
---@return af_services_ui_map_object
AuroraFramework.services.UIService.getMapObject = function(id)
	return AuroraFramework.services.UIService.UI.mapObjects[id]
end

-- Remove a Map Object
---@param id string|number
AuroraFramework.services.UIService.removeMapObject = function(id)
	local data = AuroraFramework.services.UIService.UI.mapObjects[id]
	data.properties.visible = false
	data:refresh() -- hide ui

	AuroraFramework.services.UIService.UI.mapObjects[id] = nil
end

--------------------------------------------------------------------------------
--// Callbacks \\--
--------------------------------------------------------------------------------
---@type table<string, af_game_callbacks_callback>
AuroraFramework.game.callbacks = {}

AuroraFramework.game.callbacks.onTick = {
	internal = AuroraFramework.libraries.events.create("callback_onTick_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onTick_addon")
}

function onTick(...)
	AuroraFramework.game.callbacks.onTick.internal:fire(...)
	AuroraFramework.game.callbacks.onTick.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onCreate = {
	internal = AuroraFramework.libraries.events.create("callback_onCreate_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onCreate_addon")
}

function onCreate(...)
	AuroraFramework.game.callbacks.onCreate.internal:fire(...)
	AuroraFramework.game.callbacks.onCreate.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onDestroy = {
	internal = AuroraFramework.libraries.events.create("callback_onDestroy_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onDestroy_addon")
}

function onDestroy(...)
	AuroraFramework.game.callbacks.onDestroy.internal:fire(...)
	AuroraFramework.game.callbacks.onDestroy.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onCustomCommand = {
	internal = AuroraFramework.libraries.events.create("callback_onCustomCommand_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onCustomCommand_addon")
}

function onCustomCommand(...)
	AuroraFramework.game.callbacks.onCustomCommand.internal:fire(...)
	AuroraFramework.game.callbacks.onCustomCommand.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onChatMessage = {
	internal = AuroraFramework.libraries.events.create("callback_onChatMessage_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onChatMessage_addon")
}

function onChatMessage(...)
	AuroraFramework.game.callbacks.onChatMessage.internal:fire(...)
	AuroraFramework.game.callbacks.onChatMessage.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onPlayerJoin = {
	internal = AuroraFramework.libraries.events.create("callback_onPlayerJoin_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onPlayerJoin_addon")
}

function onPlayerJoin(...)
	AuroraFramework.game.callbacks.onPlayerJoin.internal:fire(...)
	AuroraFramework.game.callbacks.onPlayerJoin.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onPlayerSit = {
	internal = AuroraFramework.libraries.events.create("callback_onPlayerSit_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onPlayerSit_addon")
}

function onPlayerSit(...)
	AuroraFramework.game.callbacks.onPlayerSit.internal:fire(...)
	AuroraFramework.game.callbacks.onPlayerSit.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onPlayerUnsit = {
	internal = AuroraFramework.libraries.events.create("callback_onPlayerUnsit_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onPlayerUnsit_addon")
}

function onPlayerUnsit(...)
	AuroraFramework.game.callbacks.onPlayerUnsit.internal:fire(...)
	AuroraFramework.game.callbacks.onPlayerUnsit.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onCharacterSit = {
	internal = AuroraFramework.libraries.events.create("callback_onCharacterSit_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onCharacterSit_addon")
}

function onCharacterSit(...)
	AuroraFramework.game.callbacks.onCharacterSit.internal:fire(...)
	AuroraFramework.game.callbacks.onCharacterSit.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onCharacterUnsit = {
	internal = AuroraFramework.libraries.events.create("callback_onCharacterUnsit_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onCharacterUnsit_addon")
}

function onCharacterUnsit(...)
	AuroraFramework.game.callbacks.onCharacterUnsit.internal:fire(...)
	AuroraFramework.game.callbacks.onCharacterUnsit.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onCharacterPickup = {
	internal = AuroraFramework.libraries.events.create("callback_onCharacterPickup_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onCharacterPickup_addon")
}

function onCharacterPickup(...)
	AuroraFramework.game.callbacks.onCharacterPickup.internal:fire(...)
	AuroraFramework.game.callbacks.onCharacterPickup.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onEquipmentPickup = {
	internal = AuroraFramework.libraries.events.create("callback_onEquipmentPickup_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onEquipmentPickup_addon")
}

function onEquipmentPickup(...)
	AuroraFramework.game.callbacks.onEquipmentPickup.internal:fire(...)
	AuroraFramework.game.callbacks.onEquipmentPickup.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onEquipmentDrop = {
	internal = AuroraFramework.libraries.events.create("callback_onEquipmentDrop_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onEquipmentDrop_addon")
}

function onEquipmentDrop(...)
	AuroraFramework.game.callbacks.onEquipmentDrop.internal:fire(...)
	AuroraFramework.game.callbacks.onEquipmentDrop.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onCharacterPickup = {
	internal = AuroraFramework.libraries.events.create("callback_onCharacterPickup_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onCharacterPickup_addon")
}

function onCharacterPickup(...)
	AuroraFramework.game.callbacks.onCharacterPickup.internal:fire(...)
	AuroraFramework.game.callbacks.onCharacterPickup.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onPlayerRespawn = {
	internal = AuroraFramework.libraries.events.create("callback_onPlayerRespawn_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onPlayerRespawn_addon")
}

function onPlayerRespawn(...)
	AuroraFramework.game.callbacks.onPlayerRespawn.internal:fire(...)
	AuroraFramework.game.callbacks.onPlayerRespawn.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onPlayerLeave = {
	internal = AuroraFramework.libraries.events.create("callback_onPlayerLeave_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onPlayerLeave_addon")
}

function onPlayerLeave(...)
	AuroraFramework.game.callbacks.onPlayerLeave.internal:fire(...)
	AuroraFramework.game.callbacks.onPlayerLeave.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onToggleMap = {
	internal = AuroraFramework.libraries.events.create("callback_onToggleMap_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onToggleMap_addon")
}

function onToggleMap(...)
	AuroraFramework.game.callbacks.onToggleMap.internal:fire(...)
	AuroraFramework.game.callbacks.onToggleMap.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onPlayerDie = {
	internal = AuroraFramework.libraries.events.create("callback_onPlayerDie_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onPlayerDie_addon")
}

function onPlayerDie(...)
	AuroraFramework.game.callbacks.onPlayerDie.internal:fire(...)
	AuroraFramework.game.callbacks.onPlayerDie.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onVehicleSpawn = {
	internal = AuroraFramework.libraries.events.create("callback_onVehicleSpawn_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onVehicleSpawn_addon")
}

function onVehicleSpawn(...)
	AuroraFramework.game.callbacks.onVehicleSpawn.internal:fire(...)
	AuroraFramework.game.callbacks.onVehicleSpawn.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onVehicleDespawn = {
	internal = AuroraFramework.libraries.events.create("callback_onVehicleDespawn_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onVehicleDespawn_addon")
}

function onVehicleDespawn(...)
	AuroraFramework.game.callbacks.onVehicleDespawn.internal:fire(...)
	AuroraFramework.game.callbacks.onVehicleDespawn.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onVehicleLoad = {
	internal = AuroraFramework.libraries.events.create("callback_onVehicleLoad_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onVehicleLoad_addon")
}

function onVehicleLoad(...)
	AuroraFramework.game.callbacks.onVehicleLoad.internal:fire(...)
	AuroraFramework.game.callbacks.onVehicleLoad.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onVehicleUnload = {
	internal = AuroraFramework.libraries.events.create("callback_onVehicleUnload_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onVehicleUnload_addon")
}

function onVehicleUnload(...)
	AuroraFramework.game.callbacks.onVehicleUnload.internal:fire(...)
	AuroraFramework.game.callbacks.onVehicleUnload.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onVehicleTeleport = {
	internal = AuroraFramework.libraries.events.create("callback_onVehicleTeleport_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onVehicleTeleport_addon")
}

function onVehicleTeleport(...)
	AuroraFramework.game.callbacks.onVehicleTeleport.internal:fire(...)
	AuroraFramework.game.callbacks.onVehicleTeleport.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onObjectLoad = {
	internal = AuroraFramework.libraries.events.create("callback_onObjectLoad_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onObjectLoad_addon")
}

function onObjectLoad(...)
	AuroraFramework.game.callbacks.onObjectLoad.internal:fire(...)
	AuroraFramework.game.callbacks.onObjectLoad.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onObjectUnload = {
	internal = AuroraFramework.libraries.events.create("callback_onObjectUnload_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onObjectUnload_addon")
}

function onObjectUnload(...)
	AuroraFramework.game.callbacks.onObjectUnload.internal:fire(...)
	AuroraFramework.game.callbacks.onObjectUnload.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onButtonPress = {
	internal = AuroraFramework.libraries.events.create("callback_onButtonPress_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onButtonPress_addon")
}

function onButtonPress(...)
	AuroraFramework.game.callbacks.onButtonPress.internal:fire(...)
	AuroraFramework.game.callbacks.onButtonPress.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onCreatureSit = {
	internal = AuroraFramework.libraries.events.create("callback_onCreatureSit_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onCreatureSit_addon")
}

function onCreatureSit(...)
	AuroraFramework.game.callbacks.onCreatureSit.internal:fire(...)
	AuroraFramework.game.callbacks.onCreatureSit.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onCreatureUnsit = {
	internal = AuroraFramework.libraries.events.create("callback_onCreatureUnsit_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onCreatureUnsit_addon")
}

function onCreatureUnsit(...)
	AuroraFramework.game.callbacks.onCreatureUnsit.internal:fire(...)
	AuroraFramework.game.callbacks.onCreatureUnsit.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onCreaturePickup = {
	internal = AuroraFramework.libraries.events.create("callback_onCreaturePickup_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onCreaturePickup_addon")
}

function onCreaturePickup(...)
	AuroraFramework.game.callbacks.onCreaturePickup.internal:fire(...)
	AuroraFramework.game.callbacks.onCreaturePickup.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onSpawnAddonComponent = {
	internal = AuroraFramework.libraries.events.create("callback_onSpawnAddonComponent_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onSpawnAddonComponent_addon")
}

function onSpawnAddonComponent(...)
	AuroraFramework.game.callbacks.onSpawnAddonComponent.internal:fire(...)
	AuroraFramework.game.callbacks.onSpawnAddonComponent.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onVehicleDamaged = {
	internal = AuroraFramework.libraries.events.create("callback_onVehicleDamaged_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onVehicleDamaged_addon")
}

function onVehicleDamaged(...)
	AuroraFramework.game.callbacks.onVehicleDamaged.internal:fire(...)
	AuroraFramework.game.callbacks.onVehicleDamaged.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.httpReply = {
	internal = AuroraFramework.libraries.events.create("callback_httpReply_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_httpReply_addon")
}

function httpReply(...)
	AuroraFramework.game.callbacks.httpReply.internal:fire(...)
	AuroraFramework.game.callbacks.httpReply.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onFireExtinguished = {
	internal = AuroraFramework.libraries.events.create("callback_onFireExtinguished_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onFireExtinguished_addon")
}

function onFireExtinguished(...)
	AuroraFramework.game.callbacks.onFireExtinguished.internal:fire(...)
	AuroraFramework.game.callbacks.onFireExtinguished.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onForestFireSpawned = {
	internal = AuroraFramework.libraries.events.create("callback_onForestFireSpawned_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onForestFireSpawned_addon")
}

function onForestFireSpawned(...)
	AuroraFramework.game.callbacks.onForestFireSpawned.internal:fire(...)
	AuroraFramework.game.callbacks.onForestFireSpawned.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onForestFireExtinguised = {
	internal = AuroraFramework.libraries.events.create("callback_onForestFireExtinguised_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onForestFireExtinguised_addon")
}

function onForestFireExtinguised(...)
	AuroraFramework.game.callbacks.onForestFireExtinguised.internal:fire(...)
	AuroraFramework.game.callbacks.onForestFireExtinguised.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onTornado = {
	internal = AuroraFramework.libraries.events.create("callback_onTornado_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onTornado_addon")
}

function onTornado(...)
	AuroraFramework.game.callbacks.onTornado.internal:fire(...)
	AuroraFramework.game.callbacks.onTornado.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onMeteor = {
	internal = AuroraFramework.libraries.events.create("callback_onMeteor_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onMeteor_addon")
}

function onMeteor(...)
	AuroraFramework.game.callbacks.onMeteor.internal:fire(...)
	AuroraFramework.game.callbacks.onMeteor.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onTsunami = {
	internal = AuroraFramework.libraries.events.create("callback_onTsunami_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onTsunami_addon")
}

function onTsunami(...)
	AuroraFramework.game.callbacks.onTsunami.internal:fire(...)
	AuroraFramework.game.callbacks.onTsunami.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onWhirlpool = {
	internal = AuroraFramework.libraries.events.create("callback_onWhirlpool_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onWhirlpool_addon")
}

function onWhirlpool(...)
	AuroraFramework.game.callbacks.onWhirlpool.internal:fire(...)
	AuroraFramework.game.callbacks.onWhirlpool.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onVolcano = {
	internal = AuroraFramework.libraries.events.create("callback_onVolcano_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onVolcano_addon")
}

function onVolcano(...)
	AuroraFramework.game.callbacks.onVolcano.internal:fire(...)
	AuroraFramework.game.callbacks.onVolcano.main:fire(...)
end

----------------

AuroraFramework.game.callbacks.onOilSpill = {
	internal = AuroraFramework.libraries.events.create("callback_onOilSpill_frameworkInternal"),
	main = AuroraFramework.libraries.events.create("callback_onOilSpill_addon")
}

function onOilSpill(...)
	AuroraFramework.game.callbacks.onOilSpill.internal:fire(...)
	AuroraFramework.game.callbacks.onOilSpill.main:fire(...)
end

--------------------------------------------------------------------------------
--// Inits \\--
--------------------------------------------------------------------------------
AuroraFramework.services.playerService.initialize()
AuroraFramework.services.vehicleService.initialize()
AuroraFramework.services.chatService.initialize()
AuroraFramework.services.commandService.initialize()
AuroraFramework.services.HTTPService.initialize()
AuroraFramework.services.UIService.initialize()
AuroraFramework.services.TPSService.initialize()

AuroraFramework.libraries.timer.handler()