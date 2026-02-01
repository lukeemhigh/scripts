# nexus-inventory-retrieve

Sonatype Nexus Repository inventory automation tool that retrieves comprehensive asset lists via REST APIs and generates CSV reports for all repositories.

## Description

This script automates the complete inventory retrieval process for Sonatype Nexus repositories. It connects via REST API to enumerate all repositories and their assets, handling pagination automatically and generating detailed CSV reports for each repository.

## Usage

```bash
./nexus-inventory-retrieve --address <nexus-address> --output <output-dir> [--nogroups]
./nexus-inventory-retrieve -a <nexus-address> -o <output-dir> [-n]
```

### Options

- `-a, --address <address>`: IP address or FQDN of the Nexus Repository (prompts if not provided)
- `-o, --output <directory>`: Output directory path (defaults to `~/tmp/nexus-inventory-<timestamp>`)
- `-n, --nogroups`: Skip group-type repositories (only process hosted and proxy repos)
- `-h, --help`: Display help message

## Authentication: .netrc Configuration

This script uses the `.netrc` file for authentication. Create a `.netrc` file in your home directory with the following format:

```sh
machine nexus.example.com
login admin
password admin123
```

**Security Note**: Set appropriate permissions on `.netrc`:

```bash
chmod 600 ~/.netrc
```

## How It Works

1. **Protocol Detection**: Tests HTTPS connectivity and falls back to HTTP if necessary
2. **Repository Discovery**: Retrieves list of all repositories with their metadata
3. **Asset Enumeration**: Iterates through each repository, handling API pagination
4. **CSV Generation**: Creates individual CSV files for each non-empty repository

## Output Structure

```sh
~/tmp/nexus-inventory-<timestamp>/
  ├── <nexus-server>-repositories-list.csv    # Repository metadata
  └── assets/
      ├── <repo-name>-assets-list.csv         # Assets for each repository
      ├── <repo-name>-assets-list.csv
      └── ...
```

### Repository List CSV Columns

- Repository Name
- Format (maven2, npm, docker, etc.)
- Type (hosted, proxy, group)
- Repository URL

### Asset List CSV Columns

- Repository Name
- Format
- Asset ID
- Path
- Download URL

## Features

- Automatic HTTPS/HTTP detection
- Pagination handling for large repositories
- Empty repository filtering (no CSV generated for empty repos)
- Group repository exclusion option
- Progress indicators with colored output
- Comprehensive error handling
- Interactive address prompting if not specified

## Requirements

- **curl**: HTTP client with .netrc support
- **jq**: JSON processing
- **wget**: For HTTPS testing
- Network access to Nexus Repository
- Valid Nexus credentials in `~/.netrc`

## Supported Repository Formats

- Maven2
- npm
- Docker
- PyPI
- NuGet
- Raw
- Yum
- Apt
- And all other Nexus-supported formats

## Performance Considerations

- Large repositories with thousands of assets may take significant time
- API pagination is handled automatically (continuation tokens)
- Progress is displayed page-by-page during asset retrieval
- Consider using `--nogroups` to skip group repositories and speed up execution

## Example Output

```sh
Checking https connection..
Server accepts https connections. Proceeding..
Checking repositories for nexus.example.com
Output written to ~/tmp/nexus-inventory-2026-02-01_10:45:00/nexus.example.com-repositories-list.csv
Checking assets for "docker-hosted"
Done processing 15 pages
Assets found. Written list at ~/tmp/nexus-inventory-2026-02-01_10:45:00/assets/docker-hosted-assets-list.csv
Checking assets for "maven-central"
Repo "maven-central" is empty
```

## Notes

- Group-type repositories aggregate content from other repositories and may be skipped with `-n` flag
- Empty repositories are automatically excluded from output
- The script preserves the original implementation's commented-out GNU parallel section for future optimization
- Continuation tokens ensure complete asset retrieval even for very large repositories
