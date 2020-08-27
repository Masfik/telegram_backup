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

# shellcheck source=utils/generate_config.sh
source "$3/generate_config.sh" --source-only

declare -r config_file="$config_dir/teamspeak.config"

# Generating default config folder and file if non-existent
generate_config -f "$config_file" \
  -s teamspeak_dir="/opt/teamspeak-server" \
  -s service_file="/etc/systemd/system/teamspeak.service" \
  -s zip_file_name="TeamSpeak.zip"

declare teamspeak_dir
declare service_file
declare zip_file_name

# shellcheck source=teamspeak/teamspeak.config
source "$config_file"

#-------------------------------------------------------------------------------
# BACKING UP FILES
#-------------------------------------------------------------------------------

# Directory of the temporary files
declare -r tmp_dir=$4

# Path of the backed up database
declare -r db_backup_path="$tmp_dir/ts3server.sqlitedb"
# Safely backing up the database via the special .backup function
sqlite3 "$teamspeak_dir/ts3server.sqlitedb" ".backup '$db_backup_path'"

# Zipping database, icons, license, ts3server.ini, query whitelist and service
zip -r "$backup_dir/$zip_file_name" \
  "$db_backup_path" \
  "$teamspeak_dir/files" \
  "$teamspeak_dir/license" \
  "$teamspeak_dir/ts3server.ini" \
  "$teamspeak_dir/query_ip_whitelist.txt" \
  "$service_file"
