# ***Aurora Framework***
### **Overview**
Aurora Framework is a super reliable framework that makes the creation of Stormworks: Build and Rescue (game) addons much easier.

This framework also makes most things OOP-based, meaning instead of doing:

```lua
local vehicle_id = 1
local pos = server.getVehiclePos(vehicle_id)
```

You can do:

```lua
local vehicle_id = 1
local vehicle = AuroraFramework.services.vehicleService.getVehicleByVehicleID(vehicle_id)
local pos = vehicle:getPosition()
```

### **Features**
- **Services** - This framework contains numerous functions/"classes" for different things that are categorized depending on what they do. These functions/"classes" go under services.
- **OOP-Based** - This framework is entirely OOP-based. To apply something to a player, or a vehicle, you must find the player/vehicle object and call a method inside of the object.
- **Reliable** - This framework is consistently maintained and works extremely well.
- **Intellisense Support** - This framework utilizes [Lua LSP's](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) annotations feature to provide full intellisense (auto-completion, etc) support. Please note that you'll need to have the [Lua LSP extension](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) and the [Stormworks Lua extension](https://marketplace.visualstudio.com/items?itemName=NameousChangey.lifeboatapi) for intellisense.

### **Installation**
To use this framework within your addon, you can either:
- 1) Use [Stormworks Lua extension](https://marketplace.visualstudio.com/items?itemName=NameousChangey.lifeboatapi)'s `require("path.to.file")` feature, and simply require `p0_framework/AuroraFramework.lua`. Be sure to place `p0_framework/intellisense.lua` into your addon's workspace for intellisense support.
- 2) Place `p0_framework/AuroraFramework.lua` into your addon's `script.lua` file to use the framework, and place `p0_framework/intellisense.lua` into your addon's workspace for intellisense support.

### **Examples**
These examples may help you understand how to use the framework, and how it works. Note that all of these examples are made by me, and some are publicly available in Stormworks: Build and Rescue's Steam workshop.
- [**All Creatures Hate You**](https://github.com/Cuh4/AllCreaturesHateYou)
- [**No More Oil Spills**](https://github.com/Cuh4/NoMoreOilSpills)
- [**Nextbot Addon**](https://github.com/Cuh4/NextbotAddon)
- [**Proximity Text Chat**](https://github.com/Cuh4/ProximityTextChat)

### **Warnings**
- **This framework contains little to no documentation because this was made purely for myself. There are function parameter and return annotations throughout the framework file though.**