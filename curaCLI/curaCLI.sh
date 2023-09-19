#!/bin/bash
# MUST REMOVE fdmextruder.def.json!


engine="/mnt/c/Program Files/UltiMaker Cura 5.4.0/CuraEngine.exe"
resource="C:/Program Files/UltiMaker Cura 5.4.0/share/cura/resources/definitions/fdmprinter.def.json"
input="C:/Users/Zeke/Desktop/test.stl"
output="C:/Users/Zeke/Desktop/test.gcode"
newoutput="/mnt/c/Users/Zeke/Desktop/test.gcode"
source arrays.sh

#process() {
#  local array_name="$1"
#  declare -n current_array="$array_name"
#  local temp_result=""
#  for key in "${!current_array[@]}"; do
#    local value="${current_array[$key]}"
#    if [ -n "$value" ]; then
#      temp_result="$temp_result -s $key=$value"
#    fi
#  done
#  result="${result}${temp_result}"
#}

process() {
  local array_name="$1"
  declare -n current_array="$array_name"
  local args=()  # Create an array to store arguments
  for key in "${!current_array[@]}"; do
    local value="${current_array[$key]}"
    if [ -n "$value" ]; then
      args+=("-s" "$key=$value")  # Add each argument as separate elements in the array
    fi
  done
  result="${result} ${args[*]}"  # Join the array into a single string
}




if [ "$1" = "hornet" ]; then
  #walls["min_wall_line_width"]="0.25"
  quality["machine_nozzle_size"]="0.3"
  quality["line_width"]="0.35"
  quality["wall_line_width_x"]="0.4"
  quality["infill_line_width"]="0.4"
  machine["machine_width"]="220"
  machine["machine_depth"]="220"
  machine["machine_height"]="250"
  command_line["center_object"]="true"
  #command_line["mesh_position_z"]="0"
  command_line["mesh_position_z"]="-0.5"
  material["material_print_temperature"]="215"
  material["material_print_temperature_layer_0"]="220"
  #my_var="M140 S${material["material_bed_temperature_layer_0"]}"$'\n'"M104 S${material["material_print_temperature_layer_0"]}"$'\n'"G28XY"$'\n'"G1 X10 Y2.5 Z0.25 F4000"$'\n'"G28Z"$'\n'"M190 S${material["material_bed_temperature_layer_0"]}"$'\n'"M104 S${material["material_print_temperature_layer_0"]}"
  infill["min_infill_area"]="65"
  infill["infill_line_distance"]="8"
fi

if [ "$1" = "lunar" ]; then
  #walls["min_wall_line_width"]="0.25"
  quality["machine_nozzle_size"]="0.4"
  quality["line_width"]="0.45"
  quality["wall_line_width_x"]="0.5"
  quality["infill_line_width"]="0.5"
  machine["machine_width"]="255"
  machine["machine_depth"]="255"
  machine["machine_height"]="250"
  command_line["center_object"]="true"
  #command_line["mesh_position_z"]="0"
  #command_line["mesh_position_z"]="-0.5"
  material["material_print_temperature"]="220"
  material["material_print_temperature_layer_0"]="230"
fi

#result="${result#}"



array_names=("machine" "quality" "walls" "top_bottom" "infill" "material" "speed" "travel" "cooling" "support" "adhesion" "dual" "meshfix" "special" "experimental" "command_line")

for array_name in "${array_names[@]}"; do
  process "$array_name"
done

 my_var=$(cat <<END
M140 S${material["material_bed_temperature_layer_0"]}
M104 S${material["material_print_temperature_layer_0"]}
G28XY
ADDSKIRTLOCATION
G28Z
M190 S${material["material_bed_temperature_layer_0"]}
M104 S${material["material_print_temperature_layer_0"]}
END
)

"$engine" slice -j "$resource" $result -l "$input" -o "$output"
sleep 2
sed -i '1,20d' test.gcode
{ echo "$my_var"; cat "$newoutput" | sed '/^$/d'; } > "/mnt/c/Users/Zeke/Desktop/temp" && mv "/mnt/c/Users/Zeke/Desktop/temp" "$newoutput"

echo You are Finished!!!

startpoint=$(grep -A 1 -m 1 'M107' test.gcode | tail -n 1 | sed 's/Z0.2/Z0.05/')
echo $startpoint
sed -i -e "/ADDSKIRTLOCATION/c$startpoint" -e '10d' test.gcode
