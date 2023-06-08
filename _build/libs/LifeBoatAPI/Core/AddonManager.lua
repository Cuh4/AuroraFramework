-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


-- Provides a simple way to spawn all the assets associated with a specific addon
---@class LifeBoatAPI.AddonManager
---@field this LifeBoatAPI.Addon
---@field addons LifeBoatAPI.Addon[]
---@field addonsByName table<string, LifeBoatAPI.Addon>
LifeBoatAPI.AddonManager = {
    ---@param cls LifeBoatAPI.AddonManager
    ---@return LifeBoatAPI.AddonManager
    new = function(cls)
        local self = {
            this = nil;
            addons = {};
            addonsByName = {};
            scripts = {};

            --- methods
            init = cls.init,
            loadOtherAddons = cls.loadOtherAddons
        }

        return self
    end;

    ---@param self LifeBoatAPI.AddonManager
    init = function(self)
        -- addon indexes start at 0
        local numberOfAddons = server.getAddonCount()
        for i=0, numberOfAddons-1 do
            local addonData = server.getAddonData(i)
            local addon = LifeBoatAPI.Addon:new(i, addonData)
            self.addons[#self.addons+1] = addon
            self.addonsByName[addon.name] = addon
        end

        local thisIndex = server.getAddonIndex() + 1
        self.this = self.addons[thisIndex]
        self.this:load()
    end;

    -- by default, not loaded; as 99% of addons won't care or need to know
    ---@param self LifeBoatAPI.AddonManager
    loadOtherAddons = function(self)
        local thisAddon = self.this
        for i=1, #self.addons do
            local addon = self.addons[i]
            if addon ~= thisAddon then
                addon:load()
            end
        end
    end;
}

---@class LifeBoatAPI.Addon
---@field rawdata SWAddonData
---@field name string
---@field index number
---@field locations LifeBoatAPI.AddonLocation[]
---@field locationsByName table<string, LifeBoatAPI.AddonLocation>
---@field componentsByID LifeBoatAPI.AddonComponent global lists of components in this addon, by id
---@field isLoaded boolean prevent loading the same component twice
LifeBoatAPI.Addon = {
    ---@param addonData SWAddonData
    ---@return LifeBoatAPI.Addon
    new = function(cls, index, addonData)
        return {
            rawdata = addonData,
            name = addonData.name,
            index = index;
            locations = {};
            locationsByName = {};
            componentsByID = {};
            isLoaded = false;

            --methods
            load = cls.load
        }
    end;

    ---@param self LifeBoatAPI.Addon
    load = function(self)
        if not self.isLoaded then
            self.isLoaded = true

            -- addon location indexes start at 0
            for i=0, self.rawdata.location_count-1 do
                local locationData = server.getLocationData(self.index, i)
                local location = LifeBoatAPI.AddonLocation:new(self, i, locationData)
                self.locations[#self.locations+1] = location
                self.locationsByName[locationData.name] = location

                for iComponent=1, #location.components do
                    local component = location.components[iComponent]
                    self.componentsByID[component.index] = component
                end
            end
        end
    end;
}

---@class LifeBoatAPI.AddonLocation
---@field components LifeBoatAPI.AddonComponent[]
---@field componentsByID table<number, LifeBoatAPI.AddonComponent>
---@field componentsByName table<string, LifeBoatAPI.AddonComponent>
---@field addon LifeBoatAPI.Addon
---@field rawdata SWLocationData
---@field index number
LifeBoatAPI.AddonLocation = {
    ---@param cls LifeBoatAPI.AddonLocation
    ---@param locationData SWLocationData
    ---@param parent LifeBoatAPI.Addon
    ---@return LifeBoatAPI.AddonLocation
    new = function(cls, parent, index, locationData)
        ---@type LifeBoatAPI.AddonLocation
        local self = {
            addon = parent,
            index = index,
            rawdata = locationData,
            components = {};
            componentsByID = {};
            componentsByName = {};

            firesByName = {};
            zonesByName = {};
            vehiclesByName = {};
            objectsByName = {};

            --methods
            spawnMultiple = cls.spawnMultiple;
            spawnMultipleRelativeToPosition = cls.spawnMultipleRelativeToPosition;
            getPosition = cls.getPosition;
        }

        ---@type LifeBoatAPI.AddonComponent[]
        local withParent = {}

        -- component index starts at 0
        for i=0, locationData.component_count-1 do
            local componentData = server.getLocationComponentData(self.addon.index, self.index, i)
            local component = LifeBoatAPI.AddonComponent:new(self, i, componentData)

            self.componentsByID[componentData.id] = component

            if (component.rawdata.type == "zone" or component.rawdata.type == "fire")
                and (component.tags["parentID"]) then

                withParent[#withParent+1] = component
            else
                self.components[#self.components+1] = component

                if componentData.display_name ~= "" then
                    self.componentsByName[componentData.display_name] = component
                end
            end
        end

        -- todo: manage parented items
        for i=1, #withParent do
            local component = withParent[i]
            local parentID = tonumber(component.tags["parentID"])

            ---@type LifeBoatAPI.AddonComponent
            local parent = self.componentsByID[parentID]
            if parent then
                local parentTransformInverse = LifeBoatAPI.Matrix.invert(parent.rawdata.transform)
                parent.children[#parent.children+1] = component
                -- handle relative transform
                component.rawdata.transform = LifeBoatAPI.Matrix.multiplyMatrix(component.rawdata.transform, parentTransformInverse)
            end
        end

        return self
    end;

    ---@param closestToMatrix LifeBoatAPI.Matrix|nil optional, center position to try and be closest to
    ---@param self LifeBoatAPI.AddonLocation
    ---@return LifeBoatAPI.Matrix|nil matrix
    getPosition = function(self, closestToMatrix)
        closestToMatrix = closestToMatrix or LifeBoatAPI.Matrix:newMatrix()
        local tileMatrix, success = server.getTileTransform(closestToMatrix, self.rawdata.tile, 50000)

        if not success then
            return nil
        end
        return tileMatrix
    end;

    ---Spawn the location exactly as it is in the editor
    ---@param self LifeBoatAPI.AddonLocation
    ---@param closestToMatrix LifeBoatAPI.Matrix|nil (optional) default s 0,0,0. some tiles can be represented multiple times, such as ocean or small islands - this determines the search start for the closest one
    ---@param predicate nil|fun(component:LifeBoatAPI.AddonComponent):bool function that returns true, if the component should be spawned, or nil for all objects (not recommended)
    ---@param collectionIsTemporary boolean|nil if true, will not persist this collection - used when just wanting to spawn a lot of things, and will manually track them all in future
    ---@return LifeBoatAPI.ObjectCollection spawned
    spawnMultiple = function(self, closestToMatrix, predicate, collectionIsTemporary)
        closestToMatrix = closestToMatrix or LifeBoatAPI.Matrix:newMatrix()
        local tileMatrix, success = server.getTileTransform(closestToMatrix, self.rawdata.tile, 50000)

        local collection = LifeBoatAPI.ObjectCollection:new(collectionIsTemporary)
        if not success then
            return collection
        end

        for i=1, #self.components do
            local component = self.components[i]
            if not predicate or predicate(component) then
                local spawned = component:spawnRelativeToPosition(tileMatrix)
                if spawned then
                    collection:addObject(spawned)
                end
            end
        end
        return collection
    end;

    ---@param self LifeBoatAPI.AddonLocation
    ---@param position LifeBoatAPI.Matrix
    ---@param predicate nil|fun(component:LifeBoatAPI.AddonComponent):bool function that returns true, if the component should be spawned, or nil for all objects (not recommended)
    ---@param collectionIsTemporary boolean|nil if true, will not persist this collection - used when just wanting to spawn a lot of things, and will manually track them all in future
    ---@return LifeBoatAPI.ObjectCollection
    spawnMultipleRelativeToPosition = function(self, position, predicate, collectionIsTemporary)
        local collection = LifeBoatAPI.ObjectCollection:new(collectionIsTemporary)

        for i=1, #self.components do
            local component = self.components[i]
            if not predicate or predicate(component) then
                local spawned = component:spawnRelativeToPosition(position)
                if spawned then
                    collection:addObject(spawned)
                end
            end
        end
        return collection
    end;
}

---@class LifeBoatAPI.AddonComponent
---@field index number
---@field location LifeBoatAPI.AddonLocation
---@field rawdata SWAddonComponentData
---@field tags table<string,string> -- or table<number,string> where no specific key was given (iterate for flags, use key names for tags)
---@field children LifeBoatAPI.AddonComponent[]
LifeBoatAPI.AddonComponent = {

    ---@param cls LifeBoatAPI.AddonComponent
    ---@param componentData SWAddonComponentData
    ---@return LifeBoatAPI.AddonComponent 
    new = function(cls, location, index, componentData)
        local self = {
            index = index;
            location = location;
            rawdata = componentData;
            tags = {};
            children = {};

            --methods
            parseSequentialTag = cls.parseSequentialTag;
            spawnRelativeToPosition = cls.spawnRelativeToPosition;
            spawnAtPosition = cls.spawnAtPosition;
            spawn = cls.spawn
        }

        -- parse tags delimited by ";" and "," (a=b) => ["a"] = "b", and (a) => ["a"]=true
        local rawtags = self.rawdata.tags_full
        local tags = self.tags
        for tagbase in string.gmatch(rawtags, "%s*([^;,]*%w+)%s*[;,]?") do

            local wasKeyVal = false
            -- if it was a key-value pair a = b, then add to the key:value pairs, otherwise add as a iterable "flag"
            for key,value in string.gmatch(tagbase, "([^;,]*%w+)%s*=%s*([^;,]*%w+)") do
                tags[key] = value
                wasKeyVal = true
            end

            if not wasKeyVal then
                tags[tagbase] = true; 
            end
        end

        return self
    end;

    ---@param self LifeBoatAPI.AddonComponent
    ---@return string[]|nil
    parseSequentialTag = function(self, tagBase)
        local sequence = {}

        -- potentially first named collision layer
        local baseTag = self.tags[tagBase]
        if baseTag then
            sequence[#sequence+1] = baseTag
        end

        -- find numbered following tags (e.g. a1=1, a2=1, a3=1)
        local i=1
        while true do
            local tag = self.tags[tagBase .. i]
            if tag then
                sequence[#sequence+1] = tag
            else
                break
            end
        end

        if #sequence > 0 then
            return sequence
        else
            return nil
        end
    end;

    ---@param self LifeBoatAPI.AddonComponent
    ---@param position LifeBoatAPI.Matrix
    ---@return LifeBoatAPI.GameObject|nil
    spawnRelativeToPosition = function(self, position)
        return self:spawn(LifeBoatAPI.Matrix.multiplyMatrix(self.rawdata.transform, position))
    end;

    ---@param self LifeBoatAPI.AddonComponent
    ---@param position LifeBoatAPI.Matrix
    ---@return LifeBoatAPI.GameObject|nil
    spawnAtPosition = function(self, position)
        return self:spawn(position)
    end;

    ---@param self LifeBoatAPI.AddonComponent
    ---@param matrix LifeBoatAPI.Matrix (optional) if not provided, uses the preset matrix from the editor
    ---@param parent LifeBoatAPI.Vehicle|LifeBoatAPI.Object|nil
    ---@return LifeBoatAPI.GameObject|nil
    spawn = function(self, matrix, parent)
        
        -- don't actually "spawn" a zone, otherwise it adds an insane load on the server; due to how the game handles them 
        local spawnedData, success;
        if self.rawdata.type ~= "zone" then
            spawnedData, success =  server.spawnAddonComponent(matrix, self.location.addon.index, self.location.index, self.index)
        else
            success = true
        end

        if success then

            ---@type LifeBoatAPI.GameObject
            local entity;
            if self.rawdata.type == "zone" then
                entity = LifeBoatAPI.Zone:fromAddonSpawn(self, matrix, parent)

            elseif self.rawdata.type == "fire" then
                entity = LifeBoatAPI.Fire:fromAddonSpawn(self, spawnedData, parent)
                
            elseif self.rawdata.type == "character" then
                entity = LifeBoatAPI.Object:fromAddonSpawn(self, spawnedData)

            elseif self.rawdata.type == "vehicle" then
                entity = LifeBoatAPI.Vehicle:fromAddonSpawn(self, spawnedData)

            -- regular objects
            elseif self.rawdata.type == "object"    -- small objects 
            or self.rawdata.type == "loot"        -- flare
            or self.rawdata.type == "flare"        -- loot
            or self.rawdata.type == "animal"        -- button
            or self.rawdata.type == "ice" then   -- ice
                entity = LifeBoatAPI.Object:fromAddonSpawn(self, spawnedData)
            end

            -- spawn children, at relative positions
            for i=1, #self.children do
                local child = self.children[i]

                ---@cast entity LifeBoatAPI.Vehicle|LifeBoatAPI.Object
                -- do we really want to multiply that? do we not want to find the difference between
                child:spawn(LifeBoatAPI.Matrix.multiplyMatrix(child.rawdata.transform, matrix), entity)
            end

            -- vehicle & object want intialized after children created/added
            if entity.init then
                entity:init()
            end

            return entity
        end
        return nil
    end;
}