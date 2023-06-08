


-- Manager for handling UI popups/map markers
-- Ensures those meant for all players, are added whenever a player connects
-- Ensures those meant for a single player, are added when that player re-connects etc.
-- Provides a smooth way to handle basic popups
---@class LifeBoatAPI.UIManager
---@field savedata table
---@field uiByID table<number, LifeBoatAPI.UIElement>
---@field uiBySteamID table<string, LifeBoatAPI.UIElement[]>
LifeBoatAPI.UIManager = {
    ---@param cls LifeBoatAPI.UIManager
    ---@param playerManager LifeBoatAPI.PlayerManager
    ---@return LifeBoatAPI.UIManager
    new = function(cls, playerManager)
        local self = {
            savedata = {
                uiByID = {}, -- id : savedata
                temporaryUIIDs = {} -- list of ids to be killed when re-starting the server, as these are all temporary
            };
            uiByID = {}; -- id: object
            uiBySteamID = { -- id: object[]
                all = {}
            };

            --- methods
            init = cls.init,
            trackEntity = cls.trackEntity,
            stopTracking = cls.stopTracking,
            getUIByID = cls.getUIByID,
            getUIBySteamID = cls.getUIBySteamID,
            _onPlayerJoin = cls._onPlayerJoin
        }

        -- register for new players connecting
        playerManager.onPlayerConnected:register(self._onPlayerJoin, self)
        
        return self
    end;

    ---@param self LifeBoatAPI.UIManager
    init = function(self)
        g_savedata.uiManager = g_savedata.uiManager or self.savedata
        self.savedata = g_savedata.uiManager

        -- kill all temporaryIDs that shouldn't exist anymore
        -- prevents UI duplicates between reload_scripts
        for i=1, #self.savedata.temporaryUIIDs do
            local uiID = self.savedata.temporaryUIIDs[i]
            server.removePopup(-1, uiID)
            server.removeMapID(-1, uiID)
        end
        self.savedata.temporaryUIIDs = {}

        -- load all elements (note: only very popular, long running servers - potentially for data leak, due to UI that never gets seen again, by players who never return)
        for id, elementSave in pairs(self.savedata.uiByID) do
            local element;
            if elementSave.type == "maplabel" then
                element = LifeBoatAPI.UIMapLabel:fromSavedata(elementSave)
            elseif elementSave.type == "mapline" then
                element = LifeBoatAPI.UIMapLine:fromSavedata(elementSave)
            elseif elementSave.type == "mapobject" then
                element = LifeBoatAPI.UIMapObject:fromSavedata(elementSave)
            elseif elementSave.type == "popup" then
                element = LifeBoatAPI.UIPopup:fromSavedata(elementSave)
            elseif elementSave.type == "screenpopup" then
                element = LifeBoatAPI.UIScreenPopup:fromSavedata(elementSave)
            elseif elementSave.type == "mapcollection" then
                element = LifeBoatAPI.UIMapCollection:fromSavedata(elementSave)
                element:beginDisplaying()
            elseif elementSave.type == "popuprelative" then
                element = LifeBoatAPI.UIPopupRelativePos:fromSavedata(elementSave)
            end

            if element and not element.isDisposed then
                self.uiByID[element.id] = element

                local steamID = element.savedata.steamID
                self.uiBySteamID[steamID] = self.uiBySteamID[steamID] or {}
                self.uiBySteamID[steamID][#self.uiBySteamID[steamID]+1] = element
            end
        end


    end;

    ---@param self LifeBoatAPI.UIManager
    ---@param player LifeBoatAPI.Player
    _onPlayerJoin = function(l, self, player)
        
        -- when the player joins, give them all the UI they are entitled to
        -- this will generally be used for when you want popups to display for all players
        local uiForAll = self.uiBySteamID["all"]
        log("finding UI", "for player (steamID)", player.steamID, " there are ", uiForAll and #uiForAll or "nil", " elements to show to all")
        if uiForAll then
            for i=1, #uiForAll do
                local ui = uiForAll[i]
                ui:show(player.id)
                log("showing player UI", "UI with ID: " .. tostring(ui.id))
            end
        end

       
        local uiBySteamID = self.uiBySteamID[player.steamID]
        log("finding ui", "there are ", uiBySteamID and #uiBySteamID or "nil", " elements specific to the player")
        if uiBySteamID then
            for i=1, #uiBySteamID do
                local ui = uiBySteamID[i]
                ui:show(player.id)
            end
        end
    end;

    --- Tracks this entity, so that it exists "permanently"
    ---@param self LifeBoatAPI.UIManager
    ---@param uiElement LifeBoatAPI.UIElement
    trackEntity = function(self, uiElement)
        if uiElement.isDisposed then
            return 
        end

        log("new ui element tracking with id: ", uiElement.id, uiElement.savedata.type, "and showing to", uiElement.savedata.steamID)
        
        -- temporary elements are stored separately, so we can safely remove them next reload
        if uiElement.savedata.isTemporary then
            self.savedata.temporaryUIIDs[#self.savedata.temporaryUIIDs+1] = uiElement.id
        else
            self.savedata.uiByID[uiElement.id] = uiElement.savedata
        end

        self.uiByID[uiElement.id] = uiElement

        -- add to list by steamID
        local uiBySteamID = self.uiBySteamID[uiElement.savedata.steamID]
        if not uiBySteamID then
            self.uiBySteamID[uiElement.savedata.steamID] = {uiElement}
        else
            uiBySteamID[#uiBySteamID+1] = uiElement
        end

        local allElements = self.uiBySteamID.all
        log("there are now", allElements and #allElements or "nil", "elements for all")
    end;

    ---@param self LifeBoatAPI.UIManager
    ---@param uiElement LifeBoatAPI.UIElement
    stopTracking = function(self, uiElement)
        log("stopping tracking ui element", uiElement.id, "steamID", uiElement.savedata.steamID) -- if this is all, it'll delete everything lmao
        self.savedata.uiByID[uiElement.id] = nil
        self.uiByID[uiElement.id] = nil

        local bySteamID = self.uiBySteamID[uiElement.savedata.steamID]
        for i=#bySteamID, 1, -1 do
            if bySteamID[i] == uiElement then
                table.remove(bySteamID, i)
            end
        end

        log("there are now", #bySteamID, " elements with the steamID ", uiElement.savedata.steamID)
    end;

    ---@param self LifeBoatAPI.UIManager
    ---@param uiID number
    ---@return LifeBoatAPI.UIElement
    getUIByID = function(self, uiID)
        return self.uiByID[uiID]
    end;

    ---@param self LifeBoatAPI.UIManager
    ---@param steamID string
    ---@return LifeBoatAPI.UIElement[]
    getUIBySteamID = function(self, steamID)
        return self.uiBySteamID[steamID] or {}
    end;
}
