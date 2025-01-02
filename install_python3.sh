#!/bin/bash

# This is the bash conversion of install.python3
####################################################################
#       WARNING DON'T EXECUTE THIS SCRIPT, IT'S NOT TESTED !       #
####################################################################

echo "####################################################################"
echo "#       WARNING DON'T EXECUTE THIS SCRIPT, IT'S NOT TESTED !       #"
echo "####################################################################"
sleep 10
# don't execute, exit now with error
# If you delete the next line, it's at your own risk.
exit 1

# portage de install.python3
# Vérifier que le script est exécuté avec Bash
if [ -z "$BASH_VERSION" ]; then
    echo "Ce script doit être exécuté avec Bash."
    exit 1
fi

# Déclarations des variables
rPath=$(dirname "$(realpath "$0")")
rPackages=("cpufrequtils" "iproute2" "python" "net-tools" "dirmngr" "gpg-agent" "software-properties-common" "libmaxminddb0" "libmaxminddb-dev" "mmdb-bin" "libcurl4" "libgeoip-dev" "libxslt1-dev" "libonig-dev" "e2fsprogs" "wget" "mariadb-server" "sysstat" "alsa-utils" "v4l-utils" "mcrypt" "certbot" "iptables-persistent" "libjpeg-dev" "libpng-dev" "php-ssh2" "xz-utils" "zip" "unzip")
rRemove=("mysql-server")
rMySQLCnf="# XUI
[client]
port = 3306

[mysqld_safe]
nice = 0

[mysqld]
user = mysql
port = 3306
basedir = /usr
datadir = /var/lib/mysql
tmpdir = /tmp
lc-messages-dir = /usr/share/mysql
skip-external-locking
skip-name-resolve
bind-address = *

key_buffer_size = 128M
myisam_sort_buffer_size = 4M
max_allowed_packet = 64M
..."

rConfig="; XUI Configuration
; -----------------
; Your username and password will be encrypted and
; saved to the 'credentials' file in this folder
; automatically.
;
; To change your username or password, modify BOTH
; below and XUI will read and re-encrypt them.

[XUI]
hostname = \"127.0.0.1\"
database = \"xui\"
port = 3306
server_id = 1
license = \"\"

[Encrypted]
username = \"%s\"
password = \"%s\""

# Fonction pour générer une chaîne aléatoire
generate() {
    local length=${1:-32}
    local chars="23456789abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ"
    local result=""
    for ((i = 0; i < length; i++)); do
        result+="${chars:RANDOM % ${#chars}:1}"
    done
    echo "$result"
}

# Fonction pour obtenir l'adresse IP
getIP() {
    local ip
    ip=$(ip route get 8.8.8.8 | awk '{print $7; exit}')
    echo "$ip"
}

# Fonction pour afficher du texte formaté
printc() {
    local rText="$1"
    local rColour="${2:-\e[34m}" # Bleu par défaut
    local rPadding="${3:-0}"
    local rLeft=$((30 - ${#rText} / 2))
    local rRight=$((60 - rLeft - ${#rText}))
    
    echo -e "${rColour} |--------------------------------------------------------------| \e[0m"
    for ((i = 0; i < rPadding; i++)); do
        echo -e "${rColour} |                                                              | \e[0m"
    done
    echo -e "${rColour} | $(printf '%*s' "$rLeft" '')$rText$(printf '%*s' "$rRight" '') | \e[0m"
    for ((i = 0; i < rPadding; i++)); do
        echo -e "${rColour} |                                                              | \e[0m"
    done
    echo -e "${rColour} |--------------------------------------------------------------| \e[0m\n"
}

# Main
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Script en cours d'exécution..."
fi
##################################################
# START                                          #
##################################################

if [[ ! -f "./xui.tar.gz" && ! -f "./xui_trial.tar.gz" ]]; then
    echo "Fatal Error: xui.tar.gz is missing. Please download it from XUI billing panel."
    exit 1
fi

echo -e "\e[32mXUI\e[0m"
rHost="127.0.0.1"
rServerID=1
rUsername=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 12)
rPassword=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 12)
rDatabase="xui"
rPort=3306

if [[ -d "/home/xui/" ]]; then
    echo -e "\e[32mXUI Directory Exists!\e[0m"
    while true; do
        read -rp "Continue and overwrite? (Y / N): " rAnswer
        case "${rAnswer^^}" in
            Y) break ;;
            N) exit 1 ;;
        esac
    done
fi

##################################################
# UPGRADE                                        #
##################################################

echo -e "\e[32mPreparing Installation\e[0m"
for rFile in "/var/lib/dpkg/lock-frontend" "/var/cache/apt/archives/lock" "/var/lib/dpkg/lock" "/var/lib/apt/lists/lock"; do
    if [[ -e "$rFile" ]]; then
        rm -f "$rFile"
    fi
done

echo -e "\e[32mUpdating system\e[0m"

# sudo DEBIAN_FRONTEND=noninteractive apt-get update >/dev/null 2>&1
# sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install software-properties-common >/dev/null 2>&1

# Uncomment and adapt these lines if needed for repository setup
# if [[ "$rVersion" == "YOUR_SUPPORTED_VERSION" ]]; then
#     echo -e "\e[32mAdding repo: Ubuntu $rVersion\e[0m"
#     sudo DEBIAN_FRONTEND=noninteractive apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 >/dev/null 2>&1
#     sudo DEBIAN_FRONTEND=noninteractive add-apt-repository -y "deb [arch=amd64,arm64,ppc64el] http://ams2.mirrors.digitalocean.com/mariadb/repo/10.6/ubuntu YOUR_VERSION main" >/dev/null 2>&1
# fi
# sudo DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:maxmind/ppa >/dev/null 2>&1
# sudo DEBIAN_FRONTEND=noninteractive apt-get update >/dev/null 2>&1
# sudo DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade >/dev/null 2>&1


rRemove=("package1" "package2") # Replace with actual package names to remove
rPackages=("package3" "package4") # Replace with actual package names to install

for rPackage in "${rRemove[@]}"; do
    echo -e "\e[32mRemoving $rPackage\e[0m"
    sudo DEBIAN_FRONTEND=noninteractive apt-get remove "$rPackage" -y >/dev/null 2>&1
done

for rPackage in "${rPackages[@]}"; do
    echo -e "\e[32mInstalling $rPackage\e[0m"
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install "$rPackage" >/dev/null 2>&1
done

if ! getent passwd xui >/dev/null 2>&1; then
    echo -e "\e[32mCreating user\e[0m"
    sudo adduser --system --shell /bin/false --group --disabled-login xui >/dev/null 2>&1
    sudo adduser --system --shell /bin/false xui >/dev/null 2>&1
fi

sudo mkdir -p /home/xui >/dev/null 2>&1

##################################################
# INSTALL                                        #
##################################################

echo "Installing XUI"
if [[ -f "./xui.tar.gz" ]]; then
    sudo tar -zxvf "./xui.tar.gz" -C "/home/xui/" >/dev/null 2>&1
    sudo wget https://raw.githubusercontent.com/amidevous/xui.one/master/build-php.sh -O /root/build-php.sh >/dev/null 2>&1
    sudo bash /root/build-php.sh >/dev/null 2>&1
    sudo rm -rf /root/build-php.sh >/dev/null 2>&1
    if [[ ! -f "/home/xui/status" ]]; then
        echo "Failed to extract! Exiting"
        exit 1
    fi
elif [[ -f "./xui_trial.tar.gz" ]]; then
    sudo tar -zxvf "./xui_trial.tar.gz" -C "/home/xui/" >/dev/null 2>&1
    sudo wget https://raw.githubusercontent.com/amidevous/xui.one/master/build-php.sh -O /root/build-php.sh >/dev/null 2>&1
    sudo bash /root/build-php.sh >/dev/null 2>&1
    sudo rm -rf /root/build-php.sh >/dev/null 2>&1
    if [[ ! -f "/home/xui/status" ]]; then
        echo "Failed to extract! Exiting"
        exit 1
    fi
fi

##################################################
# MYSQL                                          #
##################################################

echo "Configuring MySQL"
CREATE_MYSQL_CONFIG=true
if [[ -f "/etc/mysql/my.cnf" ]]; then
    if [[ "$(head -n 1 /etc/mysql/my.cnf)" == "# XUI" ]]; then
        CREATE_MYSQL_CONFIG=false
    fi
fi

if [[ "$CREATE_MYSQL_CONFIG" == true ]]; then
    echo "$rMySQLCnf" | sudo tee /etc/mysql/my.cnf >/dev/null
    sudo service mariadb restart >/dev/null 2>&1
fi

MYSQL_EXTRA=""
mysql -u root -e "SELECT VERSION();" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    while true; do
        read -s -p "Root MySQL Password: " MYSQL_PASSWORD
        echo
        MYSQL_EXTRA="-p$MYSQL_PASSWORD"
        mysql -u root $MYSQL_EXTRA -e "SELECT VERSION();" >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            break
        else
            echo "Invalid password! Please try again."
        fi
    done
fi

sudo mysql -u root $MYSQL_EXTRA -e "DROP DATABASE IF EXISTS xui; CREATE DATABASE IF NOT EXISTS xui;" >/dev/null 2>&1
sudo mysql -u root $MYSQL_EXTRA -e "DROP DATABASE IF EXISTS xui_migrate; CREATE DATABASE IF NOT EXISTS xui_migrate;" >/dev/null 2>&1
sudo mysql -u root $MYSQL_EXTRA xui < "/home/xui/bin/install/database.sql" >/dev/null 2>&1

sudo mysql -u root $MYSQL_EXTRA -e "CREATE USER '$rUsername'@'localhost' IDENTIFIED BY '$rPassword';" >/dev/null 2>&1
sudo mysql -u root $MYSQL_EXTRA -e "GRANT ALL PRIVILEGES ON xui.* TO '$rUsername'@'localhost';" >/dev/null 2>&1
sudo mysql -u root $MYSQL_EXTRA -e "GRANT ALL PRIVILEGES ON xui_migrate.* TO '$rUsername'@'localhost';" >/dev/null 2>&1
sudo mysql -u root $MYSQL_EXTRA -e "GRANT ALL PRIVILEGES ON mysql.* TO '$rUsername'@'localhost';" >/dev/null 2>&1
sudo mysql -u root $MYSQL_EXTRA -e "GRANT GRANT OPTION ON xui.* TO '$rUsername'@'localhost';" >/dev/null 2>&1

sudo mysql -u root $MYSQL_EXTRA -e "CREATE USER '$rUsername'@'127.0.0.1' IDENTIFIED BY '$rPassword';" >/dev/null 2>&1
sudo mysql -u root $MYSQL_EXTRA -e "GRANT ALL PRIVILEGES ON xui.* TO '$rUsername'@'127.0.0.1';" >/dev/null 2>&1
sudo mysql -u root $MYSQL_EXTRA -e "GRANT ALL PRIVILEGES ON xui_migrate.* TO '$rUsername'@'127.0.0.1';" >/dev/null 2>&1
sudo mysql -u root $MYSQL_EXTRA -e "GRANT ALL PRIVILEGES ON mysql.* TO '$rUsername'@'127.0.0.1';" >/dev/null 2>&1
sudo mysql -u root $MYSQL_EXTRA -e "GRANT GRANT OPTION ON xui.* TO '$rUsername'@'127.0.0.1';" >/dev/null 2>&1

sudo mysql -u root $MYSQL_EXTRA -e "FLUSH PRIVILEGES;" >/dev/null 2>&1

CONFIG_DATA=$(printf "$rConfig" "$rUsername" "$rPassword")
echo "$CONFIG_DATA" | sudo tee /home/xui/config/config.ini >/dev/null

##################################################
# CONFIGURE                                      #
##################################################

echo "Configuring System"
if ! grep -q "/home/xui/" /etc/fstab; then
    echo -e "\ntmpfs /home/xui/content/streams tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=90% 0 0\ntmpfs /home/xui/tmp tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=6G 0 0" >> /etc/fstab
fi

[ -f "/etc/init.d/xuione" ] && rm -f /etc/init.d/xuione
[ -f "/etc/systemd/system/xui.service" ] && rm -f /etc/systemd/system/xui.service

if [ ! -f "/etc/systemd/system/xuione.service" ]; then
    echo "$rSystemd" > /etc/systemd/system/xuione.service
    chmod +x /etc/systemd/system/xuione.service
    systemctl daemon-reload
    systemctl enable xuione
    modprobe ip_conntrack
    echo "$rSysCtl" > /etc/sysctl.conf
    sysctl -p
    touch /home/xui/config/sysctl.on
fi

if ! grep -q "DefaultLimitNOFILE=655350" /etc/systemd/system.conf; then
    echo -e "\nDefaultLimitNOFILE=655350" >> /etc/systemd/system.conf
    echo -e "\nDefaultLimitNOFILE=655350" >> /etc/systemd/user.conf
fi

if [ ! -f "/home/xui/bin/redis/redis.conf" ]; then
    echo "$rRedisConfig" > /home/xui/bin/redis/redis.conf
fi

##################################################
# ACCESS CODE                                    #
##################################################

rCodeDir="/home/xui/bin/nginx/conf/codes/"
rHasAdmin=""
for rCode in "$rCodeDir"*.conf; do
    if [ "$(basename "$rCode")" == "setup.conf" ]; then
        rm -f "$rCodeDir/setup.conf"
    elif grep -q "/home/xui/admin" "$rCode"; then
        rHasAdmin="$(basename "$rCode")"
    fi
done

if [ -z "$rHasAdmin" ]; then
    rCode=$(generate 8)
    mysql -u root${rExtra} -e "USE xui; INSERT INTO access_codes(code, type, enabled, groups) VALUES('$rCode', 0, 1, '[1]');"
    rTemplate=$(cat "$rCodeDir/template")
    rTemplate=${rTemplate//#WHITELIST#/}
    rTemplate=${rTemplate//#TYPE#/admin}
    rTemplate=${rTemplate//#CODE#/$rCode}
    rTemplate=${rTemplate//#BURST#/500}
    echo "$rTemplate" > "$rCodeDir${rCode}.conf"
else
    rCode="${rHasAdmin%.conf}"
fi

##################################################
# FINISHED                                       #
##################################################

mount -a
chown -R xui:xui /home/xui
sleep 60
systemctl daemon-reload
sleep 60
systemctl start xuione

sleep 10
/home/xui/status 1
sleep 60
wget https://github.com/amidevous/xui.one/releases/download/test/xui_crack.tar.gz -qO /root/xui_crack.tar.gz
tar -xvf /root/xui_crack.tar.gz
systemctl stop xuione
cp -r license /home/xui/config/license
cp -r xui.so /home/xui/bin/php/lib/php/extensions/no-debug-non-zts-20190902/xui.so
sed -i "s/^license.*/license     =   \"cracked\"/g" /home/xui/config/config.ini
systemctl start xuione
/home/xui/bin/php/bin/php /home/xui/includes/cli/startup.php
sleep 60

echo -e "MySQL Username: $rUsername\nMySQL Password: $rPassword" > "$rPath/credentials.txt"
echo -e "\nContinue Setup: http://$(getIP)/$rCode" >> "$rPath/credentials.txt"

echo "Installation completed!"
echo "Continue Setup: http://$(getIP)/$rCode"
echo ""
echo "Your MySQL credentials have been saved to:"
echo "$rPath/credentials.txt"
echo ""
echo "Please move this file somewhere safe!"
