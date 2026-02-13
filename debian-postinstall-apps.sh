#!/bin/bash

# =============================================================================
# APPLICATION LISTS - CUSTOMIZE HERE
# =============================================================================

# APT packages to install (selected by default)
PKG_APT=(
    apostrophe
    aria2
    bat
    btop
    cheese
    cups
    cups-filters
    curl
    evolution
    foomatic-db
    gimp
    git
    gnome-authenticator
    gnome-decoder
    gnome-video-effects-frei0r
    grsync
    htop
    micro
    network-manager-openvpn
    network-manager-openvpn-gnome
    nomacs
    papers
    pdfarranger
    printer-driver-all
    pixz
    simple-scan
    system-config-printer
    uget
    unrar-free
    vlc
    wget
    wireguard-tools
    xclip
    yt-dlp
    zsh
)

# APT optional packages (not selected by default)
PKG_APT_OPTIONAL=()

# Flatpak applications to install (selected by default)
PKG_FLATPAK=(
    com.brave.Browser
    com.github.huluti.Curtail
    com.rustdesk.RustDesk
    im.riot.Riot
    io.freetubeapp.FreeTube
    io.github.qtox.qTox
    io.github.ungoogled_software.ungoogled_chromium
    io.gitlab.librewolf-community
    net.cozic.joplin_desktop
    org.flozz.yoga-image-optimizer
    org.localsend.localsend_app
    org.pvermeer.WebAppHub
    re.sonny.Junction
)

# Flatpak optional applications (not selected by default)
PKG_FLATPAK_OPTIONAL=(
    com.rtosta.zapzap
    so.onekey.Wallet
    io.trezor.suite
    org.electrum.electrum
    org.getmonero.Monero
)

# Snap applications to install (selected by default)
PKG_SNAP=()

# Snap optional applications (not selected by default)
PKG_SNAP_OPTIONAL=(
    signal-desktop
)

# =============================================================================
# DESKTOP-SPECIFIC PACKAGES
# =============================================================================

# GNOME-specific packages (installed automatically if GNOME detected)
PKG_GNOME=(
    gnome-shell-extension-appindicator
    gnome-shell-extension-dashtodock
    gnome-shell-extension-easyscreencast
    gnome-shell-extension-freon
    gnome-shell-extension-gpaste
    gnome-shell-extension-gsconnect
    gnome-shell-extension-gsconnect-browsers
    gnome-shell-extension-system-monitor
)

# Packages for both GNOME and XFCE
PKG_GNOME_XFCE=(
    gnome-calculator
    gnome-calendar
    gnome-contacts
    gnome-software-plugin-flatpak
    gnome-software-plugin-snap
)

# =============================================================================
# SCRIPT START
# =============================================================================

# Color variables for output
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
BOLD="\033[1m"
RESET="\033[0m"

# Detect system architecture
SYS_ARCH=$(uname -m)

# Check if running as root or with sudo
check_privileges() {
    if [ "$(id -u)" -eq 0 ]; then
        SUDO_CMD=""
        echo -e "${YELLOW}Running as root${RESET}"
    elif sudo -n true 2>/dev/null; then
        SUDO_CMD="sudo"
        echo -e "${GREEN}Sudo available${RESET}"
    else
        echo -e "${RED}Error: This script requires root privileges or sudo access${RESET}"
        echo -e "${YELLOW}Please ensure sudo is installed and configured${RESET}"
        exit 1
    fi
}

# Get description for APT package
get_apt_description() {
    local pkg="$1"
    apt show "$pkg" 2>/dev/null | grep "^Description:" | cut -d':' -f2 | cut -d'(' -f1 | sed 's/^ *//' | head -c 50
}

# Get description for Flatpak app
get_flatpak_description() {
    local app="$1"
    flatpak info "$app" 2>/dev/null | head -n 2 | tail -n 1 | head -c 50
}

# Get description for Snap app
get_snap_description() {
    local snap="$1"
    snap info "$snap" 2>/dev/null | grep "summary:" | cut -d':' -f2 | sed 's/^ *//' | head -c 50
}

# Check if APT package is compatible with architecture
is_apt_compatible() {
    local pkg="$1"
    local pkg_arch
    pkg_arch=$(apt show "$pkg" 2>/dev/null | grep "^Architecture:" | awk '{print $2}')
    [ "$pkg_arch" = "all" ] || [ "$pkg_arch" = "$SYS_ARCH" ] || [ -z "$pkg_arch" ]
}

# Check if Flatpak app is compatible
is_flatpak_compatible() {
    return 0
}

# Check if Snap is compatible
is_snap_compatible() {
    return 0
}

echo -e "${CYAN}${BOLD}Starting system update...${RESET}"

# Check privileges first
check_privileges

# Update system
$SUDO_CMD apt update || { echo -e "${RED}Failed to update package list! Aborting.${RESET}"; exit 1; }
echo

# Preinstall dialog if needed
if ! command -v dialog &> /dev/null; then
    echo -e "${YELLOW}Dialog not found. Installing dialog package for interactive menus...${RESET}"
    $SUDO_CMD apt install -y dialog || { echo -e "${RED}Failed to install dialog. Aborting.${RESET}"; exit 1; }
fi
echo -e "${GREEN}Dialog is installed, proceeding...${RESET}"
echo

# =============================================================================
# BUILD MENU OPTIONS WITH DESCRIPTIONS
# =============================================================================

# Build APT options array (default + optional)
APT_OPTIONS=()
SKIPPED_APT=()

# Add default packages (selected by default - "on")
for pkg in "${PKG_APT[@]}"; do
    if is_apt_compatible "$pkg"; then
        desc=$(get_apt_description "$pkg")
        [ -z "$desc" ] && desc="$pkg"
        APT_OPTIONS+=("$pkg" "$desc" "on")
    else
        SKIPPED_APT+=("$pkg")
    fi
done

# Add optional packages (not selected by default - "off")
for pkg in "${PKG_APT_OPTIONAL[@]}"; do
    if is_apt_compatible "$pkg"; then
        desc=$(get_apt_description "$pkg")
        [ -z "$desc" ] && desc="$pkg"
        APT_OPTIONS+=("$pkg" "$desc" "off")
    else
        SKIPPED_APT+=("$pkg")
    fi
done

# Show skipped APT packages
if [ ${#SKIPPED_APT[@]} -gt 0 ]; then
    echo -e "${YELLOW}Warning: The following APT packages are not available for $SYS_ARCH:${RESET}"
    printf "  - %s\n" "${SKIPPED_APT[@]}"
    echo
fi

# Build Flatpak options array (default + optional)
FLATPAK_OPTIONS=()
SKIPPED_FLATPAK=()

# Add default applications (selected by default - "on")
for app in "${PKG_FLATPAK[@]}"; do
    if is_flatpak_compatible "$app"; then
        desc=$(get_flatpak_description "$app")
        [ -z "$desc" ] && desc="$app"
        FLATPAK_OPTIONS+=("$app" "$desc" "on")
    else
        SKIPPED_FLATPAK+=("$app")
    fi
done

# Add optional applications (not selected by default - "off")
for app in "${PKG_FLATPAK_OPTIONAL[@]}"; do
    if is_flatpak_compatible "$app"; then
        desc=$(get_flatpak_description "$app")
        [ -z "$desc" ] && desc="$app"
        FLATPAK_OPTIONS+=("$app" "$desc" "off")
    else
        SKIPPED_FLATPAK+=("$app")
    fi
done

# Show skipped Flatpak packages
if [ ${#SKIPPED_FLATPAK[@]} -gt 0 ]; then
    echo -e "${YELLOW}Warning: The following Flatpak apps are not available for $SYS_ARCH:${RESET}"
    printf "  - %s\n" "${SKIPPED_FLATPAK[@]}"
    echo
fi

# Build Snap options array (default + optional)
SNAP_OPTIONS=()
SKIPPED_SNAP=()

# Add default snaps (selected by default - "on")
for snap in "${PKG_SNAP[@]}"; do
    if is_snap_compatible "$snap"; then
        desc=$(get_snap_description "$snap")
        [ -z "$desc" ] && desc="$snap"
        SNAP_OPTIONS+=("$snap" "$desc" "on")
    else
        SKIPPED_SNAP+=("$snap")
    fi
done

# Add optional snaps (not selected by default - "off")
for snap in "${PKG_SNAP_OPTIONAL[@]}"; do
    if is_snap_compatible "$snap"; then
        desc=$(get_snap_description "$snap")
        [ -z "$desc" ] && desc="$snap"
        SNAP_OPTIONS+=("$snap" "$desc" "off")
    else
        SKIPPED_SNAP+=("$snap")
    fi
done

# Show skipped Snap packages
if [ ${#SKIPPED_SNAP[@]} -gt 0 ]; then
    echo -e "${YELLOW}Warning: The following Snap apps are not available for $SYS_ARCH:${RESET}"
    printf "  - %s\n" "${SKIPPED_SNAP[@]}"
    echo
fi

# =============================================================================
# SHOW INTERACTIVE MENUS
# =============================================================================

echo -e "${BLUE}${BOLD}Please select the APT packages to install:${RESET}"
APT_SELECTED=$(dialog --stdout --separate-output \
    --checklist "Select APT packages to install (GNOME/XFCE packages installed by default):" 25 80 20 \
    "${APT_OPTIONS[@]}")
clear
echo

echo -e "${BLUE}${BOLD}Please select the Flatpak applications to install:${RESET}"
FLATPAK_SELECTED=$(dialog --stdout --separate-output \
    --checklist "Select Flatpak applications to install:" 25 80 15 \
    "${FLATPAK_OPTIONS[@]}")
clear
echo

# Only show Snap menu if there are Snap packages configured
if [ ${#SNAP_OPTIONS[@]} -gt 0 ]; then
    echo -e "${BLUE}${BOLD}Please select the Snap applications to install:${RESET}"
    SNAP_SELECTED=$(dialog --stdout --separate-output \
        --checklist "Select Snap applications to install:" 20 80 10 \
        "${SNAP_OPTIONS[@]}")
    clear
    echo
fi

# =============================================================================
# INSTALLATION
# =============================================================================

echo -e "${CYAN}${BOLD}Upgrading system...${RESET}"
$SUDO_CMD apt full-upgrade -y || { echo -e "${RED}System upgrade failed! Aborting.${RESET}"; exit 1; }
echo

echo -e "${CYAN}${BOLD}Installing flatpak & snap...${RESET}"
$SUDO_CMD apt install -y flatpak snap || { echo -e "${RED}Install failed! Aborting.${RESET}"; exit 1; }
echo

echo -e "${CYAN}${BOLD}Configuring flathub.org...${RESET}"
$SUDO_CMD flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || { echo -e "${RED}Failed to configure flathub.org! Aborting.${RESET}"; exit 1; }
echo

# Install selected APT packages
if [ -n "$APT_SELECTED" ]; then
    echo -e "${GREEN}${BOLD}Installing selected APT packages...${RESET}"
    $SUDO_CMD apt install -y $APT_SELECTED || echo -e "${RED}One or more APT packages failed to install.${RESET}"
else
    echo -e "${YELLOW}No APT packages selected for installation.${RESET}"
fi
echo

# Install desktop-specific packages
if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ] && [ ${#PKG_GNOME[@]} -gt 0 ]; then
    echo -e "${MAGENTA}${BOLD}Installing GNOME desktop extensions...${RESET}"
    $SUDO_CMD apt install -y "${PKG_GNOME[@]}" || echo -e "${RED}Failed to install some GNOME extensions.${RESET}"
    
    # Enable installed extensions
    echo -e "${MAGENTA}Enabling GNOME extensions...${RESET}"
    if command -v gnome-extensions &>/dev/null; then
        gnome-extensions list 2>/dev/null | xargs -r -I {} gnome-extensions enable {} 2>/dev/null || true
        echo -e "${GREEN}Extensions enabled${RESET}"
    fi
    echo
fi

if [ "$XDG_CURRENT_DESKTOP" = "XFCE" ] || [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
    if [ ${#PKG_GNOME_XFCE[@]} -gt 0 ]; then
        echo -e "${MAGENTA}Installing GNOME apps and Flatpak + Snap plugins for app stores...${RESET}"
        $SUDO_CMD apt install -y "${PKG_GNOME_XFCE[@]}" || echo -e "${RED}Failed to install software plugins.${RESET}"
        echo
    fi
fi

# Install selected Flatpak apps
if [ -n "$FLATPAK_SELECTED" ]; then
    echo -e "${GREEN}${BOLD}Installing selected Flatpak apps...${RESET}"
    flatpak install -y flathub $FLATPAK_SELECTED || echo -e "${RED}One or more Flatpak apps failed to install.${RESET}"
else
    echo -e "${YELLOW}No Flatpak apps selected for installation.${RESET}"
fi
echo

# Install selected Snap apps
if [ -n "$SNAP_SELECTED" ]; then
    echo -e "${GREEN}${BOLD}Installing selected Snap apps...${RESET}"
    for snap in $SNAP_SELECTED; do
        $SUDO_CMD snap install "$snap" || echo -e "${RED}Failed to install $snap.${RESET}"
    done
else
    echo -e "${YELLOW}No Snap apps selected for installation.${RESET}"
fi
echo

echo -e "${CYAN}Setting default web browser to ${BOLD}re.sonny.Junction.desktop${RESET}"
xdg-settings set default-web-browser re.sonny.Junction.desktop || echo -e "${RED}Failed to set default web browser.${RESET}"
echo

echo -e "${GREEN}${BOLD}Installation complete. Thank you for using this script!${RESET}"
