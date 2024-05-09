#!/usr/bin/env bash
# Author: Luca Giugliardi
# Email: <luca.giugliardi@gmail.com>
#
#####################################
# Prints a rotating bar and a message
# in a given color for a given period
# of time
# Arguments:
#   Color. eg: green, red, blue
#   Time. ds, or n/10th of a second
#####################################

wait_message() {
  spin='\|/-'
  local i=0
  NC='[0m' # No Color
  case $1 in
    "green")
      COLOR="[0;32m"
      ;;
    "red")
      COLOR="[0;31m"
      ;;
    "blue")
      COLOR="[1;34m"
      ;;
    "purple")
      COLOR="[1;35m"
      ;;
    "yellow")
      COLOR="[1;33m"
      ;;
    "white")
      COLOR="[0m"
      ;;
    *)
      COLOR="[0m"
      ;;
  esac
  while [[ i -le $2 ]]; do
    printf '\r%s \e%s%s\e%s' "${spin:$((i % 4)):1}" "$COLOR" "$3" "$NC"
    ((i++))
    sleep 0.1
  done
}
