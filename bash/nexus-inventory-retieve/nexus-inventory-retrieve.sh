#!/bin/bash
#
# Automate Sonatype Nexus Repository inventory retrieval through its REST APIs
#
# Author Luca Giugliardi
# Email: luca.giugliardi@gmail.com

# --------------------------- Import Functions ---------------------------

# shellcheck source=/dev/null
source "$HOME/git-repos/scripts/bash/useful-functions/print-color.sh"

# shellcheck source=/dev/null
source "$HOME/git-repos/scripts/bash/useful-functions/test-https.sh"


# --------------------------- Optional Flags ---------------------------

TEMP=$(getopt -o a: --long address: -n 'test.sh' -- "$@")

if [ $? -ne 0 ]; then
    echo "usage: $0 [--address | -a] [NEXUS_ADDRESS]"
    exit 1
fi

eval set -- "$TEMP"

while true; do
    case "$1" in
        -a|--address)
            address="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "usage: $0 [--address | -a] [NEXUS_ADDRESS]"
            exit 1
            ;;
    esac
done

# If no flag is specified, prompt user for Nexus Repo address

if [ -z "$address" ]; then
    read -p "Enter your Nexus Repo Address:"$'\n> ' address
fi

# --------------------------- Global Variables ---------------------------

date=$(date +%F_%T)

output_path="$HOME/tmp/nexus-inventory-$date"

https=$(test_https)
https=$(test_https "$address")

# --------------------------- Repositories Retrieval ---------------------------

print_color "blue" "Checking https connection.."

if [[ "${https}" == "true" ]]; then
    print_color "green" "Server accepts https connections. Proceeding.."
    protocol="https"
else
    print_color "red" "Server does not accept https connection. Falling back to http.."
    protocol="http"
fi

print_color "blue" "Checking repositories for $address"

mkdir -p "$output_path/assets"

curl -sn -X 'GET' \
    "$protocol://$address/service/rest/v1/repositories" \
    -H 'accept: application/json' | \
    jq -r '.[] | . as $e | [.name,.format,.type,.url] | @csv' \
    >> "$output_path/$address-repositories-list.csv"

print_color "green" "Done writing file $output_path/$address-repositories-list.csv"

# --------------------------- Assets Retrieval ---------------------------

mapfile -t repo_list < <(cut -d',' -f1 "$output_path/$address-repositories-list.csv")

declare -a repo_list

for repo in "${repo_list[@]}"; do

    print_color "blue" "Checking assets for ${repo//\"/}"

    curl -sn -X 'GET' \
        "$protocol://$address/service/rest/v1/assets?repository=${repo//\"/}" \
        -H 'accept: application/json' | \
        jq -r '.items[] | . as $e | [.repository,.format,.id,.path,.downloadUrl] | @csv' \
        >> "$output_path/assets/${repo//\"/}-assets-list.csv"

    if [[ ! -s "$output_path/assets/${repo//\"/}-assets-list.csv" ]]; then
        print_color "red" "Repo ${repo//\"/} is empty"
        rm -f "$output_path/assets/${repo//\"/}-assets-list.csv"
    else
        print_color "green" "Assets found. Written list at $output_path/assets/${repo//\"/}-assets-list.csv"
    fi

done
