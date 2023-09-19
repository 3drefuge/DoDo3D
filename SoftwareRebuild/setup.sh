#!/bin/bash

setup="setup.dodo3d"

remove_s() {
  local str="$1"
  if [[ "$str" == *s ]]; then
    str="${str::-1}"
  fi
  echo "$str"
}

save_array() {
  declare -n array="$1"
  echo "declare -A machines=(" > "$setup"
  for key in "${!array[@]}"; do
    echo "  [\"$key\"]=\"${array[$key]}\"" >> "$setup"
  done
  echo ")" >> "$setup"
}

read -p "How many different groups of 3D printers do you have?: " num_groups; num_groups="${num_groups,,}"

declare -A machines
for ((i = 1; i <= num_groups; i++)); do
  read -p "Enter the name of machine group $i?: " group_name; group_name="${group_name,,}"
  group_name="$(remove_s "$group_name")"
  read -p "How many machines are in this group?: " num_group_machines; num_group_machines="${num_group_machines,,}"
  declare -A group
  group["name"]=$group_name
  group["num_groups"]=$num_group_machines
  machines["group$i"]="${group[@]}"
done
save_array machines

for key in "${!machines[@]}"; do
  echo "Machine Group $key:"
  eval "group=(${machines[$key]})"
  for sub_key in "${!group[@]}"; do
    echo "$sub_key: ${group[$sub_key]}"
  done
done

bash creation.sh