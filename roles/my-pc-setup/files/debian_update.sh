#!/bin/bash

set -e

echo "Refreshing firmware metadata and updating firmware..."
sudo fwupdmgr refresh
sudo fwupdmgr get-updates
sudo fwupdmgr update

echo "Updating all packages..."
sudo apt-get update -y
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade

echo "Removing old kernels..."
sudo apt-get -y autoremove --purge

echo "Cleaning package cache..."
sudo apt-get clean -y 
sudo apt-get autoclean -y

echo "Update and cleanup complete."
