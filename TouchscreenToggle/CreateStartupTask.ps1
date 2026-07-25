# Creates a Windows Scheduled Task to run ToggleTouchscreen.ahk as Administrator at logon WITHOUT UAC prompts
$ahkExe = "C:\Users\Steve\AppData\Local\Programs\AutoHotkey\v2\AutoHotkey64.exe"
$scriptPath = Join-Path $PSScriptRoot "ToggleTouchscreen.ahk"
$taskName = "AutoHotkey_ToggleTouchscreen"

$action = New-ScheduledTaskAction -Execute $ahkExe -Argument "`"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force
Write-Output "Task '$taskName' successfully registered for $scriptPath!"
