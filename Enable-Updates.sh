#!/bin/sh
apt install unattended-upgrades -y
echo "
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
" > /etc/apt/apt.conf.d/20auto-upgrades
