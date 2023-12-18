------------------------------------------------------------------------------------------------------------------------
    -- Aurora Framework | A reliable addon creation framework designed to make addon creation easier.
	-- 		Created by @cuh6_ on Discord
	--		My Discord: https://discord.gg/CymKaDE2pj
------------------------------------------------------------------------------------------------------------------------

----------------------------------------
-- [Example] Debugging
-- This example shows how you implement debugging in your code with the help of this framework
----------------------------------------

-- Create a logger
local myLogger = AuroraFramework.services.debuggerService.createLogger("Main Logger", false) -- Name of logger, and whether or not it should send in chat

-- Send random messages
myLogger:send("Hello world!")

myLogger:send({
    "you",
    "can",
    "even",
    "send",
    "messages",
    "that",
    "aren't",
    "strings",
    {"neat", "right?"}
})

-- Create a function, and attach debug code to it
function hello() -- It is important that your function is a *non-local* function, otherwise the framework won't be able to find it through _ENV and it simply won't be able to attach debug code to your function
    return "hello"
end

AuroraFramework.services.debuggerService.attach(hello, myLogger) -- Attaches debug code

-- Now, if we call the "hello" function, we'll get a message in Debug View (google "SysInternals DebugView") or in chat depending on logger settings
hello()

-- If we was to check chat/debug view, we would see:
-- _ENV.hello() was called. | Usage Count: 1 | Took: 0 ms, AVG: 0.0 ms | Returned: hello

-- And if we called it again,
hello()

-- We would see:
-- _ENV.hello() was called. | Usage Count: 2 | Took: 0 ms, AVG: 0.0 ms | Returned: hello

-- You can also attach debug code to multiple functions:
functions = {
    hello = hello,
    world = function()
        return "world"
    end
}

AuroraFramework.services.debuggerService.attachMultiple(functions, myLogger)

-- And if we ran them,
functions.hello()
functions.world()

-- We would see:
-- _ENV.functions.hello() was called. | Usage Count: 1 | Took: 0 ms, AVG: 0.0 ms | Returned: hello
-- _ENV.functions.world() was called. | Usage Count: 1 | Took: 0 ms, AVG: 0.0 ms | Returned: world