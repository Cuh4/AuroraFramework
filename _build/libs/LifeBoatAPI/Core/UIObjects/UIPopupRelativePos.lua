-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


---@class LifeBoatAPI.UIPopupRelativePos : LifeBoatAPI.UIElement
---@field savedata table
---@field id number uiID
---@field tickable LifeBoatAPI.ITickable
---@field parent LifeBoatAPI.GameObject
LifeBoatAPI.UIPopupRelativePos = {

    ---@param cls LifeBoatAPI.UIPopupRelativePos
    ---@return LifeBoatAPI.UIPopupRelativePos
    fromSavedata = function(cls, savedata)

        local parentID = savedata.parentID
        local parentType = savedata.parentType
        local parent;
        if parentID and parentType then
            parent = LB.objects:getByType(parentType, parentID)
        end

        local self = {
            savedata = savedata,
            id = savedata.id,
            parent = parent,
            nextUpdateTick = 0,

            -- methods
            redraw = cls.redraw,
            despawn = LifeBoatAPI.lb_dispose,
            onDispose = cls.onDispose,
            show = cls.show,
            edit = cls.edit
        }

        -- meant to be attached to an object that's now gone, or parent object exists but is disposed
        if not parent then -- this specific UI type cannot exist without a valid parent 
            LifeBoatAPI.lb_dispose(self)
        else
            parent:attach(self)
        end

        if self.isDisposed then
            return self
        end

        -- reminder parent and player are NOT the same
        -- parent if the object being tracked
        -- potential to need to start showing from the start of being created, if the player exists
        local player = LB.players.playersBySteamID[savedata.steamID]
        if self.savedata.steamID == "all" or player then
            self:show()
        end

        return self
    end;

    ---@param cls LifeBoatAPI.UIPopupRelativePos
    ---@param isTemporary boolean|nil if true, this will not persist between reload_scripts
    ---@param player LifeBoatAPI.Player|nil nil displays to all players
    ---@param parent LifeBoatAPI.GameObject
    ---@return LifeBoatAPI.UIPopupRelativePos
    new = function(cls, player, text, offset, centerOffset,  renderDistance, parent, isTemporary)
        local obj = cls:fromSavedata({
            id = server.getMapID(),
            type = "popuprelative",
            steamID = player and player.steamID or "all",
            offset = offset,
            centerOffset = centerOffset, 
            text = text,
            renderDistance = renderDistance,
            parentID = parent and parent.id,
            parentType = parent and parent.savedata.type,
            isTemporary = isTemporary,
        })

        LB.ui:trackEntity(obj)

        return obj
    end;

    ---@param self LifeBoatAPI.UIPopupRelativePos
    show = function(self)
        -- needs to be implemented, as we can end up "showing" this at any time
        -- what we don't want, is this to be running constantly without any need
        -- and we don't want to create a new tickable every time a player joins if it's (-1)
        if not self.tickable then
            -- begin following the given parent 
            self.tickable = LB.ticks:register(self.redraw, self, 30, 0)
        end
    end;

    redraw = function(listener, ctx, deltaGameTicks)
        local self = ctx
        local save = self.savedata

        local peerID;
        if save.steamID == "all" then
            peerID = -1
        else
            local player = LB.players.playersBySteamID[save.steamID]
            if player then
               peerID = player.id
            else
                -- singular player we're displaying to, has gone 
                listener.isDisposed = true
                self.tickable = nil
                server.removePopup(-1, self.id)
                return
            end
        end

        -- redraw, avoid function call cost
        if self.nextUpdateTick ~= self.parent.nextUpdateTick then
            if self.parent.nextUpdateTick <= LB.ticks.ticks then
                self.parent:getTransform()
            end

            local transform = save.centerOffset and LifeBoatAPI.Matrix.multiplyMatrix(save.centerOffset, self.parent.transform) or self.parent.transform
            local offset = save.offset and LifeBoatAPI.Matrix.multiplyMatrix(transform, save.offset) or transform
            local x,y,z = offset[13], offset[14], offset[15]
            server.setPopup(peerID, save.id, nil, save.text ~= "", save.text, x, y, z, save.renderDistance, nil, nil)

            self.nextUpdateTick = self.parent.nextUpdateTick
        end
    end;

    ---Override the existing values and re-show, provide "false" to mean "don't overwrite the existing value"
    ---@param self LifeBoatAPI.UIPopupRelativePos
    ---@param text string|nil
    ---@param offset LifeBoatAPI.Matrix|nil
    ---@param centerOffset LifeBoatAPI.Matrix|nil
    ---@param renderDistance number|nil
    edit = function(self, text, offset, centerOffset, renderDistance)
        local save = self.savedata
        save.text = text or save.text
        save.offset = offset or save.offset;
        save.centerOffset = centerOffset or save.centerOffset;
        save.renderDistance = renderDistance or save.renderDistance;
        self.nextUpdateTick = 0

        self.redraw(self.tickable, self, 0)
    end;

    ---@param self LifeBoatAPI.UIPopupRelativePos
    onDispose = function(self)
        self.tickable.isDisposed = true
        server.removePopup(-1, self.id)
        LB.ui:stopTracking(self)
    end;
}
