#NoEnv
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Window
SendMode Input
#SingleInstance Force
SetTitleMatchMode 2
#WinActivateForce
SetControlDelay 1
SetWinDelay 0
SetKeyDelay -1
SetMouseDelay -1
SetBatchLines -1

; Global variables
global isGameActive := false
global autoClickEnabled := false  ; Track auto-clicker state
global currentResolution := "3840x2160"  ; Default resolution
global mainGuiVisible := false

; Initialize recipe database
InitializeRecipes()

; --- Main Window (hidden by default) ---
Gui, +AlwaysOnTop +ToolWindow -Caption +HwndGui
Gui, Color, 333333
Gui, Show, w160 h200 Hide, RM Insta Depo ; Create window hidden, GuiHwnd is now set

; Set WS_EX_LAYERED style to enable transparency and other effects
DllCall("SetWindowLong", "UInt", GuiHwnd, "Int", -20, "UInt", DllCall("GetWindowLong", "UInt", GuiHwnd, "Int", -20) | 0x80000)

; Round the corners of the window (15px radius) - Applied before transparency
WinSet, Region, 0-0 w160 h200 r15-15, ahk_id %GuiHwnd%

; Set transparency for the main window (150 out of 255 for more noticeable effect) - Applied after region
WinSet, Transparent, 150, ahk_id %GuiHwnd%
; Font, s10 bold, Segoe UI ; Reduced font size for title

; Add a draggable bar at the top
Gui, Add, Text, x0 y0 w180 h30 vDragBar BackgroundTrans, ; Draggable area
Gui, Font, s10 norm, Segoe UI
; Add title text - positioned at the top
Gui, Add, Text, x20 y2 w200 h25 cWhite BackgroundTrans, RM Insta Depo

; Reset font to normal for other controls
Gui, Font, s8 norm, Segoe UI ; Smaller font size for items

; Replace buttons with static text
Gui, Add, Text, x20 y20 w130 h22 cWhite BackgroundTrans, F1: Depo
Gui, Add, Text, x20 y40 w130 h22 cWhite BackgroundTrans, F2: Loot Output
Gui, Add, Text, x20 y60 w130 h22 cWhite BackgroundTrans, F3: Loot Input
Gui, Add, Text, x20 y80 w130 h22 cWhite BackgroundTrans, F4: Recipe Search
Gui, Add, Text, x20 y100 w130 h22 cWhite BackgroundTrans, F5: Select Res: Default 4k
Gui, Add, Text, x20 y120 w130 h22 cWhite BackgroundTrans, F6: Auto Click (OFF)
Gui, Add, Text, x20 y140 w200 h25 cWhite BackgroundTrans, F8: Show/Hide GUI

; Add digital clock at the top right - 12-HOUR FORMAT
Gui, Font, s8 norm, Consolas  ; Smaller monospace font for clock
Gui, Add, Text, x0 y165 w100 h25 Right vDigitalClock cWhite BackgroundTrans, 00:00:00 AM

; Show with reduced width
Gui, Show, w160 h200, RM Insta Depo

; Create resolution selector GUI
Gui, 3:+ToolWindow +AlwaysOnTop +Owner1
Gui, 3:Color, 333333
Gui, 3:Font, s10 cWhite, Segoe UI
Gui, 3:Add, Text, x10 y10 w250 h20, Select your screen resolution:
Gui, 3:Add, Radio, x20 y40 w200 h20 vRes4K Checked, 3840 x 2160 (4K)
Gui, 3:Add, Radio, x20 y70 w200 h20 vResQHD, 2560 x 1440 (QHD) 
Gui, 3:Add, Radio, x20 y100 w200 h20 vResFHD, 1920 x 1080 (FHD)
Gui, 3:Add, Button, x60 y130 w80 h30 gApplyResolution, Apply
Gui, 3:Add, Button, x150 y130 w80 h30 g3GuiClose, Cancel

; Create recipe search GUI
Gui, 4:+ToolWindow +AlwaysOnTop +Owner1
Gui, 4:Color, 333333
Gui, 4:Font, s10 cWhite, Segoe UI
Gui, 4:Add, Text, x10 y10 w300 h20, Search for crafting recipes:
Gui, 4:Font, s10 cBlack, Segoe UI  ; Change font color to black for edit control
Gui, 4:Add, Edit, x10 y35 w220 h25 vSearchTerm gSearchOnEnter +WantReturn
GuiControl, Focus, SearchTerm  ; Set focus to the Search bar by default
Gui, 4:Font, s10 cWhite, Segoe UI  ; Change back to white for other controls
Gui, 4:Add, Button, x240 y35 w80 h25 gPerformSearch, Search
Gui, 4:Add, Edit, x10 y70 w310 h200 vSearchResults ReadOnly +Wrap, Type a recipe name above and click Search...
Gui, 4:Add, Button, x240 y280 w80 h30 g4GuiClose, Close

; Set up a timer to update the clock every second
SetTimer, UpdateClock, 1000

; Make the GUI draggable
Gui, +LastFound
hwnd := WinExist()
DllCall("SetWindowLong", "UInt", hwnd, "Int", -20, "UInt", DllCall("GetWindowLong", "UInt", hwnd, "Int", -20) | 0x80000)

; Set up handlers for UI interactions
OnMessage(0x201, "StartDrag") ; WM_LBUTTONDOWN
OnMessage(0x204, "ShowContextMenu") ; WM_RBUTTONDOWN
OnMessage(0x200, "HandleMouseMove") ; WM_MOUSEMOVE - For button hover effects

; Initialize menu state
MenuState := "Resume" ; Default state is Resume

; Create the context menu
Menu, ContextMenu, Add, Pause Hotkeys, PauseHotkeys
Menu, ContextMenu, Add, Resume Hotkeys, ResumeHotkeys
Menu, ContextMenu, Add, Toggle Auto Click, ToggleAutoClick
Menu, ContextMenu, Add, Recipe Search, OpenRecipeSearch
Menu, ContextMenu, Add, Change Resolution, OpenResSelector
Menu, ContextMenu, Add, Exit, ExitScript

; Set up a timer to check if Last Oasis is active
SetTimer, CheckGameActive, 1000

Return

; Function to initialize recipe database
InitializeRecipes() {
    global recipes := {}
    
    ; Utility -> Crafting recipes
    recipes["Aloe Goo Bomb"] := "6 Aloe Gel, 6 Cotton, 2 Rope"
recipes["Aloe Goo Bomb"] := "6 Aloe Gel, 6 Cotton, 2 Rope"
recipes["Ammo Chest"] := "12 Wood Shaft, 20 Stone, 40 Fiber, 25 Wood"
recipes["Advanced Capital Walker Wing"] := "40 Lightwood, 27 Hollowbone, 22 Nomad Cloth"
recipes["Ammo Scroll Rack"] := "12 Wood, 2 Bone Glue, 16 Fiber Weave, 12 Stone, 4 Rope"
recipes["Advanced Fiberworking Station"] := "35 Wood, 8 Nurr Fang, 35 Fiber Weave, 12 Wood Shaft"
recipes["Advanced Furnace"] := "25 Iron Gear, 10 Shardrock, 12 Gelatinous Goo, 100 Lightwood"
recipes["Advanced Stomping Station"] := "85 Redwood Wood, 90 Stone, 32 Wood Shaft, 15 Clay, 24 Rope"
recipes["Advanced Windmill"] := "87 Redwood Wood, 34 Nomad Cloth, 16 Rope, 45 Cotton"
recipes["Advanced Woodworking Station"] := "12 Nomad Cloth, 112 Cattail, 25 Earth Wax, 20 Rope, 120 Wood"
recipes["Arena Fence 1"] := "5 Wood, 8 Fiber"
recipes["Arena Fence 2"] := "5 Wood, 8 Fiber"
recipes["Aloe Gel"] := "5 Aloe Vera"
recipes["Aloe Gel"] := "5 Aloe Vera"
recipes["Aloe Gel"] := "5 Aloe Vera"
recipes["Advanced Large Walker Wing"] := "25 Nomad Cloth, 30 Redwood Wood, 28 Chitin Plate"
recipes["Advanced Medium Walker Wing"] := "25 Wood Shaft, 12 Triple Stitch Fabric, 12 Ceramic Shard"
recipes["Ancient Repair Hammer"] := "100 Bone Splinter, 50 Hide"
recipes["Apple Kambaro"] := "3 Apple"
recipes["Armored Capital Walker Leg"] := "32 Lightwood, 22 Iron Ore, 15 Shardrock"
recipes["Armored Medium Walker Leg"] := "12 Redwood Wood, 23 Earth Wax, 17 Bone Splinter"
recipes["Anti-Personnel Turret"] := "60 Wood, 7 Rope, 5 Fiber Weave"
recipes["Armor Shipment"] := "20 Brittle Bone Armor, 20 Forester's Armor, 20 Brittle Bone Handwraps, 20 Forester's Sleeves, 20 Brittle Bone Boots, 20 Forester's Sandals, 20 Fiber Headwrap"
recipes["Armor Shipment"] := "10 Baskwood Armor, 10 Baskwood Bracers, 10 Baskwood Boots, 10 Triple Stitch Boots, 10 Triple Stitch Bracers, 10 Triple Stitch Armor, 10 Fiber Headwrap"
recipes["Armored Large Walker Leg"] := "18 Chitin Plate, 25 Redwood Wood, 8 Obsidian"
recipes["Balaclava"] := "12 Fiber"
recipes["Base Container"] := "375 Wood, 80 Stone, 185 Fiber, 15 Nomad Cloth, 20 Rupu Vine, 20 Wood Shaft, 5 Beeswax"
recipes["Base Maintenance Chest"] := "130 Wood, 150 Fiber, 25 Stone, 12 Rope"
recipes["Artificer Woodworking Station"] := "120 Redwood Wood, 15 Ceramic Shard, 3 Nurr Fang, 8 Nomad Cloth"
recipes["Artisan Fiberworking Station"] := "35 Wood, 65 Chitin Plate, 35 Fiber Weave, 12 Wood Shaft"
recipes["Barrier Base"] := "250 Redwood Wood, 100 Stone, 20 Rope"
recipes["Barrier Gate"] := "250 Redwood Wood, 100 Stone, 20 Rope"
recipes["Barrier Plank"] := "250 Redwood Wood, 100 Stone, 20 Rope"
recipes["Banner 1"] := "10 Wood Shaft, 8 Fiber Weave"
recipes["Banner 2"] := "12 Wood Shaft, 4 Fiber Weave"
recipes["Banner 3"] := "12 Wood Shaft, 4 Fiber Weave"
recipes["Armoury Walker Module"] := "1 Spline, 1 Strut, 1 Lever"
recipes["Ash"] := "1 Wood"
recipes["Ash"] := "1 Wood"
recipes["Ash"] := "1 Wooden Slab"
recipes["Ash"] := "1 Lightwood"
recipes["Ash"] := "1 Lightwood"
recipes["Balang Walker Upgrade Torque Tier 1"] := "60 Wood, 15 Bone Splinter, 65 Fiber, 12 Rope"
recipes["Balang Walker Upgrade Torque Tier 3"] := "65 Fiber, 15 Bone Splinter, 12 Rope, 60 Wood"
recipes["Balang Walker Upgrade Torque Tier 4"] := "12 Rope, 60 Wood, 65 Fiber, 15 Bone Splinter"
recipes["Balang Walker Upgrade Water Tier 1"] := "10 Bone Glue, 45 Fiber, 15 Rupu Pelt"
recipes["Balang Walker Upgrade Water Tier 2"] := "45 Fiber, 10 Bone Glue"
recipes["Balang Walker Upgrade Water Tier 3"] := "15 Rupu Pelt, 45 Fiber, 10 Bone Glue"
recipes["Balang Walker Upgrade Water Tier 4"] := "45 Fiber, 15 Rupu Pelt, 10 Bone Glue"
recipes["Balang Walker Legs (1 of 2)"] := "1 Small Walker Leg"
recipes["Balang Walker Wings (1 of 2)"] := "1 Small Walker Wing"
recipes["Balang Walker Wings Small (1 of 2)"] := "1 Improved Small Walker Wing"
recipes["Artisan Soil Auger"] := "6 Reinforced Gear, 35 Wooden Slab, 60 Rope, 16 Nurr Fang, 10 Leather"
recipes["Automaton"] := "15 Wood, 10 Rope, 20 Fiber, 5 Wood Shaft"
recipes["Balang Walker"] := "18 Wood Shaft, 28 Fiber Weave, 27 Rope, 95 Wood, 100 Fiber, 2 Rupu Vine, 1 Wooden Gear"
recipes["Ballista"] := "24 Wood, 5 Fiber Weave, 5 Wood Shaft"
recipes["Ballista - Tier 2"] := "135 Wood, 165 Fiber, 35 Stone, 32 Palm Leaves"
recipes["Ballista - Tier 3"] := "55 Stone, 35 Rope, 80 Wood, 10 Earth Wax"
recipes["Ballista - Tier 4"] := "20 Redwood Wood, 10 Bone Splinter, 20 Rope"
recipes["Bombolt"] := "10 Wood Shaft, 3 Lava Fuel, 1 Obsidian"
recipes["Bone Bolt"] := "5 Wood Shaft, 5 Bone Splinter, 12 Fiber"
recipes["Bone Bolt"] := "5 Wood Shaft, 5 Bone Splinter, 12 Fiber"
recipes["Bone Bolt"] := "5 Wood Shaft, 5 Bone Splinter, 12 Fiber"
recipes["Bone Scattershot Ammo"] := "8 Bone Splinter, 3 Fiber Weave"
recipes["Bone Scattershot Ammo"] := "8 Bone Splinter, 3 Fiber Weave"
recipes["Bone Scattershot Ammo"] := "8 Bone Splinter, 3 Fiber Weave"
recipes["Baskwood Armor"] := "20 Tree Sap, 7 Leather"
recipes["Baskwood Armor"] := "20 Tree Sap, 7 Leather"
recipes["Bone Dart"] := "3 Wood Shaft, 6 Bone Splinter, 12 Fiber"
recipes["Bone Dart"] := "3 Wood Shaft, 6 Bone Splinter, 12 Fiber"
recipes["Bone Dart"] := "3 Wood Shaft, 6 Bone Splinter, 12 Fiber"
recipes["Bone Harpoon"] := "1 Bone Bolt, 2 Hide, 4 Rope"
recipes["Bone Harpoon"] := "1 Bone Bolt, 2 Hide, 4 Rope"
recipes["Bone Harpoon"] := "1 Bone Bolt, 2 Hide, 4 Rope"
recipes["Baskwood Boots"] := "10 Tree Sap, 2 Leather"
recipes["Baskwood Boots"] := "10 Tree Sap, 2 Leather"
recipes["Baskwood Bracers"] := "8 Rupu Vine, 1 Leather"
recipes["Baskwood Bracers"] := "8 Rupu Vine, 1 Leather"
recipes["Blacksmith Station"] := "15 Nibiran Ingot, 10 Worm Scale, 115 Lightwood, 12 Shardrock"
recipes["Bomb Chest Trap"] := "30 Wood, 10 Rope"
recipes["Basket Tall"] := "10 Wood, 15 Fiber"
recipes["Bone Bottle"] := "1 Nomad Cloth, 5 Bone Splinter, 32 Fiber"
recipes["Bone Bottle"] := "1 Nomad Cloth, 5 Bone Splinter, 32 Fiber"
recipes["Basket Open"] := "10 Wood, 15 Fiber"
recipes["Basket Wide"] := "10 Wood, 15 Fiber"
recipes["Bone Effigy"] := "5 Wood, 1 Rupu Pelt"
recipes["Bed"] := "32 Redwood Wood, 45 Cotton, 2 Nomad Cloth"
recipes["Big Roped Ladder"] := "80 Wood, 22 Stone, 3 Rupu Vine"
recipes["Boarding Plank"] := "290 Wood, 3 Nomad Cloth, 4 Wood Shaft"
recipes["Battery Walker Module"] := "1 Strut, 1 Lever, 1 Shackle"
recipes["Bent Wooden Planks"] := "1 Wood Log"
recipes["Bone Glue"] := "10 Purified Water, 3 Bone Splinter"
recipes["Bone Glue"] := "4 Purified Water, 1 Nurr Fang"
recipes["Bone Glue"] := "10 Purified Water, 3 Bone Splinter"
recipes["Bone Glue"] := "1 Nurr Fang, 4 Purified Water"
recipes["Battleship Walker Legs (1 of 2)"] := "360 Wood, 200 Fiber, 6 Reinforced Plank"
recipes["Battleship Walker Legs Armored (1 of 2)"] := "900 Wood, 500 Fiber, 3 Reinforced Plank"
recipes["Battleship Walker Legs Heavy (1 of 2)"] := "1800 Wood, 1000 Fiber, 6 Reinforced Plank"
recipes["Battleship Walker Wings (1 of 2)"] := "90 Wood, 4 Nomad Cloth"
recipes["Battleship Walker Wings Large (1 of 2)"] := "900 Wood, 14 Nomad Cloth"
recipes["Battleship Walker Wings Medium (1 of 2)"] := "720 Wood, 10 Nomad Cloth"
recipes["Battleship Walker Wings Small (1 of 2)"] := "450 Wood, 8 Nomad Cloth"
recipes["Battleship Walker"] := "3964 Wood, 1711 Fiber, 4 Reinforced Plank"
recipes["Battle Fan"] := "6 Reinforced Plank, 35 Wood Shaft, 60 Rupu Vine, 5 Bone Glue"
recipes["Battlements"] := "2 Wooden Slab, 14 Fiber"
recipes["Beat Stick"] := "7 Wood, 5 Fiber"
recipes["Blunt Quarterstaff"] := "1 Wood Shaft, 2 Fiber Weave, 2 Charcoal"
recipes["Bomb Javelin"] := "1 Heavy Javelin, 12 Tar, 24 Lava, 2 Spearmint"
recipes["Bone Pickaxe"] := "6 Fiber Weave, 10 Wood Shaft, 12 Bone Splinter"
recipes["Bone Repair Hammer"] := "26 Bone Splinter, 11 Hide"
recipes["Bone Sickle"] := "2 Wood Shaft, 22 Fiber, 10 Stone, 10 Bone Splinter"
recipes["Brittle Bone Armor"] := "6 Ceramic Shard, 8 Nomad Cloth, 18 Bone Splinter"
recipes["Brittle Bone Boots"] := "25 Cattail, 12 Bone Splinter, 2 Ceramic Shard"
recipes["Brittle Bone Handwraps"] := "12 Bone Splinter, 7 Rope, 2 Ceramic Shard"
recipes["Bucket helmet"] := "12 Fiber"
recipes["Bones Pile"] := "20 Fiber, 5 Rupu Pelt"
recipes["Brazier"] := "10 Wood, 20 Fiber"
recipes["Buffalo Walker Upgrade Cargo Tier 1"] := "10 Chitin Plate, 14 Redwood Wood, 22 Stone"
recipes["Buffalo Walker Upgrade Cargo Tier 2"] := "10 Chitin Plate, 14 Redwood Wood, 22 Stone"
recipes["Buffalo Walker Upgrade Cargo Tier 3"] := "10 Chitin Plate, 14 Redwood Wood, 22 Stone"
recipes["Buffalo Walker Upgrade Cargo Tier 4"] := "22 Stone, 10 Chitin Plate, 14 Ceramic Shard"
recipes["Buffalo Walker Upgrade Durability Tier 1"] := "24 Tar, 40 Obsidian, 40 Chitin Plate"
recipes["Buffalo Walker Upgrade Durability Tier 2"] := "24 Tar, 40 Obsidian, 40 Chitin Plate"
recipes["Buffalo Walker Upgrade Durability Tier 3"] := "24 Tar, 40 Obsidian, 40 Chitin Plate"
recipes["Buffalo Walker Upgrade Durability Tier 4"] := "40 Chitin Plate, 24 Tar, 40 Obsidian"
recipes["Buffalo Walker Upgrade Gear Tier 1"] := "9 Triple Stitch Fabric, 15 Tar, 27 Bone Splinter"
recipes["Buffalo Walker Upgrade Gear Tier 2"] := "27 Bone Splinter, 9 Triple Stitch Fabric, 15 Tar"
recipes["Buffalo Walker Upgrade Gear Tier 3"] := "9 Triple Stitch Fabric, 15 Tar, 27 Bone Splinter"
recipes["Buffalo Walker Upgrade Gear Tier 4"] := "9 Triple Stitch Fabric, 15 Tar, 27 Bone Splinter"
recipes["Buffalo Walker Upgrade Mobility Tier 1"] := "5 Reinforced Gear, 24 Tallow, 56 Chitin Plate"
recipes["Buffalo Walker Upgrade Mobility Tier 2"] := "5 Reinforced Gear, 24 Tallow, 56 Chitin Plate"
recipes["Buffalo Walker Upgrade Mobility Tier 3"] := "5 Reinforced Gear, 24 Tallow, 56 Chitin Plate"
recipes["Buffalo Walker Upgrade Mobility Tier 4"] := "5 Reinforced Gear, 24 Tallow, 56 Chitin Plate"
recipes["Buffalo Walker Upgrade Torque Tier 1"] := "36 Redwood Wood, 17 Earth Wax"
recipes["Buffalo Walker Upgrade Torque Tier 2"] := "36 Redwood Wood, 13 Wood Shaft, 17 Earth Wax"
recipes["Buffalo Walker Upgrade Torque Tier 3"] := "36 Redwood Wood, 17 Earth Wax, 13 Wood Shaft"
recipes["Buffalo Walker Upgrade Torque Tier 4"] := "13 Wood Shaft, 17 Earth Wax, 36 Redwood Wood"
recipes["Buffalo Walker Upgrade Water Tier 1"] := "25 Charcoal, 40 Spearmint, 17 Leather"
recipes["Buffalo Walker Upgrade Water Tier 2"] := "25 Charcoal, 40 Spearmint, 17 Leather"
recipes["Buffalo Walker Upgrade Water Tier 3"] := "25 Charcoal, 40 Spearmint, 17 Leather"
recipes["Buffalo Walker Upgrade Water Tier 4"] := "25 Charcoal, 40 Spearmint, 17 Leather"
recipes["Bonebreaker"] := "2 Spearmint, 6 Lava Poppy, 3 Tar, 1 Glass"
recipes["Bonebreaker"] := "2 Spearmint, 6 Lava Poppy, 3 Tar, 1 Glass"
recipes["Buffalo Walker Legs (1 of 2)"] := "1 Large Walker Leg"
recipes["Buffalo Walker Legs Armored (1 of 2)"] := "1 Armored Large Walker Leg"
recipes["Buffalo Walker Wings Large (1 of 2)"] := "1 Flotillan Large Walker Wing"
recipes["Buffalo Walker Wings Medium (1 of 2)"] := "1 WalkerWingAdvanced_T3"
recipes["Bonespike Sword"] := "3 Wood Shaft, 2 Bone Glue, 4 Rope"
recipes["Catapult Boulder"] := "50 Stone, 5 Ceramic Shard"
recipes["Carapace Armor"] := "15 Chitin Plate, 3 Nomad Cloth, 8 Tar"
recipes["Carapace Boots"] := "8 Chitin Plate, 3 Nomad Cloth, 15 Earth Wax"
recipes["Carapace Gauntlets"] := "12 Chitin Plate, 3 Nomad Cloth, 10 Earth Wax"
recipes["Cement Balang Core"] := "100 Wood, 20 Stone, 50 Fiber"
recipes["Cement Battlements"] := "25 Lightwood, 6 Iron Ingot, 4 Iron Nails, 6 Tar"
recipes["Cement Corner"] := "25 Lightwood, 6 Iron Ingot, 4 Iron Nails, 6 Tar"
recipes["Cement Door"] := "25 Lightwood, 6 Iron Ingot, 4 Iron Nails, 6 Tar"
recipes["Cement Floor / Roof"] := "25 Lightwood, 6 Iron Ingot, 4 Iron Nails, 6 Tar"
recipes["Cement Foundation"] := "25 Lightwood, 6 Iron Ingot, 4 Iron Nails, 6 Tar"
recipes["Cement Silur Core"] := "200 Wood, 50 Stone, 100 Fiber"
recipes["Cement Wall 1"] := "25 Lightwood, 6 Iron Ingot, 4 Iron Nails, 6 Tar"
recipes["Cement Wall 2"] := "25 Lightwood, 6 Iron Ingot, 4 Iron Nails, 6 Tar"
recipes["Cement Wall With Window 1"] := "25 Lightwood, 6 Iron Ingot, 4 Iron Nails, 6 Tar"
recipes["Cement Wall With Window 2"] := "25 Lightwood, 6 Iron Ingot, 4 Iron Nails, 6 Tar"
recipes["Cement Wall With Windows 1"] := "25 Lightwood, 6 Iron Ingot, 4 Iron Nails, 6 Tar"
recipes["Cement Wall With Windows 2"] := "25 Lightwood, 6 Iron Ingot, 4 Iron Nails, 6 Tar"
recipes["Camp Fire"] := "16 Wood, 11 Fiber, 18 Stone"
recipes["Curing Station"] := "13 Hide, 15 Wood Shaft, 26 Rope, 45 Salt Rock, 12 Tree Sap"
recipes["Decal"] := "10 Charcoal"
recipes["Defensive Tower"] := "480 Wood, 345 Fiber, 117 Wood Shaft, 22 Rope, 15 Fiber Weave"
recipes["Cage"] := "50 Wood, 30 Fiber"
recipes["Cage 1"] := "20 Wood, 10 Fiber"
recipes["Cage 2"] := "20 Wood, 10 Fiber"
recipes["Carpet Dark"] := "1 Rupu Vine, 5 Rupu Pelt"
recipes["Carpet Light"] := "1 Rupu Vine, 5 Fiber Weave"
recipes["Crate 1"] := "20 Wood, 20 Fiber"
recipes["Cauterizing Station"] := "45 Wood, 20 Stone, 20 Aloe Vera"
recipes["Bullrush Base Module"] := "1 Spring, 1 Strut, 1 Cog"
recipes["Bullrush Walker Module"] := "1 Spring, 1 Strut, 1 Cog"
recipes["Craftsman Base Module"] := "1 Spline, 1 Spring, 1 Shackle"
recipes["Camelop Walker Upgrade Torque Tier 1"] := "5 Rope"
recipes["Camelop Walker Upgrade Torque Tier 2"] := "13 Wood Shaft, 52 Wood, 5 Rope"
recipes["Camelop Walker Upgrade Torque Tier 3"] := "13 Wood Shaft, 5 Rope, 52 Wood"
recipes["Camelop Walker Upgrade Torque Tier 4"] := "5 Rope, 13 Wood Shaft, 52 Wood"
recipes["Camelop Walker Upgrade Water Tier 1"] := "42 Wood Shaft, 28 Rope"
recipes["Camelop Walker Upgrade Water Tier 2"] := "42 Wood Shaft, 28 Rope"
recipes["Camelop Walker Upgrade Water Tier 3"] := "42 Wood Shaft, 28 Rope"
recipes["Camelop Walker Upgrade Water Tier 4"] := "42 Wood Shaft, 28 Rope"
recipes["Cobra Walker Upgrade Water Tier 1"] := "45 Wood Shaft, 22 Rope"
recipes["Cobra Walker Upgrade Water Tier 2"] := "32 Wood Shaft, 24 Rope"
recipes["Cobra Walker Upgrade Water Tier 3"] := "35 Wood Shaft, 25 Rope"
recipes["Cobra Walker Upgrade Water Tier 4"] := "42 Wood Shaft, 28 Rope"
recipes["Buffalo Walker Wings Raider (1 of 2)"] := "1 WalkerWingAdvanced_T3"
recipes["Buffalo Walker Wings Rugged (1 of 2)"] := "1 WalkerWingAdvanced_T3"
recipes["Buffalo Walker Wings Skirmish (1 of 2)"] := "1 Improved Large Walker Wing"
recipes["Buffalo Walker Wings Small (1 of 2)"] := "1 Improved Large Walker Wing"
recipes["Camelop Walker Legs (1 of 2)"] := "1 Large Walker Leg"
recipes["Capital Walker Leg"] := "18 Lightwood, 22 Earth Wax, 15 Wood Shaft"
recipes["Capital Walker Wing"] := "22 Lightwood, 20 Nomad Cloth"
recipes["Camelop  Walker"] := "650 Wood, 90 Fiber, 120 Stone, 125 Wood Shaft, 70 Rope, 50 Obsidian, 20 Clay, 1 Reinforced Gear"
recipes["Catapult"] := "140 Wood, 60 Stone, 35 Rope, 35 Earth Wax, 20 Fiber Weave, 20 Ceramic Shard"
recipes["Ceramic Dart"] := "6 Wood Shaft, 6 Fiber Weave, 5 Ceramic Shard"
recipes["Ceramic Rok"] := "10 Ceramic Shard, 5 Fiber Weave"
recipes["Ceramic Rok"] := "10 Ceramic Shard, 5 Fiber Weave"
recipes["Ceramic Scattershot Ammo"] := "6 Ceramic Shard, 8 Fiber Weave"
recipes["Ceramic-Tipped Bolt"] := "5 Wood Shaft, 8 Ceramic Shard, 20 Fiber Weave"
recipes["Ceramic-Tipped Bolt"] := "5 Wood Shaft, 8 Ceramic Shard, 20 Fiber Weave"
recipes["Ceramic-Tipped Harpoon"] := "1 Ceramic Bolt, 2 Hide, 5 Rope"
recipes["Chalk Bomb"] := "1 Tar, 3 Cotton, 2 Rope"
recipes["Chalk Bomb"] := "1 Tar, 3 Cotton, 2 Rope"
recipes["Charged Boulder"] := "3 Meteor Core, 25 Stone, 5 Fiber Weave"
recipes["Charged Boulder"] := "3 Meteor Core, 25 Stone, 5 Fiber Weave"
recipes["Charged Boulder"] := "3 Meteor Core, 25 Stone, 5 Fiber Weave"
recipes["Charged Rok"] := "65 Chitin Plate, 3 Meteor Core, 22 Earth Wax"
recipes["Charged Rok"] := "65 Chitin Plate, 3 Meteor Core, 22 Earth Wax"
recipes["Cluster Bomb"] := "30 Obsidian, 10 Earth Wax, 25 Phosphorus, 1 Lava Fuel, 10 Tar"
recipes["Cloak"] := "10 Nomad Cloth, 5 Lightwood, 4 Rubber Block"
recipes["Cloaked Rupu Fur Armor"] := "4 Fiber Weave, 5 Wood Shaft, 9 Rupu Pelt, 4 Hide"
recipes["Clay Battlement"] := "8 Cattail, 3 Wooden Slab, 10 Clay"
recipes["Clay Corner"] := "20 Cattail, 3 Wooden Slab, 40 Clay"
recipes["Clay Door"] := "20 Cattail, 3 Wooden Slab, 20 Clay"
recipes["Clay Floor / Roof"] := "20 Cattail, 3 Wooden Slab, 20 Clay"
recipes["Clay Foundation"] := "8 Cattail, 3 Wooden Slab, 25 Clay"
recipes["Clay Wall"] := "20 Cattail, 3 Wooden Slab, 20 Clay"
recipes["Clay Wall with Window"] := "20 Cattail, 3 Wooden Slab, 20 Clay"
recipes["Clay Wall with Windows"] := "20 Cattail, 3 Wooden Slab, 15 Clay"
recipes["Clay Pot"] := "3 Stone, 5 Wood Shaft, 10 Clay, 2 Rope, 10 Redwood Wood"
recipes["Ceramic Flask"] := "8 Ceramic Shard, 1 Rope"
recipes["Chair throne"] := "5 Wood, 25 Rupu Vine"
recipes["Clan Flag"] := "10 Wood, 1 Fiber Weave"
recipes["Ceramic Hatchet"] := "12 Cotton, 3 Ceramic Shard, 6 Redwood Wood"
recipes["Ceramic Pickaxe"] := "12 Ceramic Shard, 20 Wood Shaft, 2 Bone Glue"
recipes["Ceramic Repair Hammer"] := "22 Wood Shaft, 14 Ceramic Shard, 6 Rope, 24 Cotton"
recipes["Chair Comfortable"] := "35 Wood, 1 Fiber Weave"
recipes["Chair Simple"] := "15 Wood, 10 Fiber"
recipes["Clan Flag Hanging"] := "15 Wood, 2 Fiber Weave"
recipes["Ceramic Shard"] := "1 Clay"
recipes["Ceramic Shard"] := "1 Clay"
recipes["Charcoal"] := "1 Wood"
recipes["Charcoal"] := "1 Wood"
recipes["Charcoal"] := "1 Wood"
recipes["Charcoal"] := "1 Wooden Slab"
recipes["Charcoal"] := "1 Redwood Wood"
recipes["Charcoal"] := "1 Redwood Wood"
recipes["Chitin PickAxe"] := "6 Fiber Weave, 10 Wood Shaft, 4 Chitin Plate"
recipes["Chitin Plate"] := "5 Insects"
recipes["Chitin Plate"] := "5 Insects"
recipes["Chitin Plate"] := "5 Insects"
recipes["Chitin Repair Hammer"] := "14 Wood Shaft, 10 Chitin Plate, 5 Rope"
recipes["Chitin Sickle"] := "2 Wood Shaft, 22 Fiber, 10 Stone, 4 Chitin Plate"
recipes["Clay"] := "1 Terrain: Clay Spots, 10 Ash"
recipes["Clay"] := "1 Terrain: Clay Spots, 10 Ash"
recipes["Cobra Walker Upgrade Torque Tier 1"] := "5 Rope"
recipes["Cobra Walker Legs (1 of 2)"] := "1 Large Walker Leg"
recipes["Cobra Walker"] := "900 Wood, 390 Fiber, 350 Stone, 40 Wood Shaft, 30 Rope, 10 Bone Splinter, 12 Rupu Vine, 1 Reinforced Gear"
recipes["Compacted Torque Battery"] := "30 Rope, 24 Ceramic Shard, 16 Obsidian"
recipes["Crafting Bench"] := "35 Wood, 7 Fiber Weave, 12 Wood Shaft, 14 Bone Splinter"
recipes["Crate 2"] := "20 Wood, 10 Fiber Weave"
recipes["Craftsman Walker Module"] := "1 Spline, 1 Spring, 1 Shackle"
recipes["Cooked Corn"] := "20 Corn"
recipes["Corner"] := "2 Wooden Slab, 14 Fiber"
recipes["Dinghy Walker Upgrade Cargo Tier 1"] := "30 Wood Shaft, 20 Fiber Weave"
recipes["Dinghy Walker Upgrade Cargo Tier 2"] := "30 Wood Shaft, 20 Fiber Weave"
recipes["Dinghy Walker Upgrade Cargo Tier 3"] := "20 Fiber Weave, 30 Wood Shaft, 10 Stone"
recipes["Desert Mule"] := "3 Thornberry, 6 Aloe Gel, 6 Mushroom Flesh, 1 Glass"
recipes["Desert Mule"] := "3 Thornberry, 6 Aloe Gel, 6 Mushroom Flesh, 1 Glass"
recipes["Dinghy Walker Legs (1 of 2)"] := "1 Small Walker Leg"
recipes["Crane"] := "150 Wood, 15 Iron Ingot, 15 Bone Glue, 30 Tar"
recipes["Dinghy Walker"] := "126 Wood, 88 Fiber, 43 Stone, 8 Rupu Vine, 8 Wood Shaft"
recipes["Crude Hatchet"] := "2 Stone, 8 Wood"
recipes["Dinghy Gate"] := "6 Wooden Slab, 20 Wood Shaft, 12 Stone"
recipes["Explosive Bolt"] := "3 Wood Shaft, 2 Lava, 1 Phosphorus"
recipes["Explosive Dart"] := "8 Wood Shaft, 6 Lava, 3 Phosphorus"
recipes["Fire Bolt"] := "5 Wood Shaft, 12 Fiber Weave, 8 Earth Wax, 60 Phosphorus"
recipes["Fire Bolt"] := "5 Wood Shaft, 12 Fiber Weave, 8 Earth Wax, 60 Phosphorus"
recipes["Fire Bomb"] := "4 Lava, 3 Cotton, 1 Gelatinous Goo, 1 Phosphorus"
recipes["Fire Dart"] := "2 Wood Shaft, 2 Fiber Weave, 2 Earth Wax, 30 Phosphorus"
recipes["Fire Dart"] := "2 Wood Shaft, 2 Fiber Weave, 2 Earth Wax, 30 Phosphorus"
recipes["Feather Boots"] := "2 Worm Silk, 2 Rope"
recipes["Feather mask"] := "12 Fiber"
recipes["Festive Turban"] := "12 Fiber"
recipes["Fiber Arm Wraps"] := "7 Fiber, 2 Rupu Pelt"
recipes["Fiber Headwrap"] := "2 Fiber Weave"
recipes["Fiber Sandals"] := "8 Fiber, 3 Palm Leaves"
recipes["Fiber Shirt and Trousers"] := "25 Fiber, 1 Charcoal"
recipes["Dyeing Station"] := "20 Wood, 30 Fiber, 10 Stone"
recipes["Farmable Area"] := "500 Fiber, 50 Clay"
recipes["Fiberworking Station"] := "30 Wood, 25 Fiber, 8 Wood Shaft, 4 Rupu Vine"
recipes["Falling Rock Trap"] := "5 Rupu Vine, 40 Stone, 7 Fiber Weave, 10 Bone Glue"
recipes["Durable Water Sack"] := "8 Fiber Weave, 3 Earth Wax"
recipes["Durable Water Sack"] := "8 Fiber Weave, 3 Earth Wax"
recipes["Exoskeleton"] := "45 Redwood Wood, 15 Chitin Plate, 5 Bone Glue, 30 Hide"
recipes["Fence 1"] := "20 Wood, 10 Fiber Weave"
recipes["Fence 2"] := "20 Wood, 10 Fiber Weave"
recipes["Fence 3"] := "20 Wood, 10 Fiber Weave"
recipes["Fence 4"] := "20 Wood, 10 Fiber Weave"
recipes["Fence 5"] := "20 Wood, 10 Fiber Weave"
recipes["Fence 6"] := "20 Wood, 10 Fiber Weave"
recipes["Fire Goblet"] := "50 Wood, 25 Stone, 45 Animal Fat"
recipes["Fast Grappling Hook"] := "22 Wood Shaft, 8 Nomad Cloth, 12 Rope"
recipes["Firework 1"] := "5 Charcoal, 5 Cattail"
recipes["Earth Wax"] := "1 Terrain: Black Soil, 2 Purified Water"
recipes["Earth Wax"] := "1 Terrain: Black Soil, 2 Purified Water"
recipes["Earth Wax"] := "15 Palm Leaves"
recipes["Earth Wax"] := "14 Palm Leaves"
recipes["Earth Wax"] := "13 Palm Leaves"
recipes["Earth Wax"] := "10 Rupu Vine"
recipes["Earth Wax"] := "9 Rupu Vine"
recipes["Earth Wax"] := "8 Rupu Vine"
recipes["Earth Wax"] := "1 Beeswax"
recipes["Earth Wax"] := "1 Beeswax"
recipes["Earth Wax"] := "1 Beeswax"
recipes["Earth Wax"] := "10 Mushroom Flesh"
recipes["Earth Wax"] := "9 Mushroom Flesh"
recipes["Earth Wax"] := "8 Mushroom Flesh"
recipes["Fiber"] := "1 Rupu Pelt"
recipes["Fiber"] := "1 Rupu Pelt"
recipes["Fiber"] := "1 Rupu Pelt"
recipes["Fiber"] := "100 Rupu Pelt"
recipes["Fiber"] := "100 Rupu Pelt"
recipes["Fiber"] := "100 Rupu Pelt"
recipes["Fiber"] := "10 Cattail"
recipes["Fiber"] := "10 Cattail"
recipes["Fiber"] := "100 Cattail"
recipes["Fiber"] := "100 Cattail"
recipes["Fiber"] := "1 Palm Leaves"
recipes["Fiber"] := "1 Palm Leaves"
recipes["Fiber"] := "1 Palm Leaves"
recipes["Fiber"] := "100 Palm Leaves"
recipes["Fiber"] := "100 Palm Leaves"
recipes["Fiber"] := "100 Palm Leaves"
recipes["Fiber Weave"] := "6 Fiber"
recipes["Fiber Weave"] := "6 Fiber"
recipes["Fiber Weave"] := "600 Fiber"
recipes["Fiber Weave"] := "600 Fiber"
recipes["Fiber Weave"] := "6 Fiber"
recipes["Fiber Weave"] := "600 Fiber"
recipes["Fireproof Walker Module"] := "1 Spline, 1 Spring, 1 Cog"
recipes["Domus Walker Upgrade Mobility Tier 4"] := "6 Iron Gear, 38 Rubber Block, 23 Shardrock"
recipes["Domus Walker Upgrade Torque Tier 1"] := "12 Tar, 45 Lightwood, 9 Rope"
recipes["Domus Walker Upgrade Torque Tier 2"] := "12 Tar, 45 Lightwood, 9 Rope"
recipes["Domus Walker Upgrade Torque Tier 3"] := "12 Tar, 9 Rope, 45 Lightwood"
recipes["Domus Walker Upgrade Torque Tier 4"] := "12 Tar, 45 Lightwood, 9 Rope"
recipes["Domus Walker Upgrade Water Tier 1"] := "15 Rubber Block, 12 Eucalyptus Leaf, 8 Reinforced Plank, 45 Iron Nails"
recipes["Domus Walker Upgrade Water Tier 2"] := "15 Rubber Block, 12 Eucalyptus Leaf, 8 Reinforced Plank, 45 Iron Nails"
recipes["Domus Walker Upgrade Water Tier 3"] := "15 Rubber Block, 12 Eucalyptus Leaf, 8 Reinforced Plank, 45 Iron Nails"
recipes["Domus Walker Upgrade Water Tier 4"] := "15 Rubber Block, 12 Eucalyptus Leaf, 8 Reinforced Plank, 45 Iron Nails"
recipes["Falco Walker Upgrade Cargo Tier 1"] := "31 Wood Shaft, 20 Clay, 15 Chitin Plate"
recipes["Falco Walker Upgrade Cargo Tier 2"] := "31 Wood Shaft, 20 Clay, 15 Chitin Plate"
recipes["Falco Walker Upgrade Cargo Tier 3"] := "20 Clay, 31 Wood Shaft, 15 Chitin Plate"
recipes["Falco Walker Upgrade Cargo Tier 4"] := "20 Clay, 31 Wood Shaft, 15 Chitin Plate"
recipes["Falco Walker Upgrade Durability Tier 1"] := "40 Redwood Wood, 25 Ceramic Shard, 45 Obsidian"
recipes["Falco Walker Upgrade Durability Tier 2"] := "40 Redwood Wood, 25 Ceramic Shard, 45 Obsidian"
recipes["Falco Walker Upgrade Durability Tier 3"] := "25 Ceramic Shard, 40 Redwood Wood, 45 Obsidian"
recipes["Falco Walker Upgrade Durability Tier 4"] := "25 Ceramic Shard, 40 Redwood Wood, 45 Obsidian"
recipes["Falco Walker Upgrade Gear Tier 1"] := "15 Bone Splinter, 45 Redwood Wood, 22 Fiber Weave"
recipes["Falco Walker Upgrade Gear Tier 2"] := "15 Bone Splinter, 22 Fiber Weave, 45 Redwood Wood"
recipes["Falco Walker Upgrade Gear Tier 3"] := "22 Fiber Weave, 45 Redwood Wood, 15 Bone Splinter"
recipes["Falco Walker Upgrade Gear Tier 4"] := "22 Fiber Weave, 45 Redwood Wood, 15 Bone Splinter"
recipes["Falco Walker Upgrade Mobility Tier 1"] := "5 Gelatinous Goo, 32 Clay, 5 Reinforced Gear"
recipes["Falco Walker Upgrade Mobility Tier 2"] := "5 Gelatinous Goo, 32 Clay, 5 Reinforced Gear"
recipes["Falco Walker Upgrade Mobility Tier 3"] := "32 Clay, 5 Gelatinous Goo, 5 Reinforced Gear"
recipes["Falco Walker Upgrade Mobility Tier 4"] := "32 Clay, 5 Gelatinous Goo, 5 Reinforced Gear"
recipes["Falco Walker Upgrade Torque Tier 1"] := "17 Chitin Plate, 10 Earth Wax"
recipes["Falco Walker Upgrade Torque Tier 2"] := "17 Chitin Plate, 13 Wood Shaft, 10 Earth Wax"
recipes["Falco Walker Upgrade Torque Tier 3"] := "17 Chitin Plate, 13 Wood Shaft, 10 Earth Wax"
recipes["Falco Walker Upgrade Torque Tier 4"] := "17 Chitin Plate, 13 Wood Shaft, 10 Earth Wax"
recipes["Falco Walker Upgrade Water Tier 1"] := "20 Charcoal, 25 Triple Stitch Fabric, 40 Spearmint"
recipes["Falco Walker Upgrade Water Tier 2"] := "20 Tallow, 25 Triple Stitch Fabric, 40 Spearmint"
recipes["Falco Walker Upgrade Water Tier 3"] := "20 Tallow, 25 Triple Stitch Fabric, 40 Spearmint"
recipes["Falco Walker Upgrade Water Tier 4"] := "20 Tallow, 25 Triple Stitch Fabric, 40 Spearmint"
recipes["Domus Walker Wings (1 of 2)"] := "1 Capital Walker Wing"
recipes["Domus Walker Wings Heavy (1 of 2)"] := "1 Improved Capital Walker Wing"
recipes["Domus Walker Wings Large (1 of 2)"] := "1 Flotillan Capital Walker Wing"
recipes["Domus Walker Wings Medium (1 of 2)"] := "1 Advanced Capital Walker Wing"
recipes["Domus Walker Wings Raider (1 of 2)"] := "1 Advanced Capital Walker Wing"
recipes["Domus Walker Wings Rugged (1 of 2)"] := "1 Advanced Capital Walker Wing"
recipes["Domus Walker Wings Skirmish (1 of 2)"] := "1 Improved Capital Walker Wing"
recipes["Domus Walker Wings Small (1 of 2)"] := "1 Improved Capital Walker Wing"
recipes["Door"] := "3 Wooden Slab, 14 Fiber"
recipes["Double Slit Wall"] := "2 Wooden Slab, 14 Fiber"
recipes["Drill Spade"] := "18 Wood, 8 Wood Shaft, 1 Rope, 1 Wooden Gear"
recipes["Firefly Walker Upgrade Cargo Tier 1"] := "20 Wood, 15 Fiber"
recipes["Firefly Walker Upgrade Cargo Tier 2"] := "15 Fiber, 20 Wood"
recipes["Firefly Walker Upgrade Cargo Tier 3"] := "20 Wood, 15 Fiber, 10 Stone"
recipes["Firefly Walker Upgrade Cargo Tier 4"] := "20 Wood, 15 Fiber, 10 Stone"
recipes["Firefly Walker Upgrade Durability Tier 1"] := "3 Wood Shaft, 15 Stone"
recipes["Firefly Walker Upgrade Durability Tier 2"] := "3 Wood Shaft, 8 Hide, 15 Stone"
recipes["Firefly Walker Upgrade Durability Tier 3"] := "3 Wood Shaft, 8 Hide, 15 Stone"
recipes["Firefly Walker Upgrade Durability Tier 4"] := "3 Wood Shaft, 8 Hide, 15 Stone"
recipes["Firefly Walker Upgrade Gear Tier 1"] := "2 Fiber Weave, 4 Wooden Slab"
recipes["Firefly Walker Upgrade Gear Tier 2"] := "2 Fiber Weave, 4 Wooden Slab"
recipes["Firefly Walker Upgrade Gear Tier 3"] := "4 Wooden Slab, 22 Wood"
recipes["Firefly Walker Upgrade Gear Tier 4"] := "2 Fiber Weave, 4 Wooden Slab"
recipes["Firefly Walker Upgrade Mobility Tier 2"] := "20 Palm Leaves, 15 Wood Shaft, 35 Wood"
recipes["Firefly Walker Upgrade Mobility Tier 3"] := "20 Palm Leaves, 15 Wood Shaft, 35 Wood"
recipes["Firefly Walker Upgrade Mobility Tier 4"] := "20 Palm Leaves, 15 Wood Shaft, 35 Wood"
recipes["Firefly Walker Upgrade Water Tier 1"] := "20 Wood, 3 Rupu Pelt"
recipes["Firefly Walker Upgrade Water Tier 2"] := "25 Fiber, 3 Rupu Pelt, 20 Wood"
recipes["Firefly Walker Upgrade Water Tier 3"] := "3 Rupu Pelt, 20 Wood, 25 Fiber"
recipes["Firefly Walker Upgrade Water Tier 4"] := "3 Rupu Pelt, 25 Fiber, 20 Wood"
recipes["Falco Walker Legs (1 of 2)"] := "1 Large Walker Leg"
recipes["Falco Walker Legs Armored (1 of 2)"] := "1 Armored Large Walker Leg"
recipes["Falco Walker Legs Heavy (1 of 2)"] := "1 Heavy Large Walker Leg"
recipes["Falco Walker Wings (1 of 2)"] := "1 Large Walker Wing"
recipes["Falco Walker Wings Heavy (1 of 2)"] := "1 Improved Large Walker Wing"
recipes["Falco Walker Wings Large (1 of 2)"] := "1 Flotillan Large Walker Wing"
recipes["Falco Walker Wings Medium (1 of 2)"] := "1 WalkerWingAdvanced_T3"
recipes["Falco Walker Wings Raider (1 of 2)"] := "1 WalkerWingAdvanced_T3"
recipes["Falco Walker Wings Rugged (1 of 2)"] := "1 WalkerWingAdvanced_T3"
recipes["Falco Walker Wings Skirmish (1 of 2)"] := "1 Improved Large Walker Wing"
recipes["Falco Walker Wings Small (1 of 2)"] := "1 Improved Large Walker Wing"
recipes["Firefly Walker Legs (1 of 2)"] := "5 Wood, 2 Wood Shaft"
recipes["Firefly Walker Wings (1 of 2)"] := "12 Wood Shaft, 7 Fiber Weave, 4 Rupu Vine"
recipes["Firefly Walker"] := "85 Wood, 46 Fiber, 25 Stone, 22 Wood Shaft, 18 Rupu Vine"
recipes["Firestone Axe"] := "6 Obsidian, 3 Rope, 4 Wood Shaft, 1 Clay"
recipes["Firestone Battleaxe"] := "2 Leather, 6 Obsidian, 3 Chitin Plate"
recipes["Firestone Bladestaff"] := "6 Obsidian, 4 Rope, 2 Bone Glue"
recipes["Firestone Bludgeon"] := "6 Obsidian, 4 Wood Shaft, 3 Fiber Weave"
recipes["Firestone Bozdogan"] := "6 Obsidian, 3 Triple Stitch Fabric, 8 Rope"
recipes["Firestone Hammerstaff"] := "6 Obsidian, 3 Rope, 6 Wood Shaft"
recipes["Firestone Kopesh"] := "6 Rope, 3 Obsidian, 12 Bone Splinter"
recipes["Firestone Longblade"] := "6 Obsidian, 8 Rope, 10 Triple Stitch Fabric"
recipes["Flag 1"] := "5 Wood Shaft, 5 Fiber Weave"
recipes["Flag 2"] := "5 Wood Shaft, 5 Fiber Weave"
recipes["Flag 3"] := "5 Wood Shaft, 5 Fiber Weave"
recipes["Flag 4"] := "5 Wood Shaft, 5 Fiber Weave"
recipes["Flag 5"] := "5 Wood Shaft, 5 Fiber Weave"
recipes["Flag 6"] := "5 Wood Shaft, 5 Fiber Weave"
recipes["Flag 7"] := "5 Wood Shaft, 5 Fiber Weave"
recipes["Flint Harpoon"] := "1 Flint Bolt, 2 Hide, 5 Rupu Vine"
recipes["Flint Harpoon"] := "1 Flint Bolt, 2 Hide, 5 Rupu Vine"
recipes["Flint Harpoon"] := "1 Flint Bolt, 2 Hide, 5 Rupu Vine"
recipes["Flare - white"] := "5 Charcoal, 5 Cattail"
recipes["Flint Bolt"] := "3 Wood Shaft, 9 Stone"
recipes["Flint Bolt"] := "3 Wood Shaft, 9 Stone"
recipes["Flint Bolt"] := "3 Wood Shaft, 9 Stone"
recipes["Floating Mine"] := "8 Wood Shaft, 12 Lava Fuel"
recipes["Forester's Armor"] := "1 Nomad Cloth, 6 Rope"
recipes["Forester's Armor"] := "1 Nomad Cloth, 6 Rope"
recipes["Floor / Roof"] := "2 Wooden Slab, 14 Fiber"
recipes["Flotillian Stomping Station"] := "120 Lightwood, 100 Stone, 35 Wood Shaft, 5 Iron Ore, 30 Rope"
recipes["Foraging Pouch"] := "28 Fiber"
recipes["Flotillan Grappling Hook"] := "8 Ceramic Shard, 17 Wood Shaft, 5 Leather"
recipes["Forager Walker Module"] := "1 Spline, 1 Strut, 1 Cog"
recipes["Flotillan Capital Walker Wing"] := "18 Worm Silk, 30 Lightwood, 12 Nibiran Ingot"
recipes["Flotillan Large Walker Wing"] := "32 Nomad Cloth, 35 Lightwood, 28 Hollowbone"
recipes["Flotillan Medium Walker Wing"] := "25 Nomad Cloth, 30 Redwood Wood, 28 Iron Ore"
recipes["Hullbreaker Scattershot"] := "5 Iron Ore, 8 Tar, 12 Sulfur, 8 Fiber Weave"
recipes["Forester's Sandals"] := "18 Cattail, 8 Fiber Weave"
recipes["Forester's Sandals"] := "18 Cattail, 8 Fiber Weave"
recipes["Forester's Sleeves"] := "18 Cattail, 5 Earth Wax"
recipes["Forester's Sleeves"] := "18 Cattail, 5 Earth Wax"
recipes["Furnace"] := "12 Rope, 25 Wood Shaft, 120 Clay, 14 Nomad Cloth, 40 Leather"
recipes["Fortress Walker Module"] := "1 Spring, 1 Lever, 1 Cog"
recipes["Foundation"] := "3 Wooden Slab, 14 Fiber"
recipes["Fruit Pulp"] := "1 Apple"
recipes["Fruit Pulp"] := "1 Apple"
recipes["Fruit Pulp"] := "1 Apple"
recipes["Fruit Pulp"] := "6 Corn"
recipes["Fruit Pulp"] := "5 Corn"
recipes["Fruit Pulp"] := "4 Corn"
recipes["Fruit Pulp"] := "1 Blood Turnip"
recipes["Fruit Pulp"] := "1 Blood Turnip"
recipes["Fruit Pulp"] := "1 Blood Turnip"
recipes["Fruit Pulp"] := "1 Huge Cactus Fruit"
recipes["Fruit Pulp"] := "1 Huge Cactus Fruit"
recipes["Fruit Pulp"] := "1 Huge Cactus Fruit"
recipes["Fruit Pulp"] := "1 Thornberry"
recipes["Fruit Pulp"] := "1 Thornberry"
recipes["Fruit Pulp"] := "1 Thornberry"
recipes["Fruit Pulp"] := "5 Cactus Flesh"
recipes["Fruit Pulp"] := "4 Cactus Flesh"
recipes["Fruit Pulp"] := "3 Cactus Flesh"
recipes["Green Death Bomb"] := "1 Cotton, 3 Gelatinous Goo, 2 Tallow, 8 Mushroom Flesh"
recipes["Hardened Hellfire Bolt"] := "1 Hellfire Bolt, 2 Worm Oil, 3 Tar"
recipes["Gas Mask"] := "1 Nomad Cloth, 6 Charcoal, 4 Hide, 8 Aloe Gel"
recipes["Gas Mask"] := "1 Nomad Cloth, 6 Charcoal, 4 Hide, 8 Aloe Gel"
recipes["Gigantic Chest"] := "25 Iron Ingot, 85 Stone, 110 Fiber"
recipes["Giant Wall"] := "9 Bent Wooden Planks, 50 Stone, 12 Wood Shaft"
recipes["Giant Wall Gate"] := "50 Bent Wooden Planks, 30 Obsidian, 45 Wood Shaft"
recipes["Giant Wall Packer"] := "85 Redwood Wood, 10 Reinforced Plank, 55 Rope"
recipes["Heavy Backpack"] := "5 Worm Silk, 14 Nomad Cloth"
recipes["Human Sling"] := "91 Wood, 15 Fiber Weave, 20 Wood Shaft"
recipes["Humidity"] := "1 Charcoal"
recipes["Humidity"] := "1 Purified Water"
recipes["Hornet Walker Upgrade Durability Tier 1"] := "22 Ceramic Shard, 17 Tar, 38 Rupu Pelt"
recipes["Hornet Walker Upgrade Durability Tier 2"] := "22 Ceramic Shard, 38 Rupu Pelt, 17 Tar"
recipes["Hornet Walker Upgrade Durability Tier 3"] := "22 Ceramic Shard, 17 Tar, 38 Rupu Pelt"
recipes["Hornet Walker Upgrade Durability Tier 4"] := "22 Ceramic Shard, 17 Tar, 38 Rupu Pelt"
recipes["Hornet Walker Upgrade Gear Tier 1"] := "17 Triple Stitch Fabric, 32 Cotton, 36 Wood Shaft"
recipes["Hornet Walker Upgrade Gear Tier 2"] := "17 Triple Stitch Fabric, 32 Cotton, 36 Wood Shaft"
recipes["Hornet Walker Upgrade Gear Tier 3"] := "17 Triple Stitch Fabric, 32 Cotton, 36 Wood Shaft"
recipes["Hornet Walker Upgrade Gear Tier 4"] := "17 Triple Stitch Fabric, 32 Cotton, 36 Wood Shaft"
recipes["Hornet Walker Upgrade Mobility Tier 1"] := "12 Reinforced Gear, 32 Wood Shaft, 24 Tallow"
recipes["Hornet Walker Upgrade Mobility Tier 2"] := "12 Reinforced Gear, 24 Tallow, 32 Wood Shaft"
recipes["Hornet Walker Upgrade Mobility Tier 3"] := "12 Reinforced Gear, 24 Tallow, 32 Wood Shaft"
recipes["Hornet Walker Upgrade Mobility Tier 4"] := "24 Reinforced Gear, 23 Tallow"
recipes["Hornet Walker Upgrade Torque Tier 1"] := "5 Rope, 8 Earth Wax"
recipes["Hornet Walker Upgrade Torque Tier 2"] := "13 Wood Shaft, 8 Earth Wax, 5 Rope"
recipes["Hornet Walker Upgrade Torque Tier 3"] := "13 Wood Shaft, 5 Rope, 8 Earth Wax"
recipes["Hornet Walker Upgrade Torque Tier 4"] := "5 Rope, 13 Wood Shaft, 8 Earth Wax"
recipes["Hornet Walker Upgrade Water Tier 1"] := "8 Leather, 40 Clay, 3 Gelatinous Goo"
recipes["Hornet Walker Upgrade Water Tier 2"] := "8 Leather, 40 Clay, 3 Gelatinous Goo"
recipes["Hornet Walker Upgrade Water Tier 3"] := "40 Clay, 8 Wood, 3 Gelatinous Goo"
recipes["Hornet Walker Upgrade Water Tier 4"] := "8 Wood, 40 Clay, 3 Gelatinous Goo"
recipes["Hornet Walker Wings (1 of 2)"] := "1 Large Walker Wing"
recipes["Hornet Walker Wings Heavy (1 of 2)"] := "1 Improved Large Walker Wing"
recipes["Hornet Walker Wings Large (1 of 2)"] := "1 Flotillan Large Walker Wing"
recipes["Hornet Walker Wings Medium (1 of 2)"] := "1 WalkerWingAdvanced_T3"
recipes["Hornet Walker Wings Raider (1 of 2)"] := "1 WalkerWingAdvanced_T3"
recipes["Hornet Walker Wings Rugged (1 of 2)"] := "1 WalkerWingAdvanced_T3"
recipes["Hornet Walker Wings Skirmish (1 of 2)"] := "1 Improved Large Walker Wing"
recipes["Hornet Walker Wings Small (1 of 2)"] := "1 Improved Large Walker Wing"
recipes["Hose Station"] := "134 Wood, 38 Stone, 80 Fiber, 40 Purified Water"
recipes["Improved Capital Walker Wing"] := "35 Lightwood, 25 Iron Ore, 17 Nomad Cloth"
recipes["Improved Large Walker Wing"] := "22 Nomad Cloth, 28 Redwood Wood, 18 Ceramic Shard"
recipes["Improved Medium Walker Wing"] := "25 Wood Shaft, 18 Triple Stitch Fabric, 12 Bone Splinter"
recipes["Iron Dart"] := "3 Wood Shaft, 2 Fiber Weave, 1 Iron Ingot, 6 Lightwood"
recipes["Iron-Tipped Bolt"] := "8 Wood Shaft, 1 Iron Ingot, 8 Lightwood"
recipes["Iron Studded Armor"] := "35 Bone Glue, 15 Iron Ingot, 30 Nomad Cloth"
recipes["Iron Ore"] := "1 Terrain: Asteroid Crash Site, 5 Animal Fat"
recipes["Improved Small Walker Wing"] := "25 Wood Shaft, 22 Fiber Weave, 15 Rope"
recipes["Iron Rok"] := "100 Stone, 8 Tar, 1 Iron Ingot, 12 Lightwood"
recipes["Iron Studded Boots"] := "10 Bone Glue, 5 Iron Ingot, 15 Nomad Cloth"
recipes["Iron Studded Gauntlets"] := "10 Bone Glue, 5 Iron Ingot, 15 Nomad Cloth"
recipes["Large Base Walker Packer"] := "150 Wood, 6 Bone Glue, 60 Rope, 35 Wood Shaft"
recipes["Improvised Bottle"] := "1 Huge Cactus Fruit, 20 Fiber, 2 Hide"
recipes["Iron Ingot"] := "1 Iron Ore"
recipes["Insect Bomb"] := "6 Insects, 3 Cotton, 6 Beeswax, 2 Rope"
recipes["Large Chest"] := "12 Rope, 50 Wood, 10 Ceramic Shard"
recipes["Infused Obsidian Bottle"] := "28 Obsidian, 4 Bone Glue"
recipes["Iron Gear"] := "50 Redwood Wood, 10 Tree Sap, 10 Iron Ore"
recipes["Infused Pickaxe"] := "4 Nibiran Ingot, 35 Wood Shaft, 4 Nomad Cloth"
recipes["Infused Repair Hammer"] := "10 Wood Shaft, 55 Stone, 3 Nibiran Ingot"
recipes["Infused Scythe"] := "14 Wood Shaft, 10 Bone Splinter, 2 Nomad Cloth, 8 Stone, 2 Nibiran Ingot"
recipes["Iron-Tipped Harpoon"] := "1 Iron-Tipped Bolt, 2 Hide, 10 Rope"
recipes["Iron Nails"] := "1 Iron Ingot"
recipes["Iron Pickaxe"] := "3 Iron Ingot, 28 Wood Shaft, 1 Nomad Cloth"
recipes["Iron Repair Hammer"] := "28 Wood Shaft, 5 Iron Ingot, 12 Leather"
recipes["Iron Scythe"] := "14 Wood Shaft, 10 Rope, 4 Nomad Cloth, 4 Iron Ingot"
recipes["Large Gathering Pouch"] := "8 Fiber Weave, 3 Beeswax"
recipes["Large Gathering Pouch"] := "8 Fiber Weave, 3 Beeswax"
recipes["Gate 1"] := "50 Wood, 10 Rupu Vine, 60 Fiber"
recipes["Haysludge Arch"] := "50 Wood, 30 Fiber"
recipes["Haysludge Fence"] := "20 Wood, 20 Fiber"
recipes["Lamp Double Hanging"] := "20 Wood, 3 Stone, 5 Animal Fat"
recipes["Lamp Overhanging"] := "25 Wood, 4 Stone, 12 Animal Fat"
recipes["Lamp Single Hanging"] := "20 Wood, 3 Stone, 12 Animal Fat"
recipes["Lamp Standing"] := "10 Wood, 2 Stone, 8 Animal Fat"
recipes["Grappling Belt Charging Station"] := "3 Nomad Cloth, 22 Rupu Vine, 60 Stone, 150 Wood"
recipes["Hammock"] := "30 Wood, 35 Fiber Weave, 46 Wood Shaft, 12 Rupu Pelt"
recipes["Glass"] := "3 Sand"
recipes["Glass"] := "2 Sand"
recipes["Hardening Walker Module"] := "1 Spline, 1 Strut, 1 Shackle"
recipes["Harpoon Protection Walker Module"] := "1 Spring, 1 Shackle, 1 Cog"
recipes["Hearth Walker Module"] := "1 Lever, 1 Spline, 1 Strut"
recipes["Dinghy Walker Upgrade Cargo Tier 4"] := "30 Wood Shaft, 20 Fiber Weave, 10 Stone"
recipes["Dinghy Walker Upgrade Durability Tier 1"] := "12 Wood, 5 Wood Shaft"
recipes["Dinghy Walker Upgrade Durability Tier 2"] := "5 Wood Shaft, 40 Stone, 8 Hide, 12 Wood"
recipes["Dinghy Walker Upgrade Durability Tier 3"] := "5 Wood Shaft, 8 Hide, 40 Stone, 12 Wood"
recipes["Dinghy Walker Upgrade Durability Tier 4"] := "5 Wood Shaft, 8 Hide, 40 Stone, 12 Wood"
recipes["Dinghy Walker Upgrade Gear Tier 1"] := "18 Fiber Weave, 30 Wood Shaft"
recipes["Dinghy Walker Upgrade Gear Tier 2"] := "18 Fiber Weave, 30 Wood Shaft"
recipes["Dinghy Walker Upgrade Gear Tier 3"] := "10 Stone, 18 Fiber Weave, 30 Wood Shaft"
recipes["Dinghy Walker Upgrade Gear Tier 4"] := "10 Stone, 18 Fiber Weave, 30 Wood Shaft"
recipes["Dinghy Walker Upgrade Mobility Tier 2"] := "20 Palm Leaves, 15 Wood Shaft, 35 Wood"
recipes["Dinghy Walker Upgrade Mobility Tier 3"] := "20 Palm Leaves, 15 Wood Shaft, 35 Wood"
recipes["Dinghy Walker Upgrade Mobility Tier 4"] := "20 Palm Leaves, 15 Wood Shaft, 35 Wood"
recipes["Dinghy Walker Upgrade Torque Tier 1"] := "12 Rupu Vine"
recipes["Dinghy Walker Upgrade Torque Tier 2"] := "8 Wood Shaft, 32 Wood, 12 Rupu Vine"
recipes["Dinghy Walker Upgrade Torque Tier 3"] := "12 Rupu Vine, 8 Wood Shaft, 32 Wood"
recipes["Dinghy Walker Upgrade Torque Tier 4"] := "32 Wood, 8 Wood Shaft, 12 Rupu Vine"
recipes["Dinghy Walker Upgrade Water Tier 1"] := "30 Wood Shaft, 25 Fiber Weave"
recipes["Dinghy Walker Upgrade Water Tier 2"] := "30 Wood Shaft, 5 Rupu Pelt, 25 Fiber Weave"
recipes["Dinghy Walker Upgrade Water Tier 3"] := "5 Rupu Pelt, 30 Wood Shaft, 25 Fiber Weave"
recipes["Dinghy Walker Upgrade Water Tier 4"] := "30 Wood Shaft, 25 Fiber Weave, 5 Rupu Pelt"
recipes["Domus Walker Upgrade Cargo Tier 1"] := "75 Lightwood, 50 Rubber Block, 25 Iron Ore"
recipes["Domus Walker Upgrade Cargo Tier 2"] := "75 Lightwood, 50 Rubber Block, 25 Iron Ore"
recipes["Domus Walker Upgrade Cargo Tier 3"] := "75 Lightwood, 50 Rubber Block, 25 Iron Ore"
recipes["Domus Walker Upgrade Cargo Tier 4"] := "75 Lightwood, 50 Rubber Block, 25 Iron Ore"
recipes["Domus Walker Upgrade Durability Tier 1"] := "55 Iron Ore, 34 Shardrock, 38 Rubber Block, 24 Worm Scale"
recipes["Domus Walker Upgrade Durability Tier 2"] := "55 Iron Ore, 34 Shardrock, 38 Rubber Block, 24 Worm Scale"
recipes["Domus Walker Upgrade Durability Tier 3"] := "55 Iron Ore, 34 Shardrock, 38 Rubber Block, 24 Worm Scale"
recipes["Domus Walker Upgrade Durability Tier 4"] := "55 Iron Ore, 34 Shardrock, 38 Rubber Block, 24 Worm Scale"
recipes["Domus Walker Upgrade Gear Tier 1"] := "14 Reinforced Plank, 45 Lightwood, 45 Nomad Cloth"
recipes["Domus Walker Upgrade Gear Tier 2"] := "14 Reinforced Plank, 45 Lightwood, 45 Nomad Cloth"
recipes["Domus Walker Upgrade Gear Tier 3"] := "45 Nomad Cloth, 14 Reinforced Plank, 45 Lightwood"
recipes["Domus Walker Upgrade Gear Tier 4"] := "45 Nomad Cloth, 14 Reinforced Plank, 45 Lightwood"
recipes["Domus Walker Upgrade Mobility Tier 1"] := "6 Iron Gear, 38 Rubber Block, 23 Shardrock"
recipes["Domus Walker Upgrade Mobility Tier 2"] := "6 Iron Gear, 38 Rubber Block, 23 Shardrock"
recipes["Domus Walker Upgrade Mobility Tier 3"] := "6 Iron Gear, 38 Rubber Block, 23 Shardrock"
recipes["Fury Fumes"] := "1 Gelatinous Goo, 6 Aloe Gel, 3 Blood Turnip, 1 Glass"
recipes["Fury Fumes"] := "1 Gelatinous Goo, 6 Aloe Gel, 3 Blood Turnip, 1 Glass"
recipes["Hangar Gate"] := "12 Wood, 2 Rope, 12 Wood Shaft"
recipes["Hangar Roof"] := "40 Wood, 12 Fiber Weave"
recipes["Hangar Wall"] := "40 Wood, 6 Rope, 8 Wood Shaft"
recipes["Hangar Wall with Door"] := "40 Wood, 18 Rope, 4 Wood Shaft"
recipes["Heavy Capital Walker Leg"] := "16 Worm Scale, 12 Iron Ingot, 25 Lightwood"
recipes["Heavy Large Walker Leg"] := "18 Ceramic Shard, 30 Redwood Wood, 5 Gelatinous Goo"
recipes["Heavy Medium Walker Leg"] := "12 Ceramic Shard, 25 Redwood Wood, 22 Animal Fat"
recipes["Gun Pod"] := "27 Wood, 20 Rope, 8 Wooden Gear, 35 Bone Splinter"
recipes["Gun Pod Plating"] := "164 Wood, 12 Obsidian, 37 Bone Splinter"
recipes["Gun Pod Shell"] := "7 Nomad Cloth, 26 Bone Splinter, 89 Wood"
recipes["Gunpod Stinger"] := "15 Wood, 10 Rope, 20 Fiber, 5 Wood Shaft"
recipes["Heavy Javelin"] := "1 Wood Shaft, 1 Ceramic Shard, 5 Rope"
recipes["Heavy Rawbone Hand Axe"] := "3 Wood Shaft, 4 Rope, 1 Nurr Fang"
recipes["Hellfire Bolt"] := "1 Fire Bolt, 5 Tar, 5 Lava Fuel"
recipes["Hercul Walker Upgrade Torque Tier 1"] := "6 Rope"
recipes["Hercul Walker Upgrade Water Tier 3"] := "24 Ceramic Shard, 52 Hide, 45 Wood, 32 Fiber Weave"
recipes["Hercul Walker Upgrade Water Tier 4"] := "44 Fiber Weave, 65 Wood, 62 Hide, 32 Ceramic Shard"
recipes["Hornet Walker Upgrade Cargo Tier 1"] := "32 Fiber Weave, 48 Redwood Wood"
recipes["Hornet Walker Upgrade Cargo Tier 2"] := "32 Fiber Weave, 48 Redwood Wood"
recipes["Hornet Walker Upgrade Cargo Tier 3"] := "32 Fiber Weave, 48 Redwood Wood"
recipes["Hornet Walker Upgrade Cargo Tier 4"] := "48 Redwood Wood, 32 Fiber Weave"
recipes["Jojo Mojo"] := "6 Tree Sap, 6 Aloe Gel, 6 Earth Wax, 1 Glass"
recipes["Jojo Mojo"] := "6 Tree Sap, 6 Aloe Gel, 6 Earth Wax, 1 Glass"
recipes["Buffalo Walker Legs Heavy (1 of 2)"] := "1 Heavy Large Walker Leg"
recipes["Buffalo Walker Wings (1 of 2)"] := "1 Large Walker Wing"
recipes["Buffalo Walker Wings Heavy (1 of 2)"] := "1 Improved Large Walker Wing"
recipes["Dinghy Walker Wings (1 of 2)"] := "1 Small Walker Wing"
recipes["Dinghy Walker Wings Small (1 of 2)"] := "1 Improved Small Walker Wing"
recipes["Domus Walker Legs (1 of 2)"] := "1 Capital Walker Leg"
recipes["Domus Walker Legs Armored (1 of 2)"] := "1 Capital Walker Leg"
recipes["Domus Walker Legs Heavy (1 of 2)"] := "1 Heavy Capital Walker Leg"
recipes["Hercul Walker Legs (1 of 2)"] := "1 Large Walker Leg"
recipes["Hercul Walker Legs Armored (1 of 2)"] := "1 Armored Large Walker Leg"
recipes["Hercul Walker Legs Heavy (1 of 2)"] := "1 Heavy Large Walker Leg"
recipes["Hercul Walker Wings (1 of 2)"] := "1 Large Walker Leg"
recipes["Hercul Walker Wings Heavy (1 of 2)"] := "1 Improved Large Walker Wing"
recipes["Hercul Walker Wings Large (1 of 2)"] := "1 Flotillan Large Walker Wing"
recipes["Hercul Walker Wings Medium (1 of 2)"] := "1 WalkerWingAdvanced_T3"
recipes["Hercul Walker Wings Raider (1 of 2)"] := "1 WalkerWingAdvanced_T3"
recipes["Hercul Walker Wings Rugged (1 of 2)"] := "1 WalkerWingAdvanced_T3"
recipes["Hercul Walker Wings Skirmish (1 of 2)"] := "1 Improved Large Walker Wing"
recipes["Hercul Walker Wings Small (1 of 2)"] := "1 Improved Large Walker Wing"
recipes["Hornet Walker Legs (1 of 2)"] := "1 Large Walker Leg"
recipes["Hornet Walker Legs Armored (1 of 2)"] := "1 Armored Large Walker Leg"
recipes["Hornet Walker Legs Heavy (1 of 2)"] := "1 Heavy Large Walker Leg"
recipes["Large Walker Leg"] := "27 Redwood Wood, 14 Wood Shaft, 18 Earth Wax"
recipes["Kite"] := "200 Wood, 40 Nomad Cloth"
recipes["Buffalo Walker"] := "287 Wooden Slab, 344 Redwood Wood, 190 Rope, 279 Wood Shaft, 327 Stone, 22 Chitin Plate, 87 Earth Wax, 238 Wood, 265 Fiber, 1 Reinforced Gear"
recipes["Domus Walker"] := "4110 Lightwood, 235 Wood Shaft, 1350 Fiber, 140 Rope, 90 Obsidian, 9 Bone Glue, 510 Stone, 1 Iron Gear, 30 Iron Nails"
recipes["Falco Walker"] := "512 Wood, 333 Fiber, 209 Stone, 104 Wooden Slab, 63 Wood Shaft, 96 Rope, 300 Redwood Wood, 79 Chitin Plate, 3 Reinforced Gear"
recipes["Hercul Walker"] := "1580 Wood, 270 Stone, 1200 Fiber, 15 Rope, 38 Wood Shaft, 10 Earth Wax, 1 Reinforced Gear"
recipes["Hornet Walker"] := "1285 Wood, 400 Stone, 550 Fiber, 18 Wooden Slab, 130 Redwood Wood, 42 Rope, 36 Chitin Plate, 82 Rupu Vine, 20 Leather, 55 Bone Splinter, 1 Reinforced Gear"
recipes["Ironblade Quarterstaff"] := "5 Nibiran Ingot, 3 Bone Splinter, 6 Triple Stitch Fabric"
recipes["Jaggertooth Club"] := "16 Stone, 2 Wood Shaft, 15 Rupu Pelt"
recipes["Jaggertooth Maul"] := "8 Stone, 4 Hide, 6 Fiber Weave"
recipes["Jaggertooth Swordclub"] := "4 Wood Shaft, 9 Stone, 2 Charcoal"
recipes["Heavy Wood Battlements"] := "35 Redwood Wood, 5 Iron Ingot, 1 Bone Glue"
recipes["Heavy Wood Corner"] := "35 Redwood Wood, 5 Iron Ingot, 1 Bone Glue"
recipes["Heavy Wood Door"] := "35 Redwood Wood, 5 Iron Ingot, 1 Bone Glue"
recipes["Heavy Wood Double Slit Wall"] := "35 Redwood Wood, 5 Iron Ingot, 1 Bone Glue"
recipes["Heavy Wood Floor / Roof"] := "35 Redwood Wood, 5 Iron Ingot, 1 Bone Glue"
recipes["Heavy Wood Foundation"] := "35 Redwood Wood, 5 Iron Ingot, 1 Bone Glue"
recipes["Heavy Wood Slit Wall"] := "35 Redwood Wood, 5 Iron Ingot, 1 Bone Glue"
recipes["Heavy Wood Wall 1"] := "35 Redwood Wood, 5 Iron Ingot, 1 Bone Glue"
recipes["Heavy Wood Wall 2"] := "35 Redwood Wood, 5 Iron Ingot, 1 Bone Glue"
recipes["Mask and eyepatch"] := "12 Fiber"
recipes["Large Water Bag"] := "5 Earth Wax, 6 Nomad Cloth, 5 Clay, 80 Stone"
recipes["Maintenance Box"] := "15 Wood, 25 Fiber, 8 Stone"
recipes["Maintenance Vault"] := "25 Redwood Wood, 40 Fiber Weave, 85 Clay, 38 Wood Shaft"
recipes["Medium Chest"] := "22 Bone Splinter, 45 Stone, 2 Nomad Cloth, 36 Wood, 16 Wood Shaft"
recipes["Medium Water Bag"] := "2 Nomad Cloth, 90 Fiber, 2 Earth Wax, 15 Stone"
recipes["Lathe"] := "75 Chitin Plate, 4 Wooden Gear, 15 Ceramic Shard, 17 Obsidian, 26 Wood"
recipes["Lumbermill"] := "250 Lightwood, 12 Iron Nails, 2 Iron Gear, 10 Shardrock"
recipes["Light Backpack"] := "4 Rupu Vine, 12 Hide"
recipes["Medium Backpack"] := "4 Rope, 8 Fiber Weave, 1 Bone Glue"
recipes["Medium Backpack"] := "4 Rope, 8 Fiber Weave, 1 Bone Glue"
recipes["Long Grappling Hook"] := "18 Rope, 29 Earth Wax, 15 Wood Shaft"
recipes["Lava Fuel"] := "17 Lava, 8 Corn, 5 Purified Water"
recipes["Leather"] := "2 Hide, 10 Salt Rock"
recipes["Large Walker Wing"] := "15 Nomad Cloth, 25 Redwood Wood"
recipes["Penetrating Dart"] := "5 Wood Shaft, 3 Fiber Weave, 10 Stone"
recipes["Penetrating Dart"] := "5 Wood Shaft, 3 Fiber Weave, 10 Stone"
recipes["Penetrating Dart"] := "5 Wood Shaft, 3 Fiber Weave, 10 Stone"
recipes["Redwood Armor"] := "25 Redwood Wood, 25 Clay, 5 Nomad Cloth"
recipes["Redwood Boots"] := "2 Nomad Cloth, 15 Redwood Wood, 12 Clay"
recipes["Ruffian mask"] := "12 Fiber"
recipes["Rupu Desolator Armor"] := "25 Fiber, 1 Charcoal"
recipes["Rupu Drudge Armor"] := "25 Fiber, 1 Charcoal"
recipes["Pedestal Chest"] := "24 Fiber, 2 Bone Glue, 40 Wood Shaft"
recipes["Pine Tree"] := "1 Magma Seeds"
recipes["Purification Station"] := "6 Nomad Cloth, 75 Wood, 2 Gelatinous Goo"
recipes["Quarry"] := "300 Lightwood, 3 Iron Gear, 15 Shardrock"
recipes["Podium"] := "30 Wood, 15 Stone"
recipes["Premade Throne"] := "150 Wood, 20 Wood Shaft"
recipes["Rag"] := "1 Rupu Vine, 5 Fiber Weave"
recipes["Roofing 1"] := "5 Wood Shaft, 8 Fiber Weave"
recipes["Roofing 2"] := "5 Wood Shaft, 8 Fiber Weave"
recipes["Rupu Campfire 1"] := "16 Wood, 11 Fiber, 5 Stone"
recipes["Rupu Campfire 2"] := "16 Wood, 11 Fiber, 5 Stone"
recipes["Poaching Hut"] := "1000 Wood, 50 Rope, 100 Nomad Cloth"
recipes["Primitive Bandage"] := "16 Fiber, 1 Ash"
recipes["Proxy License"] := "100 Stone Plank"
recipes["Proxy License"] := "100 Stone Plank"
recipes["Proxy License"] := "100 Stone Plank"
recipes["Rangefinder"] := "30 Wood, 4 Nomad Cloth, 1 Bone Glue"
recipes["Repair Station"] := "125 Wood, 6 Bone Glue, 15 Rope"
recipes["Purified Water"] := "10 Cactus Flesh"
recipes["Purified Water"] := "10 Cactus Flesh"
recipes["Purified Water"] := "1 Fruit Pulp"
recipes["Purified Water"] := "1 Fruit Pulp"
recipes["Purified Water"] := "50 Toxic Water, 6 Charcoal, 25 Sand"
recipes["Purified Water"] := "5 Toxic Water, 1 Charcoal"
recipes["Purified Water"] := "5 Toxic Water, 1 Charcoal"
recipes["Purified Water"] := "3 Thornberry"
recipes["Purified Water"] := "3 Thornberry"
recipes["Purified Water"] := "1 Huge Cactus Fruit"
recipes["Purified Water"] := "1 Huge Cactus Fruit"
recipes["Purified Water"] := "10 Aloe Vera"
recipes["Purified Water"] := "10 Aloe Vera"
recipes["Phosphorus"] := "10 Bone Splinter"
recipes["Phosphorus"] := "10 Bone Splinter"
recipes["Phosphorus"] := "10 Bone Splinter"
recipes["Reinforced Gear"] := "50 Wood, 10 Tree Sap, 10 Ceramic Shard"
recipes["Reinforced Plank"] := "50 Wood, 1 Iron Ingot"
recipes["Reinforced Plank"] := "15 Wood, 1 Iron Ingot"
recipes["Reinforced Plank"] := "1 Wood Log, 2 Iron Ingot"
recipes["Rope"] := "8 Cattail"
recipes["Rope"] := "8 Cattail"
recipes["Rope"] := "800 Cattail"
recipes["Rope"] := "800 Cattail"
recipes["Rope"] := "30 Fiber, 5 Rupu Vine"
recipes["Rope"] := "30 Fiber, 5 Rupu Vine"
recipes["Rubber Block"] := "10 Tree Sap, 20 Sulfur"
recipes["Rig T2"] := "1 Buffalo Walker Rig T2"
recipes["Rig T3"] := "1 Buffalo Walker Rig T3"
recipes["Raptor Walker Upgrade Cargo Tier 1"] := "15 Hollowbone, 32 Iron Nails, 12 Lightwood"
recipes["Raptor Walker Upgrade Cargo Tier 2"] := "15 Hollowbone, 32 Iron Nails, 12 Lightwood"
recipes["Raptor Walker Upgrade Cargo Tier 3"] := "15 Hollowbone, 32 Iron Nails, 12 Lightwood"
recipes["Raptor Walker Upgrade Cargo Tier 4"] := "15 Hollowbone, 32 Iron Nails, 12 Lightwood"
recipes["Raptor Walker Upgrade Durability Tier 1"] := "32 Rubber Block, 12 Lightwood, 15 Hollowbone"
recipes["Raptor Walker Upgrade Durability Tier 2"] := "32 Rubber Block, 12 Lightwood, 15 Hollowbone"
recipes["Raptor Walker Upgrade Durability Tier 3"] := "32 Rubber Block, 12 Lightwood, 15 Hollowbone"
recipes["Raptor Walker Upgrade Durability Tier 4"] := "32 Rubber Block, 12 Lightwood, 15 Hollowbone"
recipes["Raptor Walker Upgrade Gear Tier 1"] := "15 Shardrock, 32 Iron Nails, 12 Lightwood"
recipes["Raptor Walker Upgrade Gear Tier 2"] := "15 Shardrock, 32 Iron Nails, 12 Lightwood"
recipes["Raptor Walker Upgrade Gear Tier 3"] := "15 Shardrock, 32 Iron Nails, 12 Lightwood"
recipes["Raptor Walker Upgrade Gear Tier 4"] := "15 Shardrock, 32 Iron Nails, 12 Lightwood"
recipes["Raptor Walker Upgrade Torque Tier 1"] := "7 Rope, 12 Lightwood, 32 Iron Ore"
recipes["Raptor Walker Upgrade Torque Tier 2"] := "12 Lightwood, 32 Iron Ore, 7 Rope"
recipes["Raptor Walker Upgrade Torque Tier 3"] := "12 Lightwood, 7 Rope, 32 Iron Ore"
recipes["Raptor Walker Upgrade Torque Tier 4"] := "7 Rope, 12 Lightwood, 32 Iron Ore"
recipes["Raptor Walker Upgrade Water Tier 1"] := "15 Rubber Block, 32 Iron Ore, 12 Lightwood"
recipes["Raptor Walker Upgrade Water Tier 2"] := "15 Rubber Block, 32 Iron Ore, 12 Lightwood"
recipes["Raptor Walker Upgrade Water Tier 3"] := "15 Rubber Block, 32 Iron Ore, 12 Lightwood"
recipes["Raptor Walker Upgrade Water Tier 4"] := "15 Rubber Block, 32 Iron Ore, 12 Lightwood"
recipes["Race Dust"] := "6 Nurr Fang, 6 Beeswax, 6 Sulfur, 1 Glass"
recipes["Race Dust"] := "6 Nurr Fang, 6 Beeswax, 6 Sulfur, 1 Glass"
recipes["Panda Walker Wings (1 of 2)"] := "1 Capital Walker Wing"
recipes["Panda Walker Wings Heavy (1 of 2)"] := "1 Improved Capital Walker Wing"
recipes["Panda Walker Wings Large (1 of 2)"] := "1 Flotillan Capital Walker Wing"
recipes["Panda Walker Wings Medium (1 of 2)"] := "1 Advanced Capital Walker Wing"
recipes["Panda Walker Wings Raider (1 of 2)"] := "1 Advanced Capital Walker Wing"
recipes["Panda Walker Wings Rugged (1 of 2)"] := "1 Advanced Capital Walker Wing"
recipes["Panda Walker Wings Skirmish (1 of 2)"] := "1 Improved Capital Walker Wing"
recipes["Panda Walker Wings Small (1 of 2)"] := "1 Improved Capital Walker Wing"
recipes["Proxy Walker Legs (1 of 2)"] := "1 Medium Walker Leg"
recipes["Proxy Walker Legs Armored (1 of 2)"] := "1 Armored Large Walker Leg"
recipes["Proxy Walker Legs Heavy (1 of 2)"] := "1 Heavy Capital Walker Leg"
recipes["Raptor Sky Walker Legs (1 of 2)"] := "35 Lightwood, 70 Fiber, 10 Rope"
recipes["Raptor Sky Walker Wings (1 of 2)"] := "30 Lightwood, 40 Fiber Weave, 25 Earth Wax"
recipes["Proxy Walker"] := "225 Bone Glue, 750 Wood Shaft, 1400 Wood, 300 Nomad Cloth, 150 Rope, 300 Earth Wax, 1 Proxy License"
recipes["Raptor Sky Walker"] := "460 Lightwood, 100 Rupu Vine, 142 Rope, 710 Fiber, 80 Earth Wax, 100 Fiber Weave, 240 Stone, 1 Iron Gear, 10 Iron Nails"
recipes["Rawbone Battle Axe"] := "4 Rope, 6 Tree Sap, 8 Bone Splinter"
recipes["Rawbone Club"] := "6 Bone Splinter, 3 Wood Shaft"
recipes["Rawbone Hand Axe"] := "5 Bone Splinter, 3 Fiber Weave, 4 Wood Shaft"
recipes["Rawbone Maul"] := "4 Wood Shaft, 1 Nurr Fang, 6 Rope"
recipes["Rawbone Quarterstaff"] := "8 Rope, 2 Bone Glue, 7 Wood Shaft"
recipes["Rawbone Sawsword"] := "4 Bone Splinter, 2 Wood Shaft, 8 Rupu Vine"
recipes["Repeater"] := "6 Fiber Weave, 5 Wood Shaft, 25 Wood"
recipes["Rupu Rock"] := "10 Stone, 2 Rupu Pelt"
recipes["Rupu Rock"] := "10 Stone, 2 Rupu Pelt"
recipes["Scattershot Ammo"] := "20 Stone, 4 Fiber Weave"
recipes["Scattershot Ammo"] := "20 Stone, 4 Fiber Weave"
recipes["Scattershot Ammo"] := "20 Stone, 4 Fiber Weave"
recipes["Rupu Dunestalker Armor"] := "25 Fiber, 1 Charcoal"
recipes["Rupu Firebrand Armor"] := "25 Fiber, 1 Charcoal"
recipes["Rupu Forager Armor"] := "25 Fiber, 1 Charcoal"
recipes["Rupu Forerunner Armor"] := "25 Fiber, 1 Charcoal"
recipes["Rupu Fur Armor"] := "8 Rupu Pelt, 2 Fiber Weave, 6 Hide"
recipes["Rupu Fur Sandals"] := "2 Rupu Pelt, 8 Palm Leaves"
recipes["Rupu Fur Sleeves"] := "2 Fiber Weave, 6 Rupu Vine"
recipes["Rupu Harasser Armor"] := "25 Fiber, 1 Charcoal"
recipes["Rupu Hazraki Armor"] := "25 Fiber, 1 Charcoal"
recipes["Rupu Plainstrider Armor"] := "25 Fiber, 1 Charcoal"
recipes["Rupu Prophet Armor"] := "25 Fiber, 1 Charcoal"
recipes["Rupu Sentinel Armor"] := "25 Fiber, 1 Charcoal"
recipes["Rupu Shaman Armor"] := "25 Fiber, 1 Charcoal"
recipes["Rupu Skirmisher Armor"] := "25 Fiber, 1 Charcoal"
recipes["Rupu Thug Armor"] := "25 Fiber, 1 Charcoal"
recipes["Rupu mask"] := "12 Fiber"
recipes["Sand Cloth Door"] := "7 Fiber, 15 Sand, 4 Palm Leaves"
recipes["Sand Sand Foundation"] := "5 Fiber, 10 Sand"
recipes["Sand Sand Ramp"] := "10 Fiber, 20 Sand, 4 Wood Shaft"
recipes["Sand Sandbag Gate"] := "16 Fiber, 8 Wood Shaft, 12 Palm Leaves"
recipes["Sand Sandbag Roof"] := "6 Fiber, 5 Wood, 8 Palm Leaves"
recipes["Sand Sandbag Wall"] := "3 Fiber, 12 Sand, 2 Palm Leaves"
recipes["Sand Sandbag Wall Window"] := "4 Fiber, 12 Sand, 4 Wood Shaft"
recipes["Scroll Rack"] := "40 Wood, 40 Wood Shaft, 24 Fiber, 12 Stone"
recipes["Sharp Spikes"] := "8 Rupu Vine, 50 Wood, 6 Bone Splinter"
recipes["Makeshift Bottle"] := "5 Fiber, 5 Wood, 3 Rupu Pelt"
recipes["Schematic Bag"] := "3 Hide, 10 Fiber, 20 Cattail"
recipes["Masked Totem 1"] := "40 Wood, 30 Fiber"
recipes["Masked Totem 2"] := "40 Wood, 30 Fiber"
recipes["Masked Totem 3"] := "40 Wood, 30 Fiber"
recipes["Meat Rack"] := "20 Wood, 5 Rupu Pelt"
recipes["Segment 1"] := "20 Wood, 25 Fiber"
recipes["Segment 2 (round)"] := "20 Wood, 25 Fiber"
recipes["Segment 3 (round)"] := "20 Wood, 25 Fiber"
recipes["Segment 4 (half)"] := "10 Wood, 12 Fiber"
recipes["Segment 5"] := "20 Wood, 25 Fiber"
recipes["Makeshift Grappling Hook"] := "15 Fiber, 6 Wood"
recipes["Sand Bed"] := "35 Fiber, 8 Wood"
recipes["Sand"] := "1 Terrain: Sand"
recipes["Sand"] := "1 Terrain: Sand"
recipes["Sand"] := "1 Stone"
recipes["Sand"] := "1 Stone"
recipes["Sand"] := "1 Stone"
recipes["Lifeforce Walker Module"] := "1 Spring, 1 Strut, 1 Shackle"
recipes["Lumberjack Walker Module"] := "1 Cog, 1 Lever, 1 Spline"
recipes["Salt Rock"] := "1 Brine"
recipes["Salt Rock"] := "1 Terrain: Salt Flats"
recipes["Sandy Walker Module"] := "1 Spring, 1 Lever, 1 Shackle"
recipes["Scavenger Walker Module"] := "1 Spline, 1 Lever, 1 Shackle"
recipes["Medium Walker Leg"] := "15 Wood Shaft, 26 Wood, 8 Earth Wax"
recipes["Medium Walker Wing"] := "10 Wood Shaft, 15 Triple Stitch Fabric"
recipes["Long Sawblade"] := "280 Wood Shaft, 2000 Wood, 400 Bone Splinter, 5 Iron Ore"
recipes["Light Javelin"] := "1 Wood Shaft, 1 Stone"
recipes["Lobber"] := "7 Wood, 5 Wood Shaft, 13 Bone Splinter, 8 Stone"
recipes["Long Bonespike Swordstaff"] := "1 Nurr Fang, 4 Rope, 6 Wood Shaft"
recipes["Long Ceramic Hoofmace"] := "8 Wood Shaft, 4 Ceramic Shard, 6 Nomad Cloth"
recipes["Medium Stinger"] := "20 Wood, 2 Fiber Weave, 4 Bone Glue, 12 Wood Shaft"
recipes["Light Wood Guard Rail"] := "1 Wooden Slab, 45 Fiber"
recipes["Light Wood Scaffolding"] := "3 Wooden Slab, 45 Fiber"
recipes["Light Wood Walker Gate"] := "38 Wood, 1 Fiber Weave, 11 Stone, 2 Wood Shaft"
recipes["Medium Wood Battlements"] := "3 Wooden Slab, 8 Bone Splinter, 4 Wood Shaft"
recipes["Medium Wood Door"] := "3 Wooden Slab, 8 Bone Splinter, 4 Wood Shaft"
recipes["Medium Wood Double Slit Wall"] := "3 Wooden Slab, 8 Bone Splinter, 4 Wood Shaft"
recipes["Medium Wood Floor / Roof"] := "3 Wooden Slab, 8 Bone Splinter, 4 Wood Shaft"
recipes["Medium Wood Foundation"] := "3 Wooden Slab, 8 Bone Splinter, 4 Wood Shaft"
recipes["Medium Wood Slit Wall"] := "3 Wooden Slab, 8 Bone Splinter, 4 Wood Shaft"
recipes["Medium Wood Wall"] := "3 Wooden Slab, 8 Bone Splinter, 4 Wood Shaft"
recipes["Net"] := "35 Rupu Vine, 10 Stone, 3 Rupu Pelt"
recipes["Net"] := "35 Rupu Vine, 10 Stone, 3 Rupu Pelt"
recipes["Net"] := "35 Rupu Vine, 10 Stone, 3 Rupu Pelt"
recipes["Nibiran-tipped Bolt"] := "8 Wood Shaft, 1 Nibiran Ingot, 8 Lightwood"
recipes["Nibirian Dart"] := "1 Wood Shaft, 2 Fiber Weave, 1 Nibiran Ingot"
recipes["Nibirian Harpoon"] := "1 Nibiran-tipped Bolt, 10 Rope"
recipes["Obsidian Rok"] := "40 Earth Wax, 8 Fiber Weave, 15 Obsidian"
recipes["Nibirian Armor"] := "15 Nibiran Ingot, 30 Worm Silk"
recipes["Nibirian Boots"] := "5 Nibiran Ingot, 15 Worm Silk"
recipes["Nibirian Gauntlets"] := "13 Worm Silk, 5 Nibiran Ingot"
recipes["Ornate veil cap"] := "12 Fiber"
recipes["Obsidian Canister"] := "100 Obsidian, 50 Nomad Cloth, 65 Redwood Wood, 20 Chitin Plate"
recipes["Obsidian Pot"] := "38 Obsidian, 10 Nomad Cloth, 30 Redwood Wood, 20 Rupu Vine"
recipes["Obsidian Machine"] := "36 Obsidian, 12 Redwood Wood, 2 Nomad Cloth"
recipes["Packing Station"] := "18 Rope, 12 Wood Shaft, 60 Wood"
recipes["Net Pouch"] := "4 Nomad Cloth, 25 Earth Wax, 4 Bone Glue"
recipes["Net Pouch"] := "4 Nomad Cloth, 25 Earth Wax, 4 Bone Glue"
recipes["Obsidian Flask"] := "10 Obsidian, 50 Ash, 50 Fiber"
recipes["Ornate banner 1"] := "20 Wood, 10 Fiber Weave"
recipes["Ornate banner 2"] := "20 Wood, 10 Fiber Weave"
recipes["Ornate banner 3"] := "20 Wood, 15 Fiber Weave"
recipes["Nomad Grappling Hook"] := "35 Fiber, 22 Wood, 4 Wood Shaft"
recipes["Mountable Nurr"] := "50 Nurr Fang"
recipes["Okkam Statue 1"] := "300 Stone"
recipes["Okkam Statue 2"] := "300 Stone"
recipes["Merchant Walker Module"] := "1 Spline, 1 Spring, 1 Lever"
recipes["Nibiran Ingot"] := "1 Iron Ingot, 8 Nibiran Mineral, 2 Worm Oil"
recipes["Nomad Cloth"] := "50 Cattail, 1 Bone Glue"
recipes["Nomad Cloth"] := "50 Cattail, 1 Bone Glue"
recipes["Nomad Cloth"] := "12 Cotton, 6 Earth Wax"
recipes["Nomad Cloth"] := "12 Cotton, 6 Earth Wax"
recipes["Pack Mule Walker Module"] := "1 Lever, 1 Shackle, 1 Cog"
recipes["Pack Speed Base Module"] := "1 Spline, 1 Shackle, 1 Cog"
recipes["Pack Speed Walker Module"] := "1 Spline, 1 Shackle, 1 Cog"
recipes["Mollusk Walker Upgrade Cargo Tier 1"] := "24 Bone Splinter, 22 Triple Stitch Fabric, 40 Wood Shaft"
recipes["Mollusk Walker Upgrade Cargo Tier 2"] := "22 Triple Stitch Fabric, 40 Wood Shaft"
recipes["Mollusk Walker Upgrade Cargo Tier 3"] := "24 Bone Splinter, 40 Wood Shaft, 22 Triple Stitch Fabric"
recipes["Mollusk Walker Upgrade Cargo Tier 4"] := "24 Bone Splinter, 22 Triple Stitch Fabric, 40 Wood Shaft"
recipes["Mollusk Walker Upgrade Durability Tier 1"] := "28 Bone Splinter, 24 Fiber Weave, 42 Rupu Pelt"
recipes["Mollusk Walker Upgrade Durability Tier 2"] := "28 Bone Splinter"
recipes["Mollusk Walker Upgrade Durability Tier 3"] := "28 Bone Splinter, 24 Fiber Weave, 42 Rupu Pelt"
recipes["Mollusk Walker Upgrade Durability Tier 4"] := "28 Bone Splinter, 24 Fiber Weave, 42 Rupu Pelt"
recipes["Mollusk Walker Upgrade Gear Tier 1"] := "16 Fiber Weave, 38 Wood Shaft, 13 Bone Splinter"
recipes["Mollusk Walker Upgrade Gear Tier 2"] := "16 Fiber Weave, 38 Wood Shaft"
recipes["Mollusk Walker Upgrade Gear Tier 3"] := "16 Fiber Weave, 38 Wood Shaft, 13 Bone Splinter"
recipes["Mollusk Walker Upgrade Gear Tier 4"] := "16 Fiber Weave, 38 Wood Shaft, 13 Bone Splinter"
recipes["Mollusk Walker Upgrade Mobility Tier 1"] := "14 Bone Splinter, 8 Wood Shaft, 28 Earth Wax"
recipes["Mollusk Walker Upgrade Mobility Tier 2"] := "28 Bone Splinter, 14 Earth Wax, 8 Wood Shaft"
recipes["Mollusk Walker Upgrade Mobility Tier 3"] := "14 Bone Splinter, 28 Earth Wax, 8 Wood Shaft"
recipes["Mollusk Walker Upgrade Mobility Tier 4"] := "14 Bone Splinter, 8 Wood Shaft, 28 Earth Wax"
recipes["Mollusk Walker Upgrade Torque Tier 1"] := "25 Rope, 5 Earth Wax"
recipes["Mollusk Walker Upgrade Torque Tier 2"] := "13 Wood Shaft, 5 Earth Wax, 25 Rope"
recipes["Mollusk Walker Upgrade Torque Tier 3"] := "13 Wood Shaft, 25 Rope, 5 Earth Wax"
recipes["Mollusk Walker Upgrade Torque Tier 4"] := "25 Rope, 13 Wood Shaft, 1 Earth Wax"
recipes["Mollusk Walker Upgrade Water Tier 1"] := "8 Rupu Pelt, 6 Nomad Cloth, 12 Wood Shaft"
recipes["Mollusk Walker Upgrade Water Tier 2"] := "8 Rupu Pelt, 15 Nomad Cloth, 48 Wood Shaft"
recipes["Mollusk Walker Upgrade Water Tier 3"] := "8 Rupu Pelt, 15 Nomad Cloth, 48 Wood Shaft"
recipes["Mollusk Walker Upgrade Water Tier 4"] := "15 Nomad Cloth, 8 Rupu Pelt, 48 Wood Shaft"
recipes["Nomad Walker Upgrade Cargo Tier 2"] := "30 Wood"
recipes["Nomad Walker Upgrade Cargo Tier 3"] := "30 Wood, 10 Stone"
recipes["Nomad Walker Upgrade Cargo Tier 4"] := "30 Wood, 10 Stone"
recipes["Nomad Walker Upgrade Durability Tier 2"] := "40 Stone, 8 Hide, 40 Wood"
recipes["Nomad Walker Upgrade Durability Tier 3"] := "8 Hide, 40 Stone, 40 Wood"
recipes["Nomad Walker Upgrade Durability Tier 4"] := "8 Hide, 40 Stone, 40 Wood"
recipes["Nomad Walker Upgrade Gear Tier 2"] := "22 Wood"
recipes["Nomad Walker Upgrade Gear Tier 3"] := "10 Stone, 22 Wood"
recipes["Nomad Walker Upgrade Gear Tier 4"] := "22 Wood, 10 Stone"
recipes["Nomad Walker Upgrade Mobility Tier 1"] := "20 Stone"
recipes["Nomad Walker Upgrade Mobility Tier 2"] := "20 Stone, 35 Wood"
recipes["Nomad Walker Upgrade Mobility Tier 3"] := "20 Stone, 35 Wood"
recipes["Nomad Walker Upgrade Mobility Tier 4"] := "20 Stone, 35 Wood"
recipes["Nomad Walker Upgrade Water Tier 1"] := "25 Palm Leaves"
recipes["Nomad Walker Upgrade Water Tier 2"] := "25 Palm Leaves, 5 Rupu Pelt, 30 Wood"
recipes["Nomad Walker Upgrade Water Tier 3"] := "5 Rupu Pelt, 30 Wood, 25 Palm Leaves"
recipes["Nomad Walker Upgrade Water Tier 4"] := "30 Wood, 25 Palm Leaves, 5 Rupu Pelt"
recipes["Panda Walker Upgrade Cargo Tier 1"] := "75 Lightwood, 50 Nomad Cloth, 25 Iron Nails"
recipes["Panda Walker Upgrade Cargo Tier 2"] := "75 Lightwood, 50 Nomad Cloth, 25 Iron Nails"
recipes["Panda Walker Upgrade Cargo Tier 3"] := "50 Nomad Cloth, 75 Lightwood, 25 Iron Nails"
recipes["Panda Walker Upgrade Cargo Tier 4"] := "50 Nomad Cloth, 75 Lightwood, 25 Iron Nails"
recipes["Panda Walker Upgrade Durability Tier 1"] := "43 Shardrock, 29 Iron Ingot, 38 Hollowbone"
recipes["Panda Walker Upgrade Durability Tier 2"] := "43 Shardrock, 29 Iron Ingot, 38 Hollowbone"
recipes["Panda Walker Upgrade Durability Tier 3"] := "43 Shardrock, 29 Iron Ingot, 38 Hollowbone"
recipes["Panda Walker Upgrade Durability Tier 4"] := "29 Iron Ingot, 43 Shardrock, 38 Hollowbone"
recipes["Panda Walker Upgrade Gear Tier 1"] := "37 Iron Ore, 24 Reinforced Plank, 8 Hollowbone"
recipes["Panda Walker Upgrade Gear Tier 2"] := "37 Iron Ore, 24 Reinforced Plank, 8 Hollowbone"
recipes["Panda Walker Upgrade Gear Tier 3"] := "37 Iron Ore, 24 Reinforced Plank, 8 Hollowbone"
recipes["Panda Walker Upgrade Gear Tier 4"] := "24 Reinforced Plank, 37 Iron Ore, 8 Hollowbone"
recipes["Panda Walker Upgrade Mobility Tier 1"] := "38 Iron Gear, 88 Wood Shaft, 50 Rubber Block"
recipes["Panda Walker Upgrade Mobility Tier 2"] := "38 Iron Gear, 88 Wood Shaft, 50 Rubber Block"
recipes["Panda Walker Upgrade Mobility Tier 3"] := "38 Iron Gear, 88 Wood Shaft, 50 Rubber Block"
recipes["Panda Walker Upgrade Mobility Tier 4"] := "38 Iron Gear, 88 Wood Shaft, 50 Rubber Block"
recipes["Panda Walker Upgrade Torque Tier 1"] := "22 Tar, 34 Shardrock, 55 Lightwood"
recipes["Panda Walker Upgrade Torque Tier 2"] := "22 Tar, 34 Shardrock, 55 Lightwood"
recipes["Panda Walker Upgrade Torque Tier 3"] := "22 Tar, 34 Shardrock, 55 Lightwood"
recipes["Panda Walker Upgrade Torque Tier 4"] := "22 Tar, 34 Shardrock, 55 Lightwood"
recipes["Panda Walker Upgrade Water Tier 1"] := "25 Eucalyptus Leaf, 44 Leather, 23 Iron Ore"
recipes["Panda Walker Upgrade Water Tier 2"] := "25 Eucalyptus Leaf, 44 Leather, 23 Iron Ore"
recipes["Panda Walker Upgrade Water Tier 3"] := "25 Eucalyptus Leaf, 44 Leather, 23 Iron Ore"
recipes["Panda Walker Upgrade Water Tier 4"] := "25 Eucalyptus Leaf, 44 Leather, 23 Iron Ore"
recipes["Schmetterling Walker Upgrade Cargo Tier 1"] := "75 Lightwood, 50 Hollowbone, 25 Iron Ore"
recipes["Schmetterling Walker Upgrade Cargo Tier 2"] := "75 Lightwood, 50 Hollowbone, 25 Iron Ore"
recipes["Schmetterling Walker Upgrade Cargo Tier 3"] := "75 Lightwood, 50 Hollowbone, 25 Iron Ore"
recipes["Schmetterling Walker Upgrade Cargo Tier 4"] := "75 Lightwood, 50 Hollowbone, 25 Iron Ore"
recipes["Schmetterling Walker Upgrade Durability Tier 1"] := "63 Iron Ingot, 45 Shardrock, 38 Rubber Block"
recipes["Schmetterling Walker Upgrade Durability Tier 2"] := "63 Iron Ingot, 45 Shardrock, 38 Rubber Block"
recipes["Schmetterling Walker Upgrade Durability Tier 3"] := "63 Iron Ingot, 45 Shardrock, 38 Rubber Block"
recipes["Schmetterling Walker Upgrade Durability Tier 4"] := "63 Iron Ingot, 45 Shardrock, 38 Rubber Block"
recipes["Schmetterling Walker Upgrade Gear Tier 1"] := "55 Lightwood, 45 Iron Nails, 20 Nomad Cloth"
recipes["Schmetterling Walker Upgrade Gear Tier 2"] := "55 Lightwood, 45 Iron Nails, 20 Nomad Cloth"
recipes["Schmetterling Walker Upgrade Gear Tier 3"] := "20 Nomad Cloth, 55 Lightwood, 45 Iron Nails"
recipes["Schmetterling Walker Upgrade Gear Tier 4"] := "20 Nomad Cloth, 55 Lightwood, 45 Iron Nails"
recipes["Schmetterling Walker Upgrade Mobility Tier 1"] := "5 Iron Gear, 38 Rubber Block, 24 Reinforced Plank"
recipes["Schmetterling Walker Upgrade Mobility Tier 2"] := "5 Iron Gear, 38 Rubber Block, 24 Reinforced Plank"
recipes["Schmetterling Walker Upgrade Mobility Tier 3"] := "24 Reinforced Plank, 5 Iron Gear, 38 Rubber Block"
recipes["Schmetterling Walker Upgrade Mobility Tier 4"] := "24 Reinforced Plank, 5 Iron Gear, 38 Rubber Block"
recipes["Schmetterling Walker Upgrade Torque Tier 1"] := "25 Tar, 20 Reinforced Plank, 24 Shardrock"
recipes["Schmetterling Walker Upgrade Torque Tier 2"] := "25 Tar, 20 Reinforced Plank, 24 Shardrock"
recipes["Schmetterling Walker Upgrade Torque Tier 3"] := "25 Tar, 20 Reinforced Plank, 24 Shardrock"
recipes["Schmetterling Walker Upgrade Torque Tier 4"] := "20 Reinforced Plank, 25 Tar, 24 Shardrock"
recipes["Schmetterling Walker Upgrade Water Tier 1"] := "15 Rubber Block, 12 Eucalyptus Leaf, 25 Shardrock, 8 Charcoal"
recipes["Schmetterling Walker Upgrade Water Tier 2"] := "15 Rubber Block, 12 Eucalyptus Leaf, 25 Shardrock, 8 Charcoal"
recipes["Schmetterling Walker Upgrade Water Tier 3"] := "15 Rubber Block, 12 Eucalyptus Leaf, 25 Shardrock, 8 Charcoal"
recipes["Schmetterling Walker Upgrade Water Tier 4"] := "15 Rubber Block, 12 Eucalyptus Leaf, 25 Shardrock, 8 Charcoal"
recipes["Mollusk Walker Legs (1 of 2)"] := "1 Medium Walker Leg"
recipes["Mollusk Walker Legs Armored (1 of 2)"] := "1 Armored Medium Walker Leg"
recipes["Mollusk Walker Wings (1 of 2)"] := "1 Medium Walker Wing"
recipes["Mollusk Walker Wings Heavy (1 of 2)"] := "1 Medium Walker Wing"
recipes["Mollusk Walker Wings Medium (1 of 2)"] := "1 Advanced Medium Walker Wing"
recipes["Mollusk Walker Wings Raider (1 of 2)"] := "1 Advanced Medium Walker Wing"
recipes["Mollusk Walker Wings Rugged (1 of 2)"] := "1 Advanced Medium Walker Wing"
recipes["Mollusk Walker Wings Skirmish (1 of 2)"] := "1 Improved Medium Walker Wing"
recipes["Mollusk Walker Wings Small (1 of 2)"] := "1 Improved Medium Walker Wing"
recipes["Panda Walker Legs (1 of 2)"] := "1 Capital Walker Leg"
recipes["Panda Walker Legs Armored (1 of 2)"] := "1 Armored Capital Walker Leg"
recipes["Panda Walker Legs Heavy (1 of 2)"] := "1 Heavy Capital Walker Leg"
recipes["Schmetterling Walker Legs (1 of 2)"] := "1 Capital Walker Leg"
recipes["Schmetterling Walker Legs Armored (1 of 2)"] := "1 Armored Capital Walker Leg"
recipes["Schmetterling Walker Legs Heavy (1 of 2)"] := "1 Armored Capital Walker Leg"
recipes["Schmetterling Walker Wings (1 of 2)"] := "1 Capital Walker Wing"
recipes["Schmetterling Walker Wings Heavy (1 of 2)"] := "0 Improved Capital Walker Wing"
recipes["Schmetterling Walker Wings Large (1 of 2)"] := "1 Flotillan Capital Walker Wing"
recipes["Schmetterling Walker Wings Medium (1 of 2)"] := "1 Advanced Capital Walker Wing"
recipes["Schmetterling Walker Wings Raider (1 of 2)"] := "1 Advanced Capital Walker Wing"
recipes["Schmetterling Walker Wings Rugged (1 of 2)"] := "1 Advanced Capital Walker Wing"
recipes["Schmetterling Walker Wings Skirmish (1 of 2)"] := "1 Improved Capital Walker Wing"
recipes["Schmetterling Walker Wings Small (1 of 2)"] := "1 Improved Capital Walker Wing"
recipes["Sawblade"] := "12 Wood Shaft, 26 Bone Splinter, 20 Rope, 2 Wooden Gear, 4 Wooden Slab, 40 Redwood Wood"
recipes["Mollusk Walker"] := "185 Wood, 7 Rope, 110 Fiber, 57 Stone, 4 Fiber Weave, 1 Wooden Gear"
recipes["Panda Walker"] := "1360 Lightwood, 600 Fiber, 350 Stone, 121 Wood Shaft, 86 Rope, 5 Nomad Cloth, 110 Rupu Vine, 35 Ceramic Shard, 1 Iron Gear, 30 Iron Nails"
recipes["Schmetterling Walker"] := "5177 Lightwood, 225 Wood Shaft, 88 Rope, 1425 Fiber, 7 Bone Glue, 450 Stone, 1 Iron Gear, 30 Iron Nails"
recipes["Net Thrower"] := "60 Wood, 30 Stone, 65 Fiber"
recipes["Nibiran Battle Axe"] := "5 Nibiran Ingot, 6 Rubber Block, 7 Rope"
recipes["Nibiran Curved Dagger"] := "5 Nibiran Ingot, 6 Nomad Cloth, 3 Leather"
recipes["Nibiran Decapitator"] := "5 Nibiran Ingot, 8 Lightwood, 3 Nomad Cloth"
recipes["Nibiran Hammer"] := "5 Nibiran Ingot, 3 Bone Glue, 12 Lightwood"
recipes["Nibiran Hand Axe"] := "5 Nibiran Ingot, 12 Lightwood, 3 Rubber Block"
recipes["Nibiran Quarterstaff"] := "5 Nibiran Ingot, 6 Nomad Cloth, 8 Bone Splinter"
recipes["Nibiran Warhammer"] := "5 Nibiran Ingot, 6 Nomad Cloth, 14 Lightwood"
recipes["Nurrfang Toothclub"] := "1 Nurr Fang, 4 Wood Shaft, 3 Rope"
recipes["Paddleblade Quarterstaff"] := "3 Ceramic Shard, 4 Leather, 6 Redwood Wood"
recipes["Rokker"] := "140 Wood, 60 Stone, 35 Rope, 35 Earth Wax, 20 Fiber Weave, 8 Leather, 85 Ceramic Shard"
recipes["Rupu Sling"] := "50 Rupu Pelt, 3 Rope, 10 Wood"
recipes["Scattershot Gun"] := "24 Wood, 12 Stone, 4 Wood Shaft, 7 Fiber Weave"
recipes["Scythe"] := "14 Wood Shaft, 10 Ceramic Shard, 2 Nomad Cloth, 8 Stone"
recipes["Small Boulder"] := "35 Stone, 10 Fiber Weave"
recipes["Small Boulder"] := "35 Stone, 10 Fiber Weave"
recipes["Small Boulder"] := "35 Stone, 10 Fiber Weave"
recipes["Squared eyepatches"] := "12 Fiber"
recipes["Small Base Walker Packer"] := "370 Wood, 27 Fiber Weave, 10 Stone, 25 Wood Shaft"
recipes["Small Chest"] := "10 Wood, 5 Stone, 15 Fiber"
recipes["Small Water Bag"] := "1 Wood Shaft, 2 Rupu Pelt, 15 Fiber, 4 Hide"
recipes["Soil Excavator"] := "35 Wood, 6 Rope, 3 Nurr Fang, 1 Terrain: Excavatable, 12 Wood Shaft"
recipes["Stairs"] := "20 Wood, 10 Fiber Weave"
recipes["Stairs 1"] := "18 Wood, 22 Fiber, 6 Wood Shaft"
recipes["Stairs 2"] := "12 Wood, 15 Fiber, 4 Wood Shaft"
recipes["Stairs 3"] := "5 Wood, 8 Fiber, 2 Wood Shaft"
recipes["Small Rope Ladder"] := "34 Wood, 10 Stone, 40 Fiber"
recipes["Sterile Bandage"] := "2 Fiber Weave, 1 Aloe Gel"
recipes["Starch Cement"] := "30 Corn, 10 Tree Sap, 5 Salt Rock"
recipes["Simple Pickaxe"] := "2 Fiber Weave, 5 Wood Shaft, 12 Stone, 5 Rupu Vine"
recipes["Simple Repair Hammer"] := "22 Wood, 17 Stone, 15 Rupu Vine"
recipes["Simple Sickle"] := "2 Wood Shaft, 22 Fiber, 8 Stone, 2 Rupu Vine"
recipes["Silur Walker Upgrade Torque Tier 1"] := "1 Compacted Torque Battery, 13 Tallow, 6 Rope"
recipes["Silur Walker Upgrade Torque Tier 2"] := "1 Compacted Torque Battery, 13 Tallow, 6 Rope"
recipes["Silur Walker Upgrade Torque Tier 3"] := "1 Compacted Torque Battery, 6 Rope, 13 Tallow"
recipes["Silur Walker Upgrade Torque Tier 4"] := "1 Compacted Torque Battery, 13 Tallow, 6 Rope"
recipes["Silur Walker Upgrade Water Tier 1"] := "48 Leather, 12 Gelatinous Goo"
recipes["Silur Walker Upgrade Water Tier 2"] := "48 Leather, 12 Gelatinous Goo"
recipes["Silur Walker Upgrade Water Tier 3"] := "48 Leather, 12 Gelatinous Goo"
recipes["Silur Walker Upgrade Water Tier 4"] := "48 Leather, 12 Gelatinous Goo"
recipes["Spider Walker Upgrade Cargo Tier 1"] := "20 Fiber Weave"
recipes["Spider Walker Upgrade Cargo Tier 2"] := "20 Fiber Weave, 30 Wood"
recipes["Spider Walker Upgrade Cargo Tier 3"] := "20 Fiber Weave, 30 Wood, 10 Stone"
recipes["Spider Walker Upgrade Cargo Tier 4"] := "10 Stone, 20 Fiber Weave, 30 Wood"
recipes["Spider Walker Upgrade Durability Tier 2"] := "40 Wood, 8 Hide, 40 Stone"
recipes["Spider Walker Upgrade Durability Tier 3"] := "40 Wood, 40 Stone, 8 Hide"
recipes["Spider Walker Upgrade Durability Tier 4"] := "40 Wood, 40 Stone, 8 Hide"
recipes["Spider Walker Upgrade Gear Tier 1"] := "18 Fiber Weave"
recipes["Spider Walker Upgrade Gear Tier 2"] := "18 Fiber Weave, 22 Wood"
recipes["Spider Walker Upgrade Gear Tier 3"] := "10 Stone, 18 Fiber Weave, 22 Wood"
recipes["Sinus Destroyer"] := "3 Rupu Gel, 6 Lava Poppy, 2 Spearmint, 1 Glass"
recipes["Sinus Destroyer"] := "3 Rupu Gel, 6 Lava Poppy, 2 Spearmint, 1 Glass"
recipes["Silur Walker Legs (1 of 2)"] := "1 Large Walker Leg"
recipes["Silur Walker Legs Armored (1 of 2)"] := "1 Armored Large Walker Leg"
recipes["Silur Walker Legs Heavy (1 of 2)"] := "1 Heavy Large Walker Leg"
recipes["Small Walker Leg"] := "12 Rupu Vine, 5 Wood Shaft"
recipes["Spider Walker Legs (1 of 2)"] := "10 Wood, 12 Fiber"
recipes["Spider Walker Legs Armored (1 of 2)"] := "15 Wood, 18 Fiber"
recipes["Small Repair Hoist"] := "8 Wood Shaft, 3 Bone Splinter, 25 Fiber Weave, 18 Rope, 45 Stone"
recipes["Singblade"] := "6 Redwood Wood, 3 Ceramic Shard, 4 Nomad Cloth"
recipes["Slingshot"] := "125 Wood, 55 Stone, 25 Fiber Weave, 20 Rope"
recipes["Slit Wall"] := "2 Wooden Slab, 14 Fiber"
recipes["Small Scattershot Gun"] := "30 Wood, 45 Stone, 30 Fiber, 6 Earth Wax"
recipes["Small Walker Wing"] := "12 Wood Shaft, 15 Fiber Weave"
recipes["Spider Walker Upgrade Gear Tier 4"] := "10 Stone, 18 Fiber Weave, 22 Wood"
recipes["Spider Walker Upgrade Mobility Tier 2"] := "15 Wood Shaft, 20 Palm Leaves, 35 Wood"
recipes["Spider Walker Upgrade Mobility Tier 3"] := "35 Wood, 15 Wood Shaft, 20 Palm Leaves"
recipes["Spider Walker Upgrade Mobility Tier 4"] := "35 Wood, 15 Wood Shaft, 20 Palm Leaves"
recipes["Spider Walker Upgrade Water Tier 2"] := "25 Fiber, 5 Rupu Pelt, 30 Wood"
recipes["Spider Walker Upgrade Water Tier 3"] := "5 Rupu Pelt, 30 Wood, 25 Fiber"
recipes["Spider Walker Upgrade Water Tier 4"] := "5 Rupu Pelt, 25 Fiber, 30 Wood"
recipes["Stiletto Walker Upgrade Gear Tier 4"] := "13 Bone Splinter, 10 Wood Shaft, 16 Fiber Weave"
recipes["Stiletto Walker Upgrade Mobility Tier 2"] := "14 Bone Splinter, 8 Wood Shaft, 28 Palm Leaves"
recipes["Stiletto Walker Upgrade Mobility Tier 4"] := "14 Bone Splinter, 8 Wood Shaft, 28 Palm Leaves"
recipes["Spinner"] := "8 Wood, 12 Stone, 5 Wood Shaft"
recipes["Split Bone Bottle"] := "7 Bone Splinter, 35 Fiber, 1 Nomad Cloth"
recipes["Split Bone Bottle"] := "7 Bone Splinter, 35 Fiber, 1 Nomad Cloth"
recipes["Split Ceramic Flask"] := "7 Ceramic Shard, 2 Bone Glue, 4 Earth Wax"
recipes["Split Durable Water Sack"] := "12 Iron Ingot, 35 Palm Leaves, 112 Fiber, 15 Beeswax"
recipes["Sulfur Bomb"] := "12 Salt Rock, 18 Earth Wax, 25 Sulfur, 4 Fiber Weave"
recipes["Sulfur Bomb"] := "12 Salt Rock, 18 Earth Wax, 25 Sulfur, 4 Fiber Weave"
recipes["Sunset headdress"] := "12 Fiber"
recipes["Swampwood Galoshes"] := "3 Hide, 8 Tree Sap, 3 Fiber Weave"
recipes["Swampwood Galoshes"] := "3 Hide, 8 Tree Sap, 3 Fiber Weave"
recipes["Swampwood Galoshes"] := "3 Hide, 8 Tree Sap, 3 Fiber Weave"
recipes["Stomping Station"] := "165 Wood, 80 Stone, 28 Wood Shaft, 25 Fiber Weave, 28 Rope"
recipes["Spring Spikes Trap"] := "150 Wood, 8 Bone Splinter, 6 Bone Glue"
recipes["Sturdy Grappling Hook"] := "23 Rope, 15 Beeswax, 11 Triple Stitch Fabric"
recipes["Sturdy Grappling Hook"] := "15 Rope, 8 Beeswax, 12 Tree Sap, 6 Triple Stitch Fabric"
recipes["Stone Humidifier"] := "15 Stone, 8 Wood, 4 Fiber"
recipes["Tallow"] := "5 Animal Fat, 10 Phosphorus"
recipes["Tar"] := "1 Tree Sap"
recipes["Tar"] := "1 Tree Sap"
recipes["Table"] := "300 Stone"
recipes["Structure Hardening Base Module"] := "1 Spline, 1 Strut, 1 Shackle"
recipes["Stone Door"] := "3 Wooden Slab, 10 Stone, 1 Wood Shaft, 3 Tree Sap"
recipes["Stone Floor / Roof"] := "3 Wooden Slab, 10 Stone, 1 Wood Shaft, 3 Tree Sap"
recipes["Stone Foundation"] := "3 Wooden Slab, 10 Stone, 1 Wood Shaft, 3 Tree Sap"
recipes["Stone Wall"] := "3 Wooden Slab, 10 Stone, 1 Wood Shaft, 3 Tree Sap"
recipes["Stone Wall with Window"] := "3 Wooden Slab, 10 Stone, 1 Wood Shaft, 3 Tree Sap"
recipes["Stiletto Walker Upgrade Cargo Tier 1"] := "40 Wood, 22 Fiber, 24 Bone Splinter"
recipes["Stiletto Walker Upgrade Cargo Tier 2"] := "40 Wood, 6 Fiber Weave"
recipes["Stiletto Walker Upgrade Cargo Tier 3"] := "40 Wood, 6 Fiber Weave, 24 Bone Splinter"
recipes["Stiletto Walker Upgrade Cargo Tier 4"] := "40 Wood, 6 Fiber Weave, 24 Bone Splinter"
recipes["Stiletto Walker Upgrade Durability Tier 1"] := "56 Wood, 18 Triple Stitch Fabric, 18 Bone Glue"
recipes["Stiletto Walker Upgrade Durability Tier 2"] := "56 Wood, 18 Triple Stitch Fabric, 18 Bone Glue"
recipes["Stiletto Walker Upgrade Durability Tier 3"] := "56 Wood, 18 Bone Glue, 18 Triple Stitch Fabric"
recipes["Stiletto Walker Upgrade Durability Tier 4"] := "56 Wood, 18 Triple Stitch Fabric, 18 Bone Glue"
recipes["Stiletto Walker Upgrade Gear Tier 1"] := "10 Wood Shaft, 13 Bone Splinter, 16 Fiber Weave"
recipes["Stiletto Walker Upgrade Gear Tier 2"] := "10 Wood Shaft, 16 Fiber Weave"
recipes["Stiletto Walker Upgrade Gear Tier 3"] := "13 Bone Splinter, 16 Fiber Weave, 10 Wood Shaft"
recipes["Stiletto Walker Upgrade Mobility Tier 1"] := "14 Bone Splinter, 8 Wood Shaft, 28 Palm Leaves"
recipes["Stiletto Walker Upgrade Mobility Tier 3"] := "14 Bone Splinter, 8 Wood Shaft, 28 Palm Leaves"
recipes["Stiletto Walker Upgrade Torque Tier 1"] := "7 Earth Wax, 25 Rope"
recipes["Stiletto Walker Upgrade Torque Tier 2"] := "7 Earth Wax, 13 Wood Shaft, 25 Rope"
recipes["Stiletto Walker Upgrade Torque Tier 3"] := "7 Earth Wax, 25 Rope, 13 Wood Shaft"
recipes["Stiletto Walker Upgrade Torque Tier 4"] := "7 Earth Wax, 13 Wood Shaft, 25 Rope"
recipes["Stiletto Walker Upgrade Water Tier 1"] := "28 Fiber Weave, 12 Earth Wax, 24 Hide"
recipes["Stiletto Walker Upgrade Water Tier 2"] := "28 Fiber Weave, 12 Earth Wax"
recipes["Stiletto Walker Upgrade Water Tier 3"] := "24 Hide, 12 Earth Wax, 28 Fiber Weave"
recipes["Stiletto Walker Upgrade Water Tier 4"] := "28 Fiber Weave, 24 Hide, 12 Earth Wax"
recipes["Stiletto Walker Wings (1 of 2)"] := "1 Medium Walker Wing"
recipes["Stiletto Walker Wings Heavy (1 of 2)"] := "1 Improved Medium Walker Wing"
recipes["Stiletto Walker Wings Medium (1 of 2)"] := "1 Advanced Medium Walker Wing"
recipes["Stiletto Walker Wings Raider (1 of 2)"] := "1 Advanced Medium Walker Wing"
recipes["Stiletto Walker Wings Rugged (1 of 2)"] := "1 Advanced Medium Walker Wing"
recipes["Stiletto Walker Wings Skirmish (1 of 2)"] := "1 Improved Medium Walker Wing"
recipes["Stiletto Walker Wings Small (1 of 2)"] := "1 Improved Medium Walker Wing"
recipes["Stinger"] := "4 Wood, 2 Fiber Weave, 8 Fiber, 1 Wood Shaft"
recipes["Stone Axe"] := "8 Stone, 10 Wood, 1 Wood Shaft"
recipes["Tied keffiyeh scarf"] := "12 Fiber"
recipes["Toboggan Walker Upgrade Cargo Tier 1"] := "8 Wooden Slab, 22 Fiber, 30 Bone Splinter"
recipes["Toboggan Walker Upgrade Cargo Tier 2"] := "30 Bone Splinter, 22 Fiber, 8 Wooden Slab"
recipes["Toboggan Walker Upgrade Cargo Tier 3"] := "30 Bone Splinter, 22 Fiber, 8 Wooden Slab"
recipes["Toboggan Walker Upgrade Cargo Tier 4"] := "30 Bone Splinter, 22 Fiber, 8 Wooden Slab"
recipes["Toboggan Walker Upgrade Durability Tier 1"] := "47 Tree Sap, 28 Bone Splinter, 24 Triple Stitch Fabric"
recipes["Toboggan Walker Upgrade Durability Tier 2"] := "28 Bone Splinter, 24 Triple Stitch Fabric, 47 Tree Sap"
recipes["Toboggan Walker Upgrade Durability Tier 3"] := "28 Bone Splinter, 24 Triple Stitch Fabric, 47 Tree Sap"
recipes["Toboggan Walker Upgrade Durability Tier 4"] := "28 Bone Splinter, 24 Triple Stitch Fabric, 47 Tree Sap"
recipes["Toboggan Walker Upgrade Gear Tier 1"] := "45 Wood, 18 Bone Splinter, 16 Fiber Weave"
recipes["Toboggan Walker Upgrade Gear Tier 2"] := "18 Bone Splinter, 45 Wood, 16 Fiber Weave"
recipes["Toboggan Walker Upgrade Gear Tier 3"] := "18 Bone Splinter, 16 Fiber Weave, 45 Wood"
recipes["Toboggan Walker Upgrade Gear Tier 4"] := "18 Bone Splinter, 45 Wood, 16 Fiber Weave"
recipes["Toboggan Walker Upgrade Mobility Tier 1"] := "40 Bone Splinter, 48 Rupu Vine, 3 Wooden Gear"
recipes["Toboggan Walker Upgrade Mobility Tier 2"] := "40 Bone Splinter, 3 Wooden Gear"
recipes["Toboggan Walker Upgrade Mobility Tier 3"] := "40 Bone Splinter, 3 Wooden Gear, 48 Rupu Vine"
recipes["Toboggan Walker Upgrade Mobility Tier 4"] := "40 Bone Splinter, 48 Rupu Vine, 3 Wooden Gear"
recipes["Toboggan Walker Upgrade Torque Tier 1"] := "1 Wooden Gear, 16 Earth Wax, 13 Rope"
recipes["Toboggan Walker Upgrade Torque Tier 2"] := "1 Wooden Gear, 16 Earth Wax, 13 Rope"
recipes["Toboggan Walker Upgrade Torque Tier 3"] := "1 Wooden Gear, 13 Rope, 16 Earth Wax"
recipes["Toboggan Walker Upgrade Torque Tier 4"] := "1 Wooden Gear, 16 Earth Wax, 13 Rope"
recipes["Toboggan Walker Upgrade Water Tier 1"] := "16 Salt Rock, 28 Earth Wax, 30 Leather"
recipes["Toboggan Walker Upgrade Water Tier 2"] := "16 Salt Rock, 30 Leather, 28 Earth Wax"
recipes["Toboggan Walker Upgrade Water Tier 3"] := "30 Leather, 16 Salt Rock, 28 Earth Wax"
recipes["Toboggan Walker Upgrade Water Tier 4"] := "16 Salt Rock, 30 Leather, 28 Earth Wax"
recipes["Titan Walker Wings Raider (1 of 2)"] := "1 Advanced Capital Walker Wing"
recipes["Titan Walker Wings Rugged (1 of 2)"] := "1 Advanced Capital Walker Wing"
recipes["Titan Walker Wings Skirmish (1 of 2)"] := "1 Improved Capital Walker Wing"
recipes["Titan Walker Wings Small (1 of 2)"] := "1 Improved Capital Walker Wing"
recipes["Toboggan Walker Legs (1 of 2)"] := "1 Medium Walker Leg"
recipes["Toboggan Walker Legs Armored (1 of 2)"] := "1 Armored Medium Walker Leg"
recipes["Toboggan Walker Legs Heavy (1 of 2)"] := "1 Heavy Medium Walker Leg"
recipes["Toboggan Walker Wings (1 of 2)"] := "1 Medium Walker Wing"
recipes["Toboggan Walker Wings Heavy (1 of 2)"] := "1 Improved Medium Walker Wing"
recipes["Toboggan Walker Wings Large (1 of 2)"] := "1 Flotillan Medium Walker Wing"
recipes["Toboggan Walker Wings Medium (1 of 2)"] := "1 Advanced Medium Walker Wing"
recipes["Toboggan Walker Wings Raider (1 of 2)"] := "1 Advanced Medium Walker Wing"
recipes["Toboggan Walker Wings Rugged (1 of 2)"] := "1 Advanced Medium Walker Wing"
recipes["Toboggan Walker Wings Skirmish (1 of 2)"] := "1 Improved Medium Walker Wing"
recipes["Toboggan Walker Wings Small (1 of 2)"] := "1 Improved Medium Walker Wing"
recipes["Tool Pod"] := "25 Wooden Slab, 15 Leather, 30 Rope, 24 Wood Shaft"
recipes["Toboggan Walker"] := "310 Wood, 29 Rope, 2 Bone Glue, 12 Wood Shaft, 115 Fiber, 27 Fiber Weave, 24 Leather, 45 Stone, 1 Wooden Gear"
recipes["Winged Helmet"] := "2 Iron Ingot, 5 Worm Silk, 6 Leather, 22 Lightwood"
recipes["Water Condenser"] := "6 Ceramic Shard, 5 Tar, 12 Redwood Wood"
recipes["Windmill"] := "25 Wood, 22 Fiber Weave, 4 Rope, 5 Earth Wax"
recipes["Watery Walker Module"] := "1 Strut, 1 Shackle, 1 Cog"
recipes["Tusker Walker Upgrade Water Tier 1"] := "13 Charcoal, 63 Cotton, 23 Leather"
recipes["Tusker Walker Upgrade Water Tier 2"] := "13 Charcoal, 63 Cotton, 23 Leather"
recipes["Tusker Walker Upgrade Water Tier 3"] := "13 Charcoal, 63 Cotton, 23 Leather"
recipes["Tusker Walker Upgrade Water Tier 4"] := "13 Charcoal, 63 Cotton, 23 Leather"
recipes["Tusker Walker Wings (1 of 2)"] := "1 Large Walker Wing"
recipes["Tusker Walker Wings Heavy (1 of 2)"] := "1 Improved Large Walker Wing"
recipes["Tusker Walker Wings Large (1 of 2)"] := "1 Flotillan Large Walker Wing"
recipes["Tusker Walker Wings Medium (1 of 2)"] := "1 WalkerWingAdvanced_T3"
recipes["Tusker Walker Wings Raider (1 of 2)"] := "1 WalkerWingAdvanced_T3"
recipes["Tusker Walker Wings Rugged (1 of 2)"] := "1 WalkerWingAdvanced_T3"
recipes["Tusker Walker Wings Skirmish (1 of 2)"] := "1 Improved Large Walker Wing"
recipes["Tusker Walker Wings Small (1 of 2)"] := "1 Improved Large Walker Wing"
recipes["Vault"] := "25 Rupu Vine, 10 Wooden Slab, 40 Fiber Weave"
recipes["Vision Powder"] := "3 Huge Cactus Fruit, 5 Purified Water"
recipes["Vision Powder"] := "3 Huge Cactus Fruit, 5 Purified Water"
recipes["Walker Climber"] := "30 Wood, 4 Wood Shaft, 35 Fiber"
recipes["Walker Packing Compartment"] := "400 Wood, 35 Fiber Weave, 20 Rope, 10 Rupu Vine"
recipes["Walker Totem"] := "60 Wood, 35 Fiber"
recipes["Wall"] := "2 Wooden Slab, 14 Fiber"
recipes["Water Circulator"] := "38 Worm Silk, 5 Iron Ingot, 25 Rope"
recipes["Wingsuit"] := "6 Nomad Cloth, 20 Wood Shaft"
recipes["Wingsuit"] := "6 Nomad Cloth, 20 Wood Shaft"
recipes["Wall 1"] := "25 Redwood Wood, 50 Fiber"
recipes["Water Bed"] := "188 Wood, 1 Worm Silk, 15 Purified Water, 8 Wood Shaft"
recipes["Weightless Walker Module"] := "1 Spline, 1 Spring, 1 Strut"
recipes["Wood"] := "1 Wood Log"
recipes["Wood Shaft"] := "2 Wood"
recipes["Wood Shaft"] := "2 Wood"
recipes["Wood Shaft"] := "2 Wood"
recipes["Wood Shaft"] := "800 Wood"
recipes["Wood Shaft"] := "800 Wood"
recipes["Wood Shaft"] := "800 Wood"
recipes["Weapon Shipment"] := "20 Rawbone Quarterstaff, 10 Rawbone Battle Axe, 30 Rawbone Maul, 10 Rawbone Sawsword, 30 Rawbone Club, 40 Rawbone Maul, 10 Bonespike Sword, 50 Rawbone Hand Axe"
recipes["Weapon Shipment"] := "12 Paddleblade Quarterstaff, 8 Ceramic Hatchet, 15 Short Ceramic Hoofmace, 20 Short Malletblade, 18 Long Ceramic Hoofmace, 10 Singblade, 15 Heavy Rawbone Hand Axe, 20 Long Bonespike Swordstaff"
recipes["Wooden Dart"] := "2 Wood Shaft, 3 Fiber, 6 Stone"
recipes["Wooden Dart"] := "2 Wood Shaft, 3 Fiber, 6 Stone"
recipes["Wooden Dart"] := "2 Wood Shaft, 3 Fiber, 6 Stone"
recipes["Triple Stitch Armor"] := "10 Bone Splinter, 12 Triple Stitch Fabric"
recipes["Triple Stitch Armor"] := "10 Bone Splinter, 12 Triple Stitch Fabric"
recipes["Triple Stitch Boots"] := "8 Bone Splinter, 6 Triple Stitch Fabric"
recipes["Triple Stitch Boots"] := "8 Bone Splinter, 6 Triple Stitch Fabric"
recipes["Triple Stitch Bracers"] := "6 Bone Splinter, 4 Triple Stitch Fabric"
recipes["Triple Stitch Bracers"] := "6 Bone Splinter, 4 Triple Stitch Fabric"
recipes["Wrapped keffiyeh scarf"] := "12 Fiber"
recipes["Woodworking Station"] := "35 Wood, 28 Fiber"
recipes["Worm Vivarium"] := "80 Wood, 4 Wood Shaft"
recipes["Trap Door"] := "45 Wood, 4 Wood Shaft, 3 Bone Glue"
recipes["Trip Wire Trap"] := "12 Lava, 4 Rope, 6 Wood Shaft"
recipes["Torque Backpack"] := "22 Rupu Vine, 4 Nomad Cloth, 30 Earth Wax, 85 Wood"
recipes["Torque Backpack"] := "22 Rupu Vine, 4 Nomad Cloth, 30 Earth Wax, 85 Wood"
recipes["Torque Battery"] := "8 Earth Wax, 4 Rope, 6 Bone Splinter"
recipes["Torque Battery"] := "8 Earth Wax, 4 Rope, 6 Bone Splinter"
recipes["Throne"] := "20 Wood, 10 Stone"
recipes["Worshipping Wreath"] := "40 Wood, 30 Fiber"
recipes["Wreath"] := "20 Wood, 10 Fiber Weave"
recipes["Worm Oil"] := "1 Worm Egg"
recipes["Torque Walker Module"] := "1 Strut, 1 Lever, 1 Cog"
recipes["Triple Stitch Fabric"] := "10 Fiber Weave, 10 Tree Sap"
recipes["Triple Stitch Fabric"] := "10 Tree Sap, 15 Cotton"
recipes["Wooden Gear"] := "50 Wood, 10 Tree Sap"
recipes["Wooden Gear"] := "50 Wood, 10 Tree Sap"
recipes["Wooden Slab"] := "10 Wood, 2 Fiber Weave"
recipes["Wooden Slab"] := "10 Wood, 2 Fiber Weave"
recipes["Wooden Slab"] := "10 Wood, 2 Fiber Weave"
recipes["Wooden Slab"] := "100 Wood, 20 Fiber Weave"
recipes["Wooden Slab"] := "100 Wood, 20 Fiber Weave"
recipes["Wooden Slab"] := "100 Wood, 20 Fiber Weave"
recipes["Worm Tincture"] := "100 Worm Sand, 50 Purified Water, 50 Magma Seeds, 1 Worm Fang, 5 Worm Oil"
recipes["Worm Tincture"] := "100 Worm Sand, 100 Corn, 50 Magma Seeds, 1 Worm Fang, 1 Worm Oil"
recipes["Worm Sand"] := "1 Terrain: Worm Sand"
recipes["Worm Sand"] := "1 Terrain: Worm Sand"
recipes["Torch"] := "12 Wood, 9 Fiber, 2 Stone"
recipes["Tube Spade"] := "18 Wood, 12 Fiber, 7 Stone"
recipes["Titan Walker Upgrade Cargo Tier 1"] := "55 Lightwood, 12 Iron Ore, 15 Rubber Block"
recipes["Titan Walker Upgrade Cargo Tier 2"] := "55 Lightwood, 12 Iron Ore, 15 Rubber Block"
recipes["Titan Walker Upgrade Cargo Tier 3"] := "55 Lightwood, 12 Iron Ore, 15 Rubber Block"
recipes["Titan Walker Upgrade Cargo Tier 4"] := "55 Lightwood, 12 Iron Ore, 15 Rubber Block"
recipes["Titan Walker Upgrade Durability Tier 1"] := "50 Iron Ingot, 26 Shardrock, 38 Reinforced Plank"
recipes["Titan Walker Upgrade Durability Tier 2"] := "50 Iron Ingot, 26 Shardrock, 38 Reinforced Plank"
recipes["Titan Walker Upgrade Durability Tier 3"] := "50 Iron Ingot, 26 Shardrock, 38 Reinforced Plank"
recipes["Titan Walker Upgrade Durability Tier 4"] := "50 Iron Ingot, 26 Shardrock, 38 Reinforced Plank"
recipes["Titan Walker Upgrade Gear Tier 1"] := "17 Iron Nails, 45 Lightwood, 55 Triple Stitch Fabric"
recipes["Titan Walker Upgrade Gear Tier 2"] := "17 Iron Nails, 45 Lightwood, 55 Triple Stitch Fabric"
recipes["Titan Walker Upgrade Gear Tier 3"] := "17 Iron Nails, 45 Lightwood, 55 Triple Stitch Fabric"
recipes["Titan Walker Upgrade Gear Tier 4"] := "17 Iron Nails, 45 Lightwood, 55 Triple Stitch Fabric"
recipes["Titan Walker Upgrade Mobility Tier 1"] := "23 Hollowbone, 25 Shardrock, 3 Iron Gear"
recipes["Titan Walker Upgrade Mobility Tier 2"] := "23 Hollowbone, 25 Shardrock, 3 Iron Gear"
recipes["Titan Walker Upgrade Mobility Tier 3"] := "23 Hollowbone, 25 Shardrock, 3 Iron Gear"
recipes["Titan Walker Upgrade Mobility Tier 4"] := "23 Hollowbone, 25 Shardrock, 3 Iron Gear"
recipes["Titan Walker Upgrade Torque Tier 1"] := "25 Tar, 20 Reinforced Plank, 12 Hollowbone"
recipes["Titan Walker Upgrade Torque Tier 2"] := "25 Tar, 20 Reinforced Plank, 12 Hollowbone"
recipes["Titan Walker Upgrade Torque Tier 3"] := "25 Tar, 20 Reinforced Plank, 12 Hollowbone"
recipes["Titan Walker Upgrade Torque Tier 4"] := "20 Reinforced Plank, 25 Tar, 12 Hollowbone"
recipes["Titan Walker Upgrade Water Tier 1"] := "44 Rubber Block, 63 Eucalyptus Leaf, 13 Leather"
recipes["Titan Walker Upgrade Water Tier 2"] := "44 Rubber Block, 63 Eucalyptus Leaf, 13 Leather"
recipes["Titan Walker Upgrade Water Tier 3"] := "44 Rubber Block, 63 Eucalyptus Leaf, 13 Leather"
recipes["Titan Walker Upgrade Water Tier 4"] := "44 Rubber Block, 63 Eucalyptus Leaf, 13 Leather"
recipes["Tusker Walker Upgrade Cargo Tier 1"] := "50 Chitin Plate, 75 Redwood Wood"
recipes["Tusker Walker Upgrade Cargo Tier 2"] := "50 Chitin Plate, 75 Redwood Wood"
recipes["Tusker Walker Upgrade Cargo Tier 3"] := "50 Chitin Plate, 75 Redwood Wood, 25 Stone"
recipes["Tusker Walker Upgrade Cargo Tier 4"] := "25 Stone, 75 Redwood Wood, 50 Chitin Plate"
recipes["Tusker Walker Upgrade Durability Tier 1"] := "65 Obsidian, 70 Chitin Plate, 24 Tar"
recipes["Tusker Walker Upgrade Durability Tier 2"] := "65 Obsidian, 65 Tar, 70 Chitin Plate"
recipes["Tusker Walker Upgrade Durability Tier 3"] := "65 Obsidian, 65 Tar, 70 Chitin Plate"
recipes["Tusker Walker Upgrade Durability Tier 4"] := "70 Chitin Plate, 65 Tar, 65 Obsidian"
recipes["Tusker Walker Upgrade Gear Tier 1"] := "20 Tar, 22 Wooden Slab, 55 Cotton"
recipes["Tusker Walker Upgrade Gear Tier 2"] := "20 Tar, 22 Wooden Slab, 55 Cotton"
recipes["Tusker Walker Upgrade Gear Tier 3"] := "20 Tar, 22 Wooden Slab, 55 Cotton"
recipes["Tusker Walker Upgrade Gear Tier 4"] := "20 Tar, 22 Wooden Slab, 55 Cotton"
recipes["Tusker Walker Upgrade Mobility Tier 1"] := "50 Tar, 38 Obsidian, 5 Reinforced Gear"
recipes["Tusker Walker Upgrade Mobility Tier 2"] := "50 Tar, 38 Obsidian, 5 Reinforced Gear"
recipes["Tusker Walker Upgrade Mobility Tier 3"] := "50 Tar, 38 Obsidian, 5 Reinforced Gear"
recipes["Tusker Walker Upgrade Mobility Tier 4"] := "38 Obsidian, 5 Reinforced Gear, 50 Tar"
recipes["Tusker Walker Upgrade Torque Tier 1"] := "25 Tallow, 22 Wood Shaft, 45 Clay"
recipes["Tusker Walker Upgrade Torque Tier 2"] := "25 Tallow, 45 Clay, 22 Wood Shaft"
recipes["Tusker Walker Upgrade Torque Tier 3"] := "25 Tallow, 45 Clay, 22 Wood Shaft"
recipes["Tusker Walker Upgrade Torque Tier 4"] := "25 Tallow, 45 Clay, 22 Wood Shaft"
recipes["Stiletto Walker Legs (1 of 2)"] := "1 Medium Walker Leg"
recipes["Stiletto Walker Legs Armored (1 of 2)"] := "1 Armored Medium Walker Leg"
recipes["Titan Walker Legs (1 of 2)"] := "1 Capital Walker Leg"
recipes["Titan Walker Legs Armored (1 of 2)"] := "1 Armored Capital Walker Leg"
recipes["Titan Walker Legs Heavy (1 of 2)"] := "1 Heavy Capital Walker Leg"
recipes["Titan Walker Wings (1 of 2)"] := "1 Capital Walker Wing"
recipes["Titan Walker Wings Heavy (1 of 2)"] := "1 Improved Capital Walker Wing"
recipes["Titan Walker Wings Large (1 of 2)"] := "1 Flotillan Capital Walker Wing"
recipes["Titan Walker Wings Medium (1 of 2)"] := "1 Advanced Capital Walker Wing"
recipes["Tusker Walker Legs (1 of 2)"] := "1 Large Walker Leg"
recipes["Tusker Walker Legs Armored (1 of 2)"] := "1 Armored Large Walker Leg"
recipes["Tusker Walker Legs Heavy (1 of 2)"] := "1 Heavy Large Walker Leg"
recipes["Steering Levers"] := "2 Wood Shaft, 2 Rope"
recipes["Steering Levers Cage"] := "210 Wood, 60 Stone, 30 Rope, 15 Bone Splinter"
recipes["Silur Walker"] := "1615 Wood, 950 Fiber, 190 Stone, 39 Rope, 42 Wood Shaft, 200 Obsidian, 12 Tar, 1 Reinforced Gear"
recipes["Spider Walker"] := "50 Wood, 60 Fiber, 12 Stone, 6 Rupu Vine"
recipes["Stiletto Walker"] := "295 Wood, 23 Rope, 87 Fiber, 2 Fiber Weave, 50 Stone, 1 Wooden Gear"
recipes["Titan Walker"] := "3030 Lightwood, 625 Fiber, 600 Stone, 159 Rope, 385 Wood Shaft, 1 Iron Gear, 30 Iron Nails"
recipes["Tusker Walker"] := "2182 Wood, 270 Rope, 52 Wood Shaft, 629 Fiber, 500 Stone, 280 Redwood Wood, 52 Leather, 215 Chitin Plate, 30 Fiber Weave, 135 Tar, 5 Bone Glue, 1 Reinforced Gear"
recipes["Short Ceramic Hoofmace"] := "6 Wood Shaft, 3 Ceramic Shard, 4 Nomad Cloth"
recipes["Short Malletblade"] := "6 Wood Shaft, 3 Ceramic Shard, 6 Redwood Wood"
recipes["Tall Stinger"] := "20 Wood, 2 Fiber Weave, 28 Fiber, 5 Wood Shaft"
recipes["Throwable Aloe Bomb"] := "6 Aloe Gel, 6 Cotton, 2 Rope"
recipes["Throwable Insect Bomb"] := "6 Insects, 3 Cotton, 2 Rope, 6 Beeswax"
recipes["Throwable Smoke Bomb"] := "1 Tar, 3 Cotton, 2 Rope"
recipes["Throwing Net"] := "35 Rupu Vine, 10 Stone, 8 Rupu Pelt, 3 Rope"
recipes["Throwstone"] := "1 Stone"
recipes["Thumper"] := "3 Wood, 5 Fiber Weave, 2 Rupu Vine, 3 Wood Shaft"
recipes["Travellerâ€™s Staff"] := "8 Wood Shaft, 4 Hide, 6 Rupu Pelt"
recipes["Wyndan Battle Axe"] := "10 Lightwood, 6 Leather, 3 Iron Ingot"
recipes["Wyndan Flame Sword"] := "10 Lightwood, 6 Triple Stitch Fabric, 3 Iron Ingot"
recipes["Wyndan Hammer"] := "10 Lightwood, 4 Leather, 3 Iron Ingot"
recipes["Wyndan Hand Axe"] := "6 Wood Shaft, 3 Iron Ingot, 5 Rope"
recipes["Wyndan Sabre"] := "10 Lightwood, 6 Leather, 3 Iron Ingot"
recipes["Wyndan Warhammer"] := "7 Iron Ore, 12 Wood Shaft, 12 Rupu Vine"
recipes["Wyndanblade Quarterstaff"] := "10 Lightwood, 6 Nomad Cloth, 3 Iron Ingot"

}

; Auto-click toggle function
ToggleAutoClick:
    global autoClickEnabled
    
    ; Toggle the state
    autoClickEnabled := !autoClickEnabled
    
    if (autoClickEnabled) {
        ; Enable auto-clicking
        SetTimer, PerformAutoClick, 500  ; 0.5 seconds
        GuiControl,, Button4, F6: Auto Click (ON)
        
        ; Show tooltip to confirm activation
        ToolTip, Auto-clicking enabled, 0, 0
        SetTimer, RemoveToolTip, 1500
    } else {
        ; Disable auto-clicking
        SetTimer, PerformAutoClick, Off
        GuiControl,, Button4, F6: Auto Click (OFF)
        
        ; Show tooltip to confirm deactivation
        ToolTip, Auto-clicking disabled, 0, 0
        SetTimer, RemoveToolTip, 1500
    }
    return

; Auto-click function - improved version
PerformAutoClick:
    if (autoClickEnabled) {
        ; Force the click to go through to the active window
        CoordMode, Mouse, Screen  ; Use screen coordinates
        MouseGetPos, xpos, ypos   ; Get current mouse position
        
        ; Send click down, wait, and then send click up
        SendEvent {Click Down %xpos%, %ypos%}
        Sleep, 50
        SendEvent {Click Up %xpos%, %ypos%}
    }
return

; Show resolution selector
OpenResSelector:
    ; Set the current resolution radio button
    if (currentResolution = "3840x2160")
        GuiControl, 3:, Res4K, 1
    else if (currentResolution = "2560x1440")
        GuiControl, 3:, ResQHD, 1
    else if (currentResolution = "1920x1080")
        GuiControl, 3:, ResFHD, 1
    
    ; Show the dialog
    Gui, 3:Show, w270 h170, Select Res
Return

F5::Gosub, OpenResSelector
Return

; Apply selected resolution
ApplyResolution:
    Gui, 3:Submit, NoHide
    
    ; Determine which resolution was selected
    if (Res4K)
        currentResolution := "3840x2160"
    else if (ResQHD)
        currentResolution := "2560x1440"
    else if (ResFHD)
        currentResolution := "1920x1080"
    
    ; Update button label
    if (currentResolution = "3840x2160")
        GuiControl,, ResButton, Resolution: 4K
    else if (currentResolution = "2560x1440")
        GuiControl,, ResButton, Resolution: 1440p
    else if (currentResolution = "1920x1080")
        GuiControl,, ResButton, Resolution: 1080p
    
    ; Show confirmation tooltip
    ToolTip, Resolution changed to %currentResolution%, 0, 0
    SetTimer, RemoveToolTip, 1500
    
    ; Close the dialog
    Gui, 3:Hide
Return

; Function to update the digital clock - 12-HOUR FORMAT
UpdateClock:
    FormatTime, CurrentTime,, h:mm:ss tt
    GuiControl,, DigitalClock, %CurrentTime%
Return

; Function to remove tooltip
RemoveToolTip:
    ToolTip
    SetTimer, RemoveToolTip, Off
Return

; Function to check if Last Oasis is active and adjust GUI accordingly
CheckGameActive:
    IfWinActive, Last Oasis ahk_class UnrealWindow
    {
        if (!isGameActive) {
            ; Make the window click-through when game is active
            Gui, +LastFound
            WinSet, ExStyle, +0x20 ; WS_EX_TRANSPARENT - Makes the window click-through
            isGameActive := true
        }
    }
    else
    {
        if (isGameActive) {
            ; Restore normal window behavior when game is not active
            Gui, +LastFound
            WinSet, ExStyle, -0x20 ; Remove the WS_EX_TRANSPARENT style
            isGameActive := false
        }
    }
Return

F4::
    IfWinActive, Recipe Search
    {
        Gosub, 4GuiClose
    }
    Else
    {
        Gosub, OpenRecipeSearch
    }
Return

; Recipe search window
OpenRecipeSearch:
    ; Show the recipe search window
    Gui, 4:Show, w330 h320, Recipe Search
    
    return

SearchOnEnter:
    if (A_GuiEvent = "Normal") ; For an Edit control with +WantReturn, Enter triggers the g-label with A_GuiEvent = "Normal"
    {
        Gosub, PerformSearch
    }
    return

; Search function for recipes
PerformSearch:
    Gui, 4:Submit, NoHide
    global recipes
    
    ; Clear previous results
    GuiControl, 4:, SearchResults, Searching...
    
    if (SearchTerm = "") {
        ; If search term is empty, show all recipes
        resultText := "All Available Recipes:`n`n"
        for recipeName, recipeDetails in recipes {
            resultText .= recipeName . ":`n" . recipeDetails . "`n`n"
        }
    } else {
        ; Search for matches
        matches := {}
        partialMatches := {}
        
        for recipeName, recipeDetails in recipes {
            ; Check for exact match (case insensitive)
            if (Format("{:L}", recipeName) = Format("{:L}", SearchTerm)) {
                matches[recipeName] := recipeDetails
            } 
            ; Check for partial match
            else if (InStr(Format("{:L}", recipeName), Format("{:L}", SearchTerm))) {
                partialMatches[recipeName] := recipeDetails
            }
        }
        
        ; Format results
        resultText := ""
        
        ; Add exact matches
        if (matches.Count() > 0) {
            resultText .= "Exact Matches:`n`n"
            for recipeName, recipeDetails in matches {
                resultText .= recipeName . ":`n" . recipeDetails . "`n`n"
            }
        }
        
        ; Add partial matches
        if (partialMatches.Count() > 0) {
            resultText .= "Partial Matches:`n`n"
            for recipeName, recipeDetails in partialMatches {
                resultText .= recipeName . ":`n" . recipeDetails . "`n`n"
            }
        }
        
        ; No matches found
        if (resultText = "") {
            resultText := "No recipes found matching: " . SearchTerm
        }
    }
    
    ; Update results
    GuiControl, 4:, SearchResults, %resultText%
    return

; Pause hotkeys
PauseHotkeys:
    Suspend, On
    MenuState := "Pause"
Return

; Resume hotkeys
ResumeHotkeys:
    Suspend, Off
    MenuState := "Resume"
Return

; Exit the script
ExitScript:
    ExitApp
Return

; Handler for the Cancel button in resolution selector
3GuiClose:
    Gui, 3:Hide
Return

; Handler for the Close button in recipe search
4GuiClose:
    Gui, 4:Hide
Return

; Button actions
RunMacro1:
    Gosub, Macro1
Return

RunMacro2:
    Gosub, Macro2
Return

RunMacro3:
    Gosub, Macro3
Return

; F6 hotkey to toggle auto-clicking
F6::Gosub, ToggleAutoClick

F8::
    ; Show/hide main window only
    if (mainGuiVisible) {
        Gui, Hide
        mainGuiVisible := false
    } else {
        Gui, Show, NoActivate
        mainGuiVisible := true
    }
Return

F1::
Macro1:
    WinActivate, Last Oasis   ahk_class UnrealWindow
    Sleep, 333
    Send, {LAlt Down}
    
    if (currentResolution = "2560x1440") {
        Click, 1907, 244 Left, Down
        Click, 1907, 244 Left, Up
        Click, 1971, 252 Left, Down
        Click, 1973, 253 Left, Up
        Click, 2080, 260 Left, Down
        Click, 2080, 262 Left, Up
        Click, 2152, 262 Left, Down
        Click, 2152, 263 Left, Up
        Click, 1883, 332 Left, Down
        Click, 1883, 332 Left, Up
        Click, 1962, 341 Left, Down
        Click, 1970, 343 Left, Up
        Click, 2051, 344 Left, Down
        Click, 2052, 345 Left, Up
        Click, 2134, 347 Left, Down
        Click, 2133, 349 Left, Up
        Click, 1881, 418 Left, Down
        Click, 1881, 418 Left, Up
        Click, 2001, 426 Left, Down
        Click, 2000, 426 Left, Up
        Click, 2071, 430 Left, Down
        Click, 2074, 431 Left, Up
        Click, 2138, 428 Left, Down
        Click, 2138, 428 Left, Up
        Click, 1890, 506 Left, Down
        Click, 1892, 506 Left, Up
        Click, 1964, 504 Left, Down
        Click, 2010, 507 Left, Up
        Click, 2066, 508 Left, Down
        Click, 2083, 509 Left, Up
        Click, 2159, 516 Left, Down
        Click, 2154, 516 Left, Up
        Click, 1900, 622 Left, Down
        Click, 1900, 622 Left, Up
        Click, 1981, 615 Left, Down
        Click, 1981, 615 Left, Up
        Click, 2050, 617 Left, Down
        Click, 2055, 617 Left, Up
        Click, 2131, 618 Left, Down
        Click, 2162, 623 Left, Up
        Click, 2213, 624 Left, Down
        Click, 2214, 625 Left, Up
        Click, 1903, 688 Left, Down
        Click, 1933, 693 Left, Up
        Click, 1970, 697 Left, Down
        Click, 1973, 698 Left, Up
        Click, 2058, 712 Left, Down
        Click, 2072, 714 Left, Up
        Click, 2138, 718 Left, Down
        Click, 2149, 719 Left, Up
        Click, 2220, 722 Left, Down
        Click, 2218, 721 Left, Up
        Click, 1887, 884 Left, Down
        Click, 1887, 885 Left, Up
        Click, 1962, 891 Left, Down
        Click, 1964, 892 Left, Up
        Click, 2045, 904 Left, Down
        Click, 2053, 906 Left, Up
        Click, 2150, 901 Left, Down
        Click, 2161, 901 Left, Up
        Click, 2238, 897 Left, Down
        Click, 2238, 897 Left, Up
        Click, 1886, 983 Left, Down
        Click, 1899, 989 Left, Up
        Click, 1967, 985 Left, Down
        Click, 1992, 985 Left, Up
        Click, 2071, 978 Left, Down
        Click, 2080, 978 Left, Up
        Click, 2125, 978 Left, Down
        Click, 2144, 981 Left, Up
        Click, 2211, 982 Left, Down
        Click, 2211, 982 Left, Up
    }
    else if (currentResolution = "1920x1080") {
        Click, 1423, 211 Left, Down
        Click, 1431, 210 Left, Up
        Click, 1502, 208 Left, Down
        Click, 1502, 208 Left, Up
        Click, 1558, 201 Left, Down
        Click, 1558, 201 Left, Up
        Click, 1607, 195 Left, Down
        Click, 1607, 195 Left, Up
        Click, 1416, 250 Left, Down
        Click, 1425, 250 Left, Up
        Click, 1476, 248 Left, Down
        Click, 1484, 248 Left, Up
        Click, 1539, 250 Left, Down
        Click, 1549, 254 Left, Up
        Click, 1603, 257 Left, Down
        Click, 1597, 261 Left, Up
        Click, 1426, 319 Left, Down
        Click, 1426, 319 Left, Up
        Click, 1477, 321 Left, Down
        Click, 1486, 321 Left, Up
        Click, 1538, 318 Left, Down
        Click, 1544, 318 Left, Up
        Click, 1597, 317 Left, Down
        Click, 1590, 325 Left, Up
        Click, 1438, 384 Left, Down
        Click, 1438, 384 Left, Up
        Click, 1491, 387 Left, Down
        Click, 1495, 387 Left, Up
        Click, 1546, 388 Left, Down
        Click, 1550, 388 Left, Up
        Click, 1604, 389 Left, Down
        Click, 1598, 394 Left, Up
        Click, 1428, 463 Left, Down
        Click, 1429, 464 Left, Up
        Click, 1489, 470 Left, Down
        Click, 1492, 470 Left, Up
        Click, 1541, 471 Left, Down
        Click, 1542, 471 Left, Up
        Click, 1608, 472 Left, Down
        Click, 1612, 473 Left, Up
        Click, 1665, 475 Left, Down
        Click, 1665, 477 Left, Up
        Click, 1424, 536 Left, Down
        Click, 1430, 537 Left, Up
        Click, 1486, 539 Left, Down
        Click, 1488, 539 Left, Up
        Click, 1551, 539 Left, Down
        Click, 1573, 539 Left, Up
        Click, 1609, 539 Left, Down
        Click, 1610, 539 Left, Up
        Click, 1668, 544 Left, Down
        Click, 1667, 545 Left, Up
        Click, 1425, 599 Left, Down
        Click, 1442, 602 Left, Up
        Click, 1485, 603 Left, Down
        Click, 1490, 604 Left, Up
        Click, 1557, 610 Left, Down
        Click, 1560, 610 Left, Up
        Click, 1607, 615 Left, Down
        Click, 1615, 616 Left, Up
        Click, 1685, 617 Left, Down
        Click, 1685, 617 Left, Up
        Click, 1433, 654 Left, Down
        Click, 1445, 658 Left, Up
        Click, 1485, 660 Left, Down
        Click, 1507, 663 Left, Up
        Click, 1553, 667 Left, Down
        Click, 1559, 669 Left, Up
        Click, 1607, 671 Left, Down
        Click, 1615, 672 Left, Up
        Click, 1690, 675 Left, Down
        Click, 1690, 675 Left, Up
        Click, 1419, 727 Left, Down
        Click, 1442, 735 Left, Up
        Click, 1467, 739 Left, Down
        Click, 1495, 743 Left, Up
        Click, 1557, 741 Left, Down
        Click, 1576, 742 Left, Up
        Click, 1606, 743 Left, Down
        Click, 1608, 743 Left, Up
        Click, 1678, 745 Left, Down
        Click, 1678, 745 Left, Up
    }
    else {
        ; Default 4K coordinates
        Click, 2825, 439 Left, Down
        Click, 2825, 439 Left, Up
        Click, 2955, 435 Left, Down
        Click, 2955, 435 Left, Up
        Click, 3032, 427 Left, Down
        Click, 3032, 427 Left, Up
        Click, 3174, 428 Left, Down
        Click, 3174, 428 Left, Up
        Click, 3273, 414 Left, Down
        Click, 3273, 414 Left, Up
        Click, 3306, 510 Left, Down
        Click, 3296, 523 Left, Up
        Click, 3182, 542 Left, Down
        Click, 3179, 544 Left, Up
        Click, 3034, 552 Left, Down
        Click, 3034, 552 Left, Up
        Click, 2933, 536 Left, Down
        Click, 2933, 536 Left, Up
        Click, 2808, 539 Left, Down
        Click, 2808, 539 Left, Up
        Click, 2806, 657 Left, Down
        Click, 2808, 657 Left, Up
        Click, 2912, 656 Left, Down
        Click, 2912, 656 Left, Up
        Click, 3050, 656 Left, Down
        Click, 3050, 656 Left, Up
        Click, 3160, 658 Left, Down
        Click, 3160, 658 Left, Up
        Click, 3293, 661 Left, Down
        Click, 3293, 671 Left, Up
        Click, 3294, 782 Left, Down
        Click, 3291, 784 Left, Up
        Click, 3168, 773 Left, Down
        Click, 3167, 773 Left, Up
        Click, 3048, 773 Left, Down
        Click, 3045, 775 Left, Up
        Click, 2925, 781 Left, Down
        Click, 2923, 783 Left, Up
        Click, 2800, 785 Left, Down
        Click, 2800, 785 Left, Up
        Click, 2776, 940 Left, Down
        Click, 2776, 940 Left, Up
        Click, 2864, 942 Left, Down
        Click, 2867, 942 Left, Up
        Click, 2923, 941 Left, Down
        Click, 2925, 941 Left, Up
        Click, 3009, 931 Left, Down
        Click, 3009, 931 Left, Up
        Click, 3074, 937 Left, Down
        Click, 3074, 937 Left, Up
        Click, 3140, 938 Left, Down
        Click, 3141, 938 Left, Up
        Click, 3247, 949 Left, Down
        Click, 3235, 950 Left, Up
        Click, 3290, 952 Left, Down
        Click, 3290, 952 Left, Up
        Click, 3371, 924 Left, Down
        Click, 3365, 929 Left, Up
        Click, 3441, 929 Left, Down
        Click, 3431, 929 Left, Up
        Click, 3442, 1083 Left, Down
        Click, 3442, 1083 Left, Up
        Click, 3352, 1067 Left, Down
        Click, 3352, 1067 Left, Up
        Click, 3284, 1072 Left, Down
        Click, 3284, 1072 Left, Up
        Click, 3205, 1079 Left, Down
        Click, 3205, 1079 Left, Up
        Click, 3131, 1064 Left, Down
        Click, 3131, 1064 Left, Up
        Click, 3074, 1071 Left, Down
        Click, 3074, 1071 Left, Up
        Click, 3014, 1072 Left, Down
        Click, 3013, 1072 Left, Up
        Click, 2916, 1068 Left, Down
        Click, 2920, 1061 Left, Up
        Click, 2848, 1063 Left, Down
        Click, 2848, 1063 Left, Up
        Click, 2785, 1065 Left, Down
        Click, 2785, 1067 Left, Up
        Click, 2812, 1192 Left, Down
        Click, 2813, 1192 Left, Up
        Click, 2983, 1218 Left, Down
        Click, 2983, 1218 Left, Up
        Click, 3060, 1221 Left, Down
        Click, 3062, 1220 Left, Up
        Click, 3176, 1204 Left, Down
        Click, 3176, 1204 Left, Up
        Click, 3282, 1182 Left, Down
        Click, 3293, 1182 Left, Up
        Click, 3393, 1193 Left, Down
        Click, 3399, 1195 Left, Up
        Click, 3395, 1288 Left, Down
        Click, 3395, 1288 Left, Up
        Click, 3265, 1299 Left, Down
        Click, 3265, 1299 Left, Up
        Click, 3175, 1306 Left, Down
        Click, 3138, 1316 Left, Up
        Click, 3034, 1312 Left, Down
        Click, 3027, 1314 Left, Up
        Click, 2937, 1314 Left, Down
        Click, 2938, 1314 Left, Up
        Click, 2795, 1309 Left, Down
        Click, 2795, 1308 Left, Up
    }
    
    Send, {LAlt Up}
Return

F2::
Macro2:
    WinActivate, Last Oasis   ahk_class UnrealWindow
    Sleep, 333
    Send, {LAlt Down}
    
    if (currentResolution = "2560x1440") {
        Click, 1907, 244 Left, Down
        Click, 1907, 244 Left, Up
        Click, 1971, 252 Left, Down
        Click, 1973, 253 Left, Up
        Click, 2080, 260 Left, Down
        Click, 2080, 262 Left, Up
        Click, 2152, 262 Left, Down
        Click, 2152, 263 Left, Up
        Click, 1883, 332 Left, Down
        Click, 1883, 332 Left, Up
        Click, 1962, 341 Left, Down
        Click, 1970, 343 Left, Up
        Click, 2051, 344 Left, Down
        Click, 2052, 345 Left, Up
        Click, 2134, 347 Left, Down
        Click, 2133, 349 Left, Up
        Click, 1881, 418 Left, Down
        Click, 1881, 418 Left, Up
        Click, 2001, 426 Left, Down
        Click, 2000, 426 Left, Up
        Click, 2071, 430 Left, Down
        Click, 2074, 431 Left, Up
        Click, 2138, 428 Left, Down
        Click, 2138, 428 Left, Up
        Click, 1890, 506 Left, Down
        Click, 1892, 506 Left, Up
        Click, 1964, 504 Left, Down
        Click, 2010, 507 Left, Up
        Click, 2066, 508 Left, Down
        Click, 2083, 509 Left, Up
        Click, 2159, 516 Left, Down
        Click, 2154, 516 Left, Up
        Click, 1900, 622 Left, Down
        Click, 1900, 622 Left, Up
        Click, 1981, 615 Left, Down
        Click, 1981, 615 Left, Up
        Click, 2050, 617 Left, Down
        Click, 2055, 617 Left, Up
        Click, 2131, 618 Left, Down
        Click, 2162, 623 Left, Up
        Click, 2213, 624 Left, Down
        Click, 2214, 625 Left, Up
        Click, 1903, 688 Left, Down
        Click, 1933, 693 Left, Up
        Click, 1970, 697 Left, Down
        Click, 1973, 698 Left, Up
        Click, 2058, 712 Left, Down
        Click, 2072, 714 Left, Up
        Click, 2138, 718 Left, Down
        Click, 2149, 719 Left, Up
        Click, 2220, 722 Left, Down
        Click, 2218, 721 Left, Up
        Click, 1887, 884 Left, Down
        Click, 1887, 885 Left, Up
        Click, 1962, 891 Left, Down
        Click, 1964, 892 Left, Up
        Click, 2045, 904 Left, Down
        Click, 2053, 906 Left, Up
        Click, 2150, 901 Left, Down
        Click, 2161, 901 Left, Up
        Click, 2238, 897 Left, Down
        Click, 2238, 897 Left, Up
        Click, 1886, 983 Left, Down
        Click, 1899, 989 Left, Up
        Click, 1967, 985 Left, Down
        Click, 1992, 985 Left, Up
        Click, 2071, 978 Left, Down
        Click, 2080, 978 Left, Up
        Click, 2125, 978 Left, Down
        Click, 2144, 981 Left, Up
        Click, 2211, 982 Left, Down
        Click, 2211, 982 Left, Up
    }
    else if (currentResolution = "1920x1080") {
        Click, 1423, 211 Left, Down
        Click, 1431, 210 Left, Up
        Click, 1502, 208 Left, Down
        Click, 1502, 208 Left, Up
        Click, 1558, 201 Left, Down
        Click, 1558, 201 Left, Up
        Click, 1607, 195 Left, Down
        Click, 1607, 195 Left, Up
        Click, 1416, 250 Left, Down
        Click, 1425, 250 Left, Up
        Click, 1476, 248 Left, Down
        Click, 1484, 248 Left, Up
        Click, 1539, 250 Left, Down
        Click, 1549, 254 Left, Up
        Click, 1603, 257 Left, Down
        Click, 1597, 261 Left, Up
        Click, 1426, 319 Left, Down
        Click, 1426, 319 Left, Up
        Click, 1477, 321 Left, Down
        Click, 1486, 321 Left, Up
        Click, 1538, 318 Left, Down
        Click, 1544, 318 Left, Up
        Click, 1597, 317 Left, Down
        Click, 1590, 325 Left, Up
        Click, 1438, 384 Left, Down
        Click, 1438, 384 Left, Up
        Click, 1491, 387 Left, Down
        Click, 1495, 387 Left, Up
        Click, 1546, 388 Left, Down
        Click, 1550, 388 Left, Up
        Click, 1604, 389 Left, Down
        Click, 1598, 394 Left, Up
        Click, 1428, 463 Left, Down
        Click, 1429, 464 Left, Up
        Click, 1489, 470 Left, Down
        Click, 1492, 470 Left, Up
        Click, 1541, 471 Left, Down
        Click, 1542, 471 Left, Up
        Click, 1608, 472 Left, Down
        Click, 1612, 473 Left, Up
        Click, 1665, 475 Left, Down
        Click, 1665, 477 Left, Up
        Click, 1424, 536 Left, Down
        Click, 1430, 537 Left, Up
        Click, 1486, 539 Left, Down
        Click, 1488, 539 Left, Up
        Click, 1551, 539 Left, Down
        Click, 1573, 539 Left, Up
        Click, 1609, 539 Left, Down
        Click, 1610, 539 Left, Up
        Click, 1668, 544 Left, Down
        Click, 1667, 545 Left, Up
        Click, 1425, 599 Left, Down
        Click, 1442, 602 Left, Up
        Click, 1485, 603 Left, Down
        Click, 1490, 604 Left, Up
        Click, 1557, 610 Left, Down
        Click, 1560, 610 Left, Up
        Click, 1607, 615 Left, Down
        Click, 1615, 616 Left, Up
        Click, 1685, 617 Left, Down
        Click, 1685, 617 Left, Up
        Click, 1433, 654 Left, Down
        Click, 1445, 658 Left, Up
        Click, 1485, 660 Left, Down
        Click, 1507, 663 Left, Up
        Click, 1553, 667 Left, Down
        Click, 1559, 669 Left, Up
        Click, 1607, 671 Left, Down
        Click, 1615, 672 Left, Up
        Click, 1690, 675 Left, Down
        Click, 1690, 675 Left, Up
        Click, 1419, 727 Left, Down
        Click, 1442, 735 Left, Up
        Click, 1467, 739 Left, Down
        Click, 1495, 743 Left, Up
        Click, 1557, 741 Left, Down
        Click, 1576, 742 Left, Up
        Click, 1606, 743 Left, Down
        Click, 1608, 743 Left, Up
        Click, 1678, 745 Left, Down
        Click, 1678, 745 Left, Up
    }
    else {
        ; Default 4K coordinates
        Click, 2825, 439 Left, Down
        Click, 2825, 439 Left, Up
        Click, 2955, 435 Left, Down
        Click, 2955, 435 Left, Up
        Click, 3032, 427 Left, Down
        Click, 3032, 427 Left, Up
        Click, 3174, 428 Left, Down
        Click, 3174, 428 Left, Up
        Click, 3273, 414 Left, Down
        Click, 3273, 414 Left, Up
        Click, 3306, 510 Left, Down
        Click, 3296, 523 Left, Up
        Click, 3182, 542 Left, Down
        Click, 3179, 544 Left, Up
        Click, 3034, 552 Left, Down
        Click, 3034, 552 Left, Up
        Click, 2933, 536 Left, Down
        Click, 2933, 536 Left, Up
        Click, 2808, 539 Left, Down
        Click, 2808, 539 Left, Up
        Click, 2806, 657 Left, Down
        Click, 2808, 657 Left, Up
        Click, 2912, 656 Left, Down
        Click, 2912, 656 Left, Up
        Click, 3050, 656 Left, Down
        Click, 3050, 656 Left, Up
        Click, 3160, 658 Left, Down
        Click, 3160, 658 Left, Up
        Click, 3293, 661 Left, Down
        Click, 3293, 671 Left, Up
        Click, 3294, 782 Left, Down
        Click, 3291, 784 Left, Up
        Click, 3168, 773 Left, Down
        Click, 3167, 773 Left, Up
        Click, 3048, 773 Left, Down
        Click, 3045, 775 Left, Up
        Click, 2925, 781 Left, Down
        Click, 2923, 783 Left, Up
        Click, 2800, 785 Left, Down
        Click, 2800, 785 Left, Up
        Click, 2776, 940 Left, Down
        Click, 2776, 940 Left, Up
        Click, 2864, 942 Left, Down
        Click, 2867, 942 Left, Up
        Click, 2923, 941 Left, Down
        Click, 2925, 941 Left, Up
        Click, 3009, 931 Left, Down
        Click, 3009, 931 Left, Up
        Click, 3074, 937 Left, Down
        Click, 3074, 937 Left, Up
        Click, 3140, 938 Left, Down
        Click, 3141, 938 Left, Up
        Click, 3247, 949 Left, Down
        Click, 3235, 950 Left, Up
        Click, 3290, 952 Left, Down
        Click, 3290, 952 Left, Up
        Click, 3371, 924 Left, Down
        Click, 3365, 929 Left, Up
        Click, 3441, 929 Left, Down
        Click, 3431, 929 Left, Up
        Click, 3442, 1083 Left, Down
        Click, 3442, 1083 Left, Up
        Click, 3352, 1067 Left, Down
        Click, 3352, 1067 Left, Up
        Click, 3284, 1072 Left, Down
        Click, 3284, 1072 Left, Up
        Click, 3205, 1079 Left, Down
        Click, 3205, 1079 Left, Up
        Click, 3131, 1064 Left, Down
        Click, 3131, 1064 Left, Up
        Click, 3074, 1071 Left, Down
        Click, 3074, 1071 Left, Up
        Click, 3014, 1072 Left, Down
        Click, 3013, 1072 Left, Up
        Click, 2916, 1068 Left, Down
        Click, 2920, 1061 Left, Up
        Click, 2848, 1063 Left, Down
        Click, 2848, 1063 Left, Up
        Click, 2785, 1065 Left, Down
        Click, 2785, 1067 Left, Up
        Click, 2812, 1192 Left, Down
        Click, 2813, 1192 Left, Up
        Click, 2983, 1218 Left, Down
        Click, 2983, 1218 Left, Up
        Click, 3060, 1221 Left, Down
        Click, 3062, 1220 Left, Up
        Click, 3176, 1204 Left, Down
        Click, 3176, 1204 Left, Up
        Click, 3282, 1182 Left, Down
        Click, 3293, 1182 Left, Up
        Click, 3393, 1193 Left, Down
        Click, 3399, 1195 Left, Up
        Click, 3395, 1288 Left, Down
        Click, 3395, 1288 Left, Up
        Click, 3265, 1299 Left, Down
        Click, 3265, 1299 Left, Up
        Click, 3175, 1306 Left, Down
        Click, 3138, 1316 Left, Up
        Click, 3034, 1312 Left, Down
        Click, 3027, 1314 Left, Up
        Click, 2937, 1314 Left, Down
        Click, 2938, 1314 Left, Up
        Click, 2795, 1309 Left, Down
        Click, 2795, 1308 Left, Up
    }
    
    Send, {LAlt Up}
Return

F3::
Macro3:
    WinActivate, Last Oasis   ahk_class UnrealWindow
    Send, {LAlt Down}
    
    if (currentResolution = "2560x1440") {
        Click, 1443, 319 Left, Down
        Click, 1443, 319 Left, Up
        Click, 1538, 330 Left, Down
        Click, 1538, 330 Left, Up
        Click, 1441, 410 Left, Down
        Click, 1441, 410 Left, Up
        Click, 1528, 416 Left, Down
        Click, 1528, 416 Left, Up
        Click, 1441, 492 Left, Down
        Click, 1441, 492 Left, Up
        Click, 1521, 496 Left, Down
        Click, 1521, 496 Left, Up
        Click, 1451, 576 Left, Down
        Click, 1451, 576 Left, Up
        Click, 1539, 577 Left, Down
        Click, 1539, 577 Left, Up
    }
    else if (currentResolution = "1920x1080") {
        Click, 1091, 237 Left, Down
        Click, 1091, 237 Left, Up
        Click, 1154, 236 Left, Down
        Click, 1154, 236 Left, Up
        Click, 1088, 307 Left, Down
        Click, 1090, 306 Left, Up
        Click, 1152, 302 Left, Down
        Click, 1153, 302 Left, Up
        Click, 1078, 356 Left, Down
        Click, 1078, 356 Left, Up
        Click, 1152, 356 Left, Down
        Click, 1152, 357 Left, Up
        Click, 1074, 426 Left, Down
        Click, 1074, 426 Left, Up
        Click, 1150, 428 Left, Down
        Click, 1150, 428 Left, Up
    }
    else {
        ; Default 4K coordinates
        Click, 2191, 483 Left, Down
        Click, 2191, 483 Left, Up
        Click, 2269, 484 Left, Down
        Click, 2270, 484 Left, Up
        Click, 2307, 633 Left, Down
        Click, 2307, 633 Left, Up
        Click, 2169, 623 Left, Down
        Click, 2169, 626 Left, Up
        Click, 2145, 736 Left, Down
        Click, 2155, 737 Left, Up
        Click, 2321, 786 Left, Down
        Click, 2326, 809 Left, Up
        Click, 2329, 860 Left, Down
        Click, 2329, 860 Left, Up
        Click, 2182, 866 Left, Down
        Click, 2182, 866 Left, Up
    }
    
    Send, {LAlt Up}
Return

StartDrag(wParam, lParam, msg, hwnd) {
    MouseGetPos,,, win, control
    ; Only block dragging if the control is a button, otherwise allow drag from anywhere else
    if !(control ~= "Button\d+") {
        PostMessage, 0xA1, 2,,, ahk_id %hwnd% ; WM_NCLBUTTONDOWN, HTCAPTION
    }
}

ShowContextMenu(wParam, lParam) {
    MouseGetPos, mouseX, mouseY, win, control
    ; Show context menu if right-clicking anywhere except a button
    if !(control ~= "Button\d+") {
        Menu, ContextMenu, Show, %mouseX%, %mouseY%
    }
}