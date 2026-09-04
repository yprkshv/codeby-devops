#!/bin/bash
set -e

sleep 120
echo "--> remove needrestart..."
sudo apt -y remove needrestart
#sudo apt update -y
#sudo apt install -yq nginx
echo "--> Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# 2. Install Nginx web server
echo "--> Installing Nginx..."
sudo apt-get install nginx -y
sudo systemctl enable --now nginx
echo '<h1>Hello</h1>' | sudo tee /var/www/html/index.html",