#!/bin/bash
# Current directory of the script
declare -r current_dir=$1
# Directory of the backup files
declare -r backup_dir=$2
# Directory of the config files
declare -r config_dir="$current_dir/teamspeak"

#-------------------------------------------------------------------------------
# CONFIGURATION FILE
#-------------------------------------------------------------------------------

# utils/generate_config.sh
# shellcheck disable=SC1090
source "$3/generate_config.sh" --source-only

declare -r config_file="$config_dir/teamspeak.config"

# Generating default config folder and file if non-existent
generate_config -f "$config_file" \
  -s teamspeak_dir="/opt/teamspeak-server" \
  -s service_file="/etc/systemd/system/teamspeak.service" \
  -s file_name="TeamSpeak"

declare teamspeak_dir
declare service_file
declare file_name

# shellcheck disable=SC1090
source "$config_file" --source-only

#-------------------------------------------------------------------------------
# BACKING UP FILES
#-------------------------------------------------------------------------------

# utils/file_encryption.sh
# shellcheck disable=SC1090
source "$3/file_encryption.sh" --source-only

# Directory of the temporary files
declare -r tmp_dir=$4

# Path of the backed up database
declare -r db_backup_path="$tmp_dir/ts3server.sqlitedb"
# Safely backing up the database via the special .backup function
sqlite3 "$teamspeak_dir/ts3server.sqlitedb" ".backup '$db_backup_path'"

# ../tg-backup.config
# shellcheck disable=SC1090
source "$5" --source only; declare -a gpg_recipients

# Zipping database, icons, license, ts3server.ini, query whitelist and service
encrypted_zip "$backup_dir/$file_name.zip" -r \
  "$db_backup_path" \
  "$teamspeak_dir/files" \
  "$teamspeak_dir/license" \
  "$teamspeak_dir/ts3server.ini" \
  "$teamspeak_dir/query_ip_whitelist.txt" \
  "$service_file" \
  \
  --gpg-recipients "${gpg_recipients[@]}"
