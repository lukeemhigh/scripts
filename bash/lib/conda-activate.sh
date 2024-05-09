#!/usr/bin/env bash
#
# Author: Luca Giugliardi
# Email: <luca.giugliardi@gmail.com>
#
#####################################
# Activates an anaconda virtual
# environment.
#####################################

conda_activate() {
  local venv="$1"
  source "${HOME}/anaconda3/bin/activate" "${venv}"
}
