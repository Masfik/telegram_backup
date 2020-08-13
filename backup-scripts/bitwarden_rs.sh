#!/bin/bash
# Current directory of the script
current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# Directory of the backup files
backup_dir=$1
# Directory of the config files
config_dir="$current_dir/bitwarden_rs"

#-------------------------------------------------------------------------------
# CONFIGURATION FILE
#-------------------------------------------------------------------------------

# Creating the ./bitwarden directory if non-existent
if [ ! -d "$config_dir" ]; then
  mkdir -p "$config_dir"
fi

config_file="$config_dir/bitwarden.config"

if [[ ! -f "$config_file" ]]; then
  # Creating the bitwarden.config file
  touch "$config_file"
  # Appending default config to bitwarden.config
  {
    echo "#!/bin/bash"
    echo "export bitwarden_dir=\"/root/bw-data\""
    echp "export service_file=\"/etc/systemd/system/bitwarden.service\""
    echo "export zip_file_name=\"Bitwarden.zip\""
  } >>"$config_file"
fi

declare bitwarden_dir
declare service_file
declare zip_file_name

# shellcheck source=bitwarden/bitwarden.config
source "$config_file"

#-------------------------------------------------------------------------------
# BACKING UP FILES
#-------------------------------------------------------------------------------

# Path of the backed up database
db_backup_path="$config_dir/db.sqlite3"
# Safely backing up the database via the special .backup function
sqlite3 "$bitwarden_dir/db.sqlite3" ".backup '$db_backup_path'"

# Zipping the database
zip -r "$backup_dir/$zip_file_name" \
  "$db_backup_path" \
  "$bitwarden_dir/attachments" \
  "$service_file"
