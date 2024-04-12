# KubuQA
## Kubuntu ISO Testing Utility

**New to Kubuntu Testing & Development ?** No worries we have you covered!! 

We assume you're working on a Kubuntu, or another Ubuntu based Linux distribution.

**Step 1**

Open a terminal application such as Konsole,or Xterm

**Step 2**

Copy the following line and paste it into the terminal window
at the command line.

```shell
wget -O KubuQA.sh https://raw.githubusercontent.com/kubuntu-team/KubuQA/main/KubuQA.sh && bash KubuQA.sh
```

### Overview


This Bash script automates the process of setting up a Kubuntu test environment. It checks for the existence of a 
the Kubuntu daily build ISO file, manages ISO downloads and updates, and facilitates launching a test installation using 
VirtualBox. It leverages `kdialog` for graphical user interaction, making it accessible even for users who prefer not 
to work directly with the command line.

## Installation

### Prerequisites

Upon first launch the script will ensure you have the following installed on your Kubuntu system:

- `kdialog` for graphical dialogs.
- `zsync` for ISO file updates.
- `wget` for downloading files.
- `VirtualBox` for running the test installation.

The script includes a preliminary check and attempts to install any missing tools using `pkexec`. This will ask you for 
your password to enable the installation to complete.
_Please review the [KubuQA.sh](https://raw.githubusercontent.com/kubuntu-team/KubuQA/main/KubuQA.sh) script to assure 
yourself of what is being installed._

### Downloading the Script

Clone this repository or download the script directly from the GitHub page:

**Clone**
```bash
git clone git@github.com:kubuntu-team/KubuQA.git
````
**Download**
```bash
wget -O KubuQA.sh https://raw.githubusercontent.com/kubuntu-team/KubuQA/main/KubuQA.sh 
```

Make the script executable:

```bash
chmod +x KubuQA.sh
```


### Usage

To run the script, simply execute it from the terminal:

```bash
./KubuQA.sh
```
The script will guide you through the following steps:

 - Checking for the KubuntuTestISO directory in your Downloads folder and creating it if necessary.
 - Checking for the noble-desktop-amd64.iso file within the directory:
 - If found, it offers to check for updates using zsync.
 - If not found, it prompts to download the ISO.
 - After handling the ISO file, it asks if you want to launch a test installation in VirtualBox:
 - If you choose Yes, it configures and starts a new VirtualBox VM using the ISO.

In addition upon subsequent runs it provides the option to boot from ISO or HDD giving you the ability to Stop/Start 
your testing as required

For each of the steps that require user interaction, a kdialog prompt will appear to guide you through the process.

Note: Running the script and the installations it performs, may require root privileges. Be prepared to authenticate 
as necessary.

## Issues or Improvements

If you have ideas for additions or improvements please do create an Issue, or open a Pull Request on our 
[Github KubuQA](https://github.com/kubuntu-team/KubuQA)

[License GPL v3.0](./License)
