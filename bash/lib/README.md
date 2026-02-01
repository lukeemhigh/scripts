# Bash Library Functions

Shared utility functions for bash scripts. These functions provide common functionality for logging, AWS operations, system checks, and formatted output.

## Functions Reference

### check-item.sh

#### `check_item(page, item)`

Checks if an item is present on a webpage or text content.

**Parameters:**

- `page`: The page content or text to search
- `item`: The item to search for (e.g., "Laptop", "VR", "Watch")

**Behavior:**

- Prints green success message if item is found
- Prints red error message if item is not found

**Example:**

```bash
page_content=$(curl -s https://example.com/products)
check_item "$page_content" "Laptop"
```

---

### check-ports.sh

#### `check_ports(port)`

Checks if a specified port is open in firewalld.

**Parameters:**

- `port`: Port number to check (e.g., "3306", "80")

**Behavior:**

- Prints green success message if port is configured
- Prints red error message and exits (code 1) if port is not configured

**Requirements:**

- Root/sudo privileges
- firewalld service running

**Example:**

```bash
check_ports 3306  # Check if MySQL port is open
```

---

### check-service-status.sh

#### `check_service_status(service)`

Checks if a systemd service is active and running.

**Parameters:**

- `service`: Service name (e.g., "httpd", "firewalld", "nginx")

**Behavior:**

- Prints green success message if service is active
- Prints red error message and exits (code 1) if service is not running

**Requirements:**

- systemd-based system
- Root/sudo privileges

**Example:**

```bash
check_service_status "httpd"
check_service_status "postgresql"
```

---

### check-utils.sh

#### `check_utils(util1, util2, ...)`

Verifies that required command-line utilities are installed and available in PATH.

**Parameters:**

- Variable number of utility names to check

**Behavior:**

- Silently succeeds if all utilities are found
- Logs error and exits (code 1) if any utility is missing

**Example:**

```bash
check_utils "aws" "kubectl" "jq" "parallel"
check_utils "git" "docker" "terraform"
```

---

### conda-activate.sh

#### `conda_activate(environment)`

Activates an Anaconda/Miniconda virtual environment.

**Parameters:**

- `environment`: Name of the conda environment to activate

**Behavior:**

- Sources the conda activation script
- Activates the specified environment

**Requirements:**

- Anaconda3 installed in `${HOME}/anaconda3`
- Target environment must exist

**Example:**

```bash
conda_activate "data-science"
conda_activate "get-aws-resources"
```

---

### get-aws-profile.sh

#### `get_aws_profile()`

Retrieves AWS CLI profile through interactive selection or automatic detection.

**Parameters:** None

**Returns:**

- Selected AWS profile name (stdout)

**Behavior:**

- If 0 profiles: Prints error and exits (code 1)
- If 1 profile: Returns that profile automatically
- If multiple profiles: Presents fzf interactive menu for selection

**Requirements:**

- AWS CLI configured with profiles in `~/.aws/config`
- `fzf` (for multi-profile selection)

**Example:**

```bash
profile=$(get_aws_profile)
aws --profile "$profile" s3 ls
```

---

### log.sh

#### `log(level, message)`

Prints formatted log messages with ISO8601 timestamps and color-coded severity levels.

**Parameters:**

- `level`: Log level - "debug", "info", "warning"/"warn", or "error"
- `message`: Log message text

**Behavior:**

- Outputs: `<ISO8601-timestamp> [LEVEL]: <message>`
- Color coding:
  - `debug`: Blue
  - `info`: Green
  - `warning`/`warn`: Yellow
  - `error`: Red
- UTC timezone used for timestamps

**Example:**

```bash
log info "Starting process..."
log warn "Configuration file not found, using defaults"
log error "Connection failed"
log debug "Variable x = ${x}"
```

**Output:**

```sh
2026-02-01T10:15:23 UTC +00:00 [INFO]: Starting process...
2026-02-01T10:15:24 UTC +00:00 [WARNING]: Configuration file not found, using defaults
2026-02-01T10:15:25 UTC +00:00 [ERROR]: Connection failed
```

---

### print-as-table.sh

#### `print_as_table(filename, column1, column2, ...)`

Formats and displays CSV file content as an aligned table.

**Parameters:**

- `filename`: Path to CSV file
- `column1, column2, ...`: Column header names

**Behavior:**

- Removes quotes from CSV fields
- Converts commas to spaces
- Aligns columns for readability
- Adds blank lines before and after for spacing

**Example:**

```bash
print_as_table "volumes.csv" "VOLUME ID" "SIZE" "STATE"
print_as_table "users.csv" "USERNAME" "EMAIL" "ROLE"
```

---

### print-color.sh

#### `print_color(color, message)`

Prints colored text to the console using ANSI escape codes.

**Parameters:**

- `color`: Color name - "green", "red", "blue", "purple", "yellow", "white"
- `message`: Text to display

**Behavior:**

- Applies color to message
- Resets color after message
- Falls back to white/default for unknown colors

**Example:**

```bash
print_color "green" "Success!"
print_color "red" "Error occurred"
print_color "blue" "Processing..."
print_color "yellow" "Warning: deprecated feature"
```

---

### test-https.sh

#### `test_https(address)`

Tests whether a server accepts HTTPS connections.

**Parameters:**

- `address`: Server address (IP or FQDN)

**Returns:**

- `"true"`: HTTPS connection successful
- `"false"`: HTTPS connection failed

**Behavior:**

- Uses `wget --spider` to test connection
- Suppresses all output
- Returns result as string

**Example:**

```bash
if [[ $(test_https "example.com") == "true" ]]; then
  protocol="https"
else
  protocol="http"
fi
```

---

### tz-to-age.awk

AWK script for converting ISO8601 timestamps to human-readable age format (e.g., "5d3h").

**Usage:**

```bash
# Process a specific column (column 3 in this example)
awk -f tz-to-age.awk -v col=3 -v now=$(date +%s) input.txt
```

**Variables:**

- `col`: Column number containing timestamp
- `now`: Current Unix timestamp

**Behavior:**

- Detects ISO8601 timestamps (format: `YYYY-MM-DDTHH:MM:SSZ`)
- Converts to "days+hours" format (e.g., "5d3h")
- Passes through non-timestamp data unchanged

**Example:**

```bash
# Input: "vol-123  2026-01-25T10:00:00Z  available"
# Output: "vol-123  7d0h  available"
```

---

### wait-message.sh

#### `wait_message(color, duration, message)`

Displays an animated rotating spinner with colored message for a specified duration.

**Parameters:**

- `color`: Color name - "green", "red", "blue", "purple", "yellow", "white"
- `duration`: Duration in deciseconds (tenths of a second)
- `message`: Text to display alongside spinner

**Behavior:**

- Shows rotating animation: `\|/-`
- Updates every 0.1 seconds
- Uses carriage return for in-place updates

**Example:**

```bash
wait_message "blue" 50 "Loading..."      # 5 seconds
wait_message "yellow" 100 "Processing..."  # 10 seconds
```

**Output:**

```sh
/ Loading...  (animates through \ | / - characters)
```

---

## Dependencies

Most functions require:

- Bash 4.0+
- GNU coreutils (date, awk, sed, grep, etc.)

Specific requirements:

- **check-ports.sh**: firewalld
- **check-service-status.sh**: systemd
- **conda-activate.sh**: Anaconda/Miniconda
- **get-aws-profile.sh**: AWS CLI, fzf
- **test-https.sh**: wget
- **tz-to-age.awk**: gawk (GNU awk)

## Integration Pattern

All main scripts use this pattern to load libraries:

```bash
get_lib_path() {
  local lib_path
  lib_path=$(cd "$(dirname "$0")" && echo "${PWD}" | sed 's/\/[^/]*$/\/lib/')
  echo "${lib_path}"
}

lib_path=$(get_lib_path)

# shellcheck source=/dev/null
source "${lib_path}/print-color.sh"
source "${lib_path}/log.sh"
source "${lib_path}/check-utils.sh"
```

This allows scripts to be run from any directory while correctly locating the library functions.
