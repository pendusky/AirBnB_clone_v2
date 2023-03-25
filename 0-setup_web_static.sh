#!/usr/bin/env bash
# script that creates a folder if one doesn't already exist

sudo apt-get -y update
sudo apt-get -y install nginx
sudo mkdir -p /data/web_static/shared/
sudo mkdir -p /data/web_static/releases/test
sudo echo "Best School" | sudo tee /data/web_static/releases/test/index.html
sudo ln -sf /data/web_static/releases/test/ /data/web_static/current
sudo chown -hR ubuntu:ubuntu /data/
sudo sed -i "37i\\tlocation /hbnb_static {\n\t\talias /data/web_static/current/\n\t}" /etc/nginx/sites-available/default
sudo service nginx restart
