#!/bin/bash

# This script automates downloading the latest daily ISO for Kubuntu and spinning up a VM in VirtualBox.
# It uses VBoxManage to set up the VM, look here for documentation: https://www.virtualbox.org/manual/ch08.html

# CONFIGURATION
# -------------

# If you want to configure things (e.g. Download directory, location of the VDI), please edit the variables below.

# Directory the ISO file will be downloaded to.
# Default: "$HOME/Downloads/KubuntuTestISO"
ISO_DOWNLOAD_DIR="$HOME/Downloads/KubuntuTestISO"

# Name of the VM.
# Default: "TestKubuntuInstall"
VM_NAME="TestKubuntuInstall"

# Path to the Virtual Disk Image (VDI). The image will be created if it doesn't exist.
# Default: "$HOME/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi"
VDI_FILEPATH="$HOME/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi"


#############################################
# DO NOT EDIT ANY VARIABLES BELOW THIS LINE #
#############################################

ISO_FILENAME="noble-desktop-amd64.iso"
ISO_FILEPATH="$ISO_DOWNLOAD_DIR/$ISO_FILENAME"

# Don't include the protocol http:// || https:// as we need to switch between them
# to enable zsync to be succesful. See:
# https://ubuntuforums.org/showthread.php?t=2494264
ISO_DOWNLOAD_URL="cdimages.ubuntu.com/kubuntu/daily-live/current/$ISO_FILENAME"

# FUNCTIONS
# ---------

# Function to check and install required tools & dependencies
check_and_install_tool() {
    local tool_name="$1"
    local package_name="$2" # Package name might differ from tool name

    if ! command -v "$tool_name" &> /dev/null; then
        echo "$tool_name could not be found, attempting to install."
        pkexec apt-get install -y "$package_name"
    fi
}

# Function to check for a previous Kubuntu Test VM. If not found, create one.
check_existing_vm(){
    # Run VBoxManage list vms and capture output
    vms_output=$(VBoxManage list vms)
    # Check for "$VM_NAME" Virtual Machine
    vm_id=$(echo "$vms_output" | grep "\"$VM_NAME\"" | awk '{print $2}' | tr -d '{}')
    if [ -n "$vm_id" ]; then
        # Prompt the user with kdialog
        if kdialog --title "VM Exists" --yesno "The '$VM_NAME' VM exists (ID: $vm_id). Do you want to keep it?"; then
            # User chose to keep the VM
            echo "Keeping '$VM_NAME' VM."
            return
        else
            # User chose to remove the VM
            VBoxManage unregistervm "$vm_id" --delete
            echo "'$VM_NAME' VM has been removed."
        fi
    fi
    # There was no VM or the user chose to remove it
    VBoxManage createvm --name "$VM_NAME" --register
    # Set up the newly created VM
    VBoxManage modifyvm "$VM_NAME" --memory 2048 --acpi on --nic1 nat
    # Create storage controllers for the ISO and VDI
    VBoxManage storagectl "$VM_NAME" --name "SATA Controller" --add sata --bootable=on
    VBoxManage storagectl "$VM_NAME" --name "IDE Controller" --add ide --bootable=on
    echo "A new '$VM_NAME' VM has been created."
}

# Function to check for existing Virtual Disk Image. If not found, create one.
function check_existing_vdi() {
    # Check if there is already a registered VDI in VirtualBox
    if VBoxManage list hdds | grep --quiet "$VM_NAME"; then
        if kdialog --yesno "Existing Virtual Disk Image (VDI) found. Keep it?"; then
            echo "User chose to keep the existing VDI file."
            return
        else
            echo "Deleting the existing VDI file..."
            VBoxManage closemedium disk "$VDI_FILEPATH" --delete
        fi
    fi
    echo "No Virtual Disk Image found. Creating a new one..."
    VBoxManage createmedium disk --filename "$VDI_FILEPATH" --size 12000 --format=VDI
}

function check_existing_iso() {
    # Ensure the ISO Download directory exists
    mkdir -p "$ISO_DOWNLOAD_DIR"
    cd "$ISO_DOWNLOAD_DIR"
    # Check if the ISO file exists, and has already been downloaded
    if [ -f "$ISO_FILENAME" ]; then
        # Prompt the user to check for updates
        if kdialog --yesno "I found an ISO Test Image, would you like to check for updates?"; then
            # Use zsync to update the ISO
            zsync "http://$ISO_DOWNLOAD_URL.zsync"
        fi
    else
        # Prompt the user to download the ISO if it doesn't exist
        if kdialog --yesno "No local test ISO image available, should I download one?"; then
            # Download the ISO
            wget "https://$ISO_DOWNLOAD_URL"
        else
            exit
        fi
    fi
}

# MAIN
# ----

# Ensure required tools are installed
check_and_install_tool kdialog kdialog
check_and_install_tool zsync zsync
check_and_install_tool wget wget
check_and_install_tool VBoxManage virtualbox

# Check whether various components exist. If not or if requested, (re)create them
check_existing_vm
check_existing_vdi
check_existing_iso

# Prompt the user to launch a test install using VirtualBox
if kdialog --yesno "Launch a Test Install using Virtual Box?"; then

    # Enable the user to choose which device to boot from
    choice=$(kdialog --menu "Select boot medium" 1 "ISO" 2 "VDI")

    case "$choice" in
           # Attatch the ISO to its storage controller and make VirtualBox boot from it
        1) VBoxManage modifyvm "$VM_NAME" --boot1 dvd
           VBoxManage storageattach "$VM_NAME" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$ISO_FILEPATH" ;;
           # Make VirtualBox boot from the VDI
        2) VBoxManage modifyvm "$VM_NAME" --boot1 disk ;;
        *) echo "Invalid choice"; exit 1 ;;
    esac

    # Connect the VDI to its storage controller
    VBoxManage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VDI_FILEPATH"

    # Spin it up, we are Go For Launch!!
    VBoxManage startvm "$VM_NAME"
else
    exit
fi
