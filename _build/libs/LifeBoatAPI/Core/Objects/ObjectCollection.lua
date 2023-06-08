-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@class LifeBoatAPI.ObjectCollection : LifeBoatAPI.IDisposable
---@field objects LifeBoatAPI.GameObject[]
---@field savedata table
---@field id number
LifeBoatAPI.ObjectCollection = {
    _generateID = function()
        g_savedata.lb_nextObjCollectionID = g_savedata.lb_nextObjCollectionID and (g_savedata.lb_nextObjCollectionID + 1) or 0
        return g_savedata.lb_nextObjCollectionID
    end;

    ---@param cls LifeBoatAPI.ObjectCollection
    ---@return LifeBoatAPI.ObjectCollection
    fromSavedata = function(cls, savedata)
        local self = {
            id = savedata.id,
            savedata = savedata,
            objects = {},
            disposables = {},

            despawn = LifeBoatAPI.lb_dispose,
            attach = LifeBoatAPI.lb_attachDisposable,
            addObject = cls.addObject,
        }

        for i=1, #savedata.objects do
            local obj = savedata.objects[i]
            local instance = LB.objects:getByType(obj.type, obj.id)
            self.objects[#self.objects+1] = instance
            self.disposables[#self.disposables+1] = instance
        end

        return self
    end;

    ---@param cls LifeBoatAPI.ObjectCollection
    ---@param isTemporary boolean|nil
    ---@return LifeBoatAPI.ObjectCollection
    new = function(cls, isTemporary)
        local self = cls:fromSavedata({
            id = cls:_generateID(),
            type = "object_collection",
            objects = {}
        })

        if not isTemporary then
            LB.objects:trackEntity(self)
        end

        return self
    end;

    ---@param self LifeBoatAPI.ObjectCollection
    ---@param entity LifeBoatAPI.GameObject
    addObject = function(self, entity)
        self.objects[#self.objects+1] = entity
        self.disposables[#self.disposables+1] = entity
        self.savedata.objects[#self.savedata.objects+1] = {type=entity.savedata.type, id=entity.id}
    end;

    despawn = function(self) end
}