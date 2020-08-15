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

# Creating the ./teamspeak directory if non-existent
if [ ! -d "$config_dir" ]; then
  mkdir -p "$config_dir"
fi

declare -r config_file="$config_dir/teamspeak.config"

if [[ ! -f "$config_file" ]]; then
  # Creating the teamspeak.config file
  touch "$config_file"
  # Appending default config to teamspeak.config
  {
    echo "#!/bin/bash"
    echo "export teamspeak_dir=\"/opt/teamspeak-server\""
    echo "export service_file=\"/etc/systemd/system/teamspeak.service\""
    echo "export zip_file_name=\"TeamSpeak.zip\""
  } >>"$config_file"
fi

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
