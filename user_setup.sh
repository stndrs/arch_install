#!/bin/bash

# Install yay for aur
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Install aur packages
yay -S ttf-dejavu rbenv ruby-build nvm

# Configure bash for nvm and rbenv
echo 'source /usr/share/nvm/init-nvm.sh' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc 
source ~/.bashrc

# Install ruby and node
rbenv install 2.6.3
rbenv global 2.6.3

nvm install node
nvm use node

