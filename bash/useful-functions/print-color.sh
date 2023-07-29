#!/usr/bin/env bash
# Author: Luca Giugliardi
# Email: luca.giugliardi@gmail.com
#
#####################################
# Prints a message in a given color
# Arguments:
#   Color. eg: green, red, blue
#####################################
print_color(){
    NC='\033[0m' # No Color
    case $1 in
        "green") COLOR="\033[0;32m" ;;
        "red") COLOR="\033[0;31m" ;;
        "blue") COLOR="\033[1;34m" ;;
        "purple") COLOR="\033[1;35m" ;;
        "yellow") COLOR="\033[1;33m" ;;
        "white") COLOR="\033[0m" ;;
        *) COLOR="\033[0m" ;;
    esac
    echo -e "${COLOR}${2}${NC}"
}
