#!/bin/bash

printf "Enter the disk you want to install arch linux to:"
read -r DISK
printf "Arch will be installed on $DISK. Continue? [Y/n]: "
read -r CONTINUE

# Stop execution if the read value is not Y or empty string
if [[ $CONTINUE ]] && [ "$CONTINUE" != "Y" ]
then
  exit 0
fi

timedatectl set-ntp true

PART1="1"
PART2="2"
if [[ $DISK == *"nvme"* ]]; then
  PART1="p1"
  PART2="p2"
fi
# Disk partitioning
# More info: https://www.rodsbooks.com/gdisk/sgdisk-walkthrough.html

# Convert disk to GPT and clear disk
sgdisk -go $DISK

# Create boot partition
FIRSTSECTOR=`sgdisk -F $DISK`
sgdisk -n 1:$FIRSTSECTOR:+500M -c 1:"boot" -t 1:ef00 $DISK

# Create partition for luks
NEXTSECTOR=`sgdisk -f $DISK`
ENDSECTOR=`sgdisk -E $DISK`
sgdisk -n 2:$NEXTSECTOR:$ENDSECTOR -c 2:"luks" -t 2:8e00 $DISK

# Set up luks
cryptsetup luksFormat --type luks2 ${DISK}${PART2}
cryptsetup open ${DISK}${PART2} cryptlvm

pvcreate /dev/mapper/cryptlvm
vgcreate cryptvg /dev/mapper/cryptlvm

# Create logical volumes for swap /root and/home
printf "How big should the swap parition be? [n]{MG}"
read -r SWAP
lvcreate -L $SWAP cryptvg -n swap

printf "How big should the root partition be? [n]{MG}"
read -r ROOT
lvcreate -L $ROOT cryptvg -n root
lvcreate -l 100%FREE cryptvg -n home

# Format partitions
mkfs.fat -F32 ${DISK}${PART1}
mkfs.ext4 /dev/cryptvg/root
mkfs.ext4 /dev/cryptvg/home
mkswap /dev/cryptvg/swap

mount /dev/cryptvg/root /mnt
mkdir /mnt/home
mount /dev/cryptvg/home /mnt/home
swapon /dev/cryptvg/swap
mkdir /mnt/boot
mount ${DISK}${PART1} /mnt/boot

# Install arch!
pacstrap /mnt base linux linux-firmware

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Make script executable
chmod +x setup.sh

# Copy setup script to new installation
cp setup.sh /mnt

# Change to root in new installation
arch-chroot /mnt ./setup.sh "${DISK}${PART2}"
