-------------------------------------------------
-- Lua LSP Diagnostics
-------------------------------------------------
---@diagnostic disable missing-return

-------------------------------------------------
-- Game Callbacks
-------------------------------------------------

---@class af_game_callbacks_callback
---@field internal af_libs_event_event To be used by the framework
---@field main af_libs_event_event To be used by your addon

-------------------------------------------------
-- Internal
-------------------------------------------------

---@class af_internal_class
_ = {
    -- The name of this class
    __name__ = "",

    -- The properties of this class
    properties = {},

    -- The events of this class
    events = {}
}

-------------------------------------------------
-- Services
-------------------------------------------------

---------------- UI
---@class af_services_ui_screen: af_internal_class
_ = {
    __name__ = "UIScreen",

    properties = {
        x = 0, -- -1 to 1. -1 being far left of the screen. 0 being center
        y = 0, -- -1 to 1. -1 being the bottom of the screen. 0 being center

        text = "", -- The text shown in the UI
        visible = false, -- Whether or not the UI is visible

        ---@type af_services_player_player|nil
        player = nil, -- The player this UI is shown to. If this is nil, the UI will be shown to everyone

        id = 0 -- The ID of this UI
    },

    -- Refreshes this UI
    ---@param self af_services_ui_screen
    refresh = function(self) end,

    -- Removes this UI
    ---@param self af_services_ui_screen
    remove = function(self) end,
}

---@class af_services_ui_map_label: af_internal_class
_ = {
    __name__ = "UIMapLabel",

    properties = {
        ---@type SWMatrix
        pos = nil, -- The position where this UI is shown on the map

        text = "", -- The text of this map label
        visible = false, -- Whether or not the UI is visible

        ---@type af_services_player_player|nil
        player = nil, -- The player this map label is shown to. If this is nil, the map label is shown to everyone

        id = 0, -- The ID of this UI

        ---@type SWLabelTypeEnum
        labelType = nil, -- The type of label
    },

    -- Refreshes this UI
    ---@param self af_services_ui_map_label
    refresh = function(self) end,

    -- Removes this UI
    ---@param self af_services_ui_map_label
    remove = function(self) end,
}

---@class af_services_ui_map_line: af_internal_class
_ = {
    __name__ = "UIMapLine",

    properties = {
        ---@type SWMatrix
        startPoint = nil, -- Where the line starts

        ---@type SWMatrix
        endPoint = nil, -- Where the line ends

        visible = false, -- Whether or not the UI is visible

        ---@type af_services_player_player|nil
        player = nil, -- The player this map line is shown to. If this is nil, the map line is shown to everyone

        id = 0, -- The ID of this UI

        r = 0, -- RGBA - 0-255
        g = 0, -- RGBA - 0-255
        b = 0, -- RGBA - 0-255
        a = 0, -- RGBA - 0-255
        thickness = 0 -- The thickness of this map line
    },

    -- Refreshes this UI
    ---@param self af_services_ui_map_line
    refresh = function(self) end,

    -- Removes this UI
    ---@param self af_services_ui_map_line
    remove = function(self) end
}

---@class af_services_ui_map_object: af_internal_class
_ = {
    __name__ = "UIMapObject",

    properties = {
        ---@type SWMatrix
        pos = nil, -- The position where this UI is shown on the map

        title = "", -- The title of this map object
        subtitle = "", -- The subtitle of this map object
        visible = false, -- Whether or not the UI is visible

        ---@type af_services_player_player|nil
        player = nil, -- The player this map object is shown to. If this is nil, the map object is shown to everyone

        id = 0, -- The ID of this UI

        ---@type SWMarkerTypeEnum
        markerType = nil, -- The type of map object

        ---@type SWPositionTypeEnum
        positionType = nil, -- 0, 1, or 2 (fixed, vehicle, object)

        attachID = 0, -- Vehicle ID/Object ID. 0 if not attached
        r = 0, -- RGBA - 0-255
        g = 0, -- RGBA - 0-255
        b = 0, -- RGBA - 0-255
        a = 0, -- RGBA - 0-255
        radius = 0 -- The radius of this map object
    },

    -- Refreshes this UI
    ---@param self af_services_ui_map_object
    refresh = function(self) end,

    -- Removes this UI
    ---@param self af_services_ui_map_object
    remove = function(self) end,

    -- Make this UI follow a vehicle or object
    ---@param self af_services_ui_map_object
    ---@param positionType SWPositionTypeEnum
    ---@param objectOrVehicleID integer
    attach = function(self, positionType, objectOrVehicleID) end
}

---------------- HTTP
---@class af_services_http_request: af_internal_class
_ = {
    __name__ = "httpRequest",

    properties = {
        port = 0, -- The destination port of this request
        url = "" -- The destination URL of this request. Always localhost
    },

    events = {
        ---@type af_libs_event_event
        reply = nil -- This event is called when this request receives a reply
    },

    -- Cancel this HTTP request
    ---@param self af_services_http_request
    cancel = function(self) end
}

---------------- Messages
---@class af_services_chat_message: af_internal_class
_ = {
    __name__ = "chatMessage",

    properties = {
        ---@type af_services_player_player
        author = nil, -- The player who sent this message

        content = "", -- The content of this message
        id = 0 -- The ID of this message
    },

    -- Delete this message for everyone or just a specific player
    ---@param self af_services_chat_message
    ---@param player af_services_player_player|nil
    delete = function(self, player) end,

    -- Edit this message for everyone or just a specific player
    ---@param self af_services_chat_message
    ---@param newContent string
    ---@param player af_services_player_player|nil
    edit = function(self, newContent, player) end
}

---------------- Commands
---@class af_services_command_command: af_internal_class
_ = {
    __name__ = "command",

    properties = {
        name = "", -- The name of this command
        requiresAdmin = false, -- Whether or not this command requires admin
        requiresAuth = false, -- Whether or not this command requires auth
        description = "", -- The description of this command. Unused by this framework

        ---@type table<integer, string>
        shorthands = {}, -- The shorthands of this command
        capsSensitive = false -- Whether or not this command is caps-sensitive.
    },

    events = {
        ---@type af_libs_event_event
        activation = nil -- This event is fired when the command is used by a player
    },

    -- Remove this command
    ---@param self af_services_command_command
    remove = function(self) end
}

---------------- Groups
---@class af_services_group_group: af_internal_class
_ = {
    __name__ = "group",

    properties = {
        ---@type table<integer, af_services_vehicle_vehicle>
        vehicles = {}, -- The vehicles that belong to this group

        ---@type SWMatrix
        spawnPos = nil,

        ---@type af_services_vehicle_vehicle
        primaryVehicle = nil,

        ---@type af_services_player_player
        owner = nil, -- The owner of this group

        addonSpawned = false, -- Whether or not this group was spawned by the server
        cost = 0, -- The cost of this vehicle
        group_id = 0 -- The ID of this group
    },

    -- Teleport this group
    ---@param self af_services_group_group
    ---@param position SWMatrix
    teleport = function(self, position) end,

    -- Move this group, basically teleporting it without reloading the vehicle
    ---@param self af_services_group_group
    ---@param position SWMatrix
    move = function(self, position) end,

    -- Despawn all vehicles in the group, despawning the group itself
    ---@param self af_services_group_group
    despawn = function(self) end,

    -- Get the position of this group
    ---@param self af_services_group_group
    getPosition = function(self) end,

    -- Get a vehicle that is apart of this group
    ---@param self af_services_group_group
    ---@param vehicle_id integer
    getVehicle = function(self, vehicle_id) end
}

---------------- Vehicles
---@class af_services_vehicle_vehicle: af_internal_class
_ = {
    __name__ = "vehicle",

    properties = {
        ---@type af_services_player_player
        owner = nil, -- The owner of this vehicle

        ---@type af_services_group_group
        group = nil, -- The group this vehicle belongs to
        isPrimaryVehicle = false, -- Whether or not this is the main vehicle in a group

        addonSpawned = false, -- Whether or not an addon spawned this vehicle
        vehicle_id = 0, -- The ID of this vehicle

        ---@type SWMatrix
        spawnPos = nil, -- The position this vehicle was spawned at

        cost = 0 -- The cost of this vehicle. 0 if infinite_money is enabled
    },

    -- Despawn this vehicle
    ---@param self af_services_vehicle_vehicle
    despawn = function(self) end,

    -- Explode this vehicle
    ---@param self af_services_vehicle_vehicle
    ---@param magnitude number|nil
    ---@param despawn boolean|nil
    explode = function(self, magnitude, despawn) end,

    -- Move this vehicle somewhere, keeping the vehicle's velocity and not reloading the vehicle
    ---@param self af_services_vehicle_vehicle
    ---@param position SWMatrix
    move = function(self, position) end,

    -- Teleport this vehicle somewhere
    ---@param self af_services_vehicle_vehicle
    ---@param position SWMatrix
    teleport = function(self, position) end,

    -- Repairs this vehicle
    ---@param self af_services_vehicle_vehicle
    repair = function(self) end,

    -- Get the position of this vehicle
    ---@param self af_services_vehicle_vehicle
    ---@param voxelX number|nil
    ---@param voxelY number|nil
    ---@param voxelZ number|nil
    ---@return SWMatrix
    getPosition = function(self, voxelX, voxelY, voxelZ) end,

    -- Get the vehicle's data
    ---@param self af_services_vehicle_vehicle
    ---@return SWVehicleData
    getVehicleData = function(self) end,

    -- Get the vehicle's components
    ---@param self af_services_vehicle_vehicle
    ---@return SWVehicleComponents
    getVehicleComponents = function(self) end,

    -- Sets whether or not the vehicle is invulnerable to damage
    ---@param self af_services_vehicle_vehicle
    ---@param isInvulnerable boolean
    setInvulnerable = function(self, isInvulnerable) end,

    -- Sets whether or not the vehicle is editable (can be brought to workbench)
    ---@param self af_services_vehicle_vehicle
    ---@param isEditable boolean
    setEditable = function(self, isEditable) end,

    -- Sets whether or not the vehicle is visible on the map
    ---@param self af_services_vehicle_vehicle
    ---@param isVisible boolean
    setMapVisibility = function(self, isVisible) end,

    -- Sets the tooltip of this vehicle
    ---@param self af_services_vehicle_vehicle
    ---@param text string
    setTooltip = function(self, text) end
}

---------------- Players
---@class af_services_player_player: af_internal_class
_ = {
    __name__ = "player",

    properties = {
        steam_id = "",
        name = "",
        peer_id = 0,
        admin = false,
        auth = false,
        isHost = false
    },

    -- Give this player an item
    ---@param self af_services_player_player
    ---@param slot SWSlotNumberEnum
    ---@param type SWEquipmentTypeEnum
    ---@param active boolean|nil
    ---@param int integer|nil
    ---@param float number|nil
    setItem = function(self, slot, type, active, int, float) end,

    -- Remove an item from this player
    ---@param self af_services_player_player
    ---@param slot SWSlotNumberEnum
    removeItem = function(self, slot) end,

    -- Get an item this player has equipped
    ---@param self af_services_player_player
    ---@param slot SWSlotNumberEnum
    ---@return integer
    getItem = function(self, slot) end,

    -- Kick this player
    ---@param self af_services_player_player
    kick = function(self) end,

    -- Ban this player
    ---@param self af_services_player_player
    ban = function(self) end,

    -- Teleport this player somewhere
    ---@param self af_services_player_player
    ---@param position SWMatrix
    teleport = function(self, position) end,

    -- Get the position of this player
    ---@param self af_services_player_player
    ---@return SWMatrix
    getPosition = function(self) end,

    -- Get this player's character ID
    ---@param self af_services_player_player
    ---@return integer
    getCharacter = function(self) end,

    -- Damage this player. Supply a negative number to heal the player
    ---@param self af_services_player_player
    ---@param damageToDeal number
    damage = function(self, damageToDeal) end,

    -- Kill this player
    ---@param self af_services_player_player
    kill = function(self) end,

    -- Revive this player
    ---@param self af_services_player_player
    revive = function(self) end,

    -- Give or removes admin to/from the player
    ---@param self af_services_player_player
    ---@param shouldGive boolean
    setAdmin = function(self, shouldGive) end,

    -- Give or removes auth to/from the player
    ---@param self af_services_player_player
    ---@param shouldGive boolean
    setAuth = function(self, shouldGive) end
}

-------------------------------------------------
-- Libraries
-------------------------------------------------

---------------- Timer
---@class af_libs_timer_loop: af_internal_class
_ = {
    __name__ = "loop",

    properties = {
        duration = 0, -- Duration of the loop in seconds
        creationTime = 0, -- The time this loop was created
        id = 0 -- The ID of this loop
    },

    events = {
        ---@type af_libs_event_event
        completion = nil -- The event that is fired when the loop is completed
    },

    ---@param self af_libs_timer_loop
    remove = function(self) end, -- Remove this loop

    ---@param self af_libs_timer_loop
    ---@param duration number
    setDuration = function(self, duration) end -- Sets the duration of this loop
}

---@class af_libs_timer_delay: af_internal_class
_ = {
    __name__ = "delay",

    properties = {
        duration = 0, -- Duration of the delay in seconds
        creationTime = 0, -- The time this delay was created
        id = 0 -- The ID of this delay
    },

    events = {
        ---@type af_libs_event_event
        completion = nil -- The event that is fired when the delay is completed
    },

    ---@param self af_libs_timer_delay
    remove = function(self) end, -- Remove this delay

    ---@param self af_libs_timer_delay
    ---@param duration number
    setDuration = function(self, duration) end -- Sets the duration of this delay
}

---------------- Events
---@class af_libs_event_event: af_internal_class
_ = {
    __name__ = "event",
    name = "", -- The name of this event

    properties = {
        ---@type table<integer, function>
        connections = {} -- All functions connected to this event
    },

    -- Fire this event by calling all functions
    ---@param self af_libs_event_event
    ---@param ... any
    fire = function(self, ...) end,

    -- Remove all connections to this event
    ---@param self af_libs_event_event
    clear = function(self) end,

    -- Remove this event from the saved events
    ---@param self af_libs_event_event
    remove = function(self) end,

    -- Connect a function to this event
    ---@param self af_libs_event_event
    ---@param callback function
    connect = function(self, callback) end
}

---------------- Miscellaneous
---@class af_libs_miscellaneous_pid: af_internal_class
_ = {
    __name__ = "PID",

    properties = {
        proportional = 0,
        integral = 0,
        derivative = 0,

        _E = 0,
        _D = 0,
        _I = 0
    },

    -- Run the PID
    ---@param self af_libs_miscellaneous_pid
    ---@param setPoint number
    ---@param processVariable number
    ---@return number
    run = function(self, setPoint, processVariable) end
}