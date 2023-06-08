-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

LifeBoatAPI.DialogConfig = {
    Speed_Fast = 60,
    Speed_Default = 120,
    Speed_Slow = 240,
    showInChat = false,
    speed = 120,
    
    init = function(self)
        g_savedata.dialogConfig = g_savedata.dialogConfig or {
            showInChat = false,
            speedName = "default",
            speed = LifeBoatAPI.DialogConfig.Speed_Default
        }
        LifeBoatAPI.DialogConfig = g_savedata.dialogConfig
        LifeBoatAPI.DialogConfig.init = nil
        self = LifeBoatAPI.DialogConfig

        LB.events.onCustomCommand:register(function (l, context, fullMessage, peerID, isAdmin, isAuth, command, ...)
            --[[ allow players to set the dialog speed (global), solving this per-player is far too much performance cost for the benefit]]
            if command == "?lb_dialog_speed" then
                local args = {...}
                if args > 0 then
                    if not isAdmin then
                        server.announce(LB.addons.this.name, "command requires admin")
                        return
                    end

                    local asLower = args[1]:lower()
                    local asNumber = tonumber(args[1])
                    if asLower == "fast" then
                        self.speed = self.Speed_Fast
                    elseif asLower == "default" then
                        self.speed = self.Speed_Default
                    elseif asLower == "slow" then
                        self.speed = self.Speed_Slow
                    elseif asNumber then
                        self.speed = asNumber
                    else
                        server.announce(LB.addons.this.name, "bad argument, dialog speed unchanged ["..self.speedName.."], (try: default, fast, slow, or a number)", peerID)
                        return
                    end
                    server.announce(LB.addons.this.name, "dialog speed changed to: " .. self.speedName, peerID)
                    return
                else
                    server.announce(LB.addons.this.name, "dialog speed currently: " .. self.speedName, peerID)
                    return
                end
            -- [[ allow players to have dialog show in chat, this may increase accessibility options, such as screen/text readers ]]
            elseif command == "?lb_dialog_in_chat" then
               local args = {...}
               if args > 0 then
                   if not isAdmin then
                       server.announce(LB.addons.this.name, "command requires admin")
                       return
                   end

                   local asLower = args[1]:lower()
                   if asLower == "true" then
                       self.showInChat = true
                   elseif asLower == "false" then
                       self.showInChat = false
                   else
                       server.announce(LB.addons.this.name, "bad argument, (try: true or false)", peerID)
                       return
                   end
                   server.announce(LB.addons.this.name, "dialog is now " .. not self.showInChat and "no longer" or "" .. " shown in chat", peerID)
                   return
               else
                   server.announce(LB.addons.this.name, "dialog is currently " .. not self.showInChat and "not" or "" .. " shown in chat", peerID)
                   return
               end
            end
        end)
    end;
}

---@class LifeBoatAPI.DialogUtils
LifeBoatAPI.DialogUtils = {
    getDefaultDrawFunction = function(popup, dialogModel, displayLocally, npc)
        local popupRadius2 = popup.savedata.renderDistance * popup.savedata.renderDistance 
        return function(player, line)
            if LifeBoatAPI.DialogConfig.showInChat then
                if displayLocally then
                    -- if local, can assume the player must be able to see it from where they are
                    server.announce(dialogModel.name, line.textWithChoices, player.id)
                else
                    -- if not "local" then we only want to display within the same radius the popup shows
                    local players = LB.players.players
                    for i=1, #players do
                        local player = players[i]
                        local playerPos = player.transform
                        local npcPos = npc.transform

                        local dx,dy,dz = playerPos[13]-npcPos[13], playerPos[14]-npcPos[14], playerPos[15]-npcPos[15]
                        if (dx*dx + dy*dy + dz*dz) > popupRadius2 then
                            server.announce(dialogModel.name, line.textWithChoices, player.id)
                        end
                    end
                end
            end
            popup:edit(line.textWithChoices)
        end
    end;

    ---@param zone LifeBoatAPI.Zone
    ---@param dialogModel LifeBoatAPI.Dialog
    ---@param npc LifeBoatAPI.Object|LifeBoatAPI.Vehicle
    ---@param heightOffset number
    ---@param goodbyeLine string
    ---@param onDialogStarted fun(dialog:LifeBoatAPI.DialogInstance)
    ---@param onDialogComplete LifeBoatAPI.DialogOnCompleteHandler 
    ---@param displayLocally boolean|nil
    ---@param defaultResults table|nil
    ---@param popupRange number|nil
    ---@param useRelativePosPoup boolean|nil whether to use the more costly, "Relative" UIPopup that stays vertical, even if the object topples over
    ---@return LifeBoatAPI.IDisposable
    newSimpleZoneDialog = function(zone, dialogModel, npc, heightOffset, goodbyeLine, defaultResults, popupRange, displayLocally, useRelativePosPoup, onDialogStarted, onDialogComplete)
        popupRange = popupRange or 100
        heightOffset = heightOffset or 1

        local disposable = LifeBoatAPI.SimpleDisposable:new()

        local popup;
        local collision = zone.onCollision:register(function (l, context, zone, collision, collidingWith)
            -- check we're colliding with a *real* player and not just a crate we've given the "player" collision tag
            ---@cast collidingWith LifeBoatAPI.Player
            local player = collidingWith
            if not player.onChat then
                return
            end

            if popup and not popup.isDisposed then
                -- we're already displaying this to another player
                return;
            end
            
            if useRelativePosPoup then
                popup = LifeBoatAPI.UIPopupRelativePos:new(displayLocally and player or nil, "", LifeBoatAPI.Matrix:newMatrix(0, heightOffset, 0), nil, popupRange, npc, true)
            else
                popup = LifeBoatAPI.UIPopup:new(displayLocally and player or nil, "", 0, heightOffset, 0, popupRange, npc, true)
            end
    
            -- optional "show in chat" dialog behaviour
            local dialog = dialogModel:start(LifeBoatAPI.DialogUtils.getDefaultDrawFunction(popup, dialogModel, displayLocally, zone), player, defaultResults)
            collision:attach(dialog)
    
            -- additional start points for the dialog, to make it more interesting
            if onDialogStarted then
                onDialogStarted(dialog)
            end

            dialog.onComplete:register(onDialogComplete)

            -- when you walk away, add a nice little goodbye message when you leave that destroys itself after 2 seconds (120 ticks)
            collision.onCollisionEnd:register(function (l, context, collision)
                -- be polite if exiting mid conversation
                if dialog and not dialog.isDisposed then
                    popup:edit(goodbyeLine)
                    LifeBoatAPI.CoroutineUtils.disposeAfterDelay(popup, 120)
                else
                    LifeBoatAPI.lb_dispose(popup)
                end
                popup = nil
                
            end)
        end)

        disposable:attach(collision)
        
        return disposable
    end;
}