#!/usr/bin/env bash
#
# Author: Luca Giugliardi
# Email: <luca.giugliardi@gmail.com>
#
#####################################
# Prints a CSV file as a table.
# Arguments:
#   $1: the CSV file to print
#   $@:2: the column names
#####################################

print_as_table() {
  local filename="${1}"
  local -a column_names=("${@:2}")

  printf "\n"
  sed -e 's/,/ /g' -e 's/"//g' "${filename}" |
    column -t -N "$(printf "%s," "${column_names[@]}")"
  printf "\n"
}
