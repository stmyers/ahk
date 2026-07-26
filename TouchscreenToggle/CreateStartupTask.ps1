$ahkExe = "C:\Users\Steve\AppData\Local\Programs\AutoHotkey\v2\AutoHotkey64.exe"
$scriptPath = "c:\Users\Steve\git_tree\ahk\TouchscreenToggle\ToggleTouchscreen.ahk"
$taskName = "AutoHotkey_ToggleTouchscreen"

Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

$action = New-ScheduledTaskAction -Execute $ahkExe -Argument "`"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force
