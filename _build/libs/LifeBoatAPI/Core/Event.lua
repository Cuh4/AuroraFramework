---@class LifeBoatAPI.IEventListener : LifeBoatAPI.IDisposable
---@field onExecute fun(l:IEventListener, ctx:any, ...)
---@field executeCount number          number of times for this listener to be called, or -1 for indefinitely
---@field context any

---@class LifeBoatAPI.Event
---@field listeners LifeBoatAPI.IEventListener[]
---@field hasListeners boolean
LifeBoatAPI.Event = {
	---@param cls LifeBoatAPI.Event
	---@return LifeBoatAPI.Event
    new = function (cls)
        return {
            --fields
            listeners = {};
			hasListeners = false;

            --methods
			await = cls.await;
			awaitIf = cls.awaitIf;
            register = cls.register;
            trigger = cls.trigger;
        }
    end;

    ---@param self LifeBoatAPI.Event
    ---@param func fun(l:IEventListener, ctx:any, ...)
    ---@param timesToExecute number|nil
	---@return LifeBoatAPI.IEventListener
    register = function (self, func, context, timesToExecute)
        local listener = {
            onExecute = func,
            executeCount = timesToExecute or -1,
			context = context
        }
        self.listeners[#self.listeners + 1] = listener
		self.hasListeners = true
        return listener
    end;

	---@param self LifeBoatAPI.Event
	---@return LifeBoatAPI.Coroutine
	await = function(self)
		local cr = LifeBoatAPI.Coroutine:start(nil, true)

		self:register(function(l, ctx, ...)
			l.isDisposed = true
			cr.lastResult = {...}
			cr:trigger()
		end, nil, 1)

		return cr
	end;

	---@param self LifeBoatAPI.Event
	---@param predicate fun(l:LifeBoatAPI.IEventListener, context:any, ...:any):boolean predicate that returns true, if the condition is met - e.g. "if peerID == <something>". May be performance heavy if overused.
	---@return LifeBoatAPI.Coroutine
	awaitIf = function(self, predicate)
		local cr = LifeBoatAPI.Coroutine:start(nil, true)

		self:register(function(l, ctx, ...)
			if predicate(l, ctx, ...) then
				l.isDisposed = true
				cr.lastResult = {...}
				cr:trigger()
			end
		end)

		return cr
	end;

    ---@param self LifeBoatAPI.Event
    trigger = function (self, ...)
        local newListeners = {}
        for i = 1, #self.listeners do
            local listener = self.listeners[i]

            -- check against ~=0 so that a listener set to -1 will stay registered forever
            if not listener.isDisposed and listener.executeCount ~= 0 then
                listener.executeCount = listener.executeCount - 1
                listener:onExecute(listener.context, ...)
            end
            
            -- add listener to list that remains for the next trigger event
            if not listener.isDisposed and listener.executeCount ~= 0 then
                newListeners[#newListeners+1] = listener
            end
        end
        self.listeners = newListeners
		self.hasListeners = #self.listeners > 0
    end;
}


---Event specialization for handling the global callbacks
---Automatically deregisters itself when there are no listeners
---@class LifeBoatAPI.ENVCallbackEvent : LifeBoatAPI.Event
---@field callbackName string
---@field onExecute function actual executed code when the event is fired
---@field transformFunc function optional transform functions, turns e.g. game_callback(a,b,c) => callback(player, vehicle)
---@field originalExecute function original callback that we're overwriting in case somebody wants to still use e.g. onPlayerSit directly too
LifeBoatAPI.ENVCallbackEvent = {
	---@param cls LifeBoatAPI.ENVCallbackEvent
	---@param callbackName string
	---@param transformFunc function|nil optional function to transform the arguments
	---@return LifeBoatAPI.ENVCallbackEvent
	new = function(cls, callbackName, transformFunc)
		local self = {
			--fields
			callbackName = callbackName;
			listeners = {};
			hasListeners = false;
			transformFunc = transformFunc;

			--methods
			init = cls.init;
			await = LifeBoatAPI.Event.await;
			awaitIf = LifeBoatAPI.Event.awaitIf;
			register = cls.register;
			trigger = LifeBoatAPI.Event.trigger;
		}

		self.onExecute = cls._onExecuteClosure(self)

		return self
	end;

	---@param self LifeBoatAPI.ENVCallbackEvent
	init = function(self)
		if self.hasListeners and self.onExecute ~= _ENV[self.callbackName] then
			self.originalExecute = _ENV[self.callbackName]
			_ENV[self.callbackName] = self.onExecute
		end
	end;

	---@param self LifeBoatAPI.ENVCallbackEvent
	_onExecuteClosure = function (self)
		return function(...)
			local newListeners = {}
			for i = 1, #self.listeners do
				local listener = self.listeners[i]

				-- check against ~=0 so that a listener set to -1 will stay registered forever
				if not listener.isDisposed and listener.executeCount ~= 0 then
					listener.executeCount = listener.executeCount - 1

					if self.transformFunc then
						listener:onExecute(listener.context, self.transformFunc(...))
					else
						listener:onExecute(listener.context, ...)
					end
					
					if self.originalExecute then
						self.originalExecute(...)
					end
				end
				
				-- add listener to list that remains for the next trigger event
				if not listener.isDisposed and listener.executeCount ~= 0 then
					newListeners[#newListeners+1] = listener
				end
			end
			
        	self.listeners = newListeners
			self.hasListeners = #self.listeners > 0

			if not self.hasListeners then
				_ENV[self.callbackName] = self.originalExecute;
				self.originalExecute = nil
			end			
		end
	end;

	---@param self LifeBoatAPI.ENVCallbackEvent
	---@param func fun(listener:LifeBoatAPI.IEventListener, context:any, ...)
	---@param context any
	---@param timesToExecute number|nil infinite if not provided, otherwise limits the executions to given number of times (e.g. "run this once")
	---@return LifeBoatAPI.IEventListener
	register = function(self, func, context, timesToExecute)
		-- if something starts listening for the 
		if not self.hasListeners and self.onExecute ~= _ENV[self.callbackName] then
			self.originalExecute = _ENV[self.callbackName]
			_ENV[self.callbackName] = self.onExecute
		end

		local listener = {
            onExecute = func,
            executeCount = timesToExecute or -1,
			context = context
        }
        self.listeners[#self.listeners + 1] = listener
		self.hasListeners = true
        return listener
	end;
}