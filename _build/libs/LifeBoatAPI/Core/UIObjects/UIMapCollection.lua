-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey
-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@class LifeBoatAPI.UIMapCollection : LifeBoatAPI.UIElement
LifeBoatAPI.UIMapCollection = {
    ---@param cls LifeBoatAPI.UIMapCollection
    ---@return LifeBoatAPI.UIMapCollection
    fromSavedata = function(cls, savedata)
        local self = {
            savedata = savedata,
            id = savedata.id,

            -- methods
            despawn = LifeBoatAPI.lb_dispose,
            show = cls.show,
            onDispose = cls.onDispose,
            beginDisplaying = cls.beginDisplaying
        }
        
        return self
    end;

    ---@param isTemporary boolean|nil if true, this will not persist between reload_scripts
    ---@param player LifeBoatAPI.Player|nil nil displays to all players
    ---@return LifeBoatAPI.UIMapCollection
    new = function(cls, player, isTemporary)
        local obj = cls:fromSavedata({
            id = server.getMapID(),
            type = "mapcollection",
            steamID = player and player.steamID or "all",
            isTemporary = isTemporary,
            objects = {}
        })

        LB.ui:trackEntity(obj)

        return obj
    end;

    ---@param positionType SWPositionTypeEnum
    ---@param markerType SWMarkerTypeEnum
    ---@param x number
    ---@param z number
    ---@param radius number
    ---@param label string
    ---@param hoverLabel string
    ---@param self LifeBoatAPI.UIMapCollection
    addObject = function(self, positionType, markerType, x, z, radius, label, hoverLabel)
        local objects = self.savedata.objects
        objects[#objects+1] = {type="object", positionType=positionType, markerType=markerType, x=x, z=z, radius=radius, label=label, hoverLabel=hoverLabel}
        return self
    end;

    ---@param labelType SWLabelTypeEnum
    ---@param name string
    ---@param x number
    ---@param z number
    ---@param self LifeBoatAPI.UIMapCollection
    addLabel = function(self, labelType, name, x, z)
        local objects = self.savedata.objects
        objects[#objects+1] = {type="label", labelType=labelType, name=name, x=x, z=z}
        return self
    end;

    ---@param startMatrix LifeBoatAPI.Matrix
    ---@param endMatrix LifeBoatAPI.Matrix
    ---@param width number
    ---@param self LifeBoatAPI.UIMapCollection
    addLine = function(self, startMatrix, endMatrix, width)
        local objects = self.savedata.objects
        objects[#objects+1] = {type="line", startMatrix=startMatrix, endMatrix=endMatrix, width=width}
        return self
    end;

    --- call this once setup with all the lines/objects/labels wanted
    ---@param self LifeBoatAPI.UIMapCollection
    beginDisplaying = function(self)
        if self.savedata.steamID == "all" then
            self:show(-1)
        else
            local player = LB.players.playersBySteamID[self.savedata.steamID]
            if player then
                self:show(player.id)
            end
        end
    end;

    ---@param self LifeBoatAPI.UIMapCollection
    show = function(self, peerID)
        local objects = self.savedata.objects
        for i=1, #objects do
            local object = objects[i]
            local type = object.type
            if type == "object" then
                server.addMapObject(peerID, self.id, object.positionType, object.markerType, object.x, object.z, nil, nil, nil, nil, object.label, object.radius, object.hoverLabel)
            elseif type == "label" then
                server.addMapLabel(peerID, self.id, object.labelType, object.name, object.x, object.z)
            elseif type == "line" then
                server.addMapLine(peerID, self.id, object.startMatrix, object.endMatrix, object.width)
            end
        end
    end;

    ---@param self LifeBoatAPI.UIMapCollection
    onDispose = function(self)
        server.removeMapID(-1, self.id)
        LB.ui:stopTracking(self)
    end;
}