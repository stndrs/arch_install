#!/bin/bash

PART=$1

# Make sure the variable contains a forward slach
if [[ ! $PART ]]
then
  printf "Enter the partition where the LUKS partition can be found: "
  read -r PART
fi

printf "
The bootloader will use the UUID for $PART as the target for decryption.
Continue? [Y/n]: "

read -r CONTINUE

if [[ $CONTINUE ]] && [ "$CONTINUE" != "Y" ]
then
  exit 0
fi

# Initial config
rm /etc/localtime
ln -sf /usr/share/zoneinfo/Canada/Eastern /etc/localtime
hwclock --systohc

# Uncomment desired locale
sed -i 's/#en_CA.UTF/en_CA.UTF/g' /etc/locale.gen
locale-gen

echo "LANG=en_CA.UTF-8" >> /etc/locale.conf

echo KEYMAP=us >> /etc/vconsole.conf

# Set hostname and update hosts file
printf 'Please enter a hostname: '
read HOSTNAME

echo "$HOSTNAME" >> /etc/hostname

echo "127.0.0.1  localhost" >> /etc/hosts
echo "::1" >> /etc/hosts
echo "127.0.0.1  $HOSTNAME.local   $HOSTNAME" >> /etc/hosts

# Set root password
echo "Set root password"
passwd

# Install essential packages
pacman -Sy vim openssh git sudo tree intel-ucode \
           weston mariadb libreoffice-fresh gnome \
           gnome-tweaks deja-dup gnome-podcasts \
           gopass chrome-gnome-shell

# Configure mkinitcpio
sed -i '/HOOKS\=/d' /etc/mkinitcpio.conf
sed -i '/\#/d' /etc/mkinitcpio.conf
echo "HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 filesystems fsck)" >> /etc/mkinitcpio.conf

# Enable multilib in pacman
echo "[multilib]
Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf

# Upgrade after enabling multilib
pacman -Syu

# Generate new initramfs
mkinitcpio -p linux

# Install boot manager
bootctl --path=/boot install

# Create loader conf
rm /boot/loader/loader.conf
touch /boot/loader/loader.conf

echo "default arch
timeout 0
editor  no" >> /boot/loader/loader.conf

touch /boot/loader/entries/arch.conf

# Get the uuid of the luks partition to be loaded by the boot loader
fs_uuid=$(blkid -o value -s UUID $PART)

# Set up arch conf file for boot loader
echo "title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options cryptdevice=UUID=$fs_uuid:cryptvg root=/dev/cryptvg/root rw" >> /boot/loader/entries/arch.conf

# Start services
systemctl enable sshd.service
systemctl enable NetworkManager.service
systemctl enable gdm.service

# Admin user creation
printf "Please enter a username: "
read -r USERNAME

useradd --create-home --groups wheel --shell /bin/bash $USERNAME
printf "User password"
passwd $USERNAME

echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

