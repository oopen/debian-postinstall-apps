# Debian Post-Install Setup Script

## Overview
This Bash script automates the installation of essential software on a Debian-based system.
It provides an interactive, user-friendly terminal interface for selecting packages to install, with support for APT, Flatpak, and Snap packages.

## Features
- Interactive APT, Flatpak, and Snap package selection
- Dynamic package descriptions retrieved from package managers
- Architecture compatibility checking
- Automatic installation of GNOME desktop extensions and plugins
- Color-coded terminal output for better readability

## Requirements
- Debian or Debian-based Linux distribution
- `sudo` privileges (or run as root)
- `wget` and `sudo` must be installed beforehand
- Internet connection
- Terminal supporting ANSI colors
- Desktop environment variables set (e.g. `XDG_CURRENT_DESKTOP`)

### Prerequisites Installation
If not already installed:
```bash
sudo apt update
sudo apt install -y wget sudo
```

## Installation

### Method 1: Direct Execution from GitHub
```bash
bash <(wget -O- https://raw.githubusercontent.com/oOpen/debian-postinstall-apps/master/debian-postinstall-apps.sh)
```

Or with curl:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/oOpen/debian-postinstall-apps/master/debian-postinstall-apps.sh)
```

### Method 2: Download and Execute Locally
```bash
wget https://raw.githubusercontent.com/oOpen/debian-postinstall-apps/master/debian-postinstall-apps.sh
chmod +x debian-postinstall-apps.sh
./debian-postinstall-apps.sh
```

## Installed Applications

### APT Packages
- **Text editors**: apostrophe, micro
- **Development**: git
- **System utilities**: bat, btop, htop, curl, wget, zsh
- **VPN tools**: network-manager-openvpn, network-manager-openvpn-gnome, wireguard, wireguard-tools
- **Multimedia**: cheese, gimp, vlc
- **Office**: evolution, nomacs, papers, pdfarranger
- **Printing**: cups, cups-filters, foomatic-db, printer-driver-all, simple-scan, system-config-printer
- **Download tools**: aria2, uget, yt-dlp
- **Security**: gnome-authenticator, gnome-decoder
- **Utilities**: grsync, pixz, unrar-free, xclip

### Flatpak Applications (Default)
- **Browsers**: com.brave.Browser, io.github.ungoogled_software.ungoogled_chromium, io.gitlab.librewolf-community
- **Communication**: com.rustdesk.RustDesk, im.riot.Riot, io.github.qtox.qTox
- **Productivity**: net.cozic.joplin_desktop, org.pvermeer.WebAppHub
- **Media**: io.freetubeapp.FreeTube
- **Utilities**: com.github.huluti.Curtail, org.flozz.yoga-image-optimizer, org.localsend.localsend_app, re.sonny.Junction

### Snap Applications (Default)
No default Snap packages are configured.

### Optional Applications (Not Selected by Default)
The following applications are available but **not selected by default**:

**Flatpak Optional:**
- `com.rtosta.zapzap` - WhatsApp client

**Snap Optional:**
- `signal-desktop` - Signal messenger

## Desktop-Specific Packages

The script automatically detects your desktop environment and installs specific packages:

### GNOME-Specific Packages (`PKG_GNOME`)
Installed automatically if GNOME desktop is detected:
- gnome-shell-extension-appindicator
- gnome-shell-extension-dashtodock
- gnome-shell-extension-easyscreencast
- gnome-shell-extension-freon
- gnome-shell-extension-gpaste
- gnome-shell-extension-gsconnect
- gnome-shell-extension-gsconnect-browsers
- gnome-shell-extension-system-monitor

### GNOME & XFCE Shared Packages (`PKG_GNOME_XFCE`)
Installed for both GNOME and XFCE desktops:
- gnome-calculator
- gnome-calendar
- gnome-contacts
- gnome-software-plugin-flatpak
- gnome-software-plugin-snap

## Customization

To customize which applications are installed, edit the arrays at the top of the script:

**Main packages (selected by default in interactive mode):**
- `PKG_APT` - APT packages
- `PKG_FLATPAK` - Flatpak applications  
- `PKG_SNAP` - Snap packages

**Optional packages (not selected by default):**
- `PKG_APT_OPTIONAL` - Optional APT packages
- `PKG_FLATPAK_OPTIONAL` - Optional Flatpak apps
- `PKG_SNAP_OPTIONAL` - Optional Snap packages

**Desktop-specific packages (auto-installed based on desktop environment):**
- `PKG_GNOME` - GNOME-specific packages
- `PKG_GNOME_XFCE` - Packages for both GNOME and XFCE

## License

This project is licensed under the GNU GPL v3.0 - see the LICENSE file for details.
