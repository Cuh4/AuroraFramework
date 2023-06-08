-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@section CoroutineUtils

-- Coroutine that triggers once any player has entered the zone
LifeBoatAPI.CoroutineUtils = {

    --- Disposes of an object after the given number of ticks
    --- Useful for UI popups, where you want it to be destroyed after e.g. 10 seconds
    ---@param disposable LifeBoatAPI.IDisposable
    ---@param numTicks number number of ticks to delay before disposing of this object
    ---@return LifeBoatAPI.Coroutine
    disposeAfterDelay = function(disposable, numTicks)
        local cr = LifeBoatAPI.Coroutine:start(nil, true)
        LB.ticks:register(function (listener, context, deltaGameTicks) 
            if disposable.onDispose or disposable.disposables then
                LifeBoatAPI.lb_dispose(disposable)
            else
                disposable.isDisposed = true
            end
            cr:trigger()
        end, nil, -1, numTicks)
        return cr
    end;

    ---creates a delay that triggers after the given number of ticks have passed
    ---@param numTicks number number of ticks to delay for (number of times onTick will run, can get the actual in-game delay from deltaTime)
    ---@return LifeBoatAPI.Coroutine
    delay = function(numTicks)
        local cr = LifeBoatAPI.Coroutine:start(nil, true)
        LB.ticks:register(function() cr:trigger() end, cr, -1, numTicks, nil, true); -- no need to worry about disposing, as it will self-dispose after being run once
        return cr
    end;


    --- awaits the provided coroutines, and only triggers once all of them have completed
    --- the lastResult field of the chained function, will then be the list of results in the same order they were given as parameters
    --- (i.e. lastResult[1] => coroutines[1].lastResult, and so forth)
    ---@vararg LifeBoatAPI.Coroutine
    ---@return LifeBoatAPI.Coroutine
    awaitAll = function(...)
        local coroutines = {...}
        local awaitAllRoutine = LifeBoatAPI.Coroutine:start(nil, true)

        local results = {} -- results stored in the order given in parameters

        local numToAwait = 0
        for i=1, #coroutines do
            local coroutine = coroutines[i]

            -- if the coroutine is has already "finished" or is now disposed, we don't need to await it
            -- it already has a result
            if coroutine.status == 2 or coroutine.isDisposed then
                if coroutine.lastResult then
                    results[i] = coroutine.lastResult
                end
            else
                numToAwait = numToAwait + 1

                coroutine.listeners[#coroutine.listeners+1] = {
                    trigger = function(l)
                        l.isDisposed = true -- safe to call directly, as internal and will never have any disposable children
                        results[i] = coroutine.lastResult

                        numToAwait = numToAwait - 1

                        if numToAwait == 0 then
                            awaitAllRoutine.lastResult = results -- last result is the list of each non-nil result that was returned
                            awaitAllRoutine:trigger()
                        end
                    end
                }
            end
        end
        
        return awaitAllRoutine
    end;


    --- awaits the provided coroutines, and triggers once any of them are complete
    --- the lastResult field of the chained function, is the result from whichever coroutine finishes first
    ---@vararg LifeBoatAPI.Coroutine
    ---@return LifeBoatAPI.Coroutine
    awaitAny = function(...)
        local coroutines = {...}
        local cr = LifeBoatAPI.Coroutine:start(nil, true)

        -- check if any are already finished, avoid bothering to setup listeners
        for i=1, #coroutines do
            local coroutine = coroutines[i]
            if coroutine.status==2 or coroutine.isDisposed then
                cr.lastResult = coroutine.lastResult
                cr:trigger()
                return cr
            end
        end

        -- trigger if any of them trigger (we already know all coroutines in the list are active/awaitable)
        local triggers = {}
        for i=1, #coroutines do
            local coroutine = coroutines[i]
            local trigger = {
                parent = coroutine;
                trigger = function(self)
                    -- kill this and all other triggers
                    for i=1, #triggers do
                        triggers[i].isDisposed = true -- safe as these listeners are internal
                    end

                    cr.lastResult = coroutine.lastResult -- result is from whichever coroutine finished first (Allowing checking for e.g. failures etc.)
                    cr:trigger()
                end
            }
            triggers[#triggers+1] = trigger
            coroutine.listeners[#coroutine.listeners+1] = trigger
        end
        
        return cr
    end;
}

---@endsection