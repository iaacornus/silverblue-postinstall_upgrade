#!/usr/bin/env bash

battery_level=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep 'percentage:' | awk '{ print $2 }' | sed 's/%//')
state=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep 'state:' | awk '{ print $2 }' | sed 's/%//')
if [[ "$state" == "charging" ]] && [[ battery_level -eq 55 ]]; then
    notify-send "Battery" "Threshold of 80% reached. Unplug the charger."
    paplay /usr/share/sounds/Yaru/stereo/complete.oga

    while true; do # to avoid sending a lot of notifications and sound
        sleep 15 # prevent from running too often
        if [[ battery_level=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep 'percentage:' | awk '{ print $2 }' | sed 's/%//') -ne 55 ]]; then
            break
        fi
    done
fi
