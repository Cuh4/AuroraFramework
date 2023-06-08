-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@class LifeBoatAPI.IDisposable
---@field isDisposed boolean|nil
---@field disposables LifeBoatAPI.IDisposable[]|nil
---@field onDispose fun(self: LifeBoatAPI.IDiposable)|nil
---@field attach fun(self:LifeBoatAPI.IDisposable, child:LifeBoatAPI.IDisposable)

--- quick container for when a  basic disposable parent is needed
---@class LifeBoatAPI.SimpleDisposable : LifeBoatAPI.IDisposable
LifeBoatAPI.SimpleDisposable = {
    new = function(cls)
        return {
            disposables = {},

            attach = LifeBoatAPI.lb_attachDisposable
        }
    end;
}

-- natural events, tick handlers etc. should watch for isDisposed when they fire
-- when this happens, remove anything that is disposed of
-- larger objects that contain others, should self-dispose using this function - to ensure all children are disposed of correctly
-- it adds an overhead, but arguably not that huge, and only when things destruct (which shouldn't include small/useless objects)
-- anything that contains an IDiposable should itself be an IDisposable - that way the chain is always maintained
---@param disposable LifeBoatAPI.IDisposable
LifeBoatAPI.lb_dispose = function(disposable)
    --[[
        goes through every child and disposes of it in turn, if it's not already disposed of
        optimized to avoid recursive function calls, so this is relatively cheap to use whenever needing to dispose of something
    ]]
    if disposable.disposables then
        local disposablesStack = {disposable}

        -- unrolled recursion, handle disposal for all children
        local iStack = 1
        local numDisposables = 1
        while iStack <= numDisposables do
            local disposable = disposablesStack[iStack]
            iStack = iStack + 1

            if not disposable.isDisposed then
                if disposable.disposables then
                    for i=1, #disposable.disposables do
                        numDisposables = numDisposables + 1
                        disposablesStack[numDisposables] = disposable.disposables[i]
                    end
                end
                disposable.isDisposed = true
                if disposable.onDispose then
                    disposable:onDispose()
                end
            end
        end
    else
        -- minor optimization, avoid all the disposables loops if we just have 1 thing to dispose of
        disposable.isDisposed = true
        if disposable.onDispose then
            disposable:onDispose()
        end
    end
end;

---Attaches the given disposable, to the given object; so when the object is disposed - the attached disposable is too
---@param self LifeBoatAPI.IDisposable
---@vararg LifeBoatAPI.IDisposable 
LifeBoatAPI.lb_attachMultiple = function(self, ...)
    local children = {...}
    for i=1, #children do
        local child = children[i]
        if not self.isDisposed then
            self.disposables = self.disposables or {}
            self.disposables[#self.disposables+1] = child
        else
            -- already disposed, so dispose the child immediately
            LifeBoatAPI.lb_dispose(child)
        end
    end
end;

---Attaches the given disposable, to the given object; so when the object is disposed - the attached disposable is too
---@param self LifeBoatAPI.IDisposable
---@param child LifeBoatAPI.IDisposable
LifeBoatAPI.lb_attachDisposable = function(self, child)
    if not self.isDisposed then
        self.disposables = self.disposables or {}
        self.disposables[#self.disposables+1] = child
    else
        -- already disposed, so dispose the child immediately
        LifeBoatAPI.lb_dispose(child)
    end
end;