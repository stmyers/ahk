# Windows Touchscreen Toggle (AutoHotkey)

An ultra-fast, silent AutoHotkey script to instantly enable or disable the touchscreen on Windows 10 & 11 with a modern On-Screen Display (OSD) notification.

> [!NOTE]
> This script was created specifically for the **GPD Win Max 2 (2024)** (Goodix `GXTP7385` touchscreen controller). While it dynamically auto-detects touchscreen devices on any PC, any failure to enumerate hardware will automatically fall back to the GPD Win Max 2 hardware instance ID (`HID\GXTP7385&COL01\4&36625B9A&2&0000`).

---

## Features

- 🖐️ **Instant Touchscreen Toggle**: Press <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>T</kbd> to switch touchscreen ON or OFF (< 50ms latency).
- 🎨 **Sleek Dark-Mode OSD Notification**: Modern floating toast popup at top-center of the screen.
- 🟢 **Dynamic System Tray Icon**: Real-time tray icon (`TS`) with status dot (🟢 ON / 🔴 OFF) and hover tooltip.
- ⚡ **Zero-Flash Execution**: Operates completely silently without console window popups (`CREATE_NO_WINDOW`).
- 🚀 **Silent Boot Auto-Start**: Includes a PowerShell setup script to run elevated on boot via Windows Task Scheduler **without UAC prompts**.

---

## Folder Contents

- [`ToggleTouchscreen.ahk`](file:///c:/Users/Steve/git_tree/ahk/TouchscreenToggle/ToggleTouchscreen.ahk) – **AutoHotkey v2** script (*Recommended*).
- [`ToggleTouchscreen_v1.ahk`](file:///c:/Users/Steve/git_tree/ahk/TouchscreenToggle/ToggleTouchscreen_v1.ahk) – **AutoHotkey v1** script (legacy compatibility).
- [`CreateStartupTask.ps1`](file:///c:/Users/Steve/git_tree/ahk/TouchscreenToggle/CreateStartupTask.ps1) – PowerShell script to register logon auto-start without UAC prompts.
- [`README.md`](file:///c:/Users/Steve/git_tree/ahk/TouchscreenToggle/README.md) – This documentation file.

---

## How to Run

1. Ensure [AutoHotkey v2](https://www.autohotkey.com/) is installed.
2. Double-click [`ToggleTouchscreen.ahk`](file:///c:/Users/Steve/git_tree/ahk/TouchscreenToggle/ToggleTouchscreen.ahk).
3. If prompted by Windows User Account Control (UAC), click **Yes** to grant Administrator privileges (required for Plug-and-Play device management).
4. Press <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>T</kbd> to toggle the touchscreen!

---

## Hotkey Shortcuts

| Shortcut | Action |
|---|---|
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>T</kbd> | Toggle Touchscreen ON / OFF |

*To customize hotkey, open `ToggleTouchscreen.ahk` in any text editor and change line 37 (`^!t` = Ctrl+Alt+T).*

---

## Auto-Start on Windows Boot (No UAC Prompts)

To run the script automatically when Windows boots **without getting UAC prompts**:

Right-click [`CreateStartupTask.ps1`](file:///c:/Users/Steve/git_tree/ahk/TouchscreenToggle/CreateStartupTask.ps1) -> **Run with PowerShell** (or run as Administrator in PowerShell). This registers a Task Scheduler entry (`AutoHotkey_ToggleTouchscreen`) with highest privileges.
