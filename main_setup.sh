#!/bin/bash

# SETUP SCRIPT FOR DEBIAN/UBUNTU BASED DISTROS USING APT

# NALA & BASIC UPGRADES
sudo apt install -y localepurge nala curl
sudo nala fetch && sudo nala update && sudo nala upgrade -y

# IF UBUNTU, DE-SNAP & INSTALL FLATPAK
if [  -n "$(uname -a | grep buntu)" ]; then
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

# BRAVE
sudo apt install curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser

# GAMING
sudo add-apt-repository multiverse
sudo apt-get update -y
sudo apt install steam steam-devices
sudo add-apt-repository ppa:libretro/stable && sudo apt-get update && sudo apt-get install retroarch
wget https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/download/v2.14.1/heroic_2.14.1_amd64.deb
sudo dpkg -i heroic_*_amd64.deb
#delete?

# FLATPAK STUFF
sudo flatpak install -y --noninteractive --system org.gtk.Gtk3theme.Breeze
sudo flatpak override --filesystem=xdg-config/gtk-3.0:ro
sudo flatpak install flathub -y com.usebottles.bottles

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
sudo nala install -y neofetch bleachbit ufw python3-pip mc libavcodec-extra git ncdu gamemode hunspell-en-gb vlc powertop
sudo nala purge -y hunspell-en-us thunderbird transmission-cli transmission-qt pidgin pidgin-extprefs pidgin-gnome-keyring pidgin-otr pidgin-plugin-pack firefox-esr synaptic #  Spiral specifics
sudo nala purge -y ktorrent kmahjongg ksudoku # Kubuntu specifics
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
sudo apt-get install ttf-mscorefonts-installer

# DESKTOP SPECIFICS
case $XDG_SESSION_DESKTOP in
  KDE)
    echo -n "KDE Plasma specific customizations"
    sudo python3 -m pip install konsave --break-system-packages
    sudo nala install -y  plasma-discover-backend-flatpak plasma-discover
    ;;
  Gnome)
    echo -n "Gnome specific customizations"
    sudo nala install -y gnome-software-plugin-flatpak
    ;;
  X-Cinnamon)
    echo -n "Cinnamon specific customizations"
    ;;
  XFCE)
    echo -n "XFCE specific customizations"
    ;;
  Budgie)
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

# POWER TUNING
wget https://github.com/methanoid/setup/blob/main/powertuning.sh
sudo sh ./powertuning.sh

# CONF files?
# make konsole & BRAVE favouriteS
# screen locking,sleep settings
