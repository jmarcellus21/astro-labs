#!/bin/bash

# get mac address of eth0 interface
ifconfig eth0 | grep -o "..:..:..:..:..:.."

