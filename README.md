# ***Aurora Framework***

### **Overview**
Aurora Framework is a super reliable framework that makes the creation of Stormworks: Build and Rescue (game) addons much easier.

This framework also makes most things OOP-based, meaning instead of doing:

```lua
function onReady()
    local vehicle_id = 1
    local pos = server.getVehiclePos(vehicle_id)
end
```

You can do:

```lua
AuroraFramework.ready:connect(function()
    local vehicle_id = 1
    local vehicle = AuroraFramework.services.vehicleService.getVehicleByVehicleID(vehicle_id)
    local pos = vehicle:getPosition()
end)
```

You can view examples over in the `examples` folder.

### **Features**
- **Services** - This framework contains numerous functions/"classes" for different things that are categorized depending on what they do. These functions/"classes" go under services.
- **OOP-Based** - This framework is entirely OOP-based. To apply something to a player, or a vehicle, you must find the player/vehicle object and call a method inside of the object.
- **Reliable** - This framework is consistently maintained and works extremely well.
- **Intellisense Support** - This framework utilizes [Lua LSP's](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) annotations feature to provide full intellisense (auto-completion, etc) support. Please note that you'll need to have the [Lua LSP extension](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) and the [Stormworks Lua extension](https://marketplace.visualstudio.com/items?itemName=NameousChangey.lifeboatapi) for intellisense.
- **Less Work** - This framework handles so much of the tough stuff for you. You won't need to create tables to track players, vehicles, and such. There are also plenty of helper functions in the framework's libraries that you can utilize.
- **Libraries** - This framework has numerous libraries that contain functions you might need during addon development. This speeds up development time as you won't need to create as many functions single-handedly.

### **Installation**
Before doing anything, place `src/framework` into your addon's folder.

After doing so, place `src/gameIntellisense.lua` into your addon's folder for Addon Lua intellisense support. This is not needed, but it will provide auto-completion for all of the game's functions and such.

Your addon's folder should now look like:

![Example](imgs/addon_folder_example.png)

Now, for actually using the framework, you can either:
- Take the  `require()` route:
    1) Install the [Stormworks Lua Visual Studio Code extension](https://marketplace.visualstudio.com/items?itemName=NameousChangey.lifeboatapi).
    2) Use the extension's `require("path.to.file")` support feature with your addon's framework file.
        ```lua
        -- file: script.lua
        -- merges everything in framework/AuroraFramework.lua with your script.lua file once you build your addon using the extension
        require("framework.AuroraFramework")

        -- use the framework like so:
        AuroraFramework.services.chatService.sendMessage("Server", "Hey all!")
        ```
    3) Build your addon using the `F7` key. You'll have to do this everytime you make a change to your addon.

- Take the all-in-one route:
    1) Copy the contents of your addon's `framework/AuroraFramework.lua`.
    2) Paste it into your addon's `script.lua` file. Be sure to paste it above all of your addon code, not below it.
        ```lua
        -- file: script.lua
        -- the entirety of the framework
        AuroraFramework = {...} -- it won't look *exactly* like this

        -- your addon code
        AuroraFramework.services.chatService.sendMessage("Server", "Hey all!")
        ```

Be sure to keep `framework/intellisense.lua` in your addon's workspace for intellisense support.

### **Warnings**
- This framework gets updated quite frequently, so you may need to repeat the installation steps above there and then.
- This framework contains little descriptive documentation because this was made purely for myself originally. The framework does utilize typehinting and basic function annotations though.