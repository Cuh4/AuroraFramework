![SW Screenshot](imgs/readme_top.png)

---

# *Aurora Framework*


## 📚 | Overview
Aurora Framework is a super reliable OOP-based framework that makes the creation of Stormworks: Build and Rescue (game) addons much easier.

As said, the framework makes creating addons easier, here's an example of that:

```lua
-- Without Aurora Framework
local timer = 0

function onTick()
    timer = timer + 1

    if timer % 60 ~= 0 then
        return
    end

    server.announce("Woah", "A second has passed.")
end
```

```lua
-- With Aurora Framework
AuroraFramework.services.timerService.loop.create(1, function()
    AuroraFramework.services.chatService.sendMessage("Woah", "A second has passed.")
end)
```

You can view examples over in the `examples` folder.

## 😔 | Quirks
- Creating UI in the Player Service onJoin event when UI with the same name in g_savedata is about to get instantiated from the UI Service will cause the original UI to get overwritten. I can't think of a way to fix this. This happens because the Player Service is initialized before the UI Service. If this happened the other way around, the UI Service would break when loading UI parented to players from g_savedata. To get around this, you could create UI the next tick after the onJoin event by utilizing a delay.

## 📃 | Features
- **Services** - This framework contains numerous functions/"classes" for different things that are categorized depending on what they do. These functions/"classes" go under services.
- **OOP-Based** - This framework is entirely OOP-based. To apply something to a player, or a vehicle, you must find the player/vehicle object and call a method inside of the object.
- **Reliable** - This framework is consistently maintained and works extremely well.
- **Intellisense Support** - This framework utilizes [Lua LSP's](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) annotations feature to provide full intellisense (auto-completion, etc) support. Please note that you'll need to have the [Lua LSP extension](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) and the [Stormworks Lua extension](https://marketplace.visualstudio.com/items?itemName=NameousChangey.lifeboatapi) for intellisense.
- **Less Work** - This framework handles so much of the tough stuff for you. You won't need to create tables to track players, vehicles, and such. There are also plenty of helper functions in the framework's libraries that you can utilize.
- **Libraries** - This framework has numerous libraries that contain functions you might need during addon development. This speeds up development time as you won't need to create as many functions single-handedly.

## 💾 | Installation
Stormworks addons are located at `%appdata%/Stormworks/data/missions`.

### 💽 | Installation
1) `git clone` this repo into your addon's folder: `git clone "https://github.com/Cuh4/AuroraFramework"`
2) Move `src/framework` into your addon's folder. This will provide the framework itself (`AuroraFramework.lua`), as well as intellisense for the framework (`intellisense.lua`).
3) **[Optional]** Move `docs/intellisense.lua` from [this repo](https://github.com/Cuh4/StormworksAddonLuaDocumentation) into your addon's folder. This will provide intellisense (auto-completion, etc) for Addon Lua.

Your addon's folder should now look like:

![Example](imgs/addon_folder_example.png)

Note that `intellisense.lua` from the repo mentioned above was renamed to `gameIntellisense.lua`.

### 📖 | Utilizing Aurora Framework
Now, for actually using the framework, you can either:

- **Take the `require()` route:**
    1) Install the [Stormworks Lua Visual Studio Code extension](https://marketplace.visualstudio.com/items?itemName=NameousChangey.lifeboatapi).
    2) Use the extension's `require("path.to.file")` support feature with your addon's framework file.
        ```lua
        -- file: script.lua
        -- merges everything in framework/AuroraFramework.lua with your script.lua file once you build your addon using the extension
        require("framework.AuroraFramework")

        -- your addon code
        AuroraFramework.services.chatService.sendMessage("Server", "Hey all!")
        ```
    3) Build your addon using the extension. You'll have to do this everytime you make a change to your addon.

- **Take the all-in-one route:**
    1) Copy the contents of your addon's `framework/AuroraFramework.lua`.
    2) Paste it into your addon's `script.lua` file. Be sure to paste it above all of your addon code, not below it.
        ```lua
        -- file: script.lua
        -- the entirety of the framework
        AuroraFramework = {...} -- it won't look *exactly* like this

        -- your addon code
        AuroraFramework.services.chatService.sendMessage("Server", "Hey all!")
        ```

    - **Note:** You can create your own script to automatically combine the framework with your addon's `script.lua`. This is what I personally do.

## ⚠️ | Warnings
- This framework gets updated quite frequently, so you may need to repeat the installation steps above there and then.
- This framework doesn't include actual documentation because this was made purely for myself originally. The framework does utilize typehinting and basic function annotations for intellisense support though.