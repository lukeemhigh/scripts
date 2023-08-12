#!/usr/bin/env bash

get_lib_path() {
	local lib_path
	lib_path=$(cd "$(dirname "$0")" && echo "${PWD}" | sed 's/\/[^/]*$/\/lib/')
	echo "${lib_path}"
}
