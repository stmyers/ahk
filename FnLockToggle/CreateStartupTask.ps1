# ==============================================================================
# Script:       Register Portable Boot Task for Fn Lock Toggle
# Description:  Creates a Windows Scheduled Task to run ToggleFnLock.ahk
#               at logon WITHOUT UAC prompts on any system.
# ==============================================================================

# Self-elevate the script if not running as Administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator privileges to register Scheduled Task..." -ForegroundColor Yellow
    $psExe = (Get-Process -Id $PID).Path
    Start-Process $psExe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Wait
    exit
}

# Dynamically locate AutoHotkey v2 executable using system environment variables
$ahkExe = (Get-Command AutoHotkey64.exe -ErrorAction SilentlyContinue).Path

if (-not $ahkExe) {
    $candidates = @(
        "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe",
        "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe",
        "${env:ProgramFiles(x86)}\AutoHotkey\v2\AutoHotkey64.exe"
    )
    foreach ($cand in $candidates) {
        if (Test-Path $cand) {
            $ahkExe = $cand
            break
        }
    }
}

# Dynamically resolve script path relative to this PowerShell script location
$scriptPath = Join-Path $PSScriptRoot "ToggleFnLock.ahk"
$taskName = "AutoHotkey_ToggleFnLock"

if (-not (Test-Path $ahkExe)) {
    Write-Error "AutoHotkey v2 executable not found on system!"
    exit 1
}

if (-not (Test-Path $scriptPath)) {
    Write-Error "Script file not found at: $scriptPath"
    exit 1
}

# Unregister previous task instance if present
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

# Register new Task Scheduler task using current logon user environment with 3s delay for Explorer startup
$action = New-ScheduledTaskAction -Execute $ahkExe -Argument "`"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$trigger.Delay = "PT3S"
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0 -MultipleInstances StopExisting

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force -ErrorAction Stop
Write-Host "Task '$taskName' successfully registered for user '$env:USERNAME'!" -ForegroundColor Green
