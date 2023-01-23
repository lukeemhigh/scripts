#!/bin/bash
#
# Creates users massively, reding from file
#
# Author: Luca Giugliardi
# Email: luca.giugliardi@gmail.com

# --------------------------- Import Functions ---------------------------

# shellcheck source=/dev/null

source "$HOME/git-repos/scripts/bash/useful-functions/print-color.sh"

# --------------------------- Users Creation ---------------------------

while IFS=: read -r username password group description shell; do
	shell=${shell:-bash}
	shell_path=$(which "$shell")
	password=${password:-Lingotto01!}

	print_color "blue" "Creating user $username"

	if [ -z "$group" ]
	then 
		useradd -c "$description" -d "/home/$username" -s "$shell_path" "$username"
	else
		useradd -G "$group" -c "$description" -d "/home/$username" -s "$shell_path" "$username"
	fi

	print_color "green" "User $username succesfully created"

	print_color "blue" "Sentting $username initial password"

	echo -e "$password\n$password\n" | passwd --stdin  "$username"
	passwd --expire "$username"

	print_color "green" "Set password for user $username"

done < users_list.txt
unset IFS
