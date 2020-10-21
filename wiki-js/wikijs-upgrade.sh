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
echo "Latest Release: v$LATEST_VERSION"

# stop wiki service
sudo systemctl stop $SERVICE_NAME

#backup config.yml file
echo "## Backing up config.yml"
sudo cp $INSTALL_DIR/config.yml ~/config.yml.bak

# delete application folder
echo "## Removing existing application folder"
sudo rm -rf $INSTALL_DIR/*

# dowload latest version of wiki.js
echo "## Downloading latest release"
wget --quiet https://github.com/Requarks/wiki/releases/download/$LATEST_VERSION/wiki-js.tar.gz -O wiki-js.tar.gz

# extract the package to installation directory
echo "## Extracting package to installation directory"
sudo tar xzf wiki-js.tar.gz -C $INSTALL_DIR

# restore config.yml file
echo "## Restoring the config.yml file"
cp ~/config.yml.bak $INSTALL_DIR/config.yml

# give wikijs service account ownership of files
echo "## Give wikijs service account ownership of installation directory"
sudo chown -R wikijs:wikijs $INSTALL_DIR/*

# start wiki
systemctl start wiki

sudo rm wiki-js.tar.gz
