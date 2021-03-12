#!/bin/bash

# Disable internal speaker (system beep)
sudo rmmod pcspkr
echo "blacklist pcspkr" | sudo tee /etc/modprobe.d/nobeep.conf

# Enable networking
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

# AUR helper
cd $HOME
sudo pacman -S git base-devel --noconfirm
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd $HOME
sudo rm -r yay

# To change backlight with xbacklight (via acpilight package)
sudo usermod -aG video $USER

# Allow passwordless rfkill (e.g. sudo rfkill block bluetooth)
sudo cp $HOME/.local/cfg/rfkill /etc/sudoers.d/rfkill
