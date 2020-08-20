#!/bin/bash
function generate_config() {
  # Defining local variables (the "g" prefix is required to avoid conflicts)
  local g_arg g_config_file g_config_items=()

  # Function named arguments (-f for "config File" and -i for "config Item")
  while getopts ":f:i:" g_arg; do
    case ${g_arg} in
    f) g_config_file=${OPTARG} ;;
    i) g_config_items+=("${OPTARG}") ;;
    \?)
      echo "Usage: generate_config [-f -i]"
      return 1
      ;;
    esac
  done

  # Creating the config directory if non-existent
  if [ ! -d "$g_config_file" ]; then
    mkdir -p "$(dirname "$g_config_file")"
  fi

  # Creating the config file if non-existent and appending comments
  if [[ ! -f "$g_config_file" ]]; then
    touch "$g_config_file"
    {
      echo "#!/bin/bash"
      echo "# IMPORTANT: only change the value between the \"quotation marks\"."
    } >"$g_config_file"

    # Adding each config item specified by the "-i" argument
    for item in "${g_config_items[@]}"; do
      # Appending config item to file and wrapping value around quotation marks
      echo "export $item" | sed 's/=/=\"/; s/$/\"/' >>"$g_config_file"
    done
  fi
}
