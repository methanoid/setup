#!/bin/bash

# SETUP SCRIPT FOR KVM & FILE SERVER USAGE
# https://www.linuxserver.io/blog/2017-06-24-the-perfect-media-server-2017

# PREP DIRS FOR SERVER USAGE (VM & CACHE SSDs)
sudo mkdir /mnt/vm
sudo mkdir /mnt/cache
sudo mkdir /mnt/disk{1,2,3,4,5,6,7,8}
sudo mkdir /mnt/parity{1,2}
sudo mkdir /mnt/cache
sudo mkdir /mnt/storage
sudo mkdir /mnt/gdrive
sudo chown -R $USER:$USER /mnt/vm
sudo chown -R $USER:$USER /mnt/cache
sudo chown -R $USER:$USER /mnt/storage

# KVM STUFF (incomplete)
# dont forget edits to GRUB
sudo nala install -y qemu-kvm libvirt-clients libvirt-daemon libvirt-daemon-system bridge-utils virtinst virt-manager
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
adduser $user libvirt
adduser $user libvirt-qemu

# PLEX (not Docker as Nvidia card wanted for Linux desktop/gaming also)
wget https://downloads.plex.tv/plex-media-server-new/1.40.1.8227-c0dd5a73e/debian/plexmediaserver_1.40.1.8227-c0dd5a73e_amd64.deb
sudo dpkg -i plexmediaserver_1.40.1.8227-c0dd5a73e_amd64.deb
sudo sed 's/#deb https://downloads.plex.tv/repo/deb/ public main/deb https://downloads.plex.tv/repo/deb/ public main/' /etc/apt/sources.list.d/plexmediaserver.list

# DOCKER STUFF
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker $USER
sudo apt install docker-compose
# need Yaml file for all these!
# lidarr,sonarr,radarr,mylar3,bazarr,heimdall,minecraft,unmanic,pihole,homarr,handbrake,plex,jellyfin,autoscan,ombi,ubooquity,prowlarr,qbitorrent-vpn,ngpost,sabnzbd,readarr,calibre,calibre-web

# SNAPRAID & MERGERFS
sudo nala install -y mergerfs snapraid fuse rclone samba
# wget SNAPRAID.conf
# mount disks, config mergerFS in /etc/fstab
# samba share /mnt/storage
# config rclone to use /mnt/gdrive (for config backups, NZBs)
# 
.CONF files
