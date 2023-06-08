-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

LifeBoatAPI = LifeBoatAPI or {}

-- type data only
require("LifeBoatAPI.Util.Utils")

require("LifeBoatAPI.Util.Bitwise")
require("LifeBoatAPI.Util.Constants")
require("LifeBoatAPI.Util.CoroutineUtils")
require("LifeBoatAPI.Util.Disposable")


require("LifeBoatAPI.Maths.Colliders")
require("LifeBoatAPI.Maths.Matrix")
require("LifeBoatAPI.Maths.RollingAverage")
require("LifeBoatAPI.Maths.Vector")

require("LifeBoatAPI.Core.Objects.Fire")
require("LifeBoatAPI.Core.Objects.GameObject")
require("LifeBoatAPI.Core.Objects.Object")
require("LifeBoatAPI.Core.Objects.Player")
require("LifeBoatAPI.Core.Objects.Vehicle")
require("LifeBoatAPI.Core.Objects.Zone")
require("LifeBoatAPI.Core.Objects.ObjectCollection")


require("LifeBoatAPI.Core.UIObjects.UIElement")
require("LifeBoatAPI.Core.UIObjects.UIMapLabel")
require("LifeBoatAPI.Core.UIObjects.UIMapObject")
require("LifeBoatAPI.Core.UIObjects.UIPopup")
require("LifeBoatAPI.Core.UIObjects.UIScreenPopup")
require("LifeBoatAPI.Core.UIObjects.UIMapCollection")
require("LifeBoatAPI.Core.UIObjects.UIPopupRelativePos")

require("LifeBoatAPI.Core.AddonManager")
require("LifeBoatAPI.Core.CollisionManager")
require("LifeBoatAPI.Core.Coroutine")
require("LifeBoatAPI.Core.Event")
require("LifeBoatAPI.Core.EventManager")
require("LifeBoatAPI.Core.ObjectManager")
require("LifeBoatAPI.Core.PlayerManager")
require("LifeBoatAPI.Core.TickManager")
require("LifeBoatAPI.Core.UIManager")

require("LifeBoatAPI.Missions.Mission")
require("LifeBoatAPI.Missions.Dialog")
require("LifeBoatAPI.Missions.DialogUtils")

-- instantiates live data
require("LifeBoatAPI.Core.LB")

-- fake addon api, to allow quick testing
require("LifeBoatAPI.AddonSimulator")