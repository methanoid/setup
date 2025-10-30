#!/bin/bash
# SETUP SCRIPT FOR DEBIAN/UBUNTU BASED DISTROS USING APT
# NALA
sudo apt install -y nala curl && sudo nala fetch && sudo nala update && sudo nala upgrade -y

# DE-SNAP UBUNTU-DERVIATIVES
if [  -n "$(uname -a | grep buntu)" ]; then
  sudo snap remove firefox && sudo snap remove gtk-common-themes && sudo snap remove gnome-42-2204 && sudo snap remove thunderbird && sudo snap remove firmware-updater && sudo snap remove bare && sudo snap remove core22
  sudo snap remove snapd && sudo systemctl stop snapd && sudo systemctl disable snapd && sudo apt purge snapd -y && sudo apt-mark hold snapd
  sudo rm -rf ~/snap && sudo rm -rf /snap && sudo rm -rf /var/snap && sudo rm -rf /var/lib/snapd
  sudo cat <<EOF | sudo tee /etc/apt/preferences.d/nosnap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
fi

# BRAVE
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo nala update && sudo nala install -y brave-browser

# FLATPAK INSTALLS
sudo nala install -y flatpak && sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y --noninteractive --system org.gtk.Gtk3theme.Breeze && sudo flatpak override --filesystem=xdg-config/gtk-3.0:ro
sudo flatpak install flathub -y com.usebottles.bottles    # Only available as Flatpak
sudo flatpak override com.usebottles.bottles --user --filesystem=xdg-data/applications  # Allows access elsewhere
sudo flatpak install flathub net.lutris.Lutris            # Without Flatpak it requires Wine installed and we use Bottles
sudo flatpak install flathub io.github.dosbox-staging     # PPA isnt updated
sudo flatpak install flathub org.libretro.RetroArch       # No particular reason
sudo flatpak install flathub com.valvesoftware.Steam      # Means dont need to add 32bit multiverse

# GPU SPECIFICS
gpu=$(lspci | grep -i '.* vga .* nvidia .*') && shopt -s nocasematch
if [[ $gpu == *' nvidia '* ]]; then
  printf 'Installing Nvidia GPU bits:  %s\n'
  sudo ubuntu-drivers install && flatpak --user install flathub com.leinardi.gwe && sudo flatpak update  # need to ensure latest org.freedesktop.Platform.GL.nvidia
else
  printf 'AMD - all golden%s\n'
fi

# INSTALLS & TWEAKS
sudo nala update
wget https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/download/v2.14.1/heroic_2.14.1_amd64.deb && sudo dpkg -i heroic_*_amd64.deb && rm ~/Downloads/heroic_*_amd64.deb
sudo nala install -y fastfetch bleachbit ufw python3-pip mc libavcodec-extra git ncdu gamemode hunspell-en-gb vlc powertop steam-devices localepurge
sudo nala purge -y hunspell-en-us thunderbird transmission-cli transmission-qt pidgin pidgin-extprefs pidgin-gnome-keyring pidgin-otr pidgin-plugin-pack firefox-esr synaptic #  Spiral specifics
sudo nala purge -y ktorrent kmahjongg ksudoku # Kubuntu specifics
sudo systemctl disable NetworkManager-wait-online.service  # Just for Ubuntu derivatives? sudo systemd-analyze critical-chain indicates they waste 5s on boot
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections && sudo apt install -y ttf-mscorefonts-installer

# TIDY UP & UPGRADES
sudo nala upgrade -y && sudo nala clean && sudo nala autoremove -y && sudo nala autopurge -y

sudo printf "fastfetch" >> /home/$USER/.bashrc && sudo timedatectl set-local-rtc 1 --adjust-system-clock

echo -n "KDE Plasma specific customizations"
    sudo python3 -m pip install konsave --break-system-packages
    sudo nala install -y  plasma-discover-backend-flatpak plasma-discover

exit

# POWER TUNING
wget https://github.com/methanoid/setup/blob/main/powertuning.sh
sudo sh ./powertuning.sh

# CONF files?
# make konsole & BRAVE favouriteS
# screen locking,sleep settings
# .local/share/user-places.xbel   # copy this to add unRAID to Dolphin places

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
