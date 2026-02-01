# patch-secrets

Kubernetes TLS secret updater that patches multiple secrets matching a regex pattern with new certificate and key files in parallel.

## Description

This script automates the process of updating TLS certificates and keys across multiple Kubernetes secrets. It searches for secrets matching a provided pattern, displays them for review, and patches them in parallel with new certificate and key data.

## Usage

```bash
./patch-secrets --cert <cert-file> --key <key-file> --pattern <regex>
./patch-secrets -c <cert-file> -k <key-file> -p <regex>
```

### Options

- `-c, --cert <path>`: Path to the new certificate file
- `-k, --key <path>`: Path to the new key file
- `-p, --pattern <regex>`: Regex pattern to match secret names
- `-h, --help`: Display help message

## How It Works

1. **Validation**: Verifies certificate and key files exist
2. **Secret Discovery**: Searches all namespaces for secrets matching the pattern
3. **Interactive Review**: Displays matching secrets in a formatted table
4. **User Confirmation**: Prompts for confirmation before proceeding
5. **Base64 Encoding**: Encodes certificate and key files to base64
6. **Parallel Patching**: Updates secrets concurrently (4 jobs at a time)

## Features

- Pattern-based secret matching with regex support
- Cross-namespace secret discovery
- Interactive confirmation before modification
- Parallel execution for faster updates (4 concurrent patches)
- Comprehensive error handling and logging
- Temporary file cleanup on exit
- Base64 encoding handled automatically

## Requirements

- **kubectl**: Configured with cluster access
- **GNU parallel**: Concurrent operations
- Kubernetes permissions: Read/write access to secrets in target namespaces
- Certificate and key files in PEM format

## Example Usage

Update all wildcard certificates:

```bash
./patch-secrets \
  --cert /path/to/new-wildcard.crt \
  --key /path/to/new-wildcard.key \
  --pattern "wildcard-.*-tls"
```

Update specific environment secrets:

```bash
./patch-secrets \
  -c ./production.crt \
  -k ./production.key \
  -p "prod-.*-secret"
```

## Output Example

```sh
2026-02-01T10:30:00 UTC [INFO]: Fetching secrets matching pattern wildcard-.*-tls...
2026-02-01T10:30:01 UTC [INFO]: Found the following secrets:

NAMESPACE      SECRET NAME
frontend       wildcard-frontend-tls
backend        wildcard-backend-tls
api            wildcard-api-tls

Do you want to proceed with patching these secrets? [Y/n] y
2026-02-01T10:30:05 UTC [INFO]: Proceeding with patching...
2026-02-01T10:30:05 UTC [INFO]: Patching secret frontend/wildcard-frontend-tls...
2026-02-01T10:30:05 UTC [INFO]: Patching secret backend/wildcard-backend-tls...
2026-02-01T10:30:05 UTC [INFO]: Patching secret api/wildcard-api-tls...
2026-02-01T10:30:06 UTC [INFO]: Secret frontend/wildcard-frontend-tls patched successfully.
2026-02-01T10:30:06 UTC [INFO]: Secret backend/wildcard-backend-tls patched successfully.
2026-02-01T10:30:06 UTC [INFO]: Secret api/wildcard-api-tls patched successfully.
```

## Pattern Matching

The pattern is used with `grep -oP` to match secret names. Examples:

- `".*"` - Match all secrets (use with caution!)
- `"wildcard-.*"` - Match all secrets starting with "wildcard-"
- `".*-tls$"` - Match all secrets ending with "-tls"
- `"prod-app-.*"` - Match all secrets starting with "prod-app-"

## Safety Features

- Validates certificate and key files exist before proceeding
- Displays all matched secrets before any modifications
- Requires explicit user confirmation
- Logs all operations with timestamps
- Error handling for failed patch operations
- Preserves existing secret structure (only updates `tls.crt` and `tls.key`)

## Technical Details

The script creates a JSON merge patch with base64-encoded certificate and key data:

```json
{
  "data": {
    "tls.crt": "<base64-encoded-cert>",
    "tls.key": "<base64-encoded-key>"
  }
}
```

This preserves any other fields in the secret while updating only the TLS data.
