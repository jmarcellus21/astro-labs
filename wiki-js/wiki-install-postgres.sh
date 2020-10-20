#!/bin/bash
# install WikiJS w/ PostgreSQL

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

REPO="Requarks/wiki"
SERVICE_NAME="wiki"
INSTALL_DIR="/opt/wiki"

LATEST_VERSION=$(get_latest_release $REPO)

# install software dependencies
sudo apt update
sudo apt install -y gnupg2 software-properties-common apt-transport-https curl wget vim

# install PostgreSQL repo key
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# setup NodeJS 14 repo
curl -sL https://deb.nodesource.com/setup_current.x | sudo -E bash -

# install PostgreSQL and NodeJS
sudo apt update
sudo apt install -y postgresql nodejs

# download and install WikiJS
wget -O https://github.com/Requarks/wiki/releases/download/$LATEST_VERSION/wiki-js.tar.gz
mkdir $INSTALL_DIR
sudo tar xzf wiki-js.tar.gz -C $INSTALL_DIR
cp $INSTALL_DIR/config.sample.yml $INSTALL_DIR/config.yml

# modify config file to use port 80
sed -in 's/3000/80/' config.yml
sed -in '47 s/^/#/' config.yml

# start postgreSQL
pg_ctlcluster 12 main start

# add wikijs user
sudo useradd --system --shell /bin/bash wikijs

# create DB
sudo -u postgres psql -c "CREATE DATABASE wiki;"

# create user 'wikijs'
sudo -u postgres psql -c "create user wikijs with password 'wikijsrocks';"

# grant all privileges to 'wikijs' user
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE wiki TO wikijs;"

# make wiki user owner of wiki files
sudo chown -R wikijs:wikijs $INSTALL_DIR

# enable non-privileged users to use privileged ports
sudo setcap cap_net_bind_service=+ep `readlink -f \`which node\``

# create service
sudo cat > /etc/systemd/system/wiki.service <<EOF
[Unit]
Description=Wiki.js
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/node server
Restart=always
# Consider creating a dedicated user for Wiki.js here:
User=wikijs
Environment=NODE_ENV=production
WorkingDirectory=$INSTALL_DIR

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable wiki
sudo systemctl start wiki
sudo systemctl status wiki

rm wiki-js.tar.gz
