#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"

# When switching between devices, it's possible to get hit with multiple
# concurrent events, some of which may occur before `scutil` picks up the
# changes, resulting in race conditions.
sleep 1

services=$(networksetup -listnetworkserviceorder)
device=$(scutil --nwi | awk '/Network interfaces:/ {print $3}')

icon="$ICON_NET_OFF"
color="$OFF"

if [ -n "$device" ]; then
  service=$(echo "$services" | sed -n "s/.*Hardware Port: \([^,]*\), Device: $device.*/\1/p")
  
  case $service in
  "iPhone USB")
    icon="$ICON_NET_USB"
    color="$ON"
    ;;
  "Thunderbolt Bridge")
    icon="$ICON_NET_THUNDERBOLT"
    color="$ON"
    ;;
  "Wi-Fi")
    airportnetwork=$(networksetup -getairportnetwork "$device")
    ssid=$(echo $airportnetwork | sed -n 's/Current Wi-Fi Network: \(.*\)/\1/p')

    if [[ $ssid == *iPhone* ]]; then
      icon="$ICON_NET_HOTSPOT"
      color="$ON"
    else
      wifi_status=$(networksetup -getairportpower "$device" | awk '{print $NF}')
      if [[ "$wifi_status" == "On" ]]; then
        RSSI=$(sudo wdutil info | awk '/^WIFI$/,/^BLUETOOTH$/ {if ($1=="RSSI") print $3}')
        if [ "$RSSI" -ge -50 ] && [ "$RSSI" -le -30 ]; then
          icon="$ICON_NET_WIFI_3" # High signal
        elif [ "$RSSI" -ge -70 ] && [ "$RSSI" -le -51 ]; then
          icon="$ICON_NET_WIFI_2" # Medium signal
        else
          icon="$ICON_NET_WIFI_1" # Low signal
        fi
        color="$ON"
      fi
    fi
    ;;

  esac
fi

props=(
  background.height=20
  icon.font="$ICOMOON:20"
  icon=$icon
  icon.color="$color"
)
sketchybar --set "$NAME" "${props[@]}"

if [ "$SENDER" = "mouse.clicked" ]; then
  open x-apple.systempreferences:com.apple.wifi-settings-extension
fi
