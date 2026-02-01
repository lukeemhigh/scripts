# Scripts Collection

A curated collection of automation scripts developed over the years to streamline system administration, cloud infrastructure management, and DevOps workflows.

## Overview

All bash scripts leverage shared utility functions from `./bash/lib` through the `get_lib_path` function, enabling modular and maintainable code.

## Bash Scripts

### Infrastructure & Cloud Management

- **batch-useradd**: Mass user creation utility that reads user specifications from a file and creates Linux users with customizable attributes (groups, shells, descriptions).

- **ebs-cleaner**: AWS EBS volume cleanup tool that identifies and deletes dangling (unattached) volumes not claimed by Kubernetes persistent volume claims.

- **get-aws-resources**: Comprehensive AWS resource inventory generator that scans across all regions and produces an Excel report of in-use resources with their tags.

- **patch-secrets**: Kubernetes TLS secret updater that patches multiple secrets matching a pattern with new certificate and key files in parallel.

- **update-eks-nodegroups**: EKS nodegroup automation tool that upgrades managed nodegroups to the latest AMI version, handling capacity scaling to prevent service interruptions.

- **nexus-inventory-retieve**: Sonatype Nexus Repository inventory tool that retrieves complete asset lists via REST APIs and generates CSV reports.

### Shared Libraries

The `bash/lib` directory contains reusable functions for logging, AWS profile management, service checks, formatted output, and more. See individual README files for details.

## Code Snippets

The `snippets` directory contains example code and templates:

- **bash**: Shell script patterns (library path resolution, argument parsing, spinners)
- **jenkins**: Groovy scripts for job retention and cleanup policies

## Requirements

Most scripts require:

- Bash 4.0+
- GNU utilities (awk, sed, grep, etc.)
- AWS CLI (for AWS-related scripts)
- kubectl (for Kubernetes scripts)
- jq (for JSON processing)
- GNU parallel (for concurrent operations)

Specific requirements are documented in each script's README.
