#!/bin/bash

# Install yay for aur
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Install aur packages
yay -S lightdm-slick-greeter google-chrome ttf-dejavu visual-studio-code-bin rbenv ruby-build nvm mysql

# Modify lightdm conf to use slick greeter
sed -i '/greeter-session/d' /etc/lightdm/lightdm.conf
echo "greeter-session=lightdm-slick-greeter" >> /etc/lightdm/lightdm.conf

# Gnome won't show a wayland option until gnome.desktop for xorg is removed/renamed
# /usr/share/wayland-sessions has a gnome.desktop file that will then be seen by lightdm
mv /usr/share/xsessions/gnome.desktop /usr/share/xsessions/gnome.desktop.bak

# Configure bash for nvm and rbenv
echo 'source /usr/share/nvm/init-nvm.sh' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc 
source ~/.bashrc

# Install ruby and node
rbenv install 2.6.3
rbenv global 2.6.3

nvm install node
nvm use node

