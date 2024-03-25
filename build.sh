#!/bin/bash

red=$(echo -e '\e[31m')
green=$(echo -e '\e[32m')
yellow=$(echo -e '\e[1;33m')
# underscore=$(echo -e '\033[4m')
cyan=$(echo -e '\033[1m\e[36m')
bold=$(echo -e '\033[1m')
reset=$(echo -e '\033(B\033[m')

version="1.0.0"

# Init
CONFIG_FILE="config.conf"
BASE_DIR="$PWD"
source "$BASE_DIR"/"$CONFIG_FILE"

# Check for root permissions
if [[ "$(id -u)" != 0 ]]; then
  echo -e "${red}[!] ${bold}Requires root permissions${reset}"
  exit 1
fi

echo -e "${cyan}--- StrawberryOS ISO Builder v${version} --- ${reset}"

# Installing host dependencies
echo -e "${green}
* ---------------------------- *
| Installing host dependencies |
* ---------------------------- * ${reset}
"
if [[ ! $1 == "--pass-apt" ]]; then
  echo -e "${green}=>${reset} $ apt update"
  apt update
  echo ""
  echo -e "${green}=>${reset} $ apt install -y live-build gnupg2 binutils zstd ca-certificates"
  apt install -y live-build gnupg2 binutils zstd ca-certificates
else
  echo -e "${yellow}=>${reset} Skipping host tool installation"
fi


# Preparing build
echo -e "${green}
* --------------- *
| Preparing build |
* --------------- * ${reset}
"

# Remove old tmp directroy
echo -e "${green}=>${reset} Removing old temp directory"
rm -rf tmp

# Create new tmp directory 
echo -e "${green}=>${reset} Creating new temp directory"
mkdir -p "$BASE_DIR/tmp/$ARCH"
cd "$BASE_DIR/tmp/$ARCH" || exit

# Copy new config
echo -e "${green}=>${reset} Copying new config files to it"
cp -r "$BASE_DIR"/etc/* .
cp -f "$BASE_DIR"/"$CONFIG_FILE" .

echo -e "${green}=>${reset} Symlinking package lists"
ln -s "package-lists.$PACKAGE_LISTS_SUFFIX" "config/package-lists"


# Live-Build Clean
echo -e "${green}
* ------------------ *
| [Live Build] Clean |
* ------------------ * ${reset}
"

echo -e "${green}=>${reset} $ lb clean"
lb clean


# Live-Build Config
echo -e "${green}
* ---------------------- *
| [Live Build] Configure |
* ---------------------- * ${reset}
"

echo -e "${green}=>${reset} $ lb config"
lb config


# Live-Build Config
echo -e "${green}
* ------------------ *
| [Live Build] Build |
* ------------------ * ${reset}
"

echo -e "${green}=>${reset} $ lb build"
lb build



# Move Output to build dir
echo -e "${green}
* ------------------------------- *
| Move Output to Builds Directory |
* ------------------------------- * ${reset}
"

YYYYMMDD="$(date +%Y%m%d)"
OUTPUT_DIR="$BASE_DIR/builds/$BUILD_ARCH"
mkdir -p "$OUTPUT_DIR"
FNAME="StrawberryOS-$VERSION-$CHANNEL.$YYYYMMDD$OUTPUT_SUFFIX"
mv $BASE_DIR/tmp/amd64/live-image-amd64.hybrid.iso "$OUTPUT_DIR/${FNAME}.iso"

cd $OUTPUT_DIR || exit
cd $BASE_DIR || exit