#!/usr/bin/env bash
#
# Author: Luca Giugliardi
# Email: <luca.giugliardi@gmail.com>

##########################################
# Check if an item is present on the page
# Arguments:
#   Page.
#   Item. eg: Laptop, VR, Watch
##########################################

test_https() {
  if wget --spider https://"$1" >/dev/null 2>&1; then
    local https="true"
  else
    local https="false"
  fi

  echo $https
}
