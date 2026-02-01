# get-aws-resources

Comprehensive AWS resource inventory generator that scans all regions and produces detailed Excel reports of in-use resources with their associated tags.

## Description

This script performs a parallel scan across all AWS regions to catalog resources by service type. It leverages the AWS Resource Groups Tagging API to gather comprehensive resource information and tags, then generates an Excel file for easy analysis and reporting.

## Usage

```bash
./get-aws-resources --profile <aws-profile> --jobs <concurrent-jobs>
./get-aws-resources -p <aws-profile> -j <concurrent-jobs>
```

### Options

- `-p, --profile <profile>`: AWS CLI profile to use (prompts with fzf if not specified)
- `-j, --jobs <number>`: Number of concurrent jobs (controls parallelism)

## How It Works

1. **Profile Selection**: Uses specified profile or prompts for selection via fzf
2. **Parallel Scanning**: Launches concurrent jobs to check each region/service combination
3. **Data Collection**: Queries AWS Resource Groups Tagging API for resources and tags
4. **CSV Generation**: Creates individual CSV files per region/service combination
5. **Excel Export**: Consolidates all CSV files into a single Excel workbook with Python

## Scanned Regions

Covers all 24+ AWS regions globally:

- US regions (us-east-1, us-east-2, us-west-1, us-west-2)
- Asia Pacific (ap-southeast-1, ap-southeast-2, ap-northeast-1, ap-south-1, etc.)
- Europe (eu-central-1, eu-west-1, eu-west-2, eu-west-3, eu-north-1, eu-south-1)
- Middle East (me-south-1, me-central-1)
- South America (sa-east-1)
- Africa (af-south-1)
- Canada (ca-central-1)

## Monitored Services

- **Compute**: EC2, ECS, EKS, Lambda
- **Storage**: EBS, S3
- **Database**: RDS, DynamoDB, ElastiCache
- **Networking**: ELB, Route53, CloudFront
- **Security**: IAM, Cognito
- **Application**: SNS, SQS, Amplify
- **Monitoring**: CloudWatch

## Output

Results are stored in:

```sh
~/tmp/get-aws-resources-<timestamp>/
  ├── data/          # Individual CSV files per region/service
  └── output/        # Final Excel workbook
```

### CSV Format

Each CSV contains:

- Region
- Service Type
- Resource ARN
- Tag Key
- Tag Value

### Excel Output

The Python component (`csv-import.py`) consolidates all CSVs into a single Excel file with:

- Formatted worksheets
- Auto-sized columns
- Resource grouping by region and service

## Requirements

- **AWS CLI**: Configured with valid credentials
- **jq**: JSON processing
- **GNU parallel**: Concurrent operations
- **Python 3**: With pandas and openpyxl libraries
- **Anaconda**: For Python virtual environment management (or modify conda_activate call)
- IAM permissions: `tag:GetResources` for Resource Groups Tagging API

## Python Dependencies

Install in your Python environment:

```bash
pip install pandas openpyxl
```

Or ensure the `get-aws-resources` conda environment exists with these packages.

## Performance

- Parallel execution dramatically reduces scan time
- Typical full-account scan: 5-15 minutes depending on resource count
- Adjust `--jobs` parameter based on system resources and API rate limits

## Notes

- Empty regions/services are automatically excluded from output
- The script requires a conda environment named `get-aws-resources` (or modify the activation call)
- Large accounts with thousands of resources may produce large Excel files
