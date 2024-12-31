#!/bin/bash

GH="https://github.com"
GH_USER="rickeymandraque"
GH_REPO="xui.one-24.04"
GH_URL_REPO="$GH/$GH_USER/$GH_REPO"
GH_RAW="$GH_URL_REPO/raw/refs/heads/master"
LATEST_VERSION=$(curl -sL "$GH_RAW/latest.ver")
OFFICIAL_RELEASE="https://update.xui.one/$LATEST_VERSION"
GH_RELEASE="$GH_RAW/latest.ver"

# Function to check if the script is run as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "I am Groot !"
        echo "[ERROR] This script must be run as root or with sudo."
        # Attempt to relaunch with sudo if possible
        if command -v sudo &> /dev/null; then
            echo "[INFO] Attempting to relaunch with sudo..."
            echo "I am Root !"
            sudo bash -c "$*"
            exit $? # Exit with the status of the sudo command
        else
            echo "[ERROR] 'sudo' is not available. Please run this script as root."
            exit 1
        fi
    fi
}

# Initial user-mode message
if [[ $EUID -ne 0 ]]; then
    echo "I am Groot!"
    echo "It seems you have launched the script as a regular user."
fi

echo -e "\nChecking that minimal requirements are ok"

# Ensure the OS is compatible with the launcher
if [ -f /etc/centos-release ]; then
    inst() {
       rpm -q "$1" &> /dev/null
    } 
    if (inst "centos-stream-repos"); then
        OS="CentOS-Stream"
    else
        OS="CentOs"
    fi    
    VERFULL="$(sed 's/^.*release //;s/ (Fin.*$//' /etc/centos-release)"
    VER="${VERFULL:0:1}" # return 6, 7 or 8
elif [ -f /etc/fedora-release ]; then
    inst() {
       rpm -q "$1" &> /dev/null
    } 
    OS="Fedora"
    VERFULL="$(sed 's/^.*release //;s/ (Fin.*$//' /etc/fedora-release)"
    VER="${VERFULL:0:2}" # return 34, 35 or 36
elif [ -f /etc/lsb-release ]; then
    OS="$(grep DISTRIB_ID /etc/lsb-release | sed 's/^.*=//')"
    VER="$(grep DISTRIB_RELEASE /etc/lsb-release | sed 's/^.*=//')"
elif [ -f /etc/os-release ]; then
    OS="$(grep -w ID /etc/os-release | sed 's/^.*=//')"
    VER="$(grep -w VERSION_ID /etc/os-release | sed 's/^.*=//')"
else
    OS="$(uname -s)"
    VER="$(uname -r)"
fi
ARCH=$(uname -m)
echo "Detected : $OS  $VER  $ARCH"

# Download and unzip files as a regular user
tmp_dir=$(mktemp -d)
trap "rm -rf $tmp_dir" EXIT

wget "$GH_RAW/install-dep.sh" -qO "$tmp_dir/install-dep.sh" >/dev/null 2>&1
wget "$GH_RELEASE" -qO "$tmp_dir/$LATEST_VERSION" >/dev/null 2>&1
unzip "$tmp_dir/$LATEST_VERSION" -d "$tmp_dir" >/dev/null 2>&1
wget "$GH_RAW/install.python3" -qO "$tmp_dir/install.python3" >/dev/null 2>&1

chmod +x "$tmp_dir/install-dep.sh"
chmod +x "$tmp_dir/install.python3"

# Execute the scripts as root
check_root "$tmp_dir/install-dep.sh"
check_root "python3 $tmp_dir/install.python3"
