-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

--[[
todo:
we do actually want a Mission system that has nested stages
this allows a "the thing that spawns it, checks if it exists, and adds it as disposable in the same place"
    meaning that cleanup is far more reliable & we don't need to remember to explicitly despawn everything each time

how should it work?
    the same overall Mission -> instance thing
    how does the instance track which children it has?
    current -> child -> current -> etc?
    and then next() moves along, and if there's nothing there, that stage completes and we check the parent?
]]
---@section Mission

---@class EventTypes.LBOnMissionComplete : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, mission:LifeBoatAPI.MissionInstance), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class LifeBoatAPI.MissionManager
---@field missionTypes table<string, LifeBoatAPI.Mission>
---@field missionsByID table<number, LifeBoatAPI.MissionInstance>
---@field missionsByType table<string, LifeBoatAPI.MissionInstance[]>
---@field savedata table
LifeBoatAPI.MissionManager = {

    ---@param cls LifeBoatAPI.MissionManager
    ---@return LifeBoatAPI.MissionManager
    new = function(cls)
        local self = {
            savedata = {
                missionsByID = {}
            },
            missionsByType = {},
            missionsByID = {},
            missionTypes = {},

            --methods
            init = cls.init,
            registerMissionType = cls.registerMissionType,
            getMission = cls.getMission,
            trackInstance = cls.trackInstance,
            stopTracking = cls.stopTracking,
        }

        return self
    end;

    ---@param self LifeBoatAPI.MissionManager
    init = function(self)
        g_savedata.missionManager = g_savedata.missionManager or self.savedata
        self.savedata = g_savedata.missionManager

        for missionID, missionSave in pairs(self.savedata.missionsByID) do
            if self.missionTypes[missionSave.type] then
                local missionType = self.missionTypes[missionSave.type]
                local instance = LifeBoatAPI.MissionInstance:fromSavedata(missionType, missionSave)

                self.missionsByID[instance.id] = instance
                local missionsByTypeList = self.missionsByType[missionSave.type]
                if not missionsByTypeList then
                    self.missionsByType[missionSave.type] = {instance}
                else
                    missionsByTypeList[#missionsByTypeList+1] = instance
                end
            else
                self.savedata.missionsByID[missionID] = nil -- remove no longer supported mission type
            end
        end
    end;

    ---@param self LifeBoatAPI.MissionManager
    ---@param id number
    getMission = function(self, id)
        return self.missionsByID[id]
    end;

    ---@param self LifeBoatAPI.MissionManager
    ---@param mission LifeBoatAPI.Mission
    registerMissionType = function(self, mission)
        self.missionTypes[mission.type] = mission
    end;

    ---@param self LifeBoatAPI.MissionManager
    ---@param missionInstance LifeBoatAPI.MissionInstance
    trackInstance = function(self, missionInstance, isTemporary)
        if missionInstance.isDisposed or self.missionsByID[missionInstance.id] then
            return
        end

        -- add to live lists
        self.missionsByID[missionInstance.id] = missionInstance
        local missionsByType = self.missionsByType[missionInstance.savedata.type]
        if not missionsByType then
            self.missionsByType[missionInstance.savedata.type] = {missionInstance}
        else
            missionsByType[#missionsByType+1] = missionInstance
        end

        -- persist if not temporary
        if not isTemporary then
            self.savedata.missionsByID[missionInstance.id] = missionInstance.savedata
        end
    end;

    ---@param self LifeBoatAPI.MissionManager
    ---@param missionInstance LifeBoatAPI.MissionInstance
    stopTracking = function(self, missionInstance)
        
        self.missionsByID[missionInstance.id] = nil
        self.savedata.missionsByID[missionInstance.id] = nil
        local missionsOfType = self.missionsByType[missionInstance.savedata.type]
        if missionsOfType then
            for i=1, #missionsOfType do
                local mission = missionsOfType[i]
                if mission.id == missionInstance.id then
                    table.remove(missionsOfType, i)
                    break
                end
            end
        end
    end;
}


---@alias LifeBoatAPI.MissionExecutionFunction fun(self:LifeBoatAPI.MissionInstance, savedata:table, params:table)

---@class EventTypes.LBOnMissionComplete : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:fun(l:LifeBoatAPI.IEventListener, context:any, mission:LifeBoatAPI.MissionInstance), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---on dispose, we kill it? right?
---@class LifeBoatAPI.MissionInstance : LifeBoatAPI.IDisposable
---@field savedata table
---@field mission LifeBoatAPI.Mission
---@field onComplete EventTypes.LBOnMissionComplete
---@field terminate fun(self:LifeBoatAPI.MissionInstance)
---@field currentStage LifeBoatAPI.MissionInstance
---@field parent LifeBoatAPI.MissionInstance
---@field id number
LifeBoatAPI.MissionInstance = {
    _generateID = function()
        g_savedata.lb_nextMissionID = g_savedata.lb_nextMissionID and (g_savedata.lb_nextMissionID + 1) or 0
        return g_savedata.lb_nextMissionID
    end;

    ---@param cls LifeBoatAPI.MissionInstance
    ---@param mission LifeBoatAPI.Mission
    ---@param parent LifeBoatAPI.MissionInstance|nil
    ---@param savedata table
    ---@return LifeBoatAPI.MissionInstance
    fromSavedata = function(cls, mission, savedata, parent)
        local self = {
            id = savedata.id,
            savedata = savedata,
            mission = mission;
            disposables = {};
            currentStage = nil;
            parent = parent;

            onComplete = LifeBoatAPI.Event:new();

            --methods 
            attach = LifeBoatAPI.lb_attachDisposable;
            onDispose = cls.onDispose;
            next = cls.next;
            terminate = LifeBoatAPI.lb_dispose;
        }

        -- now run our initial function
        self.mission.onExecute(self, self.savedata, self.savedata.lastResult)

        if self.isDisposed then
            return self
        end
        
        -- instantiate the current child
        local childMission = mission.stages[self.savedata.current]
        if childMission then
            self.savedata.currentChildSavedata = self.savedata.currentChildSavedata or {current = 1}
            self.currentStage = LifeBoatAPI.MissionInstance:fromSavedata(childMission, self.savedata.currentChildSavedata, self)
            if self.currentStage.isDisposed then
                self:next()
            else
                self.disposables[#self.disposables+1] = self.currentStage.onComplete:register(function (l, context, mission)
                    if self.currentStage ~= nil then -- prevent duplicate-next from destroying child
                        self:next() -- when the child stage finishes, we move on
                    end
                end)
            end
        end

        return self
    end;

    ---@param cls LifeBoatAPI.MissionInstance
    ---@param mission LifeBoatAPI.Mission
    ---@param isTemporary boolean|nil
    ---@param params table|nil
    new = function(cls, mission, params, isTemporary, parent)
        local self = cls:fromSavedata(mission, {
            id = LifeBoatAPI.MissionInstance._generateID(),
            type = mission.type,
            current = 1, -- first thing we do with a new mission is call next()
            lastResult = params
        }, parent)
        
        if not parent then
            LB.missions:trackInstance(self, isTemporary)
        end

        return self
    end;

    ---@param self LifeBoatAPI.MissionInstance
    ---@param name string|nil (optional) name to skip to, otherwise goes to the next stage numerically
    ---@param params table|nil (optional) params object to pass to the next stage, most useful for the initial spawn otherwise can pass just straight via savedata
    next = function(self, name, params)
        -- dispose of the current stage
        if self.currentStage then
            local stage = self.currentStage
            self.currentStage = nil -- hack to prevent double-next from listener
            stage:terminate()
        end

        self.savedata.lastResult = params
        self.savedata.currentChildSavedata = {
            current = 1, -- first thing we do with a new mission is call next()
            lastResult = params
        }

        -- move to the next stage and run it if it exists
        self.savedata.current = (name and self.mission.stageIndexesByName[name]) or (self.savedata.current + 1)
        
        local stageData = self.mission.stages[self.savedata.current]
        if not stageData then
            if self.parent then
                -- parent side we also need to handle killing this one; perhaps we need to actually do 
                self.parent:next(nil, params)
            else
                self:terminate()
            end
        else
            self.currentStage = LifeBoatAPI.MissionInstance:fromSavedata(stageData, self.savedata.currentChildSavedata, self)
            if self.currentStage.isDisposed then
                self:next()
            else
                self.disposables[#self.disposables+1] = self.currentStage.onComplete:register(function (l, context, mission)
                    if self.currentStage ~= nil then -- prevent duplicate-next from destroying child
                        self:next() -- when the child stage finishes, we move on
                    end
                end)
            end
        end
    end;

    ---@param self LifeBoatAPI.MissionInstance
    onDispose = function (self)
        if self.onComplete.hasListeners then
            self.onComplete:trigger(self)
        end

        if self.currentStage then
            local stage = self.currentStage
            self.currentStage = nil -- hack to prevent double-next from listener
            stage:terminate()
        end

        if not self.parent then
            LB.missions:stopTracking(self)
        end
    end;
}


-- could have the registration here too?
-- would mean that LB events onInit can be used from anywhere else - easier to connect things to
---@class LifeBoatAPI.Mission
---@field stages LifeBoatAPI.Mission[]
---@field stageIndexesByName table<string, number>
---@field type string
---@field parent LifeBoatAPI.Mission
---@field onExecute LifeBoatAPI.MissionExecutionFunction
LifeBoatAPI.Mission = {

    ---@param cls LifeBoatAPI.Mission
    ---@param uniqueMissionTypeName string
    ---@param fun LifeBoatAPI.MissionExecutionFunction
    ---@param parent LifeBoatAPI.Mission|nil
    ---@return LifeBoatAPI.Mission
    new = function(cls, uniqueMissionTypeName, fun, parent)
        local self = {
            type = uniqueMissionTypeName,
            parent = parent,
            stages = {},
            stageIndexesByName = {},
            
            -- working method
            onExecute = fun;

            -- methods
            addStage = cls.addStage,
            addNamedStage = cls.addNamedStage,
            start = cls.start,
            startUnique = cls.startUnique,

        }

        LB.missions:registerMissionType(self)

        return self
    end;

    ---@param self LifeBoatAPI.Mission
    ---@param fun LifeBoatAPI.MissionExecutionFunction
    ---@return LifeBoatAPI.Mission
    addStage = function(self, fun)
        local child = LifeBoatAPI.Mission:new("", fun, self)
        self.stages[#self.stages+1] = child
        return child
    end;

    ---@param self LifeBoatAPI.Mission
    ---@param name string
    ---@param fun LifeBoatAPI.MissionExecutionFunction
    ---@return LifeBoatAPI.Mission
    addNamedStage = function(self, name, fun)
        local child = LifeBoatAPI.Mission:new(name, fun, self)

        self.stages[#self.stages+1] = child
        self.stageIndexesByName[name] = #self.stages
        
        return child
    end;

    ---Ensures this mission is unique, and gets the existing instance of it if one is there
    ---@param self LifeBoatAPI.Mission
    ---@return LifeBoatAPI.MissionInstance
    startUnique = function(self, params)
        -- find an existing version of this mission if it already exists
        local missionsOfType = LB.missions.missionsByType[self.type]
        
        if missionsOfType and #missionsOfType > 0 then
            return missionsOfType[1]
        else
            local instance = self:start(params)
            return instance
        end
    end;

    ---@param self LifeBoatAPI.Mission
    ---@param isTemporary boolean|nil
    ---@return LifeBoatAPI.MissionInstance
    start = function(self, params, isTemporary)
        return LifeBoatAPI.MissionInstance:new(self, params, isTemporary)
    end;
}

---@endsection