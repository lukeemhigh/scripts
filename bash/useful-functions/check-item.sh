#!/usr/bin/env bash
#
# Author: Luca Giugliardi
# Email: luca.giugliardi@gmail.com

##########################################
# Check if an item is present on the page
# Arguments:
#   Page.
#   Item. eg: Laptop, VR, Watch
##########################################
check_item() {
	if [[ $1 = *$2* ]]; then
		print_color "green" "Item $2 present on the web page"
	else
		print_color "red" "Item $2 not present on the web page"
	fi
}
