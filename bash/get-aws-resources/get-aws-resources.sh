#!/bin/bash
#
# Simple script to generate an xlsx file containing in-use aws resources with their respective tags, 
# grouped by region and service type.
#
# TO DO: MAKE THE SCRIPT READ THE LIST OF ALL REGIONS AND SERVICES FROM AWSCLI OUTPUT (IF SUCH COMMAND EXISTS) 
# INSTEAD OF HAVING THEM HARD-CODED INTO ARRAYS
#
# Author: Luca Giugliardi
# Email: luca.giugliardi@gmail.com

# --------------------------- Import Functions ---------------------------

# shellcheck source=/dev/null

source "$HOME/scripts/bash/useful-functions/print-color.sh"

# --------------------------- Declaring Arrays ---------------------------

region_list=(
            "us-east-2"
            "us-east-1"
            "us-west-1"
            "us-west-2"
            "af-south-1"
            "ap-east-1"
            "ap-southeast-3"
            "ap-south-1"
            "ap-northeast-3"
            "ap-northeast-2"
            "ap-southeast-1"
            "ap-southeast-2"
            "ap-northeast-1"
            "ca-central-1"
            "eu-central-1"
            "eu-west-1"
            "eu-west-2"
            "eu-south-1"
            "eu-west-3"
            "eu-north-1"
            "me-south-1"
            "me-central-1"
            "sa-east-1"
            )

services_list=(
            "amplify"
            "cloudfront"
            "cloudwatch"
            "cognito"
            "dynamodb"
            "ebs"
            "ec2"
            "ecs"
            "eks"
            "elasticache"
            "elb"
            "iam"
            "lambda"
            "rds"
            "route53"
            "s3"
            "sns"
            "sqs"
            )

# --------------------------- Global Variables ---------------------------

date=$(date +%F_%T)

output_path="$HOME/tmp/get-aws-resources-$date"

# --------------------------- Writing .csv Files ---------------------------

mkdir -p "$output_path/data"
mkdir -p "$output_path/output"

for region in "${region_list[@]}"; do

    print_color "blue" "Checking services in $region..."

    for service in "${services_list[@]}"; do

        filename="$region-$service.csv"

        aws resourcegroupstaggingapi get-resources \
        --resource-type-filters "$service" \
        --region="$region" \
        --output json 2> /dev/null | \
        jq -r '.ResourceTagMappingList[] | . as $e | .Tags[] | [$e.ResourceARN, .Key, .Value] | @csv' \
        >> "$output_path/data/$filename"

        if [ ! -s "$output_path/data/$filename" ]; then
            rm -f "$output_path/data/$filename"
            print_color "red" "No $service services found in $region"
        else
            sed -i -r "s/^/\"$region\",\"$service\",/g" "$output_path/data/$filename"
            print_color "green" "Check completed, data witten into $output_path/data/$filename"
        fi
    done
done

./csv_import.py --directory "$output_path"