#!/bin/bash
#
# Automate eks nodegroups update
#
# Author Luca Giugliardi
# Email: luca.giugliardi@gmail.com

# --------------------------- Import Functions ---------------------------

# shellcheck source=/dev/null

source "$HOME/scripts/bash/useful-functions/print-color.sh"

# --------------------------- Optional Flags ---------------------------

TEMP=$(getopt -o p:c: --long profile:cluster: -n 'test.sh' -- "$@")

if [ $? != 0 ]; then
    echo "usage: $0 [--profile | -p] [AWSCLI_PROFILE] [--cluster | -c] [CLUSTER_NAME]"
    exit 1
fi

eval set -- "$TEMP"

while true; do
    case "$1" in
        -p | --profile ) profile="$2"; shift 2 ;;
        -c | --cluster ) cluster="$2"; shift 2 ;;
        -- ) shift; break ;;
        * )
            echo "usage: $0 [--profile | -p] [AWSCLI_PROFILE] [--cluster | -c] [CLUSTER_NAME]"
            exit 1
            ;;
    esac
done

# If optargs are empty, prompt user for aws profile and eks cluster name

if [[ -z $profile ]]; then
    read -p "Enter your aws profile name:"$'\n> ' profile
fi

if [[ -z $cluster ]]; then
    read -p "Enter your eks cluster name:"$'\n> ' cluster
fi

# --------------------------- Nodegroups Check ---------------------------

print_color "blue" "Checking $cluster managed nodegroups..."

mapfile -t node_list < <(eksctl get nodegroup --profile "$profile" --cluster "$cluster" -o json 2> /dev/null | jq -r '.[] | . as $e | [$e.Name] | @csv')

declare -a node_list

for node in "${node_list[@]}"; do

    s_flag=0

    print_color "blue" "Processing ${node//\"/}..."

    status=$(eksctl get nodegroup --profile "$profile" --cluster "$cluster" --name "${node//\"/}" -o json | jq -r '.[] | . as $e | [$e.Status] | @csv')
    max_size=$(eksctl get nodegroup --profile "$profile" --cluster "$cluster" --name "${node//\"/}" -o json | jq -r '.[] | . as $e | [$e.MaxSize] | @csv')
    min_size=$(eksctl get nodegroup --profile "$profile" --cluster "$cluster" --name "${node//\"/}" -o json | jq -r '.[] | . as $e | [$e.MinSize] | @csv')
    desired_capacity=$(eksctl get nodegroup --profile "$profile" --cluster "$cluster" --name "${node//\"/}" -o json | jq -r '.[] | . as $e | [$e.DesiredCapacity] | @csv')

    # Checking nodegroup status and capacity, scaling up if necessary

    if [[ "${status//\"/}" == "ACTIVE" ]]; then
        print_color "green" "Nodegroup status is ${status//\"/}"
        print_color "green" "Nodegroup max size is $max_size"
        print_color "green" "Nodegroup min size is $min_size"
        print_color "green" "Nodegroup desired capacity is $desired_capacity"

        if [ "$max_size" -lt 2 ]; then
            if [ "$desired_capacity" -lt 2 ]; then
                print_color "blue" "Scaling up nodegroup ${node//\"/} capacity..."
                s_flag=1
                eksctl scale nodegroup --profile "$profile" --cluster "$cluster" --name "${node//\"/}" --nodes $(( ++desired_capacity )) --nodes-min "$min_size" --nodes-max $(( ++max_size ))
            fi 
        fi

# --------------------------- Nodegroups Upgrade ---------------------------

        print_color "blue" "Upgrading ${node//\"/}..."
        eksctl upgrade nodegroup --profile "$profile" --cluster "$cluster" --name "${node//\"/}" --force-upgrade

        # If nodegroup was scaled up, bring it down to the original capacity

        if [ $s_flag -eq 1 ]; then
            print_color "blue" "Scaling down ${node//\"/}..."
            eksctl scale nodegroup --profile "$profile" --cluster "$cluster" --name "${node//\"/}" --nodes $(( --desired_capacity )) --nodes-min "$min_size" --nodes-max $(( --max_size ))
        fi

        print_color "green" "${node//\"/} succesfully upgraded"

    else
        print_color "red" "Skipped nodegroup ${node//\"/} due to its status"
    fi
done