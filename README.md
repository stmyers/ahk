# AutoHotkey (AHK) Scripts Collection

A collection of custom AutoHotkey (v2 & v1) scripts for Windows automation, hardware controls, and productivity enhancements.

## Repositories & Scripts Included

### ⌨️ [Fn Lock Toggle](FnLockToggle/)
A script to toggle Fn Lock mode, remapping top-row F1-F12 keys to media, volume, and brightness controls with custom dark-mode On-Screen Display (OSD) notifications.

> [!NOTE]
> Configured for the **GPD Win Max 2 (2024)** keyboard layout legends.

- **Hotkey**: <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>L</kbd>
- **Features**: Custom sleek OSD toast popup, media/volume/brightness control remappings, UAC-free Task Scheduler auto-start on boot.
- [View Fn Lock Toggle Documentation](FnLockToggle/README.md)

---

### 🖐️ [Touchscreen Toggle](TouchscreenToggle/)
An ultra-fast, silent script to toggle your Windows touchscreen ON and OFF with custom dark-mode On-Screen Display (OSD) notifications.

> [!NOTE]
> Created for the **GPD Win Max 2 (2024)** (Goodix `GXTP7385` touchscreen digitizer). Any failure to automatically enumerate hardware will fall back to the GPD Win Max 2 default hardware instance ID.

- **Hotkey**: <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>T</kbd>
- **Features**: Fast `< 50ms` execution via `pnputil.exe`, zero console window flashing, includes UAC-free Task Scheduler auto-start on boot.
- [View Touchscreen Toggle Documentation](TouchscreenToggle/README.md)
