#!/usr/bin/env bash
# Sets up a web server for deployment of web_static.

if ! dpkg -l | grep -q nginx; then
    apt-get update
    apt-get install -y nginx
fi

# Create necessary directories
mkdir -p /data/web_static/releases/test
mkdir -p /data/web_static/shared

# Create a fake HTML file
echo "<html>
  <head>
  </head>
  <body>
    Holberton School
  </body>
</html>" | tee /data/web_static/releases/test/index.html > /dev/null

# Create a symbolic link
if [ -L /data/web_static/current ]; then
    rm /data/web_static/current
fi
sudo ln -s /data/web_static/releases/test /data/web_static/current

# Give ownership to the ubuntu user and group
chown -R ubuntu /data/
chgrp -R ubuntu /data/

# Update Nginx configuration
mv /etc/nginx/nginx.conf /etc/nginx/default_nginx.conf
touch /etc/nginx/nginx.conf 

printf %s "events {
    worker_connections 768;
    # multi_accept on;
}
http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        root   /var/www/html;
    	index  index.html index.htm;
    	
    	location /hbnb_static {
            alias /data/web_static/current;
            index index.html index.htm;
        }

    	location /redirect_me {
            return 301 http://cuberule.com/;
    	}
    }
}" > /etc/nginx/nginx.conf

# Restart Nginx
service apache2 stop
service nginx restart

# Exit successfully
exit 0
