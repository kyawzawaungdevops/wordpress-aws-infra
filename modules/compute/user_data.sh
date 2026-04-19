#!/bin/bash
set -e

# System update
sudo apt update -y && sudo apt upgrade -y

# Add PHP repository (ondrej/php for all versions)
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update -y

# Install nginx and PHP 8.3
sudo apt install -y nginx mysql-client \
  php8.3-fpm php8.3-mysql php8.3-xml \
  php8.3-curl php8.3-gd php8.3-mbstring php8.3-zip php8.3-intl \
  php8.3-bcmath php8.3-soap unzip curl

# Create webroot if it doesn't exist
sudo mkdir -p /var/www/html

# Start and enable services
sudo systemctl start nginx php8.3-fpm
sudo systemctl enable nginx php8.3-fpm

# Download and extract WordPress
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz -C /var/www/html --strip-components=1
rm latest.tar.gz

# Set permissions
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# WordPress config
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo sed -i "s/database_name_here/${db_name}/" /var/www/html/wp-config.php
sudo sed -i "s/username_here/${db_username}/" /var/www/html/wp-config.php
sudo sed -i "s/password_here/${db_password}/" /var/www/html/wp-config.php
sudo sed -i "s/localhost/${db_host}/" /var/www/html/wp-config.php

# Nginx config for WordPress
sudo tee /etc/nginx/sites-available/wordpress > /dev/null <<'NGINX'
server {
    listen 80;
    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
NGINX

sudo ln -sf /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx