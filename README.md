Mac Pi 
===
Mac OS 8.1 on a Raspberry Pi without a full desktop!
===

*Works with Pi3B or later

*Uses basilisk II emulator.

*Recommended to install rasbian lite as distro choice, otherwise the whole without a desktop (X11) is kinda of useless :)

AUTOMATED FULL INSTALL SCRIPT : 
This can be used as alternative or if it doesnt work follow the guide below :) 


Install Basilisk II without a full desktop (X11) on raspberry pi ( using raspbian stretch lite for distro)
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

You will now need a hard disk image to boot, you can create your own or download the ready made one below
> OPTIONAL Ready made hard drive for download
```
https://mega.nz/file/x3hGRCRb#TB3O35X9jwj_CP_LM_NUyD_eqIw4_UY3YBzc2h1TS9E
```
creating a mac disk image is easy using the mkmacdisk.sh script as follows:
```
sh ./mkmacdisk.sh 
```
> name should be MacHDD
```
MacHDD
```


> size should be 500 , quadra900 supported 500MB since that is the model 14 we will use in our prefs file to match the gestalt ID , even though we will be using Sytem 8.1 which supports larger volumes such as 4GB i found the 500MB to be stable so far. Please feel free to experiment! 

```
500
```


```
echo "rom    /home/pi/Quadra-650.ROM
disk   /home/pi/MacOS8_1.iso
frameskip 0
cpu 4
model 14
ramsize 67108864

```

```
disk   /home/pi/MacHDD.dsk" | tee -a ~/.basilisk_ii_prefs
```

> Setup is finished lets run our newly created Macintosh system within BasiliskII by running execute command , you may add this command to your /etc/rc.local file 

```
BasiliskII
```

> To install Sytem 8.1 boot up Basilisk and then proceed to install 8.1 as normal and install it to MacHDD disk that we created earlier with easy script.

> after installation finished, you can remove the MacOS8_1.iso  from `~/.basilisk_ii_prefs`  , this was for us to boot and install Mac OS onto the machine.
