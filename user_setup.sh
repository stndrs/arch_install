#!/bin/bash

# Install aur packages
yay -S ttf-dejavu rbenv ruby-build nvm authenticator nordvpn-bin
sudo systemctl enable --now nordvpnd

# Configure bash for nvm and rbenv
echo 'source /usr/share/nvm/init-nvm.sh' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc 
source ~/.bashrc
