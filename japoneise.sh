#!/bin/bash

# Set default values
username="user"
password="root"
chrome_remote_desktop_url="https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb"

# Function to log messages
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Function to install packages
install_package() {
    package_url=$1
    log "Downloading $package_url"
    wget -q --show-progress "$package_url"
    log "Installing $(basename $package_url)"
    sudo dpkg --install $(basename $package_url)
    log "Fixing broken dependencies"
    sudo apt-get install --fix-broken -y
    rm $(basename $package_url)
}

# Installation steps
log "Starting installation"

# Create user
log "Creating user '$username'"
sudo useradd -m "$username"
echo "$username:$password" | sudo chpasswd
sudo sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd

# Install Chrome Remote Desktop
install_package "$chrome_remote_desktop_url"

# Install XFCE desktop environment
log "Installing XFCE desktop environment"
sudo DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes -y xfce4 desktop-base dbus-x11 xscreensaver

# Set up Chrome Remote Desktop session
log "Setting up Chrome Remote Desktop session"
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'

# Disable lightdm service
log "Disabling lightdm service"
sudo systemctl disable lightdm.service

# Update package lists
sudo apt update

# Install Firefox ESR
log "Installing Firefox"
sudo apt install -y firefox

# Install Wine
log "Installing Wine"
sudo dpkg --add-architecture i386
wget -nc https://dl.winehq.org/wine-builds/winehq.key
sudo apt-key add winehq.key
sudo add-apt-repository 'deb https://dl.winehq.org/wine-builds/debian/ bullseye main'
sudo apt update
sudo apt install -y --install-recommends winehq-stable
wine --version

# Install Winetricks (useful for installing common Windows components)
log "Installing Winetricks"
sudo apt install -y winetricks

# Install DOSBox
log "Installing DOSBox"
sudo apt install -y dosbox

# Install GDebi
log "Installing GDebi"
sudo apt install -y gdebi

# Install PlayOnLinux
log "Installing PlayOnLinux"
sudo apt install -y playonlinux

# Install GNOME Software (Linux app store)
log "Installing GNOME Software"
sudo apt install -y gnome-software

# Install CrossOver (Note: This is a commercial product with a free trial)
log "Installing CrossOver"
wget https://media.codeweavers.com/pub/crossover/cxlinux/demo/crossover_22.1.1-1.deb
sudo dpkg -i crossover_22.1.1-1.deb
sudo apt-get install -f -y
rm crossover_22.1.1-1.deb

log "Installation completed successfully"

# Note on running Windows executables
log "Note: You can now run Windows .exe files using either Wine or CrossOver."
log "To use Wine, run: wine path/to/your/application.exe"
log "To use CrossOver, open it from the applications menu and follow the GUI instructions."
log "CrossOver is a commercial product with a free trial. You may need to purchase a license for continued use."
