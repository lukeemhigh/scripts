#!/usr/bin/env bash

# Automates eks nodegroups update
#
# Author Luca Giugliardi
# Email: luca.giugliardi@gmail.com

# ----------------------------- Shell Options ----------------------------
set -eo pipefail

# --------------------------- Import Functions ---------------------------

# shellcheck source=/dev/null

source "${HOME}/git-repos/scripts/bash/useful-functions/print-color.sh"

# --------------------------- Optional Flags ---------------------------

TEMP=$(getopt -o p:c: --long profile:,cluster: -n 'test.sh' -- "$@")

if [ $? -ne 0 ]; then
    echo "usage: $0 [--profile | -p] [AWSCLI_PROFILE] [--cluster | -c] [CLUSTER_NAME]" 1>&2
    exit 1
fi

eval set -- "$TEMP"

while true; do
    case "$1" in
        -p|--profile)
            profile="$2"
            shift 2
            ;;
        -c|--cluster)
            cluster="$2"
            shift 2
            ;;
        --)
            shift
            break ;;
        *)
            echo "usage: $0 [--profile | -p] [AWSCLI_PROFILE] [--cluster | -c] [CLUSTER_NAME]" 1>&2
            exit 1
            ;;
    esac
done

# ------------------------- Guard Clauses -------------------------

# Check for needed tools installation

for tool in aws eksctl jq fzf; do
    if ! which "$tool" >/dev/null; then
        print_color "red" "[ERROR]: Cannot find ${tool}, please make sure it's installed before running the script"
        exit 1
    fi
done

# If optargs are empty, prompt user for aws profile and get eks cluster name from query

if [[ -z "$profile" ]]; then
    if [[ -e "${HOME}/.aws/config" ]]; then
        config=$(grep -E '\[[[:alnum:]]+\]' "${HOME}/.aws/config" |\
        sed 's/\[\(.*\)\]/\1/')
        config_number=$(echo "$config" | wc -l)
        
        case $config_number in
            0)
                print_color "red" "[ERROR]: Invalid config file" 1>&2
                exit 1
                ;;
            1)
               profile=${config}
               ;;
            *)
               profile=$(echo "$config" |\
               fzf --height=30% \
               --layout=reverse \
               --border \
               --prompt 'Which AWS profile do you want to use? ')
               ;;
        esac
        
        cluster_list=$(aws --profile "$profile" eks list-clusters |\
        jq -r '.clusters | @csv' |\
        tr ',' '\n' |\
        sed 's/\"\(.*\)\"/\1/')

        cluster_number=$(echo "$cluster_list" | wc -l)

        if [ "${cluster_number}" -gt 1 ]; then
            cluster=$(echo "$cluster_list" |\
            fzf --height=30% \
            --layout=reverse \
            --border \
            --prompt 'Which EKS cluster do you want to upgrade? ')
        else
            cluster=$cluster_list
        fi
    else
        print_color "red" "[ERROR]: Cannot fint ${HOME}/.aws/config, either specify your profile by hand, or check your aws-cli config files location" 1>&2
        exit 1
    fi
fi

# ------------------------- Variable & Constants -------------------------
 
cluster_data=$(eksctl get nodegroup --profile "$profile" --cluster "$cluster" -o json 2>/dev/null)
readonly cluster_data
number_of_nodes=$(echo "$cluster_data" | jq '. | length')
readonly number_of_nodes

# --------------------------- Nodegroups Check ---------------------------

print_color "puprle" "Checking ${cluster} managed nodegroups..."


# TODO: Use parallel instead of a for loop to speed up the upgrade (it will probably require to rewrite the upgrade part as a function..)

for ((i=0;i<number_of_nodes;i++)); do

    node_data=$(echo "$cluster_data" | jq -r --argjson index "$i" '.[$index]')
    
    node_name=$(echo "$node_data" | jq -r '. as $e | [$e.Name] | @csv')
    status=$(echo "$node_data" | jq -r '. as $e | [$e.Status] | @csv')
    max_size=$(echo "$node_data" | jq -r '. as $e | [$e.MaxSize] | @csv')
    min_size=$(echo "$node_data" | jq -r '. as $e | [$e.MinSize] | @csv')
    desired_capacity=$(echo "$node_data" | jq -r '. as $e | [$e.DesiredCapacity] | @csv')
    is_scaled=0

    print_color "blue" "Processing ${node_name//\"/}..."
    
    # Checking nodegroup status and capacity, scaling up if necessary

    if [[ "${status//\"/}" == "ACTIVE" ]]; then
        print_color "yellow" "[DEBUG]: Nodegroup status is ${status//\"/}"
        print_color "yellow" "[DEBUG]: Nodegroup max size is ${max_size}"
        print_color "yellow" "[DEBUG]: Nodegroup min size is ${min_size}"
        print_color "yellow" "[DEBUG]: Nodegroup desired capacity is ${desired_capacity}"

        if [ "$desired_capacity" -lt 2 ]; then
            if [ "$max_size" -lt 2 ]; then
                print_color "blue" "Scaling up nodegroup ${node_name//\"/} capacity..."
                is_scaled=1
                eksctl scale nodegroup --profile "$profile" --cluster "$cluster" \
                --name "${node_name//\"/}" --nodes 2 \
                --nodes-min "$min_size" --nodes-max 2
            else
                print_color "blue" "Scaling up nodegroup ${node_name//\"/} capacity..."
                is_scaled=2
                eksctl scale nodegroup --profile "$profile" --cluster "$cluster" \
                --name "${node_name//\"/}" --nodes 2 \
                --nodes-min "$min_size" --nodes-max "$max_size"
            fi
        fi

        while [[ $(eksctl get nodegroup --profile "$profile" --cluster "$cluster" --name "${node_name//\"/}" -o json | jq -r '.[] | . as $e | [$e.Status] | @csv' | sed 's/"//g') == 'UPDATING' ]]; do
            print_color "blue" "Waiting for node ${node_name//\"/} to be ready.."
            sleep 10
        done
        
        # --------------------------- Nodegroups Upgrade ---------------------------

        print_color "blue" "Upgrading ${node_name//\"/}..."
        eksctl upgrade nodegroup --profile "$profile" --cluster "$cluster" \
        --name "${node_name//\"/}" --force-upgrade

            # If nodegroup was scaled up, bring it down to the original capacity, getting it from readonly constant $cluster_data for good measure

            case $is_scaled in
                0)
                    ;;
                1)
                    print_color "blue" "Scaling down ${node_name//\"/}..."
                    eksctl scale nodegroup --profile "$profile" --cluster "$cluster" \
                    --name "${node_name//\"/}" --nodes "$(echo "$cluster_data" | jq -r --argjson index "$i" '.[$index] | . as $e | [$e.DesiredCapacity] | @csv' | sed 's/"//g')" \
                    --nodes-min "$min_size" --nodes-max "$(echo "$cluster_data" | jq -r --argjson index "$i" '.[$index] | . as $e | [$e.MaxSize] | @csv' | sed 's/"//g')"
                    ;;
                2)
                    print_color "blue" "Scaling down ${node_name//\"/}..."
                    eksctl scale nodegroup --profile "$profile" --cluster "$cluster" \
                    --name "${node_name//\"/}" --nodes "$(echo "$cluster_data" | jq -r --argjson index "$i" '.[$index] | . as $e | [$e.DesiredCapacity] | @csv' | sed 's/"//g')" \
                    --nodes-min "$min_size" --nodes-max "$max_size"
                    ;;
                *)
                    exit 1
                    ;;
            esac

        print_color "[INFO]: green" "${node_name//\"/} succesfully upgraded"

    else
        print_color "red" "[ERROR]: Skipped nodegroup ${node_name//\"/} due to its status" 1>&2 
    fi
done
