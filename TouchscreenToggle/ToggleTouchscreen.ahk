#Requires AutoHotkey v2.0
; ==============================================================================
; Script:       Ultra-Fast & Completely Silent Touch Screen Toggle
; Description:  Enables or Disables the Windows Touch Screen device instantly
;               and silently with dark-mode OSD and System Tray icon.
; Requirement:  AutoHotkey v2.0+, Windows 10/11
; Author:       Antigravity AI
; ==============================================================================

#SingleInstance Force
Persistent(true)

; Automatically request Administrator privileges (required for PnP device management)
if not A_IsAdmin {
    try {
        if A_IsCompiled
            Run('*RunAs "' A_ScriptFullPath '"')
        else
            Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"')
    }
    ExitApp()
}

; Ensure System Tray Icon is visible
A_IconHidden := false

; Global cache for Touchscreen Instance ID
global touchInstanceId := "HID\GXTP7385&COL01\4&36625B9A&2&0000"

; Set up System Tray Menu
A_TrayMenu.Delete()
A_TrayMenu.Add("Toggle Touchscreen`tCtrl+Alt+T", (*) => ToggleTouchscreen())
A_TrayMenu.Default := "Toggle Touchscreen`tCtrl+Alt+T"
A_TrayMenu.Add()
A_TrayMenu.Add("Reload Script`tCtrl+Alt+R", (*) => Reload())
A_TrayMenu.Add("Exit", (*) => ExitApp())

; Pre-cache Touchscreen Instance ID & update Tray Icon
SetTimer(InitDeviceCache, -10)
SetTimer(RefreshTrayIcon, -2000)
SetTimer(RefreshTrayIcon, -6000)

InitDeviceCache() {
    global touchInstanceId
    detectedId := GetTouchscreenInstanceId()
    if (detectedId != "")
        touchInstanceId := detectedId
    RefreshTrayIcon()
}

RefreshTrayIcon() {
    global touchInstanceId
    status := GetDeviceStatus(touchInstanceId)
    UpdateTrayIcon(status == "Started" || status == "OK")
}

; ------------------------------------------------------------------------------
; HOTKEY ASSIGNMENTS
; Ctrl + Alt + T = Toggle Touchscreen
; Ctrl + Alt + R = Reload Script
; ------------------------------------------------------------------------------
^!t::ToggleTouchscreen()
^!r::Reload()

; ------------------------------------------------------------------------------
; FUNCTION: Ultra-Fast & Silent Touchscreen Toggle
; ------------------------------------------------------------------------------
ToggleTouchscreen() {
    global touchInstanceId
    
    if (touchInstanceId == "")
        touchInstanceId := GetTouchscreenInstanceId()

    status := GetDeviceStatus(touchInstanceId)
    
    if (status == "Started" || status == "OK") {
        ; Touchscreen is currently ON -> Disable it
        UpdateTrayIcon(false)
        ShowToast("Touch Screen Disabled", "🖐️  Touchscreen OFF", "Disabled")
        RunSilent('pnputil /disable-device "' touchInstanceId '"')
    } else {
        ; Touchscreen is currently OFF -> Enable it
        UpdateTrayIcon(true)
        ShowToast("Touch Screen Enabled", "🖐️  Touchscreen ON", "Enabled")
        RunSilent('cmd.exe /c pnputil /enable-device "ACPI\GXTP7385\3&c8c3232&0" & pnputil /enable-device "' touchInstanceId '"')
    }
}

RunSilent(cmd) {
    try {
        shell := ComObject("WScript.Shell")
        shell.Run(cmd, 0, true)
    }
}

GetDeviceStatus(instanceId) {
    tmpFile := A_Temp "\ahk_pnp_status.txt"
    try FileDelete(tmpFile)
    
    shell := ComObject("WScript.Shell")
    shell.Run('cmd.exe /c pnputil /enum-devices /instanceid "' instanceId '" > "' tmpFile '"', 0, true)
    
    if FileExist(tmpFile) {
        try {
            output := FileRead(tmpFile)
            FileDelete(tmpFile)
            if InStr(output, "Started")
                return "Started"
            else if InStr(output, "Disabled")
                return "Disabled"
            else if InStr(output, "Disconnected")
                return "Disconnected"
        }
    }
    return "Unknown"
}

GetTouchscreenInstanceId() {
    tmpFile := A_Temp "\ahk_pnp_enum.txt"
    try FileDelete(tmpFile)

    shell := ComObject("WScript.Shell")
    shell.Run('cmd.exe /c pnputil /enum-devices /class HIDClass > "' tmpFile '"', 0, true)

    if FileExist(tmpFile) {
        try {
            output := FileRead(tmpFile)
            FileDelete(tmpFile)

            lines := StrSplit(output, "`n", "`r")
            currentId := ""
            
            for line in lines {
                if RegExMatch(line, "i)Instance ID:\s*(.+)", &m) {
                    currentId := Trim(m[1])
                } else if RegExMatch(line, "i)Device Description:\s*.*touch\s*screen", &m) {
                    if (currentId != "")
                        return currentId
                }
            }
        }
    }
    
    return "HID\GXTP7385&COL01\4&36625B9A&2&0000"
}

; ------------------------------------------------------------------------------
; HELPER: Tray Icon Generator
; ------------------------------------------------------------------------------
UpdateTrayIcon(isEnabled) {
    A_IconTip := "Touchscreen: " . (isEnabled ? "ON" : "OFF") . " (Ctrl+Alt+T)"
    try {
        if (isEnabled)
            TraySetIcon("imageres.dll", 100) ; Clean Touch Display Icon
        else
            TraySetIcon("imageres.dll", 98)  ; Disabled Display Icon
    } catch {
        try {
            if (isEnabled)
                TraySetIcon("shell32.dll", 16)
            else
                TraySetIcon("shell32.dll", 110)
        }
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
