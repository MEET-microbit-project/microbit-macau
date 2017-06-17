#!/bin/sh

#######################################################
# Script for automatically mounting microbit to local #
# directory and flashing a python script onto it.     #
# (using uflas)                                       #
# ! meant only for convenience !                      #
# needs root privelages for mounting.                 #
#######################################################

# requires uflash, microfs:
# pip install uflash microfs


if [ "$1" = "-h" ]; then
  printf "Use this script to automatically mount and push to the microbit. "
  printf "There are four modes:\n"
  printf "\tWith the option -h, this text is displayed.\n"
  printf "\tIf no argument is provided, the MicroPython runtime is flashed.\n"
  printf "\tOne python script provided, this is flashed onto the microbit.\n"
  printf "\tGiven \"--put\" and a number of python files provided, the runtime "
  printf "will be flashed and the python files transfered to the filesystem.\n"

else

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


  case $# in
    0)
      printf "Flashing only the MicroPython runtime."
      # if no argument is passed, flash the MicroPython runtime
      uflash
      ;;
    1)
      # flash python file
      uflash "$1" $MOUNT_DIR
      ;;
    *)
      if [ "$1" = "--put" ]; then
        # flash the runtime
        uflash

        echo "Waiting for compilation..."
        umount $MOUNT_DIR

        printf "Uploading files:\n"
        shift 1
        for py in "$@"
        do
          case "$py" in
            *.py)
              echo "uploading $py..."
              ufs put "$py"
              ;;
            *)
              echo "skipping $py."
          esac
        done
      else
        printf "Unknown argument \"$0\".\n"
        printf "Use flag -h for help. \n"
        exit 1
      fi
  esac

  if mount | grep "$MOUNT_DIR" > /dev/null; then
    # unmount MICROBIT and delete mount folder
    umount $MOUNT_DIR
    rmdir $MOUNT_DIR
  fi
fi
