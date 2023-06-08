-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@section ___REMOVE_THIS__ADDON_SIMULATOR_INIT_LUA 1 ___REMOVE_THIS__ADDON_SIMULATOR_INIT_LUA_SECTION
server = {}
g_savedata = {}
matrix = {}
debug = {}
http = {}
property = {}

require("LifeBoatAPI.AddonSimulator.addon")
require("LifeBoatAPI.AddonSimulator.ai")
require("LifeBoatAPI.AddonSimulator.game")
require("LifeBoatAPI.AddonSimulator.misc")
require("LifeBoatAPI.AddonSimulator.objects")
require("LifeBoatAPI.AddonSimulator.ui")
require("LifeBoatAPI.AddonSimulator.vehicle")

---@endsection ___REMOVE_THIS__ADDON_SIMULATOR_INIT_LUA_SECTION