#!/bin/bash

# SETUP SCRIPT FOR FEDORA BASED DISTROS USING DNF

# BRAVE
#sudo systemctl disable NetworkManager-wait-online.service  # Think this is just for Ubuntu derivatives.  sudo systemd-analyze critical-chain indicates they waste 5s on boot
sudo dnf install dnf-plugins-core
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install brave-browser

# FLATPAK STUFF
#sudo flatpak install -y --noninteractive --system org.gtk.Gtk3theme.Breeze
#sudo flatpak override --filesystem=xdg-config/gtk-3.0:ro
sudo flatpak install flathub -y com.heroicgameslauncher.hgl

# INSTALLS, REMOVES & TWEAKS
sudo dnf install -y bottles lutris dosbox-staging neofetch bleachbit python3-pip mc git ncdu gamemode hunspell-en-GB vlc powertop steam steam-devices curl retroarch
sudo dnf remove -y plasma-welcome ktorrent firefox neochat skanpage kmahjongg
sudo dnf upgrade -y && sudo dnf autoremove -y
sudo printf "neofetch" >> /home/$USER/.bashrc
sudo timedatectl set-local-rtc 1 --adjust-system-clock

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

# POWER TUNING
#wget https://github.com/methanoid/setup/blob/main/powertuning.sh
#sudo sh ./powertuning.sh

# CONF files?
# make konsole & BRAVE favouriteS
# screen locking,sleep settings
