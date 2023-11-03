#!/usr/bin/env bash

conda_activate() {
    local venv="$1"
    source "${HOME}"/anaconda3/bin/activate "${venv}"
}
