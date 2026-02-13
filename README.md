# Debian Missing Apps

Install the apps Debian should have by default. One interactive menu for APT, Flatpak, and Snap packages.

## Quick Start

```bash
bash <(wget -O- https://raw.githubusercontent.com/oOpen/debian-missing-apps/master/installer.sh)
```

## What It Does

- Shows one unified menu with all packages (APT, Flatpak, Snap)
- Desktop-specific packages appear only if GNOME/XFCE detected
- Installs selected packages automatically

## Requirements

- Debian/Ubuntu with `sudo` access
- `wget` and `sudo` installed

## Customize

Edit package lists at the top of the script:

```bash
# Packages selected by default
ALL_PACKAGES=(
    "gimp" "APT"
    "com.brave.Browser" "FLATPAK"
    "gnome-shell-extension-dashtodock" "GNOME"
)

# Packages not selected by default  
ALL_PACKAGES_OPTIONAL=(
    "signal-desktop" "SNAP"
)
```

**Types:** `APT` | `FLATPAK` | `SNAP` | `GNOME` (desktop-specific) | `DESKTOP` (GNOME/XFCE common)

## Contribute

Want to add useful open-source apps? Contributions welcome!

1. Fork the repository
2. Add your app to `ALL_PACKAGES` or `ALL_PACKAGES_OPTIONAL`
3. Open a Pull Request

**Criteria:**
- Must be open source
- If the application is open source but its core/network component is proprietary, add as optional
- Available on APT, Flatpak, or Snap
- Useful for most Debian users

## License

GPL v3.0
