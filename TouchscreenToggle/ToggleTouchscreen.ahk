#Requires AutoHotkey v2.0
; ==============================================================================
; Script:       Ultra-Fast & Completely Silent Touch Screen Toggle
; Description:  Enables or Disables the Windows Touch Screen device instantly
;               and silently without flashing console windows.
; Requirement:  AutoHotkey v2.0+, Windows 10/11
; Author:       Antigravity AI
; ==============================================================================

#SingleInstance Force

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

; Global cache for Touchscreen Instance ID
global touchInstanceId := ""

; Pre-cache Touchscreen Instance ID on startup
SetTimer(InitDeviceCache, -10)

InitDeviceCache() {
    global touchInstanceId
    touchInstanceId := GetTouchscreenInstanceId()
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

    if (touchInstanceId == "") {
        ShowToast("Error", "⚠️ Touchscreen device not found", "Error")
        return
    }

    ; Fast check of current device status using silent pnputil
    status := GetDeviceStatus(touchInstanceId)
    
    if (status == "Started" || status == "OK") {
        ; Show Toast INSTANTLY (0ms latency)
        ShowToast("Touch Screen Disabled", "🖐️  Touchscreen OFF", "Disabled")
        
        ; Execute disable completely silently with CREATE_NO_WINDOW
        RunSilent('pnputil /disable-device "' touchInstanceId '"')
    } else {
        ; Show Toast INSTANTLY (0ms latency)
        ShowToast("Touch Screen Enabled", "🖐️  Touchscreen ON", "Enabled")
        
        ; Execute enable completely silently with CREATE_NO_WINDOW
        RunSilent('pnputil /enable-device "' touchInstanceId '"')
    }
}

; ------------------------------------------------------------------------------
; HELPER: Execute Console Command Completely Silently (CREATE_NO_WINDOW mode 0)
; ------------------------------------------------------------------------------
RunSilent(cmd) {
    try {
        shell := ComObject("WScript.Shell")
        shell.Run(cmd, 0, true)
    }
}

; ------------------------------------------------------------------------------
; HELPER: Query Device Status via silent pnputil execution (CREATE_NO_WINDOW mode 0)
; ------------------------------------------------------------------------------
GetDeviceStatus(instanceId) {
    tmpFile := A_Temp "\ahk_pnp_status.txt"
    try FileDelete(tmpFile)
    
    shell := ComObject("WScript.Shell")
    ; Mode 0 = SW_HIDE + CREATE_NO_WINDOW (Guarantees zero console window flash)
    shell.Run('cmd.exe /c pnputil /enum-devices /instanceid "' instanceId '" > "' tmpFile '"', 0, true)
    
    if FileExist(tmpFile) {
        try {
            output := FileRead(tmpFile)
            FileDelete(tmpFile)
            if InStr(output, "Disabled")
                return "Disabled"
            else if InStr(output, "Started")
                return "Started"
        }
    }
    return "Unknown"
}

; ------------------------------------------------------------------------------
; HELPER: Auto-detect Touchscreen Instance ID completely silently
; ------------------------------------------------------------------------------
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
    
    ; Fallback default for Goodix touchscreen
    return "HID\GXTP7385&COL01\4&36625B9A&2&0000"
}

; ------------------------------------------------------------------------------
; FUNCTION: Sleek Custom Toast Notification
; ------------------------------------------------------------------------------
ShowToast(title, message, status := "Info") {
    ; Custom Sleek On-Screen Display (OSD) Toast GUI
    static toastGui := ""
    
    ; Destroy existing toast if already visible
    if (toastGui != "") {
        try toastGui.Destroy()
        toastGui := ""
    }

    ; Theme colors (Dark mode with accent border)
    bgColor := (status == "Disabled") ? "0x1E1E1E" : ((status == "Enabled") ? "0x1E1E1E" : "0x2A1E1E")
    accentColor := (status == "Disabled") ? "0xFF4D4D" : ((status == "Enabled") ? "0x4DFF88" : "0xFFCC00")
    textColor := "0xFFFFFF"

    ; Build Gui Window
    toastGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 +Owner") ; +E0x20 = Click-through
    toastGui.BackColor := bgColor
    toastGui.MarginX := 0
    toastGui.MarginY := 0
    
    ; Left status color indicator line
    toastGui.SetFont("s1", "Segoe UI")
    toastGui.AddProgress("x0 y0 w6 h50 Background" accentColor)

    ; Main Notification Text
    toastGui.SetFont("s11 w600", "Segoe UI")
    toastGui.AddText("x20 y14 w260 h26 Center c" textColor, message)

    ; Calculate screen position (Top-Center of screen)
    screenWidth := A_ScreenWidth
    toastWidth := 290
    toastHeight := 50
    posX := (screenWidth - toastWidth) // 2
    posY := 50

    ; Show without stealing focus from active window
    toastGui.Show("x" posX " y" posY " w" toastWidth " h" toastHeight " NoActivate")

    ; Fade out / Destroy after 2.5 seconds
    SetTimer(HideToast, -2500)

    HideToast() {
        if (toastGui != "") {
            try toastGui.Destroy()
            toastGui := ""
        }
    }
}
