#!/usr/bin/env bash

spin='-\|/'
i=0

while [[ true ]]; do
	printf "\r${spin:$((i % 4)):1}"
	sleep 0.1
	((i++))
done
