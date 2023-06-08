-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@class EventTypes.LBOnCollisionEnd : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, collision:LifeBoatAPI.Collision), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class LifeBoatAPI.Collision : LifeBoatAPI.IDisposable
---@field zone LifeBoatAPI.GameObject
---@field object LifeBoatAPI.GameObject
---@field onCollisionEnd EventTypes.LBOnCollisionEnd
LifeBoatAPI.Collision = {
    
    ---@param cls LifeBoatAPI.Collision
    ---@param zone LifeBoatAPI.Zone
    ---@param object LifeBoatAPI.GameObject
    new = function(cls, zone, object)
        return {
            zone = zone,
            object = object,

            onCollisionEnd = LifeBoatAPI.Event:new(),

            onDispose = LifeBoatAPI.Collision.onDispose,
            attach = LifeBoatAPI.lb_attachDisposable
        }
    end;

    ---@param self LifeBoatAPI.Collision
    onDispose = function(self)
        if self.onCollisionEnd.hasListeners then
            self.onCollisionEnd:trigger(self)
        end
    end;
}


---@class LifeBoatAPI.CollisionLayer
---@field objects LifeBoatAPI.GameObject[]
---@field zones LifeBoatAPI.Zone[]
---@field entityLookup table<any, boolean>
---@field name string
LifeBoatAPI.CollisionLayer = {
    ---@return LifeBoatAPI.CollisionLayer
    new = function(cls, name)
        return {
            name = name,
            zones = {},
            objects = {},
            entityLookup = {}
        }
    end;
}

---@class LifeBoatAPI.CollisionManager
---@field layers LifeBoatAPI.CollisionLayer[]
---@field layersByName table<string, LifeBoatAPI.CollisionLayer>
---@field collisions table<any, table<LifeBoatAPI.Zone, LifeBoatAPI.Collision>>
---@field tickFrequency number frequency to update collisions, default is 30ticks (twice per second - which is going to be more than enough for 99.9% of cases)
LifeBoatAPI.CollisionManager = {

    ---@param cls LifeBoatAPI.CollisionManager
    ---@return LifeBoatAPI.CollisionManager
    new = function(cls)
        ---@type LifeBoatAPI.CollisionManager
        local self = {
            layersByName = {};
            collisions = {};
            tickFrequency = 30; -- twice per second seems pretty reasonable really. Not sure why you'd need it much higher, especially as we're checking by line

            ---methods
            init = cls.init;
            trackEntity = cls.trackEntity;
            stopTracking = cls.stopTracking;
        }
        return self
    end;

    ---@param self LifeBoatAPI.CollisionManager
    init = function(self)
    end;

    ---@param self LifeBoatAPI.CollisionManager
    ---@param entity LifeBoatAPI.GameObject
    trackEntity = function(self, entity)
        local layerName = entity.savedata.collisionLayer

        -- cannot track collisions for an entity with no specified layer
        if not layerName then
            return
        end

        if not self.layersByName[layerName] then
            self.layersByName[layerName] = LifeBoatAPI.CollisionLayer:new(layerName)
        end
        local layer = self.layersByName[layerName]

        -- prevent duplicate tracking (shouldn't be needed, but important just to prevent the mess that would come of it)
        if layer.entityLookup[entity] then
            return
        end
        layer.entityLookup[entity] = true
        entity.collisionPairs = {}

        if entity.savedata.type == "zone" then
            ---@cast entity LifeBoatAPI.Zone
            local zone = entity
            layer.zones[#layer.zones+1] = zone

            -- begin colliding with all existing objects
            for i=1, #layer.objects do
                local object = layer.objects[i]

                local collisionPair = LifeBoatAPI.CollisionPair:new(object, zone, nil, nil)
                object.collisionPairs[zone] = collisionPair
                zone.collisionPairs[object] = collisionPair
            end
        else
            local object = entity
            layer.objects[#layer.objects+1] = object

            -- begin colliding with all existing zones
            for i=1, #layer.zones do
                local zone = layer.zones[i]

                local collisionPair = LifeBoatAPI.CollisionPair:new(object, zone, nil, nil)
                object.collisionPairs[zone] = collisionPair
                zone.collisionPairs[object] = collisionPair
            end
        end
    end;

    ---@param self LifeBoatAPI.CollisionManager
    ---@param entity LifeBoatAPI.GameObject
    stopTracking = function(self, entity)
        local layerName = entity.savedata.collisionLayer -- if this gets messed with, welcome to error land
        local layer = self.layersByName[layerName]
        if not layer then
            return
        end

        if entity.collisionPairs then
            if entity.savedata.type == "zone" then
                ---@cast entity LifeBoatAPI.Zone
                local zone = entity
                for i=1, #layer.objects do
                    local object = layer.objects[i]
                    local collisionPair = zone.collisionPairs[object]
                    if collisionPair and not collisionPair.isDisposed then
                        if collisionPair.collision then
                            LifeBoatAPI.lb_dispose(collisionPair.collision)
                        end

                        object.collisionPairs[zone] = nil -- remove from the other
                    end
                    collisionPair.isDisposed = true -- safe, because the collisionPair is entirely within internal implementation
                end

                -- remove from zones list
                for i=1, #layer.zones do
                    if layer.zones[i] == zone then
                        table.remove(layer.zones, i)
                        break;
                    end
                end
            else
                local object = entity
                for i=1, #layer.zones do
                    local zone = layer.zones[i]
                    local collisionPair = object.collisionPairs[zone]
                    if collisionPair and not collisionPair.isDisposed then
                        if collisionPair.collision then
                            LifeBoatAPI.lb_dispose(collisionPair.collision)
                        end

                        zone.collisionPairs[object] = nil -- remove from the other
                    end
                    collisionPair.isDisposed = true -- safe, because the collisionPair is entirely within internal implementation
                end

                -- remove from objects list
                for i=1, #layer.objects do
                    if layer.objects[i] == object then
                        table.remove(layer.objects, i)
                        break;
                    end
                end
            end
        end

        layer.entityLookup[entity] = nil
        entity.collisionPairs = {}
    end;
}


---@class LifeBoatAPI.CollisionPair : LifeBoatAPI.ITickable
---@field zone LifeBoatAPI.Zone
---@field object LifeBoatAPI.GameObject
---@field collision LifeBoatAPI.Collision
LifeBoatAPI.CollisionPair = {
    new = function(cls, object, zone, tickFrequency, firstTickDelay)
        local self = {
            collision = nil,
            object = object,
            zone = zone,
            tickFrequency = tickFrequency,
            firstTickDelay = firstTickDelay
        }
        
        LB.ticks:register(cls.onTick, self, tickFrequency, firstTickDelay, true)
        
        return self
    end;

    ---@param self LifeBoatAPI.CollisionPair
    onTick = function(self, ctx)
        -- if the zone or object is no longer colliding, kill the tickable
        local object = self.object
        local zone = self.zone
        
        
        -- if nothings listening for the collision, don't bother calculating it - come back in 2 seconds
        if not object.onCollision.hasListeners and not zone.onCollision.hasListeners then
            self.tickFrequency = 120
            return
        end

        -- check if either object or zone needs position updated
        local currentTick = LB.ticks.ticks
        if object.nextUpdateTick <= currentTick then
            object:getTransform()
        end

        if zone.nextUpdateTick <= currentTick then
            zone:getTransform()
        end

        -- actually do the collision checks
        local objTransform = object.transform
        local zoneTransform = zone.transform
        local zoneSave = zone.savedata

        -- cheap distance check first
        local dx,dy,dz = objTransform[13]-zoneTransform[13], objTransform[14]-zoneTransform[14], objTransform[15]-zoneTransform[15]
        local distance = (dx*dx + dy*dy + dz*dz)^0.5
        
        local isCollision = false;
        if distance <= zone.boundingRadius then
            if zoneSave.collisionType == "sphere" then
                isCollision = LifeBoatAPI.Colliders.isPointInSphere(objTransform, zoneTransform, zoneSave.radius)
            else
                isCollision = LifeBoatAPI.Colliders.isPointInZone(objTransform, zoneTransform, zoneSave.sizeX, zoneSave.sizeY, zoneSave.sizeZ)
            end
            
            self.tickFrequency = 30
        else
            local distanceOut = distance-zone.boundingRadius -- distance outside the radius the object is, determins how quickly to do the next collision check

            self.tickFrequency = 30 + (distanceOut * 0.001 * 300) // 1 -- 5 second, per 1000 distance away from the edge of the collider

            if self.tickFrequency > 3000 then -- max timeout 30s at 10Km
                self.tickFrequency = 3000
            end
        end

        local collision = self.collision
        -- handle calculated collision
        if isCollision and not collision then
            -- new collision
            self.collision = LifeBoatAPI.Collision:new(zone, object)
            collision = self.collision

            if object.onCollision.hasListeners then
                object.onCollision:trigger(object, collision, zone)
            end

            if zone.onCollision.hasListeners then
                zone.onCollision:trigger(zone, collision, object)
            end

        elseif not isCollision and collision then
            -- end of collision
            LifeBoatAPI.lb_dispose(collision);
            self.collision = nil
        end
    end;
}