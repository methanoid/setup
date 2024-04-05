#!/bin/bash

# SETUP SCRIPT FOR KVM & FILE SERVER USAGE

# PREP DIRS FOR SERVER USAGE (VM & CACHE SSDs)
sudo mkdir /mnt/vm
sudo mkdir /mnt/cache
sudo chown -R $USER:$USER /mnt/vm
sudo chown -R $USER:$USER /mnt/cache

# add KVM scripts

# add MergerFS, RClone, SnapRAID etc

