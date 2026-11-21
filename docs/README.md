<img src="assets/banner.png" alt="Fjord Banner" width="100%" />

# Fjord 🌊

A native, modern Material 3 Expressive implementation of the `xdg-desktop-portal` backend for Wayland and Hyprland, built with Qt 6, C++20, and PipeWire.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://github.com/SpanishSyntax/Fjord/blob/main/LICENSE)
[![C++20](https://img.shields.io/badge/C++-20-00599C.svg?logo=c%2B%2B&logoColor=white)](CMakeLists.txt)
[![Qt 6.5+](https://img.shields.io/badge/Qt-6.5+-41CD52.svg?logo=qt&logoColor=white)](CMakeLists.txt)
[![Nix Flake](https://img.shields.io/badge/Nix-Flake-5277C3.svg?logo=nixos&logoColor=white)](flake.nix)

Fjord (packaged and invoked as `wormhole` / `xdg-desktop-portal-wormhole`) serves as the official portal backend for the AstraSuite and Frost desktop ecosystems. It translates all 24 XDG Desktop Portal specifications into fluid, Material 3 Expressive dialogs powered by PipeWire, Hyprland IPC, and Qt Quick.

---

## Why "Fjord" & "Wormhole"? (The Lore)

> **fjord** (`/fjɔːd/`) — *noun:* A deep, narrow inlet of the sea flanked by steep glacial cliffs, carved by ancient glaciers to form a sheltered waterway connecting the frozen interior with the open ocean.

In polar geography, a fjord serves as the solitary navigable corridor through towering barriers of ice and stone. Without it, the frozen hinterland remains impenetrable and quarantined from the open sea.

**Fjord connects isolated application sandboxes with the desktop session:**
- **Glacial Conduit**: In Wayland, modern application sandboxes (Flatpak, Snap, browser containers) are isolated by default. Fjord serves as the secure, expressive conduit between these isolated application sandboxes and the underlying desktop session.
- **Seamless Crossing**: Translates all 24 XDG Desktop Portal interfaces (ScreenCast, FileChooser, Screenshot, ColorPicker, Permissions, DynamicLauncher, Wallpaper) into unified Material 3 Expressive dialogs powered by PipeWire and Hyprland IPC, bridging sandboxed requests to user intent without friction.

---

## Architecture Highlights

- **Complete 24-Portal Backend**: Implements the entire XDG Desktop Portal suite under a unified D-Bus daemon (`org.freedesktop.impl.portal.desktop.wormhole`).
- **PipeWire & Wayland Screencopy**: Direct integration with `ext-image-copy-capture-v1` and `ext-image-capture-source-v1` via `wayland-scanner` generated code, streaming buffers directly to PipeWire nodes without intermediary copies.
- **Hyprland IPC Window Discovery**: Live query engine reading workspace tags, window titles, process geometry, and application icons from `$HYPRLAND_INSTANCE_SIGNATURE` sockets.
- **Embedded Material 3 FileChooser**: Feature-complete native file chooser dialog supporting grid and list view toggles, inline search, drive mounts, and bookmark management.
- **Precision Pixel Color Picker & Screenshot Tool**: Interactive region selection with a live magnifying loupe, pixel grid, and instantaneous clipboard hex/RGB export.
- **Material 3 Expressive QML Presentation**: Dynamic theme adaptation with Caelestia color tokens, Google Sans Flex typography, and physics-based spring animations.

---

## Quick Start

```bash
# Start background D-Bus portal daemon
wormhole --daemon

# Test ScreenCast source selection dialog
wormhole --screencast --app-id "org.mozilla.firefox" --types 3 --multiple

# Test interactive region screenshot
wormhole --screenshot --interactive

# Test precision pixel color picker
wormhole --pick-color

# Open native Material 3 File Chooser
wormhole --file-chooser --title "Select Project Files"
```

---

## Table of Contents

- [Getting Started](getting-started.md)
  - [Installation Requirements](getting-started.md#installation-requirements)
  - [Nix Flake & Home Manager](getting-started.md#nix-flake--home-manager)
  - [Manual Compilation from Source](getting-started.md#manual-compilation-from-source)
  - [D-Bus Portal Configuration](getting-started.md#d-bus-portal-configuration)
  - [Systemd User Service](getting-started.md#systemd-user-service)
  - [Verification & Daemon Status](getting-started.md#verification--daemon-status)
- [Architecture & Design](architecture.md)
  - [System Architecture](architecture.md#system-architecture)
  - [The Lore: Glacial Conduit](architecture.md#why-fjord--wormhole-the-lore)
  - [XDG Desktop Portal D-Bus Lifecycle](architecture.md#xdg-desktop-portal-d-bus-lifecycle)
  - [Wayland Protocols & Code Generation](architecture.md#wayland-protocols--code-generation)
  - [PipeWire Stream Node Architecture](architecture.md#pipewire-stream-node-architecture)
  - [Hyprland IPC Client Discovery](architecture.md#hyprland-ipc-client-discovery)
  - [Material 3 Expressive QML Engine](architecture.md#material-3-expressive-qml-engine)
- [Portal Interfaces](usage.md)
  - [Complete Suite Overview](usage.md#complete-suite-overview)
  - [ScreenCast & Window Sharing](usage.md#screencast-sharing)
  - [Screenshot & Pixel Color Picker](usage.md#screenshot--color-picker)
  - [Material 3 FileChooser Dialog](usage.md#filechooser-dialog)
  - [Application Chooser](usage.md#application-chooser)
  - [Security Permissions & Access Prompts](usage.md#security-permissions--access)
  - [Dynamic Launcher Installer](usage.md#dynamic-launcher)
  - [Wallpaper Preview Modal](usage.md#wallpaper-preview)
  - [System Service Portals](usage.md#system-service-portals)
- [CLI & Daemon Testing](usage.md#cli-testing-triggers)
  - [CLI Testing Triggers](usage.md#cli-testing-triggers)
  - [Command-Line Options](usage.md#command-line-options)
  - [Debugging & Trace Logging](usage.md#debugging--trace-logging)
