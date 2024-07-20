#!/bin/bash

red=$(echo -e '\e[31m')
green=$(echo -e '\e[32m')
yellow=$(echo -e '\e[1;33m')
# underscore=$(echo -e '\033[4m')
cyan=$(echo -e '\033[1m\e[36m')
bold=$(echo -e '\033[1m')
reset=$(echo -e '\033(B\033[m')

YELLOW_BACK="\e[43m"
GREEN_BACK="\e[42m"
RED_BACK="\e[41m"
RESET="\e[0m"


version="1.1.0"

# Init
CONFIG_FILE="config.conf"
BASE_DIR="$PWD"
source "$BASE_DIR"/"$CONFIG_FILE"

# Check for root permissions
if [[ "$(id -u)" != 0 ]]; then
  echo -e "${RED_BACK}${bold}   ERROR   ${RESET}${bold}  Requires root permissions${reset}"
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
  echo -e "${GREEN_BACK}${bold}  INFO  ${RESET}${bold}  Running '${cyan}apt update${reset}' ${RESET}"
  echo -e "${green}=>${reset} $ apt update"
  apt update
  echo ""
  echo -e "${GREEN_BACK}${bold}  INFO  ${RESET}${bold}  Running '${cyan}apt install -y live-build gnupg2 binutils zstd ca-certificates${reset}' ${RESET}"
  apt install -y live-build gnupg2 binutils zstd ca-certificates
else
  echo -e "${GREEN_BACK}${bold}  INFO  ${RESET}${bold}  Skipping host tool installation${RESET}"
fi


# Preparing build
echo -e "${green}
* --------------- *
| Preparing build |
* --------------- * ${reset}
"

# Remove old tmp directroy
echo -e "${GREEN_BACK}${bold}  INFO  ${RESET}${bold}  Removing old temp directory${RESET}"
rm -rf tmp

# Create new tmp directory 
echo -e "${GREEN_BACK}${bold}  INFO  ${RESET}${bold}  Creating new temp directory${RESET}"
mkdir -p "$BASE_DIR/tmp/$ARCH"
cd "$BASE_DIR/tmp/$ARCH" || exit

# Copy new config
echo -e "${GREEN_BACK}${bold}  INFO  ${RESET}${bold}  Copying new config files to it${RESET}"
cp -r "$BASE_DIR"/etc/* .
cp -f "$BASE_DIR"/"$CONFIG_FILE" .

echo -e "${GREEN_BACK}${bold}  INFO  ${RESET}${bold}  Symlinking package lists${RESET}"
ln -s "package-lists.$PACKAGE_LISTS_SUFFIX" "config/package-lists"


# Live-Build Clean
echo -e "${green}
* ------------------ *
| [Live Build] Clean |
* ------------------ * ${reset}
"

echo -e "${GREEN_BACK}${bold}  INFO  ${RESET}${bold}  Running '${cyan}lb clean${reset}' ${RESET}"
lb clean


# Live-Build Config
echo -e "${green}
* ---------------------- *
| [Live Build] Configure |
* ---------------------- * ${reset}
"

echo -e "${GREEN_BACK}${bold}  INFO  ${RESET}${bold}  Running '${cyan}lb config${reset}' ${RESET}"
lb config


# Live-Build Config
echo -e "${green}
* ------------------ *
| [Live Build] Build |
* ------------------ * ${reset}
"

echo -e "${GREEN_BACK}${bold}  INFO  ${RESET}${bold}  Running '${cyan}lb build${reset}' ${RESET}"
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

echo -e "${cyan}--- Finished --- ${reset}"