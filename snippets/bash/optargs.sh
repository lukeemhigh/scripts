#!/usr/bin/env bash

TEMP=$(getopt -o a:b: --long aaa:,bbb: -n 'test.sh' -- "$@")

if [ $? -ne 0 ]; then
	echo "usage: $0 [--aaa | -a ] [VALUE] [--bbb | -b] [VALUE]"
	exit 1
fi

eval set -- "$TEMP"

while true; do
	case "$1" in
	-a | --aaa)
		foo="$2"
		shift 2
		;;
	-b | --bbb)
		bar="$2"
		shift 2
		;;
	--)
		shift
		break
		;;
	*)
		echo "usage: $0 [--aaa | -a ] [VALUE] [--bbb | -b] [VALUE]"
		exit 1
		;;
	esac
done

echo "${foo}${bar}"
