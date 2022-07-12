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
# HOSTNAME=$(hostname)
DEF_HOSTNAME=$(echo $(hostname).loc)

# test
echo $DEF_HOSTNAME