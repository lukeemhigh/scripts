#!/usr/bin/env bash
#
# Author: Luca Giugliardi
# Email: <luca.giugliardi@gmail.com>
#
#####################################
# Check if the given binaries are installed
# Arguments:
#   Utils. eg: aws, kubectl, eksctl
#####################################

check_utils() {
  local utils=("$@")
  for util in "${utils[@]}"; do
    if ! which "$util" >/dev/null 2>&1; then
      print_color "red" "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') Cannot find ${util}, please make sure it's installed before running the script"
      exit 1
    fi
  done
}
