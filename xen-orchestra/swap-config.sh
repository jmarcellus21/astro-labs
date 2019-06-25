#!/bin/bash

echo "**Retrieving swap config"
wget https://github.com/jmarcellus21/astro-labs/raw/master/xen-orchestra/raspi3b-swap-config.txt

echo "**Editing swap file configuration"
cat raspi3b-swap-config.txt > /etc/dphys-swapfile

echo "**Cleaning up"
rm raspi3b-swap-config.txt
