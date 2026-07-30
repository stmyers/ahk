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
global touchInstanceId := "HID\GXTP7385&COL01\4&36625B9A&2&0000"

; Set up System Tray Menu
A_TrayMenu.Delete()
A_TrayMenu.Add("Toggle Touchscreen`tCtrl+Alt+T", (*) => ToggleTouchscreen())
A_TrayMenu.Default := "Toggle Touchscreen`tCtrl+Alt+T"
A_TrayMenu.Add()
A_TrayMenu.Add("Reload Script`tCtrl+Alt+R", (*) => Reload())
A_TrayMenu.Add("Exit", (*) => ExitApp())

; Listen for Windows Explorer TaskbarCreated message (fires when Explorer loads/restarts)
global msgTaskbarCreated := DllCall("RegisterWindowMessage", "Str", "TaskbarCreated")
if (msgTaskbarCreated) {
    OnMessage(msgTaskbarCreated, (*) => SetTimer(ForceReaddTrayIcon, -500))
}

; Startup timers to forcibly re-register Tray Icon in System Tray during boot
SetTimer(InitDeviceCache, -10)
SetTimer(ForceReaddTrayIcon, -1000)
SetTimer(ForceReaddTrayIcon, -3000)
SetTimer(ForceReaddTrayIcon, -7000)
SetTimer(ForceReaddTrayIcon, -15000)

InitDeviceCache() {
    global touchInstanceId
    detectedId := GetTouchscreenInstanceId()
    if (detectedId != "")
        touchInstanceId := detectedId
    ForceReaddTrayIcon()
}

ForceReaddTrayIcon() {
    try {
        A_IconHidden := true
        Sleep(50)
        A_IconHidden := false
        RefreshTrayIcon()
    }
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

    ; Fast check of current device status using silent pnputil
    status := GetDeviceStatus(touchInstanceId)
    
    if (status == "Started" || status == "OK") {
        ; Touchscreen is currently ON -> Disable it
        UpdateTrayIcon(false)
        ShowToast("Touch Screen Disabled", "🖐️  Touchscreen OFF", "Disabled")
        
        ; Disable touchscreen interface
        RunSilent('pnputil /disable-device "' touchInstanceId '"')
    } else {
        ; Touchscreen is currently OFF / Disabled / Disconnected -> Enable it
        UpdateTrayIcon(true)
        ShowToast("Touch Screen Enabled", "🖐️  Touchscreen ON", "Enabled")
        
        ; Enable parent I2C bus controller AND touchscreen interface
        RunSilent('cmd.exe /c pnputil /enable-device "ACPI\GXTP7385\3&c8c3232&0" & pnputil /enable-device "' touchInstanceId '"')
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
    
    ; Fallback default for GPD Win Max 2 (2024) Goodix touchscreen
    return "HID\GXTP7385&COL01\4&36625B9A&2&0000"
}

; ------------------------------------------------------------------------------
; HELPER: Dynamic Tray Icon Generator
; ------------------------------------------------------------------------------
UpdateTrayIcon(isEnabled) {
    A_IconTip := "Touchscreen: " . (isEnabled ? "ON" : "OFF") . " (Ctrl+Alt+T)"
    hIcon := CreateStateIcon("TS", isEnabled)
    if (hIcon) {
        try TraySetIcon("HICON:" . hIcon)
    }
}

CreateStateIcon(label, isEnabled) {
    width := 32
    height := 32
    
    hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
    memDC := DllCall("CreateCompatibleDC", "Ptr", hdc, "Ptr")
    hBmp := DllCall("CreateCompatibleBitmap", "Ptr", hdc, "Int", width, "Int", height, "Ptr")
    oldBmp := DllCall("SelectObject", "Ptr", memDC, "Ptr", hBmp, "Ptr")
    
    maskDC := DllCall("CreateCompatibleDC", "Ptr", hdc, "Ptr")
    hMaskBmp := DllCall("CreateBitmap", "Int", width, "Int", height, "UInt", 1, "UInt", 1, "Ptr", 0, "Ptr")
    oldMaskBmp := DllCall("SelectObject", "Ptr", maskDC, "Ptr", hMaskBmp, "Ptr")
    
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
    
    bgColor := 0x1E1E1E
    bgrAccent := isEnabled ? 0x4DFF88 : 0x4D4DFF
    textColor := isEnabled ? 0xFFFFFF : 0x888888
    
    hBrushBg := DllCall("CreateSolidBrush", "UInt", bgColor, "Ptr")
    rect := Buffer(16, 0)
    NumPut("Int", 0, rect, 0)
    NumPut("Int", 0, rect, 4)
    NumPut("Int", width, rect, 8)
    NumPut("Int", height, rect, 12)
    DllCall("FillRect", "Ptr", memDC, "Ptr", rect, "Ptr", hBrushBg)
    DllCall("DeleteObject", "Ptr", hBrushBg)
    
    hBrushDot := DllCall("CreateSolidBrush", "UInt", bgrAccent, "Ptr")
    oldBrush := DllCall("SelectObject", "Ptr", memDC, "Ptr", hBrushDot, "Ptr")
    DllCall("Ellipse", "Ptr", memDC, "Int", 20, "Int", 20, "Int", 30, "Int", 30)
    DllCall("SelectObject", "Ptr", memDC, "Ptr", oldBrush)
    DllCall("DeleteObject", "Ptr", hBrushDot)
    
    DllCall("SetBkMode", "Ptr", memDC, "Int", 1)
    DllCall("SetTextColor", "Ptr", memDC, "UInt", textColor)
    hFont := DllCall("CreateFontW", "Int", -16, "Int", 0, "Int", 0, "Int", 0, "Int", 700, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "Str", "Segoe UI", "Ptr")
    oldFont := DllCall("SelectObject", "Ptr", memDC, "Ptr", hFont, "Ptr")
    
    textRect := Buffer(16, 0)
    NumPut("Int", 1, textRect, 0)
    NumPut("Int", 5, textRect, 4)
    NumPut("Int", 21, textRect, 8)
    NumPut("Int", 25, textRect, 12)
    DllCall("DrawTextW", "Ptr", memDC, "Str", label, "Int", -1, "Ptr", textRect, "UInt", 0x1)
    
    DllCall("SelectObject", "Ptr", memDC, "Ptr", oldFont)
    DllCall("DeleteObject", "Ptr", hFont)
    
    hBrushMask := DllCall("CreateSolidBrush", "UInt", 0, "Ptr")
    DllCall("FillRect", "Ptr", maskDC, "Ptr", rect, "Ptr", hBrushMask)
    DllCall("DeleteObject", "Ptr", hBrushMask)
    
    DllCall("SelectObject", "Ptr", memDC, "Ptr", oldBmp)
    DllCall("SelectObject", "Ptr", maskDC, "Ptr", oldMaskBmp)
    DllCall("DeleteDC", "Ptr", memDC)
    DllCall("DeleteDC", "Ptr", maskDC)
    
    iconInfo := Buffer(A_PtrSize == 8 ? 32 : 20, 0)
    NumPut("Int", 1, iconInfo, 0)
    NumPut("Ptr", hMaskBmp, iconInfo, A_PtrSize == 8 ? 16 : 12)
    NumPut("Ptr", hBmp, iconInfo, A_PtrSize == 8 ? 24 : 16)
    
    hIcon := DllCall("CreateIconIndirect", "Ptr", iconInfo, "Ptr")
    
    DllCall("DeleteObject", "Ptr", hBmp)
    DllCall("DeleteObject", "Ptr", hMaskBmp)
    
    return hIcon
}

; ------------------------------------------------------------------------------
; FUNCTION: Sleek Custom Toast Notification
; ------------------------------------------------------------------------------
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
