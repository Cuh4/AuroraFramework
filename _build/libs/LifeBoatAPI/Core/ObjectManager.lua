-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@class LifeBoatAPI.ObjectManager
---@field savedata table
---@field vehiclesByID table<number, LifeBoatAPI.Vehicle>
---@field objectsByID table<number, LifeBoatAPI.Object>
---@field npcsByID table<number, LifeBoatAPI.Object>
---@field firesByID table<number, LifeBoatAPI.Fire>
---@field zonesByID table<number, LifeBoatAPI.Zone>
---@field objectCollectionsByID table<number, LifeBoatAPI.ObjectCollection>
---@field onInitScripts table<string, fun(obj:LifeBoatAPI.GameObject)>
LifeBoatAPI.ObjectManager = {
    ---@param cls LifeBoatAPI.ObjectManager
    ---@param eventsManager LifeBoatAPI.EventManager
    ---@return LifeBoatAPI.ObjectManager
    new = function(cls, eventsManager)
        local self = {
            savedata = {
                -- id : savedata
                vehiclesByID = {};
                objectsByID = {};
                npcsByID = {};
                zonesByID = {};
                firesByID = {};
                objectCollectionsByID = {};
                nextZoneID = 0;
            };

            -- id: object
            vehiclesByID = {};
            objectsByID = {};
            npcsByID = {};
            firesByID = {};
            zonesByID = {};
            objectCollectionsByID = {};
            onInitScripts = {};

            --- methods
            init = cls.init;
            registerScript = cls.registerScript;
            trackEntity = cls.trackEntity;
            stopTracking = cls.stopTracking;
            getByType = cls.getByType;
            getVehicle = cls.getVehicle;
            getZone = cls.getZone;
            getNPC = cls.getNPC;
            getObject = cls.getObject;
            getFire = cls.getFire;
            getObjectCollection = cls.getObjectCollection;
        }

        eventsManager.onVehicleDespawn:register(function (l, context, vehicleID, peerID)
            local vehicle = self.vehiclesByID[vehicleID]  
            if vehicle then
                vehicle:despawn() -- ensure correct disposal sequence, and object removed from LB.objects     
            end
        end)

        eventsManager.onVehicleLoad:register(function (l, context, vehicleID)
            local vehicle = self.vehiclesByID[vehicleID]
            if vehicle then
                if vehicle.onLoaded.hasListeners then
                    vehicle.onLoaded:trigger(vehicle)
                end
                for i=1, #vehicle.childZones do
                    LB.collision:trackEntity(vehicle.childZones[i])
                end
                LB.collision:trackEntity(vehicle)
            end
        end)

        eventsManager.onVehicleUnload:register(function(l, context, vehicleID, peerID)
            local vehicle = self.vehiclesByID[vehicleID]  
            if vehicle then
                LB.collision:stopTracking(vehicle)

                for i=1, #vehicle.childZones do
                    LB.collision:stopTracking(vehicle.childZones[i])
                end
            end 
        end)

        eventsManager.onObjectLoad:register(function (l, context, objectID)
            local object = self.objectsByID[objectID] or self.npcsByID[objectID] or self.firesByID[objectID]
            if object then
                if object.onLoaded.hasListeners then
                    object.onLoaded:trigger(object)
                end

                for i=1, #object.childZones do
                    LB.collision:trackEntity(object.childZones[i])
                end
                LB.collision:trackEntity(object)
            end
        end)

        eventsManager.onObjectUnload:register(function (l, context, objectID)
            
            local object = self.objectsByID[objectID] or self.npcsByID[objectID] or self.firesByID[objectID]
            if object then
                LB.collision:stopTracking(object)

                for i=1, #object.childZones do
                    LB.collision:stopTracking(object.childZones[i])
                end
            end 
        end)

        return self
    end;

    ---@param self LifeBoatAPI.ObjectManager
    init = function(self)
        -- create our save data
        self.savedata = g_savedata.objectManager or self.savedata
        g_savedata.objectManager = self.savedata

        local initializables = {}
        -- initialize things that we already know exist from the savedata
        for vehicleID, vehicleSaveData in pairs(self.savedata.vehiclesByID) do
            if not self.vehiclesByID[vehicleID] then
                local vehicle = LifeBoatAPI.Vehicle:fromSavedata(vehicleSaveData)
                self.vehiclesByID[vehicleID] = vehicle
                initializables[#initializables+1] = vehicle
            end
        end

        for objectID, objectSaveData in pairs(self.savedata.objectsByID) do
            if not self.objectsByID[objectID] then
                local object = LifeBoatAPI.Object:fromSavedata(objectSaveData)
                self.objectsByID[objectID] = object
                initializables[#initializables+1] = object
            end
        end

        for objectID, objectSaveData in pairs(self.savedata.npcsByID) do
            if not self.npcsByID[objectID] then
                local object = LifeBoatAPI.Object:fromSavedata(objectSaveData)
                self.npcsByID[objectID] = object
                initializables[#initializables+1] = object
            end
        end

        -- zones and fires must come second, as they can be parents to an object/npc/vehicle
        -- note: no chained parenting, because as fun as that sounds, there's no reason to do it
        for objectID, objectSaveData in pairs(self.savedata.zonesByID) do
            if not self.zonesByID[objectID] then
                self.zonesByID[objectID] = LifeBoatAPI.Zone:fromSavedata(objectSaveData)
            end
        end

        for objectID, objectSaveData in pairs(self.savedata.firesByID) do
            if not self.firesByID[objectID] then
                self.firesByID[objectID] = LifeBoatAPI.Fire:fromSavedata(objectSaveData)
            end
        end

        -- load object collections last, so everything else exists first
        for objectID, objectSaveData in pairs(self.savedata.objectCollectionsByID) do
            if not self.objectCollectionsByID[objectID] then
                self.objectCollectionsByID[objectID] = LifeBoatAPI.ObjectCollection:fromSavedata(objectSaveData)
            end
        end

        -- initialize all vehicles and objects, that might have had children
        for i=1, #initializables do
            initializables[i]:init()
        end
    end;

    ---@param self LifeBoatAPI.ObjectManager
    ---@param scriptName string
    ---@param script fun(object:LifeBoatAPI.GameObject)
    registerScript = function (self, scriptName, script)
        self.onInitScripts[scriptName] = script
    end;

    ---@param self LifeBoatAPI.ObjectManager
    ---@param entity LifeBoatAPI.GameObject
    stopTracking = function(self, entity)
        local type = entity.savedata.type

        if type == "zone" then
            self.zonesByID[entity.id] = nil
            self.savedata.zonesByID[entity.id] = nil

        elseif type == "vehicle" then
            self.vehiclesByID[entity.id] = nil
            self.savedata.vehiclesByID[entity.id] = nil

        elseif type == "npc" then
            self.npcsByID[entity.id] = nil
            self.savedata.npcsByID[entity.id] = nil

        elseif type == "fire" then
            self.firesByID[entity.id] = nil
            self.savedata.firesByID[entity.id] = nil

        elseif type == "object" then
            self.objectsByID[entity.id] = nil
            self.savedata.objectsByID[entity.id] = nil
        elseif type == "object_collection" then
            self.objectCollectionsByID[entity.id] = nil
            self.savedata.objectCollectionsByID[entity.id] = nil 
        end
    end;

    ---@param self LifeBoatAPI.ObjectManager
    ---@param entity LifeBoatAPI.Object|LifeBoatAPI.Animal|LifeBoatAPI.Fire|LifeBoatAPI.Vehicle|LifeBoatAPI.Zone|LifeBoatAPI.ObjectCollection
    trackEntity = function(self, entity)
        -- already dead
        if entity.isDisposed then
            return
        end

        local type = entity.savedata.type

        if type == "zone" then
            ---@cast entity LifeBoatAPI.Zone
            self.zonesByID[entity.id] = entity
            self.savedata.zonesByID[entity.id] = entity.savedata

        elseif type == "vehicle" then
            ---@cast entity LifeBoatAPI.Vehicle
            self.vehiclesByID[entity.id] = entity
            self.savedata.vehiclesByID[entity.id] = entity.savedata

        elseif type == "npc" then
            ---@cast entity LifeBoatAPI.Object
            self.npcsByID[entity.id] = entity
            self.savedata.npcsByID[entity.id] = entity.savedata

        elseif type == "fire" then
            ---@cast entity LifeBoatAPI.Fire
            self.firesByID[entity.id] = entity
            self.savedata.firesByID[entity.id] = entity.savedata

        elseif type == "object" then
            ---@cast entity LifeBoatAPI.Object
            self.objectsByID[entity.id] = entity
            self.savedata.objectsByID[entity.id] = entity.savedata
        elseif type == "object_collection" then
            ---@cast entity LifeBoatAPI.ObjectCollection
            self.objectCollectionsByID[entity.id] = entity
            self.savedata.objectCollectionsByID[entity.id] = entity.savedata
        end
    end;

    ---@param self LifeBoatAPI.ObjectManager
    ---@param type string
    ---@param id number
    ---@return LifeBoatAPI.Object|LifeBoatAPI.Animal|LifeBoatAPI.Fire|LifeBoatAPI.Vehicle|LifeBoatAPI.Zone|LifeBoatAPI.ObjectCollection
    getByType = function(self, type, id)
        if type == "zone" then
            return self.zonesByID[id]
        elseif type == "vehicle" then
            return self.vehiclesByID[id]
        elseif type == "npc" then
            return self.npcsByID[id]
        elseif type == "fire" then
            return self.firesByID[id]
        elseif type == "object" then
            return self.objectsByID[id]
        elseif type == "object_collection" then
            return self.objectCollectionsByID[id]
        end
        return nil
    end;

    ---@param self LifeBoatAPI.ObjectManager
    ---@param vehicleID number
    ---@return LifeBoatAPI.Vehicle
    getVehicle = function(self, vehicleID)
        return self.vehiclesByID[vehicleID]
    end;

    ---@param self LifeBoatAPI.ObjectManager
    ---@param zoneID number
    ---@return LifeBoatAPI.Zone
    getZone = function(self, zoneID)
        return self.zonesByID[zoneID]
    end;

    ---@param self LifeBoatAPI.ObjectManager
    ---@param objectID number
    ---@return LifeBoatAPI.Object
    getNPC = function(self, objectID)
        return self.npcsByID[objectID]
    end;

    ---@param self LifeBoatAPI.ObjectManager
    ---@param objectID number
    ---@return LifeBoatAPI.Object
    getObject = function(self, objectID)
        ---@type LifeBoatAPI.Object
        local object = self.objectsByID[objectID]
        if object then
            -- check exists every time, as there's no despawn callback
            object:isLoaded()
            if object.isDisposed then
                -- if it's now dead
                return nil
            end
        end

        return object
    end;

    ---@param self LifeBoatAPI.ObjectManager
    ---@param objectID number
    ---@return LifeBoatAPI.Fire
    getFire = function(self, objectID)
        return self.firesByID[objectID]
    end;

    ---@param self LifeBoatAPI.ObjectManager
    ---@param objectID number
    ---@return LifeBoatAPI.ObjectCollection|nil
    getObjectCollection = function(self, objectID)
        return self.objectCollectionsByID[objectID]
    end;
}