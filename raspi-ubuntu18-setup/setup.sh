#!/bin/bash

# Disable auto-updating service
sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer

# Set time-zone
sudo timedatectl set-timezone America/New_York

# Update all packages
sudo apt-get update -y && sudo apt-get upgrade -y

# Install Git Subversion
sudo apt-get install subversion

# get mac address of eth0 interface
ifconfig eth0 | grep -o "..:..:..:..:..:.."
