# AWS & System Health Snapshot Script

This is a simple Bash script designed to run on a Linux server (e.g., an EC2 instance) to provide a quick, high-level snapshot of its own system health and the status of key resources in its AWS account.

It is designed for quick, "at-a-glance" reporting, perfect for running manually during a debug session.

## Features

* **AWS S3:** Reports the total count of S3 buckets in the account.
* **AWS EC2:** Reports the total count of *running* EC2 instances.
* **System Processes:** Captures a one-time "snapshot" of all running processes, sorted by CPU usage.
* **Network:** Lists all active (listening) TCP/UDP network ports and the services using them.

## Prerequisites

Before running this script, you **must** have the following installed and configured:

1.  **`aws-cli`**: The script will not work without the AWS Command Line Interface.
2.  **`jq`**: This script uses `jq` to parse the JSON output from the EC2 command. Install it:
    ```bash
    sudo dnf install jq
    ```
3.  **IAM Permissions**: The server (or user) running this script **must** have an IAM role or credentials with at least the following permissions:
    * `s3:ListAllMyBuckets` (for `aws s3 ls`)
    * `ec2:DescribeInstances` (for `aws ec2 describe-instances`)

## Usage

1.  Clone the repository:
    ```bash
    git clone [https://github.com/Z9CK-MJ/AWS-resource_tracker.git](https://github.com/Z9CK-MJ/AWS-resource_tracker.git)
    cd AWS-resource_tracker
    ```

2.  Make the script executable:
    ```bash
    chmod +x tracker.sh
    ```

3.  Run the script with `sudo`:
    (This is required for the `ss` command to see all process names).
    ```bash
    sudo ./tracker.sh
    ```
## Script Breakdown

This script is built to be simple, but it uses several core DevOps patterns.

### Strict Mode: `set -euo pipefail`

This is the most important part of the script. It makes it safe.

* `set -e`: **Exit on Error.** If any command fails (like `aws` not having credentials), the script stops immediately.
* `set -u`: **Exit on Unset.** If you use a variable that doesn't exist (e.g., `$USERNAM` instead of `$USERNAME`), the script stops. This prevents bugs.
* `set -o pipefail`: **Fail on Pipe Errors.** If any command in a pipeline (`|`) fails, the *entire pipeline* fails. This is critical for the `aws ... | jq ... | wc -l` command.

### Command 1: S3 Buckets
* `aws s3 ls | wc -l` : Lists all S3 bucket names, one per line then ipes that list to wc -l (word count - lines), which counts the number of lines to give you a total.

### Command 2: EC2 Instances
* `aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" | \ jq -r '.Reservations[].Instances[].InstanceId' | \ wc -l`: Gets a massive JSON file of all instances that are "running" then Pipes the JSON to jq.-r: "Raw output," so it gives you clean text, not strings with quotes.'.Reservations[].Instances[].InstanceId': This is the jq filter. It navigates the complex JSON to pull out only the Instance IDs, one per line.

### Command 3: System Processes
* `top -b -n 1`: the standard real-time process viewer then batch mode makes the top command to run in a non-interactive way so its output can be captured then number 1 tells the top command to run for one iteration and then quit giving us the single stable snapshot

### Command 4: Network Ports
* `sudo ss -tulpn`: uses sudo to see all process names, ss (socket statistics) to show TCP and UDP sockets, and the flags -lpn to list only listening ports, show their process, and display them as numeric.
