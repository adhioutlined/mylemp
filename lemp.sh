#!/bin/bash

# Text Colour
RED="\033[01;31m"    # Issues/Errors
GREEN="\033[01;32m"  # Success
YELLOW="\033[01;33m" # Warnings/Information
BLUE="\033[01;34m"   # Heading
BOLD="\033[01;01m"   # Highlight
RESET="\033[00m"     # Normal

# Check if running as root
if [[ "${EUID}" -ne 0 ]]; then
    echo -e "${RED}[!]${RESET} This script must be ${RED}run as root${RESET}" 1>&2
    exit 1
fi

# Variables
DEF_HOSTNAME=$(echo $(hostname).loc)

#nginx
NGINX_MAX_BODY_SIZE="64M"

#php.ini
PHP_MEMORY_LIMIT="128M"
PHP_UPLOAD_MAX_FILESIZE="5M"
PHP_POST_MAX_SIZE="5M"
PHP_MAX_EXECUTION_TIME="300"
PHP_MAX_INPUT_TIME="300"
PHP_MAX_FILE_UPLOAD="100"

#php-fpm
FPM_MAX_CHILDREN="50"
FPM_START_SERVERS="20"
FPM_MIN_SPARE_SERVERS="10"
FPM_MAX_SPARE_SERVERS="20"
FPM_MAX_REQUESTS="500"

# Default Variables
# SERVER_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
# PHP_FPM_POOL_DIR="/etc/php/${PHP_VERSION}/fpm/pool.d"
# PHP_INI="/etc/php/${PHP_VERSION}/fpm/php.ini"
NGINX_SITEAVAILABLE_DIR="/etc/nginx/sites-available"
NGINX_SITEENABLE_DIR="/etc/nginx/sites-enabled"
LOG_FILE="install_log.txt"

check_cmd_status() {
    if [[ "$?" -ne 0 ]]; then
        echo -e "\n"
        echo -e "${RED}[!]${RESET} There was an ${RED}issue on $1 ${RESET}" 1>&2
        echo -e "${YELLOW}[i]${RESET} Check log file: ${LOG_FILE}" 1>&2
        exit 1
    fi
}

# Start Server Installation
echo -e "\n"
echo -e "${GREEN}[*]${RESET} Start Installation.."
sleep 3s


# Keep operating system up to date
echo -e "${GREEN}[*]${RESET} Update system.."

apt -y update &> ${LOG_FILE}
check_cmd_status "update system.."

apt -y upgrade >> ${LOG_FILE} 2>&1
check_cmd_status "upgrade system.."

# test
# echo $DEF_HOSTNAME