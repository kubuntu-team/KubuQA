# KubuQA
Kubuntu ISO Testing Utility

## Kubuntu Test ISO Tool

### Overview

This Bash script automates the process of setting up a Kubuntu test environment. It checks for the existence of a specific directory and ISO file, manages ISO downloads and updates, and facilitates launching a test installation using VirtualBox. It leverages `kdialog` for graphical user interaction, making it accessible even for users who prefer not to work directly with the command line.

## Installation

### Prerequisites

Upon first launch the script will ensure you have the following installed on your Kubuntu system:

- `kdialog` for graphical dialogs.
- `zsync` for ISO file updates.
- `wget` for downloading files.
- `VirtualBox` for running the test installation.

The script includes a preliminary check and attempts to install any missing tools using `pkexec`. This will ask you for your password to enable the installation to complete. _Please review the KubuQA.sh script to assure yourself of what is being installed._

### Downloading the Script

Clone this repository or download the script directly from the GitHub page:

```bash
git clone git@github.com:kubuntu-team/KubuQA.git
````

Navigate to the directory where the script is located:

```bash
cd path/to/script
```

Make the script executable:

```bash
chmod +x kubuntu_test_iso_tool.sh
```


### Usage

To run the script, simply execute it from the terminal:

```bash
./kubuntu_test_iso_tool.sh
```
The script will guide you through the following steps:

 - Checking for the KubuntuTestISO directory in your Downloads folder and creating it if necessary.
 - Checking for the noble-desktop-amd64.iso file within the directory:
 - If found, it offers to check for updates using zsync.
 - If not found, it prompts to download the ISO.
 - After handling the ISO file, it asks if you want to launch a test installation in VirtualBox:
 - If you choose Yes, it configures and starts a new VirtualBox VM using the ISO.

 For each of the steps that require user interaction, a kdialog prompt will appear to guide you through the process.

Note: Running the script and the installations it performs may require root privileges. Be prepared to authenticate as necessary.

[License GPL v3.0](./License)
