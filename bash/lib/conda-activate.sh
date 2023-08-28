#!/usr/bin/env bash

conda_activate() {
	local venv="$1"
	source /home/lukeemhigh/anaconda3/bin/activate "${venv}"
}
