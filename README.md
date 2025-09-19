# Debian Post-Install Setup Script

## Overview
This Bash script automates the installation of an opinionated / recrurent / essential software set on a Debian-based system.
It provides an interactive, user-friendly terminal interface for selecting packages to install, including support for Flatpak applications. 
The script installs system updates, desktop environment extensions, and configures the default web browser with Junction.

It adapts dynamically to your CPU architecture by only showing certain Flatpak apps on supported architectures (x86_64).
GNOME and XFCE desktop-specific extensions are always installed to ensure desktop functionality.

## Features
- Interactive APT and Flatpak app selection.
- Full system update and upgrade.
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

 ## Installed Applications

### Essential packages (apt)
- Apostrophe text editor
- aria2 (Download utility)
- bat (Cat clone with syntax highlighting)
- btop (Resource monitor)
- Cheese (Webcam application)
- CUPS printing system and filters
- curl (Data transfer tool)
- Evolution (Email and calendar)
- Flatpak package manager
- foomatic-db (Printer driver database)
- GIMP (Image editor)
- git (Version control system)
- gnome-authenticator (OTP Authenticator)
- gnome-decoder (QRCode generator/decoder)
-	gnome-video-effects-frei0r (Video effects, used by Cheese)
-	grsync (Files rsync GUI)
-	htop (Terminal-based system monitor)
- micro (Terminal-based text editor)
- nomacs (Image viewer)
- papers (Reference manager)
- pdfarranger (PDF tool)
- Printer-driver-all (Generic printer drivers)
- pixz (Parallel lossless compression)
- simple-scan (Document scanner app)
- snap package manager
- system-config-printer (Printer configuration tool)
- uget (Download manager)
- unrar-free (RAR archive extractor)
- VLC (Media player)
- wget (Command line downloader)
- xclip (Clipboard manager via CLI)
- yt-dlp (Youtube downloader)
- zsh (Shell alternative to bash)

### Flatpak applications
- Curtail (Video trimming tool)
- Riot (Decentralized chat client)
- Yoga Image Optimizer (Image optimizer)
- Brave Browser
- Zapzap (WhatsApp client)
- RustDesk (Remote desktop)
- FreeTube (Youtube client)
- qTox (Secure instant messaging)
- Librewolf (Privacy focused Firefox fork)
- LocalSend (Local file sharing)
- Junction (Web browser selector)

If running on `x86_64` architecture, also:
- OnlyOffice Desktop Editors
- Signal messenger

### If GNOME :
#### Shell Extensions
- **AppIndicator Support**: Enables legacy system tray icons for applications that use AppIndicators.
- **Arc Menu**: Classic-style application menu similar to traditional desktop environments.
- **Dash to Dock**: Configurable dock for app launching and window management.
- **Easy Screencast**: Desktop screen recording tool.
- **Freon**: Hardware sensor readouts like temperatures and fan speeds in system tray.
- **GPaste**: Clipboard manager with history access.
- **GSConnect**: Integrates phone with desktop for notifications and file sharing.
- **GSConnect Browsers**: Browser integration for GSConnect.
- **System Monitor**: Displays real-time CPU, memory, disk, and network usage.

### For GNOME and XFCE
- `gnome-calculator` (Calculator)
- `gnome-calendar` (Calendar)
- `gnome-contacts` (Contacts)
- `gnome-software-plugin-flatpak` (Flatpak integration)
- `gnome-software-plugin-snap` (Snap integration)
