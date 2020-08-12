#!/bin/bash
# Current directory of the script
current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# Directory of the backup files
backup_dir=$1
# Directory of the config files
config_dir="$current_dir/caddy"

#-------------------------------------------------------------------------------
# CONFIGURATION FILE
#-------------------------------------------------------------------------------

# Creating the ./caddy directory if non-existent
if [ ! -d "$config_dir" ]; then
  mkdir -p "$config_dir"
fi

config_file="$config_dir/caddy.config"

# Generating config file if non-existent
if [[ ! -f "$config_file" ]]; then
  # Creating the caddy.config file
  touch "$config_file"
  # Appending default config to caddy.config
  {
    echo "#!/bin/bash"
    echo "export caddyfile_dir=\"/etc/caddy/Caddyfile\""
    echo "export zip_file_name=\"Caddy.zip\""
  } >>"$config_file"
fi

# Declaring variables to be sourced later ↓
declare caddyfile_dir
declare zip_file_name

# shellcheck source=caddy/caddy.config
source "$config_file"

#-------------------------------------------------------------------------------
# BACKING UP FILES
#-------------------------------------------------------------------------------

# Path of the checksum file
checksum_file="$current_dir/caddy/checksum_caddy"

# Creating the checksum file if non-existent
touch "$checksum_file"
# Reading the saved checksum of the Caddyfile
previous_checksum=$(head -n 1 "$checksum_file")
# New checksum of the file to verify changes
new_checksum=$(sha256sum "$caddyfile_dir")

if [[ "$previous_checksum" == "$new_checksum" ]]; then
  echo "[Caddy] No changes detected."
else
  # Saving the new checksum to the file
  echo "$new_checksum" >"$checksum_file"
  # Zipping the Caddyfile config
  zip "$backup_dir/$zip_file_name" "$caddyfile_dir"
fi
