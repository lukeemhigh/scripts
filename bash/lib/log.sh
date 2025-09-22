#!/usr/bin/env bash
#
# Author: Luca Giugliardi
# Email: <luca.giugliardi@gmail.com>
#
#####################################
# Prints an appropriatley formatted
# log to the console with an ISO8601
# timestamp.
# Usage:
#   log <level> <message>
#####################################

log() {
  local message="${2}"
  local color_reset="\033[0m"

  case "${1}" in
    "debug")
      log_level="[DEBUG]"
      color="\033[1;34m"
      ;;
    "info")
      log_level="[INFO]"
      color="\033[0;32m"
      ;;
    "warning" | "warn")
      log_level="[WARNING]"
      color="\033[1;33m"
      ;;
    "error")
      log_level="[ERROR]"
      color="\033[0;31m"
      ;;
    "" | *)
      color="\033[0m"
      ;;
  esac

  echo -e "$(date -u +"%Y-%m-%dT%H:%M:%S %Z%:z") ${color}${log_level}${color_reset}: ${message}"
}
