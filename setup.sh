#!/usr/bin/env bash

# ---------------------------------
#
# Fedora Silverblue Post Install Script
# Copyright (c) 2024 James Aaron Erang <iaacornus@gmail.com>
#
# ---------------------------------


FAIL="\e[1;41m[ FAIL ]\e[0m"
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

}

function main () {


}

function setup_flatpak () {

}

function setup_rpmfusion () {

}

function install_codecs () {

}

function install_nvidia () {


}


function sys_opts () {


}

function laptop_setup () {


}
