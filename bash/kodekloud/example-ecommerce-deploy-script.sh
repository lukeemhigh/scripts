#!/usr/bin/env bash
#
# Automates the deployment of Kodekloud ecommerce application
# Author: Luca Giugliardi

# ----------------------------- Shell Options ----------------------------
set -o pipefail

# -------------------------------- Functions -----------------------------------

#####################################
# Prints a message in a given color
# Arguments:
#   Color. eg: green, red
#####################################
function print_color(){
    NC='\033[0m' # No Color
    case $1 in
        "green") COLOR="‘\033[0;32m" ;;
        "red") COLOR="‘\033[0;31m" ;;
        *) COLOR="‘\033[0m" ;;
    esac
    echo -e "${COLOR} $2 ${NC}"
}

#####################################
# Check the status of a given service
# Error and exit if not active
# Arguments:
#   Service. eg: httpd, firewalld
#####################################
function check_service_status(){
    is_service_active=$(sudo systemctl is-active "$1")
    if [ "$is_service_active" = "active" ]; then
        print_color "green" "$1 service is active"
    else
        print_color "red" "$1 service is not running"
        exit 1
    fi
}

##########################################
# Check if a given firewalld port is open
# Error and exit if port is closed
# Arguments:
#   Port. eg: 3306, 80
##########################################
function check_ports(){
    firewalld_ports=$(sudo firewall-cmd --list-all --zone=public | grep ports)
    if [[ $firewalld_ports = *"$1"* ]]; then
        print_color "green" "Port $1 configured"
    else
        print_color "red" "Port $1 not configured"
        exit 1
    fi
}

##########################################
# Check if an item is present on the page
# Arguments:
#   Page.
#   Item. eg: Laptop, VR, Watch
##########################################
function check_item(){
    if [[ $1 = *$2* ]]; then
        print_color "green" "Item $2 present on the web page"
    else
        print_color "red" "Item $2 not present on the web page"
    fi
}

# --------------------- Database Configuration ---------------------

# Install and configure FirewallD
print_color "green" "Installing FirewallD..."
sudo yum install -y firewalld
sudo systemctl start firewalld.service
sudo systemctl enable firewalld

check_service_status firewalld


# Install and configure MariaDB
print_color "green" "Installing MariaDB..."
sudo yum install -y mariadb-server
sudo systemctl start mariadb.service
sudo systemctl enable mariadb

check_service_status mariadb

# Add firewall rules for database
print_color "green" "Adding firewall rules for database..."
sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload

check_ports 3306

# Configure Database
print_color "green" "Configuring database..."
cat > configure-db.sql <<-EOF
CREATE DATABASE ecomdb;
CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
FLUSH PRIVILEGES;
EOF

sudo mysql < configure-db.sql

# Load inventory data into Database
print_color "green" "Loading inventory data into database..."
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;
INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");
EOF

sudo mysql < db-load-script.sql

mysql_db_results=$(sudo mysql -e "use ecomdb; select * from products;")

if [[ $mysql_db_results = *Laptop* ]]; then
    print_color "green" "Inventory data loaded"
else
    print_color "red" "Inventory data not loaded"
    exit 1
fi


# -------------------- Web Server Configuration --------------------

# Install Apache Web Server and php
print_color "green" "Installing Apache Web Server and php..."
sudo yum install -y httpd php php-mysql

# Configure firewall rules for Web Server
print_color "green" "Configuring firewall rules for Web Server..."
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

check_ports 80

# Confifure httpd
print_color "green" "Configuring httpd..."
sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf

# Start and enable httpd service
print_color "green" "Starting web server..."
sudo systemctl start httpd.service
sudo systemctl enable httpd

check_service_status httpd

# Install GIT
print_color "green" "Installing GIT..."
sudo yum install -y git

# Download source code repository
print_color "green" "Downloading source code repository..."
sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/

# Replace database IP with localhost
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php

print_color "green" "All set."

web_page=$(curl http://localhost)

for item in Laptop Drone VR Watch
do
    check_item "$web_page" "$item"
done
