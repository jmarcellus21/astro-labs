#!/bin/bash
# Wiki.js install
# uses SQLite3 DB

# install software dependencies
sudo apt update
sudo apt install -y software-properties-common apt-transport-https curl wget vim make gcc g++
curl -sL https://deb.nodesource.com/setup_current.x | sudo -E bash -
sudo apt-get install -y nodejs sqlite3

wget -P /tmp https://github.com/Requarks/wiki/releases/download/2.5.126/wiki-js.tar.gz
mkdir -p /opt/wiki/db
tar xzf /tmp/wiki-js.tar.gz -C /opt/wiki
cd /opt/wiki
cp config.sample.yml config.yml

# modify config file to use port 80, SQLite DB
sed -in 's/3000/80/' config.yml
sed -in 's/postgres/sqlite/' config.yml
sed -in '27,32 s/^/#/' config.yml
sed -in 's|path/to/database.sqlite|/opt/wiki/db/wiki.db|' config.yml

# fetch native bindings for SQLite3
npm rebuild sqlite3

# create database
echo ".database" | sqlite3 /opt/wiki/db/wiki.db

# create 'wiki' user w/ no login shell
sudo useradd --system --no-create-home --shell=/usr/sbin/nologin wiki

# make wiki user owner of wiki files
chown -R wiki:wiki /opt/wiki

# enable non-privileged users to use privileged ports
sudo setcap cap_net_bind_service=+ep `readlink -f \`which node\``

# create service
cat > /etc/systemd/system/wiki.service <<EOF
[Unit]
Description=Wiki.js
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/node server
Restart=always
# Consider creating a dedicated user for Wiki.js here:
User=wiki
Environment=NODE_ENV=production
WorkingDirectory=/opt/wiki

[Install]
WantedBy=multi-user.target
EOF

# start service
systemctl daemon-reload
systemctl enable wiki
systemctl start wiki
systemctl status wiki
