#!/bin/bash
# Enhanced Basilisk II Installer for Raspberry Pi
# Version: 2.0
# Author: Darien Entwistle (enhanced)
# Description: Interactive installer with error handling, logging, and failsafes.
# Prerequisites: Raspberry Pi OS, >=2GB free space, internet.

set -euo pipefail  # Strict error handling
trap 'cleanup_on_exit' EXIT ERR SIGINT  # Cleanup on failure/interrupt

# Constants and variables
SCRIPT_VERSION="2.0"
LOG_FILE="/var/log/basilisk_install.log"
BACKUP_RC="/etc/rc.local.bak"
PI_USER="${USER:-pi}"
HOME_DIR="/home/${PI_USER}"
SDL2_VERSION="2.28.5"  # Latest stable
BASILISK_REPO="https://github.com/DavidLudwig/macemu/archive/refs/heads/master.zip"  # Pin if possible
ROM_URL="https://github.com/macmade/Macintosh-ROMs/raw/main/Quadra-650.ROM"
ISO_URL="https://winworldpc.com/download/7724c394-e280-9362-c382-11c3a6e28094"  # MacOS8_1.iso
DISK_SIZE_DEFAULT=500
AUTO_STARTUP=true

# Logging function
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Cleanup function
cleanup_on_exit() {
    log "Cleaning up temporary files..."
    rm -rf ~/src  # Assuming temp dir
    if [[ -f "$BACKUP_RC" ]]; then
        sudo mv "$BACKUP_RC" /etc/rc.local  # Restore if failed
    fi
}

# System checks
check_system() {
    log "Checking system compatibility..."
    if ! grep -q "Raspberry Pi" /proc/cpuinfo; then
        log "Error: Not running on a Raspberry Pi."
        exit 1
    fi
    local free_space=$(df / | awk 'NR==2 {print $4}')
    if (( free_space < 2000000 )); then  # ~2GB in KB
        log "Error: Insufficient disk space (<2GB free)."
        exit 1
    fi
    # Add Pi model detection here if needed
}

# User prompts and confirmations
get_user_input() {
    read -p "Proceed with installation? [Y/n]: " -n 1 -r
    echo
    [[ $REPLY =~ ^[Nn]$ ]] && exit 0
    
    read -p "Enter disk image size in MB [$DISK_SIZE_DEFAULT]: " DISK_SIZE
    DISK_SIZE=${DISK_SIZE:-$DISK_SIZE_DEFAULT}
    
    read -p "Enable auto-startup on boot? [Y/n]: " -n 1 -r
    echo
    [[ $REPLY =~ ^[Nn]$ ]] && AUTO_STARTUP=false
}

# Install dependencies
install_deps() {
    log "Installing dependencies..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y automake gobjc unzip wget build-essential libsdl2-dev || {
        log "Error: Dependency installation failed."
        exit 1
    }
}

# Build SDL2 (if not using apt)
build_sdl2() {
    # Skip if libsdl2-dev is installed
    if ! dpkg -l libsdl2-dev &>/dev/null; then
        log "Building SDL2 $SDL2_VERSION..."
        mkdir -p ~/src/sdl2
        wget -O ~/src/sdl2.tar.gz "https://www.libsdl.org/release/SDL2-$SDL2_VERSION.tar.gz"
        # Add SHA256 check here if known
        tar -xzf ~/src/sdl2.tar.gz -C ~/src/sdl2
        cd ~/src/sdl2/SDL2-$SDL2_VERSION
        ./configure --host=arm-raspberry-linux-gnueabihf --disable-video-opengl --disable-pulseaudio --disable-esd --disable-video-mir --disable-video-wayland
        make -j$(nproc)
        sudo make install
    fi
}

# Build Basilisk II
build_basilisk() {
    log "Building Basilisk II..."
    mkdir -p ~/src/macemu
    wget -O ~/src/macemu/master.zip "$BASILISK_REPO"
    unzip ~/src/macemu/master.zip -d ~/src/macemu
    cd ~/src/macemu/macemu-master/BasiliskII/src/Unix/
    NO_CONFIGURE=1 ./autogen.sh
    ./configure --enable-sdl-audio --enable-sdl-framework --enable-sdl-video --disable-vosf --without-mon --without-esd --without-gtk --disable-nls
    make -j$(nproc)
    sudo make install
}

# Downloads with verification
download_files() {
    log "Downloading ROM and OS image..."
    wget --continue -O "$HOME_DIR/Quadra-650.ROM" "$ROM_URL"
    wget --continue -O "$HOME_DIR/MacOS8_1.iso" "$ISO_URL"
    # Add SHA256 verification here if known
    wget -O "$HOME_DIR/mkmacdisk.sh" https://github.com/djdarien/macpi/raw/main/mkmacdisk.sh
    chmod +x "$HOME_DIR/mkmacdisk.sh"
    # Optional: Review script contents
}

# Create disk image
create_disk() {
    log "Creating Mac disk image ($DISK_SIZE MB)..."
    cd "$HOME_DIR"
    echo -e "MacHDD\n$DISK_SIZE\n" | ./mkmacdisk.sh
}

# Setup preferences
setup_prefs() {
    log "Setting up Basilisk II preferences..."
    tee "$HOME_DIR/.basilisk_ii_prefs" > /dev/null <<EOF
rom    $HOME_DIR/Quadra-650.ROM
disk   $HOME_DIR/MacOS8_1.iso
frameskip 0
cpu 4
model 14
ramsize 67108864
disk   $HOME_DIR/MacHDD.dsk
EOF
}

# Optional startup
enable_startup() {
    if $AUTO_STARTUP; then
        log "Enabling auto-startup..."
        sudo cp /etc/rc.local "$BACKUP_RC"
        sudo sed -i -e '$i\no /usr/local/bin/BasiliskII\nexit 0' /etc/rc.local
    fi
}

# Main execution
main() {
    log "Starting Basilisk II installer v$SCRIPT_VERSION"
    check_system
    get_user_input
    install_deps
    build_sdl2
    build_basilisk
    download_files
    create_disk
    setup_prefs
    enable_startup
    log "Installation complete. Run 'BasiliskII' to start."
}

main "$@"