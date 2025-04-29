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

; Modern UI Configuration with rounded corners
Gui, +AlwaysOnTop +ToolWindow -Caption +HwndGuiHwnd
Gui, Color, 333333 ; Dark grey background
Gui, Font, s16 bold, Segoe UI ; Increased font size for title

; Add a draggable bar at the top
Gui, Add, Text, x0 y0 w400 h50 vDragBar BackgroundTrans, ; Draggable area

; Add title text - positioned at the top
Gui, Add, Text, x20 y0 w400 h50 cWhite BackgroundTrans, RM Insta Depo

; Reset font to normal for other controls
Gui, Font, s16 norm, Segoe UI ; Increased font size for buttons

; Add buttons at the bottom with modern styling
Gui, Font, s8 norm, Segoe UI ; Smaller font size for buttons
Gui, Add, Button, x25 y40 w150 h24 vButton1 gRunMacro1, F1: Depo
Gui, Add, Button, x25 y70 w150 h24 vButton2 gRunMacro2, F2: Loot Output
Gui, Add, Button, x25 y100 w150 h24 vButton3 gRunMacro3, F3: Loot Input
Gui, Add, Button, x25 y130 w150 h24 vButton4 gToggleAutoClick, F6: Auto Click (OFF)

; Add resolution selector button
Gui, Add, Button, x25 y160 w150 h24 vResButton gOpenResSelector, Select Resolution: Default 4k

; Customize button appearance
Loop, 5  ; Updated to include all buttons
{
    GuiControl, +BackgroundF0F0F0, Button%A_Index% ; Light gray background
}

; Add a digital clock at the bottom middle - 12-HOUR FORMAT
Gui, Font, s10 norm, Consolas  ; Monospace font works well for clocks
Gui, Add, Text, x25 y190 w160 h30 Center vDigitalClock cWhite BackgroundTrans, 00:00:00 AM

; Show with reduced width
Gui, Show, w400 h450, RM Insta Depo

; Create rounded corners
WinSet, Region, 0-0 w400 h450 r25-25, ahk_id %GuiHwnd%

; Add transparency to the window
WinSet, Transparent, 200, ahk_id %GuiHwnd%

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
Menu, ContextMenu, Add, Change Resolution, OpenResSelector
Menu, ContextMenu, Add, Exit, ExitScript

; Set up a timer to check if Last Oasis is active
SetTimer, CheckGameActive, 1000

Return

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
    Gui, 3:Show, w270 h170, Select Resolution
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

; Handle mouse movement for button hover effects
HandleMouseMove(wParam, lParam) {
    static hoveredControl := ""
    
    ; Skip hover effects if game is active
    if (isGameActive)
        return
    
    MouseGetPos,,, id, control
    
    if (control != hoveredControl) {
        if (control = "Button1" || control = "Button2" || control = "Button3" || control = "Button4" || control = "Button5") {
            GuiControl, +BackgroundD9A590, %control% ; Highlight color on hover (darker shade of background)
            hoveredControl := control
        } else if (hoveredControl != "") {
            GuiControl, +BackgroundF0F0F0, %hoveredControl% ; Restore original color
            hoveredControl := ""
        }
    }
    return
}

; Dragging functionality
StartDrag(wParam, lParam) {
    ; Only allow dragging when game is not active
    if (!isGameActive)
        PostMessage, 0xA1, 2 ; WM_NCLBUTTONDOWN
}

; Show context menu on right-click
ShowContextMenu(wParam, lParam) {
    ; Skip showing context menu if game is active
    if (isGameActive)
        return
    
    ; Update checkmark based on current state
    if (MenuState = "Pause") {
        Menu, ContextMenu, Check, Pause Hotkeys
        Menu, ContextMenu, Uncheck, Resume Hotkeys
    } else {
        Menu, ContextMenu, Check, Resume Hotkeys
        Menu, ContextMenu, Uncheck, Pause Hotkeys
    }
    
    ; Update auto-click checkmark
    if (autoClickEnabled) {
        Menu, ContextMenu, Check, Toggle Auto Click
    } else {
        Menu, ContextMenu, Uncheck, Toggle Auto Click
    }

    Menu, ContextMenu, Show
    Return
}

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
        Click, 2182, 866 Left, Up
        Click, 2182, 866 Left, Down
    }
    
    Send, {LAlt Up}
Return

F3::
Macro3:
    WinActivate, Last Oasis ahk_class UnrealWindow
    Sleep, 333
    Send, {LAlt Down}
    
    if (currentResolution = "2560x1440") {
        Click, 1032, 322 Left, Down
        Click, 1032, 322 Left, Up
        Click, 1108, 326 Left, Down
        Click, 1109, 327 Left, Up
        Click, 1010, 414 Left, Down
        Click, 1010, 414 Left, Up
        Click, 1101, 422 Left, Down
        Click, 1101, 423 Left, Up
        Click, 1031, 510 Left, Down
        Click, 1031, 510 Left, Up
        Click, 1108, 512 Left, Down
        Click, 1108, 512 Left, Up
        Click, 1018, 602 Left, Down
        Click, 1018, 602 Left, Up
        Click, 1103, 601 Left, Down
        Click, 1103, 601 Left, Up
    }
    else if (currentResolution = "1920x1080") {
        Click, 768, 226 Left, Down
        Click, 768, 226 Left, Up
        Click, 855, 241 Left, Down
        Click, 855, 241 Left, Up
        Click, 749, 308 Left, Down
        Click, 749, 308 Left, Up
        Click, 823, 309 Left, Down
        Click, 823, 309 Left, Up
        Click, 755, 362 Left, Down
        Click, 755, 362 Left, Up
        Click, 825, 369 Left, Down
        Click, 825, 369 Left, Up
        Click, 762, 431 Left, Down
        Click, 762, 431 Left, Up
        Click, 823, 437 Left, Down
        Click, 823, 437 Left, Up
    }
    else {
        ; Default 4K coordinates
        Click, 1539, 500 Left, Down
        Click, 1539, 500 Left, Up
        Click, 1647, 486 Left, Down
        Click, 1647, 486 Left, Up
        Click, 1651, 624 Left, Down
        Click, 1651, 624 Left, Up
        Click, 1549, 621 Left, Down
        Click, 1549, 620 Left, Up
        Click, 1527, 753 Left, Down
        Click, 1530, 753 Left, Up
        Click, 1692, 738 Left, Down
        Click, 1693, 738 Left, Up
        Click, 1654, 876 Left, Down
        Click, 1654, 878 Left, Up
        Click, 1544, 889 Left, Down
        Click, 1544, 889 Left, Up
        Click, 1528, 494 Left, Down
        Click, 1528, 494 Left, Up
        Click, 1655, 506 Left, Down
        Click, 1655, 506 Left, Up
        Click, 1654, 631 Left, Down
        Click, 1654, 631 Left, Up
        Click, 1548, 623 Left, Down
        Click, 1548, 623 Left, Up
        Click, 1539, 752 Left, Down
        Click, 1540, 752 Left, Up
        Click, 1656, 772 Left, Down
        Click, 1656, 772 Left, Up
        Click, 1683, 863 Left, Down
        Click, 1682, 863 Left, Up
        Click, 1539, 871 Left, Down
        Click, 1538, 871 Left, Up
    }
    
    Send, {LAlt Up}
Return

; Add this with your other label definitions

; Handler for the Cancel button in resolution selector
3GuiClose:
    Gui, 3:Hide
Return