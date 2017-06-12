#!/usr/bin/env bash

#######################################################
# Script for automatically mounting microbit to local #
# directory and flashing a python script onto it.     #
# (using uflas)                                       #
# ! meant only for convenience !                      #
# needs root privelages for mounting.                 #
#######################################################

# requires uflash:
# pip install uflash

# create local directory for mounting if it doesn't exist
if [ -d .MICROBIT-mnt ]; then
    echo "Mount directory exists."
else
    echo "Creating mount directory"
    mkdir .MICROBIT-mnt
fi

# mount MICROBIT to local directory
if mount | grep ".MICROBIT-mnt" > /dev/null; then
  echo "Already mounted."
else
  echo "Mounting microbit..."
  mount /dev/disk/by-label/MICROBIT ./.MICROBIT-mnt
fi

# first command line argument is py file
FILE=$1

# flash python file
uflash $FILE ./.MICROBIT-mnt

# unmount MICROBIT
umount ./.MICROBIT-mnt
