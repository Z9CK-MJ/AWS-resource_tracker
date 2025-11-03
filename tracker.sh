#######################
# Author: Mohd Zeeshan
# Date: 11/2025
# Version: 1
#######################

#!/bin/bash
set -e # exit on error
set -o # exits on any pipefail
set -u # exits the script on any variable being undefined
#set -x # prints eaach command in the terminal before it's executed (uncomment by pressing home key to run this command)

aws s3 ls | wc -l
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" | \jq-r '.Reservations[].Instances[].InstanceId' | \wc -l
top -b -n 1
sudo ss tulpn

