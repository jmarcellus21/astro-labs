#!/bin/bash

# Make sure current user is root
[ $uid -ne 0 ] && { echo "Only root may this install script"; exit 1; }

# Ensure script is run in Ubuntu home directory
cd /home/ubuntu

# Download respective install scripts
echo "##[Downloading install scripts]##
wget https://github.com/jmarcellus21/astro-labs/raw/master/xen-orchestra/swap-config.sh
wget https://github.com/jmarcellus21/astro-labs/raw/master/xen-orchestra/ubuntu18.04-arm64-raspi-setup.sh
wget https://github.com/jmarcellus21/astro-labs/raw/master/xen-orchestra/xen-orchestra-install.sh
wget https://github.com/jmarcellus21/astro-labs/raw/master/unifi/unifi-controller-arm64-install.sh

# Make all scripts executable
chmod +x *

echo "##[Running configuration script]##"
./ubuntu18.04-arm64-raspi-setup.sh | tee -a install-log.txt

echo "##[Editing swap configuration]##"
./swap-config.sh | tee -a install-log.txt

echo "##[Running Unifi Controller install]##"
./unifi-controller-arm64-install.sh | tee -a install-log.txt

# go back to Ubuntu home directory
cd /home/ubuntu

echo "##[Installing xen-orchestra]##"
./xen-orchestra-install.sh | tee -a install-log.txt

echo "##[Installation of xen-orchestra and Unifi controller complete]##"
