#!/bin/bash
#ALL CREDIT GOES novaspirit.com 
#https://www.novaspirit.com/2017/03/28/running-mac-os-7-on-raspberry-pi-with-color/
#this is not mine im just sharing it to make life easier :D 

sudo apt-get update
sudo apt-get install hfsutils -y

echo -n "Enter the name of the disk: "
read dskname

echo -n "Enter the size of disk in MB (ie: 100): "
read size

sudo dd if=/dev/zero of=$dskname.dsk bs=1M count=$size
sudo hformat -l $dskname $dskname.dsk

sudo chown pi:pi $dskname.dsk
