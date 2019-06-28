# Install MongoDB 3.4
# Import the public key
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6

# Create a list file for MongoDB
echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list

# Reload package database
sudo apt-get update

# Install Unifi controller
cd /tmp/
wget https://dl.ubnt.com/unifi/5.10.25/unifi_sysvinit_all.deb
sudo dpkg -i unifi_sysvinit_all.deb
sudo apt-get install -f
