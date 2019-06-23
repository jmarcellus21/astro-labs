# Config repos
echo 'deb http://www.ui.com/downloads/unifi/debian stable ubiquiti' | sudo tee /etc/apt/sources.list.d/100-ubnt-unifi.list

# Add GPG keys
sudo wget -O /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ui.com/unifi/unifi-repo.gpg 

# Retrieve latest package information
sudo apt update
sudo apt install apt-transport-https

# Install Unifi controller
sudo apt install unifi
