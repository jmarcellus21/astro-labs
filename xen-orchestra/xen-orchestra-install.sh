#!/bin/bash

# If using Ubuntu server 18.x, disable apt-daily.timer and apt-daily-upgrade.timer

# Update all packages
echo "updating and upgrading all packages"
sudo apt-get update -y && sudo apt-get upgrade -y

# Download NodeJS (v8.x) prerequisites
echo "setting repo for NodeJS v8.x"
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

# Configure Yarn Repository
echo "configuring Yarn repos"
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Remove cmdtest package
#echo "removing cmdtest package"
#sudo apt remove cmdtest

# Update repos
sudo apt-get update -y

# Download necessary packages
echo "downloading build dependencies"
sudo apt-get install -y yarn nodejs build-essential redis-server libpng-dev git python-minimal libvhdi-utils lvm2 cifs-utils

# Clean up packages
echo "cleaning up"
sudo apt clean

# Fetch XOA source code
echo "fetching Xen Orchestra source code"
git clone -b master http://github.com/vatesfr/xen-orchestra

# Install XOA dependencies
cd xen-orchestra
yarn
yarn build

# Create config file for xo-server
cd packages/xo-server
cp sample.config.toml .xo-server.toml

# Install XO as system service
# Download forever-service packages
yarn global add forever
yarn global add forever-service
cd /home/ubuntu/xen-orchestra/packages/xo-server/bin/
forever-service install -s xo-server orchestra
service orchestra start
service orchestra status
