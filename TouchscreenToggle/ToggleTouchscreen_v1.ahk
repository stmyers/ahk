; ==============================================================================
; Script:       Ultra-Fast & Silent Touch Screen Toggle (AHK v1)
; Description:  Enables or Disables the Windows Touch Screen device silently.
; Requirement:  AutoHotkey v1.1+, Windows 10/11
; ==============================================================================

#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

if not A_IsAdmin {
    try {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%"
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}

global touchInstanceId := "HID\GXTP7385&COL01\4&36625B9A&2&0000"

^!t::ToggleTouchscreen()
^!r::Reload

SetTimer, RefreshTray, -3000
SetTimer, RefreshTray, -10000

RefreshTray:
    status := GetDeviceStatus(touchInstanceId)
return

ToggleTouchscreen() {
    status := GetDeviceStatus(touchInstanceId)
    
    if (status = "Started" or status = "OK") {
        ShowToast("Touch Screen Disabled", "🖐️  Touchscreen OFF", "Disabled")
        RunSilent("pnputil /disable-device """ . touchInstanceId . """")
    } else {
        ShowToast("Touch Screen Enabled", "🖐️  Touchscreen ON", "Enabled")
        RunSilent("cmd.exe /c pnputil /enable-device ""ACPI\GXTP7385\3&c8c3232&0"" & pnputil /enable-device """ . touchInstanceId . """")
    }
}

RunSilent(cmd) {
    try {
        shell := ComObject("WScript.Shell")
        shell.Run(cmd, 0, true)
    }
}

GetDeviceStatus(instanceId) {
    tmpFile := A_Temp . "\ahk_pnp_status.txt"
    FileDelete, %tmpFile%
    
    shell := ComObject("WScript.Shell")
    shell.Run("cmd.exe /c pnputil /enum-devices /instanceid """ . instanceId . """ > """ . tmpFile . """", 0, true)
    
    if FileExist(tmpFile) {
        FileRead, output, %tmpFile%
        FileDelete, %tmpFile%
        if InStr(output, "Started")
            return "Started"
        else if InStr(output, "Disabled")
            return "Disabled"
        else if InStr(output, "Disconnected")
            return "Disconnected"
    }
    return "Unknown"
}

ShowToast(title, message, status := "Info") {
    Gui, Toast:Destroy
    bgColor := (status == "Disabled") ? "1E1E1E" : ((status == "Enabled") ? "1E1E1E" : "2A1E1E")
    accentColor := (status == "Disabled") ? "FF4D4D" : ((status == "Enabled") ? "4DFF88" : "FFCC00")

    Gui, Toast:+AlwaysOnTop -Caption +ToolWindow +E0x20 +Owner
    Gui, Toast:Color, %bgColor%
    
    Gui, Toast:Add, Progress, x0 y0 w6 h50 Background%accentColor%
    Gui, Toast:Font, s11 w600 cWhite, Segoe UI
    Gui, Toast:Add, Text, x20 y14 w260 h26 Center, %message%

    posX := (A_ScreenWidth - 290) // 2
    Gui, Toast:Show, x%posX% y50 w290 h50 NoActivate

    SetTimer, HideToast, -2500
    return

    HideToast:
        Gui, Toast:Destroy
    return
}
