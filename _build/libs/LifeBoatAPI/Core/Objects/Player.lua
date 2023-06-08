-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@class EventTypes.LBOnCollisionStart_Player : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, player:LifeBoatAPI.Player, collision:LifeBoatAPI.Collision, zone:LifeBoatAPI.Zone), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.LBOnTeleport_Player : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, player:LifeBoatAPI.Player, vehicle:LifeBoatAPI.Vehicle, x:number, y:number, z:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.LBOnButtonPress_Player : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, player:LifeBoatAPI.Player, vehicle:LifeBoatAPI.Vehicle,  buttonName:string), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.LBOnSeatedChange_Player : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, player:LifeBoatAPI.Player, vehicle:LifeBoatAPI.Vehicle, seatName:string, isSitting:boolean), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.LBOnSpawnVehicle_Player : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, player:LifeBoatAPI.Player, vehicleID:number, x:number, y:number, z:number, cost:number), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.LBOnAliveChanged_Player : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, player:LifeBoatAPI.Player, isAlive:boolean), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.LBOnCommand_Player : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, player:LifeBoatAPI.Player, fullMessage:string, commandName:string, ...:string), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.LBOnChat_Player : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, player:LifeBoatAPI.Player, message:string), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.LBOnToggleMap_Player : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, player:LifeBoatAPI.Player, isOpen:boolean), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener


---@class LifeBoatAPI.Player : LifeBoatAPI.GameObject
---@field id number peerID
---@field steamID string
---@field isAdmin boolean
---@field isAuth boolean
---@field displayName string
---@field savedata table persistent data for this specific player
---@field onCollision EventTypes.LBOnCollisionStart_Player
---@field onTeleport EventTypes.LBOnTeleport_Player
---@field onButtonPress EventTypes.LBOnButtonPress_Player
---@field onSeatedChange EventTypes.LBOnSeatedChange_Player
---@field onSpawnVehicle EventTypes.LBOnSpawnVehicle_Player
---@field onAliveChanged EventTypes.LBOnAliveChanged_Player
---@field onCommand EventTypes.LBOnCommand_Player
---@field onChat EventTypes.LBOnChat_Player
---@field onToggleMap EventTypes.LBOnToggleMap_Player
LifeBoatAPI.Player = {
    ---@param cls LifeBoatAPI.Player
    ---@return LifeBoatAPI.Player
    new = function (cls, peerID, steamID, isAdmin, isAuth, name, savedata)
        savedata.collisionLayer = savedata.collisionLayer or "player"
        savedata.type = "player"
        
        local self = {
            savedata = savedata;
            type = "player";
            id = peerID;
            steamID = steamID;
            isAdmin = isAdmin;
            isAuth = isAuth;
            displayName = name;
            transform = LifeBoatAPI.Matrix:newMatrix(),
            nextUpdateTick = 0,

            --- events
            onDespawn = LifeBoatAPI.Event:new();
            onTeleport = LifeBoatAPI.Event:new();
            onButtonPress = LifeBoatAPI.Event:new();
            onSeatedChange = LifeBoatAPI.Event:new();
            onSpawnVehicle = LifeBoatAPI.Event:new();
            onAliveChanged = LifeBoatAPI.Event:new();
            onCommand = LifeBoatAPI.Event:new();
            onChat = LifeBoatAPI.Event:new();
            onToggleMap = LifeBoatAPI.Event:new();
            onCollision = LifeBoatAPI.Event:new();

            -- methods
            getTransform = cls.getTransform;
            attach = LifeBoatAPI.lb_attachDisposable,
            awaitLoaded = cls.awaitLoaded;
            onDispose = cls.onDispose;
        }

        -- ensure position is up to date
        self:getTransform()

        -- by default all players are collision enabled
        LB.collision:trackEntity(self)
        log("player collision enabled", tostring(self))

        return self
    end;

    ---@param self LifeBoatAPI.Player
    ---@param timeout number|nil time to keep checking for in ticks, before giving up - nil to continue indefinitely
    ---@return LifeBoatAPI.Coroutine
    awaitLoaded = function(self, timeout)
        log("awaiting player loading", "timeout: " .. tostring(timeout))
        -- check if it's already loaded
        local timePassed = 0
        
        local cr = LifeBoatAPI.Coroutine:start()
        :andThen(function (cr, deltaTicks, lastResult)
            -- keep checking if the player has loaded, until the timeout
            timePassed = timePassed + deltaTicks

            if self.isDisposed then
                log("ok", "player disposed while awaiting player")
                return cr.dispose, nil, "Player disconnected"
            end

            local characterID, success = server.getPlayerCharacterID(self.id)
            if success then
                local loadedState, success = server.getObjectSimulating(characterID)
                if success and loadedState then
                    log("ok", "player loaded")
                    return cr.yield, characterID
                end
            elseif timeout and timePassed > timeout then
                log("ok", "timeout reached while awaiting player")
                return cr.dispose, nil, "Timeout reached before loading"
            end

            return cr.loop
        end)

        return cr
    end;

    ---@param self LifeBoatAPI.Player
    getTransform = function(self)
        local matrix, success = server.getPlayerPos(self.id)
        if success then
            self.lastTransform = self.transform
            
            self.transform = matrix
            self.nextUpdateTick = LB.ticks.ticks + 30
        end
        return self.transform
    end;

    onDispose = function(self)
        LB.collision:stopTracking(self)
        log("player collision disabled", tostring(self))
    end;
}