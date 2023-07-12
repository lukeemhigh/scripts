#!/bin/bash
#
# Author: Luca Giugliardi
# Email: luca.giugliardi@gmail.com

##########################################
# Check if a given firewalld port is open
# Error and exit if port is closed
# Arguments:
#   Port. eg: 3306, 80
##########################################
function check_ports(){
    firewalld_ports=$(sudo firewall-cmd --list-all --zone=public | grep ports)
    if [[ "$firewalld_ports" = *"$1"* ]]; then
        print_color "green" "Port $1 configured"
    else
        print_color "red" "Port $1 not configured"
        exit 1
    fi
}
