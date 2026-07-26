# Windows Fn Lock Toggle (AutoHotkey)

A lightweight AutoHotkey v2 script to toggle **Fn Lock** mode on keyboards and laptops, featuring a custom dark-mode On-Screen Display (OSD) notification.

---

## Features

- ⌨️ **Fn Lock Toggle**: Press <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>L</kbd> to toggle Fn Lock state ON or OFF instantly.
- 🎨 **Sleek Dark-Mode OSD Notification**: Modern floating toast popup at top-center of the screen matching the touchscreen toggle aesthetic.
- 🟢 **Dynamic System Tray Icon**: Real-time tray icon (`Fn`) with status dot (🟢 ON / 🔴 OFF) and hover tooltip.
- 🔊 **Media & System Controls**: Automatically remaps top-row `F1`-`F12` keys to volume, media controls, screen brightness percentage OSD, and system shortcuts when Fn Lock is ON.
- 🚀 **Silent Boot Auto-Start**: Includes a PowerShell setup script to run automatically on boot via Windows Task Scheduler **without UAC prompts**.

---

## Folder Contents

- [`ToggleFnLock.ahk`](ToggleFnLock.ahk) – **AutoHotkey v2** main script.
- [`CreateStartupTask.ps1`](CreateStartupTask.ps1) – PowerShell script to register logon auto-start without UAC prompts.
- [`README.md`](README.md) – Documentation file.

---

## How to Run

1. Ensure [AutoHotkey v2](https://www.autohotkey.com/) is installed.
2. Double-click [`ToggleFnLock.ahk`](ToggleFnLock.ahk).
3. Press <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>L</kbd> to toggle Fn Lock!

---

## Hotkey Shortcut & Default Key Mappings

| Shortcut / Key | Fn Lock OFF | Fn Lock ON |
|---|---|---|
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>L</kbd> | Toggle Fn Lock | Toggle Fn Lock |
| <kbd>F1</kbd> | `F1` | Decrease Brightness (-10%) |
| <kbd>F2</kbd> | `F2` | Increase Brightness (+10%) |
| <kbd>F3</kbd> | `F3` | Mute (`Volume_Mute`) |
| <kbd>F4</kbd> | `F4` | Volume Down (`Volume_Down`) |
| <kbd>F5</kbd> | `F5` | Volume Up (`Volume_Up`) |
| <kbd>F6</kbd> | `F6` | Stop Media (`Media_Stop`) |
| <kbd>F7</kbd> | `F7` | Previous Track (`Media_Prev`) |
| <kbd>F8</kbd> | `F8` | Play / Pause (`Media_Play_Pause`) |
| <kbd>F9</kbd> | `F9` | Next Track (`Media_Next`) |
| <kbd>F10</kbd> | `F10` | Print Screen (`PrintScreen`) |
| <kbd>F11</kbd> | `F11` | Scroll Lock (`ScrollLock`) |
| <kbd>F12</kbd> | `F12` | Insert (`Insert`) |

*To customize hotkeys or key actions, edit `ToggleFnLock.ahk` in any text editor.*

---

## Auto-Start on Windows Boot (No UAC Prompts)

To run the script automatically when Windows boots:

Right-click [`CreateStartupTask.ps1`](CreateStartupTask.ps1) -> **Run with PowerShell** (or run as Administrator in PowerShell). This registers a Task Scheduler entry (`AutoHotkey_ToggleFnLock`) with highest privileges.
