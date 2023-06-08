-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@class EventTypes.LBOnCollisionStart_Zone : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, zone:LifeBoatAPI.Zone, collision:LifeBoatAPI.Collision, collidingWith:LifeBoatAPI.GameObject), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener


---@class LifeBoatAPI.ZoneSaveData : LifeBoatAPI.GameObjectSaveData
---@field sizeX number
---@field sizeY number
---@field sizeZ number
---@field radius number
---@field radiusTripled number
---@field collisionType string
---@field collisionLayer string
---@field overrideIsBig any|nil

---@class LifeBoatAPI.Zone : LifeBoatAPI.GameObject
---@field savedata LifeBoatAPI.ZoneSaveData
---@field parent LifeBoatAPI.GameObject
---@field onCollision EventTypes.LBOnCollisionStart_Zone
---@field boundingRadius number radius calculated as bounding box
LifeBoatAPI.Zone = {
    _generateZoneID = function()
        g_savedata.lb_nextZoneID = g_savedata.lb_nextZoneID and (g_savedata.lb_nextZoneID + 1) or 0
        return g_savedata.lb_nextZoneID
    end;

    ---@param cls LifeBoatAPI.Zone
    ---@param savedata LifeBoatAPI.ZoneSaveData
    fromSavedata = function(cls, savedata)
        local parentID = savedata.parentID
        local parentType = savedata.parentType
        local parent;
        if parentID and parentType then
            parent = LB.objects:getByType(parentType, parentID)
        end

        local self = {
            savedata = savedata,
            id = savedata.id,
            transform = savedata.transform,
            parent = parent,
            nextUpdateTick = (parent and 0) or math.maxinteger, -- no parent = never update
            
            onDespawn = LifeBoatAPI.Event:new(),
            onCollision = LifeBoatAPI.Event:new(),

            getTransform = cls.getTransform,
            attach = LifeBoatAPI.lb_attachDisposable,
            despawn = LifeBoatAPI.GameObject.despawn,
            onDispose = cls.onDispose,
            setCollisionLayer = LifeBoatAPI.GameObject.setCollisionLayer
        }

        if savedata.collisionType == "box" then
            -- sizes are already 1/2'd, (radial rather than edge length)
            self.boundingRadius = ((savedata.sizeX * savedata.sizeX) + (savedata.sizeY * savedata.sizeY) + (savedata.sizeZ*savedata.sizeZ)) ^ 0.5
        else
            self.boundingRadius = savedata.radius
        end

        -- meant to be attached to an object that's now gone, or parent object exists but is disposed
        if parentID and not parent then
            LifeBoatAPI.lb_dispose(self)
        elseif parent then
            parent.childZones[#parent.childZones+1] = self
            parent:attach(self)
        end

        if self.isDisposed then
            return self
        end

        -- ensure position is up to date
        self:getTransform()

        -- run init script (before enabling collision detection, so it can be cancelled if wanted)
        local script = LB.objects.onInitScripts[self.savedata.onInitScript]
        if script then
            script(self)    
        end
        
        if (not parent) or parent:isLoaded() then
            LB.collision:trackEntity(self)
        end
        
        return self
    end;

    ---@param cls LifeBoatAPI.Zone
    ---@param component LifeBoatAPI.AddonComponent
    ---@param transform LifeBoatAPI.Matrix
    ---@param parent LifeBoatAPI.Vehicle|LifeBoatAPI.Object|nil
    fromAddonSpawn = function(cls, component, transform, parent)
        local obj = cls:fromSavedata({
            id = LifeBoatAPI.Zone._generateZoneID(),
            type = "zone",
            isAddonSpawn = true,
            name = component.rawdata.display_name,
            tags = component.tags,
            collisionType = (component.tags["collisionType"] == "sphere" and "sphere") or "box",
            collisionLayer = component.tags["collisionLayer"],
            transform = parent and component.rawdata.transform or transform,
            radius = component.tags["radius"] and tonumber(component.tags["radius"]) or 0,
            sizeX = component.tags["sizeX"] and tonumber(component.tags["sizeX"]) or 0,
            sizeY = component.tags["sizeY"] and tonumber(component.tags["sizeY"]) or 0,
            sizeZ = component.tags["sizeZ"] and tonumber(component.tags["sizeZ"]) or 0,

            parentID = parent and parent.id,
            parentType = parent and parent.savedata.type,
            onInitScript = component.tags["onInitScript"]
        })

        LB.objects:trackEntity(obj)

        return obj
    end;

    ---@param cls LifeBoatAPI.Zone
    ---@param parent LifeBoatAPI.Vehicle|LifeBoatAPI.Object
    ---@param isTemporary boolean|nil if true, doesn't track between addon reloads (can simplify mission creation in some specific cases)
    ---@return LifeBoatAPI.Zone
    newSphere = function(cls, collisionLayer, transform, radius, parent, onInitScript, isTemporary)
        -- if parented, we need to turn our global transform, into a relative transform
        local obj = cls:fromSavedata({
            id = LifeBoatAPI.Zone._generateZoneID(),
            type = "zone",
            collisionType = "sphere",
            transform = transform,
            radius = radius,
            collisionLayer = collisionLayer,
            parentID = parent and parent.id,
            parentType = parent and parent.savedata.type,
            onInitScript = onInitScript
        })

        if not isTemporary and not obj.isDisposed then
            LB.objects:trackEntity(obj)
        end

        return obj
    end;

    ---@param cls LifeBoatAPI.Zone
    ---@param parent LifeBoatAPI.Vehicle|LifeBoatAPI.Object
    ---@param isTemporary boolean|nil if true, doesn't track between addon reloads (can simplify mission creation in some specific cases)
    ---@return LifeBoatAPI.Zone
    newZone = function(cls, collisionLayer, transform, sizeX, sizeY, sizeZ, parent, onInitScript, isTemporary)
        local obj = cls:fromSavedata({
            id = LifeBoatAPI.Zone._generateZoneID(),
            type = "zone",
            collisionType = "box",
            transform = transform,
            sizeX = sizeX,
            sizeY = sizeY,
            sizeZ = sizeZ,
            collisionLayer = collisionLayer,
            parentID = parent and parent.id,
            parentType = parent and parent.savedata.type,
            onInitScript = onInitScript
        })

        if not isTemporary and not obj.isDisposed then
            LB.objects:trackEntity(obj)
        end

        return obj
    end;

    ---@param self LifeBoatAPI.Zone
    ---@return LifeBoatAPI.Matrix
    getTransform = function(self)
        local parent = self.parent
        if parent then
            -- parent can be updated by somewhere else, and we still need to update our own relative position
            if parent.nextUpdateTick <= LB.ticks.ticks then
                parent:getTransform()
            end

            -- parent must have updated since we last spoke to it
            if self.nextUpdateTick ~= parent.nextUpdateTick then
                self.transform = LifeBoatAPI.Matrix.multiplyMatrix(self.savedata.transform, parent.transform)
                self.nextUpdateTick = parent.nextUpdateTick
            end
        end

        return self.transform
    end;

    ---@param self LifeBoatAPI.Zone
    onDispose = function(self)
        -- ensures all references are collected correctly
        LB.collision:stopTracking(self)
        LB.objects:stopTracking(self)
    end;
}