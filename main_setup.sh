#!/bin/bash

# SETUP SCRIPT FOR DEBIAN/UBUNTU BASED DISTROS USING APT

# NALA & BASIC UPGRADES
sudo apt install -y localepurge nala curl
sudo nala fetch && sudo nala update && sudo nala upgrade -y

# IF UBUNTU, DE-SNAP & INSTALL FLATPAK
distro=$(lsb_release -d | awk -F"\t" '{print $2}' | grep -c "buntu")
if [[ $distro == '1' ]]; then
  sudo nala install -y flatpak
  sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  sudo snap remove firefox
  sudo snap remove gtk-common-themes
  sudo snap remove gnome-42-2204
  sudo snap remove snapd-desktop-integration
  sudo snap remove snap-store
  sudo snap remove firmware-updater
  sudo snap remove bare
  sudo snap remove core22
  sudo snap remove snapd
  sudo systemctl stop snapd
  sudo systemctl disable snapd
  sudo apt purge snapd -y
  sudo apt-mark hold snapd
  sudo rm -rf ~/snap
  sudo rm -rf /snap
  sudo rm -rf /var/snap
  sudo rm -rf /var/lib/snapd
  sudo printf "Package: snapd\n" >> /etc/apt/preferences.d/nosnap.pref
  sudo printf "Pin: release a=*" >> /etc/apt/preferences.d/nosnap.pref
  sudo printf "Pin-Priority: -10" >> /etc/apt/preferences.d/nosnap.pref
  sudo systemctl disable NetworkManager-wait-online.service  # Think this is just for Ubuntu derivatives.  sudo systemd-analyze critical-chain indicates they waste 5s on boot
  sudo apt update
fi

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
sudo nala purge -y hunspell-en-us thunderbird transmission-cli transmission-qt pidgin pidgin-extprefs pidgin-gnome-keyring pidgin-otr pidgin-plugin-pack firefox-esr synaptic #  Spiral specifics
sudo nala purge -y ktorrent kmahjongg ksudoku # Kubuntu specifics
sudo nala install -y ttf-mscorefonts-installer
# sudo nala install -y preload

# DESKTOP SPECIFICS
case $XDG_SESSION_DESKTOP in
  KDE)
    echo -n "KDE Plasma specific customizations"
    sudo python3 -m pip install konsave --break-system-packages
    sudo nala install -y  plasma-discover-backend-flatpak plasma-discover
    ;;
  Gnome)
  #ubuntu:GNOME
    echo -n "Gnome specific customizations"
    sudo nala install -y gnome-software-plugin-flatpak
    ;;
  X-Cinnamon)
    echo -n "Cinnamon specific customizations"
    ;;
  XFCE)
    echo -n "XFCE specific customizations"
    ;;
  ??Budgie)
    echo -n "Budgie specific customizations"
    ;;
  *)
    echo -n "Desktop Unknown!!!"
    ;;
esac

# TIDY UP & UPGRADES
sudo nala upgrade -y && sudo nala clean && sudo nala autoremove -y && sudo nala autopurge -y
sudo printf "neofetch" >> /home/$USER/.bashrc
sudo timedatectl set-local-rtc 1 --adjust-system-clock

# ALTER SPIRAL LOOK
distro=$(lsb_release -d | awk -F"\t" '{print $2}' | grep -c "Spiral")
if [[ $distro == '1' ]]; then
#sudo sed 's/SpiralLinux //' /etc/default/grub
#sudo sed 's/SpiralLinux snap/Snap/' /etc/default/grub-btrfs/config
#sudo rm /boot/grub/splash.png
#sudo rm /usr/share/wallpapers/Zwopper-Green-Dew-CC-BY-SA-30-2560x1600.png
#sudo rm /home/$USER/Desktop/language-support.desktop
fi

# ADD ISOs to GRUB MENU
mkdir /home/$USER/ISOs    # Put ISOs in here
wget https://github.com/methanoid/setup/blob/main/append_40_custom
cat ./append_40_custom >> /etc/grub.d/40_custom
sudo update-grub

# POWER TUNING
wget https://github.com/methanoid/setup/blob/main/powertuning.sh
sudo sh ./powertuning.sh

# CONF files?
# make konsole & BRAVE favouriteS
# screen locking,sleep settings
