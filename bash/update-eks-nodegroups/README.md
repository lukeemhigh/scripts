# Descrption

Wrapper for `eksctl` in bash.
This script aims to simplify (by automating it) the update of eks managed nodegroups to the latest AMI version.

## Arguments

`update-eks-nodegroups` takes in two arguments:

- -p|--profile) The aws-cli profile you want to use
- -c|--cluser) The eks cluster you want to perform the upgrade in.
- -j|--jobs) The number of concurrent jobs to run.
- -v|--verbose) Activates some very minor debug info logging.

If the aforementioned arguments are not provided, the script will check for an existing aws-cli configuration
in `${HOME}/.aws/config` and provide a TUI selection menu if more than one configuration is found.

## Requirements

To perform the update, the script makes use of the following tools, so please make sure that you have installed them:

- `aws-cli`: [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- `eksctl`: [Installation Guide](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)
- `jq`: Install through your package manager.
- `fzf`: Install through your package manager, or from [GitHub](https://github.com/junegunn/fzf).
- `parallel`: Install it through you package manager.

