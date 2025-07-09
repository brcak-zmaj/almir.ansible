#!/bin/bash

set -e

echo "Refreshing firmware metadata and updating firmware..."
sudo fwupdmgr refresh
sudo fwupdmgr get-updates
sudo fwupdmgr update

echo "Updating all packages..."
sudo dnf -y update
sudo dnf -y upgrade

echo "Removing old kernels..."
sudo dnf -y remove $(dnf repoquery --installonly --latest-limit=-3 -q)

echo "Cleaning package cache..."
sudo dnf clean all -y

echo "Update and cleanup complete."
