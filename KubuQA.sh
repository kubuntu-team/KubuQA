#!/bin/bash

# Function to check and install required tools
check_and_install_tool() {
    local tool_name="$1"
    local package_name="$2" # Package name might differ from tool name

    if ! command -v "$tool_name" &> /dev/null; then
        echo "$tool_name could not be found, attempting to install."
        pkexec -- apt-get install -y "$package_name"
    fi
}

# Ensure required tools are installed
check_and_install_tool kdialog kdialog
check_and_install_tool zsync zsync
check_and_install_tool wget wget
check_and_install_tool VBoxManage virtualbox

# Define the directory and file names
directory="$HOME/Downloads/KubuntuTestISO"
isoFileName="noble-desktop-amd64.iso"
isoFilePath="$directory/$isoFileName"
isoDownloadURL="https://cdimages.ubuntu.com/kubuntu/daily-live/current/$isoFileName"

# Ensure the directory exists
mkdir -p "$directory"
cd "$directory"

# Check if the ISO file exists
if [ -f "$isoFileName" ]; then
    # Prompt the user to check for updates
    if kdialog --yesno "I found an ISO Test Image, would you like to check for updates?"; then
        # Use zsync to update the ISO
        zsync "$isoDownloadURL.zsync"
    fi
else
    # Prompt the user to download the ISO if it doesn't exist
    if kdialog --yesno "No local test ISO image available, should I download one?"; then
        # Download the ISO
        wget "$isoDownloadURL"
    else
        exit
    fi
fi

# Prompt the user to launch a test install using VirtualBox
if kdialog --yesno "Launch a Test Install using Virtual Box?"; then
    # Use VirtualBox to launch a VM booting from the ISO image
    VBoxManage createvm --name "TestKubuntuInstall" --register
    VBoxManage modifyvm "TestKubuntuInstall" --memory 2048 --acpi on --boot1 dvd --nic1 nat
    VBoxManage createhd --filename "$HOME/VirtualBox VMs/TestKubuntuInstall/TestKubuntuInstall.vdi" --size 12000
    VBoxManage storagectl "TestKubuntuInstall" --name "IDE Controller" --add ide
    VBoxManage storageattach "TestKubuntuInstall" --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium "$HOME/VirtualBox VMs/TestKubuntuInstall/TestKubuntuInstall.vdi"
    VBoxManage storageattach "TestKubuntuInstall" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium "$isoFilePath"
    VBoxManage startvm "TestKubuntuInstall"
else
    exit
fi
