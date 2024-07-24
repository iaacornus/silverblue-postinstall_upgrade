#!/usr/bin/env bash

# ---------------------------------
#
# Fedora Silverblue Post Install Script
# Copyright (c) 2024 James Aaron Erang <iaacornus@gmail.com>
#
# ---------------------------------


FAIL="\e[1;41m[ FAIL ]\e[0m"
INVALID="\e[1;41m[ INVALID ]\e[0m"
SUCCESS="\e[1;42m[ SUCCESS ]\e[0m"
INFO="\e[1;44m[ INFO ]\e[0m"
__USAGE="
Usage: bash setup.sh [OPTIONS]

Options:
    -h, --help                  Print this help message.
    -a, --all                   Apply all of the recommended modifications on the system.
    -f, --flatpak               Setup flatpak repository.
    -r, --rpmfusion             Setup RPMFusion repository.
    -c, --codecs                Install codecs.
    -d, --driver                Install appropriate drivers.
    -o, --optimize              Perform suggested system optimizations.
    -l, --laptop                Apply laptop recommendations.
    -n, --nvidia                Install proprietary NVidia drivers.
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

function setup_flatpak () {
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
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
