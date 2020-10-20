#!/bin/bash
# Wiki JS upgrade script

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

REPO="Requarks/wiki"
SERVICE_NAME="wiki"
INSTALL_DIR="/opt/wiki"

LATEST_VERSION=$(get_latest_release $REPO)
echo "HEllo v$LATEST_VERSION"

# stop wiki service
sudo systemctl stop $SERVICE_NAME

#backup config.yml file
sudo cp $INSTALL_DIR/config.yml ~/config.yml.bak

# delete application folder
sudo rm -rf $INSTALL_DIR/*

# dowload latest version of wiki.js
wget https://github.com/Requarks/wiki/releases/download/$LATEST_VERSION/wiki-js.tar.gz

# extract the package to installation directory
sudo tar xzf wiki-js.tar.gz -C $INSTALL_DIR

# restore config.yml file
cp ~/config.yml.bak $INSTALL_DIR/config.yml

# give wikijs service account ownership of files
sudo chown -R wikijs:wikijs $INSTALL_DIR/*

# start wiki
systemctl start wiki

sudo rm wiki-js.tar.gz
