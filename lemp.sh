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

# Install Nginx, Net Tools, Git, Zip
echo -e "${GREEN}[*]${RESET} Install nginx wget curl net-tools git unzip htop nano apache2-utils cron software-properties-common.."

apt -y install nginx wget curl net-tools git unzip htop nano apache2-utils cron software-properties-common >> ${LOG_FILE} 2>&1
check_cmd_status "install nginx wget curl net-tools git unzip htop nano apache2-utils cron software-properties-common.."

# Install PHP
echo -e "${GREEN}[*]${RESET} Install PHP.."

apt install -y php-{fpm,mysql,mbstring,xml,zip,soap,gd,curl,imagick,cli,bcmath,redis} >> ${LOG_FILE} 2>&1
check_cmd_status "install php.."

# Install PostgreSQL
echo -e "${GREEN}[*]${RESET} Install PostgreSQL.."

apt install -y postgresql postgresql-contrib >> ${LOG_FILE} 2>&1
check_cmd_status "install postgresql postgresql-contrib.."


# Create www Top Directory
echo -e "${GREEN}[*]${RESET} Create www Top Directory.."

mkdir /var/www/${DEF_HOSTNAME} >> ${LOG_FILE} 2>&1
check_cmd_status "Create www Top Directory.."

chmod 755 /var/www/${DEF_HOSTNAME} >> ${LOG_FILE} 2>&1
check_cmd_status "change mode www Top Directory.."

chown -R root:root /var/www/${DEF_HOSTNAME} >> ${LOG_FILE} 2>&1
check_cmd_status "Change ownership of www Top Directory.."

# Delete default nginx site
echo -e "${GREEN}[*]${RESET} Delete default nginx site.."

rm -f ${NGINX_SITEENABLE_DIR}/default >> ${LOG_FILE} 2>&1
check_cmd_status "Delete default nginx site.."

nginx -s reload >> ${LOG_FILE} 2>&1
check_cmd_status "reload nginx site.."

# Create nginx Top Directory config
echo -e "${GREEN}[*]${RESET} Create nginx Top Directory config.."

cat <<EOF > ${NGINX_SITEAVAILABLE_DIR}/${DEF_HOSTNAME}.conf
server {
  listen 80;
  listen [::]:80;
  server_name ${DEF_HOSTNAME};
  index index.html index.php;
  root /var/www/${DEF_HOSTNAME};
  location / {
    try_files \$uri \$uri/ =404;
  }
  location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php-fpm.sock;
    }
}
EOF

chmod 644 ${NGINX_SITEAVAILABLE_DIR}/${DEF_HOSTNAME}.conf >> ${LOG_FILE} 2>&1
check_cmd_status "change mode nginx Top Directory config.."

chown -R root:root ${NGINX_SITEAVAILABLE_DIR}/${DEF_HOSTNAME}.conf >> ${LOG_FILE} 2>&1
check_cmd_status "Change ownership of nginx Top Directory config.."


ln -sf ${NGINX_SITEAVAILABLE_DIR}/${DEF_HOSTNAME}.conf ${NGINX_SITEENABLE_DIR}/${DEF_HOSTNAME}.conf >> ${LOG_FILE} 2>&1
check_cmd_status "link enable nginx config.."

# Create index file
echo -e "${GREEN}[*]${RESET} Create index file.."

cat <<EOF > /var/www/${DEF_HOSTNAME}/index.php
<?php

// Show all information, defaults to INFO_ALL
phpinfo();

// Show just the module information.
// phpinfo(8) yields identical results.
phpinfo(INFO_MODULES);

?>
EOF

# check and reload nginx configuration
echo -e "${GREEN}[*]${RESET} check and reload nginx configuration.."

nginx -t >> ${LOG_FILE} 2>&1
check_cmd_status "check nginx configuration.."

systemctl reload nginx >> ${LOG_FILE} 2>&1
check_cmd_status "reload nginx service.."




# test
# echo $DEF_HOSTNAME
