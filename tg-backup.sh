#!/bin/bash
#-------------------------------------------------------------------------------
# IMPORTANT! BEFORE STARTING THIS SCRIPT:
# 1) Define environment variables for $BOT_TOKEN and $CHAT_ID
# 2) Make sure that the thumbnails match the name of the zip files that will be
#    put into the ./backup-files directory.
#    E.g. ./backup-files/Caddy.zip will need ./thumbnails/Caddy.jpg to function
# 3) ...
#-------------------------------------------------------------------------------

# Disable Telegram notification
disable_notification=true
# Telegram endpoint
declare -r telegram="https://api.telegram.org/bot$BOT_TOKEN"
# Current directory of the script
current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Creating the ./backup-scripts directory if non-existent
if [ ! -d "$current_dir"/backup-scripts ]; then
  mkdir -p "$current_dir"/backup-scripts
fi

# Creating the ./backup-files directory if non-existent
if [ ! -d "$current_dir"/backup-files ]; then
  mkdir -p "$current_dir"/backup-files
fi

# Creating the ./thumbnails directory if non-existent
if [ ! -d "$current_dir"/thumbnails ]; then
  mkdir -p "$current_dir"/thumbnails
fi

#-------------------------------------------------------------------------------
# RUNNING ALL BACKUP SCRIPTS INSIDE THE ./backup-scripts DIRECTORY
# 1) All scripts must end with the .sh extension
# 2) All backed up files must be .zip archives and placed inside the
#    ./backup-files directory
# 3) ...
#-------------------------------------------------------------------------------

for script in "$current_dir"/backup-scripts/*.sh; do
  # Passing the backup-files directory and utils to all scripts
  bash "$script" \
    "$current_dir/backup-scripts" \
    "$current_dir/backup-files" \
    "$current_dir/utils" -H || break
done

#-------------------------------------------------------------------------------
# SENDING ALL ZIP FILES INSIDE THE ./backup-files DIRECTORY TO TELEGRAM
#-------------------------------------------------------------------------------

echo "[Backup] Uploading files..."

for file in "$current_dir"/backup-files/*.zip; do
  # Only continue the loop if there are files inside the directory
  test -f "$file" || continue

  # Removing the .zip extension from the file name
  file_name=${file%.zip}
  # Removing the full path from the file name
  file_name=${file_name##*/}

  # Thumbnail of the file
  thumbnail="$current_dir/thumbnails/$file_name.jpg"

  # Sending the file to the Telegram chat
  if
    curl "$telegram/sendDocument" -sS -f --output /dev/null \
      -F chat_id="$CHAT_ID" \
      -F document=@"$file" \
      -F caption="#$file_name: $(date +%d/%m/%Y)" \
      -F thumb=@"$thumbnail" \
      -F disable_notification=$disable_notification \
      -H "Content-Type: multipart/form-data"
  then
    echo "[Backup] Uploaded $file_name.zip successfully."
    rm "$file" # ← Removing the zip file
  else
    # Error message in red
    echo -e "\033[31m[Backup] ERROR: Failed to upload $file"
  fi
done

# Sticker's file ID (this is a horizontal line sticker)
hr="CAACAgQAAxkBAAOiXzaxbu7yfw5_eX_lmfCV5XpeIOAAAs4FAALWbsAGNaMYJvmpBkMaBA"

# Send a separation sticker (<hr>)
curl "$telegram/sendSticker" -sS \
  -F chat_id="$CHAT_ID" \
  -F sticker="$hr" \
  -F disable_notification=$disable_notification

# Printing a message between two NEWLINEs
printf "\n%s\n" "[Backup] Done. It took $SECONDS seconds to backup everything."
