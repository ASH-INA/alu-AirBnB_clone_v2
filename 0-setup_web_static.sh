#!/usr/bin/env bash
# Sets up a web server for deployment of web_static.

if ! dpkg -l | grep -q nginx; then
    sudo apt update
    sudo apt install -y nginx
fi

# Create necessary directories
sudo mkdir -p /data/web_static/releases/test
sudo mkdir -p /data/web_static/shared

# Create a fake HTML file
echo "<html>
  <head>
  </head>
  <body>
    Holberton School
  </body>
</html>" | sudo tee /data/web_static/releases/test/index.html > /dev/null

# Create a symbolic link
if [ -L /data/web_static/current ]; then
    sudo rm /data/web_static/current
fi
sudo ln -s /data/web_static/releases/test /data/web_static/current

# Give ownership to the ubuntu user and group
sudo chown -R ubuntu:ubuntu /data/

# Update Nginx configuration
if ! grep -q "hbnb_static" /etc/nginx/sites-available/default; then
    echo "    location /hbnb_static/ {" | sudo tee -a /etc/nginx/sites-available/default > /dev/null
    echo "        alias /data/web_static/current/;" | sudo tee -a /etc/nginx/sites-available/default > /dev/null
    echo "        index index.html;" | sudo tee -a /etc/nginx/sites-available/default > /dev/null
    echo "    }" | sudo tee -a /etc/nginx/sites-available/default > /dev/null
fi

# Restart Nginx
sudo service nginx restart

# Exit successfully
exit 0
