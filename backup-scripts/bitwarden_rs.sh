#!/bin/bash
# Current directory of the script
declare -r current_dir=$1
# Directory of the backup files
declare -r backup_dir=$2
# Directory of the config files
declare -r config_dir="$current_dir/bitwarden_rs"

#-------------------------------------------------------------------------------
# CONFIGURATION FILE
#-------------------------------------------------------------------------------

# shellcheck source=utils/generate_config.sh
source "$3/generate_config.sh" --source-only

declare -r config_file="$config_dir/bitwarden.config"

# Generating default config folder and file if non-existent
generate_config -f "$config_file" \
  -s bitwarden_dir="/root/bw-data" \
  -s service_file="/etc/systemd/system/bitwarden.service" \
  -s file_name="Bitwarden"

declare bitwarden_dir
declare service_file
declare file_name

# shellcheck source=bitwarden/bitwarden.config
source "$config_file" --source-only

#-------------------------------------------------------------------------------
# BACKING UP FILES
#-------------------------------------------------------------------------------

# shellcheck source=utils/file_encryption.sh
source "$3/file_encryption.sh" --source-only

# Directory of the temporary files
declare -r tmp_dir=$4

# Path of the backed up database
declare -r db_backup_path="$tmp_dir/db.sqlite3"
# Safely backing up the database via the special .backup function
sqlite3 "$bitwarden_dir/db.sqlite3" ".backup '$db_backup_path'"

# shellcheck source=../tg-backup.config
source "$5" --source only; declare -a gpg_recipients

# Zipping the database, attachments and service file
encrypted_zip "$backup_dir/$file_name.zip" -r \
  "$db_backup_path" \
  "$bitwarden_dir/attachments" \
  "$service_file" \
  \
  --gpg-recipients "${gpg_recipients[@]}"
