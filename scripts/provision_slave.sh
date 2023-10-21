#!/bin/bash

# Update and Upgrade packages
sudo apt-get update
sudo apt-get -y upgrade

# Install Apache, MySQL, PHP, and other necessary packages
sudo apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql

# Enable Apache and MySQL services
sudo systemctl enable apache2
sudo systemctl enable mysql

# Start Apache and MySQL services
sudo systemctl start apache2
sudo systemctl start mysql
