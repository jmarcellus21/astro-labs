#!/bin/bash

sudo apt-get update -y && sudo apt-get upgrade -y

# check if line is there, insert if needed
sudo sed -i '$ s/$/ cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory/' /boot/firmware/cmdline.txt

sudo reboot now
sudo apt-get install docker.io
curl -sfL https://get.k3s.io | sh -

# verify install finished properly
sudo k3s kubectl get nodes
