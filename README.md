# Debian Post-Install Setup Script

## Overview
This Bash script automates the installation and configuration of essential software on a Debian-based system.
It provides an interactive, user-friendly terminal interface for selecting packages to install, including support for Flatpak applications. The script installs system updates, desktop environment extensions, and configures the default web browser.

It adapts dynamically to your CPU architecture by only showing certain Flatpak apps on supported architectures (x86_64).
GNOME and XFCE desktop-specific extensions are always installed to ensure desktop functionality.

## Features
- Interactive APT and Flatpak app selection.
- Full system update and upgrade using.
- Architecture-aware Flatpak app selection.
- Automatic installation of GNOME desktop extensions and plugins for GNOME and XFCE.
- Clear and structured terminal output with color for usability.
- Sets the default web browser upon completion.

## Requirements
- Debian or Debian-based Linux distribution.
- `sudo` privileges.
- Internet connection.
- Terminal supporting ANSI colors.
- Desktop environment environment variables set (e.g. `XDG_CURRENT_DESKTOP`).

## Invocation via curl from GitHub

To invoke the latest master version of this script directly from GitHub and execute it without saving locally, you can run:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/oOpen/debian-postinstall-apps/master/debian-postinstall-apps.sh)
 ```
