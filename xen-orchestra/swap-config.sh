#!/bin/bash

# Check if user is root

# Add swap file
sudo apt-get install dphys-swapfile -y

echo "**Retrieving swap config"
wget https://github.com/jmarcellus21/astro-labs/raw/master/xen-orchestra/raspi3b-swap-config.txt

echo "**Editing swap file configuration"
cat raspi3b-swap-config.txt > /etc/dphys-swapfile

echo "**Cleaning up"
rm raspi3b-swap-config.txt

echo "**Restarting swapfile service"
sudo /etc/init.d/dphys-swapfile stop
sudo /etc/init.d/dphys-swapfile start

# Display amount of memory
free -m
