#!/bin/bash

sudo apt-get update -y && sudo apt-get upgrade -y

# check if line is there, insert if needed
sudo sed -i '$ s/$/ cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory/' /boot/firmware/cmdline.txt

# reboot after editing boot parameters
sudo reboot now

# install docker and k3s
sudo apt-get install -y docker.io
curl -sfL https://get.k3s.io | sh -

# verify install finished properly
sudo k3s kubectl get nodes

# add alias for kubectl command
alias kubectl='k3s kubectl'
