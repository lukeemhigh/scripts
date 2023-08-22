# Description

Automate Sonatype Nexus Repository inventory retrieval through its REST APIs

## .netrc

This script uses the .netrc file to provide credentials to the Nexus server.
If you don't have a .netrc file, simply create one and place in in your home directory.
Format credentials following this example:

```bash
machine nexus.example.com
login admin
password admin123
```

## Parameters

This script accepts the `--address` parameter or the shorthand `-a` flag to provide the address of your Nexus Repository

```bash
./nexus-inventory-retrieve.sh --address nexus.example.com

./nexus-inventory-retrieve.sh -a nexus.example.com
```

If an address is not specified at launch, the script will prompt you for an address
