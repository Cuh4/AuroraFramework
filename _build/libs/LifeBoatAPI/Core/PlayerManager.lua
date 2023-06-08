
---@class EventTypes.LBOnPlayerConnected : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, player:LifeBoatAPI.Player), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class EventTypes.LBOnPlayerFirstTimeConnected : LifeBoatAPI.ENVCallbackEvent
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, player:LifeBoatAPI.Player), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener


---Handles all players join/leave status
---@class LifeBoatAPI.PlayerManager
---@field enablePlayerSaveTracking boolean (default false) whether to track players in g_savedata or not, and whether each player should have it's own savedata
---@field savedata table
---@field playersByPeerID table<number, LifeBoatAPI.Player>
---@field playersBySteamID table<string, LifeBoatAPI.Player>
---@field players LifeBoatAPI.Player[]
---@field onPlayerFirstTimeConnected EventTypes.LBOnPlayerFirstTimeConnected
---@field onPlayerConnected EventTypes.LBOnPlayerConnected
LifeBoatAPI.PlayerManager = {

    ---@param cls LifeBoatAPI.PlayerManager
    ---@param eventManager LifeBoatAPI.EventManager
    ---@return LifeBoatAPI.PlayerManager
    new = function(cls, eventManager)
        local self = {
            savedata = {
                playersBySteamID = {};
            };
            players = {};
            playersByPeerID = {};
            playersBySteamID = {};
            savedata_playerDataBySteamID = {};
            onPlayerFirstTimeConnected = LifeBoatAPI.Event:new();
            onPlayerConnected = LifeBoatAPI.Event:new();

            -- methods
            init = cls.init;
            _onPlayerJoin = cls._onPlayerJoin;
            _onPlayerLeave = cls._onPlayerLeave;
            getSaveDataBySteamID = cls.getSaveDataBySteamID;
            getPlayerBySteamID = cls.getPlayerBySteamID,
            getPlayerByPeerID = cls.getPlayerByPeerID
        }

        eventManager.onPlayerJoin:register(self._onPlayerJoin, self)
        eventManager.onPlayerLeave:register(self._onPlayerLeave, self)

        return self
    end;

    ---@param self LifeBoatAPI.PlayerManager
    init = function(self)
        g_savedata.playerManager = g_savedata.playerManager or self.savedata
        self.savedata = g_savedata.playerManager

        -- handle already-joined players
        log("loading existing players (init)")
        local swPlayers = server.getPlayers()
        for i=1, #swPlayers do
            local swPlayer = swPlayers[i]

            self._onPlayerJoin(nil, self, swPlayer.steam_id, swPlayer.name, swPlayer.id, swPlayer.admin, swPlayer.auth)
        end
        log("finished loading players")
    end;

    ---@param self LifeBoatAPI.PlayerManager
    ---@param steamID number
    getPlayerBySteamID = function(self, steamID)
        return self.playersBySteamID[steamID]
    end;

    ---@param self LifeBoatAPI.PlayerManager
    ---@param peerID number
    getPlayerByPeerID = function (self, peerID)
        return self.playersByPeerID[peerID]
    end;

    ---@param self LifeBoatAPI.PlayerManager
    ---@param steamID string
    getSaveDataBySteamID = function(self, steamID)
        steamID = tostring(steamID)
        return self.savedata.playersBySteamID[steamID]
    end;

    ---@param self LifeBoatAPI.PlayerManager
    _onPlayerJoin = function (l, self, steamID, name, peerId, isAdmin, isAuth)
        steamID = tostring(steamID)

        local isFirstTimeJoining = false;

        -- first time player has joined the server
        if self.enablePlayerSaveTracking and not self.savedata.playersBySteamID[steamID] then
            self.savedata.playersBySteamID[steamID] = {}
            isFirstTimeJoining = true
        end
        local savedata = self.savedata.playersBySteamID[steamID] or {}

        -- make sure there's no double-connects happening, disconnect any existing players
        local existing = self.playersByPeerID[peerId]
        if existing then
            LB.players._onPlayerLeave(nil, self, existing.steamID, existing.displayName, existing.id, existing.isAdmin, existing.isAuth)
        end

        -- add new player
        log("player on", "player joined, awaiting load, peerID: " .. tostring(peerId))
        local player = LifeBoatAPI.Player:new(peerId, steamID, isAdmin, isAuth, name, savedata)

        self.playersByPeerID[player.id] = player
        self.playersBySteamID[player.steamID] = player
        self.players[#self.players+1] = player
 
        player:awaitLoaded():andImmediately(function (cr, deltaTicks, lastResult)
            log("player on", "player LOADED", player, "last result", lastResult)
            if isFirstTimeJoining and self.onPlayerFirstTimeConnected.hasListeners then
                self.onPlayerFirstTimeConnected:trigger(player)
            end
            
            if self.onPlayerConnected.hasListeners then
                self.onPlayerConnected:trigger(player)
            end
        end)
    end;

    ---@param self LifeBoatAPI.PlayerManager
    _onPlayerLeave = function (l, self, steamID, name, peerId, isAdmin, isAuth)
        log("player leaving", "peerID: " .. tostring(peerId))
        steamID = tostring(steamID)

        local player = self.playersByPeerID[peerId]
        self.playersByPeerID[peerId] = nil
        self.playersBySteamID[steamID] = nil

        if player.onDespawn.hasListeners then
            player.onDespawn:trigger(player)
        end

        -- remove from players list
        for i=1, #self.players do
            local connectedPlayer = self.players[i]
            if connectedPlayer.steamID == player.steamID then
                table.remove(self.players, i)
                break
            end
        end

        LifeBoatAPI.lb_dispose(player)
    end;
}