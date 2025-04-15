#!/bin/bash

# SETUP SCRIPT FOR FEDORA BASED DISTROS USING DNF

echo "Installing RPM Fusion..."
sudo dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${os_version}.noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${os_version}.noarch.rpm"
sudo dnf update -y # and reboot if you are not on the latest kernel

nvgpu=$(lspci | grep -i nvidia | grep -i vga | cut -d ":" -f 3)
if [[ $nvgpu ]]; then
  sudo -S dnf install -y akmod-nvidia # xorg-x11-drv-nvidia-cuda gwe
fi
#else
#  printf 'Installing AMD GPU bits:  %s\n'
#  printf "RADV_PERFTEST=aco" >> /etc/environment
#fi
hostnamectl set-hostname new-name

# BRAVE
#sudo systemctl disable NetworkManager-wait-online.service  # Think this is just for Ubuntu derivatives.  sudo systemd-analyze critical-chain indicates they waste 5s on boot
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install -y brave-browser

#FLATPAK STUFF
#sudo flatpak install -y --noninteractive --system org.gtk.Gtk3theme.Breeze
#sudo flatpak override --filesystem=xdg-config/gtk-3.0:ro
sudo flatpak install -y flathub com.heroicgameslauncher.hgl

# INSTALLS, REMOVES & TWEAKS
sudo dnf install -y bottles lutris dosbox-staging fastfetch bleachbit python3-pip mc git ncdu gamemode hunspell-en-GB vlc powertop steam steam-devices curl retroarch
sudo dnf remove -y plasma-welcome ktorrent firefox neochat skanpage kmahjongg
sudo dnf upgrade -y && sudo dnf autoremove -y
sudo printf "fastfetch" >> /home/$USER/.bashrc
sudo timedatectl set-local-rtc 1 --adjust-system-clock

#wget https://github.com/methanoid/setup/blob/main/powertuning.sh
#sudo sh ./powertuning.sh

# CONF files?
# make konsole & BRAVE favouriteS
# screen locking,sleep settings

gamescope
prism launcher (for minecraft)
cuda-gcc:  required for sunshine
goverlay
mangohud
mesa
mesa-vulkan-drivers.x86_64
wine-tricks
wine-staging
proton-ge / proton up ??
flatpak: we've removed fedora's flatpak repos and instead enabled flathub official and flathub beta repos.
