#!/usr/bin/env bash
#
# Author: Luca Giugliardi
# Email: <luca.giugliardi@gmail.com>

#####################################
# Check the status of a given service
# Error and exit if not active
# Arguments:
#   Service. eg: httpd, firewalld
#####################################
check_service_status() {
  is_service_active=$(sudo systemctl is-active "$1")
  if [ "$is_service_active" = "active" ]; then
    print_color "green" "$1 service is active"
  else
    print_color "red" "$1 service is not running"
    exit 1
  fi
}
