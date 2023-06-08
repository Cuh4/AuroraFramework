-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


---@class LifeBoatAPI.UIPopup : LifeBoatAPI.UIElement
---@field savedata table
---@field id number uiID
---@field isPopup boolean
LifeBoatAPI.UIPopup = {

    ---@return LifeBoatAPI.UIPopup
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

            -- methods
            despawn = LifeBoatAPI.lb_dispose,
            onDispose = cls.onDispose,
            show = cls.show,
            edit = cls.edit
        }

        -- meant to be attached to an object that's now gone, or parent object exists but is disposed
        if parentID and not parent then
            LifeBoatAPI.lb_dispose(self)
        elseif parent then
            parent:attach(self)
        end

        if self.isDisposed then
            return self
        end

        if self.savedata.steamID == "all" then
            self:show(-1)
        else
            local player = LB.players.playersBySteamID[savedata.steamID]
            if player then
                self:show(player.id)
            end
        end

        return self
    end;

    ---@param isTemporary boolean|nil if true, this will not persist between reload_scripts
    ---@param player LifeBoatAPI.Player|nil nil displays to all players
    ---@return LifeBoatAPI.UIPopup
    new = function(cls, player, text, x, y, z, renderDistance, parent, isTemporary)
        local obj = cls:fromSavedata({
            id = server.getMapID(),
            type = "popup",
            steamID = player and player.steamID or "all",
            x = x,
            y = y,
            z = z,
            text = text,
            renderDistance = renderDistance,
            parentID = parent and parent.id,
            parentType = parent and parent.savedata.type,
            isTemporary = isTemporary,
        })

        LB.ui:trackEntity(obj)

        return obj
    end;

    ---Override the existing values and re-show, leave values nil to leave them unchanged
    ---@param self LifeBoatAPI.UIPopup
    ---@param text string|nil
    ---@param x number|nil
    ---@param y number|nil
    ---@param z number|nil
    ---@param renderDistance number|nil
    edit = function(self, text, x,y,z, renderDistance)
        local save = self.savedata
        save.text = text or save.text
        save.x = x or save.x
        save.y = y or save.y
        save.z = z or save.z
        save.renderDistance = renderDistance or save.renderDistance

        -- reshow
        if self.savedata.steamID == "all" then
            self:show(-1)
        else
            local player = LB.players.playersBySteamID[save.steamID]
            if player then
                self:show(player.id)
            end
        end
    end;

    ---@param self LifeBoatAPI.UIPopup
    ---@param peerID number
    show = function(self, peerID)
        if self.isDisposed then
            -- prevent accidentally re-showing a dialog that will then never be re-disposed/destroyed
            log("cant reshow UI, already disposed", self.id)
            return 
        end

        local save = self.savedata

        log("showing popup", self.id, "to player", peerID, "with text", save.text)

        if save.parentID then
            server.setPopup(peerID, save.id, nil, save.text ~= "", save.text, save.x, save.y, save.z, save.renderDistance, save.parentType == "vehicle" and save.parentID or nil, save.parentType ~= "vehicle" and save.parentID or nil)
        else
            server.setPopup(peerID, save.id, nil, save.text ~= "", save.text, save.x, save.y, save.z, save.renderDistance, nil, nil)
        end
    end;

    ---@param self LifeBoatAPI.UIPopup
    onDispose = function(self)
        server.removePopup(-1, self.id)
        LB.ui:stopTracking(self)
    end;
}
