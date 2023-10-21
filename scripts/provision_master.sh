#!/bin/bash

# Update and upgrade packages
sudo apt-get update
sudo apt-get -y upgrade

# Install LAMP stack
sudo apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql

# Clone the PHP application from GitHub
git clone https://github.com/jidejj/AltSchool_LAMP_Deployment_Project.git /var/www/html

# Configure Apache
sudo a2enmod rewrite
sudo systemctl restart apache2

# Create the database and import data
# mysql -u root -p < /var/www/html/database.sql

