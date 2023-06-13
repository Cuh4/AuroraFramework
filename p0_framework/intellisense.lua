-------------------------------------------------
-------------------------- Game Callbacks
-------------------------------------------------

---@class af_game_callbacks_callback
---@field internal af_libs_event_event To be used by the framework
---@field main af_libs_event_event To be used by your addon

-------------------------------------------------
-------------------------- Services
-------------------------------------------------

---------------- UI
---@class af_services_ui_screen
---@field properties af_services_ui_screen_properties The properties of this UI
---@field refresh function<self> Refreshes the UI
---@field remove function<self> Remove this UI

---@class af_services_ui_screen_properties
---@field x number -1 to 1
---@field y number -1 to 1
---@field text string The text shown in the UI
---@field visible boolean Whether or not this UI is visible
---@field player af_services_player_player|nil The player this UI is shown to. Everyone if nil
---@field id number The ID of this UI

---@class af_services_ui_map_label
---@field properties af_services_ui_map_label_properties The properties of this UI
---@field refresh function<self> Refreshes the UI
---@field remove function<self> Remove this UI

---@class af_services_ui_map_label_properties
---@field pos SWMatrix The position where this UI is shown on the map
---@field text string The text shown in the UI
---@field visible boolean Whether or not this UI is visible
---@field player af_services_player_player|nil The player this UI is shown to. Everyone if nil
---@field id number The ID of this UI
---@field labelType SWLabelTypeEnum The type of label

---@class af_services_ui_map_object
---@field properties af_services_ui_map_object_properties The properties of this UI
---@field refresh function<self> Refreshes the UI
---@field remove function<self> Remove this UI
---@field attach function<self, integer, integer> First param == Position Type, Second Param == Object ID/Vehicle ID

---@class af_services_ui_map_object_properties
---@field pos SWMatrix The position where this UI is shown on the map
---@field title string The title
---@field subtitle string The subtitle
---@field visible boolean Whether or not this UI is visible
---@field player af_services_player_player|nil The player this UI is shown to. Everyone if nil
---@field id number The ID of this UI
---@field objectType SWMarkerTypeEnum The type of map object
---@field positionType SWPositionTypeEnum 0, 1, or 2 (fixed, vehicle, object)
---@field attachID integer Vehicle ID/Object ID
---@field r integer 0-255
---@field g integer 0-255
---@field b integer 0-255
---@field a integer 0-255
---@field radius number The radius of this map object

---------------- HTTP
---@class af_services_http_request
---@field properties af_services_http_request_properties The properties of this request
---@field cancel function<self> Cancel this request

---@class af_services_http_request_properties
---@field port integer The port of this request
---@field url string The URL of this request
---@field event af_libs_event_event Reply event

---------------- Messages
---@class af_services_chat_message
---@field properties af_services_chat_message_properties The properties of this message
---@field delete function<self, af_services_player_player|nil> Delete this message
---@field edit function<self, string, af_services_player_player|nil> Edit this message

---@class af_services_chat_message_properties
---@field author af_services_player_player The player who sent this message
---@field content string The content of this message
---@field id integer The ID of this message
---@field isSentByPlayer boolean True = sent by player, False = sent by addon

---------------- Commands
---@class af_services_commands_command
---@field properties af_services_commands_command_properties The properties of this command
---@field events af_services_commands_command_events The events of this command
---@field remove function<self> Remove this command

---@class af_services_commands_command_events
---@field onActivation af_libs_event_event Event for the activation of this command

---@class af_services_commands_command_properties
---@field name string The name of this command
---@field requiresAdmin boolean Whether or not this command requires admin
---@field requiresAuth boolean Whether or not this command requires auth
---@field description string The description of this command. Unused by this framework
---@field shorthands table<integer, string> The shorthands of this command
---@field capsSensitive boolean Whether or not this command is caps sensitive (true = "?coMmand" doesn't works, false = "?ComMand" works)

---------------- Vehicles
---@class af_services_vehicle_vehicle
---@field properties af_services_vehicle_vehicle_properties The properties of this vehicle
---@field despawn function<self> Despawn this vehicle
---@field explode function<self, number|nil> Explode this vehicle. Second param is optional magnitude (0-1). Weapons DLC required
---@field teleport function<self, SWMatrix> Teleport this vehicle to a position
---@field getPosition function<self, number|nil, number|nil, number|nil> Get the position of this vehicle
---@field getLoadedVehicleData function<self> Raw vehicle data that can be retrieved when this vehicle is loaded
---@field setInvulnerability function<self, boolean> Sets whether or not this vehicle can receive damage (true = invincible, false = can receive damage)
---@field setEditable function<self, boolean> Sets whether or not this vehicle is editable (can be brought to the workbench)
---@field setTooltip function<self, string> Sets the tooltip of this vehicle

---@class af_services_vehicle_vehicle_properties
---@field owner af_services_player_player The owner of this player, or nil if addon spawned
---@field addonSpawned boolean Whether or not this vehicle was spawned by an addon
---@field name string The name of this vehicle
---@field vehicle_id integer The ID of this vehicle
---@field spawnPos SWMatrix The position this vehicle was spawned at
---@field cost number The cost of this vehicle, or 0 if infinite money is on
---@field loaded boolean Whether or not this vehicle is loaded
---@field storage af_libs_storage_storage The storage for this vehicle

---------------- Players
---@class af_services_player_player
---@field properties af_services_player_player_properties The properties of this player
---@field setItem function<self, SWSlotNumberEnum, SWEquipmentTypeEnum, boolean, integer|nil, float|nil> Give this player an item
---@field removeItem function<self, SWSlotNumberEnum> Remove whatever item is in the specified slotf rom this player
---@field kick function<self> Kick this player from the server
---@field ban function<self> Ban this player from the server
---@field teleport function<self, SWMatrix> Teleport this player to a position
---@field getPosition function<self> Get the position of this player
---@field getCharacter function<self> Get the object ID of this player's character
---@field damage function<self, number> Damage this player
---@field kill function<self> Kill this player
---@field setAdmin function<self, boolean> Gives/removes admin from this player
---@field setAuth function<self, boolean> Gives/removes auth from this player

---@class af_services_player_player_properties
---@field steam_id string The Steam ID of this player
---@field name string The name of this player
---@field peer_id integer The ID of this player
---@field admin boolean Whether or not this player is an admin
---@field auth boolean Whether or not this player has auth
---@field isHost boolean Whether or not this player is the host
---@field storage af_libs_storage_storage The storage for this player

-------------------------------------------------
-------------------------- Libraries
-------------------------------------------------

---------------- Storage
---@class af_libs_storage_storage
---@field name string The name of this storage
---@field data table<any, any> Table containing saved data
---
---@field save function<self, any, any> Save a value to this storage
---@field get function<self, any> Retrieve a value saved to this storage
---@field destroy function<self, any> Remove a value saved to this storage
---
---@field remove function<self> Remove this storage

---------------- Timer
---@class af_libs_timer_loop
---@field duration number Duration of the loop in seconds
---@field creationTime number
---@field event af_libs_event_event Event to connect functions to. The loop itself is the first param passed to the event on loop completion
---@field id integer The ID of this loop
---
---@field remove function<self> Remove this loop
---@field setDuration function<self, number> Set the duration of this loop

---@class af_libs_timer_delay
---@field duration number Duration of the delay in seconds
---@field creationTime number
---@field event af_libs_event_event Event to connect functions to. The delay itself is the first param passed to the event on delay completion
---@field id integer The ID of this delay
---
---@field remove function<self> Remove this delay
---@field setDuration function<self, number> Set the duration of this delay

---------------- Events
---@class af_libs_event_event
---@field name string The name of this event
---@field connections table<integer, function> Table containing functions connected to this event
---
---@field fire function<self> Call all functions connected to this event
---@field clear function<self> Clear all functions connected to this event
---@field remove function<self> Remove the event
---@field connect function<self, function> Connect a function to this event