-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


---@class LifeBoatAPI.DialogChoice
---@field phrase string
---@field next string
---@field customHandler fun(self:LifeBoatAPI.DialogChoice, player: LifeBoatAPI.Player, message: string) : boolean
---@field result table|nil same as the main result for the line, only triggered on that choice

---@class LifeBoatAPI.DialogLine
---@field text string
---@field id string|nil
---@field choices LifeBoatAPI.DialogChoice[]|nil
---@field conditionals table key values that must exist in results table for this line to run
---@field textWithChoices string
---@field showChoices boolean|nil
---@field result table|nil
---@field speed number|nil
---@field next string|nil
---@field terminate boolean|nil

---@class LifeBoatAPI.Dialog
---@field speakerName string
---@field defaultSpeed number
---@field tickFrequency number
---@field lines LifeBoatAPI.DialogLine[]
---@field lineIndexesByID table<string, number>
---@field hasChoices boolean (internal)
---@field isProcessed boolean (internal)
LifeBoatAPI.Dialog = {

    ---@param cls LifeBoatAPI.Dialog
    ---@param lines LifeBoatAPI.DialogLine[]|nil
    ---@param defaultSpeed number|nil
    ---@param tickFrequency number|nil
    ---@return LifeBoatAPI.Dialog
    new = function(cls, lines, defaultSpeed, tickFrequency)
        local self = {
            defaultSpeed = defaultSpeed or 1,
            tickFrequency = tickFrequency,
            lines = {},
            lineIndexesByID = {},
            isProcessed = false,
            hasChoices = true,

            ---methods
            start = cls.start,
            addLine = cls.addLine,
        }

        -- add initial lines
        if lines then
            for i=1, #lines do
                self:addLine(lines[i])
            end
        end

        return self
    end;

    --- can just directly add to self.lines
    ---@param self LifeBoatAPI.Dialog
    ---@param line LifeBoatAPI.DialogLine
    addLine = function(self, line)
        self.lines[#self.lines+1] = line

        if line.choices then
            self.hasChoices = true

            local textParts = {line.text or "", "\n\n"}
            for i=1, #line.choices do -- cheaper than string.format
                textParts[#textParts+1] = "["
                textParts[#textParts+1] = line.choices[i].phrase
                textParts[#textParts+1] = "] "
            end

            line.textWithChoices = table.concat(textParts)
        else
            line.textWithChoices = line.text or ""
        end

        if line.id then
            self.lineIndexesByID[line.id] = #self.lines
        end 
    end;

    ---@param self LifeBoatAPI.Dialog
    ---@param popupOrDrawFunc LifeBoatAPI.UIPopup|LifeBoatAPI.UIPopupRelativePos|fun(player, line)
    ---@param player LifeBoatAPI.Player
    ---@param resultsDefault table|nil
    ---@return LifeBoatAPI.DialogInstance
    start = function(self, popupOrDrawFunc, player, resultsDefault)
        return LifeBoatAPI.DialogInstance:new(self, popupOrDrawFunc, player, resultsDefault)
    end;
}

---@alias LifeBoatAPI.DialogOnCompleteHandler fun(l:LifeBoatAPI.IEventListener, context:any, dialog:LifeBoatAPI.DialogInstance, results:table, player: LifeBoatAPI.Player)

---@class EventTypes.LBDialogOnComplete : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.ENVCallbackEvent, func:LifeBoatAPI.DialogOnCompleteHandler, context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class LifeBoatAPI.DialogInstance : LifeBoatAPI.IDisposable
---@field results table
---@field dialog LifeBoatAPI.Dialog
---@field player LifeBoatAPI.Player
---@field onComplete EventTypes.LBDialogOnComplete
---@field drawText fun(player: LifeBoatAPI.Player, line: LifeBoatAPI.DialogLine)
LifeBoatAPI.DialogInstance = {

    ---@param cls LifeBoatAPI.DialogInstance
    ---@param dialog LifeBoatAPI.Dialog
    ---@param player LifeBoatAPI.Player
    ---@param resultsDefault tabel|nil
    new = function(cls, dialog, popupOrDrawFunc, player, resultsDefault)

        -- begin the dialog
        local self = {
            disposables = {};
            results = resultsDefault or {};
            dialog = dialog;
            player = player;
            lineIndex = 0;
            line = {text="", textWithChoices=""};
            onComplete = LifeBoatAPI.Event:new();

            -- methods
            attach = LifeBoatAPI.lb_attachDisposable;
            gotoNextLine = cls.gotoNextLine;
            onDispose = cls.onDispose;
        }

        -- create the draw function to use
        ---@cast popupOrDrawFunc fun(player : LifeBoatAPI.Player, line:DialogLine)
        self.drawText = popupOrDrawFunc
        if type(popupOrDrawFunc) == "table" then
            ---@cast popupOrDrawFunc LifeBoatAPI.UIPopup|LifeBoatAPI.UIPopupRelativePos
            self.drawText = function(player, line)
                popupOrDrawFunc:edit(line.textWithChoices)
            end
        end

        player:attach(self)

        if self.isDisposed then
            return self
        end

        -- initial line timeout
        local lineSpeed = (self.line.speed or (not self.line.choices and self.dialog.defaultSpeed)) or nil
        if lineSpeed then
            self.lineTimeout = LB.ticks.ticks + (LifeBoatAPI.DialogConfig.speed * lineSpeed)
        else
            self.lineTimeout = nil
        end
        self:gotoNextLine()


        -- run the main thread for the dialog
        self.disposables[#self.disposables+1] = LB.ticks:register(function (listener, context, deltaTicks)
            if self.lineTimeout then
                if self.lineTimeout < LB.ticks.ticks then
                    self:gotoNextLine()
                end
            end
        end, nil, self.tickFrequency or 30)

        -- setup listener for player replies, if we've got choices to make in this dialogue tree
        if dialog.hasChoices then
            self.disposables[#self.disposables+1] = player.onChat:register(function (l, context, player, message)
                local messageAsLower = message and message:lower() or ""
                local line = self.line
                if line.choices then
                    for i=1, #line.choices do
                        local choice = line.choices[i]
                        if choice.customHandler then
                            if choice:customHandler(player, messageAsLower) then
                                self:gotoNextLine(choice.next, choice.result)
                                return;
                            end
                        elseif messageAsLower:find(choice.phrase, 0, true) then
                            self:gotoNextLine(choice.next, choice.result)
                            return
                        end
                    end
                end
            end)
        end

        return self
    end;

    ---@param self LifeBoatAPI.DialogInstance
    ---@param choiceResults table|nil possible results from the specific choice selected
    ---@param nextLineNameParam string|nil
    gotoNextLine = function(self, nextLineNameParam, choiceResults)
        -- add result from current line
        if self.line.result then
            for k,v in pairs(self.line.result) do
                self.results[k] = v
            end
        end

        if choiceResults then
            for k,v in pairs(choiceResults) do
                self.results[k] = v
            end
        end

        local skipToNext = false;
        while true do
            -- find the next line
            local nextLineName = nextLineNameParam or self.line.next
            log("next line name", nextLineName, "skip to next", skipToNext)
            self.lineIndex = (skipToNext and self.lineIndex + 1) or (nextLineName and self.dialog.lineIndexesByID[nextLineName]) or (self.lineIndex + 1)
            local nextLine = self.dialog.lines[self.lineIndex]
            skipToNext = false

            -- current line said to terminate, or next line doesn't exist
            if self.line.terminate ~= nil or not nextLine then
                -- terminate
                self.drawText(self.player, {text="", textWithChoices=""}) -- hide popup
                LifeBoatAPI.lb_dispose(self)
                break
            else
                -- move to the next line
                self.line = nextLine
                local lineSpeed = self.line.speed or (not self.line.choices and self.dialog.defaultSpeed) or nil -- if specified, otherwise default unless it's a choice
                if lineSpeed then
                    self.lineTimeout = LB.ticks.ticks + (lineSpeed * LifeBoatAPI.DialogConfig.speed)
                else
                    self.lineTimeout = nil
                end

                -- check if this next line is conditionally allowed
                if self.line.conditionals then
                    log("conditionals found")
                    for k,v in pairs(self.line.conditionals) do
                        log("key", k, "value", v, "matching result", self.results[k])
                        if self.results[k] ~= v then
                            log("skipping to subsequent")
                            skipToNext = true
                            break
                        end
                    end
                end

                if not skipToNext then
                    -- specifying negative timeouts will mean we instantly skip over the line; but *next* will be respected; unlike missing conditionals above
                    if not self.lineTimeout or (self.lineTimeout >= LB.ticks.ticks) then
                        self.drawText(self.player, self.line)
                        break
                    else
                        log("skipping to actual next")
                    end
                end
                -- else: repeat the search till we find a valid line
            end
        end
    end;

    onDispose = function(self)
        if self.onComplete.hasListeners then
            self.onComplete:trigger(self, self.results, self.player)
        end
    end;
}