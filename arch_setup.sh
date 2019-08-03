#!/bin/bash

# Initial config
rm /etc/localtime
ln -sf /usr/share/zoneinfo/Canada/Eastern /etc/localtime
hwclock --systohc

locale-gen "en_CA.UTF-8"

echo "LANG=en_CA.UTF-8" >> /etc/locale.conf

echo KEYMAP=us >> /etc/vconsole.conf

# Set hostname and update hosts file
echo 'Please enter a hostname'
read HOSTNAME

echo "${HOSTNAME}" >> /etc/hostname

echo "127.0.0.1  localhost" >> /etc/hosts
echo "::1" >> /etc/hosts
echo "127.0.0.1  Aite.local   Aite" >> /etc/hosts

# Set root password
echo "Root password"
passwd

# Install essential packages
pacman -Sy vim openssh git sudo lightdm tree intel-ucode weston gnome gnome-extra libreoffice-fresh firefox

# Configure mkinitcpio
sed -i '/HOOKS\=/d' /etc/mkinitcpio.conf
sed -i '/\#/d' /etc/mkinitcpio.conf
echo "HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 filesystems fsck)" >> /etc/mkinitcpio.conf

# Enable multilib in pacman
echo "[multilib]
Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf

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
fs_uuid=$(blkid -o value -s UUID /dev/sda2)

# Set up arch conf file for boot loader
echo "title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options cryptdevice=UUID=${fs_uuid}:cryptvg root=/dev/cryptvg/root rw" >> /boot/loader/entries/arch.conf

# Start ssh service
systemctl enable sshd.service

# Admin user creation
echo 'Please enter a username'
read USERNAME

useradd --create-home --groups wheel --shell /bin/bash ${USERNAME}
echo "User password"
passwd ${USERNAME}

echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# cp arch_user_setup.sh /home/${USERNAME}/
# su - ${USERNAME} /home/${USERNAME}/arch_user_setup.sh
