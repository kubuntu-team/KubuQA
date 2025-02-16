#!/bin/bash
# shellcheck disable=SC1090

# This script automates downloading the latest daily ISO for Kubuntu and spinning up a VM in VirtualBox.
# It uses VBoxManage to set up the VM, look here for documentation: https://www.virtualbox.org/manual/ch08.html

# CONFIGURATION
# -------------

# If you want to configure things (e.g. Download directory, location of the VDI), please edit the variables below.
# You can also use flags or specify a config file via the '--config' flag. See './KubuQA.sh --help' for details.

# Directory the ISO file will be downloaded to.
# Default is a XDG download dir, i.e. for English locale: "$HOME/Downloads/KubuntuTestISO"
ISO_DOWNLOAD_DIR="$(xdg-user-dir DOWNLOAD)/KubuQATestISOfiles"

# Number of virtual CPUs to assign to the VM.
# You should not configure virtual machines to use more CPU cores than are available physically.
# Rule of thumb: Assign about 1/4-1/2 of your physical cores,
# depending on what you are doing on the host system aside from running the VM.
# Default: 2
VM_CPU_CORES="2"

# The amount of host system RAM to allocate to the VM (in MB).
# The more, the better for the VM, but keep in mind what you are doing on the host system aside from running the VM.
# Default: 2048 (aka 2 GB)
VM_RAM="2048"

# The amount of host system RAM to allocate to the Video Framebuffer
# Range (8 - 128)mb
# Default is 64mb
# More video RAM may enable higher resolution display (See VirtualBox Guest Additions for Full Video Support)
VIDEO_RAM="64"

# Whether to enable paravirtualization via KVM. This leads to better performance on devices that support it.
# Possible values: "kvm" (to enable), "none" (to diable)
# Default: "none"
PARAVIRT="none"

# Ubuntu Main and Flavor ISO Configurations
# -----------------------------------------
#   Provide path to CD image for the flavors ISO's
#   Use full download path & filename
#   Don't include the protocol http:// || https:// as we need to switch between them
#   to enable zsync to be successful. See:
#   https://ubuntuforums.org/showthread.php?t=2494264
#
#
# Current Relese: server_path/filename
# <FLAVOR>_RELEASE="cdimages.ubuntu.com/ubuntu/releases/24.10/release/ubuntu-24.10-desktop-arm64.iso"

# Daily Build: server_path/filename
# <FLAVOR>_DAILY="cdimages.ubuntu.com/daily-live/current/plucky-desktop-arm64.iso"

# UBUNTU
UBUNTU_RELEASE="releases.ubuntu.com/oracular/ubuntu-24.10-desktop-amd64.iso"
UBUNTU_DAILY="cdimages.ubuntu.com/daily-live/current/plucky-desktop-arm64.iso"

# KUBUNTU
KUBUNTU_RELEASE="cdimage.ubuntu.com/kubuntu/releases/24.10/release/kubuntu-24.10-desktop-amd64.iso"
KUBUNTU_DAILY="cdimage.ubuntu.com/kubuntu/daily-live/current/plucky-desktop-amd64.iso"

# LUBUNTU
LUBUNTU_RELEASE="cdimages.ubuntu.com/lubuntu/releases/24.10/release/lubuntu-24.10-desktop-amd64.iso"
LUBUNTU_DAILY="cdimages.ubuntu.com/lubuntu/daily-live/current/plucky-desktop-amd64.iso"

# UBUNTU BUDGIE
BUDGIE_RELEASE="cdimages.ubuntu.com/ubuntu-budgie/releases/24.10/release/ubuntu-budgie-24.10-desktop-amd64.iso"
BUDGIE_DAILY="cdimages.ubuntu.com/ubuntu-budgie/daily-live/current/plucky-desktop-amd64.iso"

# EDUBUNTU
EDUBUNTU_RELEASE="cdimages.ubuntu.com/edubuntu/releases/24.10/release/edubuntu-24.10-desktop-amd64.iso"
EDUBUNTU_DAILY="cdimages.ubuntu.com/edubuntu/daily-live/current/plucky-desktop-amd64.iso"

# UBUNTU UNITY
UNITY_RELEASE="cdimages.ubuntu.com/ubuntu-unity/releases/24.10/release/ubuntu-unity-24.10-desktop-amd64.iso"
UNITY_DAILY="cdimages.ubuntu.com/ubuntu-unity/daily-live/current/plucky-desktop-amd64.iso"

# UBUNTU CINNAMON
CINNAMON_RELEASE="cdimages.ubuntu.com/ubuntucinnamon/releases/24.10/release/ubuntucinnamon-24.10-desktop-amd64.iso"
CINNAMON_DAILY="cdimages.ubuntu.com/ubuntucinnamon/daily-live/current/plucky-desktop-amd64.iso"

# UBUNTU STUDIO
STUDIO_RELEASE="cdimages.ubuntu.com/ubuntustudio/releases/24.10/release/ubuntustudio-24.10-desktop-amd64.iso"
# Note: There doesn't seem to build a daily build for Ubuntu Studio, so using current release
STUDIO_DAILY="cdimages.ubuntu.com/ubuntustudio/releases/24.04/release/ubuntustudio-24.04-dvd-amd64.iso"

# XUBUNTU
XUBUNTU_RELEASE="cdimages.ubuntu.com/xubuntu/releases/24.10/release/xubuntu-24.10-desktop-amd64.iso"
XUBUNTU_DAILY="cdimages.ubuntu.com/xubuntu/daily-live/current/plucky-desktop-amd64.iso"


#############################################
# DO NOT EDIT ANY VARIABLES BELOW THIS LINE #
#############################################



# FUNCTIONS
# ---------

# Print a help message
usage() {
    echo "This script automates downloading the latest daily ISO for Kubuntu and spinning up a VM in VirtualBox."
    echo "It sets up the VM using VBoxManage. For more details, see: https://github.com/kubuntu-team/KubuQA/blob/main/README.md"
    echo ""
    echo "Usage: ./KubuQA.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --config <path>             Path to a config file to source. If more command line options follow, they will overwrite the setting in the config file."
    echo "  -c, --cpu <cores>           Number of virtual CPUs to assign to the VM. Default: 2"
    echo "  -i, --iso-dir <directory>   Directory to download the ISO file. Default: \"$(xdg-user-dir DOWNLOAD)/KubuntuTestISO\""
    echo "  -n, --vm-name <name>        Name of the Virtual Machine. Default: \"TestKubuntuInstall\""
    echo "  -v, --vdi-path <path>       Path to the Virtual Disk Image (VDI). Default: \"$HOME/VirtualBox VMs/<vm-name>/<vm-name>.vdi\""
    echo "  -r, --ram <MB>              Amount of host system RAM to allocate to the VM (in MB). Default: 2048 (2 GB)"
    echo "  -p, --paravirt <provider>   Enable paravirtualization via KVM for better performance. Possible values: \"kvm\", \"none\". Default: \"none\""
    echo "  -h, --help                  Display this help message and exit"
}


# Function to check and install required tools & dependencies
check_and_install_tool() {
    local tool_name="$1"
    local package_name="$2" # Package name might differ from tool name

    if ! command -v "$tool_name" &> /dev/null; then
        echo "$tool_name could not be found, attempting to install."
        pkexec apt-get install -y "$package_name"
    fi
}

# Function to check for a previous KubuQA test VM. If not found, create one.
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
    # Command parameters differ between VBoxManage v6 and v7 Doh!
    # https://www.virtualbox.org/manual/ch08.html#vboxmanage-modifyvm
    # Find VBoxManage version
    vbox_version=$(VBoxManage --version | cut -d 'r' -f 1 | cut -d '.' -f 1)

    # Define Base command
    base_cmd="VBoxManage modifyvm \"$VM_NAME\" --acpi on --nic1 nat --cpus=\"$VM_CPU_CORES\" --memory=\"$VM_RAM\" --vram=\"$VIDEO_RAM\""

    # Check version and call the command with the correct parameters
    if [ "$vbox_version" -lt 7 ]; then
        # Version 6

        eval "$base_cmd" --ostype="\"Ubuntu (64-bit)\"" --paravirtprovider="$PARAVIRT"
    else
        # Version 7 or higher
        eval "$base_cmd" --os-type="Ubuntu_64" --paravirt-provider="$PARAVIRT"
    fi

    #VBoxManage modifyvm "$VM_NAME" --ostype="Ubuntu (64-bit)" --acpi on --nic1 nat --cpus="$VM_CPU_CORES" --memory="$VM_RAM" --paravirtprovider="$PARAVIRT"
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
    echo "$ISO_DOWNLOAD_DIR"
    cd "$ISO_DOWNLOAD_DIR" || kdialog --error "There is something wrong with the ISO Download directory. Make sure it is accessible."
    # Check if the ISO file exists, and has already been downloaded
    echo "Looking for $ISO_FILENAME"
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

# Enable the user to choose which Ubuntu Flavor they want to test
function choose_flavor() {
    # See: https://cdimage.ubuntu.com/ for flavors and path info etc...
    choice=$(kdialog --menu "Select Ubuntu Flavor" 1 "Ubuntu" 2 "Kubuntu" 3 "Lubuntu" 4 "Ubuntu-Budgie" 5 "Edubuntu" 6 "Ubuntu-Unity" 7 "Ubuntu-Cinnamon" 8 "Ubuntu-Studio" 9 "Xubuntu")
    case $choice in

          # UBUNTU
          1) FLAVOR="ubuntu"
             VM_NAME="KubuQATestUbuntu"
             RELEASE="$UBUNTU_RELEASE"
             DAILY="$UBUNTU_DAILY";;

          # KUBUNTU
          2) FLAVOR="kubuntu"
             VM_NAME="KubuQATestKubuntu"
             RELEASE="$KUBUNTU_RELEASE"
             DAILY="$KUBUNTU_DAILY";;

          # LUBUNTU
          3) FLAVOR="lubuntu"
             VM_NAME="KubuQATestLubuntu"
             RELEASE="$LUBUNTU_RELEASE"
             DAILY="$LUBUNTU_DAILY";;

          # UBUNTU BUDGIE
          4) FLAVOR="ubuntu-budgie"
             VM_NAME="KubuQATestUbuntuBudgie"
             RELEASE="$BUDGIE_RELEASE"
             DAILY="$BUDGIE_DAILY";;

          # EDUBUNTU
          5) FLAVOR="edubuntu"
             VM_NAME="KubuQATestEdubuntu"
             RELEASE="$EDUBUNTU_RELEASE"
             DAILY="$EDUBUNTU_DAILY";;

          # UBUNTU UNITY
          6) FLAVOR="ubuntu-unity"
             VM_NAME="KubuQATestUbuntuUnity"
             RELEASE="$UNITY_RELEASE"
             DAILY="$UNITY_DAILY";;

          # UBUNTU CINNAMON
          7) FLAVOR="ubuntucinnamon"
             VM_NAME="KubuQATestUbuntuCinnamon"
             RELEASE="$CINNAMON_RELEASE"
             DAILY="$CINNAMON_DAILY";;

          # UBUNTU STUDIO
          8) FLAVOR="ubuntustudio"
             VM_NAME="KubuQATestUbuntuStudio"
             RELEASE="$STUDIO_RELEASE"
             DAILY="$STUDIO_DAILY";;

          # XUBUNTU
          9) FLAVOR="xubuntu"
             VM_NAME="KubuQATestXubuntu"
             RELEASE="$XUBUNTU_RELEASE"
             DAILY="$XUBUNTU_DAILY";;
    esac

    release=$(kdialog --menu "Which version " 1 "Current Release" 2 "Daily Build")
    case $release in
          1) ISO_DOWNLOAD_URL="$RELEASE";;

          2) ISO_DOWNLOAD_URL="$DAILY";;
    esac

# Extract ISO filename to Check / Update, and used by VBox manage to mount the ISO
ISO_FILENAME=$(echo "$ISO_DOWNLOAD_URL" | sed 's/^.*\///')

#Each Flavor should have it's own download directory
ISO_DOWNLOAD_DIR="$ISO_DOWNLOAD_DIR/$FLAVOR"

# Path to the Virtual Disk Image (VDI). The image will be created if it doesn't exist.
# Default: "$HOME/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi"
VDI_FILEPATH="$HOME/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi"

}
# MAIN
# ----

# Ensure required tools are installed
check_and_install_tool kdialog kdialog
check_and_install_tool zsync zsync
check_and_install_tool wget wget
check_and_install_tool VBoxManage virtualbox

# Parse command line arguments
# TODO Validate the input
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --config)        if source "$2"; then
                             echo "Sourcing \"$2\""
                         else
                             kdialog --warningcontinuecancel "The config file \"$2\" was not found. Continue with the default values?"
                         fi
                         shift;;
        -c | --cpu)      VM_CPU_CORES="$2"
                         shift ;;
        -i | --iso-dir)  ISO_DOWNLOAD_DIR="$2"
                         shift ;;
        -n | --vm-name)  VM_NAME="$2"
                         shift ;;
        -v | --vdi-path) VDI_FILEPATH="$2"
                         shift ;;
        -r | --ram)      VM_RAM="$2"
                         shift ;;
        -p | --paravirt) PARAVIRT="$2"
                         shift ;;
        -h | --help)     usage
                         exit ;;
        *)               echo "Unknown flag: $1"
                         usage
                         exit 1;;
    esac
    shift
done

# Check whether various components exist. If not or if requested, (re)create
choose_flavor
check_existing_vm
check_existing_vdi
check_existing_iso

# Prompt the user to launch a test install using VirtualBox
if kdialog --yesno "Launch a Test Install using Virtual Box?"; then

    # Enable the user to choose which device to boot from
    choice=$(kdialog --menu "Select boot medium" 1 "ISO cdimage" 2 "VDI disk")

    case "$choice" in
           # Attatch the ISO to its storage controller and make VirtualBox boot from it
        1) VBoxManage modifyvm "$VM_NAME" --boot1 dvd
           VBoxManage storageattach "$VM_NAME" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$ISO_DOWNLOAD_DIR/$ISO_FILENAME" ;;
           # Make VirtualBox boot from the VDI
        2) VBoxManage modifyvm "$VM_NAME" --boot1 disk ;;
        *) echo "Invalid choice"; exit 1 ;;
    esac

    # Connect the VDI to its storage controller
    VBoxManage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VDI_FILEPATH"

    # Spin it up, we are Go For Launch!!
    VBoxManage startvm "$VM_NAME"

    # Wait 10 seconds and then resize the display
    # This ensures that as the installer runs the Calamares Slide show renders nicely, and the user
    # has enough screen real estate to operate the installer.
    # Hat Tip to 'Sergey Tkachenko' https://winaero.com/author/hb860root/
    # https://winaero.com/set-exact-display-resolution-in-virtualbox-virtual-machine/
    sleep 10
    VBoxManage setextradata global GUI/MaxGuestResolution any
    VBoxManage setextradata "$VM_NAME" "CustomVideoMode1" "1366x768x32"
    VBoxManage controlvm "$VM_NAME" setvideomodehint 1366 768 32
else
    exit
fi
