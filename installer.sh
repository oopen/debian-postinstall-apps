#!/bin/bash

# =============================================================================
# ALL PACKAGES - SINGLE MENU
# Format: "package_name" "TYPE"
# TYPE = APT, FLATPAK, SNAP, GNOME (desktop-specific), DESKTOP (common GNOME/XFCE)
# =============================================================================

# All packages (alphabetically sorted, selected by default)
ALL_PACKAGES=(
    # APT packages
    "apostrophe" "APT"
    "aria2" "APT"
    "bat" "APT"
    "btop" "APT"
    "cheese" "APT"
    "cups" "APT"
    "cups-filters" "APT"
    "curl" "APT"
    "evolution" "APT"
    "foomatic-db" "APT"
    "gimp" "APT"
    "git" "APT"
    "gnome-authenticator" "APT"
    "gnome-decoder" "APT"
    "gnome-video-effects-frei0r" "APT"
    "grsync" "APT"
    "htop" "APT"
    "micro" "APT"
    "network-manager-openvpn" "APT"
    "network-manager-openvpn-gnome" "APT"
    "nomacs" "APT"
    "papers" "APT"
    "pdfarranger" "APT"
    "pixz" "APT"
    "printer-driver-all" "APT"
    "simple-scan" "APT"
    "system-config-printer" "APT"
    "uget" "APT"
    "unrar-free" "APT"
    "vlc" "APT"
    "wget" "APT"
    "wireguard-tools" "APT"
    "xclip" "APT"
    "yt-dlp" "APT"
    "zsh" "APT"
    
    # Flatpak applications
    "com.brave.Browser" "FLATPAK"
    "com.github.huluti.Curtail" "FLATPAK"
    "com.rustdesk.RustDesk" "FLATPAK"
    "im.riot.Riot" "FLATPAK"
    "io.freetubeapp.FreeTube" "FLATPAK"
    "io.github.qtox.qTox" "FLATPAK"
    "io.github.ungoogled_software.ungoogled_chromium" "FLATPAK"
    "io.gitlab.librewolf-community" "FLATPAK"
    "net.cozic.joplin_desktop" "FLATPAK"
    "org.flozz.yoga-image-optimizer" "FLATPAK"
    "org.localsend.localsend_app" "FLATPAK"
    "org.pvermeer.WebAppHub" "FLATPAK"
    "re.sonny.Junction" "FLATPAK"
    
    # Desktop-specific GNOME packages (only shown if GNOME detected, selected by default)
    "gnome-calculator" "DESKTOP"
    "gnome-calendar" "DESKTOP"
    "gnome-contacts" "DESKTOP"
    "gnome-shell-extension-appindicator" "GNOME"
    "gnome-shell-extension-dashtodock" "GNOME"
    "gnome-shell-extension-easyscreencast" "GNOME"
    "gnome-shell-extension-freon" "GNOME"
    "gnome-shell-extension-gpaste" "GNOME"
    "gnome-shell-extension-gsconnect" "GNOME"
    "gnome-shell-extension-gsconnect-browsers" "GNOME"
    "gnome-shell-extension-system-monitor" "GNOME"
    "gnome-software-plugin-flatpak" "DESKTOP"
    "gnome-software-plugin-snap" "DESKTOP"
)

# Optional packages (not selected by default)
ALL_PACKAGES_OPTIONAL=(
    # Flatpak optional
    "com.rtosta.zapzap" "FLATPAK"
    "io.trezor.suite" "FLATPAK"
    "org.electrum.electrum" "FLATPAK"
    "org.getmonero.Monero" "FLATPAK"
    "so.onekey.Wallet" "FLATPAK"
    
    # Snap optional
    "signal-desktop" "SNAP"
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
# BUILD UNIFIED MENU (alphabetically sorted)
# =============================================================================

generate_unified_menu() {
    local all_entries=()
    SKIPPED_APT=()
    SKIPPED_FLATPAK=()
    SKIPPED_SNAP=()
    
    echo -e "${BLUE}Building package list...${RESET}"
    
    # Process default packages
    for ((i=0; i<${#ALL_PACKAGES[@]}; i+=2)); do
        local pkg="${ALL_PACKAGES[$i]}"
        local type="${ALL_PACKAGES[$((i+1))]}"
        
        # Filter desktop-specific packages based on detected desktop
        if [[ "$type" == "GNOME" ]] && [[ "$XDG_CURRENT_DESKTOP" != *"GNOME"* ]]; then
            continue
        fi
        if [[ "$type" == "DESKTOP" ]] && [[ "$XDG_CURRENT_DESKTOP" != *"GNOME"* && "$XDG_CURRENT_DESKTOP" != "XFCE" ]]; then
            continue
        fi
        
        # Check architecture compatibility
        if [[ "$type" == "APT" || "$type" == "GNOME" || "$type" == "DESKTOP" ]]; then
            if ! is_apt_compatible "$pkg"; then
                SKIPPED_APT+=("$pkg")
                continue
            fi
        fi
        
        # Get description based on type
        local desc=""
        case "$type" in
            APT|GNOME|DESKTOP) desc=$(get_apt_description "$pkg") ;;
            FLATPAK) desc=$(get_flatpak_description "$pkg") ;;
            SNAP) desc=$(get_snap_description "$pkg") ;;
        esac
        
        [ -z "$desc" ] && desc="$pkg"
        
        # Desktop-specific packages are selected by default ("on")
        if [[ "$type" == "GNOME" || "$type" == "DESKTOP" ]]; then
            all_entries+=("$pkg|$type|$desc|on")
        else
            all_entries+=("$pkg|$type|$desc|on")
        fi
    done
    
    # Process optional packages (not selected by default)
    for ((i=0; i<${#ALL_PACKAGES_OPTIONAL[@]}; i+=2)); do
        local pkg="${ALL_PACKAGES_OPTIONAL[$i]}"
        local type="${ALL_PACKAGES_OPTIONAL[$((i+1))]}"
        
        # Filter desktop-specific
        if [[ "$type" == "GNOME" ]] && [[ "$XDG_CURRENT_DESKTOP" != *"GNOME"* ]]; then
            continue
        fi
        if [[ "$type" == "DESKTOP" ]] && [[ "$XDG_CURRENT_DESKTOP" != *"GNOME"* && "$XDG_CURRENT_DESKTOP" != "XFCE" ]]; then
            continue
        fi
        
        # Check architecture for APT packages
        if [[ "$type" == "APT" ]]; then
            if ! is_apt_compatible "$pkg"; then
                SKIPPED_APT+=("$pkg")
                continue
            fi
        fi
        
        # Get description
        local desc=""
        case "$type" in
            APT|GNOME|DESKTOP) desc=$(get_apt_description "$pkg") ;;
            FLATPAK) desc=$(get_flatpak_description "$pkg") ;;
            SNAP) desc=$(get_snap_description "$pkg") ;;
        esac
        
        [ -z "$desc" ] && desc="$pkg"
        
        # Optional packages are not selected by default ("off")
        all_entries+=("$pkg|$type|$desc|off")
    done
    
    # Sort alphabetically by package name
    IFS=$'\n' sorted_entries=($(sort <<<"${all_entries[*]}"))
    unset IFS
    
    # Show skipped packages
    if [ ${#SKIPPED_APT[@]} -gt 0 ]; then
        echo -e "${YELLOW}Warning: The following APT packages are not available for $SYS_ARCH:${RESET}"
        printf "  - %s\n" "${SKIPPED_APT[@]}"
        echo
    fi
    
    # Build dialog options array
    local dialog_options=()
    for entry in "${sorted_entries[@]}"; do
        IFS='|' read -r pkg type desc state <<< "$entry"
        dialog_options+=("$pkg" "$desc" "$state")
    done
    
    # Show unified menu
    if [ ${#dialog_options[@]} -eq 0 ]; then
        echo -e "${RED}No packages available for your system.${RESET}"
        return 1
    fi
    
    echo -e "${BLUE}${BOLD}Please select packages to install:${RESET}"
    SELECTED_PACKAGES=$(dialog --stdout --separate-output \
        --checklist "Select packages to install (alphabetically sorted):" \
        30 100 25 \
        "${dialog_options[@]}")
    
    clear
    echo
}

# Generate the unified menu
generate_unified_menu || { echo -e "${YELLOW}No packages selected.${RESET}"; exit 0; }

# =============================================================================
# SEPARATE SELECTIONS BY TYPE
# =============================================================================

# Create lookup table for package types
declare -A PACKAGE_TYPES
for ((i=0; i<${#ALL_PACKAGES[@]}; i+=2)); do
    PACKAGE_TYPES["${ALL_PACKAGES[$i]}"]="${ALL_PACKAGES[$((i+1))]}"
done
for ((i=0; i<${#ALL_PACKAGES_OPTIONAL[@]}; i+=2)); do
    PACKAGE_TYPES["${ALL_PACKAGES_OPTIONAL[$i]}"]="${ALL_PACKAGES_OPTIONAL[$((i+1))]}"
done

# Separate selections by type
APT_SELECTED=""
FLATPAK_SELECTED=""
SNAP_SELECTED=""
GNOME_SELECTED=""
DESKTOP_SELECTED=""

for pkg in $SELECTED_PACKAGES; do
    type="${PACKAGE_TYPES[$pkg]}"
    case "$type" in
        APT) APT_SELECTED+="$pkg " ;;
        FLATPAK) FLATPAK_SELECTED+="$pkg " ;;
        SNAP) SNAP_SELECTED+="$pkg " ;;
        GNOME) GNOME_SELECTED+="$pkg " ;;
        DESKTOP) DESKTOP_SELECTED+="$pkg " ;;
    esac
done

# Trim trailing spaces
APT_SELECTED=$(echo "$APT_SELECTED" | sed 's/ *$//')
FLATPAK_SELECTED=$(echo "$FLATPAK_SELECTED" | sed 's/ *$//')
SNAP_SELECTED=$(echo "$SNAP_SELECTED" | sed 's/ *$//')
GNOME_SELECTED=$(echo "$GNOME_SELECTED" | sed 's/ *$//')
DESKTOP_SELECTED=$(echo "$DESKTOP_SELECTED" | sed 's/ *$//')

# =============================================================================
# INSTALLATION
# =============================================================================

echo -e "${CYAN}${BOLD}Upgrading system...${RESET}"
$SUDO_CMD apt full-upgrade -y || { echo -e "${RED}System upgrade failed! Aborting.${RESET}"; exit 1; }
echo

# Install flatpak & snap (needed for flatpak/snap packages)
if [ -n "$FLATPAK_SELECTED" ] || [ -n "$SNAP_SELECTED" ] || [ -n "$DESKTOP_SELECTED" ]; then
    echo -e "${CYAN}${BOLD}Installing flatpak & snap...${RESET}"
    $SUDO_CMD apt install -y flatpak snap || { echo -e "${RED}Install failed! Aborting.${RESET}"; exit 1; }
    echo
    
    echo -e "${CYAN}${BOLD}Configuring flathub.org...${RESET}"
    $SUDO_CMD flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || { echo -e "${RED}Failed to configure flathub.org! Aborting.${RESET}"; exit 1; }
    echo
fi

# Install APT packages
if [ -n "$APT_SELECTED" ]; then
    echo -e "${GREEN}${BOLD}Installing APT packages...${RESET}"
    $SUDO_CMD apt install -y $APT_SELECTED || echo -e "${RED}One or more APT packages failed to install.${RESET}"
else
    echo -e "${YELLOW}No APT packages selected.${RESET}"
fi
echo

# Install desktop-specific packages (APT-based)
if [ -n "$GNOME_SELECTED" ]; then
    echo -e "${MAGENTA}${BOLD}Installing GNOME desktop extensions...${RESET}"
    $SUDO_CMD apt install -y $GNOME_SELECTED || echo -e "${RED}Failed to install some GNOME extensions.${RESET}"
    
    # Enable extensions
    echo -e "${MAGENTA}Enabling GNOME extensions...${RESET}"
    if command -v gnome-extensions &>/dev/null; then
        gnome-extensions list 2>/dev/null | xargs -r -I {} gnome-extensions enable {} 2>/dev/null || true
        echo -e "${GREEN}Extensions enabled${RESET}"
    fi
    echo
fi

if [ -n "$DESKTOP_SELECTED" ]; then
    echo -e "${MAGENTA}Installing desktop integration packages...${RESET}"
    $SUDO_CMD apt install -y $DESKTOP_SELECTED || echo -e "${RED}Failed to install some packages.${RESET}"
    echo
fi

# Install Flatpak apps
if [ -n "$FLATPAK_SELECTED" ]; then
    echo -e "${GREEN}${BOLD}Installing Flatpak apps...${RESET}"
    flatpak install -y flathub $FLATPAK_SELECTED || echo -e "${RED}One or more Flatpak apps failed to install.${RESET}"
else
    echo -e "${YELLOW}No Flatpak apps selected.${RESET}"
fi
echo

# Install Snap apps
if [ -n "$SNAP_SELECTED" ]; then
    echo -e "${GREEN}${BOLD}Installing Snap apps...${RESET}"
    for snap in $SNAP_SELECTED; do
        $SUDO_CMD snap install "$snap" || echo -e "${RED}Failed to install $snap.${RESET}"
    done
else
    echo -e "${YELLOW}No Snap apps selected.${RESET}"
fi
echo

echo -e "${CYAN}Setting default web browser to ${BOLD}re.sonny.Junction.desktop${RESET}"
xdg-settings set default-web-browser re.sonny.Junction.desktop || echo -e "${RED}Failed to set default web browser.${RESET}"
echo

echo -e "${GREEN}${BOLD}Installation complete. Thank you for using this script!${RESET}"
