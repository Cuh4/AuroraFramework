-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@class EventTypes.LBOnCollisionStart_Object : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, object:LifeBoatAPI.Object, collision:LifeBoatAPI.Collision, zone:LifeBoatAPI.Zone), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.LBOnDespawn_Object : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, object:LifeBoatAPI.Object), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.LBOnLoaded_Object : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, object:LifeBoatAPI.Object), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener


---@class LifeBoatAPI.Object : LifeBoatAPI.GameObject
---@field onLoaded EventTypes.LBOnLoaded_Object
---@field onCollision EventTypes.LBOnCollisionStart_Object
---@field onDespawn EventTypes.LBOnDespawn_Object
---@field childZones LifeBoatAPI.Zone[]
---@field childFires LifeBoatAPI.Fire[]
LifeBoatAPI.Object = {
    ---@param cls LifeBoatAPI.Object
    fromSavedata = function(cls, savedata)
        local self = {
            savedata = savedata,
            id = savedata.id,
            transform = savedata.transform or LifeBoatAPI.Matrix:newMatrix(),
            childFires = {},
            childZones = {},
            nextUpdateTick = 0,

            -- events
            onLoaded = LifeBoatAPI.Event:new(),
            onDespawn = LifeBoatAPI.Event:new(),
            onCollision = LifeBoatAPI.Event:new(),
            
            -- methods
            awaitLoaded = cls.awaitLoaded,
            getTransform = cls.getTransform,
            attach = LifeBoatAPI.lb_attachDisposable,
            despawn = LifeBoatAPI.GameObject.despawn,
            onDispose = cls.onDispose,
            isLoaded = cls.isLoaded,
            init = cls.init,
            setCollisionLayer = LifeBoatAPI.GameObject.setCollisionLayer
        }

        return self
    end;

    ---@param self LifeBoatAPI.Object
    init = function(self)
        -- ensure position is up to date
        self:getTransform()

        -- run init script (before enabling collision detection, so it can be cancelled if wanted)
        local script = LB.objects.onInitScripts[self.savedata.onInitScript]
        if script then
            script(self)
        end
        
        if server.getObjectSimulating(self.id) then
            LB.collision:trackEntity(self)
        end
    end;

    ---@param cls LifeBoatAPI.Object
    ---@param component LifeBoatAPI.AddonComponent
    ---@param spawnData SWAddonComponentSpawned
    fromAddonSpawn = function(cls, component, spawnData)
        local obj = cls:fromSavedata({
            id = spawnData.id,
            type = component.rawdata.type == "character" and "npc" or "object",
            isAddonSpawn = true,
            tags = component.tags,
            dynamicType = component.rawdata.dynamic_object_type,
            name = component.rawdata.display_name,
            transform = spawnData.transform,
            isStatic = component.tags["isStatic"],
            collisionLayer = not component.tags["isStatic"] and component.tags["collisionLayer"] or nil,
            onInitScript = component.tags["onInitScript"]
        })

        LB.objects:trackEntity(obj)

        return obj
    end;

    ---@param cls LifeBoatAPI.Object
    ---@param objectID number
    ---@param isStatic boolean
    ---@param collisionLayer string|nil leave nil if this shouldn't perform collision checks, e.g. static objects
    ---@return LifeBoatAPI.Object
    fromUntrackedSpawn = function(cls, objectID, isNPC, isStatic, collisionLayer, onInitScript)
        local obj = cls:fromSavedata({
            id = objectID,
            type = isNPC and "npc" or "object",
            isAddonSpawn = false,
            isStatic = isStatic,
            collisionLayer = collisionLayer,
            onInitScript = onInitScript
        })

        obj:init()

        LB.objects:trackEntity(obj)
        
        return obj
    end;

    ---@param self LifeBoatAPI.Object
    ---@return LifeBoatAPI.Matrix
    getTransform = function(self)
        local matrix, success = server.getObjectPos(self.id)
        if success then
            self.lastTransform = self.transform

            self.transform = matrix
            self.nextUpdateTick = LB.ticks.ticks + 30
        else
            -- object has despawned already
            --? not sure if necessary self:despawn()
        end
        return self.transform
    end;

    ---@param self LifeBoatAPI.Object
    ---@return LifeBoatAPI.Coroutine
    awaitLoaded = function(self)
        if self:isLoaded() then
            return LifeBoatAPI.Coroutine:start()
        else
            return self.onLoaded:await()
        end
    end;

    ---@param self LifeBoatAPI.Object
    ---@return boolean
    isLoaded = function(self)
        -- objects can be despawned without callback, we can check that here
        local isSimulating, isSpawned = server.getObjectSimulating(self.id)
        if not isSpawned then
            self:despawn()
            return false
        end
        return isSimulating
    end;

    ---@param self LifeBoatAPI.Object
    onDispose = function(self)
        if self.onDespawn.hasListeners then
            self.onDespawn:trigger(self)
        end
        self.isCollisionStopped = true
        LB.objects:stopTracking(self)
        server.despawnObject(self.id, true)
    end;
}
