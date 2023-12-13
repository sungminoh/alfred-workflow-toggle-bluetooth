#!/bin/bash

shopt -s nocasematch

query="{query}"
[ $query = "{query}" ] && query="$@"

IFS=' '
connected_devices=$(system_profiler SPBluetoothDataType -json | jq -r '.SPBluetoothDataType[0].device_connected[] | with_entries(.value |= .device_address)' | jq --slurp)
disconnected_devices=$(system_profiler SPBluetoothDataType -json | jq -r '.SPBluetoothDataType[0].device_not_connected[] | with_entries(.value |= .device_address)' | jq --slurp)
devices=$(jq -s add <<<"$connected_devices $disconnected_devices")
connected_device_cnt=$(jq length <<< "$connected_devices")


echo '<?xml version="1.0"?>'
echo '<items>'

function print_items {
  if [[ $1 == 0 ]]; then
    target=$connected_devices
    action="Disconnect"
    icon="icon.png"
  elif [[ $1 == 1 ]]; then
    target=$disconnected_devices
    action="Connect"
    icon="disconnected.png"
  fi

  jq -c '.[]' <<< "$target" | while IPS= read -r device; do
    device_name=$(jq -r 'to_entries[].key' <<< "$device")
    mac_address=$(jq -r 'to_entries[].value' <<< "$device")

    if [[ -n $query && ! $device_name =~ $query ]]; then
      continue
    fi

    echo "
      <item uid=\"$device_name\" arg=\"${action}_${mac_address}\">
        <title>$device_name</title>
        <subtitle>$action $device_name</subtitle>
        <icon>$icon</icon>
      </item>
    "
  done
}

print_items 0
print_items 1

echo '</items>'

