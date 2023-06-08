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


---@class LifeBoatAPI.UIScreenPopup : LifeBoatAPI.UIElement
---@field savedata table
---@field id number uiID
---@field isPopup boolean
LifeBoatAPI.UIScreenPopup = {

    ---@return LifeBoatAPI.UIScreenPopup
    fromSavedata = function(cls, savedata, isTemporary)
        local self = {
            savedata = savedata,
            id = savedata.id,

            -- methods
            despawn = LifeBoatAPI.lb_dispose,
            show = cls.show,
            onDispose = cls.onDispose,
            edit = cls.edit
        }

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
    ---@return LifeBoatAPI.UIScreenPopup
    new = function(cls, player, text, screenX, screenY, isTemporary)
        local obj = cls:fromSavedata({
            id = server.getMapID(),
            type = "screenpopup",
            steamID = player and player.steamID or "all",
            screenX = screenX,
            screenY = screenY,
            text = text,
            isTemporary = isTemporary,
        })

        LB.ui:trackEntity(obj)

        return obj
    end;

    ---@param self LifeBoatAPI.UIElement
    ---@param peerID number true => display, false => hide
    show = function(self, peerID)
        local save = self.savedata
        server.setPopupScreen(peerID, save.id, nil, true, save.text, save.screenX, save.screenY)
    end;


    ---Override the existing values and re-show, leave values nil to leave them unchanged
    ---@param self LifeBoatAPI.UIPopup
    ---@param text string|nil
    ---@param screenX number|nil
    ---@param screenY number|nil
    edit = function(self, text, screenX, screenY)
        local save = self.savedata
        save.text = text or save.text
        save.screenX = screenX or save.screenX
        save.screenY = screenY or save.screenY

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

    ---@param self LifeBoatAPI.UIElement
    onDispose = function(self)
        server.removePopup(-1, self.id)
        LB.ui:stopTracking(self)
    end;
}
