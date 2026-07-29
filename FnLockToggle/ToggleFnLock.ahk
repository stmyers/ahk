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

; Global state tracking Fn Lock status
global fnLockEnabled := false

; Set up System Tray Menu
A_TrayMenu.Delete()
A_TrayMenu.Add("Toggle Fn Lock`tCtrl+Alt+L", (*) => ToggleFnLock())
A_TrayMenu.Default := "Toggle Fn Lock`tCtrl+Alt+L"
A_TrayMenu.Add()
A_TrayMenu.Add("Reload Script`tCtrl+Alt+R", (*) => Reload())
A_TrayMenu.Add("Exit", (*) => ExitApp())

; Initialize Tray Icon & set delayed refresh timers for Explorer startup
UpdateTrayIcon(fnLockEnabled)
SetTimer(RefreshTrayIcon, -3000)
SetTimer(RefreshTrayIcon, -10000)

RefreshTrayIcon() {
    global fnLockEnabled
    UpdateTrayIcon(fnLockEnabled)
}

; ------------------------------------------------------------------------------
; HOTKEY ASSIGNMENTS
; Ctrl + Alt + L = Toggle Fn Lock
; Ctrl + Alt + R = Reload Script
; ------------------------------------------------------------------------------
^!l::ToggleFnLock()
^!r::Reload()

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

; ------------------------------------------------------------------------------
; HELPER: Adjust Screen Brightness via WMI
; ------------------------------------------------------------------------------
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
; HELPER: Dynamic Tray Icon Generator
; ------------------------------------------------------------------------------
UpdateTrayIcon(isEnabled) {
    A_IconTip := "Fn Lock: " . (isEnabled ? "ON" : "OFF") . " (Ctrl+Alt+L)"
    hIcon := CreateStateIcon("Fn", isEnabled)
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
; FUNCTION: Sleek Custom Toast Notification (OSD)
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
