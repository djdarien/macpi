#!/bin/bash
# Created by Darien Entwistle
#This script updates the package lists, installs necessary dependencies, compiles and installs SDL2 and Basilisk II, 
#downloads the required ROM and MacOS image, and sets up a Mac disk image.
# It also sets up the Basilisk II preferences file and optionally adds an execution command to /etc/rc.local for automatic startup.

# Update package lists and install dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install automake gobjc unzip -y

# Install SDL2
mkdir -p ~/src/sdl2 &&
wget https://www.libsdl.org/release/SDL2-2.0.7.tar.gz -O - | tar -xz -C ~/src/sdl2
cd ~/src/sdl2/SDL2-2.0.7 &&
./configure --host=arm-raspberry-linux-gnueabihf \
            --disable-video-opengl \
            --disable-video-x11 \
            --disable-pulseaudio \
            --disable-esd \
            --disable-video-mir \
            --disable-video-wayland &&
make -j3
sudo make install

# Install Basilisk II
mkdir -p ~/src/macemu &&
wget -O ~/src/macemu/master.zip https://github.com/DavidLudwig/macemu/archive/master.zip &&
unzip ~/src/macemu/master.zip -d ~/src/macemu
cd ~/src/macemu/macemu-master/BasiliskII/src/Unix/ &&
NO_CONFIGURE=1 ./autogen.sh &&
./configure --enable-sdl-audio --enable-sdl-framework \
            --enable-sdl-video --disable-vosf \
            --without-mon --without-esd --without-gtk --disable-nls &&
make -j3
sudo make install

# Download ROM and MacOS image
wget -O ~/Quadra-650.ROM https://github.com/macmade/Macintosh-ROMs/raw/master/Quadra-650.ROM
wget -O ~/MacOS8_1.iso "https://winworldpc.com/download/7724c394-e280-9362-c382-11c3a6e28094"

# Create Mac disk image
wget -O ~/mkmacdisk.sh https://github.com/djdarien/macpi/raw/main/mkmacdisk.sh
chmod +x ~/mkmacdisk.sh
cd ~
echo -e "MacHDD\n500\n" | ./mkmacdisk.sh

# Set up Basilisk II preferences
echo -e "rom    /home/pi/Quadra-650.ROM\ndisk   /home/pi/MacOS8_1.iso\nframeskip 0\ncpu 4\nmodel 14\nramsize 67108864\ndisk   /home/pi/MacHDD.dsk" | tee -a ~/.basilisk_ii_prefs

# Optional: Add Basilisk II execution command to /etc/rc.local
sudo sed -i -e '$i\no /usr/local/bin/BasiliskII\nexit 0' /etc/rc.local
