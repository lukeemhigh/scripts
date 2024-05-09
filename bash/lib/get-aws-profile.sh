#!/usr/bin/env bash
#
# Author: Luca Giugliardi
# Email: <luca.giugliardi@gmail.com>
#
#####################################
# Checks aws-cli configuration files
# for profiles. If more than one is
# found, it will prompt the user to
# select one via fzf.
#####################################

get_aws_profile() {
  local profiles
  local profiles_number
  local profile

  profiles=$(aws configure list-profiles)
  profiles_number=$(echo "$profiles" | wc -l)

  case $profiles_number in
    0)
      print_color "red" "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') Invalid config file" 1>&2
      exit 1
      ;;
    1)
      profile=${profiles}
      ;;
    *)
      profile=$(echo "$profiles" |
        fzf --height=30% \
          --layout=reverse \
          --border \
          --prompt 'Which AWS profile do you want to use? ' || echo "gnappo" && exit 1)
      ;;
  esac

  echo "$profile"
}
