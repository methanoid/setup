#!/bin/bash

# SETUP SCRIPT FOR FEDORA BASED DISTROS USING DNF

# NALA & BASIC UPGRADES
localepurge curl
  sudo systemctl disable NetworkManager-wait-online.service  # Think this is just for Ubuntu derivatives.  sudo systemd-analyze critical-chain indicates they waste 5s on boot
  sudo apt update


# FLATPAK STUFF
sudo flatpak install -y --noninteractive --system org.gtk.Gtk3theme.Breeze
sudo flatpak override --filesystem=xdg-config/gtk-3.0:ro
sudo flatpak install flathub -y io.gitlab.librewolf-community
sudo flatpak install flathub -y com.brave.Browser
sudo flatpak install flathub -y com.usebottles.bottles
sudo flatpak install flathub -y org.libretro.RetroArch
sudo flatpak install flathub -y com.heroicgameslauncher.hgl
sudo flatpak install flathub -y com.valvesoftware.Steam
sudo flatpak install flathub -y net.lutris.Lutris
sudo flatpak install flathub -y io.github.dosbox-staging

# GPU SPECIFICS
gpu=$(lspci | grep -i '.* vga .* nvidia .*') && shopt -s nocasematch
if [[ $gpu == *' nvidia '* ]]; then
  printf 'Installing Nvidia GPU bits:  %s\n'
  sudo nala install nvidia-driver
  sudo sed 's/splash/splash nvidia-drm.modeset=1/' /etc/default/grub-btrfs/config
  # rhgb grub option for Fedora/RedHat distros
  sudo flatpak --user install flathub com.leinardi.gwe
  sudo flatpak update  # needed to be sure to have the latest org.freedesktop.Platform.GL.nvidia
else
  printf 'Installing AMD GPU bits:  %s\n'
  printf "RADV_PERFTEST=aco" >> /etc/environment
fi

# INSTALLS & TWEAKS
sudo nala install -y neofetch bleachbit ufw python3-pip mc easyssh libavcodec-extra git make ncdu gamemode hunspell-en-gb vlc powertop steam-devices
sudo nala purge -y 
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
sudo apt-get install ttf-mscorefonts-installer

# sudo nala install -y preload

# TIDY UP & UPGRADES
sudo nala upgrade -y && sudo nala clean && sudo nala autoremove -y && sudo nala autopurge -y
sudo printf "neofetch" >> /home/$USER/.bashrc
sudo timedatectl set-local-rtc 1 --adjust-system-clock

# POWER TUNING
wget https://github.com/methanoid/setup/blob/main/powertuning.sh
sudo sh ./powertuning.sh

# CONF files?
# make konsole & BRAVE favouriteS
# screen locking,sleep settings
