#!/bin/bash

# SETUP SCRIPT FOR FEDORA BASED DISTROS USING DNF
echo "Tweaks to DNF"
echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf

echo "Installing RPM Fusion..."
sudo dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
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
sudo dnf install dnf-plugins-core
sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo dnf install brave-browser

#GENERAL INSTALLS
sudo flatpak remote-modify --no-filter --enable flathub
sudo flatpak remote-delete fedora
sudo flatpak install -y --noninteractive --system org.gtk.Gtk3theme.Breeze
sudo flatpak override --filesystem=xdg-config/gtk-3.0:ro
sudo dnf install -y fastfetch bleachbit python3-pip mc git ncdu hunspell-en-GB powertop curl
sudo printf "fastfetch" >> /home/$USER/.bashrc

#GAMING STUFF
sudo dnf install -y gamemode bottles lutris dosbox-staging steam steam-devices goverlay mangohud 
sudo dnf install -y goverlay mangohud 
sudo flatpak install -y flathub com.heroicgameslauncher.hgl
sudo flatpak install flathub org.prismlauncher.PrismLauncher

sudo dnf upgrade -y && sudo dnf autoremove -y

## retroarch BROKEN??
## sudo dnf remove -y plasma-welcome ktorrent firefox neochat skanpage kmahjongg
## sudo timedatectl set-local-rtc 1 --adjust-system-clock
#wget https://github.com/methanoid/setup/blob/main/powertuning.sh
#sudo sh ./powertuning.sh
# CONF files?
# make konsole & BRAVE favouriteS
# screen locking,sleep settings
protontricks.noarch: Simple wrapper that does winetricks things for Proton enabled games
protonvpn-cli.noarch: Linux command-line client for ProtonVPN written in Python
python-qpid-proton-docs.noarch: Documentation for the Python language bindings for Qpid Proton
python3-proton-core.noarch: proton-core library
python3-proton-vpn-api-core.noarch: Expose a uniform API to available Proton VPN services
wine-tricks wine-staging sunshine moonlight
proton-ge / proton up ??
