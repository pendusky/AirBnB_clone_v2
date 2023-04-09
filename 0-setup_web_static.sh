#!/usr/bin/env bash

# Install nginx if not already installed
if ! command -v nginx &> /dev/null
then
    sudo apt-get update
    sudo apt-get -y install nginx
fi

# Create necessary directories if they don't exist
sudo mkdir -p /data/web_static/{releases,test,shared}

# Create a fake HTML file for testing
sudo echo -e "<html>\n\t<head>\n\t</head>\n\t<body>\n\t\tHolberton School\n\t</body>\n</html>" | sudo tee /data/web_static/releases/test/index.html

# Create a symbolic link
sudo ln -sf /data/web_static/releases/test /data/web_static/current

# Change ownership of the /data directory recursively
sudo chown -R ubuntu:ubuntu /data/

# Update nginx config
sudo sed -i 's|root /var/www/html;|root /data/web_static/current/;|' /etc/nginx/sites-available/default
sudo sed -i '/listen 80 default_server;/a \\\tlocation /hbnb_static {\n\t\talias /data/web_static/current/;\n\t}\n' /etc/nginx/sites-available/default

# Restart nginx
sudo service nginx restart

exit 0

