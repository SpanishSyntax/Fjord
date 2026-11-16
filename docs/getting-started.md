# Getting Started

This guide explains how to install, configure, and verify Fjord (`wormhole`) as the primary `xdg-desktop-portal` backend for your Wayland desktop session.

---

## Installation Requirements

### System Requirements

To utilize the full screen and window sharing capabilities of Fjord, your Wayland compositor must implement modern capture protocols:
- `ext-image-capture-source-v1` (Display capture sources)
- `ext-image-copy-capture-v1` (Direct screencopy and buffer sharing)
- `ext-foreign-toplevel-list-v1` (Window discovery and toplevel capture)

> [!NOTE]
> Hyprland supports all three protocols starting from version **0.47**. Sway supports screen capture starting from version **1.11**.

### Build Dependencies

- **C++ Compiler**: C++20 compliant (`gcc` ≥ 11 or `clang` ≥ 14)
- **Build System**: `cmake` (≥ 3.19), `ninja`, `pkg-config`
- **Qt 6 Framework** (≥ 6.5):
  - `qt6-base` (`Core`, `Gui`, `DBus`, `Network`, `Concurrent`, `Test`)
  - `qt6-declarative` (`Qml`, `Quick`, `QuickControls2`)
  - `qt6-quickeffects`
  - `qt6-svg`
  - `qt6-multimedia`
- **Audio/Video Streaming**: `libpipewire-0.3` (PipeWire development headers)
- **Wayland Stack**: `wayland-client`, `wayland-protocols` (≥ 1.38), `wayland-scanner`
- **GLib Stack**: `glib-2.0`, `gio-2.0`

---

## Nix Flake & Home Manager

Fjord ships with first-class Nix Flake support, providing reproducible package derivations, development shells, and a Home Manager module.

### Adding Flake Input

Add Fjord to your system or user `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    fjord = {
      url = "github:SpanishSyntax/Fjord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, fjord, ... }: {
    # System or Home Manager modules
  };
}
```

### Home Manager Configuration

Enable the Fjord module in your Home Manager configuration:

```nix
{
  imports = [
    inputs.fjord.homeManagerModules.default
  ];

  # Enable the Fjord portal daemon and packaging
  programs.fjord.enable = true;

  # Note: programs.wormhole.enable is supported as an alias
}
```

This installs the `wormhole` binary, installs all portal definitions, and registers the D-Bus activation files.

### NixOS System Package

Alternatively, install Fjord system-wide in `configuration.nix`:

```nix
{
  environment.systemPackages = [
    inputs.fjord.packages.${pkgs.system}.default
  ];
}
```

### Development Shell

To enter a complete development environment containing all build dependencies:

```bash
nix develop github:SpanishSyntax/Fjord
```

---

## Manual Compilation from Source

If you are not using Nix, you can build and install Fjord directly using CMake and Ninja:

```bash
# Clone the repository
git clone https://github.com/SpanishSyntax/Fjord.git
cd Fjord

# Configure build tree with Release optimizations
cmake -B build -S . -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr

# Build all targets in parallel
cmake --build build -j$(nproc)

# Install binaries and D-Bus portal descriptors
sudo cmake --install build
```

### Installed Files

The build process installs the following key assets:
- **Executable**: `/usr/bin/wormhole`
- **Portal Definition**: `/usr/share/xdg-desktop-portal/portals/wormhole.portal`
- **Portal Preferences**: `/usr/share/xdg-desktop-portal/wormhole-portals.conf`
- **D-Bus Activation Service**: `/usr/share/dbus-1/services/org.freedesktop.impl.portal.Desktop.wormhole.service`
- **Systemd User Unit**: `/usr/lib/systemd/user/xdg-desktop-portal-wormhole.service`

---

## D-Bus Portal Configuration

The central `xdg-desktop-portal` frontend daemon reads configuration files in `/usr/share/xdg-desktop-portal/portals.conf` and `~/.config/xdg-desktop-portal/portals.conf`.

### Setting Fjord as Default Backend

To configure Fjord (`wormhole`) as the default backend for your session:

```bash
mkdir -p ~/.config/xdg-desktop-portal
```

Create `~/.config/xdg-desktop-portal/portals.conf`:

```ini
[preferred]
default=wormhole
```

### Hybrid Compositor Configuration

If you prefer to keep compositor-native backends (such as `xdg-desktop-portal-hyprland`) for specific features while delegating screen sharing, file choosing, and screenshots to Fjord:

```ini
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.ScreenCast=wormhole
org.freedesktop.impl.portal.Screenshot=wormhole
org.freedesktop.impl.portal.FileChooser=wormhole
org.freedesktop.impl.portal.AppChooser=wormhole
org.freedesktop.impl.portal.Access=wormhole
org.freedesktop.impl.portal.DynamicLauncher=wormhole
org.freedesktop.impl.portal.Wallpaper=wormhole
```

---

## Systemd User Service

Fjord runs as a background D-Bus service managed by systemd.

### Enabling the Service

```bash
# Reload user units
systemctl --user daemon-reload

# Enable and immediately start the Fjord portal daemon
systemctl --user enable --now xdg-desktop-portal-wormhole.service

# Restart the main xdg-desktop-portal routing daemon
systemctl --user restart xdg-desktop-portal.service
```

---

## Verification & Daemon Status

### 1. Check Systemd Service

Verify that the unit is active and running:

```bash
systemctl --user status xdg-desktop-portal-wormhole.service
```

### 2. Inspect D-Bus Registration

Confirm that the portal daemon owns its well-known D-Bus bus name on the session bus:

```bash
busctl --user status org.freedesktop.impl.portal.desktop.wormhole
```

Or list portal interfaces provided:

```bash
qdbus org.freedesktop.impl.portal.desktop.wormhole /org/freedesktop/portal/desktop
```

### 3. Test Direct Invocation

Trigger a sample ScreenCast chooser directly from the terminal:

```bash
wormhole --screencast --app-id "test.portal" --types 3
```

If the Material 3 Expressive dialog appears, your installation and PipeWire backend are fully functional.
