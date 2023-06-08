-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@class EventTypes.OnTick : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, gameTicks:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnCreate : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnDestroy : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnCustomCommand : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, fullMessage:string, peerID:number, isAdmin:boolean, isAuth:boolean, command:string, ...:string), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnChatMessage : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, peerID:number, senderName:string, message:string), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnPlayerJoin : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, steamID:number, name:number, peerID:number, isAdmin:boolean, isAuth:boolean), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnPlayerSit : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, peerID:number, vehicleID:number, seatName:string), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnPlayerUnsit : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, peerID:number, vehicleID:number, seatName:string), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnCharacterSit : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, objectID:number, vehicleID:number, seatName:string), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnCharacterUnsit : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, objectID:number, vehicleID:number, seatName:string), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnPlayerRespawn : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, peerID:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnPlayerLeave : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, steamID:number, name:string, peerID:number, isAdmin:boolean, isAuth:boolean), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnToggleMap : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, peerID:number, isOpen:boolean), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnPlayerDie : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, steamID:number, name:string, peerID:number, isAdmin:boolean, isAuth:boolean), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnVehicleSpawn : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, vehicleID:number, peerID:number, x:number, y:number, z:number, cost:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnVehicleDespawn : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, vehicleID:number, peerID:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnVehicleLoad : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, vehicleID:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnVehicleUnload : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, vehicleID:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnVehicleTeleport : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, vehicleID:number, peerID:number, x:number, y:number, z:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnObjectLoad : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, objectID:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnObjectUnload : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, objectID:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnButtonPress : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, vehicleID:number, peerID:number, buttonName:string), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnSpawnAddonComponent : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, vehicleOrObjectID:number, componentName:string, componentType:string, addonIndex:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnVehicleDamaged : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, vehicleID:number, damageAmount:number, voxelX:number, voxelZ:number, voxelZ:number, bodyIndex:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class httpReply : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, port:number, request:string, reply:string), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnFireExtinguished : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, fireX:number, fireY:number, fireZ:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnForestFireSpawned : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, fireObjectiveID:number, fireX:number, fireY:number, fireZ:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnForestFireExtinguised : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, fireObjectiveID:number, fireX:number, fireY:number, fireZ:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnTornado : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, transform:SWMatrix), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnMeteor : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, transform:SWMatrix, magnitude:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnTsunami : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, transform:SWMatrix, magnitude:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnWhirlpool : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, transform:SWMatrix, magnitude:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.OnVolcano : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, transform:SWMatrix), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener


--- Note: onTick handled by TickManager otherwise could cause significantly performance overhead, unnecessarily
---@class LifeBoatAPI.EventManager                
---@field onCreate                  EventTypes.OnCreate                
---@field onDestroy                 EventTypes.OnDestroy               
---@field onCustomCommand           EventTypes.OnCustomCommand         
---@field onChatMessage             EventTypes.OnChatMessage           
---@field onPlayerJoin              EventTypes.OnPlayerJoin            
---@field onPlayerSit               EventTypes.OnPlayerSit             
---@field onPlayerUnsit             EventTypes.OnPlayerUnsit           
---@field onCharacterSit            EventTypes.OnCharacterSit          
---@field onCharacterUnsit          EventTypes.OnCharacterUnsit        
---@field onPlayerRespawn           EventTypes.OnPlayerRespawn         
---@field onPlayerLeave             EventTypes.OnPlayerLeave           
---@field onToggleMap               EventTypes.OnToggleMap             
---@field onPlayerDie               EventTypes.OnPlayerDie             
---@field onVehicleSpawn            EventTypes.OnVehicleSpawn          
---@field onVehicleDespawn          EventTypes.OnVehicleDespawn        
---@field onVehicleLoad             EventTypes.OnVehicleLoad           
---@field onVehicleUnload           EventTypes.OnVehicleUnload         
---@field onVehicleTeleport         EventTypes.OnVehicleTeleport       
---@field onObjectLoad              EventTypes.OnObjectLoad            
---@field onObjectUnload            EventTypes.OnObjectUnload          
---@field onButtonPress             EventTypes.OnButtonPress           
---@field onSpawnAddonComponent     EventTypes.OnSpawnAddonComponent   
---@field onVehicleDamaged          EventTypes.OnVehicleDamaged        
---@field httpReply                 LifeBoatAPI.Event               
---@field onFireExtinguished        EventTypes.OnFireExtinguished      
---@field onForestFireSpawned       EventTypes.OnForestFireSpawned     
---@field onForestFireExtinguised   EventTypes.OnForestFireExtinguised 
---@field onTornado                 EventTypes.OnTornado               
---@field onMeteor                  EventTypes.OnMeteor                
---@field onTsunami                 EventTypes.OnTsunami               
---@field onWhirlpool               EventTypes.OnWhirlpool             
---@field onVolcano                 EventTypes.OnVolcano
---
---@field trackSitUnsit boolean whether to track sitting/unsitting from vehicle object API
---@field trackVehicleDamage boolean whether to track vehicle damage from vehicle object API; potentially performance heavy
---@field trackVehicleTeleport boolean whether to track vehicles teleporting, via vehicle object API
---@field trackButtonPress boolean whether to track button presses via the vehicle object API
---@field trackPlayerSpawnVehicle boolean whether to track via player object API
---@field trackPlayerLife boolean whether to track via player object API
---@field trackPlayerCommand boolean whether to track via player object API
---@field trackPlayerChat boolean whether to track via player object API
---@field trackPlayerMap boolean whether to track via player object API
LifeBoatAPI.EventManager = {
	callbacksList = {
	    "onDestroy",
		"onCustomCommand", "onChatMessage",
		"onPlayerJoin", "onPlayerSit", "onPlayerUnsit", "onPlayerRespawn", "onPlayerLeave", "onPlayerDie",
		"onCharacterSit", "onCharacterUnsit", 
		"onToggleMap",
		"onVehicleSpawn", "onVehicleDespawn", "onVehicleLoad", "onVehicleUnload", "onVehicleTeleport", "onVehicleDamaged",
		"onObjectLoad", "onObjectUnload", "onButtonPress",
		"onSpawnAddonComponent",
		"httpReply",
		"onFireExtinguished", "onForestFireSpawned", "onForestFireExtinguised",
		"onTornado", "onMeteor", "onTsunami", "onWhirlpool", "onVolcano",
	};

    ---@return LifeBoatAPI.EventManager
	new = function(cls)
        local self = {
            callbacksList = cls.callbacksList,
            onCreate = LifeBoatAPI.Event:new(),
            
            --- methods
            init = cls.init,
            _setupAdditionalEvents = cls._setupAdditionalEvents,
        }
        for i=1, #self.callbacksList do
            local callbackName = self.callbacksList[i]
            self[callbackName] = LifeBoatAPI.ENVCallbackEvent:new(callbackName)
        end

        return self
	end;

    -- should be called after all globals are setup
	---@param self LifeBoatAPI.EventManager
	init = function(self)
		for i=1, #self.callbacksList do
			local callbackName = self.callbacksList[i]
			self[callbackName]:init()
		end

		self:_setupAdditionalEvents()
	end;

    --- Event tracking for a better interface, but can be performance heavy if not used
	---@param self LifeBoatAPI.EventManager
	_setupAdditionalEvents = function(self)
        local players = LB.players;
        local objects = LB.objects;

		if self.trackVehicleTeleport then
            LB.events.onVehicleTeleport:register(function (l, context, vehicle_id, peer_id, x, y, z)
                local vehicle = objects.vehiclesByID[vehicle_id]
                local player = players.playersByPeerID[peer_id]
                if vehicle and vehicle.onTeleport.hasListeners then
                    vehicle.onTeleport:trigger(vehicle, player, x, y, z)
                end

                if player and player.onTeleport.hasListeners then
                    player.onTeleport:trigger(player, vehicle, x,y,z)
                end
            end)
		end


		if self.trackButtonPress then
            LB.events.onButtonPress:register(function (l, context, vehicle_id, peer_id, button_name)
                local vehicle = objects.vehiclesByID[vehicle_id]
                local player = players.playersByPeerID[peer_id]
                if vehicle and vehicle.onButtonPress.hasListeners then
                    vehicle.onButtonPress:trigger(vehicle, player, button_name)
                end

                if player and player.onButtonPress.hasListeners then
                    player.onButtonPress:trigger(player, vehicle, button_name)
                end
            end)
		end


		if self.trackSitUnsit then
            -- player seating
            LB.events.onPlayerSit:register(function (l, context, peer_id, vehicle_id, seat_name)
                local vehicle = objects.vehiclesByID[vehicle_id]
                local player = players.playersByPeerID[peer_id]
                if vehicle and vehicle.onSeatedChange.hasListeners then
                    vehicle.onSeatedChange:trigger(vehicle, player, nil, seat_name, true)
                end

                if player and player.onSeatedChange.hasListeners then
                    player.onSeatedChange:trigger(player, vehicle, seat_name, true)
                end
            end)

            LB.events.onPlayerUnsit:register(function (l, context, peer_id, vehicle_id, seat_name)
                local vehicle = objects.vehiclesByID[vehicle_id]
                local player = players.playersByPeerID[peer_id]
                if vehicle and vehicle.onSeatedChange.hasListeners then
                    vehicle.onSeatedChange:trigger(vehicle, player, nil,  seat_name, false)
                end

                if player and player.onSeatedChange.hasListeners then
                    player.onSeatedChange:trigger(player, vehicle, seat_name, false)
                end
            end)

            -- non-player seating change
            LB.events.onCharacterSit:register(function (l, context, object_id, vehicle_id, seat_name)
                local vehicle = objects.vehiclesByID[vehicle_id]
                if vehicle and vehicle.onSeatedChange.hasListeners then
                    vehicle.onSeatedChange:trigger(vehicle, nil, object_id, seat_name, true)
                end
            end)

            LB.events.onCharacterUnsit:register(function (l, context, object_id, vehicle_id, seat_name)
                local vehicle = objects.vehiclesByID[vehicle_id]
                if vehicle and vehicle.onSeatedChange.hasListeners then
                    vehicle.onSeatedChange:trigger(vehicle, object_id, seat_name, false)
                end
            end)
		end


        if self.trackVehicleDamage then
            LB.events.onVehicleDamaged:register(function (l, context, vehicle_id, damage_amount, voxel_x, voxel_y, voxel_z, body_index)
                local vehicle = objects.vehiclesByID[vehicle_id]
                if vehicle and vehicle.onDamaged.hasListeners then
                    vehicle.onDamaged:trigger(vehicle, damage_amount, voxel_x, voxel_y, voxel_z, body_index)
                end
            end)
        end

        if self.trackPlayerSpawnVehicle then
            LB.events.onVehicleSpawn:register(function (l, context, vehicle_id, peer_id, x, y, z, cost)
                local player = players.playersByPeerID[peer_id]
                if player and player.onSpawnVehicle.hasListeners then
                    player.onSpawnVehicle:trigger(player, vehicle_id, x,y,z, cost)
                end
            end)
        end

        if self.trackPlayerLife then
            LB.events.onPlayerDie:register(function (l, context, steam_id, name, peer_id, is_admin, is_auth)
                local player = players.playersByPeerID[peer_id]
                if player and player.onAliveChanged.hasListeners then
                    player.onAliveChanged:trigger(player, false)
                end
            end)
            
            LB.events.onPlayerRespawn:register(function (l, context, peer_id)
                local player = players.playersByPeerID[peer_id]
                if player and player.onAliveChanged.hasListeners then
                    player.onAliveChanged:trigger(player, true)
                end
            end)
        end

        if self.trackPlayerCommand then
            LB.events.onCustomCommand:register(function (l, context, full_message, peer_id, is_admin, is_auth, command, ...)
                local player = players.playersByPeerID[peer_id]
                if player and player.onCommand.hasListeners then
                    player.onCommand:trigger(player, full_message, command, ...)
                end
            end)
        end

        if self.trackPlayerChat then
            LB.events.onChatMessage:register(function (l, context, peer_id, sender_name, message)
                local player = players.playersByPeerID[peer_id]
                if player and player.onChat.hasListeners then
                    player.onChat:trigger(player, message)
                end
            end)
        end

        if self.trackPlayerMap then
            LB.events.onToggleMap:register(function (l, context, peer_id, is_open)
                local player = players.playersByPeerID[peer_id]
                if player and player.onToggleMap.hasListeners then
                    player.onToggleMap:trigger(player, is_open)
                end
            end)
        end
	end;
}