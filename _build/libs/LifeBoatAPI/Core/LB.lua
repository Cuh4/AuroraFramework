

---Global instance of the LifeBoatAPI
---Use LB.member for "live" managers etc.
---Use LifeBoatAPI.member for static types
---@class LifeBoatAPI.LB
---@field ticks LifeBoatAPI.TickManager
---@field collision LifeBoatAPI.CollisionManager
---@field players LifeBoatAPI.PlayerManager
---@field events LifeBoatAPI.EventManager
---@field addons LifeBoatAPI.AddonManager
---@field objects LifeBoatAPI.ObjectManager
---@field ui LifeBoatAPI.UIManager
---@field missions LifeBoatAPI.MissionManager
---@field savedata table
LifeBoatAPI.LB = {

    ---@param cls LifeBoatAPI.LB
    ---@return LifeBoatAPI.LB
    new = function(cls)
        ---@type LifeBoatAPI.LB
        local self = {
            init = cls.init
        }

        self.events = LifeBoatAPI.EventManager:new(); -- necessary? yes (using events multiple places in coroutines etc.)
        self.ticks = LifeBoatAPI.TickManager:new();
        self.addons = LifeBoatAPI.AddonManager:new();
        self.collision = LifeBoatAPI.CollisionManager:new(); -- fair, specific purpose
        self.players = LifeBoatAPI.PlayerManager:new(self.events);
        self.objects = LifeBoatAPI.ObjectManager:new(self.events);
        self.ui = LifeBoatAPI.UIManager:new(self.players);
        self.missions = LifeBoatAPI.MissionManager:new()
        return self
    end;

    ---@param self LifeBoatAPI.LB
    init = function(self)
        self.savedata = g_savedata

        -- order of this is painfully important
        -- frustratingly bad initialization order
        
        self.events:init() -- registers game callbacks, won't affect anything until after full init()
        self.ticks:init() -- registers ticking, won't affect anything till after full init() complete
        self.collision:init() -- does nothing
        self.addons:init() -- loads all addon data, needs to be before anything that might lookup "what's going on" etc. Does not cause any other knock-ons 
        
        self.ui:init() -- destroy previous UI then create all new, must be before anything UI creating

        self.objects:init() -- load all object persist date
        self.players:init() -- trigger init for each existing player
        self.missions:init() -- start missionsByID

        if self.events.onCreate.hasListeners then
            self.events.onCreate:trigger()
        end
    end;
}

LB = LifeBoatAPI.LB:new()