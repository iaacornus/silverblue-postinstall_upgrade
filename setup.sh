#!/usr/bin/env bash

# ---------------------------------
#
# Fedora Silverblue Post Install Script
# Copyright (c) James Aaron Erang <iaacornus.devel@gmail.com> 2024
#
# ---------------------------------


FAIL="\e[1;41m[ FAIL ]\e[0m"
INVALID="\e[1;41m[ INVALID ]\e[0m"
SUCCESS="\e[1;42m[ SUCCESS ]\e[0m"
INFO="\e[1;44m[ INFO ]\e[0m"
__USAGE="
Usage: bash setup.sh [OPTIONS]

Options:
    -h, --help              Print this help message.
    -a, --all               Apply all of the recommended modifications on the system.
    -f, --flatpak           Setup flatpak repository.
    -r, --rpmfusion         Setup RPMFusion repository.
    -c, --codecs            Install codecs.
    -d, --driver            Install appropriate drivers.
    -m, --msfonts           Install Micro\$oft fonts.
    -l, --laptop            Apply laptop recommendations.
    -o, --optimize          Perform suggested system optimizations.
    -n, --nvidia            Install proprietary NVidia drivers.
"

function setup_fail () {
    echo -e "$FAIL Installation failed for some reason."
    exit 1
}

function setup_success () {
    echo -e "$SUCCESS Installation successfully finished."
    exit 0
}

function print_help () {
    echo -e "$__USAGE"
    exit 0
}

function d_gnomesoftware () {
    gnome_software_dir="/etc/xdg/autostart/org.gnome.Software.desktop"

    if [[ -f $gnome_software_dir ]]; then
        echo -e "$INFO Disabling Gnome Software on startup."
        sudo rm /etc/xdg/autostart/org.gnome.Software.desktop
    else
        echo -e "$INFO Gnome Software already disabled on startup."
    fi
}

function setup_rpmfusion () {
    #! LIVE DO NOT FUCKING EXECUTE THIS FUNCTION
    declare -A rpmrepo=( [0]="Free" [1]="NonFree" [2]="Both" )
    echo -e "Select RPMFusion for install.\n"

    for key in "${!rpmrepo[@]}"; do
        echo -e "$key.) ${rpmrepo[$key]}"
    done

    read -sp "Input the number of the selected choice. " choice
    echo -e "\n$INFO Installing ${rpmrepo[$choice]}: "

    case "${rpmrepo[$choice]}" in
        "Free")
            rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm;;
        "NonFree")
            rpm-ostree install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm;;
        "Both")
            rpm-ostree install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm;;
        \?)
            echo -e "$INVALID Option not found.";;
    esac

}
