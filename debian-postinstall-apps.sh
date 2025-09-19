#!/bin/bash

# Color variables for output
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
BOLD="\033[1m"
RESET="\033[0m"

echo -e "${CYAN}${BOLD}Starting system update...${RESET}"
sudo apt update || { echo -e "${RED}Failed to update package list! Aborting.${RESET}"; exit 1; }
echo

# Preinstall dialog if needed
if ! command -v dialog &> /dev/null; then
    echo -e "${YELLOW}Dialog not found. Installing dialog package for interactive menus...${RESET}"
    sudo apt install -y dialog || { echo -e "${RED}Failed to install dialog. Aborting.${RESET}"; exit 1; }
fi
echo -e "${GREEN}Dialog is installed, proceeding...${RESET}"
echo

# Essential packages with short descriptions (excluding GNOME & XFCE-specific)
ESSENTIAL_PACKAGES=(
    apostrophe "Apostrophe text editor" on
    aria2 "Download utility" on
    bat "Cat clone with syntax highlighting" on
    btop "Resource monitor" on
    cheese "Webcam application" on
    cups "Printing system" on
    cups-filters "CUPS filters" on
    curl "Data transfer tool" on
    evolution "Email and calendar" on
    flatpak "Flatpak package manager" on
    foomatic-db "Printer driver database" on
    gimp "Image editor" on
    git "Version control system" on
    micro "Terminal-based text editor" on
    nomacs "Image viewer" on
    papers "Reference manager" on
    pdfarranger "PDF manipulation tool" on
    printer-driver-all "Generic printer drivers" on
    pixz "Parallel lossless compression" on
    simple-scan "Document scanner app" on
    snap "Snap package manager" on
    system-config-printer "Printer config tool" on
    uget "Download manager" on
    unrar-free "RAR archive extractor" on
    vlc "Media player" on
    wget "Command line downloader" on
    xclip "Clipboard manager via CLI" on
    yt-dlp "Youtube downloader" on
    zsh "Shell alternative to bash" on
)

echo -e "${BLUE}${BOLD}Please select the essential packages to install:${RESET}"
ESSENTIAL_SELECTED=$(dialog --stdout --separate-output \
    --checklist "Select essential packages (GNOME/XFCE packages installed by default):" 20 80 15 \
    "${ESSENTIAL_PACKAGES[@]}")
clear
echo

arch=$(uname -m)

# Base Flatpak apps (arch independent)
FLATPAK_APPS=(
    com.github.huluti.Curtail "Video trimming tool" on
    im.riot.Riot "Decentralized chat client" on
    org.flozz.yoga-image-optimizer "Image optimizer" on
    com.brave.Browser "Brave web browser" on
    com.rtosta.zapzap "WhatsApp client" on
    com.rustdesk.RustDesk "Remote desktop" on
    io.freetubeapp.FreeTube "Youtube client" on
    io.github.qtox.qTox "Secure instant messaging" on
    io.gitlab.librewolf-community "Privacy focused Firefox fork" on
    org.localsend.localsend_app "Local file sharing" on
    re.sonny.Junction "Custom web browser" on
)

if [ "$arch" = "x86_64" ]; then
    # Append x86_64-specific apps
    FLATPAK_APPS+=(
        app/org.onlyoffice.desktopeditors "OnlyOffice Desktop Editors" on
        app/org.signal.Signal "Signal messenger" on
    )
fi

# Show dialog checklist with filtered FLATPAK_APPS
FLATPAK_SELECTED=$(dialog --stdout --separate-output \
    --checklist "Select Flatpak apps to install:" 20 80 15 \
    "${FLATPAK_APPS[@]}")

clear
echo

echo -e "${CYAN}${BOLD}Upgrading system...${RESET}"
sudo apt full-upgrade -y || { echo -e "${RED}System upgrade failed! Aborting.${RESET}"; exit 1; }
echo

# Install selected essential packages
if [ -n "$ESSENTIAL_SELECTED" ]; then
    echo -e "${GREEN}${BOLD}Installing selected essential packages...${RESET}"
    sudo apt install -y $ESSENTIAL_SELECTED || echo -e "${RED}One or more essential packages failed to install.${RESET}"
else
    echo -e "${YELLOW}No essential packages selected for installation.${RESET}"
fi
echo

# Always install GNOME desktop extensions
echo -e "${MAGENTA}${BOLD}Installing GNOME desktop extensions...${RESET}"
sudo apt install -y \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-arc-menu \
    gnome-shell-extension-dashtodock \
    gnome-shell-extension-easyscreencast \
    gnome-shell-extension-freon \
    gnome-shell-extension-gpaste \
    gnome-shell-extension-gsconnect \
    gnome-shell-extension-gsconnect-browsers \
    gnome-shell-extension-system-monitor || echo -e "${RED}Failed to install some GNOME extensions.${RESET}"
echo

# Always install XFCE and GNOME Flatpak plugins if desktop environment matches
if [ "$XDG_CURRENT_DESKTOP" = "XFCE" ] || [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
    echo -e "${MAGENTA}Installing Flatpak and Snap plugins for app stores...${RESET}"
    sudo apt install -y \
        gnome-software-plugin-flatpak \
        gnome-software-plugin-snap || echo -e "${RED}Failed to install software plugins.${RESET}"
    echo
fi

# Install selected Flatpak apps
if [ -n "$FLATPAK_SELECTED" ]; then
    echo -e "${GREEN}${BOLD}Installing selected Flatpak apps...${RESET}"
    flatpak install -y $FLATPAK_SELECTED || echo -e "${RED}One or more Flatpak apps failed to install.${RESET}"
else
    echo -e "${YELLOW}No Flatpak apps selected for installation.${RESET}"
fi
echo

# Detect CPU architecture and install additional Flatpak apps if x86_64
if [ "$arch" = "x86_64" ]; then
    echo -e "${GREEN}64-bit architecture detected. Installing additional Flatpak apps...${RESET}"
    flatpak install -y \
        app/org.onlyoffice.desktopeditors \
        app/org.signal.Signal || echo -e "${RED}Failed to install additional Flatpak apps.${RESET}"
else
    echo -e "${YELLOW}CPU is not x86_64, skipping some Flatpak installations.${RESET}"
fi
echo

echo -e "${CYAN}Setting default web browser to ${BOLD}re.sonny.Junction.desktop${RESET}"
xdg-settings set default-web-browser re.sonny.Junction.desktop || echo -e "${RED}Failed to set default web browser.${RESET}"
echo

echo -e "${GREEN}${BOLD}Installation complete. Thank you for using this script!${RESET}"
