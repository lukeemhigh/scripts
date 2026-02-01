# batch-useradd

Mass user creation utility for Linux systems that automates the process of creating multiple users from a file specification.

## Description

This script reads user specifications from a file (`users-list.txt` by default) and creates Linux user accounts with customizable attributes including groups, descriptions, and shell preferences. Initial passwords are set and immediately expired, forcing users to change them on first login.

## Usage

```bash
./batch-useradd
```

The script expects a `users-list.txt` file in the same directory with the following format:

```
username:password:group:description:shell
```

### Field Specifications

- **username**: Linux username to create (required)
- **password**: Initial password (optional, defaults to `TempPassword#01`)
- **group**: Secondary group membership (optional)
- **description**: User description/GECOS field (optional)
- **shell**: Shell binary name (optional, defaults to `bash`)

### Example

```
jdoe:SecurePass123:developers:John Doe:bash
asmith::admins:Alice Smith:zsh
bwilson:::Bob Wilson:
```

## Features

- Creates user home directories automatically
- Configures custom shells (resolves shell path with `which`)
- Assigns secondary group memberships
- Sets initial passwords and forces password change on first login
- Color-coded console output for operation status
- Handles missing optional fields gracefully

## Requirements

- Root/sudo privileges (for `useradd` and `passwd` commands)
- `print-color.sh` library function
- Users-list file with colon-separated values

## Security Notes

- Password expiration is enforced immediately after user creation
- Users must change password on first login
- Consider using a secure method to distribute initial passwords
