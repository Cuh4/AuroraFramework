-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


-- performance tests on new CPU
--- run 10000/tick - rough benchmarks
--emptyFunc() --25
--isPointInSphere(a,m,5) --35ms
--isLineInSphere(a,b,m,5) --45ms
--isPointInZone -- 40ms
--isLineInZone -- 55ms

--server.isInZone(m, "Z1")  --100ms
--server.isInTransformArea(m,m,5,5,5) -- 160ms

--- run 10,000 times/tick - rough benchmarks
-- matrix.invert    130ms (game provided, handles all matrix inverses)
-- fullInvert       65ms  (all matrices, including projection)
-- fastFullInvert   45ms  (all affine matrices, 0,0,0,1 column4)
-- fastInvert       25ms  (all RotoTrans matrices - aka in-game matrices)
-- emptyFunc        11ms  ("just calling a function that does nothing" benchmark, aka shortest possible runtime)
-- local num*num    0.4ms (rough "general PC performance" benchmark)


-- fast implementation of restructuring a table/removing dead entries; performance friendly
efficientTableRestructure = function(t, keepItemPredicate)
    local to = 1
    local isRestructuring = false
    for from = 1, #t do
        local value = t[from]
        if isRestructuring then
            -- avoid unnecessary writes until we've hit at least one element needing removed
            t[from] = nil
        end

        -- do things with the element

        -- replace with inline condition to tell if value should be removed
        if keepItemPredicate(t[from]) then
            if isRestructuring then
                t[to] = value
            end

            to = to + 1
        else
            isRestructuring = true
        end
    end
end


--- fast inline implementation of math.floor 
--- not to be called directly, but copied into code that needs it
local TruncateDecimals = function(a)
    return a - (a%1)
end

--- example of putting values into "buckets" based on a given resolution
--- used for spatial partitioning for example (resolution would be the bucket size in meters)
local FloorResolution = function(a, resolution)
    a = a * (1/resolution)
    return a - (a%1)
end

print(FloorResolution(1212.31231, 1000))