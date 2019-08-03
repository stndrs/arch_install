#!/bin/bash

echo "Enter the disk you want to install arch linux to:"
read DISK
echo "Arch will be installed on ${DISK}. Hit enter to continue"

timedatectl set-ntp true

# Disk partitioning
# More info: https://www.rodsbooks.com/gdisk/sgdisk-walkthrough.html

# Convert disk to GPT and clear disk
sgdisk -go ${DISK}

# Create boot partition
FIRSTSECTOR=`sgdisk -F ${DISK}`
sgdisk -n 1:${FIRSTSECTOR}:+500M -c 1:"boot" -t 1:ef00 ${DISK}

# Create partition for luks
NEXTSECTOR=`sgdisk -f ${DISK}`
ENDSECTOR=`sgdisk -E ${DISK}`
sgdisk -n 2:${NEXTSECTOR}:${ENDSECTOR} -c 2:"luks" -t 1:8e00 ${DISK}

# Set up luks
cryptsetup luksFormat --type luks2 ${DISK}2
cryptsetup open ${DISK}2 cryptlvm

pvcreate /dev/mapper/cryptlvm
vgcreate cryptvg /dev/mapper/cryptlvm

# Create logical volumes for swap /root and/home
echo "How big should the swap parition be? [n]{MG}"
read SWAP
lvcreate -L ${SWAP} cryptvg -n swap

echo "How big should the root partition be? [n]{MG}"
read ROOT
lvcreate -L ${ROOT} cryptvg -n root
lvcreate -l 100%FREE cryptvg -n home

# Format partitions
mkfs.fat -F32 ${DISK}1
mkfs.ext4 /dev/cryptvg/root
mkfs.ext4 /dev/cryptvg/home
mkswap /dev/cryptvg/swap

mount /dev/cryptvg/root /mnt
mkdir /mnt/home
mount /dev/cryptvg/home /mnt/home
swapon /dev/cryptvg/swap
mkdir /mnt/boot
mount ${DISK}1 /mnt/boot

# Install arch!
pacstrap /mnt base base-devel

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Make script executable
chmod +x setup.sh

# Copy setup script to new installation
cp setup.sh /mnt

# Change to root in new installation
arch-chroot /mnt ./setup.sh

