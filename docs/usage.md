# Portal Interfaces & Usage Guide

Fjord (`wormhole`) provides a comprehensive implementation of the Freedesktop XDG Desktop Portal specification. This guide details each supported portal interface, its functionality, and methods for direct CLI verification.

---

## Complete Suite Overview

Fjord implements all 24 standard portal interfaces:

| Interface | D-Bus Identifier | Primary Capability | UI Modal |
| :--- | :--- | :--- | :---: |
| **ScreenCast** | `org.freedesktop.impl.portal.ScreenCast` | Display & window capture via PipeWire | Yes |
| **Screenshot** | `org.freedesktop.impl.portal.Screenshot` | Region, window & fullscreen snapshots | Yes |
| **PickColor** | `org.freedesktop.impl.portal.Screenshot.PickColor` | Precision pixel magnifier & color picker | Yes |
| **FileChooser** | `org.freedesktop.impl.portal.FileChooser` | Open, save, folder & multi-file picker | Yes |
| **AppChooser** | `org.freedesktop.impl.portal.AppChooser` | MIME & protocol application selector | Yes |
| **Access** | `org.freedesktop.impl.portal.Access` | Device & security permission prompts | Yes |
| **Account** | `org.freedesktop.impl.portal.Account` | User identity & avatar resolution | Yes |
| **DynamicLauncher** | `org.freedesktop.impl.portal.DynamicLauncher` | PWA & desktop shortcut installation | Yes |
| **Wallpaper** | `org.freedesktop.impl.portal.Wallpaper` | Wallpaper preview & target assignment | Yes |
| **Background** | `org.freedesktop.impl.portal.Background` | Background run & autostart permission | Backend |
| **Camera** | `org.freedesktop.impl.portal.Camera` | PipeWire camera device discovery | Backend |
| **Clipboard** | `org.freedesktop.impl.portal.Clipboard` | Wayland clipboard bridge | Backend |
| **Email** | `org.freedesktop.impl.portal.Email` | System mail client composition dispatch | Backend |
| **GlobalShortcuts** | `org.freedesktop.impl.portal.GlobalShortcuts` | Desktop-wide shortcut binding & trigger | Backend |
| **Inhibit** | `org.freedesktop.impl.portal.Inhibit` | Sleep, idle & notification inhibition | Backend |
| **InputCapture** | `org.freedesktop.impl.portal.InputCapture` | Virtual KVM pointer & keyboard capture | Backend |
| **Location** | `org.freedesktop.impl.portal.Location` | Geolocation provider bridge | Backend |
| **Lockdown** | `org.freedesktop.impl.portal.Lockdown` | Enterprise kiosk & desktop restrictions | Backend |
| **Notification** | `org.freedesktop.impl.portal.Notification` | Desktop notification emitter & actions | Backend |
| **Print** | `org.freedesktop.impl.portal.Print` | Print dialog & CUPS spooling handoff | Backend |
| **Realtime** | `org.freedesktop.impl.portal.Realtime` | Thread scheduling priority permissions | Backend |
| **RemoteDesktop** | `org.freedesktop.impl.portal.RemoteDesktop` | Input injection with PipeWire streams | Backend |
| **Secret** | `org.freedesktop.impl.portal.Secret` | App-specific cryptographic keys | Backend |
| **Settings** | `org.freedesktop.impl.portal.Settings` | Read system color-scheme & accents | Backend |
| **Usb** | `org.freedesktop.impl.portal.Usb` | USB device pass-through mediation | Backend |

---

## ScreenCast Sharing

The ScreenCast portal lets applications capture displays or specific application windows via PipeWire.

### Interface Features

- **Monitors & Windows Tabs**: Seamlessly toggle between sharing full display outputs or individual toplevel windows.
- **Hyprland IPC Discovery**: Window choices display active application icons, titles, and workspace designations.
- **Cursor Modes**:
  - `Hidden` (0): Cursor is stripped from the video stream.
  - `Embedded` (1): Cursor is drawn directly onto video frames.
  - `Metadata` (2): Cursor coordinates are sent out-of-band via PipeWire stream metadata.
- **Session Restoring**: Emits restore tokens allowing browsers to reconnect to previously shared screens without prompting the user repeatedly.

### Direct CLI Testing

```bash
# Basic screen share prompt
wormhole --screencast --app-id "org.mozilla.firefox"

# Multi-source selection with displays and windows enabled
wormhole --screencast --app-id "com.obsproject.Studio" --types 3 --multiple
```

---

## Screenshot & Color Picker

The Screenshot portal handles snapshot capture and interactive pixel sampling.

### Screenshot Capture

- **Interactive Region Crop**: Drag to select any rectangle on the screen with real-time width/height indicators.
- **Loupe Magnifier**: A 10x magnified view centered around the cursor with pixel-grid outlines for pixel-perfect cropping.
- **Delay Support**: Optional countdown timer before capturing.

### Precision Pixel Color Picker

The `PickColor` method provides an instant desktop color dropper:
- Magnified pixel loupe following the pointer.
- Instant display of Hex (`#RRGGBB`), RGB, and HSL values.
- One-click copy directly into system clipboard.

### Direct CLI Testing

```bash
# Interactive region crop screenshot
wormhole --screenshot --interactive

# Timed screenshot (3-second delay)
wormhole --screenshot --delay 3

# Open precision color picker
wormhole --pick-color
```

---

## FileChooser Dialog

Fjord provides a complete native Material 3 file dialog that replaces traditional GTK or Qt dialogs with a fast, modern picker matching Atlas and Caelestia.

### Features

- **View Modes**: Instantly toggle between fluid card-based Grid View and compact List View.
- **Sidebar Places**: Instant access to standard directories (`Home`, `Desktop`, `Documents`, `Downloads`, `Music`, `Pictures`, `Videos`, `Trash`).
- **Removable Media**: Automatically detects and mounts external USB drives and network shares via `DriveManager`.
- **Search & Filter**: Real-time fuzzy filtering of files and MIME type dropdown filtering.
- **Modes**: Open single file, Open multiple files, Directory selection, and Save As mode.

### Direct CLI Testing

```bash
# Standard file open picker
wormhole --file-chooser --title "Select Document"

# Open folder / directory selector
wormhole --file-chooser --directory ~/Projects

# Save file dialog
wormhole --file-chooser --save --directory ~/Downloads --title "Export Document"
```

---

## Application Chooser

The `AppChooser` portal allows sandboxed applications to delegate opening a file or web link to an appropriate host application.

### Features

- Evaluates system `.desktop` files registered in standard XDG application directories.
- Filters applications based on target MIME type or protocol scheme.
- Allows user to set preferred default handlers.

### Direct CLI Testing

```bash
# Choose handler for an image MIME type
wormhole --appchooser --mime "image/png"

# Choose browser or client for a URL
wormhole --appchooser --url "https://github.com"
```

---

## Security Permissions & Access

The `Access` portal requests explicit user consent before granting applications access to sensitive hardware or services (cameras, microphones, location, background execution).

### Features

- Dynamic `SmartIcon` mapping matching the requested capability (e.g. `camera-web`, `audio-input-microphone`).
- Detailed caller attribution identifying the requesting `app_id`.
- User choices: "Allow Once", "Always Allow", or "Deny".

### Direct CLI Testing

```bash
wormhole --access \
  --title "Microphone Access" \
  --app-id "org.telegram.desktop" \
  --icon "audio-input-microphone" \
  --subtitle "Telegram requests permission" \
  --body "Telegram wants access to your microphone for a voice call."
```

---

## Dynamic Launcher

The `DynamicLauncher` portal enables browsers and sandboxed software to create desktop entries, web shortcuts, and application launchers.

### Features

- Desktop entry generation conforming to Freedesktop Desktop Entry Specification.
- Application icon installation into `~/.local/share/icons/hicolor/`.
- Executable validation and security sandboxing checks.

### Direct CLI Testing

```bash
wormhole --dynamic-launcher \
  --name "Docsify" \
  --url "https://docsify.js.org" \
  --icon "text-html"
```

---

## Wallpaper Preview

The `Wallpaper` portal provides a preview interface before applying system wallpapers.

### Features

- Fullscreen wallpaper preview rendered within a simulated desktop frame.
- Target selection:
  - **Homescreen**: Applies to the desktop workspace.
  - **Lockscreen**: Applies to the screen locker.
  - **Both**: Applies to both desktop and lockscreen.
- Hooks into Caelestia wallpaper management.

### Direct CLI Testing

```bash
wormhole --wallpaper --url "file:///usr/share/backgrounds/default.png"
```

---

## System Service Portals

Beyond visual dialogs, Fjord provides backend portal implementations:

### Settings (`org.freedesktop.impl.portal.Settings`)
Enables Flatpak and host applications to query system appearance preferences:
- `color-scheme`: Returns `1` for Dark Mode, `0` for Light Mode (synchronized with GNOME/GSettings and Caelestia).
- `accent-color`: Emits active primary color accent in RGB format.
- Emits `SettingChanged` signals whenever theme preferences update.

### Secret (`org.freedesktop.impl.portal.Secret`)
Derives application-specific master encryption keys using HMAC-SHA256 based on the client `app_id` and a host machine seed, allowing Flatpaks to store credentials securely without root access.

### GlobalShortcuts (`org.freedesktop.impl.portal.GlobalShortcuts`)
Brokers application requests to register global keyboard shortcuts, binding hotkeys through Hyprland without exposing raw input events to the client.

### Inhibit (`org.freedesktop.impl.portal.Inhibit`)
Tracks media playback and presentation locks, preventing the compositor from sleeping or activating screen timeouts while video is playing.

---

## CLI Testing Triggers

### Summary of CLI Options

| Flag | Argument | Description |
| :--- | :--- | :--- |
| `-d`, `--daemon` | None | Start background D-Bus portal service |
| `--screencast` | None | Trigger ScreenCast dialog |
| `--screenshot` | None | Trigger Screenshot overlay |
| `--pick-color` | None | Trigger Color Picker tool |
| `--file-chooser` | None | Trigger embedded File Chooser |
| `--appchooser` | None | Trigger Application Chooser |
| `--access` | None | Trigger Permission Access dialog |
| `--account` | None | Trigger User Account modal |
| `--dynamic-launcher` | None | Trigger Dynamic Launcher installer |
| `--wallpaper` | None | Trigger Wallpaper preview dialog |
| `--title` | `"<title>"` | Override modal dialog title |
| `--app-id` | `"<id>"` | Simulated requesting application ID |
| `--types` | `<bitmask>` | Available source types (1=Monitor, 2=Window, 3=Both) |
| `--multiple` | None | Allow selecting multiple sources or files |
| `--save` | None | File chooser save mode |
| `--directory` | `"<path>"` | File chooser directory select mode or initial path |
| `--interactive` | None | Interactive region screenshot crop mode |
| `--delay` | `<sec>` | Delay in seconds before screenshot capture |
| `--mime` | `"<mime>"` | Target MIME type for app chooser |
| `--url` | `"<url>"` | Target URL or file URI |

---

## Debugging & Trace Logging

### Running Daemon in Foreground

To observe D-Bus requests and Wayland capture events in real time:

```bash
QT_LOGGING_RULES="*.debug=true;wormhole.*=true" wormhole --daemon
```

### Inspecting D-Bus Communication

Monitor live calls routed through the portal daemon:

```bash
# Monitor calls to Fjord on the session bus
busctl --user monitor org.freedesktop.impl.portal.desktop.wormhole
```

Or view systemd journal logs:

```bash
journalctl --user-unit xdg-desktop-portal-wormhole.service -f
```
