-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


---@class LifeBoatAPI.UIMapObject : LifeBoatAPI.UIElement
---@field savedata table
---@field id number uiID
---@field isPopup boolean
LifeBoatAPI.UIMapObject = {
    ---@return LifeBoatAPI.UIMapObject
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
            show = cls.show,
            onDispose = cls.onDispose
        }

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

    ---@param positionType SWPositionTypeEnum
    ---@param markerType SWMarkerTypeEnum
    ---@param x number
    ---@param z number
    ---@param radius number
    ---@param label string
    ---@param hoverLabel string
    ---@param isTemporary boolean|nil if true, this will not persist between reload_scripts
    ---@param player LifeBoatAPI.Player|nil nil displays to all players
    ---@return LifeBoatAPI.UIMapObject
    new = function(cls, player, positionType, markerType, x, z, radius, label, hoverLabel, parent, isTemporary)
        local obj = cls:fromSavedata({
            id = server.getMapID(),
            type = "mapobject",
            steamID = player and player.steamID or "all",
            positionType = positionType,
            markerType = markerType,
            x = x,
            z = z, 
            parentType = parent and parent.savedata.type,
            parentID = parent and parent.id,
            label = label,
            radius = radius,
            hoverLabel = hoverLabel,
            isTemporary = isTemporary,
        })

        LB.ui:trackEntity(obj)

        return obj
    end;

    ---@param self LifeBoatAPI.UIMapObject
    ---@param peerID number
    show = function(self, peerID)
        local save = self.savedata

        if save.parentID then
            server.addMapObject(peerID, save.id, save.positionType, save.markerType, nil, nil, save.x, save.z, save.parentType == "vehicle" and save.parentID or nil, save.parentType ~= "vehicle" and save.parentID or nil, save.label, save.radius, save.hoverLabel)
        else
            server.addMapObject(peerID, save.id, save.positionType, save.markerType, save.x, save.z, nil, nil, nil, nil, save.label, save.radius, save.hoverLabel)
        end
    end;

    ---@param self LifeBoatAPI.UIMapObject
    onDispose = function(self)
        server.removeMapObject(-1, self.id)
        LB.ui:stopTracking(self)
    end;
}
