#!/usr/bin/env bash

battery_level=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep 'percentage:' | awk '{ print $2 }' | sed 's/%//')
state=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep 'state:' | awk '{ print $2 }' | sed 's/%//')
if [[ "$state" == "discharging" ]] && [[ battery_level -eq 50 ]]; then
    notify-send "Battery" "Threshold of 80% reached. Unplug the charger."
    paplay /usr/share/sounds/Yaru/stereo/complete.oga

    while true; do # to avoid sending a lot of notifications and sound
        if [[ $(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep 'percentage:' | awk '{ print $2 }' | sed 's/%//') -lt 50 ]]; then
            break
        fi
        sleep 15 # prevent from running too often
    done
fi
