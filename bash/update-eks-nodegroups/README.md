# Descrption

Wrapper for `eksctl` in bash.
This script aims to simplify (by automating it) the update of AWS EKS managed nodegroups to the latest AMI version.
The script will check if the nodegroups in your cluster have less than two nodes, and temporarily scale them up accordingly while performing the update,
to avoid service interruptions. Make sure that you have set values for `maxUnavailable` or `maxUnavailablePercentage` in your nodegroups `updateConfig`,
otherwise this step is rendered useless!
After the update is completed, every scaled-up nodegroup is scaled down to its original capacity.

## Arguments

`update-eks-nodegroups` takes in four arguments:

- `-p`|`--profile`) The aws-cli profile you want to use
- `-c`|`--cluser`) The eks cluster you want to perform the upgrade in.
- `-j`|`--jobs`) The number of concurrent jobs to run (default is 2).
- `-v`|`--verbose`) Activates some very minor debug info logging.

If one of the first two aforementioned arguments are not provided, the script will check for an existing aws-cli configuration
in `${HOME}/.aws/config` and provide a TUI selection menu if more than one configuration is found.

## Requirements

To perform the update, the script makes use of the following tools, so please make sure that you have installed them:

- `aws-cli`: [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- `eksctl`: [Installation Guide](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)
- `jq`: Install through your package manager.
- `fzf`: Install through your package manager, or from [GitHub](https://github.com/junegunn/fzf).
- `parallel`: Install it through you package manager.

