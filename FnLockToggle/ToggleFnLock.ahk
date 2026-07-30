#Requires AutoHotkey v2.0
; ==============================================================================
; Script:       Fn Lock Toggle with Custom Dynamic Tray Icon & Sleek OSD
; Description:  Toggles software Fn Lock to switch top-row F1-F12 keys
;               between standard Function keys and Multimedia controls.
; Device:       Configured for GPD Win Max 2 (2024) keyboard layout
; Requirement:  AutoHotkey v2.0+, Windows 10/11
; Author:       Antigravity AI
; ==============================================================================

#SingleInstance Force
Persistent(true)

A_IconHidden := false

; Global state tracking Fn Lock status
global fnLockEnabled := false

; Set up System Tray Menu
A_TrayMenu.Delete()
A_TrayMenu.Add("Toggle Fn Lock`tCtrl+Alt+L", (*) => ToggleFnLock())
A_TrayMenu.Default := "Toggle Fn Lock`tCtrl+Alt+L"
A_TrayMenu.Add()
A_TrayMenu.Add("Reload Script`tCtrl+Alt+R", (*) => Reload())
A_TrayMenu.Add("Exit", (*) => ExitApp())

; Update Tray Icon on startup
UpdateTrayIcon(fnLockEnabled)
SetTimer(RefreshTrayIcon, -2000)
SetTimer(RefreshTrayIcon, -6000)

RefreshTrayIcon() {
    global fnLockEnabled
    UpdateTrayIcon(fnLockEnabled)
}

; ------------------------------------------------------------------------------
; HOTKEY ASSIGNMENTS
; Ctrl + Alt + L = Toggle Fn Lock
; Ctrl + Alt + R = Reload Script (Pass-through ~ to reload all AHK scripts)
; ------------------------------------------------------------------------------
^!l::ToggleFnLock()
~^!r::Reload()

; ------------------------------------------------------------------------------
; FUNCTION: Toggle Fn Lock State, Tray Icon & OSD Notification
; ------------------------------------------------------------------------------
ToggleFnLock() {
    global fnLockEnabled
    fnLockEnabled := !fnLockEnabled
    
    UpdateTrayIcon(fnLockEnabled)
    
    if (fnLockEnabled) {
        ShowToast("Fn Lock Enabled", "⌨️  Fn Lock ON", "Enabled")
    } else {
        ShowToast("Fn Lock Disabled", "⌨️  Fn Lock OFF", "Disabled")
    }
}

; ------------------------------------------------------------------------------
; RE-MAPPED TOP ROW KEYS (Active only when Fn Lock is ENABLED)
; ------------------------------------------------------------------------------
#HotIf fnLockEnabled

*F1::ShowBrightnessToast(AdjustBrightness(-10))
*F2::ShowBrightnessToast(AdjustBrightness(10))
*F3::Send("{Volume_Mute}")
*F4::Send("{Volume_Down}")
*F5::Send("{Volume_Up}")
*F6::Send("{Media_Stop}")
*F7::Send("{Media_Prev}")
*F8::Send("{Media_Play_Pause}")
*F9::Send("{Media_Next}")
*F10::Send("{PrintScreen}")
*F11::Send("{ScrollLock}")
*F12::Send("{Insert}")

#HotIf

ShowBrightnessToast(level) {
    if (level >= 0)
        ShowToast("Brightness", "☀️  Brightness " . level . "%", "Enabled")
}

AdjustBrightness(change) {
    newBrightness := -1
    try {
        wmi := ComObjGet("winmgmts:\\.\root\wmi")
        methods := wmi.ExecQuery("SELECT * FROM WmiMonitorBrightnessMethods")
        currentObj := wmi.ExecQuery("SELECT * FROM WmiMonitorBrightness")
        
        currentBrightness := 50
        for item in currentObj {
            currentBrightness := item.CurrentBrightness
            break
        }
        
        newBrightness := Max(0, Min(100, currentBrightness + change))
        
        for method in methods {
            method.WmiSetBrightness(1, newBrightness)
        }
    }
    return newBrightness
}

; ------------------------------------------------------------------------------
; HELPER: Custom .ico Tray Icon Loader
; ------------------------------------------------------------------------------
UpdateTrayIcon(isEnabled) {
    A_IconTip := "Fn Lock: " . (isEnabled ? "ON" : "OFF") . " (Ctrl+Alt+L)"
    iconFile := A_ScriptDir . "\" . (isEnabled ? "fn_on.ico" : "fn_off.ico")
    if FileExist(iconFile) {
        try TraySetIcon(iconFile)
    }
}

ShowToast(title, message, status := "Info") {
    static toastGui := ""
    
    if (toastGui != "") {
        try toastGui.Destroy()
        toastGui := ""
    }

    bgColor := (status == "Disabled") ? "0x1E1E1E" : ((status == "Enabled") ? "0x1E1E1E" : "0x2A1E1E")
    accentColor := (status == "Disabled") ? "0xFF4D4D" : ((status == "Enabled") ? "0x4DFF88" : "0xFFCC00")
    textColor := "0xFFFFFF"

    toastGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 +Owner")
    toastGui.BackColor := bgColor
    toastGui.MarginX := 0
    toastGui.MarginY := 0
    
    toastGui.SetFont("s1", "Segoe UI")
    toastGui.AddProgress("x0 y0 w6 h50 Background" accentColor)

    toastGui.SetFont("s11 w600", "Segoe UI")
    toastGui.AddText("x20 y14 w260 h26 Center c" textColor, message)

    screenWidth := A_ScreenWidth
    toastWidth := 290
    toastHeight := 50
    posX := (screenWidth - toastWidth) // 2
    posY := 50

    toastGui.Show("x" posX " y" posY " w" toastWidth " h" toastHeight " NoActivate")

    SetTimer(HideToast, -2500)

    HideToast() {
        if (toastGui != "") {
            try toastGui.Destroy()
            toastGui := ""
        }
    }
}
