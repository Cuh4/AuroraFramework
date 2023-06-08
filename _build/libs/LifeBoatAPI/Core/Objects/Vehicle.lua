-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@class EventTypes.LBOnCollisionStart_Vehicle : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, vehicle:LifeBoatAPI.Vehicle, collision:LifeBoatAPI.Collision, zone:LifeBoatAPI.Zone), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.LBOnDespawn_Vehicle : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, vehicle:LifeBoatAPI.Vehicle), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.LBOnLoaded_Vehicle : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, vehicle:LifeBoatAPI.Vehicle), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.LBOnTeleport_Vehicle : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, vehicle:LifeBoatAPI.Vehicle, player: LifeBoatAPI.Player, x:number, y:number, z:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.LBOnButtonPress_Vehicle : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, vehicle:LifeBoatAPI.Vehicle, player:LifeBoatAPI.Player, buttonName:string), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.LBOnSeatedChange_Vehicle : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, vehicle:LifeBoatAPI.Vehicle, player:LifeBoatAPI.Player|nil, objectID:number|nil, seatName:string, isSitting:boolean), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.LBOnDamaged_Vehicle : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, vehicle:LifeBoatAPI.Vehicle, damageAmount:number, voxelX:number, voxelY:number, voxelZ:number, bodyIndex:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class LifeBoatAPI.Vehicle : LifeBoatAPI.GameObject
---@field onCollision EventTypes.LBOnCollisionStart_Vehicle
---@field onDespawn EventTypes.LBOnDespawn_Vehicle
---@field onLoaded EventTypes.LBOnLoaded_Vehicle
---@field onDamaged EventTypes.LBOnDamaged_Vehicle
---@field onTeleport EventTypes.LBOnTeleport_Vehicle 
---@field onButtonPress EventTypes.LBOnButtonPress_Vehicle
---@field onSeatedChange EventTypes.LBOnSeatedChange_Vehicle
---@field childZones LifeBoatAPI.Zone[]
---@field childFires LifeBoatAPI.Fire[]
LifeBoatAPI.Vehicle = {
    ---@param cls LifeBoatAPI.Vehicle
    fromSavedata = function(cls, savedata)
        local self = {
            savedata = savedata,
            id = savedata.id,
            transform = savedata.transform or LifeBoatAPI.Matrix:newMatrix(),
            nextUpdateTick = 0,
            collisionRadius = 0,
            childFires = {},
            childZones = {},

            -- events
            onDamaged = LifeBoatAPI.Event:new(),
            onTeleport = LifeBoatAPI.Event:new(),
            onButtonPress = LifeBoatAPI.Event:new(),
            onSeatedChange = LifeBoatAPI.Event:new(),
            onLoaded = LifeBoatAPI.Event:new(),
            onDespawn = LifeBoatAPI.Event:new(),
            onCollision = LifeBoatAPI.Event:new(),

            -- methods
            awaitLoaded = cls.awaitLoaded,
            getTransform = cls.getTransform,
            attach = LifeBoatAPI.lb_attachDisposable,
            despawn = LifeBoatAPI.GameObject.despawn,
            onDispose = cls.onDispose,
            init = cls.init,
            setCollisionLayer = LifeBoatAPI.GameObject.setCollisionLayer
        }
        return self
    end;

    -- needs done slightly differently due to parenting order
    ---@param self LifeBoatAPI.Vehicle
    init = function(self)
        -- ensure position is up to date
        self:getTransform()

        -- run init script (before enabling collision detection, so it can be cancelled if wanted)
        local script = LB.objects.onInitScripts[self.savedata.onInitScript]
        if script then
            script(self)
        end
        
        if server.getVehicleSimulating(self.id) then
            LB.collision:trackEntity(self)
        end
    end;

    ---@param cls LifeBoatAPI.Vehicle
    ---@param component LifeBoatAPI.AddonComponent
    ---@param spawnData SWAddonComponentSpawned
    fromAddonSpawn = function(cls, component, spawnData)
        local obj = cls:fromSavedata({
            id = spawnData.id,
            type = "vehicle",
            isAddonSpawn = true,
            tags = component.tags,
            dynamicType = component.rawdata.dynamic_object_type,
            name = component.rawdata.display_name,
            transform = spawnData.transform,
            collisionLayer = component.tags["collisionLayer"],
            onInitScript = component.tags["onInitScript"]
        })

        LB.objects:trackEntity(obj)

        return obj
    end;

    ---@param vehicleID number
    ---@param collisionLayer string|nil (ignored if isStatic) leave nil if this shouldn't perform collision checks
    ---@return LifeBoatAPI.Vehicle
    fromUntrackedSpawn = function(cls, vehicleID, ownerPeerID, spawnCost, collisionLayer, onInitScript)
        -- ensure no duplicates, from multiple-listeners
        local existing = LB.objects:getVehicle(vehicleID)
        if existing then
            return existing
        end

        local obj = cls:fromSavedata({
            id = vehicleID,
            type = "vehicle",
            isAddonSpawn = false,
            ownerSteamID = LB.players.playersByPeerID[ownerPeerID].steamID,
            spawnCost = spawnCost,
            collisionLayer = collisionLayer,
            onInitScript = onInitScript
        })
        
        obj:init()

        LB.objects:trackEntity(obj)

        return obj
    end;
    
    ---@param self LifeBoatAPI.Vehicle
    ---@return LifeBoatAPI.Coroutine
    awaitLoaded = function(self)
        local isLoaded = server.getVehicleSimulating(self.id)
        if isLoaded then
            return LifeBoatAPI.Coroutine:start()
        else
            return self.onLoaded:await()
        end
    end;

    ---@param self LifeBoatAPI.Object
    ---@return boolean
    isLoaded = function(self)
        -- objects can be despawned without callback, we can check that here
        local isLoaded, isSpawned = server.getVehicleSimulating(self.id)
        return isLoaded
    end;



    ---@param self LifeBoatAPI.Vehicle
    ---@return LifeBoatAPI.Matrix
    getTransform = function(self)
        local matrix, success = server.getVehiclePos(self.id, 0, 0, 0)
        if success then
            self.lastTransform = self.transform

            self.transform = matrix
            self.nextUpdateTick = LB.ticks.ticks + 30
        end
        return self.transform
    end;

    ---@param self LifeBoatAPI.Vehicle
    onDispose = function(self)
        if self.onDespawn.hasListeners then
            self.onDespawn:trigger(self)
        end
        LB.collision:stopTracking(self)
        LB.objects:stopTracking(self)
        server.despawnVehicle(self.id, true)
    end;
}