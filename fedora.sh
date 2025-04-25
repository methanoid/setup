#!/bin/bash
# SETUP SCRIPT FOR FEDORA BASED DISTROS USING DNF

hostnamectl set-hostname FED-PCNAME
echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf
# Enable RPMfusion repos
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# Disable the Modular Repos, added load at update.
sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-updates-modular.repo
sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-modular.repo
# Testing Repos should be disabled anyways
sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-updates-testing-modular.repo
sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/rpmfusion-free-updates-testing.repo
# Rpmfusion makes this obsolete
sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-cisco-openh264.repo
# Disable Machine Counting for all repos
sudo sed -i 's/countme=1/countme=0/g' /etc/yum.repos.d/*
sudo dnf up -y            # and reboot if you are not on the latest kernel

nvgpu=$(lspci | grep -i nvidia | grep -i vga | cut -d ":" -f 3)
if [[ $nvgpu ]]; then
  sudo -S dnf install -y akmod-nvidia # xorg-x11-drv-nvidia-cuda gwe
fi
#else    #  printf "RADV_PERFTEST=aco" >> /etc/environment   #fi

#GENERAL INSTALLS
sudo dnf install -y dnf-plugins-core && sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo && sudo dnf install -y brave-browser
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo && sudo flatpak remote-modify --no-filter --enable flathub && sudo flatpak remote-delete fedora
sudo flatpak install -y --noninteractive --system org.gtk.Gtk3theme.Breeze
sudo flatpak override --filesystem=xdg-config/gtk-3.0:ro 
sudo dnf install -y fastfetch bleachbit python3-pip mc git ncdu hunspell-en-GB powertop curl libavcodec-freeworld
sudo printf "fastfetch" >> /home/$USER/.bashrc

#GAMING STUFF
sudo dnf install -y gamemode bottles lutris dosbox-staging steam steam-devices goverlay mangohud winetricks
sudo flatpak install -y flathub com.heroicgameslauncher.hgl
sudo flatpak install -y flathub org.prismlauncher.PrismLauncher
sudo flatpak install -y flathub dev.lizardbyte.app.Sunshine
sudo flatpak install -y flathub com.moonlight_stream.Moonlight
sudo flatpak install -y flathub net.retrodeck.retrodeck

sudo dnf up -y && sudo dnf autoremove -y && sudo dnf clean all && sudo dnf distro-sync -y

## sudo dnf remove -y plasma-welcome ktorrent firefox neochat skanpage kmahjongg
## sudo timedatectl set-local-rtc 1 --adjust-system-clock    # For MultiBoot systems
## wget https://github.com/methanoid/setup/blob/main/powertuning.sh && sudo sh ./powertuning.sh
## CONF files, # make konsole & BRAVE favouriteS, # screen locking,sleep settings, # proton-ge / proton up ??
