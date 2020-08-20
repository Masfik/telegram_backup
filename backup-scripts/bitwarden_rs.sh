#!/bin/bash
# Current directory of the script
current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# Directory of the backup files
declare -r backup_dir=$1
# Directory of the config files
declare -r config_dir="$current_dir/bitwarden_rs"

#-------------------------------------------------------------------------------
# CONFIGURATION FILE
#-------------------------------------------------------------------------------

# shellcheck source=utils/generate_config.sh
source "$2/generate_config.sh" --source-only

declare -r config_file="$config_dir/bitwarden.config"

# Generating default config folder and file if non-existent
generate_config -f "$config_file" \
  -i bitwarden_dir="/root/bw-data" \
  -i service_file="/etc/systemd/system/bitwarden.service" \
  -i zip_file_name="Bitwarden.zip"

declare bitwarden_dir
declare service_file
declare zip_file_name

# shellcheck source=bitwarden/bitwarden.config
source "$config_file"

#-------------------------------------------------------------------------------
# BACKING UP FILES
#-------------------------------------------------------------------------------

# Path of the backed up database
declare -r db_backup_path="$config_dir/db.sqlite3"
# Safely backing up the database via the special .backup function
sqlite3 "$bitwarden_dir/db.sqlite3" ".backup '$db_backup_path'"

# Zipping the database
zip -r "$backup_dir/$zip_file_name" \
  "$db_backup_path" \
  "$bitwarden_dir/attachments" \
  "$service_file"
