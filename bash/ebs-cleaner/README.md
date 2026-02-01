# ebs-cleaner

AWS EBS volume cleanup utility that identifies and safely deletes dangling volumes not claimed by Kubernetes persistent volume claims.

## Description

This script automates the cleanup of unused EBS volumes in AWS that were created for Kubernetes persistent volumes but are no longer attached to the cluster. It cross-references AWS EBS volumes with Kubernetes PV/PVC resources to ensure only truly orphaned volumes are deleted.

## Usage

```bash
./ebs-cleaner
```

The script must be run with:

- Active AWS credentials configured
- kubectl context set to the target cluster
- Appropriate IAM permissions for EC2 and EBS operations

## How It Works

1. **Fetch Data**: Queries AWS for all EBS volumes in `available` state (not attached)
2. **Filter Data**: For each volume, checks if its associated PV/PVC still exists in Kubernetes
3. **Verify Claims**: Validates that volumes tagged with Kubernetes metadata are genuinely unclaimed
4. **Interactive Confirmation**: Displays a table of volumes to be deleted and prompts for confirmation
5. **Parallel Deletion**: Deletes volumes in parallel (4 concurrent operations) for efficiency

## Features

- Prevents accidental deletion of claimed volumes
- Cross-references AWS tags with Kubernetes cluster state
- Displays volumes in formatted table before deletion
- Parallel processing for faster cleanup
- Comprehensive logging with timestamps
- Temporary file cleanup on exit

## Requirements

- **AWS CLI**: Configured with appropriate credentials and permissions
- **kubectl**: Configured with cluster access
- **jq**: JSON processing
- **GNU parallel**: Concurrent operations
- IAM permissions: `ec2:DescribeVolumes`, `ec2:DeleteVolume`
- Kubernetes permissions: Read access to PersistentVolumes

## Safety Features

The script filters out volumes that:

- Are claimed by existing PVCs in any namespace
- Have valid Kubernetes namespace associations
- Are currently in use by the cluster

## Output

Generates a temporary CSV file with columns:

- EBS Volume ID
- PVC Name (if tagged)
- PV Name (if tagged)

Results are displayed in a formatted table before proceeding with deletion.

## Example Output

```sh
2026-02-01T10:15:23 UTC [INFO]: Fetching all dangling volumes..
2026-02-01T10:15:25 UTC [INFO]: Done.
2026-02-01T10:15:25 UTC [INFO]: Filtering out claimed volumes..
2026-02-01T10:15:30 UTC [INFO]: Done.
2026-02-01T10:15:30 UTC [INFO]: The following EBS volumes will be deleted:

EBS VOLUME           CLAIM NAME          PV NAME
vol-0abc123def456    old-data-claim      pvc-xyz789
vol-0def789ghi012    unused-storage      pvc-abc456
```
