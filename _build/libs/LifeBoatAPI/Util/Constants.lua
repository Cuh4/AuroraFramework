-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@section Constants

LifeBoatAPI.Constants = {
    AddonComponentTypes = {
        zone = 0, 
        object = 1, 
        character = 2, 
        vehicle = 3, 
        flare = 4, 
        fire = 5, 
        loot = 6, 
        button = 7, 
        animal = 8, 
        ice = 9, 
        cargo_zone = 10,
    };

    DynamicObjectTypes = {
        none = 0,
        character = 1,
        crate_small = 2,
        collectable = 3,    --(Not spawnable)
        basketball = 4,
        television = 5,
        barrel = 6,
        schematic = 7,      --(Not spawnable)
        debris = 8,         --(Not spawnable)
        chair = 9,
        trolley_food = 10,
        trolley_med = 11,
        clothing = 12,      --(Not spawnable)
        office_chair = 13,
        book = 14,
        bottle = 15,
        fryingpan = 16,
        mug = 17,
        saucepan = 18,
        stool = 19,
        telescope = 20,
        log = 21,
        bin = 22,
        book_2 = 23,
        loot = 24,
        blue_barrel = 25,
        buoyancy_ring = 26,
        container = 27,
        gas_canister = 28,
        pallet = 29,
        storage_bin = 30,
        fire_extinguisher = 31,
        trolley_tool = 32,
        cafetiere = 33,
        drawers_tools = 34,
        glass = 35,
        microwave = 36,
        plate = 37,
        box_closed = 38,
        box_open = 39,
        desk_lamp = 40,
        eraser_board = 41,
        folder = 42,
        funnel = 43,
        lamp = 44,
        microscope = 45,
        notebook = 46,
        pen_marker = 47,
        pencil = 48,
        scales = 49,
        science_beaker = 50,
        science_cylinder = 51,
        science_flask = 52,
        tub_1 = 53,
        tub_2 = 54,
        filestack = 55,
        barrel_toxic = 56,
        flare = 57,
        fire = 58,
        animal = 59,
        map_label = 60,  --(Not spawnable)
        iceberg = 61,    --(Not spawnable)
        gun_flare = 62,
        _vehicle_flare = 63,
        ammo_shell = 64,
        binoculars = 65,
        C4 = 66,
        grenade = 67,
        vehicle_flare = 68,
        coal = 69,
        meteorite = 70,
        glowstick = 71,
    };

    TankFluidTypes = {
        freshwater = 0,
        diesel = 1,
        jetfuel = 2,
        air = 3,
        exhaust = 4,
        oil = 5,
        seawater = 6,
        steam = 7
    };

    GameSettings = {
        third_person = "third_person", 
        third_person_vehicle = "third_person_vehicle", 
        vehicle_damage = "vehicle_damage", 
        player_damage = "player_damage", 
        npc_damage = "npc_damage", 
        sharks = "sharks", 
        fast_travel = "fast_travel", 
        teleport_vehicle = "teleport_vehicle", 
        rogue_mode = "rogue_mode", 
        auto_refuel = "auto_refuel", 
        megalodon = "megalodon", 
        map_show_players = "map_show_players", 
        map_show_vehicles = "map_show_vehicles", 
        show_3d_waypoints = "show_3d_waypoints", 
        show_name_plates = "show_name_plates", 
        day_night_length = "day_night_length",  -- currently cannot be written to
        sunrise = "sunrise",  -- currently cannot be written to
        sunset = "sunset",  -- currently cannot be written to
        infinite_money = "infinite_money", 
        settings_menu = "settings_menu", 
        unlock_all_islands = "unlock_all_islands", 
        infinite_batteries = "infinite_batteries", 
        infinite_fuel = "infinite_fuel", 
        engine_overheating = "engine_overheating", 
        no_clip = "no_clip", 
        map_teleport = "map_teleport", 
        cleanup_vehicle = "cleanup_vehicle", 
        clear_fow = "clear_fow",  -- clear fog of war
        vehicle_spawning = "vehicle_spawning", 
        photo_mode = "photo_mode", 
        respawning = "respawning", 
        settings_menu_lock = "settings_menu_lock", 
        despawn_on_leave = "despawn_on_leave",  -- despawn player characters when they leave a server
        unlock_all_components = "unlock_all_components", 
        override_weather = "override_weather",
    };

    LabelTypes = {
        none = 0,
        cross = 1,
        wreckage = 2,
        terminal = 3,
        military = 4,
        heritage = 5,
        rig = 6,
        industrial = 7,
        hospital = 8,
        science = 9,
        airport = 10,
        coastguard = 11,
        lighthouse = 12,
        fuel = 13,
        fuel_sell = 14
    };


    PositionTypes = {
        fixed = 0,
        vehicle = 1,
        object = 2
    };

    MarkerTypes = {
        delivery_target = 0,
        survivor = 1,
        object = 2,
        waypoint = 3,
        tutorial = 4,
        fire = 5,
        shark = 6,
        ice = 7,
        search_radius = 8,
        flag_1 = 9,
        flag_2 = 10,
        house = 11,
        car = 12,
        plane = 13,
        tank = 14,
        heli = 15,
        ship = 16,
        boat = 17,
        attack = 18,
        defend = 19
    };

    NotificationTypes = {
        new_mission = 0,
        new_mission_critical = 1,
        failed_mission = 2,
        failed_mission_critical = 3,
        complete_mission = 4,
        network_connect = 5,
        network_disconnect = 6,
        network_info = 7,
        chat_message = 8,
        network_info_critical = 9
    };

    
    OutfitType = {
        none = 0,
        worker = 1,
        fishing = 2,
        waiter = 3,
        swimsuit = 4,
        military = 5,
        office = 6,
        police = 7,
        science = 8,
        medical = 9,
        wetsuit = 10,
        civilian = 11
    };

    AnimalTypes = {
        shark = 0,
        whale = 1,
        seal = 2,
        penguin = 3
    };

    EquipmentSlotNumber = {
        Large_Equipment_Slot1 = 1,
        Small_Equipment_Slot2 = 2,
        Small_Equipment_Slot3 = 3,
        Small_Equipment_Slot4 = 4,
        Small_Equipment_Slot5 = 5,
        Outfit_Slot = 6
    };

    EquipmentTypes = { 
        none = 0,
        diving = 1,
        firefighter = 2,
        scuba = 3,
        parachute = 4,                  -- [int = {0 = deployed, 1 = ready}]
        arctic = 5,
        hazmat = 29,
        binoculars = 6,
        cable = 7,
        compass = 8,
        defibrillator = 9,              -- [int = charges]
        fire_extinguisher = 10,         -- [float = ammo]
        first_aid = 11,                 -- [int = charges]
        flare = 12,                     -- [int = charges]
        flaregun = 13,                  -- [int = ammo]
        flaregun_ammo = 14,             -- [int = ammo]
        flashlight = 15,                -- [float = battery]
        hose = 16,                      -- [int = {0 = hose off, 1 = hose on}]
        night_vision_binoculars = 17,   -- [float = battery]
        oxygen_mask = 18,               -- [float = oxygen]
        radio = 19,                     -- [int = channel] [float = battery]
        radio_signal_locator = 20,      -- [float = battery]
        remote_control = 21,            -- [int = channel] [float = battery]
        rope = 22,                
        strobe_light = 23,              -- [int = {0 = off, 1 = on}] [float = battery]
        strobe_light_infrared = 24,     -- [int = {0 = off, 1 = on}] [float = battery]
        transponder = 25,               -- [int = {0 = off, 1 = on}] [float = battery]
        underwater_welding_torch = 26,  -- [float = charge]
        welding_torch = 27,             -- [float = charge]
        coal = 28,
        radiation_detector = 30,        -- [float = battery]
        c4 = 31,                        -- [int = ammo]
        c4_detonator = 32,      
        speargun = 33,                  -- [int = ammo]
        speargun_ammo = 34,         
        pistol = 35,                    -- [int = ammo]
        pistol_ammo = 36,           
        smg = 37,                       -- [int = ammo]
        smg_ammo = 38,              
        rifle = 39,                     -- [int = ammo]
        rifle_ammo = 40,            
        grenade = 41,                   -- [int = ammo]
        machine_gun_ammo_box_k = 42,
        machine_gun_ammo_box_he = 43,
        machine_gun_ammo_box_he_frag = 44,
        machine_gun_ammo_box_ap = 45,
        machine_gun_ammo_box_i = 46,
        light_auto_ammo_box_k = 47,
        light_auto_ammo_box_he = 48,
        light_auto_ammo_box_he_frag = 49,
        light_auto_ammo_box_ap = 50,
        light_auto_ammo_box_i = 51,
        rotary_auto_ammo_box_k = 52,
        rotary_auto_ammo_box_he = 53,
        rotary_auto_ammo_box_he_frag = 54,
        rotary_auto_ammo_box_ap = 55,
        rotary_auto_ammo_box_i = 56,
        heavy_auto_ammo_box_k = 57,
        heavy_auto_ammo_box_he = 58,
        heavy_auto_ammo_box_he_frag = 59,
        heavy_auto_ammo_box_ap = 60,
        heavy_auto_ammo_box_i = 61,
        battle_shell_k = 62,
        battle_shell_he = 63,
        battle_shell_he_frag = 64,
        battle_shell_ap = 65,
        battle_shell_i = 66,
        artillery_shell_k = 67,
        artillery_shell_he = 68,
        artillery_shell_he_frag = 69,
        artillery_shell_ap = 70,
        artillery_shell_i = 71,
        chemlight = 72
    };

}

---@endsection