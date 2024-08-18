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

sudo $pkg_manager update -y
sudo $pkg_manager upgrade -y

echo "Downloading Fedora things..."
if [ "$distro" = "Fedora Linux" ]; then
	echo -e "fastestmirror=True\nmax_parallel_downloadss=10\ndefaultyes=True\nkeepcache=True" | sudo tee -a /etc/dnf/dnf.conf
	sudo $pkg_manager clean all
	sudo $pkg_manager update -y
	sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
	sudo dnf config-manager --enable fedora-cisco-openh264
	sudo rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
	sudo dnf install --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm -y
	sudo dnf install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm -y
	sudo dnf update @core
	sudo dnf install make automake gcc gcc-c++ kernel-devel -y
	sudo dnf groupinstall "Development Tools" "Development Libraries" -y
	sudo dnf groupinstall "C Development Tools and Libraries" -y
	sudo dnf install libXcomposite libXcursor libXi libXtst libXrandr alsa-lib mesa-libEGL libXdamage mesa-libGL libXScrnSaver
fi

echo "Downloading Calibre Library"
sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin

# https://flatpak.org/setup/ 
# This is the website should you need to do this manually
echo "Downloading Flatpak"
if $pkg_manager="dnf"; then
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	wget https://code.visualstudio.com/docs/?dv=linux64_rpm
	sudo dnf install code*.x86_64.rpm -y
elif $pkg_manager="apt"; then
	sudo add-apt-repository ppa:flatpak/stable
    sudo $pkg_manager update -y
	sudo $pkg_manager install flatpak -y
	sudo apt install gnome-software-plugin-flatpak -y
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	sudo apt install build-esstential -y
	sudo apt-get install libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6 -y
fi

echo "Downloading XFreeRDP"
sudo $pkg_manager install freerdp-x11 -y

echo "Downloading necessary packages"
sudo $pkg_manager install neofetch htop nvtop git wget curl vim steam qemu-kvm qemu-utils libvirt-daemon-system libvirt-clients bridge-utils virt-managerovmf timeshift bleachbit vlc gimp gparted cmake discord ufw tmux ffmpeg python3 -y

echo "Downloading Spotify"
flatpak install flathub com.spotify.Client -y

echo "Downloading OBS Studio"
flatpak install flathub com.obsproject.Studio -y

# This is weird and does not work how I want it to, just download manually from app store for now
# echo "Downloading Obsidian"
# wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.7/Obsidian-1.6.7.AppImage
# chmod +x Obsidian-1.6.7.AppImage
# sudo mv Obsidian-1.6.7.AppImage /usr/local/bin/Obsidian

# For reference visit: https://docs.anaconda.com/anaconda/install/linux/
# Archive website for Anaconda: https://repo.anaconda.com/archive/
echo "Downloading CONDA"
curl -o https://repo.anaconda.com/archive/Anaconda3-2024.06-1-Linux-x86_64.sh
mv Anaconda3-2024.06-1-Linux-x86_64.sh ~/Downloads
bash ~/Downloads/Anaconda3-2024.06-1-Linux-x86_64.sh

echo "Downloading Signal Desktop"
flatpak install flathub org.signal.Signal -y

echo "Downloading PDFChain"
sudo flatpak install pdfchain -y

echo "Downloading Lazy Vim"
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

sudo $pkg_manager update -y
sudo $pkg_manager upgrade -y
echo "Done for now..."
echo "More things will be added later"
echo "Signing off, goodbye..."
