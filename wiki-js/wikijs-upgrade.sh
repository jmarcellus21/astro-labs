#!/bin/bash
# Script to update WikiJS to latest version

# TO-DO
# Webhook to get latest version from GitHub

VERSION="2.5.144"
INSTALL_DIR="/opt"
WIKI_USER="wikijs"

cd $INSTALL_DIR

# stop wiki servicey
sudo systemctl stop wiki

#backup config.yml file
sudo cp wiki/config.yml ~/config.yml.bak

# delete application folder
sudo rm -rf wiki/*

# dowload latest version of wiki.js
wget -P /tmp https://github.com/Requarks/wiki/releases/download/$VERSION/wiki-js.tar.gz

# extract the package
sudo tar xzf /tmp/wiki-js.tar.gz -C ./wiki

# restore config.yml file
sudo cp ~/config.yml.bak ./wiki/config.yml

# give wikijs service ownership of files
sudo chown -R $WIKI_USER:$WIKI_USER wiki/*

# start wiki
sudo systemctl start wiki

# cleanup files
rm /tmp/wiki-js.tar.gz