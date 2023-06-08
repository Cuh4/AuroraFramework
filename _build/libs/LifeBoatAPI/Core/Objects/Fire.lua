-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@class EventTypes.LBOnDespawn_Fire : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, fire:LifeBoatAPI.Fire), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener


---@class LifeBoatAPI.Fire : LifeBoatAPI.GameObject
---@field parent LifeBoatAPI.GameObject
---@field onCollision nil
---@field onDespawn EventTypes.LBOnDespawn_Fire
LifeBoatAPI.Fire = {
    ---@param cls LifeBoatAPI.Fire
    ---@param savedata LifeBoatAPI.GameObjectSaveData
    ---@return LifeBoatAPI.Fire
    fromSavedata = function(cls, savedata)
        -- get parent, if it still exists
        local parentID = savedata.parentID
        local parentType = savedata.parentType
        local parent;
        if parentID and parentType then
            parent = LB.objects:getByType(parentType, parentID)
        end

        -- no collision for fires
        local self = {
            savedata = savedata,
            id = savedata.id,
            transform = savedata.transform,
            parent = parent,
            nextUpdateTick = (parent and 0) or math.maxinteger, -- no parent = never update

            onDespawn = LifeBoatAPI.Event:new(),

            getTransform = cls.getTransform,
            attach = LifeBoatAPI.lb_attachDisposable,
            despawn = LifeBoatAPI.GameObject.despawn,
            onDispose = LifeBoatAPI.GameObject.onDispose
        }

        -- meant to be attached to an object that's now gone, or parent object exists but is disposed
        if parentID and not parent then
            LifeBoatAPI.lb_dispose(self)
        elseif parent then
            parent.childFires[#parent.childFires+1] = self
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

        return self
    end;

    ---@param cls LifeBoatAPI.Fire
    ---@param spawnData SWAddonComponentSpawned
    ---@param component LifeBoatAPI.AddonComponent
    ---@return LifeBoatAPI.Fire
    fromAddonSpawn = function(cls, component, spawnData, parent)
        -- if parented, we need to turn our global transform, into a relative transform

        local obj = cls:fromSavedata({
            id = spawnData.id,
            type = "fire",
            tags = component.tags,
            name = component.rawdata.display_name,
            transform = parent and component.rawdata.transform or spawnData.transform,
            parentID = parent and parent.id,
            parentType = parent and parent.savedata.type,
            onInitScript = component.tags["onInitScript"]
        })

        LB.objects:trackEntity(obj)
        return obj
    end;

    ---@param self LifeBoatAPI.Fire
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
    
    ---@param self LifeBoatAPI.Fire
    onDispose = function(self)
        -- if disposed by a parent, then this will ensure it gets despawned correctly
        -- we don't want to leave weird fires around
        if self.onDespawn.hasListeners then
            self.onDespawn:trigger(self)
        end
        LB.objects:stopTracking(self)
        server.despawnObject(self.id, true)
    end;
}