#!/bin/bash
#
# Author: Luca Giugliardi
# Email: luca.giugliardi@gmail.com

##########################################
# Check if an item is present on the page
# Arguments:
#   Page.
#   Item. eg: Laptop, VR, Watch
##########################################

URL=$1

function test_https(){
    if wget --spider https://"${URL}"; then
        local https="true"
    else
        local https="false"
    fi

    echo "${https}"
}
