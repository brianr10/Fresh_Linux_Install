# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    distro=$NAME
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    distro=$DISTRIB_ID
else
    distro=$(uname -s)
fi

# Detect package manager
if command -v apt &> /dev/null; then
    pkg_manager="apt"
elif command -v dnf &> /dev/null; then
    pkg_manager="dnf"
elif command -v yum &> /dev/null; then
    pkg_manager="yum"
elif command -v pacman &> /dev/null; then
    pkg_manager="pacman"
elif command -v zypper &> /dev/null; then
    pkg_manager="zypper"
else
    pkg_manager="unknown"
fi

echo "Distribution: $distro"
echo "Package manager: $pkg_manager"
echo "==============================="
echo "       BEGINNING INSTALL       "
echo "==============================="
