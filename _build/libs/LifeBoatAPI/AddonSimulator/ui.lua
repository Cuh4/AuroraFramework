-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


---@section ---@section ___REMOVE_THIS__ADDON_SIMULATOR_UI_LUA

--- Messages player(s) using the in-game chat
--- @param name string The display name of the user sending the message
--- @param message string The message to send the player(s)
--- @param peerID number|nil The peerID of the player you want to message. -1 messages all players. If ignored, it will message all players
function server.announce(name, message, peerID) end

--- Displays a notification for player(s) on the right side of the screen.
--- @param peerID number The peerID of the player you want to message. -1 messages all players
--- @param title string The title of the notification
--- @param message string The message you want to send the player(s)
--- @param notificationType SWNotifiationTypeEnum number, Changes how the notification looks. Refer to notificationTypes
function server.notify(peerID, title, message, notificationType) end

--- Gets a unique ID to be used with other UI functions. Functions similar to a vehicle ID. A UI id can be used for multiple lines and map objects but each popup with a different text or position must have it's own ID
--- @return number ui_ID
function server.getMapID()
    __mapid = __mapid or 0
    __mapid = __mapid + 1
    return __mapid
end

--- Remove any UI type created with this ui_id. If you have drawn multiple lines on the map with one UI id, this command would remove all of them.
--- @param peer_id number The peer id of the affected player. -1 affects all players
--- @param ui_id number The unique ui id to be removed
function server.removeMapID(peer_id, ui_id) end

--- Add a map marker for the specified peer(s). x, z represent the worldspace location of the marker, since the map is 2D a y coordinate is not required. If POSITION_TYPE is set to 1 or 2 (vehicle or object) then the marker will track the object/vehicle of object_id/vehicle_id and offset the position by parent_local_x, parent_local_z. 
--- @param peer_id number The peer id of the affected player. -1 affects all players
--- @param ui_id number The unique ui id to use
--- @param position_type SWPositionTypeEnum number, Defines what type (object/vehicle) the marker should follow. Or if it should not follow anything. If the vehicle/object that object is set to follow cannot be found, this defaults to 0 meaning it becomes static, when the vehicle/object is reloacated, it reverts back to the previous value.
--- @param marker_type SWMarkerTypeEnum number
--- @param x number Refer to World Space. Overrides parent_local_x
--- @param z number Refer to World Space. Overrrides parent_local_z 
--- @param parent_local_x number The x offset relative to the parent. Refer to World Space
--- @param parent_local_z number The y offset relative to the parent. Refer to World Space
--- @param vehicle_id number The vehicle to follow if POSITION_TYPE is set to 1. Set to 0 to ignore
--- @param object_id number The object to follow if POSITION_TYPE is set to 2. Set to 0 to ignore
--- @param label string The text that appears when mousing over the icon. Appears like a title
--- @param radius number The radius of the red dashed circle. Only applies if MARKER_TYPE = 8
--- @param hover_label string The text that appears when mousing over the icon. Appears like a subtitle or description
function server.addMapObject(peer_id, ui_id, position_type, marker_type, x, z, parent_local_x, parent_local_z, vehicle_id, object_id, label, radius, hover_label) end

--- 
--- @param peer_id number The peer id of the affected player. -1 affects all players
--- @param ui_id number The unique ui id to use
function server.removeMapObject(peer_id, ui_id) end

--- 
--- @param peer_id number The peer id of the affected player. -1 affects all players
--- @param ui_id number The unique ui id to use
--- @param LABEL_TYPE SWLabelTypeEnum number
--- @param name string The text that appears on the label
--- @param x number Refer to World Space
--- @param z number Refer to World Space
function server.addMapLabel(peer_id, ui_id, LABEL_TYPE, name, x, z) end

--- 
--- @param peer_id number The peer id of the affected player. -1 affects all players
--- @param ui_id number The ui id to use
function server.removeMapLabel(peer_id, ui_id) end

--- 
--- @param peer_id number The peer id of the affected player. -1 affects all players
--- @param ui_id number The ui id to use
--- @param start_matrix SWMatrix Line start position. worldspace
--- @param end_matrix SWMatrix Line stop position
--- @param width number Line width
function server.addMapLine(peer_id, ui_id, start_matrix, end_matrix, width) end

--- 
--- @param peer_id number The peer id of the affected player
--- @param ui_id number The ui id to use
function server.removeMapLine(peer_id, ui_id) end

--- Displays a tooltip-like popup either in the world. If the popup does not exist, it will be created.
--- @param peer_id number The peer id of the affected player. -1 affects all players
--- @param ui_id number A unique ui_id to be used with this popup. You cannot re-use ui ids for popups, unless they have the same text and position, then they can be used for multiple players.
--- @param name string ? Appears to do nothing. Can be left as an empty string: ""
--- @param is_show boolean If the popup is currently being shown
--- @param text string The text inside the popup. You can fit 13 characters in a line before it will wrap.
--- @param x number X position of the popup. worldspace
--- @param y number Y position of the popup. worldspace
--- @param z number Z position of the popup. worldspace
--- @param render_distance number The distance the popup will be viewable from in meters
--- @param vehicle_parent_id number The vehicle to attach the popup to
--- @param object_parent_id number The object to attach the popup to
function server.setPopup(peer_id, ui_id, name, is_show, text, x, y, z, render_distance, vehicle_parent_id, object_parent_id) end

--- Creates a popup that appears on the player's screen, regardless of their look direction and location in the world.
--- @param peer_id number The peer id of the affected player. -1 affects all players
--- @param ui_id number A unique ui_id to be used with this popup. You cannot re-use ui ids for popups. One ui id per popup.
--- @param name string ?
--- @param is_show boolean If the popup is currently being shown
--- @param text string The text inside the popup. You can fit 13 characters in a line before it will wrap.
--- @param horizontal_offset number The offset on the horizontal axis. Ranges from -1 (left) to 1 (right)
--- @param vertical_offset number The offset on the vertical axis. Ranges from -1 (Bottom) to 1(Top)
function server.setPopupScreen(peer_id, ui_id, name, is_show, text, horizontal_offset, vertical_offset) end

--- Will remove popups that have been assigned to a player
--- @param peer_id number The peer id of the affected player. -1 affects all players
--- @param ui_id number The unique ui id to use
function server.removePopup(peer_id, ui_id) end

---@endsection