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
reprint_script_content=$(echo "$reprint_script_content" | grep -v '^#')
pidtune_script_content=$(echo "$pidtune_script_content" | grep -v '^#')

# Create an array to store unique machine names
unique_machine_names=()

# Iterate through the associative array values
for machine_group in "${!machines[@]}"; do
  machine_type="${machines[$machine_group]}"
  numeric_value="${machine_type%% *}"
  machine_name="${machine_type#* }s"
  create_folders "$machine_name"
  
  # Check if the machine_name is unique, and add it to the array if not already present
  if [[ ! " ${unique_machine_names[@]} " =~ " $machine_name " ]]; then
    unique_machine_names+=("$machine_name")
  fi

  for ((i = 1; i <= numeric_value; i++)); do
    folder_name="$machine_name/${machine_name%?}$i"
    create_folders "$folder_name"
    
    # Create "ON.vbs"
    on_script_content="Set WshShell = CreateObject(\"WScript.Shell\") : WshShell.Run \"cmd /c echo run.sh smarton $(basename "$folder_name") | nc.exe -w 1 -v 192.168.77.120 12345\", 0 : MsgBox \"Command OK!\", vbInformation, \"DoDo3D Commander v1.0\""
    create_machine_script "$folder_name" "$machine_name" "ON.vbs" "$on_script_content"

    # Create "OFF.vbs"
    off_script_content="Set WshShell = CreateObject(\"WScript.Shell\") : WshShell.Run \"cmd /c echo run.sh smartoff $(basename "$folder_name") | nc.exe -w 1 -v 192.168.77.120 12345\", 0 : MsgBox \"Command OK!\", vbInformation, \"DoDo3D Commander v1.0\""
    create_machine_script "$folder_name" "$machine_name" "OFF.vbs" "$off_script_content"

    # Create "CANCEL.vbs"
    cancel_script_content="Set WshShell = CreateObject(\"WScript.Shell\") : WshShell.Run \"cmd /c echo run.sh canceljob $(basename "$folder_name") | nc.exe -w 1 -v 192.168.77.120 12345\", 0 : MsgBox \"Command OK!\", vbInformation, \"DoDo3D Commander v1.0\""
    create_machine_script "$folder_name" "$machine_name" "CANCEL.vbs" "$cancel_script_content"

    # Create "UNLOAD.vbs"
    unload_script_content="Set WshShell = CreateObject(\"WScript.Shell\") : WshShell.Run \"cmd /c echo run.sh unload $(basename "$folder_name") | nc.exe -w 1 -v 192.168.77.120 12345\", 0 : MsgBox \"Command OK!\", vbInformation, \"DoDo3D Commander v1.0\""
    create_machine_script "$folder_name" "$machine_name" "UNLOAD.vbs" "$unload_script_content"

    # Create "REPRINT.vbs"
    reprint_script_content="Set WshShell = CreateObject(\"WScript.Shell\") : WshShell.Run \"cmd /c echo run.sh reprint $(basename "$folder_name") | nc.exe -w 1 -v 192.168.77.120 12345\", 0 : MsgBox \"Command OK!\", vbInformation, \"DoDo3D Commander v1.0\""
    create_machine_script "$folder_name" "$machine_name" "REPRINT.vbs" "$reprint_script_content"

    # Create "PIDTUNE.vbs"
    pidtune_script_content="Set WshShell = CreateObject(\"WScript.Shell\") : WshShell.Run \"cmd /c echo run.sh pidtune $(basename "$folder_name") | nc.exe -w 1 -v 192.168.77.120 12345\", 0 : MsgBox \"Command OK!\", vbInformation, \"DoDo3D Commander v1.0\""
    create_machine_script "$folder_name" "$machine_name" "PIDTUNE.vbs" "$pidtune_script_content"
  done
done

# Create .vbs files in unique machine_name folders
for unique_machine_name in "${unique_machine_names[@]}"; do
  folder_name="$unique_machine_name"
  
  # Create "ONall.vbs" in the root folder
  allon_script_content="Set WshShell = CreateObject(\"WScript.Shell\") : WshShell.Run \"cmd /c echo run.sh smarton ${unique_machine_name%"s"}ALL | nc.exe -w 1 -v 192.168.77.120 12345\", 0 : MsgBox \"Command OK!\", vbInformation, \"DoDo3D Commander v1.0\""
  create_machine_script "$folder_name" "$unique_machine_name" "ON.vbs" "$allon_script_content"

  # Create "OFFall.vbs" in the root folder
  alloff_script_content="Set WshShell = CreateObject(\"WScript.Shell\") : WshShell.Run \"cmd /c echo run.sh smartoff ${unique_machine_name%"s"}ALL | nc.exe -w 1 -v 192.168.77.120 12345\", 0 : MsgBox \"Command OK!\", vbInformation, \"DoDo3D Commander v1.0\""
  create_machine_script "$folder_name" "$unique_machine_name" "OFF.vbs" "$alloff_script_content"

  # Create "CANCELall.vbs"
  allcancel_script_content="Set WshShell = CreateObject(\"WScript.Shell\") : WshShell.Run \"cmd /c echo run.sh canceljob ${unique_machine_name%"s"}ALL | nc.exe -w 1 -v 192.168.77.120 12345\", 0 : MsgBox \"Command OK!\", vbInformation, \"DoDo3D Commander v1.0\""
  create_machine_script "$folder_name" "$unique_machine_name" "CANCEL.vbs" "$allcancel_script_content"

  # Create "UNLOADall.vbs"
  allunload_script_content="Set WshShell = CreateObject(\"WScript.Shell\") : WshShell.Run \"cmd /c echo run.sh unload ${unique_machine_name%"s"}ALL | nc.exe -w 1 -v 192.168.77.120 12345\", 0 : MsgBox \"Command OK!\", vbInformation, \"DoDo3D Commander v1.0\""
  create_machine_script "$folder_name" "$unique_machine_name" "UNLOAD.vbs" "$allunload_script_content"

  # Create "REPRINTall.vbs"
  allreprint_script_content="Set WshShell = CreateObject(\"WScript.Shell\") : WshShell.Run \"cmd /c echo run.sh reprint ${unique_machine_name%"s"}ALL | nc.exe -w 1 -v 192.168.77.120 12345\", 0 : MsgBox \"Command OK!\", vbInformation, \"DoDo3D Commander v1.0\""
  create_machine_script "$folder_name" "$unique_machine_name" "REPRINT.vbs" "$allreprint_script_content"

  # Create "PIDTUNEall.vbs"
  allpidtune_script_content="Set WshShell = CreateObject(\"WScript.Shell\") : WshShell.Run \"cmd /c echo run.sh pidtune ${unique_machine_name%"s"}ALL | nc.exe -w 1 -v 192.168.77.120 12345\", 0 : MsgBox \"Command OK!\", vbInformation, \"DoDo3D Commander v1.0\""
  create_machine_script "$folder_name" "$unique_machine_name" "PIDTUNE.vbs" "$allpidtune_script_content"
done
