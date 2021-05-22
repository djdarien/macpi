# macpi
Mac OS 8.1 on Raspberry Pi without X11

Works with PI3B and later

Uses basilisk II emulator.

Recommended to install rasbian lite , otherwise the whole without X11 is kinda of useless :)

install Basilisk II without X11 on raspberry pi (raspbian stretch lite)
===

```
sudo apt update && sudo apt upgrade -y
```

```
sudo apt install automake gobjc -y
```

```
mkdir -p ~/src/sdl2 &&
wget https://www.libsdl.org/release/SDL2-2.0.7.tar.gz -O - | tar -xz -C ~/src/sdl2
```

```
cd ~/src/sdl2/SDL2-2.0.7 &&

./configure --host=arm-raspberry-linux-gnueabihf \
            --disable-video-opengl \
            --disable-video-x11 \
            --disable-pulseaudio \
            --disable-esd \
            --disable-video-mir \
            --disable-video-wayland &&
make -j3 
```

```
sudo make install
```

```
mkdir -p ~/src/macemu &&
wget -O ~/src/macemu/master.zip https://github.com/DavidLudwig/macemu/archive/master.zip &&
unzip ~/src/macemu/master.zip -d ~/src/macemu
```

```
cd ~/src/macemu/macemu-master/BasiliskII/src/Unix/ &&

NO_CONFIGURE=1 ./autogen.sh &&
./configure --enable-sdl-audio --enable-sdl-framework \
            --enable-sdl-video --disable-vosf \
            --without-mon --without-esd --without-gtk --disable-nls &&
make -j3
```

```
sudo make install 
```

```
wget -O ~/MacOS8_1.iso "https://winworldpc.com/download/7724c394-e280-9362-c382-11c3a6e28094" 
```

```
wget -O ~/Quadra-650.ROM https://github.com/macmade/Macintosh-ROMs/raw/master/Quadra-650.ROM
```

```
cd /home/pi

```

```
wget -O ~/mkmacdisk.sh https://github.com/djdarien/macpi/blob/main/mkmacdisk.sh
```


creating a mac disk image is easy using the mkmacdisk.sh script as follows:
```
sh ./mkmacdisk.sh 
```
> name should be MacHDD
```
MacHDD
```


> size should be 500 , quadra900 supported 500MB , we will be using that for Sytem 8.1

```
500
```
```
echo "rom    /home/pi/Quadra-650.ROM
disk   /home/pi/System753.iso
disk   /home/pi/MacOS8_1.iso
frameskip 0
cpu 4
model 14
ramsize 67108864

```

```
disk   /home/pi/MacHDD.dsk" | tee -a ~/.basilisk_ii_prefs
```

```
Basilisk


```
To install Sytem 8.1 boot up Basilisk and then proceed to install 8.1 as normal and install it to MacHDD disk that we created earlier with easy script.

> after installation finished, you can remove both isos from `~/.basilisk_ii_prefs`  , the System7.5.3 was for us to boot the machine.
