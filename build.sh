#!/bin/bash

set -euo pipefail

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

# Logger functions
log_info() {
    echo -e "${GREEN_BACK}${bold}  INFO  ${RESET}${bold}  $1${reset}"
}

log_error() {
    echo -e "${RED_BACK}${bold}  ERROR  ${RESET}${bold}  $1${reset}"
}

log_warn() {
    echo -e "${YELLOW_BACK}${bold}  WARN  ${RESET}${bold}  $1${reset}"
}

version="1.1.0"

# Init
CONFIG_FILE="config.conf"
BASE_DIR="${PWD}"
source "${BASE_DIR}/${CONFIG_FILE}"

# Check for root permissions
if [[ ${EUID} -ne 0 ]]; then
    log_error "Requires root permissions"
    exit 1
fi

echo -e "${cyan}--- StrawberryOS ISO Builder v${version} --- ${reset}"

# Installing host dependencies
echo -e "${green}
* ---------------------------- *
| Installing host dependencies |
* ---------------------------- * ${reset}
"
if [[ "${1:-}" == "--skip-apt" ]]; then
    log_info "Skipping host tool installation"
else
    log_info "Running 'apt update'"
    apt update

    log_info "Running 'apt upgrade -y'"
    apt upgrade -y

    log_info "Running 'apt install -y live-build gnupg2 binutils zstd ca-certificates'"
    apt install -y live-build gnupg2 binutils zstd ca-certificates
fi

# Preparing build
echo -e "${green}
* --------------- *
| Preparing build |
* --------------- * ${reset}
"

log_info "Removing old temp directory"
rm -rf tmp

log_info "Creating new temp directory"
mkdir -p "${BASE_DIR}/tmp/${ARCH}"
cd "${BASE_DIR}/tmp/${ARCH}" || exit

log_info "Copying new config files to it"
cp -r "${BASE_DIR}"/etc/* .
cp -f "${BASE_DIR}/${CONFIG_FILE}" .

log_info "Symlinking package lists"
ln -s "package-lists.${PACKAGE_LISTS_SUFFIX}" "config/package-lists"

# Live-Build Clean
echo -e "${green}
* ------------------ *
| [Live Build] Clean |
* ------------------ * ${reset}
"

log_info "Running 'lb clean'"
lb clean

# Live-Build Config
echo -e "${green}
* ---------------------- *
| [Live Build] Configure |
* ---------------------- * ${reset}
"

log_info "Running 'lb config'"
if ! lb config 2>&1 | while IFS= read -r line; do
    if [[ $line =~ ^W.* ]]; then
        log_warn "$line"
        log_warn "Warnings in this stage shouldn't be ignored. Exiting."
        exit 1
    else
        echo "$line"
    fi
done; then
    exit 1
fi

# Live-Build Build
echo -e "${green}
* ------------------ *
| [Live Build] Build |
* ------------------ * ${reset}
"

log_info "Running 'lb build'"
lb build

# Move Output to build dir
echo -e "${green}
* ------------------------------- *
| Move Output to Builds Directory |
* ------------------------------- * ${reset}
"

YYYYMMDD="$(date +%Y%m%d)"
OUTPUT_DIR="${BASE_DIR}/builds/${BUILD_ARCH}"
mkdir -p "${OUTPUT_DIR}"
FNAME="StrawberryOS-${VERSION}-${CHANNEL}.${YYYYMMDD}${OUTPUT_SUFFIX}"
mv "${BASE_DIR}/tmp/amd64/live-image-amd64.hybrid.iso" "${OUTPUT_DIR}/${FNAME}.iso"

cd "${OUTPUT_DIR}" || exit
cd "${BASE_DIR}" || exit

echo -e "${cyan}--- Finished --- ${reset}"