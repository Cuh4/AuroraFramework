
---@alias LifeBoatAPI.ITickableFunc fun(listener:LifeBoatAPI.ITickable, context:any, deltaTicks:number)

---@class LifeBoatAPI.ITickable : LifeBoatAPI.IDisposable
---@field tickFrequency number
---@field nextTick number
---@field onExecute LifeBoatAPI.ITickableFunc
---@field isPaused boolean
---@field lastTick number 
---@field context any|nil
---@field disableTickSpread any|nil

LifeBoatAPI.TickFrequency = {
    REALTIME    = 1,        -- relatively few things need to happen every tick - consider before using this
    HIGH        = 20,       -- player interactions that need to "feel instant"
    LOW         = 60,       -- player interactions that can afford a "slight delay"
    BACKGROUND  = 5*60,    -- things that aren't directly affecting the player/out of their sight do not need to happen so immediately
}

---@class LifeBoatAPI.TickManager
---@field ticks number
---@field gameTicks number
---@field tickables table<number, LifeBoatAPI.ITickable[]>
LifeBoatAPI.TickManager = {

    ---@param cls LifeBoatAPI.TickManager
    ---@return LifeBoatAPI.TickManager
    new = function (cls)
        local self = {
            tickables = {};
            ticks = 0;
            gameTicks = 0;
            
            --methods
            init = cls.init,
            register = cls.register;
            _onTickClosure = cls._onTickClosure
        }

        return self
    end;

    ---@param self LifeBoatAPI.TickManager
    init = function(self)
        onTick = self:_onTickClosure()
    end;

    ---@param self LifeBoatAPI.TickManager
    ---@param func LifeBoatAPI.ITickableFunc
    ---@param tickFrequency number|nil if nil, will run ONE TIME only and then dispose of itself
    ---@param firstTickDelay number|nil if nil, will run at a random interval between now and repeatFrequency, so that it spaces out evenly
    ---@param context any|nil
    ---@param contextIsTickable boolean|nil if true, the provided context is used as the tickable, directly. (mainly for coroutine simplification)
    ---@return LifeBoatAPI.ITickable
    register = function (self, func, context, tickFrequency, firstTickDelay, contextIsTickable, disableTickSpread)
        tickFrequency = tickFrequency or -1
        
        -- if not explicitly provided, first tick delay should be randomly spread out across the tick frequency
        -- this avoids having tons of tickables all running on the exact same tick, and removing any benefit of the tickable system
        if not firstTickDelay and tickFrequency > 0 then
            firstTickDelay = math.floor(math.random() * math.min(60, tickFrequency)) + 1
        elseif not firstTickDelay then
            firstTickDelay = 1
        end

        local tickable;
        
        if contextIsTickable then
            tickable = context
            tickable.onExecute = func
            tickable.lastTick = self.ticks
        else
            tickable = {
                onExecute = func,
                tickFrequency = tickFrequency,
                lastTick = self.ticks,
                context = context,
                disableTickSpread = disableTickSpread
            }
        end

        -- allow tickables to be run instantly in the tick they're registered, unlikely to be used
        local nextTick = self.ticks + firstTickDelay;

        if firstTickDelay == 0 then
            tickable:onExecute(tickable.context, 0)

            if tickable.tickFrequency > 0 then
                nextTick = self.ticks + tickable.tickFrequency
            else
                if tickable.disposables or tickable.onDispose then
                    LifeBoatAPI.lb_dispose(tickable)
                else
                    tickable.isDisposed = true
                end
                return tickable
            end
        end

        -- set the next tick, without spreading it - we can do that on subsequent ticks
        local nextTickTickables = self.tickables[nextTick]
        if not nextTickTickables then
            self.tickables[nextTick] = {tickable}
        else
            nextTickTickables[#nextTickTickables+1] = tickable
        end

        return tickable
    end;
    
    ---@param self LifeBoatAPI.TickManager
    _onTickClosure = function(self)
        local _onTick = onTick

        return function (gameTicks)
            -- call original/global registered onTick
            if _onTick then
                _onTick(gameTicks)
            end

            self.ticks = self.ticks + 1
            self.gameTicks = self.gameTicks + gameTicks -- track the in-game time separately
            
            local tickables = self.tickables[self.ticks]
            if not tickables then
                return
            end

            self.tickables[self.ticks] = nil -- clear old list
            for i=1, #tickables do
                local tickable = tickables[i]

                if not tickable.isDisposed then

                    if not tickable.isPaused then
                        tickable:onExecute(tickable.context, self.ticks - tickable.lastTick)
                        tickable.lastTick = self.ticks
                    end

                    if tickable.tickFrequency > 0 then
                        local nextTick = self.ticks + tickable.tickFrequency
                        local nextTickTickables = self.tickables[nextTick]

                        -- handle tick spread
                        -- if there's any tickable spread +0, +1, +10 that's empty, we use it
                        -- if tickspread is disabled, don't even calculate it
                        -- otherwise; find the best of the 3 and spread it onto that, so the load is balanced

                        --      over a short period of time, this spreads the load out evenly, so less spikes happen with e.g. 0, 0, 0, 1000 things, 0
                        --      instead should eventually tend towards: 200, 200, 200, 200, 200 things

                        if not nextTickTickables then
                            -- best place is +0 spread
                            self.tickables[nextTick] = {tickable}
                        elseif tickable.disableTickSpread then
                            -- existing ticks, but spread is disabled
                            nextTickTickables[#nextTickTickables+1] = tickable
                        else
                            -- spread ticks
                            local nextTickCount = #nextTickTickables

                            local nextTickSpread1 = nextTick + 1
                            local nextTickTickablesSpread1 = self.tickables[nextTickSpread1]
                            if not nextTickTickablesSpread1 then
                                self.tickables[nextTickSpread1] = {tickable}
                            else
                                local nextTickCountSpread1 = #nextTickTickablesSpread1

                                local nextTickSpread10 = nextTick + 10
                                local nextTickTickablesSpread10 = self.tickables[nextTickSpread10]
                                if not nextTickTickablesSpread10 then
                                    self.tickables[nextTickSpread10] = {tickable}
                                else
                                    local nextTickCountSpread10 = #nextTickTickablesSpread10

                                    -- pick best choice of the 3 potential tick spreads
                                    if nextTickCountSpread10 < nextTickCountSpread1 then
                                        if nextTickCountSpread10 < nextTickCount then
                                            nextTickTickablesSpread10[nextTickCountSpread10 + 1] = tickable
                                        else
                                            nextTickTickables[nextTickCount + 1] = tickable
                                        end
                                    elseif nextTickCountSpread1 < nextTickCount then
                                        nextTickTickablesSpread1[nextTickCountSpread1 + 1] = tickable
                                    else
                                        nextTickTickables[nextTickCount + 1] = tickable
                                    end
                                    
                                end
                            end
                        end
                    else
                        -- todo: decision to make after real-world use: does tickManager need to lb_dispose the tickables, or not
                        if tickable.disposables or tickable.onDispose then
                            LifeBoatAPI.lb_dispose(tickable)
                        else
                            tickable.isDisposed = true
                        end
                    end
                end
            end
        end
    end;
}

