#!/bin/bash

# Source the setup file to import the associative array
source "setup.dodo3d"

# Function to create folders
create_folders() {
  local folder_name="$1"
  [ ! -d "$folder_name" ] && mkdir -p "$folder_name"
}

# Function to create a machine-specific script in a folder
create_machine_script() {
  local folder_name="$1"
  local machine_name="$2"
  local script_suffix="$3"
  local script_content="$4"  # Pass the script content as an argument

  local script_name="$(basename "$folder_name")${script_suffix}"

  # Create the script file with the specified content
  echo -e "$script_content" > "$folder_name/$script_name"

  # Make the script executable
  chmod +x "$folder_name/$script_name"
}

# Remove comments from the on_script_content, off_script_content, and cancel_script_content
on_script_content=$(echo "$on_script_content" | grep -v '^#')
off_script_content=$(echo "$off_script_content" | grep -v '^#')
cancel_script_content=$(echo "$cancel_script_content" | grep -v '^#')
unload_script_content=$(echo "$unload_script_content" | grep -v '^#')
reprint_script_content=$(echo "$unload_script_content" | grep -v '^#')

# Iterate through the associative array values
for machine_group in "${!machines[@]}"; do
  machine_type="${machines[$machine_group]}"
  numeric_value="${machine_type%% *}"
  machine_name="${machine_type#* }s"
  create_folders "$machine_name"
  for ((i = 1; i <= numeric_value; i++)); do
    folder_name="$machine_name/${machine_name%?}$i"
    create_folders "$folder_name"
    
    # Create "ON.sh" with specific content
    on_script_content="#!/bin/bash\necho \"run.sh smarton $(basename "$folder_name")\" | timeout 0.1 nc -v 192.168.77.120 12345"
    create_machine_script "$folder_name" "$machine_name" "ON.sh" "$on_script_content"

    # Create "OFF.sh" with different content
    off_script_content="#!/bin/bash\necho \"run.sh smartoff $(basename "$folder_name")\" | timeout 0.1 nc -v 192.168.77.120 12345"
    create_machine_script "$folder_name" "$machine_name" "OFF.sh" "$off_script_content"

    # Create "CANCEL.sh" with "cancelJOB" content
    cancel_script_content="#!/bin/bash\necho \"run.sh canceljob $(basename "$folder_name")\" | timeout 0.1 nc -v 192.168.77.120 12345"
    create_machine_script "$folder_name" "$machine_name" "CANCEL.sh" "$cancel_script_content"

    # Create "UNLOAD.sh" with "unload" content
    unload_script_content="#!/bin/bash\necho \"run.sh unload $(basename "$folder_name")\" | timeout 0.1 nc -v 192.168.77.120 12345"
    create_machine_script "$folder_name" "$machine_name" "UNLOAD.sh" "$unload_script_content"

    # Create "REPRINT.sh" with "unload" content
    reprint_script_content="#!/bin/bash\necho \"run.sh reprint $(basename "$folder_name")\" | timeout 0.1 nc -v 192.168.77.120 12345"
    create_machine_script "$folder_name" "$machine_name" "REPRINT.sh" "$reprint_script_content"
  done
done
