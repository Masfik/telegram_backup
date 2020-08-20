#!/bin/bash
# Current directory of the script
current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# Directory of the backup files
declare -r backup_dir=$1
# Directory of the config files
declare -r config_dir="$current_dir/teamspeak"

#-------------------------------------------------------------------------------
# CONFIGURATION FILE
#-------------------------------------------------------------------------------

# shellcheck source=utils/generate_config.sh
source "$2/generate_config.sh" --source-only

declare -r config_file="$config_dir/teamspeak.config"

# Generating default config folder and file if non-existent
generate_config -f "$config_file" \
  -i teamspeak_dir="/opt/teamspeak-server" \
  -i service_file="/etc/systemd/system/teamspeak.service" \
  -i zip_file_name="TeamSpeak.zip"

declare teamspeak_dir
declare service_file
declare zip_file_name

# shellcheck source=teamspeak/teamspeak.config
source "$config_file"

#-------------------------------------------------------------------------------
# BACKING UP FILES
#-------------------------------------------------------------------------------

# Path of the backed up database
declare -r db_backup_path="$config_dir/ts3server.sqlitedb"
# Safely backing up the database via the special .backup function
sqlite3 "$teamspeak_dir/ts3server.sqlitedb" ".backup '$db_backup_path'"

# Zipping the database and icons
zip -r "$backup_dir/$zip_file_name" \
  "$db_backup_path" \
  "$teamspeak_dir/files" \
  "$service_file"
