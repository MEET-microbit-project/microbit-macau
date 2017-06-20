#!/bin/sh

########################################################
# Script for automatically mounting microbit to local  #
# directory, flashing a python script onto it (uflash) #
# and uploading files (microfs).                       #
# ! meant only for convenience !                       #
# Needs root privelages for mounting.                  #
########################################################

# requires uflash, microfs:
# pip install uflash microfs


if [ "$1" = "-h" ] || [ "$1" = "-help" ] || [ "$1" = "--help" ]; then
  printf "usage: ./run.sh [-h] [source] [--put file [file ...]]\n\n"
  printf "Use this script to automatically mount and push to the microbit.\n"
  printf "If source is specified, flash MicroPython together with this "
  printf "python script. If specified, the files listed after --put are "
  printf "transfered to the microbit. Use -h to print this help message.\n"
  exit 0
fi

if [ "$1" = "-mnt" ]; then
  MOUNT_DIR="$2"
  shift 2
else
  # local mount folder
  MOUNT_DIR="/media/$USER/MICROBIT"
fi

# need root privelages for mounting
[ $(id -u) != "0" ] && exec sudo "$0" "-mnt" "$MOUNT_DIR" "$@"

# create local directory for mounting if it doesn't exist
if [ -d $MOUNT_DIR ]; then
  printf "Mount directory exists.\n"
else
  printf "Creating mount directory...\n"
  mkdir $MOUNT_DIR
fi

# mount MICROBIT to local directory
if mount | grep "$MOUNT_DIR" > /dev/null; then
  printf "Already mounted.\n"
else
  printf "Mounting microbit...\n"
  mount /dev/disk/by-label/MICROBIT $MOUNT_DIR
fi

if [ $# -eq 0 ] || [ "$1" = "--put" ]; then
  printf "Flashing the unmodified MicroPython runtime...\n"
  # if no python script is passed, flash the unmodified MicroPython runtime
  uflash
else
  printf "Flashing MicroPython runtime with script \"$1\"...\n"
  uflash "$1" $MOUNT_DIR
  shift
fi

if [ "$1" = "--put" ]; then
  shift

  umount $MOUNT_DIR

  printf "Uploading files:\n"
  for file in "$@"
  do
    if [ -f "$file" ]; then
      printf "\tuploading $file...\n"
      ufs put "$file"
    else
      printf "\tskipping $file: this is not a file.\n"
    fi
  done
elif [ $# -ne 0 ]; then
  printf "Can only flash runtime together with one script. "
  printf "Use --put to upload a file to the file system. \n"
  printf "For help use the flag \"-h\".\n"
  exit 1
fi

if mount | grep "$MOUNT_DIR" > /dev/null; then
  # unmount MICROBIT and delete mount folder
  umount $MOUNT_DIR
  rmdir $MOUNT_DIR
fi
