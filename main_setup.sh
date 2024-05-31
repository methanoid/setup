#!/bin/bash
# SETUP SCRIPT FOR DEBIAN/UBUNTU BASED DISTROS USING APT

# NALA
sudo apt install -y nala curl && sudo nala fetch && sudo nala update -y && sudo nala upgrade -y

# DE-SNAP UBUNTU-DERVIATIVES & INSTALL FLATPAK
if [  -n "$(uname -a | grep buntu)" ]; then
  sudo snap remove firefox gtk-common-themes gnome* snapd-desktop-integration snap-store firmware-updater bare core22
  sudo snap remove snapd && sudo systemctl stop snapd && sudo systemctl disable snapd && sudo apt purge snapd -y && sudo apt-mark hold snapd
  sudo rm -rf ~/snap && sudo rm -rf /snap && sudo rm -rf /var/snap && sudo rm -rf /var/lib/snapd
  sudo printf "Package: snapd\n" >> /etc/apt/preferences.d/nosnap.pref
  sudo printf "Pin: release a=*" >> /etc/apt/preferences.d/nosnap.pref
  sudo printf "Pin-Priority: -10" >> /etc/apt/preferences.d/nosnap.pref
  sudo nala update -y
  sudo nala install -y flatpak && sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

# BRAVE
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo nala update -y && sudo nala install -y brave-browser

# FLATPAK STUFF
sudo flatpak install -y --noninteractive --system org.gtk.Gtk3theme.Breeze && sudo flatpak override --filesystem=xdg-config/gtk-3.0:ro
sudo flatpak install flathub -y com.usebottles.bottles    # Only available as Flatpak

# GPU SPECIFICS
gpu=$(lspci | grep -i '.* vga .* nvidia .*') && shopt -s nocasematch
if [[ $gpu == *' nvidia '* ]]; then
  printf 'Installing Nvidia GPU bits:  %s\n'
  sudo nala install nvidia-driver && sudo flatpak --user install flathub com.leinardi.gwe && sudo flatpak update  # need to ensure latest org.freedesktop.Platform.GL.nvidia
else
  printf 'Installing AMD GPU bits:  %s\n'
  printf "RADV_PERFTEST=aco" >> /etc/environment
fi

# INSTALLS & TWEAKS
sudo add-apt-repository multiverse # for Steam
sudo add-apt-repository ppa:libretro/stable # for Retroarch
sudo add-apt-repository ppa:feignint/dosbox-staging # for Dosbox Staging
sudo nala update -y && sudo nala install -y steam steam-devices retroarch dosbox-staging
wget https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/download/v2.14.1/heroic_2.14.1_amd64.deb
wget https://github.com/lutris/lutris/releases/download/v0.5.17/lutris_0.5.17_all.deb
sudo dpkg -i heroic_*_amd64.deb
sudo dpkg -i lutris*.deb
#delete?
sudo nala install -y neofetch bleachbit ufw python3-pip mc libavcodec-extra git ncdu gamemode hunspell-en-gb vlc powertop localepurge
sudo nala purge -y hunspell-en-us thunderbird transmission-cli transmission-qt pidgin pidgin-extprefs pidgin-gnome-keyring pidgin-otr pidgin-plugin-pack firefox-esr synaptic #  Spiral specifics
sudo nala purge -y ktorrent kmahjongg ksudoku # Kubuntu specifics
sudo systemctl disable NetworkManager-wait-online.service  # Just for Ubuntu derivatives? sudo systemd-analyze critical-chain indicates they waste 5s on boot
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections && sudo apt-get install ttf-mscorefonts-installer

# TIDY UP & UPGRADES
sudo nala upgrade -y && sudo nala clean && sudo nala autoremove -y && sudo nala autopurge -y
sudo printf "neofetch" >> /home/$USER/.bashrc
sudo timedatectl set-local-rtc 1 --adjust-system-clock

# localpurge RUN?

exit


# POWER TUNING
wget https://github.com/methanoid/setup/blob/main/powertuning.sh
sudo sh ./powertuning.sh

# CONF files?
# make konsole & BRAVE favouriteS
# screen locking,sleep settings

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
